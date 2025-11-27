import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'screens/main_menu_screen.dart';
import 'services/game_state_service.dart';
import 'services/settings_service.dart';
import 'services/achievement_service.dart';
import 'services/challenge_service.dart';
import 'widgets/toast_notification.dart';
import 'widgets/error_boundary.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Initialize Services
  await SettingsService.init();
  await AchievementService.init();
  await ChallengeService.init();
  
  runApp(const PopMusicGame());
}

class PopMusicGame extends StatelessWidget {
  const PopMusicGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final gameService = GameStateService();
            // Removed initializeWorld call as it's no longer needed.
            // gameService.initializeWorld(NPCArtists.artistNames);
            return gameService;
          },
        ),
        ChangeNotifierProvider(create: (_) => SettingsService()),
        ChangeNotifierProvider(create: (_) => AchievementService()),
      ],
      child: MaterialApp(
        title: 'PopMusic',
        theme: AppTheme.getDarkTheme(),
        builder: (context, child) {
          return ErrorBoundary(
            child: ToastContainer(child: child!),
          );
        },
        home: const MainMenuScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
