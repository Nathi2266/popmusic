// ignore_for_file: unused_element_parameter

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'screens/main_menu_screen.dart';
import 'services/game_state_service.dart';
import 'services/settings_service.dart';
import 'services/achievement_service.dart';
import 'services/challenge_service.dart';
import 'services/theme_music_service.dart';
import 'widgets/toast_notification.dart';
import 'widgets/error_boundary.dart';
import 'theme/app_theme.dart';
import 'theme/game_palette.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _BootstrapApp());
}

class _BootstrapApp extends StatefulWidget {
  const _BootstrapApp({super.key});

  @override
  State<_BootstrapApp> createState() => _BootstrapAppState();
}

class _BootstrapAppState extends State<_BootstrapApp> {
  late final Future<void> _initFuture = _initialize();

  Future<void> _initialize() async {
    await Hive.initFlutter();
    await SettingsService.init();
    await AchievementService.init();
    await ChallengeService.init();
    await GameStateService.init();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return MaterialApp(
            theme: AppTheme.getDarkTheme(),
            home: const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
            debugShowCheckedModeBanner: false,
          );
        }

        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text('Failed to start app: ${snapshot.error}'),
              ),
            ),
          );
        }

        return const PopMusicGame();
      },
    );
  }
}

class PopMusicGame extends StatelessWidget {
  const PopMusicGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => GameStateService(),
        ),
        ChangeNotifierProvider(create: (_) => SettingsService()),
        ProxyProvider<SettingsService, ThemeMusicService>(
          lazy: false,
          update: (_, settings, previous) {
            if (previous != null) return previous;
            final music = ThemeMusicService(settings);
            // ignore: discarded_futures
            music.start();
            return music;
          },
          dispose: (_, music) {
            // ignore: discarded_futures
            music.dispose();
          },
        ),
        ChangeNotifierProxyProvider<GameStateService, AchievementService>(
          create: (_) => AchievementService(),
          update: (_, game, achievements) {
            final service = achievements ?? AchievementService();
            game.attachAchievements(service);
            return service;
          },
        ),
        ChangeNotifierProxyProvider<GameStateService, ChallengeService>(
          create: (_) => ChallengeService(),
          update: (_, game, challenges) {
            final service = challenges ?? ChallengeService();
            service.attachGame(game);
            game.attachChallenges(service);
            return service;
          },
        ),
      ],
      child: Consumer<SettingsService>(
        builder: (context, settings, _) {
          final theme = AppTheme.fromId(settings.themeId);
          return MaterialApp(
            title: 'PopMusic',
            theme: theme,
            builder: (context, child) {
              final p = context.palette;
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(settings.fontSize),
                ),
                child: ErrorBoundary(
                  child: DefaultTextStyle(
                    style: TextStyle(
                      color: p.text,
                      fontFamily: AppTheme.fontFamily,
                    ),
                    child: IconTheme(
                      data: IconThemeData(color: p.text),
                      child: ToastContainer(child: child!),
                    ),
                  ),
                ),
              );
            },
            home: const MainMenuScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
