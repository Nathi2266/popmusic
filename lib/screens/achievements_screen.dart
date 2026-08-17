import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/achievement_service.dart';
import '../models/achievement.dart';
import '../widgets/achievement_badge.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  AchievementType? _selectedFilter;

  @override
  Widget build(BuildContext context) {
    return Consumer<AchievementService>(
      builder: (context, achievementService, child) {
        final achievements = _selectedFilter == null
            ? achievementService.achievements
            : achievementService.getAchievementsByType(_selectedFilter!);

        final unlockedCount = achievementService.getTotalUnlockedCount();
        final totalCount = achievementService.achievements.length;
        final completionPercentage = achievementService.getCompletionPercentage();

        return Scaffold(
          appBar: AppBar(
            title: Text('Achievements'),
                      ),
          body: Column(
            children: [
              // Progress Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$unlockedCount / $totalCount',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: completionPercentage / 100,
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                      minHeight: 8,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${completionPercentage.toStringAsFixed(1)}% Complete',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.72),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // Filter Chips
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'All',
                        isSelected: _selectedFilter == null,
                        onSelected: () {
                          setState(() {
                            _selectedFilter = null;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      ...AchievementType.values.map((type) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _FilterChip(
                            label: _getTypeName(type),
                            isSelected: _selectedFilter == type,
                            onSelected: () {
                              setState(() {
                                _selectedFilter = _selectedFilter == type
                                    ? null
                                    : type;
                              });
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              // Achievements List
              Expanded(
                child: achievements.isEmpty
                    ? Center(
                        child: Text(
                          'No achievements found',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54)),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: achievements.length,
                        itemBuilder: (context, index) {
                          final achievement = achievements[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: AchievementBadge(
                              achievement: achievement,
                              showProgress: true,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getTypeName(AchievementType type) {
    switch (type) {
      case AchievementType.song:
        return 'Songs';
      case AchievementType.performance:
        return 'Performances';
      case AchievementType.fan:
        return 'Fans';
      case AchievementType.money:
        return 'Money';
      case AchievementType.chart:
        return 'Charts';
      case AchievementType.career:
        return 'Career';
      case AchievementType.milestone:
        return 'Milestones';
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      backgroundColor: Theme.of(context).colorScheme.surface,
      selectedColor: Theme.of(context).colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.white70,
      ),
    );
  }
}

