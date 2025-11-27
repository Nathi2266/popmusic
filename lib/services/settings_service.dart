import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsService extends ChangeNotifier {
  static const String _settingsBoxName = 'settings';
  static Box? _settingsBox;

  // Settings keys
  static const String _soundEnabledKey = 'sound_enabled';
  static const String _musicVolumeKey = 'music_volume';
  static const String _themeKey = 'theme';
  static const String _fontSizeKey = 'font_size';

  // Default values
  bool _soundEnabled = true;
  double _musicVolume = 0.7;
  String _theme = 'dark';
  double _fontSize = 1.0;

  // Getters
  bool get soundEnabled => _soundEnabled;
  double get musicVolume => _musicVolume;
  String get theme => _theme;
  double get fontSize => _fontSize;

  // Initialize settings
  static Future<void> init() async {
    _settingsBox = await Hive.openBox(_settingsBoxName);
  }

  SettingsService() {
    _loadSettings();
  }

  void _loadSettings() {
    if (_settingsBox == null) return;

    _soundEnabled = _settingsBox!.get(_soundEnabledKey, defaultValue: true) as bool;
    _musicVolume = _settingsBox!.get(_musicVolumeKey, defaultValue: 0.7) as double;
    _theme = _settingsBox!.get(_themeKey, defaultValue: 'dark') as String;
    _fontSize = _settingsBox!.get(_fontSizeKey, defaultValue: 1.0) as double;
    notifyListeners();
  }

  Future<void> setSoundEnabled(bool value) async {
    _soundEnabled = value;
    await _settingsBox?.put(_soundEnabledKey, value);
    notifyListeners();
  }

  Future<void> setMusicVolume(double value) async {
    _musicVolume = value.clamp(0.0, 1.0);
    await _settingsBox?.put(_musicVolumeKey, _musicVolume);
    notifyListeners();
  }

  Future<void> setTheme(String value) async {
    _theme = value;
    await _settingsBox?.put(_themeKey, value);
    notifyListeners();
  }

  Future<void> setFontSize(double value) async {
    _fontSize = value.clamp(0.8, 1.5);
    await _settingsBox?.put(_fontSizeKey, _fontSize);
    notifyListeners();
  }

  Future<void> resetToDefaults() async {
    _soundEnabled = true;
    _musicVolume = 0.7;
    _theme = 'dark';
    _fontSize = 1.0;
    await _settingsBox?.clear();
    notifyListeners();
  }
}

