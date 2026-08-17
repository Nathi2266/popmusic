import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../theme/game_palette.dart';

class SettingsService extends ChangeNotifier {
  static const String _settingsBoxName = 'settings';
  static Box? _settingsBox;

  static const String _soundEnabledKey = 'sound_enabled';
  static const String _musicEnabledKey = 'music_enabled';
  static const String _musicVolumeKey = 'music_volume';
  static const String _themeKey = 'theme';
  static const String _fontSizeKey = 'font_size';

  bool _soundEnabled = true;
  bool _musicEnabled = true;
  double _musicVolume = 0.7;
  AppThemeId _themeId = AppThemeId.dark;
  double _fontSize = 1.0;

  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;
  double get musicVolume => _musicVolume;
  AppThemeId get themeId => _themeId;
  String get theme => _themeId.storageName;
  double get fontSize => _fontSize;

  static Future<void> init() async {
    _settingsBox = await Hive.openBox(_settingsBoxName);
  }

  SettingsService() {
    _loadSettings();
  }

  void _loadSettings() {
    if (_settingsBox == null) return;

    _soundEnabled =
        _settingsBox!.get(_soundEnabledKey, defaultValue: true) as bool;
    _musicEnabled =
        _settingsBox!.get(_musicEnabledKey, defaultValue: true) as bool;
    _musicVolume =
        (_settingsBox!.get(_musicVolumeKey, defaultValue: 0.7) as num)
            .toDouble();
    _themeId = AppThemeId.fromName(
      _settingsBox!.get(_themeKey, defaultValue: 'dark') as String?,
    );
    _fontSize =
        (_settingsBox!.get(_fontSizeKey, defaultValue: 1.0) as num).toDouble();
    notifyListeners();
  }

  Future<void> setSoundEnabled(bool value) async {
    _soundEnabled = value;
    await _settingsBox?.put(_soundEnabledKey, value);
    notifyListeners();
  }

  Future<void> setMusicEnabled(bool value) async {
    _musicEnabled = value;
    await _settingsBox?.put(_musicEnabledKey, value);
    notifyListeners();
  }

  Future<void> setMusicVolume(double value) async {
    _musicVolume = value.clamp(0.0, 1.0);
    await _settingsBox?.put(_musicVolumeKey, _musicVolume);
    notifyListeners();
  }

  Future<void> setTheme(String value) async {
    await setThemeId(AppThemeId.fromName(value));
  }

  Future<void> setThemeId(AppThemeId value) async {
    _themeId = value;
    await _settingsBox?.put(_themeKey, value.storageName);
    notifyListeners();
  }

  Future<void> setFontSize(double value) async {
    _fontSize = value.clamp(0.8, 1.5);
    await _settingsBox?.put(_fontSizeKey, _fontSize);
    notifyListeners();
  }

  Future<void> resetToDefaults() async {
    _soundEnabled = true;
    _musicEnabled = true;
    _musicVolume = 0.7;
    _themeId = AppThemeId.dark;
    _fontSize = 1.0;
    await _settingsBox?.clear();
    notifyListeners();
  }
}
