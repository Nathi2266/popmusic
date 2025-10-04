import 'package:flutter/foundation.dart';
import 'dart:math';
import '../models/artist.dart';
import '../models/artist_attributes.dart';
import '../models/song.dart';
import '../models/event.dart';
import '../data/npc_artists.dart';

class GameStateService extends ChangeNotifier {
  Artist? _player;
  List<Artist> _npcs = [];
  List<Song> _allSongs = [];
  List<GameEvent> _eventHistory = [];
  int _currentWeek = 0;
  int _currentYear = 2025;

  Artist? get player => _player;
  List<Artist> get npcs => _npcs;
  List<Song> get allSongs => List.unmodifiable(_allSongs);
  int get currentWeek => _currentWeek;
  int get currentYear => _currentYear;
  List<GameEvent> get eventHistory => _eventHistory;

  bool get isGameStarted => _player != null;

  void startNewGame(String playerName, Genre primaryGenre) {
    _player = Artist(
      id: 'player',
      name: playerName,
      isPlayer: true,
      primaryGenre: primaryGenre,
      attributes: ArtistAttributes(
        popularity: 5,
        reputation: 50,
        performance: 50,
        talent: 60,
        production: 40,
        songwriting: 55,
        charisma: 50,
        marketing: 30,
        networking: 40,
        creativity: 60,
        discipline: 50,
        stamina: 50,
        controversy: 0,
        wealth: 10,
        influence: 5,
      ),
      money: 5000,
      fanCount: 100,
    );

    _npcs = NPCArtists.generateNPCs();
    _allSongs = [];
    _eventHistory = [];
    _currentWeek = 0;
    _currentYear = 2025;

    notifyListeners();
  }

  void advanceWeek() {
    _currentWeek++;
    if (_currentWeek >= 52) {
      _currentWeek = 0;
      _currentYear++;
      _handleEndOfYear();
    }

    if (_player != null) {
      _player!.weeksSinceDebut++;
      _updatePlayerWeekly();
    }

    for (var npc in _npcs) {
      npc.weeksSinceDebut++;
      _updateNPCWeekly(npc);
    }

    for (var song in _allSongs) {
      _updateSongWeekly(song);
    }

    if (Random().nextDouble() < 0.1) {
      _triggerRandomEvent();
    }

    notifyListeners();
  }

  void _handleEndOfYear() {
    if (_player == null) return;

    if (_player!.attributes.popularity > 70 && Random().nextBool()) {
      _player!.awards.add('$_currentYear Artist of the Year');
    }
    
    if (_player!.releasedSongs.isNotEmpty && Random().nextDouble() < 0.3) {
      _player!.awards.add('$_currentYear Best New Artist');
    }
  }

  void _triggerRandomEvent() {
    if (_player == null) return;

    final random = Random();
    final eventType = random.nextInt(3);

    switch (eventType) {
      case 0:
        // Positive event
        _player!.attributes.popularity = 
            (_player!.attributes.popularity + 5).clamp(0, 100);
        break;
      case 1:
        // Scandal
        _player!.attributes.controversy = 
            (_player!.attributes.controversy + 10).clamp(0, 100);
        _player!.attributes.reputation = 
            (_player!.attributes.reputation - 5).clamp(0, 100);
        break;
      case 2:
        // Opportunity
        _player!.money += 1000;
        break;
    }
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
    );

    _allSongs.add(song);
    npc.releasedSongs.add(song.id);
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
    }

    notifyListeners();
  }
}
