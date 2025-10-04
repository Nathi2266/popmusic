import 'package:flutter/foundation.dart';
import 'dart:math';
import '../models/artist.dart';
import '../models/artist_attributes.dart';
import '../models/song.dart';
import '../models/event.dart';
import '../data/npc_artists.dart';
import '../models/summary_models.dart';


class GameStateService extends ChangeNotifier {
  Artist? _player;
  List<Artist> _npcs = [];
  List<Song> _allSongs = [];
  List<GameEvent> _eventHistory = [];
  int _currentWeek = 0;
  int _currentYear = 2025;
  int _currentMonth = 1;
  int _weekOfMonth = 1;

  List<ArtistActivity> _lastWeekActivities = [];
  List<GameEvent> _lastWeekEvents = [];
  List<SongSummary> _worldSongs = [];
  final Random _rng = Random(); // Move _rng to be a class member

  Artist? get player => _player;
  List<Artist> get npcs => _npcs;
  List<Song> get allSongs => _allSongs;
  int get currentWeek => _currentWeek;
  int get currentYear => _currentYear;
  int get currentMonth => _currentMonth;
  int get weekOfMonth => _weekOfMonth;
  List<GameEvent> get eventHistory => _eventHistory;
  List<ArtistActivity> get lastWeekActivities => _lastWeekActivities;
  List<GameEvent> get lastWeekEvents => _lastWeekEvents;
  List<SongSummary> get worldSongs => _worldSongs;

  bool get isGameStarted => _player != null;

  void initializeWorld(List<String> npcNames) {
    _npcs = NPCArtists.generateNPCs();
    _worldSongs = [
      SongSummary(title: 'Underground Anthem', artistName: npcNames.isNotEmpty ? npcNames[_rng.nextInt(npcNames.length)] : 'BandX', streams: 12000),
      SongSummary(title: 'City Lights', artistName: npcNames.isNotEmpty ? npcNames[_rng.nextInt(npcNames.length)] : 'BandY', streams: 9800),
    ];
  }

  void startNewGame(String playerName, Genre primaryGenre) {
    _player = Artist(
      id: 'player',
      name: playerName,
      isPlayer: true,
      primaryGenre: primaryGenre,
      attributes: ArtistAttributes(
        popularity: 10,
        reputation: 10,
        performance: 50,
        talent: 60,
        production: 40,
        songwriting: 55,
        charisma: 50,
        marketing: 30,
        networking: 40,
        creativity: 60,
        discipline: 50,
        stamina: 80,
        controversy: 5,
        wealth: 10,
        influence: 5,
        happiness: 50,
        health: 80,
      ),
      money: 5000,
      fanCount: 100,
      relationships: {},
    );

    _npcs = NPCArtists.generateNPCs();
    _allSongs = [];
    _eventHistory = [];
    _currentWeek = 0;
    _currentYear = 2025;
    _currentMonth = 1;
    _weekOfMonth = 1;
    _lastWeekActivities = [];
    _lastWeekEvents = [];
    _worldSongs = [];

    notifyListeners();
  }

  void advanceWeek() {
    _lastWeekActivities = [];
    _lastWeekEvents = [];

    _weekOfMonth++;
    if (_weekOfMonth > 4) {
      _weekOfMonth = 1;
      _currentMonth++;
      if (_currentMonth > 12) {
        _currentMonth = 1;
        _currentYear++;
        _handleEndOfYear();
      }
    }

    if (_player != null) {
      _player!.weeksSinceDebut++;
      _updatePlayerWeekly();
    }

    _generateNpcActivities();
    _generateRandomEvents();
    _updateSongMetrics();
    _applyEventEffectsToPlayer();

    for (var npc in _npcs) {
      npc.weeksSinceDebut++;
      _updateNPCWeekly(npc);
    }

    for (var song in _allSongs) {
      _updateSongWeekly(song);
    }

    notifyListeners();
  }

  void networkWithArtist(Artist targetArtist) {
    if (_player == null) return;

    // Increase relationship
    int currentRelationship = _player!.relationships[targetArtist.id] ?? 0;
    _player!.relationships[targetArtist.id] = (currentRelationship + 10).clamp(-100, 100);

    // Deduct stamina from player (e.g., 5 stamina)
    _player!.attributes.stamina = (_player!.attributes.stamina - 5).clamp(0, 100);

    // Deduct money from player (e.g., 50 money)
    _player!.money -= 50; 

    // Advance the week
    advanceWeek();

    notifyListeners();
  }

  void _handleEndOfYear() {
    if (_player == null) return;
    _generateEndOfYearAwards();
  }

  void _generateRandomEvents() {
    int globalRoll = _rng.nextInt(100);
    if (globalRoll < 30) {
      _lastWeekEvents.add(GameEvent(
        id: 'event_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Label Scout in Town',
        description: 'Scouts from a major label are attending shows this week.',
        type: EventType.opportunity,
        severity: EventSeverity.low,
        attributeImpacts: {'popularity': 2},
      ));
    }

    if (globalRoll >= 30 && globalRoll < 50) {
      _lastWeekEvents.add(GameEvent(
        id: 'event_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Unexpected Collaboration Offer',
        description: 'An NPC artist sent a DM for a collab.',
        type: EventType.collaboration,
        severity: EventSeverity.low,
        attributeImpacts: {'networking': 3},
      ));
    }

    if (globalRoll >= 50 && globalRoll < 70) {
      _lastWeekEvents.add(GameEvent(
        id: 'event_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Social Media Backlash',
        description: 'A post was misinterpreted and is causing backlash.',
        type: EventType.scandal,
        severity: EventSeverity.high,
        attributeImpacts: {'reputation': -8, 'controversy': 10, 'happiness': -5},
      ));
    }

    int playerRoll = _rng.nextInt(100);
    if (playerRoll < 25) {
      _lastWeekEvents.add(GameEvent(
        id: 'event_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Offer: Studio Time Discount',
        description: 'A local studio is offering discounted time this week.',
        type: EventType.opportunity,
        severity: EventSeverity.low,
        attributeImpacts: {'production': 4},
      ));
    } else if (playerRoll >= 25 && playerRoll < 40) {
      _lastWeekEvents.add(GameEvent(
        id: 'event_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Diss Track Response',
        description: 'A rival dropped a diss. Do you respond or ignore?',
        type: EventType.rivalry,
        severity: EventSeverity.medium,
        attributeImpacts: {'controversy': 6, 'popularity': 3},
      ));
    }
  }

  void _updateSongMetrics() {
    for (var s in _allSongs) {
      s.streams += 500 + _rng.nextInt(5000);
    }
    _allSongs.sort((a, b) => b.streams.compareTo(a.streams));
    _worldSongs = _allSongs.map((song) => SongSummary(
      title: song.title,
      artistName: _npcs.firstWhere((npc) => npc.id == song.artistId, orElse: () => _player!).name,
      streams: song.streams.toDouble(),
    )).toList();
  }

  void _applyEventEffectsToPlayer() {
    if (_player == null) return;
    for (var e in _lastWeekEvents) {
      e.attributeImpacts.forEach((key, value) {
        updatePlayerAttribute(key, value);
      });
    }
    if ((_player!.attributes.controversy) > 40) {
      double loss = 50 + _rng.nextInt(200).toDouble(); // Ensure double type
      _player!.money = max(0.0, _player!.money - loss); // Ensure double type
    }
  }

  void _generateEndOfYearAwards() {
    List<String> nominees = [];
    Map<String, double> totals = {};
    for (var s in _allSongs) {
      Artist? artist = _npcs.firstWhere((npc) => npc.id == s.artistId, orElse: () => _player!);
      totals[artist.name] = (totals[artist.name] ?? 0) + s.streams;
    }
    List<MapEntry<String, double>> ranking = totals.entries.toList()..sort((a,b)=>b.value.compareTo(a.value));
    for (int i = 0; i < min(5, ranking.length); i++) {
      nominees.add(ranking[i].key);
    }
    _lastWeekEvents.add(GameEvent(
      id: 'event_${DateTime.now().millisecondsSinceEpoch}',
      title: 'End of Year Awards - Best Artist Nominees',
      description: 'Top nominees: ${nominees.join(', ')}',
      type: EventType.award,
      severity: EventSeverity.low,
    ));
  }

  void _updatePlayerWeekly() {
    if (_player == null) return;

    _player!.attributes.stamina = 
        (_player!.attributes.stamina + 5).clamp(0, 100);
    
    _player!.attributes.popularity = 
        (_player!.attributes.popularity * 0.99).clamp(0, 100);
    
    int weeklyIncome = 0;
    switch (_player!.labelTier) {
      case LabelTier.unsigned:
        weeklyIncome = 0;
        break;
      case LabelTier.indie:
        weeklyIncome = 500;
        break;
      case LabelTier.major:
        weeklyIncome = 2000;
        break;
      case LabelTier.superstar:
        weeklyIncome = 10000;
        break;
    }
    _player!.money += weeklyIncome;
  }

  void _updateNPCWeekly(Artist npc) {
    final random = Random();
    
    if (random.nextDouble() < 0.05) {
      _npcReleaseSong(npc);
    }

    npc.attributes.popularity = 
        (npc.attributes.popularity * 0.995).clamp(0, 100);
  }

  void _updateSongWeekly(Song song) {
    // Hype decay handled in song model
  }

  void _generateNpcActivities() {
    _lastWeekActivities = [];
    int activeCount = min(6, _npcs.length);
    List<int> indices = [];
    while (indices.length < activeCount) {
      int i = _rng.nextInt(_npcs.length);
      if (!indices.contains(i)) indices.add(i);
    }

    for (int i in indices) {
      Artist npc = _npcs[i];
      int roll = _rng.nextInt(100);
      if (roll < 45) {
        String title = _randomSongTitle();
        _npcReleaseSongWithTitle(npc, title);
        _lastWeekActivities.add(ArtistActivity(artistName: npc.name, activity: 'Released "$title"'));
      } else if (roll < 75) {
        _lastWeekActivities.add(ArtistActivity(artistName: npc.name, activity: 'Played a show in the city'));
      } else {
        _lastWeekActivities.add(ArtistActivity(artistName: npc.name, activity: 'Was involved in a viral scandal'));
        _lastWeekEvents.add(GameEvent(
          id: 'event_${DateTime.now().millisecondsSinceEpoch}',
          title: '${npc.name} scandal',
          description: 'A viral story about ${npc.name} is trending.',
          type: EventType.scandal,
          severity: EventSeverity.medium,
          attributeImpacts: {'reputation': -3, 'controversy': 5},
        ));
      }
    }
  }

  void _npcReleaseSong(Artist npc) {
    final random = Random();
    final quality = 40 + random.nextInt(60);
    
    final song = Song(
      id: 'song_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Song by ${npc.name}',
      artistId: npc.id,
      genre: npc.primaryGenre,
      quality: quality,
      hypeLevel: random.nextInt(50),
      streams: 0, // Initialize streams
    );

    _allSongs.add(song);
    npc.releasedSongs.add(song.id);
  }

  void _npcReleaseSongWithTitle(Artist npc, String title) {
    final random = Random();
    final quality = 40 + random.nextInt(60);

    final song = Song(
      id: 'song_${DateTime.now().millisecondsSinceEpoch}_${title.replaceAll(' ', '_')}',
      title: title,
      artistId: npc.id,
      genre: npc.primaryGenre,
      quality: quality,
      hypeLevel: random.nextInt(50),
      streams: 0,
    );
    _allSongs.add(song);
    npc.releasedSongs.add(song.id);
  }

  String _randomSongTitle() {
    List<String> words = ['Midnight','Echo','Wave','Rush','Haze','Dream','Sky','Pulse','Groove','Sun'];
    return '${words[_rng.nextInt(words.length)]} ${words[_rng.nextInt(words.length)]}';
  }

  void addSong(Song song) {
    _allSongs.add(song);
    if (_player != null) {
      _player!.releasedSongs.add(song.id);
    }
    notifyListeners();
  }

  void updatePlayerMoney(int amount) {
    if (_player != null) {
      _player!.money += amount;
      notifyListeners();
    }
  }

  void updatePlayerAttribute(String attribute, double change) {
    if (_player == null) return;

    switch (attribute) {
      case 'popularity':
        _player!.attributes.popularity = 
            (_player!.attributes.popularity + change).clamp(0, 100);
        break;
      case 'reputation':
        _player!.attributes.reputation = 
            (_player!.attributes.reputation + change).clamp(0, 100);
        break;
      case 'performance':
        _player!.attributes.performance = 
            (_player!.attributes.performance + change).clamp(0, 100);
        break;
      case 'stamina':
        _player!.attributes.stamina = 
            (_player!.attributes.stamina + change).clamp(0, 100);
        break;
      case 'influence':
        _player!.attributes.influence = 
            (_player!.attributes.influence + change).clamp(0, 100);
        break;
      case 'wealth':
        _player!.attributes.wealth = 
            (_player!.attributes.wealth + change).clamp(0, 100);
        break;
      case 'happiness':
        _player!.attributes.happiness = 
            (_player!.attributes.happiness + change).clamp(0, 100);
        break;
      case 'health':
        _player!.attributes.health = 
            (_player!.attributes.health + change).clamp(0, 100);
        break;
      case 'controversy':
        _player!.attributes.controversy = 
            (_player!.attributes.controversy + change).clamp(0, 100);
        break;
    }

    notifyListeners();
  }
}
