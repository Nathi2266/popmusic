import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'screens/main_menu_screen.dart';
import 'services/game_state_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  runApp(const PopMusicGame());
}

class PopMusicGame extends StatefulWidget {
  const PopMusicGame({super.key});

  @override
  State<PopMusicGame> createState() => _PopMusicGameState();
}

class _PopMusicGameState extends State<PopMusicGame> {
  late Future<GameStateService> _gameStateServiceFuture;

  @override
  void initState() {
    super.initState();
    _gameStateServiceFuture = _initializeGame();
  }

  Future<GameStateService> _initializeGame() async {
    final gameService = GameStateService();
    await gameService.initHive();
    return gameService;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<GameStateService>(
      future: _gameStateServiceFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return ChangeNotifierProvider<GameStateService>(
              create: (_) => snapshot.data!,
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
        } else {
          return const Center(child: CircularProgressIndicator()); // Loading indicator
        }
      },
    );
  }
}
