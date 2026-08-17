/// Shared theme-music configuration (kept free of platform imports).
class ThemeMusicConfig {
  /// Override at build time: `--dart-define=THEME_MUSIC_URL=https://...`
  static const String remoteUrl = String.fromEnvironment(
    'THEME_MUSIC_URL',
    defaultValue:
        'https://raw.githubusercontent.com/Nathi2266/popmusic/main/web/audio/theme_music.mp3',
  );
}
