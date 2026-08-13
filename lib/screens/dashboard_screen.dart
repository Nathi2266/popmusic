import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_state_service.dart';
import '../widgets/attribute_bar.dart';
import '../widgets/stat_card.dart';
import 'performance_screen.dart';
import 'create_song_screen.dart';
import '../models/song.dart';
import '../models/label_tier.dart';
import 'weekly_events_and_proceed_button.dart';
import 'charts_screen.dart';
import 'lifestyle_screen.dart';
import '../widgets/error_widget.dart';
import '../widgets/xp_bar.dart';
import '../utils/toast_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameStateService>(
      builder: (context, gameState, child) {
        final player = gameState.player; // Assuming player is still accessible, but its structure has changed.
        
        if (player == null) {
          return const Scaffold(
            body: CustomErrorWidget(
              message: 'No player data',
              details: 'Please start a new game to begin playing.',
              icon: Icons.person_off,
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(player.name),
            backgroundColor: const Color(0xFF16213e),
            leading: Builder(
              builder: (BuildContext context) {
                return IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                  tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
                );
              },
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Center(
                  child: Text(
                    'W${gameState.weekOfMonth} M${gameState.month} ${gameState.year}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const ProceedWeekButton(),
            ],
          ),
          drawer: Drawer(
            backgroundColor: const Color(0xFF1a1a2e), // Set a consistent background color
            child: Column(
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).padding.top + kToolbarHeight, // Status bar + AppBar height
                  decoration: const BoxDecoration(
                    color: Color(0xFF16213e),
                  ),
                  child: const SizedBox.shrink(), // Empty child
                ),
                // Other drawer items can go here
                ListTile(
                  leading: const Icon(Icons.show_chart, color: Colors.white70),
                  title: const Text('Charts', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context); // Close the drawer
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ChartsScreen()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.diamond_outlined, color: Colors.white70),
                  title: const Text('Lifestyle', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LifestyleScreen(),
                      ),
                    );
                  },
                ),
                const Spacer(), // Pushes the exit button to the bottom
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.exit_to_app),
                    label: const Text('Exit Game'),
                    onPressed: () {
                      // Implement exit game logic here
                      // For example, navigate to main menu or close the app
                      Navigator.of(context).popUntil((route) => route.isFirst); // Example: Pop all routes to main menu
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50), // Make button full width
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Level and XP
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2a2a3e),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: XpBar(
                      playerLevel: gameState.getPlayerLevel(),
                      showLevel: true,
                      showXpText: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2a2a3e),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF2196F3).withAlpha(80),
                      ),
                    ),
                    child: Text(
                      'This week: ${gameState.weeklyGoalHint}',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  if (gameState.fanClubFounded ||
                      gameState.streetTeamWeeksRemaining > 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF66BB6A).withAlpha(40),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF66BB6A).withAlpha(160),
                        ),
                      ),
                      child: Text(
                        [
                          if (gameState.fanClubFounded)
                            'Fan club: ${gameState.fanClubMembers} members · \$${gameState.fanClubUpkeep.toStringAsFixed(0)}/wk',
                          if (gameState.streetTeamWeeksRemaining > 0)
                            'Street team converting fans → streams (${gameState.streetTeamWeeksRemaining}w)',
                        ].join(' · '),
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                  if (gameState.afterpartyBuzzWeeks > 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFB74D).withAlpha(40),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFFFB74D).withAlpha(160),
                        ),
                      ),
                      child: Text(
                        gameState.afterpartyBanner,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                  if (gameState.radioLiveWeeksRemaining > 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4FC3F7).withAlpha(40),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF4FC3F7).withAlpha(160),
                        ),
                      ),
                      child: Text(
                        gameState.radioLiveBanner,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                  if (gameState.demoLeakHeatWeeks > 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF5350).withAlpha(40),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFEF5350).withAlpha(160),
                        ),
                      ),
                      child: Text(
                        gameState.demoLeakBanner,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                  if (gameState.producerCreditWeeks > 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFAB47BC).withAlpha(40),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFAB47BC).withAlpha(160),
                        ),
                      ),
                      child: Text(
                        gameState.producerBeefBanner,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                  if (gameState.mentorCosignWeeks > 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7E57C2).withAlpha(40),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF7E57C2).withAlpha(160),
                        ),
                      ),
                      child: Text(
                        gameState.mentorCosignBanner,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                  if (gameState.meetGreetWeeks > 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEC407A).withAlpha(40),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFEC407A).withAlpha(160),
                        ),
                      ),
                      child: Text(
                        gameState.meetGreetBanner,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                  if (gameState.danceChallengeWeeks > 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF26A69A).withAlpha(40),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF26A69A).withAlpha(160),
                        ),
                      ),
                      child: Text(
                        gameState.danceChallengeBanner,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                  if (gameState.brandDealWeeks > 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFCA28).withAlpha(40),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFFFCA28).withAlpha(160),
                        ),
                      ),
                      child: Text(
                        gameState.brandDealBanner,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                  if (gameState.chartWagerWeeks > 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD54F).withAlpha(40),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFFFD54F).withAlpha(160),
                        ),
                      ),
                      child: Text(
                        gameState.chartWagerBanner,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                  if (gameState.rivalTruceWeeks > 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5C6BC0).withAlpha(40),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF5C6BC0).withAlpha(160),
                        ),
                      ),
                      child: Text(
                        gameState.rivalTruceBanner,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                  if (gameState.documentaryWeeks > 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF80CBC4).withAlpha(40),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF80CBC4).withAlpha(160),
                        ),
                      ),
                      child: Text(
                        gameState.documentaryBanner,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                  if (gameState.therapyPodcastWeeks > 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCE93D8).withAlpha(40),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFCE93D8).withAlpha(160),
                        ),
                      ),
                      child: Text(
                        gameState.therapyPodcastBanner,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                  if (gameState.collabDmWeeks > 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF90CAF9).withAlpha(40),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF90CAF9).withAlpha(160),
                        ),
                      ),
                      child: Text(
                        gameState.collabDmBanner,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],

                  if (gameState.stalkerFanWeeks > 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF8A65).withAlpha(40),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFFF8A65).withAlpha(160),
                        ),
                      ),
                      child: Text(
                        gameState.stalkerFanBanner,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                  if (gameState.merchDropWeeks > 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF80CBC4).withAlpha(40),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF80CBC4).withAlpha(160),
                        ),
                      ),
                      child: Text(
                        gameState.merchDropBanner,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                  if (gameState.tourBusWeeks > 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFB74D).withAlpha(40),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFFFB74D).withAlpha(160),
                        ),
                      ),
                      child: Text(
                        gameState.tourBusBanner,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                  if (gameState.awardsCampWeeks > 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD54F).withAlpha(40),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFFFD54F).withAlpha(160),
                        ),
                      ),
                      child: Text(
                        gameState.awardsCampBanner,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                  if (gameState.genrePivotWeeks > 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4DB6AC).withAlpha(40),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF4DB6AC).withAlpha(160),
                        ),
                      ),
                      child: Text(
                        gameState.genrePivotBanner,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                  if (gameState.arenaSlotWeeks > 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF81C784).withAlpha(40),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF81C784).withAlpha(160),
                        ),
                      ),
                      child: Text(
                        gameState.arenaSlotBanner,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                  if (gameState.fanTheoryWeeks > 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFA1887F).withAlpha(40),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFA1887F).withAlpha(160),
                        ),
                      ),
                      child: Text(
                        gameState.fanTheoryBanner,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                  if (gameState.blacklistWeeks > 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE57373).withAlpha(40),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE57373).withAlpha(160),
                        ),
                      ),
                      child: Text(
                        gameState.blacklistBanner,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                  if (gameState.comebackWeeks > 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF64B5F6).withAlpha(40),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF64B5F6).withAlpha(160),
                        ),
                      ),
                      child: Text(
                        gameState.comebackBanner,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                  if (gameState.charityWeeks > 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFAED581).withAlpha(40),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFAED581).withAlpha(160),
                        ),
                      ),
                      child: Text(
                        gameState.charityBanner,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                  if (gameState.pressCoverWeeksRemaining > 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCE93D8).withAlpha(40),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFCE93D8).withAlpha(160),
                        ),
                      ),
                      child: Text(
                        '${gameState.pressMagazine} cover heat — +12% streams (${gameState.pressCoverWeeksRemaining}w left)',
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                  if (gameState.isFestivalSeason) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEB3B).withAlpha(35),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFFFEB3B).withAlpha(160),
                        ),
                      ),
                      child: Text(
                        gameState.canPlayFestival
                            ? 'Summer festival is open (Jun–Aug). One exclusive slot this year.'
                            : 'You already played this summer\'s festival slot.',
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                  if (gameState.isOnTour) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9800).withAlpha(40),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFFF9800).withAlpha(160),
                        ),
                      ),
                      child: Text(
                        'On tour: ${gameState.activeTour!.name} · next ${gameState.activeTour!.currentCity} · ${gameState.activeTour!.weeksRemaining}w left',
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                  if (gameState.weekStartedBurnedOut) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE94560).withAlpha(40),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE94560).withAlpha(140),
                        ),
                      ),
                      child: const Text(
                        'Burned out — this week\'s streams are dipping. Sleep it off in Events.',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (gameState.lastWeekRecap.isNotEmpty)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2a2a3e),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        gameState.lastWeekRecap,
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ),
                  if (gameState.weeklyHeadlines.isNotEmpty) ...[
                    const Text(
                      'THE FEED',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...gameState.weeklyHeadlines.take(5).map(
                          (h) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('• ',
                                    style: TextStyle(color: Color(0xFFe94560))),
                                Expanded(
                                  child: Text(
                                    h,
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    const SizedBox(height: 16),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'Money',
                          value: '\$${gameState.playerMoney.toStringAsFixed(0)}',
                          icon: Icons.attach_money,
                          color: const Color(0xFF4CAF50),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          title: 'Fans',
                          value: '${gameState.playerFanCount}',
                          icon: Icons.people,
                          color: const Color(0xFFe94560),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'Label',
                          value: player.labelTier.displayName,
                          icon: Icons.business,
                          color: Color(player.labelTier.colorValue),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          title: 'Songs',
                          value: '${gameState.worldSongs.where((s) => s.artistId == player.id).length}',
                          icon: Icons.music_note,
                          color: const Color(0xFFFF9800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'Royalties',
                          value:
                              '\$${gameState.lastWeekRoyalties.toStringAsFixed(0)}',
                          icon: Icons.graphic_eq,
                          color: const Color(0xFF26C6DA),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          title: 'Stream cut',
                          value:
                              '${(gameState.effectiveRoyaltyKeep * 100).toStringAsFixed(0)}%',
                          icon: Icons.percent,
                          color: Color(player.labelTier.colorValue),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'Passive',
                          value:
                              '\$${gameState.lastWeekPassive.toStringAsFixed(0)}',
                          icon: Icons.trending_up,
                          color: const Color(0xFF66BB6A),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          title: 'Lifestyle',
                          value:
                              '\$${gameState.lastWeekUpkeep.toStringAsFixed(0)}',
                          icon: Icons.diamond_outlined,
                          color: const Color(0xFFFFD700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16213e),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFe94560).withAlpha(140)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'STORY',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          gameState.currentChapter,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${gameState.completedStoryBeats.length} career beats unlocked',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFFD700).withAlpha(40),
                          const Color(0xFF2a2a3e),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFD700).withAlpha(100)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.trending_up, color: Color(0xFFFFD700)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Trending: ${gameState.trendingGenre} · your lane: ${gameState.playerDominantGenre}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'CHART RIVALS',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (gameState.rivals.isEmpty)
                    const Text(
                      'No rivals assigned yet.',
                      style: TextStyle(color: Colors.white54),
                    )
                  else
                    ...gameState.rivals.map((rival) {
                      final rivalRank = gameState.bestChartRankFor(rival.id);
                      final playerRank = gameState.bestChartRankFor(player.id);
                      String pressure;
                      if (rivalRank == null && playerRank == null) {
                        pressure = 'Both off-chart';
                      } else if (rivalRank == null) {
                        pressure = 'You lead (they unranked)';
                      } else if (playerRank == null) {
                        pressure = 'They lead #$rivalRank';
                      } else if (playerRank < rivalRank) {
                        pressure = 'You #$playerRank vs them #$rivalRank';
                      } else if (playerRank > rivalRank) {
                        pressure = 'Behind: you #$playerRank · them #$rivalRank';
                      } else {
                        pressure = 'Tied at #$playerRank';
                      }
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2a2a3e),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFe94560).withAlpha(120),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.sports_mma, color: Color(0xFFe94560)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    rival.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    '${rival.labelTier.displayName} · Pop ${rival.attributes['popularity']?.toStringAsFixed(0) ?? '0'}%',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    pressure,
                                    style: const TextStyle(
                                      color: Color(0xFFe94560),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: gameState.dissCooldownWeeks > 0
                                  ? null
                                  : () {
                                      final err =
                                          gameState.dropDissTrack(rival.id);
                                      if (err != null) {
                                        ToastService().showError(err);
                                      } else {
                                        ToastService().showSuccess(
                                          'Diss dropped on ${rival.name}.',
                                        );
                                      }
                                    },
                              child: Text(
                                gameState.dissCooldownWeeks > 0
                                    ? 'Cooling'
                                    : 'Diss',
                                style: const TextStyle(
                                  color: Color(0xFFe94560),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                  const SizedBox(height: 24),

                  // Display Top 3 Songs
                  const Text(
                    'TOP 3 SONGS',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 250, // Fixed height to prevent overflow for a few entries
                    child: _buildTopSongsList(gameState.getTopSongs(3), context),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'ATTRIBUTES',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 16),

                  AttributeBar(
                    label: 'Popularity',
                    value: player.attributes['popularity'] ?? 0,
                    color: const Color(0xFFe94560),
                  ),
                  AttributeBar(
                    label: 'Reputation',
                    value: player.attributes['reputation'] ?? 0,
                    color: const Color(0xFF4CAF50),
                  ),
                  AttributeBar(
                    label: 'Performance',
                    value: player.attributes['performance'] ?? 0,
                    color: const Color(0xFF2196F3),
                  ),
                  AttributeBar(
                    label: 'Talent',
                    value: player.attributes['talent'] ?? 0,
                    color: const Color(0xFFFF9800),
                  ),
                  AttributeBar(
                    label: 'Production',
                    value: player.attributes['production'] ?? 0,
                    color: const Color(0xFF9C27B0),
                  ),
                  AttributeBar(
                    label: 'Songwriting',
                    value: player.attributes['songwriting'] ?? 0,
                    color: const Color(0xFF00BCD4),
                  ),
                  AttributeBar(
                    label: 'Charisma',
                    value: player.attributes['charisma'] ?? 0,
                    color: const Color(0xFFFFEB3B),
                  ),
                  AttributeBar(
                    label: 'Marketing',
                    value: player.attributes['marketing'] ?? 0,
                    color: const Color(0xFF8BC34A),
                  ),
                  AttributeBar(
                    label: 'Networking',
                    value: player.attributes['networking'] ?? 0,
                    color: const Color(0xFF03A9F4),
                  ),
                  AttributeBar(
                    label: 'Creativity',
                    value: player.attributes['creativity'] ?? 0,
                    color: const Color(0xFFE91E63),
                  ),
                  AttributeBar(
                    label: 'Discipline',
                    value: player.attributes['discipline'] ?? 0,
                    color: const Color(0xFF607D8B),
                  ),
                  AttributeBar(
                    label: 'Stamina',
                    value: player.attributes['stamina'] ?? 0,
                    color: const Color(0xFFFF5722),
                  ),
                  AttributeBar(
                    label: 'Controversy',
                    value: player.attributes['controversy'] ?? 0,
                    color: const Color(0xFFF44336),
                  ),
                  AttributeBar(
                    label: 'Wealth',
                    value: player.attributes['wealth'] ?? 0,
                    color: const Color(0xFFFFD700),
                  ),
                  AttributeBar(
                    label: 'Influence',
                    value: player.attributes['influence'] ?? 0,
                    color: const Color(0xFF673AB7),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'QUICK ACTIONS',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _ActionButton(
                        label: 'Create Music',
                        icon: Icons.music_note,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CreateSongScreen(),
                            ),
                          );
                        },
                      ),
                      _ActionButton(
                        label: 'Perform',
                        icon: Icons.mic,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PerformanceScreen(),
                            ),
                          );
                        },
                      ),
                      _ActionButton(
                        label: 'Network',
                        icon: Icons.people,
                        onPressed: () {
                          final err = gameState.hustleNetwork();
                          if (err != null) {
                            ToastService().showError(err);
                          } else {
                            ToastService().showSuccess('You worked the room.');
                          }
                        },
                      ),
                      if (!gameState.fanClubFounded)
                        _ActionButton(
                          label: 'Fan Club',
                          icon: Icons.favorite,
                          onPressed: () {
                            final err = gameState.foundFanClub();
                            if (err != null) {
                              ToastService().showError(err);
                            } else {
                              ToastService().showSuccess(
                                'Fan club is live.',
                              );
                            }
                          },
                        ),
                      _ActionButton(
                        label: 'Street Team',
                        icon: Icons.campaign,
                        onPressed: () {
                          final err = gameState.runStreetTeam();
                          if (err != null) {
                            ToastService().showError(err);
                          } else {
                            ToastService().showSuccess(
                              'Street team is out for 2 weeks.',
                            );
                          }
                        },
                      ),
                      if (gameState.canHostMeetGreet)
                        _ActionButton(
                          label: 'Meet Fans',
                          icon: Icons.groups,
                          onPressed: () =>
                              _showMeetGreetSheet(context, gameState),
                        ),
                      if (gameState.canJoinDanceTrend)
                        _ActionButton(
                          label: 'Dance Trend',
                          icon: Icons.nightlife,
                          onPressed: () =>
                              _showDanceChallengeSheet(context, gameState),
                        ),
                      if (gameState.canReviewBrandDeal)
                        _ActionButton(
                          label: 'Brand Deal',
                          icon: Icons.handshake,
                          onPressed: () =>
                              _showBrandDealSheet(context, gameState),
                        ),
                      if (gameState.canChartWager)
                        _ActionButton(
                          label: 'Chart Wager',
                          icon: Icons.trending_up,
                          onPressed: () =>
                              _showChartWagerSheet(context, gameState),
                        ),
                      if (gameState.canOfferRivalTruce)
                        _ActionButton(
                          label: 'Rival Truce',
                          icon: Icons.handshake_outlined,
                          onPressed: () =>
                              _showRivalTruceSheet(context, gameState),
                        ),
                      if (gameState.canOfferDocumentary)
                        _ActionButton(
                          label: 'Documentary',
                          icon: Icons.videocam_outlined,
                          onPressed: () =>
                              _showDocumentarySheet(context, gameState),
                        ),
                      if (gameState.canOfferTherapyPodcast)
                        _ActionButton(
                          label: 'Podcast',
                          icon: Icons.mic,
                          onPressed: () =>
                              _showTherapyPodcastSheet(context, gameState),
                        ),
                      if (gameState.canOfferCollabDm)
                        _ActionButton(
                          label: 'Collab DM',
                          icon: Icons.mail_outline,
                          onPressed: () =>
                              _showCollabDmSheet(context, gameState),
                        ),

                      if (gameState.canOfferStalkerFan)
                        _ActionButton(
                          label: 'Fan Safety',
                          icon: Icons.security,
                          onPressed: () =>
                              _showStalkerFanSheet(context, gameState),
                        ),
                      if (gameState.canOfferMerchDrop)
                        _ActionButton(
                          label: 'Merch Drop',
                          icon: Icons.storefront,
                          onPressed: () =>
                              _showMerchDropSheet(context, gameState),
                        ),
                      if (gameState.canOfferTourBus)
                        _ActionButton(
                          label: 'Tour Bus',
                          icon: Icons.directions_bus,
                          onPressed: () =>
                              _showTourBusSheet(context, gameState),
                        ),
                      if (gameState.canOfferAwardsCamp)
                        _ActionButton(
                          label: 'Awards Night',
                          icon: Icons.emoji_events_outlined,
                          onPressed: () =>
                              _showAwardsCampSheet(context, gameState),
                        ),
                      if (gameState.canOfferGenrePivot)
                        _ActionButton(
                          label: 'Genre Rumor',
                          icon: Icons.swap_horiz,
                          onPressed: () =>
                              _showGenrePivotSheet(context, gameState),
                        ),
                      if (gameState.canOfferArenaSlot)
                        _ActionButton(
                          label: 'Arena Slot',
                          icon: Icons.stadium,
                          onPressed: () =>
                              _showArenaSlotSheet(context, gameState),
                        ),
                      if (gameState.canOfferFanTheory)
                        _ActionButton(
                          label: 'Fan Theory',
                          icon: Icons.psychology_outlined,
                          onPressed: () =>
                              _showFanTheorySheet(context, gameState),
                        ),
                      if (gameState.canOfferBlacklist)
                        _ActionButton(
                          label: 'Blacklist',
                          icon: Icons.block,
                          onPressed: () =>
                              _showBlacklistSheet(context, gameState),
                        ),
                      if (gameState.canOfferComeback)
                        _ActionButton(
                          label: 'Comeback',
                          icon: Icons.album,
                          onPressed: () =>
                              _showComebackSheet(context, gameState),
                        ),
                      if (gameState.canOfferCharity)
                        _ActionButton(
                          label: 'Charity',
                          icon: Icons.volunteer_activism,
                          onPressed: () =>
                              _showCharitySheet(context, gameState),
                        ),
                      _ActionButton(
                        label: 'Train',
                        icon: Icons.fitness_center,
                        onPressed: () => _showTrainSheet(context, gameState),
                      ),
                      _ActionButton(
                        label: 'Pitch Radio',
                        icon: Icons.radio,
                        onPressed: () => _showPitchSheet(context, gameState),
                      ),
                      _ActionButton(
                        label: 'Shoot Video',
                        icon: Icons.videocam,
                        onPressed: () => _showVideoSheet(context, gameState),
                      ),
                      _ActionButton(
                        label: 'Reissue',
                        icon: Icons.replay,
                        onPressed: () => _showReissueSheet(context, gameState),
                      ),
                      if (gameState.canSitRadio)
                        _ActionButton(
                          label: 'Live Radio',
                          icon: Icons.mic_external_on,
                          onPressed: () =>
                              _showRadioLiveSheet(context, gameState),
                        ),
                      if (gameState.canSitPress)
                        _ActionButton(
                          label: 'Press',
                          icon: Icons.newspaper,
                          onPressed: () =>
                              _showPressSheet(context, gameState),
                        ),
                      if (gameState.canPlayFestival)
                        _ActionButton(
                          label: 'Festival',
                          icon: Icons.festival,
                          onPressed: () {
                            final err = gameState.playFestivalSlot();
                            if (err != null) {
                              ToastService().showError(err);
                            } else {
                              ToastService().showSuccess(
                                'You played the summer festival slot.',
                              );
                            }
                          },
                        ),
                      _ActionButton(
                        label: 'Lifestyle',
                        icon: Icons.diamond_outlined,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LifestyleScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopSongsList(List<Song> songs, BuildContext context) {
    if (songs.isEmpty) {
      return const Text(
        'No songs on the charts yet.',
        style: TextStyle(color: Colors.white70),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        final artist = Provider.of<GameStateService>(context, listen: false).getArtistById(song.artistId);
        return ListTile(
          leading: CircleAvatar(child: Text('#${index + 1}')),
          title: Text(song.title, style: const TextStyle(color: Colors.white)),
          subtitle: Text('${artist?.name ?? 'Unknown Artist'} - ${song.weeklyListeners.toStringAsFixed(0)} listeners',
              style: const TextStyle(color: Colors.white70)),
          trailing: Text('${song.totalStreams.toStringAsFixed(0)} streams', style: const TextStyle(color: Colors.white70)),
        );
      },
    );
  }
}

// Remove _getLabelName as LabelTier is no longer in Artist model
// String _getLabelName(LabelTier tier) {
//   switch (tier) {
//     case LabelTier.unsigned:
//       return 'Unsigned';
//     case LabelTier.indie:
//       return 'Indie';
//     case LabelTier.major:
//       return 'Major';
//     case LabelTier.superstar:
//       return 'Superstar';
//   }
// }

void _showTrainSheet(BuildContext context, GameStateService game) {
  const skills = {
    'songwriting': 'Songwriting',
    'production': 'Production',
    'performance': 'Performance',
    'discipline': 'Discipline',
    'creativity': 'Creativity',
  };
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF16213e),
    builder: (_) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Train a skill (\$80, -14 stamina)',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          ...skills.entries.map(
            (e) => ListTile(
              title: Text(e.value, style: const TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                final err = game.trainSkill(e.key);
                if (err != null) {
                  ToastService().showError(err);
                } else {
                  ToastService().showSuccess('Trained ${e.value}.');
                }
              },
            ),
          ),
        ],
      ),
    ),
  );
}

void _showPitchSheet(BuildContext context, GameStateService game) {
  final songs = game.playerSongs;
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF16213e),
    builder: (_) => SafeArea(
      child: songs.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Release a song first.',
                style: TextStyle(color: Colors.white70),
              ),
            )
          : ListView(
              shrinkWrap: true,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Pitch radio / playlist (debut week stacks extra time)',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                ...songs.map(
                  (s) => ListTile(
                    title: Text(s.title,
                        style: const TextStyle(color: Colors.white)),
                    subtitle: Text(
                      s.playlistWeeksRemaining > 0
                          ? 'On playlist · ${s.playlistWeeksRemaining}w left'
                          : game.inDebutWindow(s)
                              ? 'DEBUT WINDOW · pitch now for a stacked add'
                              : '${s.genre} · viral ${s.viralFactor.toStringAsFixed(0)}',
                      style: const TextStyle(color: Colors.white54),
                    ),
                    enabled: s.playlistWeeksRemaining == 0,
                    onTap: s.playlistWeeksRemaining > 0
                        ? null
                        : () {
                            Navigator.pop(context);
                            final err = game.pitchSongToRadio(s.id);
                            if (err != null) {
                              ToastService().showError(err);
                            } else {
                              ToastService().showSuccess(
                                game.inDebutWindow(s)
                                    ? 'Debut stack: extra playlist week on "${s.title}".'
                                    : 'Playlist add: "${s.title}".',
                              );
                            }
                          },
                  ),
                ),
              ],
            ),
    ),
  );
}

void _showVideoSheet(BuildContext context, GameStateService game) {
  final songs = game.playerSongs;
  final cost = game.musicVideoCost();
  final weeks = game.musicVideoWeeks();
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF16213e),
    builder: (_) => SafeArea(
      child: songs.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Release a song first.',
                style: TextStyle(color: Colors.white70),
              ),
            )
          : ListView(
              shrinkWrap: true,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Shoot a video (\$${cost.toStringAsFixed(0)}, ${weeks}w boost)',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                ...songs.map(
                  (s) => ListTile(
                    title: Text(s.title,
                        style: const TextStyle(color: Colors.white)),
                    subtitle: Text(
                      s.videoWeeksRemaining > 0
                          ? 'Already boosting · ${s.videoWeeksRemaining}w left'
                          : '${s.genre} · weekly ${s.weeklyListeners.toStringAsFixed(0)}',
                      style: const TextStyle(color: Colors.white54),
                    ),
                    enabled: s.videoWeeksRemaining == 0,
                    onTap: s.videoWeeksRemaining > 0
                        ? null
                        : () {
                            Navigator.pop(context);
                            final err = game.shootMusicVideo(s.id);
                            if (err != null) {
                              ToastService().showError(err);
                            } else {
                              ToastService().showSuccess(
                                'Video out for "${s.title}".',
                              );
                            }
                          },
                  ),
                ),
              ],
            ),
    ),
  );
}

void _showReissueSheet(BuildContext context, GameStateService game) {
  final songs = game.playerSongs
      .where((s) => game.canDeluxeReissue(s) || game.canDropRemix(s))
      .toList();
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF16213e),
    builder: (_) => SafeArea(
      child: songs.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                game.reissueCooldownWeeks > 0
                    ? 'Studio cooldown: ${game.reissueCooldownWeeks}w left.'
                    : 'Need a catalog original (5+ weeks) without a deluxe/remix yet.',
                style: const TextStyle(color: Colors.white70),
              ),
            )
          : ListView(
              shrinkWrap: true,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Reissue catalog — deluxe resets recency, remix is a new debut',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                ...songs.map(
                  (s) => ListTile(
                    title: Text(s.title,
                        style: const TextStyle(color: Colors.white)),
                    subtitle: Text(
                      '${s.genre} · ${s.weeksSinceRelease}w old',
                      style: const TextStyle(color: Colors.white54),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: const Color(0xFF16213e),
                          title: Text(s.title,
                              style: const TextStyle(color: Colors.white)),
                          content: const Text(
                            'Deluxe puts the original back in the debut window. Remix adds a new chart entry.',
                            style: TextStyle(color: Colors.white70),
                          ),
                          actions: [
                            if (game.canDeluxeReissue(s))
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  final err = game.reissueDeluxe(s.id);
                                  if (err != null) {
                                    ToastService().showError(err);
                                  } else {
                                    ToastService().showSuccess(
                                      'Deluxe is out on "${s.title}".',
                                    );
                                  }
                                },
                                child: Text(
                                  'Deluxe \$${game.deluxeReissueCost().toStringAsFixed(0)}',
                                ),
                              ),
                            if (game.canDropRemix(s))
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  final err = game.dropRemix(s.id);
                                  if (err != null) {
                                    ToastService().showError(err);
                                  } else {
                                    ToastService().showSuccess(
                                      'Remix dropped for "${s.title}".',
                                    );
                                  }
                                },
                                child: Text(
                                  'Remix \$${game.remixDropCost().toStringAsFixed(0)}',
                                ),
                              ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancel'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    ),
  );
}

void _showRivalTruceSheet(BuildContext context, GameStateService game) {
  final rival = game.rivals.isNotEmpty ? game.rivals.first : null;
  final stances = <String, String>{
    'Form Alliance': 'Peace with ${rival?.name ?? 'rival'} — +6% 3w.',
    'Spy on Them': '\$650 intel — +9% streams 2w.',
    'Refuse Truce': 'Stay at war. Rival gains clout.',
  };
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF16213e),
    builder: (_) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Truce offer${rival != null ? ': ${rival.name}' : ''}',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          ...stances.entries.map(
            (e) => ListTile(
              title: Text(e.key, style: const TextStyle(color: Colors.white)),
              subtitle: Text(e.value,
                  style: const TextStyle(color: Colors.white54)),
              onTap: () {
                Navigator.pop(context);
                final err = game.resolveRivalTruce(
                  e.key,
                  rivalId: rival?.id,
                );
                if (err != null) {
                  ToastService().showError(err);
                } else {
                  ToastService().showSuccess(e.key);
                }
              },
            ),
          ),
        ],
      ),
    ),
  );
}

void _showDocumentarySheet(BuildContext context, GameStateService game) {
  final crew = game.documentaryCrewName.isNotEmpty
      ? game.documentaryCrewName
      : 'A documentary crew';
  final stances = <String, String>{
    'Grant Full Access': 'Cameras everywhere — +11% streams 4w.',
    'Limit Privacy': 'Curated story — +7% streams 3w.',
    'Deny Crew': 'Keep mystique. Reputation up.',
  };
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF16213e),
    builder: (_) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '$crew wants access',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          ...stances.entries.map(
            (e) => ListTile(
              title: Text(e.key, style: const TextStyle(color: Colors.white)),
              subtitle: Text(e.value,
                  style: const TextStyle(color: Colors.white54)),
              onTap: () {
                Navigator.pop(context);
                final err = game.resolveDocumentaryCrew(e.key);
                if (err != null) {
                  ToastService().showError(err);
                } else {
                  ToastService().showSuccess(e.key);
                }
              },
            ),
          ),
        ],
      ),
    ),
  );
}

void _showTherapyPodcastSheet(BuildContext context, GameStateService game) {
  final show = game.therapyPodcastName.isNotEmpty
      ? game.therapyPodcastName
      : 'A therapy podcast';
  final stances = <String, String>{
    'Open Up': 'Vulnerable — +8% streams 3w. Fans connect.',
    'Deflect': 'Stay polished — +5% streams 2w.',
    'Cancel Appearance': 'Skip it. Discipline up.',
  };
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF16213e),
    builder: (_) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '$show invite',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          ...stances.entries.map(
            (e) => ListTile(
              title: Text(e.key, style: const TextStyle(color: Colors.white)),
              subtitle: Text(e.value,
                  style: const TextStyle(color: Colors.white54)),
              onTap: () {
                Navigator.pop(context);
                final err = game.resolveTherapyPodcast(e.key);
                if (err != null) {
                  ToastService().showError(err);
                } else {
                  ToastService().showSuccess(e.key);
                }
              },
            ),
          ),
        ],
      ),
    ),
  );
}

void _showCollabDmSheet(BuildContext context, GameStateService game) {
  final artist = game.worldArtists
      .where((a) =>
          a.id != game.player?.id &&
          (a.attributes['popularity'] ?? 0) >= 30)
      .toList();
  final pick = artist.isNotEmpty ? artist.first : null;
  final stances = <String, String>{
    'Accept Collab': 'Studio with ${pick?.name ?? 'artist'} — +14% top song 3w.',
    'Ghost Them': 'Leave on read. Reputation dips.',
    'Leak Teaser': 'Snippet hype — +10% top song 2w. Messy.',
  };
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF16213e),
    builder: (_) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Collab DM${pick != null ? ': ${pick.name}' : ''}',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          ...stances.entries.map(
            (e) => ListTile(
              title: Text(e.key, style: const TextStyle(color: Colors.white)),
              subtitle: Text(e.value,
                  style: const TextStyle(color: Colors.white54)),
              onTap: () {
                Navigator.pop(context);
                final err = game.resolveCollabDm(
                  e.key,
                  fromEvent: false,
                );
                if (err != null) {
                  ToastService().showError(err);
                } else {
                  ToastService().showSuccess(e.key);
                }
              },
            ),
          ),
        ],
      ),
    ),
  );
}


void _showStalkerFanSheet(BuildContext context, GameStateService game) {
  final stances = <String, String>{
    'Restraining Order': '\$800 legal — +6% catalog 3w. Safer, colder.',
    'Soft Block': 'Quiet boundary — +5% catalog 2w.',
    'Engage': 'Lean into drama — +9% catalog 2w. Messy.',
  };
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF16213e),
    builder: (_) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Fan Safety',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          ...stances.entries.map(
            (e) => ListTile(
              title: Text(e.key, style: const TextStyle(color: Colors.white)),
              subtitle: Text(e.value,
                  style: const TextStyle(color: Colors.white54)),
              onTap: () {
                Navigator.pop(context);
                final err = game.resolveStalkerFan(e.key);
                if (err != null) {
                  ToastService().showError(err);
                } else {
                  ToastService().showSuccess(e.key);
                }
              },
            ),
          ),
        ],
      ),
    ),
  );
}

void _showMerchDropSheet(BuildContext context, GameStateService game) {
  final stances = <String, String>{
    'Premium Drop': '\$1200 limited vinyl — +8% 3w, money + fans.',
    'Mass Market': '\$500 flood the shops — +6% 2w, less cred.',
    'Skip Drop': 'Hold inventory. Discipline + happiness.',
  };
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF16213e),
    builder: (_) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Merch Drop',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          ...stances.entries.map(
            (e) => ListTile(
              title: Text(e.key, style: const TextStyle(color: Colors.white)),
              subtitle: Text(e.value,
                  style: const TextStyle(color: Colors.white54)),
              onTap: () {
                Navigator.pop(context);
                final err = game.resolveMerchDrop(e.key);
                if (err != null) {
                  ToastService().showError(err);
                } else {
                  ToastService().showSuccess(e.key);
                }
              },
            ),
          ),
        ],
      ),
    ),
  );
}

void _showTourBusSheet(BuildContext context, GameStateService game) {
  final stances = <String, String>{
    'Pay for Fix': '\$1500 mechanic — +7% 2w, keep dates.',
    'DIY Repair': 'Stamina hit. 50% good buzz or flop drama.',
    'Cancel Dates': 'Refunds lost. Fans dip. Discipline up.',
  };
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF16213e),
    builder: (_) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Tour Bus',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          ...stances.entries.map(
            (e) => ListTile(
              title: Text(e.key, style: const TextStyle(color: Colors.white)),
              subtitle: Text(e.value,
                  style: const TextStyle(color: Colors.white54)),
              onTap: () {
                Navigator.pop(context);
                final err = game.resolveTourBus(e.key);
                if (err != null) {
                  ToastService().showError(err);
                } else {
                  ToastService().showSuccess(e.key);
                }
              },
            ),
          ),
        ],
      ),
    ),
  );
}

void _showAwardsCampSheet(BuildContext context, GameStateService game) {
  final stances = <String, String>{
    'Full Campaign': '\$2000 + stamina — +12% 3w campaign heat.',
    'Keep It Chill': 'Soft presence — +7% 2w.',
    'Skip Night': 'Stay home. Discipline + happiness.',
  };
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF16213e),
    builder: (_) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Awards Night',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          ...stances.entries.map(
            (e) => ListTile(
              title: Text(e.key, style: const TextStyle(color: Colors.white)),
              subtitle: Text(e.value,
                  style: const TextStyle(color: Colors.white54)),
              onTap: () {
                Navigator.pop(context);
                final err = game.resolveAwardsCamp(e.key);
                if (err != null) {
                  ToastService().showError(err);
                } else {
                  ToastService().showSuccess(e.key);
                }
              },
            ),
          ),
        ],
      ),
    ),
  );
}

void _showGenrePivotSheet(BuildContext context, GameStateService game) {
  final stances = <String, String>{
    'Lean Into It': 'Own the rumor — +8% 3w, genre heat.',
    'Deny the Rumor': 'Stay in lane — +5% 2w.',
    'Double Down': '\$600 all-in — +11% 2w, controversy.',
  };
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF16213e),
    builder: (_) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Genre Rumor',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          ...stances.entries.map(
            (e) => ListTile(
              title: Text(e.key, style: const TextStyle(color: Colors.white)),
              subtitle: Text(e.value,
                  style: const TextStyle(color: Colors.white54)),
              onTap: () {
                Navigator.pop(context);
                final err = game.resolveGenrePivot(e.key);
                if (err != null) {
                  ToastService().showError(err);
                } else {
                  ToastService().showSuccess(e.key);
                }
              },
            ),
          ),
        ],
      ),
    ),
  );
}

void _showArenaSlotSheet(BuildContext context, GameStateService game) {
  final stances = <String, String>{
    'Take Support Slot': 'Pay + fans — +9% 3w. Stamina hit.',
    'Hold for Headliner': 'Patient play — +6% 2w networking.',
    'Pass': 'Skip the offer. Happiness + discipline.',
  };
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF16213e),
    builder: (_) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Arena Slot',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          ...stances.entries.map(
            (e) => ListTile(
              title: Text(e.key, style: const TextStyle(color: Colors.white)),
              subtitle: Text(e.value,
                  style: const TextStyle(color: Colors.white54)),
              onTap: () {
                Navigator.pop(context);
                final err = game.resolveArenaSlot(e.key);
                if (err != null) {
                  ToastService().showError(err);
                } else {
                  ToastService().showSuccess(e.key);
                }
              },
            ),
          ),
        ],
      ),
    ),
  );
}

void _showFanTheorySheet(BuildContext context, GameStateService game) {
  final stances = <String, String>{
    'Confirm Theory': 'Spoil the mystery — +7% 2w.',
    'Deny Theory': 'Shut it down — +4% 2w.',
    'Feed the Theory': 'Pour gasoline — +10% 3w.',
  };
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF16213e),
    builder: (_) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Fan Theory',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          ...stances.entries.map(
            (e) => ListTile(
              title: Text(e.key, style: const TextStyle(color: Colors.white)),
              subtitle: Text(e.value,
                  style: const TextStyle(color: Colors.white54)),
              onTap: () {
                Navigator.pop(context);
                final err = game.resolveFanTheory(e.key);
                if (err != null) {
                  ToastService().showError(err);
                } else {
                  ToastService().showSuccess(e.key);
                }
              },
            ),
          ),
        ],
      ),
    ),
  );
}

void _showBlacklistSheet(BuildContext context, GameStateService game) {
  final stances = <String, String>{
    'Address It': '\$400 PR — +6% 3w, cool the room.',
    'Ignore It': 'No stream boost. Discipline + happiness.',
    'Clap Back': 'Fight back — +9% 2w, rep dips.',
  };
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF16213e),
    builder: (_) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Blacklist',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          ...stances.entries.map(
            (e) => ListTile(
              title: Text(e.key, style: const TextStyle(color: Colors.white)),
              subtitle: Text(e.value,
                  style: const TextStyle(color: Colors.white54)),
              onTap: () {
                Navigator.pop(context);
                final err = game.resolveBlacklistRumor(e.key);
                if (err != null) {
                  ToastService().showError(err);
                } else {
                  ToastService().showSuccess(e.key);
                }
              },
            ),
          ),
        ],
      ),
    ),
  );
}

void _showComebackSheet(BuildContext context, GameStateService game) {
  final stances = <String, String>{
    'Intimate Concept': 'Soft album vision — +8% 3w.',
    'Maximalist Concept': '\$2500 spectacle — +12% 3w, stamina hit.',
    'Delay Project': 'Park it. Discipline + happiness.',
  };
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF16213e),
    builder: (_) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Comeback',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          ...stances.entries.map(
            (e) => ListTile(
              title: Text(e.key, style: const TextStyle(color: Colors.white)),
              subtitle: Text(e.value,
                  style: const TextStyle(color: Colors.white54)),
              onTap: () {
                Navigator.pop(context);
                final err = game.resolveComebackConcept(e.key);
                if (err != null) {
                  ToastService().showError(err);
                } else {
                  ToastService().showSuccess(e.key);
                }
              },
            ),
          ),
        ],
      ),
    ),
  );
}

void _showCharitySheet(BuildContext context, GameStateService game) {
  final stances = <String, String>{
    'Donate Proceeds': 'Give away cash — +7% 3w, rep + fans.',
    'Match Donations': '\$1200 match — +9% 2w.',
    'Skip Charity': 'Pass. Mild -rep, +discipline.',
  };
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF16213e),
    builder: (_) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Charity',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          ...stances.entries.map(
            (e) => ListTile(
              title: Text(e.key, style: const TextStyle(color: Colors.white)),
              subtitle: Text(e.value,
                  style: const TextStyle(color: Colors.white54)),
              onTap: () {
                Navigator.pop(context);
                final err = game.resolveCharitySingle(e.key);
                if (err != null) {
                  ToastService().showError(err);
                } else {
                  ToastService().showSuccess(e.key);
                }
              },
            ),
          ),
        ],
      ),
    ),
  );
}

void _showChartWagerSheet(BuildContext context, GameStateService game) {
  final rank = game.bestPlayerChartRank;
  final song = game.playerSongs.isEmpty
      ? null
      : game.playerSongs.reduce((a, b) {
          final ra = game.worldSongs.indexOf(a);
          final rb = game.worldSongs.indexOf(b);
          return ra <= rb ? a : b;
        });
  final stances = <String, String>{
    'Double Down': '\$900 promo — +12% on "${song?.title ?? 'hit'}" 2w.',
    'Protect the Streak': '\$350 safe spend — +7% 2w.',
    'Sit Out': 'Let the chart ride with no bet.',
  };
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF16213e),
    builder: (_) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Chart streak wager${rank != null ? ' · #$rank' : ''}',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          ...stances.entries.map(
            (e) => ListTile(
              title: Text(e.key, style: const TextStyle(color: Colors.white)),
              subtitle: Text(e.value,
                  style: const TextStyle(color: Colors.white54)),
              onTap: () {
                Navigator.pop(context);
                final err = game.resolveChartWager(e.key);
                if (err != null) {
                  ToastService().showError(err);
                } else {
                  ToastService().showSuccess(e.key);
                }
              },
            ),
          ),
        ],
      ),
    ),
  );
}

void _showBrandDealSheet(BuildContext context, GameStateService game) {
  final brand = game.brandSponsorName.isNotEmpty
      ? game.brandSponsorName
      : 'A brand';
  final est =
      (3200 + (game.player?.labelTier.index ?? 0) * 900 + game.playerFanCount * 0.04)
          .clamp(3200.0, 12000.0);
  final stances = <String, String>{
    'Take the Deal': 'Cash ~\$${est.toStringAsFixed(0)}. +6% streams 3w.',
    'Negotiate': 'Networking rolls for more pay. +8% streams 2w.',
    'Decline': 'Keep indie cred. Reputation up.',
  };
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF16213e),
    builder: (_) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '$brand sponsorship pitch',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          ...stances.entries.map(
            (e) => ListTile(
              title: Text(e.key, style: const TextStyle(color: Colors.white)),
              subtitle: Text(e.value,
                  style: const TextStyle(color: Colors.white54)),
              onTap: () {
                Navigator.pop(context);
                final err = game.resolveBrandSponsorship(e.key);
                if (err != null) {
                  ToastService().showError(err);
                } else {
                  ToastService().showSuccess(e.key);
                }
              },
            ),
          ),
        ],
      ),
    ),
  );
}

void _showDanceChallengeSheet(BuildContext context, GameStateService game) {
  final song = game.playerSongs.isEmpty
      ? null
      : game.playerSongs.reduce(
          (a, b) => a.viralFactor >= b.viralFactor ? a : b,
        );
  final stances = <String, String>{
    'Join the Trend': song == null
        ? 'Film the dance.'
        : 'Ride "${song.title}" — +14% for 2 weeks.',
    'Mock It': 'Petty clout — +10% for 1 week, reputation hit.',
    'Ignore': 'Stay off the timeline.',
  };
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF16213e),
    builder: (_) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Viral dance challenge',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          ...stances.entries.map(
            (e) => ListTile(
              title: Text(e.key, style: const TextStyle(color: Colors.white)),
              subtitle: Text(e.value,
                  style: const TextStyle(color: Colors.white54)),
              onTap: () {
                Navigator.pop(context);
                final err = game.resolveDanceChallenge(e.key);
                if (err != null) {
                  ToastService().showError(err);
                } else {
                  ToastService().showSuccess(e.key);
                }
              },
            ),
          ),
        ],
      ),
    ),
  );
}

void _showMeetGreetSheet(BuildContext context, GameStateService game) {
  final estPay =
      (game.playerFanCount * 0.85 + 450).clamp(450.0, 3800.0);
  final stances = <String, String>{
    'Charge Tickets': 'Cash ~\$${estPay.toStringAsFixed(0)}. +5% streams 2w.',
    'Free Meetup': 'Stamina hit. Fan love +9% streams 2w.',
    'Skip': 'Stay off the floor. Fans notice.',
  };
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF16213e),
    builder: (_) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Superfan meet & greet',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          ...stances.entries.map(
            (e) => ListTile(
              title: Text(e.key, style: const TextStyle(color: Colors.white)),
              subtitle: Text(e.value,
                  style: const TextStyle(color: Colors.white54)),
              onTap: () {
                Navigator.pop(context);
                final err = game.resolveMeetGreet(e.key);
                if (err != null) {
                  ToastService().showError(err);
                } else {
                  ToastService().showSuccess(e.key);
                }
              },
            ),
          ),
        ],
      ),
    ),
  );
}

void _showRadioLiveSheet(BuildContext context, GameStateService game) {
  final plug = game.bestRadioPlugSong();
  final stances = <String, String>{
    'Perform Live': 'Session heat — +8% catalog for 2 weeks.',
    'Plug the Single': plug == null
        ? 'Talk the catalog.'
        : 'Plug "${plug.title}" — +16% and a playlist bump.',
    'Freeze': 'Dead air. Clips hurt. No heat.',
  };
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF16213e),
    builder: (_) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '${game.radioStation} wants you live',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          ...stances.entries.map(
            (e) => ListTile(
              title: Text(e.key, style: const TextStyle(color: Colors.white)),
              subtitle: Text(e.value,
                  style: const TextStyle(color: Colors.white54)),
              onTap: () {
                Navigator.pop(context);
                final err = game.runRadioInterview(e.key);
                if (err != null) {
                  ToastService().showError(err);
                } else {
                  ToastService().showSuccess('${game.radioStation}: ${e.key}');
                }
              },
            ),
          ),
        ],
      ),
    ),
  );
}

void _showPressSheet(BuildContext context, GameStateService game) {
  const stances = <String, String>{
    'Play It Safe': 'Clean cover. Reputation up, quieter streams.',
    'Spill the Tea': 'Messy cover. Fans and viral, reputation hit.',
    'Cancel': 'Walk out. No cover heat.',
  };
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF16213e),
    builder: (_) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '${game.pressMagazine} wants a cover story',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          ...stances.entries.map(
            (e) => ListTile(
              title: Text(e.key, style: const TextStyle(color: Colors.white)),
              subtitle: Text(e.value,
                  style: const TextStyle(color: Colors.white54)),
              onTap: () {
                Navigator.pop(context);
                final err = game.runPressInterview(e.key);
                if (err != null) {
                  ToastService().showError(err);
                } else {
                  ToastService().showSuccess('${game.pressMagazine}: ${e.key}');
                }
              },
            ),
          ),
        ],
      ),
    ),
  );
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2a2a3e),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}
