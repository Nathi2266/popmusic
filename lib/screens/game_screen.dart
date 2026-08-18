import 'package:flutter/material.dart';

import '../theme/game_palette.dart';
import '../widgets/game_shell.dart';
import 'activities_screen.dart';
import 'artists_screen.dart';
import 'career_screen.dart';
import 'challenges_screen.dart';
import 'charts_screen.dart';
import 'dashboard_screen.dart';
import 'labels_screen.dart';
import 'lifestyle_screen.dart';
import 'music_screen.dart';
import 'performance_screen.dart';
import 'settings_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    MusicScreen(),
    ActivitiesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return GameShell(
      openDrawer: () => _scaffoldKey.currentState?.openDrawer(),
      child: Scaffold(
        key: _scaffoldKey,
        drawer: const _GameDrawer(),
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: p.navBar,
          selectedItemColor: p.primary,
          unselectedItemColor: p.textFaint,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.music_note),
              label: 'Music',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event),
              label: 'Activities',
            ),
          ],
        ),
      ),
    );
  }
}

class _GameDrawer extends StatelessWidget {
  const _GameDrawer();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Drawer(
      backgroundColor: p.scaffold,
      child: Column(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).padding.top + kToolbarHeight,
            decoration: BoxDecoration(color: p.appBar),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Text(
              'More',
              style: TextStyle(
                color: p.text,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _tile(
                  context,
                  icon: Icons.show_chart,
                  title: 'Charts',
                  screen: const ChartsScreen(),
                ),
                _tile(
                  context,
                  icon: Icons.mic,
                  title: 'Perform',
                  screen: const PerformanceScreen(),
                ),
                _tile(
                  context,
                  icon: Icons.people,
                  title: 'Artists',
                  screen: const ArtistsScreen(),
                ),
                _tile(
                  context,
                  icon: Icons.star,
                  title: 'Career',
                  screen: const CareerScreen(),
                ),
                _tile(
                  context,
                  icon: Icons.flag,
                  title: 'Challenges',
                  screen: const ChallengesScreen(),
                ),
                _tile(
                  context,
                  icon: Icons.diamond_outlined,
                  title: 'Lifestyle',
                  screen: const LifestyleScreen(),
                ),
                _tile(
                  context,
                  icon: Icons.album_outlined,
                  title: 'Record Labels',
                  screen: const LabelsScreen(),
                ),
                _tile(
                  context,
                  icon: Icons.settings,
                  title: 'Settings',
                  screen: const SettingsScreen(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.exit_to_app),
              label: const Text('Exit Game'),
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.red.shade700,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget screen,
  }) {
    final p = context.palette;
    return ListTile(
      leading: Icon(icon, color: p.textMuted),
      title: Text(title, style: TextStyle(color: p.text)),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
      },
    );
  }
}
