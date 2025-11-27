import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';
import '../services/game_state_service.dart';
import '../utils/toast_service.dart';
import 'main_menu_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsService>(
      builder: (context, settings, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Settings'),
            backgroundColor: const Color(0xFF16213e),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Audio Settings
              _SettingsSection(
                title: 'Audio',
                icon: Icons.volume_up,
                children: [
                  SwitchListTile(
                    title: const Text('Sound Effects', style: TextStyle(color: Colors.white)),
                    subtitle: const Text('Enable sound effects for game actions', style: TextStyle(color: Colors.white70)),
                    value: settings.soundEnabled,
                    onChanged: (value) {
                      settings.setSoundEnabled(value);
                      ToastService().showInfo(value ? 'Sound effects enabled' : 'Sound effects disabled');
                    },
                    activeTrackColor: const Color(0xFFe94560),
                  ),
                  const Divider(color: Colors.white24),
                  ListTile(
                    title: const Text('Music Volume', style: TextStyle(color: Colors.white)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${(settings.musicVolume * 100).toInt()}%', style: const TextStyle(color: Colors.white70)),
                        const SizedBox(height: 8),
                        Slider(
                          value: settings.musicVolume,
                          onChanged: (value) {
                            settings.setMusicVolume(value);
                          },
                          activeColor: const Color(0xFFe94560),
                          inactiveColor: Colors.white24,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Appearance Settings
              _SettingsSection(
                title: 'Appearance',
                icon: Icons.palette,
                children: [
                  ListTile(
                    title: const Text('Theme', style: TextStyle(color: Colors.white)),
                    subtitle: const Text('Choose your preferred theme', style: TextStyle(color: Colors.white70)),
                    trailing: DropdownButton<String>(
                      value: settings.theme,
                      dropdownColor: const Color(0xFF2a2a3e),
                      style: const TextStyle(color: Colors.white),
                      items: const [
                        DropdownMenuItem(value: 'dark', child: Text('Dark')),
                        DropdownMenuItem(value: 'darker', child: Text('Darker')),
                        DropdownMenuItem(value: 'neon', child: Text('Neon')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          settings.setTheme(value);
                          ToastService().showInfo('Theme changed to ${value.capitalize()}');
                        }
                      },
                    ),
                  ),
                  const Divider(color: Colors.white24),
                  ListTile(
                    title: const Text('Font Size', style: TextStyle(color: Colors.white)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${(settings.fontSize * 100).toInt()}%', style: const TextStyle(color: Colors.white70)),
                        const SizedBox(height: 8),
                        Slider(
                          value: settings.fontSize,
                          min: 0.8,
                          max: 1.5,
                          divisions: 7,
                          label: '${(settings.fontSize * 100).toInt()}%',
                          onChanged: (value) {
                            settings.setFontSize(value);
                          },
                          activeColor: const Color(0xFFe94560),
                          inactiveColor: Colors.white24,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Game Settings
              _SettingsSection(
                title: 'Game',
                icon: Icons.sports_esports,
                children: [
                  Consumer<GameStateService>(
                    builder: (context, gameState, child) {
                      return ListTile(
                        title: const Text('Reset Game Data', style: TextStyle(color: Colors.white)),
                        subtitle: const Text('Delete all saved game progress', style: TextStyle(color: Colors.white70)),
                        leading: const Icon(Icons.delete_outline, color: Color(0xFFF44336)),
                        onTap: () {
                          _showResetGameDialog(context, gameState);
                        },
                      );
                    },
                  ),
                  const Divider(color: Colors.white24),
                  ListTile(
                    title: const Text('Reset Settings', style: TextStyle(color: Colors.white)),
                    subtitle: const Text('Restore all settings to default values', style: TextStyle(color: Colors.white70)),
                    leading: const Icon(Icons.restore, color: Color(0xFFFF9800)),
                    onTap: () {
                      _showResetSettingsDialog(context, settings);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // About Section
              const _SettingsSection(
                title: 'About',
                icon: Icons.info,
                children: [
                  ListTile(
                    title: Text('Version', style: TextStyle(color: Colors.white)),
                    subtitle: Text('1.0.0', style: TextStyle(color: Colors.white70)),
                  ),
                  Divider(color: Colors.white24),
                  ListTile(
                    title: Text('Description', style: TextStyle(color: Colors.white)),
                    subtitle: Text(
                      'PopMusic is a music industry simulation game where you build your career as an artist.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showResetGameDialog(BuildContext context, GameStateService gameState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2a2a3e),
        title: const Text('Reset Game Data', style: TextStyle(color: Colors.white)),
        content: const Text(
          'This will delete all your game progress including your artist, songs, and achievements. This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
            ElevatedButton(
            onPressed: () {
              gameState.resetGame();
              
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MainMenuScreen()),
              );
              ToastService().showSuccess('Game data reset successfully');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF44336),
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showResetSettingsDialog(BuildContext context, SettingsService settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2a2a3e),
        title: const Text('Reset Settings', style: TextStyle(color: Colors.white)),
        content: const Text(
          'This will restore all settings to their default values.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              settings.resetToDefaults();
              Navigator.pop(context);
              ToastService().showSuccess('Settings reset to defaults');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFe94560),
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2a2a3e),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFFe94560), size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
