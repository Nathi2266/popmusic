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
    for (var song in worldSongs) {
      song.lastWeekListeners = song.weeklyListeners;

      final listeners = _calculateWeeklyListenersForSong(song);
      song.weeklyListeners = listeners;
      song.totalStreams += listeners;
      song.weeksSinceRelease++;

      _applySongPerformanceToArtist(song);
    }

    worldSongs.sort((a, b) => b.totalStreams.compareTo(a.totalStreams));
    notifyListeners();
  }

  List<Song> getTopSongs(int limit) {
    worldSongs.sort((a, b) => b.totalStreams.compareTo(a.totalStreams));
    return worldSongs.take(limit).toList();
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
