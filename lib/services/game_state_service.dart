import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
  final List<String> _notifications = []; // New field for notifications

  late Box _gameBox; // Hive box for game state

  // Getter for notifications
  List<String> get notifications => _notifications;

  // Method to add notifications
  void addNotification(String message) {
    _notifications.add(message);
    // You might want to limit the number of notifications or add a timestamp
    if (_notifications.length > 10) {
      _notifications.removeAt(0); // Keep only the latest 10 notifications
    }
    notifyListeners();
  }

  final List<String> _songTitles = [
    "Love Is Nice", "Neon Dreams", "City Lights", "Broken Heart", "Summer Vibes",
    "Midnight Drive", "Electric Touch", "Golden Hour", "Lost in Translation", "Starlight Serenade",
    "Whispering Winds", "Crimson Sky", "Echoes in the Dark", "Fading Memories", "Rhythm of Rain",
    "Silent Symphony", "Velvet Moon", "Wildflower Fields", "Eternal Flame", "Parallel Universe",
    "Quantum Leap", "Digital Soul", "Cybernetic Love", "Astral Projection", "Cosmic Dust",
    "Melody of the Machine", "Synthetic Emotion", "Virtual Reality", "Dream Weaver", "Sonic Boom",
    "Future Shock", "Time Warp", "Gravity Shift", "Aurora Borealis", "Crystal Caves",
    "Mystic River", "Shadow Play", "Enchanted Forest", "Sunken City", "Dragon's Breath",
    "Phoenix Rising", "Starfall", "Lunar Eclipse", "Solar Flare", "Nebula Nectar",
    "Galactic Groove", "Infinity Loop", "Zero Gravity", "Black Hole Blues", "Milky Way Waltz",
  ];

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
    _releaseNPCSongsWeekly(); // NPC artists release new songs

    // Player-specific updates
    _updatePlayerMetrics();

    // Recalculate charts after events
    recalculateCharts();
    saveGame(); // Save game state after weekly progression
  }

  void _updatePlayerMetrics() {
    if (_player == null) return;

    // Money: Basic income and expenses (can be expanded)
    double weeklyIncome = 0;
    for (var song in worldSongs.where((s) => s.artistId == _player!.id)) {
      weeklyIncome += song.weeklyListeners * 0.005; // Example: $0.005 per stream
    }
    playerMoney += weeklyIncome;
    addNotification('You earned \$${weeklyIncome.toStringAsFixed(2)} from your songs this week!');

    double weeklyExpenses = 1000; // Example fixed weekly expense
    playerMoney -= weeklyExpenses;
    addNotification('-\$${weeklyExpenses.toStringAsFixed(2)} in weekly expenses.');

    // Fans: Based on popularity and chart performance
    int fanChange = 0;
    final playerPopularity = _player!.attributes['popularity'] ?? 0;
    fanChange += (playerPopularity * 10).toInt(); // Base gain from popularity

    // Bonus for top songs
    final playerTopSongs = worldSongs.where((s) => s.artistId == _player!.id && s.currentRank != null && s.currentRank! <= 30);
    if (playerTopSongs.isNotEmpty) {
      fanChange += playerTopSongs.length * 500; // Additional fans for having songs in top 30
      addNotification('Your songs in the Top 30 gained you ${playerTopSongs.length * 500} new fans!');
    }

    playerFanCount += fanChange;
    addNotification('You gained $fanChange new fans, bringing your total to $playerFanCount!');

    // Label Status
    String oldLabelTier = _player!.labelTier;
    if (playerFanCount > 1000000) {
      _player!.labelTier = "Major";
    } else if (playerFanCount > 100000) {
      _player!.labelTier = "Indie";
    } else if (playerFanCount > 10000) {
      _player!.labelTier = "Underground";
    } else {
      _player!.labelTier = "Unsigned";
    }

    if (oldLabelTier != _player!.labelTier) {
      addNotification('Congratulations! You are now a ${_player!.labelTier} artist!');
    }
    // Attributes Influence - Already handled in _applySongPerformanceToArtist and _generateWeeklyEvents
  }

  // ---------------------------
  // Hive Persistence
  // ---------------------------
  Future<void> initHive() async {
    // Ensure adapters are registered
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ArtistAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(SongAdapter());
    }

    _gameBox = await Hive.openBox('gameBox');
    await loadGame(); // Load game state on initialization
  }

  Future<void> saveGame() async {
    await _gameBox.put('year', year);
    await _gameBox.put('month', month);
    await _gameBox.put('weekOfMonth', weekOfMonth);
    await _gameBox.put('player', _player); // Assuming Artist is a HiveObject or has a TypeAdapter
    await _gameBox.put('worldArtists', worldArtists);
    await _gameBox.put('worldSongs', worldSongs);
    // Add other game state variables to save
  }

  Future<void> loadGame() async {
    year = _gameBox.get('year') ?? 2025;
    month = _gameBox.get('month') ?? 1;
    weekOfMonth = _gameBox.get('weekOfMonth') ?? 1;

    _player = _gameBox.get('player');
    worldArtists = List<Artist>.from(_gameBox.get('worldArtists') ?? []);
    worldSongs = List<Song>.from(_gameBox.get('worldSongs') ?? []);

    if (_player != null && !worldArtists.any((artist) => artist.id == _player!.id)) {
      worldArtists.add(_player!); // Ensure player is in worldArtists after loading
    }

    // If no game data, start a new game (or load initial data)
    if (!isGameStarted && worldArtists.isEmpty) {
      // This might be the first launch, or a corrupted save
      // Consider calling startNewGame() here with a default name or prompt user
    }
    notifyListeners();
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

      // Global events affecting all songs (e.g., festival boosts all song viral factors)
      for (var song in worldSongs) {
        song.viralFactor = (song.viralFactor + 5.0).clamp(0.0, 100.0); // Small viral boost
      }

      notifyListeners(); // Notify after global attribute changes
    }

    // Example: Artist-specific events (scandals or opportunities)
    for (var artist in worldArtists) {
      if (artist.id == _player?.id) continue; // Skip player artist for NPC events

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
          // Scandal also affects song popularity negatively
          for (var song in worldSongs.where((s) => s.artistId == artist.id)) {
            song.popularityFactor = (song.popularityFactor - 10.0).clamp(0.0, 100.0);
          }
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
          // Opportunity also affects song viral factor positively
          for (var song in worldSongs.where((s) => s.artistId == artist.id)) {
            song.viralFactor = (song.viralFactor + 15.0).clamp(0.0, 100.0);
            song.isViral = true; // Mark as viral due to feature
          }
        }
        notifyListeners(); // Notify after artist-specific attribute changes
      }
    }

    // Random viral boost event for a single song (e.g., social media trend)
    if (worldSongs.isNotEmpty && rng.nextDouble() < 0.15) { // 15% chance for a song to go viral
      final randomSong = worldSongs[rng.nextInt(worldSongs.length)];
      final artist = getArtistById(randomSong.artistId);
      if (artist != null) {
        final eventTitle = '${randomSong.title} Goes Viral on BuzzApp!';
        final eventDescription = '${randomSong.title} by ${artist.name} is trending, leading to a massive boost in streams!';
        lastWeekEvents.add(GameEvent(
          id: 'event_${DateTime.now().millisecondsSinceEpoch}',
          title: eventTitle,
          description: eventDescription,
          type: EventType.opportunity,
          severity: EventSeverity.high,
        ));
        randomSong.viralFactor = (randomSong.viralFactor + 30.0).clamp(0.0, 100.0); // Significant viral boost
        randomSong.isViral = true;
        notifyListeners();
      }
    }
  }

  // ---------------------------
  // NPC Song Release
  // ---------------------------
  void _releaseNPCSongsWeekly() {
    final rng = Random();
    for (var artist in worldArtists) {
      if (artist.id == _player?.id) continue; // Skip player artist

      // 15% chance for an NPC to release a new song each week
      if (rng.nextDouble() < 0.15) {
        // Generate song attributes based on artist attributes and some randomness
        final songwritingSkill = (artist.attributes['songwriting'] ?? 50).clamp(10.0, 100.0);
        final productionSkill = (artist.attributes['production'] ?? 50).clamp(10.0, 100.0);
        final marketingSkill = (artist.attributes['marketing'] ?? 50).clamp(10.0, 100.0);
        final charismaSkill = (artist.attributes['charisma'] ?? 50).clamp(10.0, 100.0);

        final popularityFactor = ((songwritingSkill * 0.4) + (productionSkill * 0.3) + (rng.nextDouble() * 30)).clamp(10.0, 90.0);
        final viralFactor = ((marketingSkill * 0.5) + (charismaSkill * 0.3) + (rng.nextDouble() * 20)).clamp(5.0, 80.0);
        final salesPotential = ((marketingSkill * 0.6) + (rng.nextDouble() * 40)).clamp(10.0, 90.0);

        final newSong = Song(
          id: 'song_${artist.id}_${DateTime.now().millisecondsSinceEpoch}',
          title: _songTitles[rng.nextInt(_songTitles.length)], // Use a random title from the list
          artistId: artist.id,
          popularityFactor: popularityFactor,
          viralFactor: viralFactor,
          salesPotential: salesPotential,
          totalStreams: 0,
          weeklyListeners: 0,
          weeksSinceRelease: 0,
        );
        addSong(newSong);
      }
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
    final List<Song> previousWeekTopSongs = worldSongs.where((song) => song.currentRank != null && song.currentRank! <= 30).toList();
    previousWeekTopSongs.sort((a, b) => a.currentRank!.compareTo(b.currentRank!));

    // Reset chart-related properties for all songs
    for (var song in worldSongs) {
      song.lastWeekRank = song.currentRank; // Store last week's rank
      song.currentRank = null; // Reset current rank
      song.isNewEntry = song.weeksOnChart == 0; // If weeksOnChart is 0, it's a new entry
      song.isViral = false; // Reset viral status
      if (song.listenerHistory.length >= 4) {
        song.listenerHistory.removeAt(0); // Keep history to last 4 weeks
      }
      song.listenerHistory.add(song.weeklyListeners); // Add current weekly listeners to history

      // Apply song aging: streams taper off after 8-12 weeks unless boosted.
      // This logic can be expanded with more detailed aging curves.
      if (song.weeksSinceRelease > 8 && song.viralFactor < 50) { // If not very viral
        song.popularityFactor *= 0.95; // Gradual decrease
        song.viralFactor *= 0.9; // Viral factor decreases faster
        song.salesPotential *= 0.95;
      }

      final listeners = _calculateWeeklyListenersForSong(song);
      song.weeklyListeners = listeners;
      song.totalStreams += listeners;
      song.weeksSinceRelease++;

      _applySongPerformanceToArtist(song);
    }

    // Sort all songs by totalStreams to determine new ranks
    worldSongs.sort((a, b) => b.totalStreams.compareTo(a.totalStreams));

    // Update current ranks and track biggest movers
    int biggestGainerDelta = 0;
    int biggestDropDelta = 0;

    for (int i = 0; i < worldSongs.length; i++) {
      final song = worldSongs[i];
      final newRank = i + 1;

      // Only consider songs that are in the Top 30 for rank tracking for now
      if (newRank <= 30) {
        song.currentRank = newRank;
        if (song.peakRank == null || newRank < song.peakRank!) {
          song.peakRank = newRank; // Update peak rank if current rank is better
        }
        song.weeksOnChart++;

        // Check for rank changes
        if (song.lastWeekRank != null) {
          final delta = song.lastWeekRank! - newRank; // Positive delta means moving up
          if (delta > biggestGainerDelta) {
            biggestGainerDelta = delta;
          }
          if (delta < biggestDropDelta) {
            biggestDropDelta = delta;
          }
          song.isNewEntry = false; // It's not a new entry if it had a last week rank
        } else {
          song.isNewEntry = true; // No last week rank, so it's a new entry
        }
      }
    }
    
    // Apply cumulative streams to artists
    for (var artist in worldArtists) {
      artist.cumulativeStreams = worldSongs.where((song) => song.artistId == artist.id).fold(0.0, (sum, song) => sum + song.totalStreams);
      // Update label tier based on cumulative streams (example logic)
      if (artist.cumulativeStreams > 10000000) {
        artist.labelTier = "Major";
      } else if (artist.cumulativeStreams > 1000000) {
        artist.labelTier = "Indie";
      } else if (artist.cumulativeStreams > 100000) {
        artist.labelTier = "Underground";
      }
    }

    // TODO: Implement chart events and player milestones
    addNotification('Charts have been recalculated for the week.');

    notifyListeners();
  }

  List<Song> getTopSongs(int limit) {
    // Ensure songs are sorted and filtered to only include those with a currentRank within the limit
    return worldSongs.where((song) => song.currentRank != null && song.currentRank! <= limit).toList()..sort((a, b) => a.currentRank!.compareTo(b.currentRank!));
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
    saveGame(); // Save initial game state
  }

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
