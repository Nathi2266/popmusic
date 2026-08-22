import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/widgets.dart';

import 'settings_service.dart';
import 'theme_music_config.dart';
import 'theme_music_local.dart'
    if (dart.library.html) 'theme_music_local_web.dart' as local;

/// Loops the main theme until the player turns music off in Settings.
class ThemeMusicService with WidgetsBindingObserver {
  ThemeMusicService(this._settings);

  final SettingsService _settings;
  final AudioPlayer _player = AudioPlayer();

  bool _started = false;
  bool _loading = false;
  VoidCallback? _settingsListener;
  StreamSubscription<ProcessingState>? _stateSub;

  Future<void> start() async {
    if (_started) return;
    _started = true;

    WidgetsBinding.instance.addObserver(this);
    _settingsListener = () => unawaited(_applySettings());
    _settings.addListener(_settingsListener!);

    _stateSub = _player.processingStateStream.listen((state) {
      if (!_settings.musicEnabled) return;
      if (state == ProcessingState.completed) {
        unawaited(_restartFromStart());
      }
    });

    try {
      await _player.setLoopMode(LoopMode.one);
    } catch (_) {}

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

  Future<void> _restartFromStart() async {
    if (!_settings.musicEnabled) return;
    try {
      await _player.setLoopMode(LoopMode.one);
      await _player.seek(Duration.zero);
      await _player.setVolume(_settings.musicVolume);
      await _player.play();
    } catch (e) {
      debugPrint('Theme music restart failed: $e');
      await _ensurePlaying(forceReload: true);
    }
  }

  Future<void> _ensurePlaying({bool forceReload = false}) async {
    if (!_settings.musicEnabled || _loading) return;

    if (!forceReload &&
        _player.audioSource != null &&
        _player.playing &&
        _player.processingState != ProcessingState.completed) {
      return;
    }

    if (!forceReload && _player.audioSource != null) {
      try {
        await _player.setLoopMode(LoopMode.one);
        if (_player.processingState == ProcessingState.completed) {
          await _player.seek(Duration.zero);
        }
        await _player.setVolume(_settings.musicVolume);
        await _player.play();
        return;
      } catch (e) {
        debugPrint('Theme music resume failed: $e');
      }
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
      await _player.setLoopMode(LoopMode.one);
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
    return AudioSource.asset(ThemeMusicConfig.assetPath);
  }

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
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        break;
    }
  }

  Future<void> dispose() async {
    await _stateSub?.cancel();
    _stateSub = null;
    if (_settingsListener != null) {
      _settings.removeListener(_settingsListener!);
      _settingsListener = null;
    }
    WidgetsBinding.instance.removeObserver(this);
    await _player.dispose();
  }
}
