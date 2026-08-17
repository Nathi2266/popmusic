import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';
import '../services/game_state_service.dart';
import '../theme/game_palette.dart';
import '../utils/toast_service.dart';
import 'main_menu_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Consumer<SettingsService>(
      builder: (context, settings, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Settings'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SettingsSection(
                title: 'Theme',
                icon: Icons.palette,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Text(
                      'Applies to every screen. Pick light, dark, or a custom look.',
                      style: TextStyle(color: p.textMuted, fontSize: 13),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: AppThemeId.values.map((id) {
                        final selected = settings.themeId == id;
                        final swatch = GamePalette.forId(id);
                        return SizedBox(
                          width: 156,
                          child: Material(
                            color: swatch.card,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                settings.setThemeId(id);
                                ToastService().showInfo('${id.displayName} theme on');
                              },
                              child: Semantics(
                                button: true,
                                selected: selected,
                                label: '${id.displayName} theme. ${id.blurb}',
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: selected
                                          ? swatch.primary
                                          : swatch.divider,
                                      width: selected ? 2 : 1,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(id.icon,
                                              color: swatch.primary, size: 20),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              id.displayName,
                                              style: TextStyle(
                                                color: swatch.text,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          if (selected)
                                            Icon(Icons.check_circle,
                                                color: swatch.primary, size: 18),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          _Swatch(swatch.scaffold),
                                          _Swatch(swatch.appBar),
                                          _Swatch(swatch.primary),
                                          _Swatch(swatch.gold),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        id.blurb,
                                        style: TextStyle(
                                          color: swatch.textMuted,
                                          fontSize: 11,
                                          height: 1.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _SettingsSection(
                title: 'Audio',
                icon: Icons.volume_up,
                children: [
                  SwitchListTile(
                    title: Text('Sound Effects'),
                    subtitle: Text('Enable sound effects for game actions'),
                    value: settings.soundEnabled,
                    onChanged: (value) {
                      settings.setSoundEnabled(value);
                      ToastService().showInfo(
                        value
                            ? 'Sound effects enabled'
                            : 'Sound effects disabled',
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: Text('Music Volume'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${(settings.musicVolume * 100).toInt()}%'),
                        Slider(
                          value: settings.musicVolume,
                          onChanged: settings.setMusicVolume,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _SettingsSection(
                title: 'Text',
                icon: Icons.format_size,
                children: [
                  ListTile(
                    title: Text('Font Size'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${(settings.fontSize * 100).toInt()}%'),
                        Slider(
                          value: settings.fontSize,
                          min: 0.8,
                          max: 1.5,
                          divisions: 7,
                          label: '${(settings.fontSize * 100).toInt()}%',
                          onChanged: settings.setFontSize,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _SettingsSection(
                title: 'Game',
                icon: Icons.sports_esports,
                children: [
                  Consumer<GameStateService>(
                    builder: (context, gameState, child) {
                      return ListTile(
                        title: Text('Reset Game Data'),
                        subtitle: Text(
                          'Delete all saved game progress',
                        ),
                        leading: Icon(Icons.delete_outline,
                            color: Theme.of(context).colorScheme.error),
                        onTap: () => _showResetGameDialog(context, gameState),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: Text('Reset Settings'),
                    subtitle: Text(
                      'Restore all settings to default values',
                    ),
                    leading: Icon(Icons.restore, color: p.gold),
                    onTap: () => _showResetSettingsDialog(context, settings),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const _SettingsSection(
                title: 'About',
                icon: Icons.info,
                children: [
                  ListTile(
                    title: Text('Version'),
                    subtitle: Text('1.0.0'),
                  ),
                  Divider(),
                  ListTile(
                    title: Text('Description'),
                    subtitle: Text(
                      'PopMusic is a music industry simulation game where you build your career as an artist.',
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
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset Game Data'),
        content: Text(
          'This will delete all your game progress including your artist, songs, and achievements. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
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
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showResetSettingsDialog(
    BuildContext context,
    SettingsService settings,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset Settings'),
        content: Text(
          'This will restore all settings to their default values.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              settings.resetToDefaults();
              Navigator.pop(context);
              ToastService().showSuccess('Settings reset to defaults');
            },
            child: Text('Reset'),
          ),
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  final Color color;
  const _Swatch(this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      margin: const EdgeInsets.only(right: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.black26),
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
    final p = context.palette;
    return Container(
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: p.primary, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: p.text,
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
