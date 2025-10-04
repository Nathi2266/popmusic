import 'dart:math';
import 'package:flutter/foundation.dart';

import '../models/artist.dart';
import '../models/song.dart';
import '../models/event.dart';
import '../data/npc_artists.dart'; // Corrected import for NPCArtists

class GameStateService extends ChangeNotifier {
  int year = 2025;
  int month = 1;
  int weekOfMonth = 1;

  // World data
  List<Song> worldSongs = [];
  List<Artist> worldArtists = [];
  List<GameEvent> lastWeekEvents = [];

  final List<String> availableGenres = ['Pop', 'Rock', 'Hip-Hop', 'R&B', 'Electronic', 'Indie']; // Define available genres
  String? currentGenreFilter; // Added to filter songs by genre
  String chartViewMode = 'songs'; // 'songs' or 'artists'

  List<Map<String, dynamic>> weeklyChartHistory = []; // Stores historical chart data

  // ---------------------------
  // Time progression
  // ---------------------------
  void proceedWeek() {
    weekOfMonth++;
    if (weekOfMonth > 4) {
      weekOfMonth = 1;
      month++;
      if (month > 12) {
        month = 1;
        year++;
      }
    }

    lastWeekEvents.clear(); // Clear events from the previous week
    _generateWeeklyEvents(); // Generate events for the current week
    _generateNPCSongs(); // Generate new songs from NPCs

    // Recalculate charts after events
    recalculateCharts();
  }

  // ---------------------------
  // Event generation
  // ---------------------------
  void _generateWeeklyEvents() {
    final rng = Random();

    // Example: A global event chance
    if (rng.nextDouble() < 0.2) { // 20% chance of a global event
      final eventTitle = rng.nextBool() ? 'Industry Music Festival' : 'New Music Streaming Platform Launched';
      final eventDescription = rng.nextBool()
          ? 'A major music festival is happening, boosting popularity for all artists!'
          : 'A new streaming platform is live, potentially changing listener habits.';
      lastWeekEvents.add(GameEvent(
        id: 'event_${DateTime.now().millisecondsSinceEpoch}',
        title: eventTitle,
        description: eventDescription,
        type: EventType.opportunity,
        severity: EventSeverity.medium,
      ));

      // Apply global event effects (e.g., slight popularity boost for all artists)
      for (var artist in worldArtists) {
        updateArtistAttribute(artist.id, 'popularity', 2.0); // Small boost
      }
      notifyListeners(); // Notify after global attribute changes
    }

    // New: Viral Boost Event (random song gets a boost)
    if (worldSongs.isNotEmpty && rng.nextDouble() < 0.15) { // 15% chance of a viral boost
      final songToBoost = worldSongs[rng.nextInt(worldSongs.length)];
      final boostAmount = 10 + rng.nextDouble() * 20; // Boost viral factor by 10-30
      songToBoost.viralFactor = (songToBoost.viralFactor + boostAmount).clamp(0.0, 100.0);
      lastWeekEvents.add(GameEvent(
        id: 'event_${DateTime.now().millisecondsSinceEpoch}_viral',
        title: '${songToBoost.title} Goes Viral!',
        description: '${songToBoost.title} is trending across social media, leading to a massive surge in listeners!',
        type: EventType.opportunity,
        severity: EventSeverity.high,
      ));
      notifyListeners();
    }

    // Example: Artist-specific events (scandals or opportunities)
    for (var artist in worldArtists) {
      if (rng.nextDouble() < 0.1) { // 10% chance of a personal event
        if (rng.nextBool()) { // 50% chance of scandal, 50% opportunity
          // Scandal
          final eventTitle = '${artist.name} in Social Media Backlash';
          final eventDescription = '${artist.name} is facing criticism for recent comments.';
          lastWeekEvents.add(GameEvent(
        id: 'event_${DateTime.now().millisecondsSinceEpoch}',
            title: eventTitle,
            description: eventDescription,
        type: EventType.scandal,
        severity: EventSeverity.high,
          ));
          updateArtistAttribute(artist.id, 'reputation', -5.0); // Reputation hit
          updateArtistAttribute(artist.id, 'controversy', 10.0); // Controversy boost
        } else {
          // Opportunity
          final eventTitle = '${artist.name} Featured on Discover Weekly';
          final eventDescription = '${artist.name}\'s music is gaining traction on popular playlists.'; // Fixed string interpolation
          lastWeekEvents.add(GameEvent(
        id: 'event_${DateTime.now().millisecondsSinceEpoch}',
            title: eventTitle,
            description: eventDescription,
        type: EventType.opportunity,
        severity: EventSeverity.medium,
          ));
          updateArtistAttribute(artist.id, 'popularity', 5.0); // Popularity boost
          updateArtistAttribute(artist.id, 'fan_connection', 3.0); // Fan connection boost
        }
        notifyListeners(); // Notify after artist-specific attribute changes
      }
    }

    // New: Collaboration Event
    if (worldArtists.length >= 2 && rng.nextDouble() < 0.05) { // 5% chance of a collaboration
      final artist1 = worldArtists[rng.nextInt(worldArtists.length)];
      Artist artist2;
      do {
        artist2 = worldArtists[rng.nextInt(worldArtists.length)];
      } while (artist2.id == artist1.id); // Ensure different artists

      final collabSongTitle = '${artist1.name} & ${artist2.name} - Unity Track';
      final collabSong = Song(
        id: 'song_${DateTime.now().millisecondsSinceEpoch}_collab',
        title: collabSongTitle,
        artistId: artist1.id, // Assign to artist1, but both benefit
        // Attributes for collaboration songs can be an average or influenced by both artists
        popularityFactor: ((artist1.attributes['popularity'] ?? 10) + (artist2.attributes['popularity'] ?? 10)) / 2,
        viralFactor: ((artist1.attributes['creativity'] ?? 5) + (artist2.attributes['creativity'] ?? 5)) / 2,
        salesPotential: ((artist1.attributes['marketing'] ?? 10) + (artist2.attributes['marketing'] ?? 10)) / 2,
        isNewEntry: true,
      );
      worldSongs.add(collabSong);
      lastWeekEvents.add(GameEvent(
        id: 'event_${DateTime.now().millisecondsSinceEpoch}_collab',
        title: 'New Collaboration: ${artist1.name} & ${artist2.name}!',
        description: '${artist1.name} and ${artist2.name} have teamed up for a hot new single!',
        type: EventType.opportunity,
        severity: EventSeverity.medium,
      ));
      notifyListeners();
    }
  }

  // Helper to update any artist's attribute
  void updateArtistAttribute(String artistId, String attribute, double change) {
    final artist = getArtistById(artistId);
    if (artist == null) return;
    artist.attributes[attribute] = ((artist.attributes[attribute] ?? 0) + change).clamp(0.0, 100.0);
    notifyListeners();
  }

  // ---------------------------
  // Chart calculations
  // ---------------------------
  void recalculateCharts() {
    final rng = Random();
    // Store current ranks before updating for the new week
    final Map<String, int> currentRanks = {};
    for (int i = 0; i < worldSongs.length; i++) {
      currentRanks[worldSongs[i].id] = i + 1;
    }

    for (var song in worldSongs) {
      song.lastWeekListeners = song.weeklyListeners;
      song.lastWeekRank = currentRanks[song.id]; // Assign the rank from the previous week
      song.isNewEntry = song.weeksSinceRelease == 0; // If weeksSinceRelease is 0, it's a new entry

      final listeners = _calculateWeeklyListenersForSong(song);
      song.weeklyListeners = listeners;
      song.totalStreams += listeners;
      song.weeksSinceRelease++;

      _applySongPerformanceToArtist(song);

      // Update listener history
      song.listenerHistory.add(song.weeklyListeners);
      if (song.listenerHistory.length > 4) {
        song.listenerHistory.removeAt(0); // Keep only the last 4 weeks
      }
    }

    worldSongs.sort((a, b) => b.totalStreams.compareTo(a.totalStreams));

    // After sorting, update the isNewEntry for existing songs.
    // If a song wasn't new this week (weeksSinceRelease > 0), then it's no longer a new entry.
    for (var song in worldSongs) {
      if (song.weeksSinceRelease > 0) {
        song.isNewEntry = false;
      }
    }

    // Update player's chart peak and check for milestones
    if (player != null) {
      for (var playerSong in playerSongs) {
        final currentRank = worldSongs.indexOf(playerSong) + 1;
        // Update playerChartPeak
        if (playerChartPeak == null || currentRank < playerChartPeak!) {
          playerChartPeak = currentRank;
        }

        // Check for chart milestones
        if (playerSong.lastWeekRank == null) { // New entry to charts
          if (currentRank <= 30) {
            lastWeekEvents.add(GameEvent(
              id: 'player_chart_debut_${playerSong.id}',
              title: '${playerSong.title} Enters Top 30!',
              description: 'Your song "${playerSong.title}" has entered the Top 30 charts at #$currentRank!',
              type: EventType.opportunity,
              severity: EventSeverity.medium,
            ));
          }
        } else if (playerSong.lastWeekRank! > 30 && currentRank <= 30) { // Entered Top 30 this week
          lastWeekEvents.add(GameEvent(
            id: 'player_chart_enter_top30_${playerSong.id}',
            title: '${playerSong.title} Climbs into Top 30!',
            description: 'Your song "${playerSong.title}" has climbed into the Top 30 charts at #$currentRank!',
            type: EventType.opportunity,
            severity: EventSeverity.medium,
          ));
        }

        if (currentRank == 1 && (playerSong.lastWeekRank != 1 || playerSong.lastWeekRank == null)) { // Hit #1 this week
          lastWeekEvents.add(GameEvent(
            id: 'player_chart_hit_1_${playerSong.id}',
            title: '${playerSong.title} is #1!',
            description: 'Congratulations! Your song "${playerSong.title}" has hit #1 on the charts!',
            type: EventType.opportunity,
            severity: EventSeverity.high,
          ));
        } else if (playerSong.lastWeekRank == 1 && currentRank > 1) { // Dropped from #1
          lastWeekEvents.add(GameEvent(
            id: 'player_chart_drop_1_${playerSong.id}',
            title: '${playerSong.title} Drops from #1',
            description: 'Your song "${playerSong.title}" has dropped from the #1 spot.',
            type: EventType.scandal,
            severity: EventSeverity.low,
          ));
        }

        // Check if song dropped off the Top 30 (assuming charts show top 30)
        if (playerSong.lastWeekRank != null && playerSong.lastWeekRank! <= 30 && currentRank > 30) {
          lastWeekEvents.add(GameEvent(
            id: 'player_chart_drop_off_${playerSong.id}',
            title: '${playerSong.title} Drops Off Top 30',
            description: 'Your song "${playerSong.title}" has dropped off the Top 30 charts.',
            type: EventType.scandal,
            severity: EventSeverity.low,
          ));
        }
      }
    }

    // Archive current week's top 30 songs
    final currentWeekTopSongs = worldSongs.take(30).map((song) => {
      'id': song.id,
      'title': song.title,
      'artistId': song.artistId,
      'totalStreams': song.totalStreams,
      'weeklyListeners': song.weeklyListeners,
      'rank': worldSongs.indexOf(song) + 1, // Current rank
      'week': weekOfMonth,
      'month': month,
      'year': year,
    }).toList();
    weeklyChartHistory.add({
      'week': weekOfMonth,
      'month': month,
      'year': year,
      'songs': currentWeekTopSongs,
    });

    // Keep only the last 52 weeks of history (1 year)
    if (weeklyChartHistory.length > 52) {
      weeklyChartHistory.removeAt(0);
    }

    // "Best Viral Song" Nomination and Award
    final viralSongsCandidates = worldSongs.where((song) => song.totalStreams >= 1000000 && song.weeksSinceRelease < 8).toList();
    if (viralSongsCandidates.isNotEmpty && rng.nextDouble() < 0.1) { // 10% chance for a viral award event
      // Sort by viral factor to pick the 'best' viral song
      viralSongsCandidates.sort((a, b) => b.viralFactor.compareTo(a.viralFactor));
      final winningSong = viralSongsCandidates.first;
      final winningArtist = getArtistById(winningSong.artistId);

      if (winningArtist != null) {
        // Give money and popularity boost to the winning artist
        playerMoney += 10000; // Assuming player gets money if their artist wins, or if an NPC artist wins it's general game money
        updateArtistAttribute(winningArtist.id, 'popularity', 10.0);
        winningArtist.awardsWon.add('Best Viral Song - ${year}');

        lastWeekEvents.add(GameEvent(
          id: 'viral_award_${year}_${winningArtist.id}',
          title: '${winningArtist.name} Wins Best Viral Song!',
          description: '${winningArtist.name}\'s song "${winningSong.title}" has been awarded Best Viral Song of the year, earning them \$10,000 and a popularity boost!',
          type: EventType.opportunity,
          severity: EventSeverity.high,
        ));

        // Nominate 3 other artists
        final otherNominees = viralSongsCandidates.where((song) => song.artistId != winningArtist.id).take(3).toList();
        for (var nominatedSong in otherNominees) {
          final nominatedArtist = getArtistById(nominatedSong.artistId);
          if (nominatedArtist != null) {
            lastWeekEvents.add(GameEvent(
              id: 'viral_nominee_${year}_${nominatedArtist.id}',
              title: '${nominatedArtist.name} Nominated for Best Viral Song!',
              description: '${nominatedArtist.name}\'s song "${nominatedSong.title}" has been nominated for Best Viral Song of the year!',
              type: EventType.opportunity,
              severity: EventSeverity.low,
            ));
          }
        }
      }
    }

    notifyListeners();
  }

  void _generateNPCSongs() {
    final rng = Random();
    // For simplicity, let's say 10% of NPCs release a new song each week
    for (var artist in worldArtists) {
      if (artist.id == 'player') continue; // Player releases songs differently

      if (rng.nextDouble() < 0.1) {
        final newSongTitle = '${artist.name}\'s New Track ${rng.nextInt(100)}'; // Simple title generation
        final newSong = Song(
          id: 'song_${DateTime.now().millisecondsSinceEpoch}_${artist.id}',
          title: newSongTitle,
          artistId: artist.id,
          popularityFactor: (artist.attributes['popularity'] ?? 10).clamp(10.0, 90.0), // Base on artist popularity
          viralFactor: (artist.attributes['creativity'] ?? 5).clamp(5.0, 70.0), // Base on artist creativity
          salesPotential: (artist.attributes['marketing'] ?? 10).clamp(10.0, 80.0), // Base on artist marketing
          isNewEntry: true, // Mark as a new entry
          genre: availableGenres[rng.nextInt(availableGenres.length)], // Assign a random genre
        );
        worldSongs.add(newSong);
      }
    }

    // NPC song retirement
    final songsToRetire = worldSongs.where((song) =>
        song.artistId != 'player' &&
        song.weeksSinceRelease > 12 && // Older than 12 weeks
        song.weeklyListeners < 500 && // Low weekly listeners
        rng.nextDouble() < 0.05 // 5% chance to retire
    ).toList();

    for (var song in songsToRetire) {
      worldSongs.removeWhere((s) => s.id == song.id);
      lastWeekEvents.add(GameEvent(
        id: 'event_${DateTime.now().millisecondsSinceEpoch}_retire_${song.id}',
        title: '${getArtistById(song.artistId)?.name ?? 'An Artist'} Retires ${song.title}',
        description: '${song.title} has run its course and been retired from active rotation.',
        type: EventType.scandal, // Can be considered a minor setback/natural lifecycle event
        severity: EventSeverity.low,
      ));
    }
  }

  List<Song> getTopSongs(int limit) {
    List<Song> songsToConsider = worldSongs;
    if (currentGenreFilter != null) {
      if (currentGenreFilter == 'New Releases') {
        songsToConsider = worldSongs.where((song) => song.isNewEntry).toList();
      } else {
        songsToConsider = worldSongs.where((song) => song.genre == currentGenreFilter).toList();
      }
    }

    songsToConsider.sort((a, b) => b.totalStreams.compareTo(a.totalStreams));
    return songsToConsider.take(limit).toList();
  }

  double getArtistCumulativeStreams(String artistId) {
    return worldSongs.where((song) => song.artistId == artistId).fold(0.0, (sum, song) => sum + song.totalStreams);
  }

  List<Artist> getTopArtists(int limit) {
    // Calculate cumulative streams for each artist
    Map<String, double> artistStreams = {};
    for (var song in worldSongs) {
      artistStreams.update(song.artistId, (value) => value + song.totalStreams, ifAbsent: () => song.totalStreams);
    }

    // Sort artists by cumulative streams
    List<Artist> sortedArtists = worldArtists.toList();
    sortedArtists.sort((a, b) => (artistStreams[b.id] ?? 0.0).compareTo(artistStreams[a.id] ?? 0.0));

    return sortedArtists.take(limit).toList();
  }

  Artist? getArtistById(String id) {
    try {
      return worldArtists.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  void addSong(Song song) {
    worldSongs.add(song);
    notifyListeners();
  }

  void addArtist(Artist artist) {
    worldArtists.add(artist);
    notifyListeners();
  }

  // ---------------------------
  // Core formulas
  // ---------------------------
  double _calculateWeeklyListenersForSong(Song song) {
    final artist = getArtistById(song.artistId);
    final rng = Random();

    final pop = (artist?.attributes['popularity'] ?? 10).clamp(0.0, 100.0);
    final fanConn = (artist?.attributes['fan_connection'] ?? 10).clamp(0.0, 100.0);

    double base = (pop * 20) + (fanConn * 10);

    final reputation = (artist?.attributes['reputation'] ?? 10);
    base *= 1 + (reputation / 300);

    double recencyBoost = song.weeksSinceRelease <= 2
        ? 1.4
        : 1.0 - (song.weeksSinceRelease * 0.03).clamp(0.0, 0.5);

    double viral = (song.viralFactor / 100.0) + (rng.nextDouble() * 0.2);

    final controversy = (artist?.attributes['controversy'] ?? 0);
    double controversyEffect = 1.0;
    if (controversy > 50) {
      controversyEffect += (controversy - 50) / 200.0;
    } else if (controversy > 20) {
      controversyEffect += (controversy - 20) / 500.0;
    }

    bool hadScandalThisWeek =
        lastWeekEvents.any((e) => e.title.contains(artist?.name ?? ''));
    if (hadScandalThisWeek) controversyEffect *= 0.7;

    double marketingBoost = 1.0 + ((song.salesPotential / 100.0) * 0.5);

    double listeners =
        base * recencyBoost * (1 + viral) * controversyEffect * marketingBoost;

    final jitter = (rng.nextDouble() - 0.5) * 0.15;
    listeners *= (1 + jitter);

    if (listeners < 50) listeners = (50 + rng.nextInt(150)).toDouble(); // Cast to double

    return listeners;
  }

  void _applySongPerformanceToArtist(Song song) {
    final artist = getArtistById(song.artistId);
    if (artist == null) return;

    final deltaListeners =
        (song.weeklyListeners - (song.lastWeekListeners ?? 0));

    final popularityGain =
        (deltaListeners / 2000).clamp(-5.0, 12.0);
    artist.attributes['popularity'] =
        ((artist.attributes['popularity'] ?? 0) + popularityGain)
            .clamp(0.0, 100.0);

    if (deltaListeners < 0) {
      artist.attributes['happiness'] =
          ((artist.attributes['happiness'] ?? 50) +
                  (deltaListeners / 1000))
              .clamp(0.0, 100.0);
      artist.attributes['reputation'] =
          ((artist.attributes['reputation'] ?? 10) +
                  (deltaListeners / 500))
              .clamp(0.0, 100.0);
    } else {
      artist.attributes['reputation'] =
          ((artist.attributes['reputation'] ?? 10) +
                  (popularityGain * 0.25))
              .clamp(0.0, 100.0);
      artist.attributes['talent'] =
          ((artist.attributes['talent'] ?? 10) +
                  (popularityGain * 0.1))
              .clamp(0.0, 100.0);
    }

    if (song.viralFactor > 70) {
      artist.attributes['controversy'] =
          ((artist.attributes['controversy'] ?? 0) + 5)
              .clamp(0.0, 100.0);
    }
  }

  // Player-specific logic and initialization
  Artist? _player;
  Artist? get player => _player;
  bool get isGameStarted => _player != null; // Added isGameStarted getter

  double playerMoney = 5000; // Example initial money
  int playerFanCount = 100; // Example initial fan count
  int? playerChartPeak; // Stores the highest (lowest number) rank a player's song has achieved

  void startNewGame(String playerName) {
    _player = Artist(
      id: 'player',
      name: playerName,
      attributes: {
        'popularity': 10,
        'reputation': 10,
        'happiness': 50,
        'talent': 10,
        'controversy': 0,
        'fan_connection': 10,
        'performance': 50,
        'production': 40,
        'songwriting': 55,
        'charisma': 50,
        'marketing': 30,
        'networking': 40,
        'creativity': 60,
        'discipline': 50,
        'stamina': 80,
        'wealth': 10,
        'influence': 5,
      },
    );
    worldArtists.add(_player!); // Add player to worldArtists
    worldArtists.addAll(NPCArtists.generateNPCs()); // Add NPC artists to worldArtists
    playerMoney = 5000;
    playerFanCount = 100;
    notifyListeners();
  }

  List<Song> get playerSongs => worldSongs.where((song) => song.artistId == _player?.id).toList();

  void updatePlayerMoney(double amount) {
    playerMoney += amount;
    notifyListeners();
  }

  void updatePlayerFanCount(int amount) {
    playerFanCount += amount;
      notifyListeners();
  }

  // You might want to add a method to update specific player attributes
  void updatePlayerAttribute(String attribute, double change) {
    if (_player == null) return;
    _player!.attributes[attribute] = ((_player!.attributes[attribute] ?? 0) + change).clamp(0.0, 100.0);
    notifyListeners();
  }
}
