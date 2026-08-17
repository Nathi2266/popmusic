import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/widgets.dart';

import 'settings_service.dart';
import 'theme_music_config.dart';
import 'theme_music_local.dart'
    if (dart.library.html) 'theme_music_local_web.dart' as local;

/// Loops the main theme. Uses a bundled asset on mobile/desktop; web serves
/// `web/audio/theme_music.mp3`. Respects Settings → Music on/off and volume.
class ThemeMusicService with WidgetsBindingObserver {
  ThemeMusicService(this._settings);

  final SettingsService _settings;
  final AudioPlayer _player = AudioPlayer();

  bool _started = false;
  bool _loading = false;
  VoidCallback? _settingsListener;

  Future<void> start() async {
    if (_started) return;
    _started = true;

    WidgetsBinding.instance.addObserver(this);
    _settingsListener = () => unawaited(_applySettings());
    _settings.addListener(_settingsListener!);

    await _player.setLoopMode(LoopMode.one);
    await _applySettings();
  }

  Future<void> _applySettings() async {
    await _player.setVolume(_settings.musicVolume);
    if (!_settings.musicEnabled) {
      await _player.pause();
      return;
    }
    await _ensurePlaying();
  }

  Future<void> _ensurePlaying() async {
    if (!_settings.musicEnabled || _loading) return;

    if (_player.playing) return;

    if (_player.audioSource != null) {
      try {
        await _player.play();
      } catch (e) {
        debugPrint('Theme music resume failed: $e');
      }
      return;
    }

    _loading = true;
    try {
      AudioSource? source = await _resolveSource();
      if (source == null) return;
      try {
        await _player.setAudioSource(source);
      } catch (e) {
        debugPrint('Theme music asset load failed, trying fallback: $e');
        source = await _resolveFallbackSource();
        if (source == null) return;
        await _player.setAudioSource(source);
      }
      if (_settings.musicEnabled) {
        await _player.setVolume(_settings.musicVolume);
        await _player.play();
      }
    } catch (e) {
      debugPrint('Theme music failed to start: $e');
    } finally {
      _loading = false;
    }
  }

  Future<AudioSource?> _resolveSource() async {
    if (kIsWeb) {
      return AudioSource.uri(Uri.parse('audio/theme_music.mp3'));
    }

    // Primary: bundled asset (works offline in release builds).
    return AudioSource.asset(ThemeMusicConfig.assetPath);
  }

  /// Optional fallback if asset load fails (e.g. missing from bundle).
  Future<AudioSource?> _resolveFallbackSource() async {
    final localPath = await local.resolveLocalThemePath();
    if (localPath != null) {
      return AudioSource.uri(Uri.file(localPath));
    }
    if (ThemeMusicConfig.remoteUrl.isNotEmpty) {
      return AudioSource.uri(Uri.parse(ThemeMusicConfig.remoteUrl));
    }
    return null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_settings.musicEnabled) return;
    switch (state) {
      case AppLifecycleState.resumed:
        unawaited(_ensurePlaying());
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        unawaited(_player.pause());
        break;
    }
  }

  Future<void> dispose() async {
    if (_settingsListener != null) {
      _settings.removeListener(_settingsListener!);
      _settingsListener = null;
    }
    WidgetsBinding.instance.removeObserver(this);
    await _player.dispose();
  }
}
