import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'screens/main_menu_screen.dart';
import 'services/game_state_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  runApp(const PopMusicGame());
}

class PopMusicGame extends StatelessWidget {
  const PopMusicGame({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final gameService = GameStateService();
        // Removed initializeWorld call as it's no longer needed.
        // gameService.initializeWorld(NPCArtists.artistNames);
        return gameService;
      },
      child: MaterialApp(
        title: 'PopMusic',
        theme: ThemeData(
          primarySwatch: Colors.purple,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF1a1a2e),
          fontFamily: 'Arial',
        ),
        home: const MainMenuScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
