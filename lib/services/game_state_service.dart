import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/artist.dart';
import '../models/artist_appearance.dart';
import '../models/song.dart';
import '../models/event.dart';
import '../models/label_tier.dart';
import '../data/npc_artists.dart'; // Corrected import for NPCArtists
import '../models/player_level.dart';
import '../models/challenge.dart';
import '../models/album.dart';
import 'achievement_service.dart';
import 'challenge_service.dart';

class GameStateService extends ChangeNotifier {
  static const String _saveBoxName = 'save_game';
  static const String _saveSlotKey = 'slot_0';
  static Box? _saveBox;

  ChallengeService? _challenges;
  AchievementService? _achievements;

  void attachChallenges(ChallengeService challenges) {
    _challenges = challenges;
  }

  void attachAchievements(AchievementService achievements) {
    _achievements = achievements;
  }

  static Future<void> init() async {
    _saveBox = await Hive.openBox(_saveBoxName);
  }

  bool get hasSavedGameOnDisk =>
      _saveBox?.containsKey(_saveSlotKey) ?? false;

  bool get canContinue => isGameStarted || hasSavedGameOnDisk;

  int year = 2025;
  int month = 1;
  int weekOfMonth = 1;

  // World data
  List<Song> worldSongs = [];
  List<Artist> worldArtists = [];
  List<GameEvent> lastWeekEvents = [];

  final List<String> availableGenres = ['Pop', 'Rock', 'Hip-Hop', 'R&B', 'Electronic', 'Indie'];
  String? currentGenreFilter;
  String trendingGenre = 'Pop';
  final Map<String, double> genreHeat = {};

  /// Player's most-released genre (defaults to Pop).
  String get playerDominantGenre {
    if (_player == null) return 'Pop';
    final counts = <String, int>{};
    for (final song in playerSongs) {
      counts[song.genre] = (counts[song.genre] ?? 0) + 1;
    }
    if (counts.isEmpty) return 'Pop';
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  double genreHeatFor(String genre) => genreHeat[genre] ?? 40.0;

  String chartViewMode = 'songs'; // 'songs' or 'artists'

  List<Album> playerAlbums = [];
  List<String> weeklyHeadlines = [];
  String lastWeekRecap = '';
  double lastWeekRoyalties = 0;
  int hustlesThisWeek = 0;
  String playerHomeGenre = 'Pop';
  /// 0.85 easy · 1.0 normal · 1.18 hard — scales NPC/rival pressure.
  double worldHeat = 1.0;
  /// Stamina was already low when this week started — streams dip even after rest.
  bool weekStartedBurnedOut = false;

  String get weeklyGoalHint {
    final active = _challenges?.activeChallenges ?? const [];
    if (active.isEmpty) {
      return 'Release a single or hustle the scene this week.';
    }
    final first = active.first;
    return '${first.title} · ${first.currentProgress}/${first.targetValue}';
  }

  /// Scripted career storyline progress.
  final Set<String> completedStoryBeats = {};
  String currentChapter = 'Unsigned Hustle';

  List<Map<String, dynamic>> weeklyChartHistory = []; // Stores historical chart data

  /// Named rivals who compete harder on the charts.
  List<String> rivalIds = [];

  bool isRival(String artistId) => rivalIds.contains(artistId);

  List<Artist> get rivals => rivalIds
      .map(getArtistById)
      .whereType<Artist>()
      .toList();

  /// Best chart rank (1 = #1) among an artist's songs; null if none charted.
  int? bestChartRankFor(String artistId) {
    int? best;
    for (var i = 0; i < worldSongs.length; i++) {
      if (worldSongs[i].artistId != artistId) continue;
      final rank = i + 1;
      if (best == null || rank < best) best = rank;
    }
    return best;
  }

  // Predefined list of NPC song titles
  final List<String> _npcSongTitles = [
    'Midnight Dreams',
    'Lost in the City',
    'Neon Pulse',
    'Crown & Chains',
    'Skyfall Nights',
    'Broken Promises',
    'Paradise Drive',
    'Love Frequency',
    'Shadows & Lights',
    'Golden Hour',
    'Fame & Fire',
    'Silent Thunder',
    'Starlit Road',
    'Rebel Heart',
    'Wildflower',
    'Secrets in Motion',
    'Fast Lane Love',
    'Echo Chamber',
    'Ride or Fade',
    'Diamond Tears',
    'Heart on Replay',
    'Blood & Velvet',
    'Static Love',
    'Digital Skyline',
    'Flame in the Cold',
    'Tomorrow’s Echo',
    'Love Like Gasoline',
    'Runaway Fame',
    'City Serenade',
    'Broken Halo',
    'Rhythm & Roses',
    'Skyline Fever',
    'Blue Haze',
    'Lights On Me',
    'Broken Microphone',
    'Unwritten Stars',
    'Fire Escape Love',
    'High Voltage Heart',
    'Silent Fame',
    'Bitter Sweet Glow',
    'Love & Envy',
    'Concrete Crown',
    'Wild Horizon',
    'Shattered Mirrors',
    'Velvet Nights',
    'Storm of Roses',
    'Heat of the Crowd',
    'Lunar Rhythm',
    'Famous Alone',
    'Spark & Silence',
    'Silver & Smoke',
    'Heartbeat Skyline',
    'Drown in Lights',
    'Chaos Melody',
    'Drifting Echoes',
    'Love & Legends',
    'Phoenix Rising',
    'Burning Out Loud',
    'Glitter & Dust',
    'Hidden Frequencies',
    'Cold Fame',
    'Angel in Blue',
    'Sunset Riot',
    'Bad Habits',
    'Rhythm of Steel',
    'Wired Emotions',
    'Dangerous Love',
    'Electric Tears',
    'Fame Machine',
    'Paper Crowns',
    'Ghosts of Pop',
    'Last Encore',
    'Broken Stage',
    'Echoed Silence',
    'Fever Dream',
    'Spotlight Shadow',
    'Love’s Fireworks',
    'Wild Fame',
    'Stolen Harmony',
    'Roses & Chains',
    'Burning Starlight',
    'Digital Crown',
    'Melody in Flames',
    'Rain & Fire',
    'Electric Soul',
    'Nightfall Roses',
    'Lost & Famous',
    'Glass Halo',
    'Running with Echoes',
    'Whispered Spotlight',
    'Violet Sky',
    'Fame Addiction',
    'Tears on Vinyl',
    'Midnight Empire',
    'Chasing Fireworks',
    'Lonely Star',
    'Crowned Illusions',
    'Darkened Rhythm',
    'Overdrive Love',
    'Endless Applause',
    'Echoes of Tomorrow',
    'Savage Harmony',
    'Blue Flame Love',
    'Wild Silence',
    'Heavy on My Mind',
    'Toxic Paradise',
    'Broken Wavelengths',
    'Spotlight Dreams',
    'Digital Tears',
    'Velvet Crown',
    'Ghost in the Beat',
    'Living for Tonight',
    'Chrome Shadows',
    'Ride the Thunder',
    'Lost Horizon',
    'Crashing Fame',
    'Heatwave Emotions',
    'Diamond Skies',
    'Pulse of Fire',
    'Unstoppable Love',
    'Chaos Crown',
    'Violet Rain',
    'Legends & Lies',
    'Popstar Fever',
    'Electric Ocean',
    'Drip & Glory',
    'Neon Kingdom',
    'Chained to the Rhythm',
    'Nightfall Flames',
    'After Midnight',
    'Fame Over Fear',
    'Crown of Dust',
    'Shadows of Gold',
    'Rebel Symphony',
    'Moonlight Addiction',
    'Concrete Roses',
    'Heart of Voltage',
    'Storm Chaser',
    'Lights Fall Down',
    'Dream in Static',
    'Pop Apocalypse',
    'Forever Glow',
    'Crying in Glitter',
    'King Without a Throne',
    'Wild Static',
    'Fever Crown',
    'Scarlet Vibes',
    'Endless Mirage',
    'Runaway Stars',
    'Stolen Empire',
    'Paper Sparks',
    'Melody & Madness',
    'Cyber Love',
    'Crown in Chains',
    'Tears in Rhythm',
    'Lonely Anthem',
    'Fade into Fire',
    'Skyline Stars',
    'Underground Glory',
    'Immortal Beat',
    'Digital Halo',
    'Crushed Diamonds',
    'Urban Serenade',
    'Burning Midnight',
    'Scars & Fame',
    'Heavy Crown',
    'Shattered Lights',
    'Golden Mirage',
    'Toxic Skyline',
    'Eternal Flame',
    'Rebel Lights',
    'Ashes of Stardom',
    'Blood on Vinyl',
    'Wildfire Heart',
    'Vanity Rhythm',
    'Soul Machine',
    'Love Electric',
    'Viral Empire',
    'Black Rose Melody',
    'Fame Phantom',
    'Heartstrings Broken',
    'Throne of Smoke',
    'Whispering Sparks',
    'Outlaw Symphony',
    'Crystal Fame',
    'Dreams in Motion',
    'Firestorm Rhythm',
    'Starstruck Shadows',
    'Pop Machine',
    'Phantom Glory',
    'Shining Void',
    'Glitter Chains',
    'Famous or Forgotten',
    'Last Serenade',
    'Thunder Crown',
    'Rose Gold Lights',
    'Masked Fame',
    'Illusion & Love',
    'Immortal Stage',
    'Fame Horizon',
  ];

  // ---------------------------
  // Time progression
  // ---------------------------
  void proceedWeek() {
    weekOfMonth++;
    var yearRolled = false;
    if (weekOfMonth > 4) {
      weekOfMonth = 1;
      month++;
      if (month > 12) {
        month = 1;
        year++;
        yearRolled = true;
      }
    }

    hustlesThisWeek = 0;

    // New week: drop last week's cards, then build this week's.
    lastWeekEvents.clear();
    weeklyHeadlines.clear();
    weekStartedBurnedOut = false;

    // Weekly player recovery / label stipend (discipline slightly boosts stamina)
    if (_player != null) {
      final incomingStamina = _player!.attributes['stamina'] ?? 80;
      weekStartedBurnedOut = incomingStamina < 22;

      final discipline = _player!.attributes['discipline'] ?? 50;
      final staminaGain = 18 + (discipline / 25);
      updatePlayerAttribute('stamina', staminaGain.clamp(18.0, 28.0));
      final weeksInIndustry =
          ((_player!.attributes['weeksSinceDebut'] ?? 0) + 1).clamp(0.0, 9999.0);
      _player!.attributes['weeksSinceDebut'] = weeksInIndustry;
      updatePlayerMoney(_player!.labelTier.weeklyIncome);
      // Merch / street sales scale with fans + wealth
      final wealth = _player!.attributes['wealth'] ?? 10;
      final merch = (playerFanCount * 0.04) + (wealth * 8);
      updatePlayerMoney(merch);
      _player!.attributes['wealth'] =
          (wealth + (playerFanCount / 50000)).clamp(0.0, 100.0);

      if (weekStartedBurnedOut) {
        lastWeekEvents.add(GameEvent(
          id: 'fatigue_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Burned Out',
          description:
              'Last week drained you. Streams already feel the dip. Sleep it off or grind through?',
          type: EventType.scandal,
          severity: EventSeverity.medium,
          choices: const ['Sleep it off', 'Grind anyway'],
          choiceOutcomes: const {
            'Sleep it off': {'stamina': 15, 'happiness': 5},
            'Grind anyway': {
              'stamina': -8,
              'discipline': 4,
              'happiness': -6,
              '_money': 180,
            },
          },
        ));
        weeklyHeadlines.add(
          '${_player!.name} looks exhausted on the timeline. Streams dip.',
        );
      }
    }

    _updateGenreTrends();
    _generateWeeklyEvents(); // Generate events for the current week
    _checkStoryBeats();
    _generateNPCSongs(); // Generate new songs from NPCs
    if (yearRolled) {
      _runYearEndAwards();
    }

    // Recalculate charts after events
    recalculateCharts();
    _payStreamRoyalties();
    _buildWeeklyRecap();
    saveGame();
  }

  /// Streaming payouts: weekly listeners convert to money; label takes a cut.
  void _payStreamRoyalties() {
    lastWeekRoyalties = 0;
    if (_player == null) return;
    final streams = playerSongs.fold<double>(
      0,
      (sum, song) => sum + song.weeklyListeners,
    );
    if (streams <= 0) return;

    const perStream = 0.0038;
    lastWeekRoyalties = streams * perStream * _player!.labelTier.royaltyKeep;
    if (lastWeekRoyalties > 0) {
      updatePlayerMoney(lastWeekRoyalties);
      weeklyHeadlines.add(
        'Streaming paid \$${lastWeekRoyalties.toStringAsFixed(0)} this week.',
      );
    }
  }

  void _buildWeeklyRecap() {
    if (_player == null) {
      lastWeekRecap = '';
      return;
    }
    final best = playerSongs.isEmpty
        ? null
        : playerSongs.reduce(
            (a, b) => a.weeklyListeners >= b.weeklyListeners ? a : b,
          );
    final rank = best == null ? null : worldSongs.indexOf(best) + 1;
    final parts = <String>[
      'Week $weekOfMonth · ${player!.name}',
      if (best != null && rank != null && rank > 0)
        '"${best.title}" sits at #$rank (${best.weeklyListeners.toStringAsFixed(0)} weekly)'
      else
        'No singles charting — drop something.',
      'Trend: $trendingGenre · Chapter: $currentChapter',
    ];
    if (lastWeekRoyalties > 0) {
      parts.add('Royalties \$${lastWeekRoyalties.toStringAsFixed(0)}');
    }
    if (weekStartedBurnedOut) {
      parts.add('Burned out — streams dipped');
    }
    final videoHits = playerSongs.where((s) => s.videoWeeksRemaining > 0).length;
    if (videoHits > 0) {
      parts.add('$videoHits video${videoHits == 1 ? '' : 's'} boosting');
    }
    lastWeekRecap = parts.join(' · ');
    if (weeklyHeadlines.isEmpty) {
      weeklyHeadlines.add(
        '${player!.name} keeps grinding the ${playerDominantGenre} lane.',
      );
    }
  }

  String? hustleNetwork() {
    if (_player == null) return 'No player';
    if (hustlesThisWeek >= 2) return 'Already hustled enough this week';
    final stamina = _player!.attributes['stamina'] ?? 0;
    if (stamina < 12) return 'Too tired to network';
    if (playerMoney < 120) return 'Need \$120 for the scene';
    hustlesThisWeek++;
    updatePlayerAttribute('stamina', -12);
    updatePlayerMoney(-120);
    updatePlayerAttribute('networking', 4);
    updatePlayerAttribute('charisma', 2);
    updatePlayerAttribute('marketing', 1);
    updatePlayerFanCount(40 + Random().nextInt(80));
    weeklyHeadlines.add('${_player!.name} was spotted at a writers room hang.');
    addPlayerXp(15);
    notifyListeners();
    saveGame();
    return null;
  }

  String? trainSkill(String skill) {
    if (_player == null) return 'No player';
    const trainable = {
      'songwriting',
      'production',
      'performance',
      'discipline',
      'creativity',
    };
    if (!trainable.contains(skill)) return 'Unknown skill';
    if (hustlesThisWeek >= 2) return 'Already trained enough this week';
    final stamina = _player!.attributes['stamina'] ?? 0;
    if (stamina < 14) return 'Too tired to train';
    if (playerMoney < 80) return 'Need \$80 for session time';
    hustlesThisWeek++;
    updatePlayerAttribute('stamina', -14);
    updatePlayerMoney(-80);
    updatePlayerAttribute(skill, 5);
    updatePlayerAttribute('discipline', 1);
    weeklyHeadlines.add('${_player!.name} locked in a $skill session.');
    addPlayerXp(12);
    notifyListeners();
    saveGame();
    return null;
  }

  String? pitchSongToRadio(String songId) {
    if (_player == null) return 'No player';
    Song? song;
    for (final s in worldSongs) {
      if (s.id == songId) {
        song = s;
        break;
      }
    }
    if (song == null || song.artistId != _player!.id) {
      return 'Pick one of your songs';
    }
    final cost = 350.0 + (_player!.labelTier.index * 150);
    if (playerMoney < cost) {
      return 'Need \$${cost.toStringAsFixed(0)} to pitch radio';
    }
    updatePlayerMoney(-cost);
    song.viralFactor = (song.viralFactor + 12 + Random().nextDouble() * 10)
        .clamp(0.0, 100.0);
    song.salesPotential =
        (song.salesPotential + 8).clamp(0.0, 100.0);
    updatePlayerAttribute('marketing', 2);
    weeklyHeadlines.add('Radio added "${song.title}" to mid-day rotation.');
    lastWeekEvents.add(GameEvent(
      id: 'radio_pitch_${song.id}_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Radio Pitch Landed',
      description:
          '"${song.title}" is spinning on regional radio. Expect a listener bump.',
      type: EventType.opportunity,
      severity: EventSeverity.medium,
    ));
    addPlayerXp(20);
    notifyListeners();
    saveGame();
    return null;
  }

  double musicVideoCost() {
    final tier = _player?.labelTier.index ?? 0;
    return 650.0 + (tier * 400);
  }

  int musicVideoWeeks() {
    final tier = _player?.labelTier.index ?? 0;
    return (2 + tier).clamp(2, 4);
  }

  String? shootMusicVideo(String songId) {
    if (_player == null) return 'No player';
    Song? song;
    for (final s in worldSongs) {
      if (s.id == songId) {
        song = s;
        break;
      }
    }
    if (song == null || song.artistId != _player!.id) {
      return 'Pick one of your songs';
    }
    if (song.videoWeeksRemaining > 0) {
      return 'That video is still circulating (${song.videoWeeksRemaining}w left)';
    }
    final cost = musicVideoCost();
    if (playerMoney < cost) {
      return 'Need \$${cost.toStringAsFixed(0)} to shoot a video';
    }
    final stamina = _player!.attributes['stamina'] ?? 0;
    if (stamina < 12) return 'Too tired to shoot a video';

    updatePlayerMoney(-cost);
    updatePlayerAttribute('stamina', -12);
    updatePlayerAttribute('marketing', 3);
    song.videoWeeksRemaining = musicVideoWeeks();
    song.viralFactor =
        (song.viralFactor + 8 + Random().nextDouble() * 8).clamp(0.0, 100.0);
    weeklyHeadlines.add(
      'Music video for "${song.title}" is out — ${song.videoWeeksRemaining} weeks of extra streams.',
    );
    lastWeekEvents.add(GameEvent(
      id: 'mv_${song.id}_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Music Video Drop',
      description:
          '"${song.title}" has a video in rotation. Weekly listeners jump for ${song.videoWeeksRemaining} weeks.',
      type: EventType.opportunity,
      severity: EventSeverity.medium,
    ));
    addPlayerXp(25);
    notifyListeners();
    saveGame();
    return null;
  }

  String? compileAlbum(String title, List<String> songIds) {
    if (_player == null) return 'No player';
    final cleanTitle = title.trim();
    if (cleanTitle.isEmpty) return 'Name the album';
    if (songIds.length < 3) return 'Need at least 3 of your songs';
    if (songIds.length > 8) return 'Max 8 tracks';
    final owned = songIds.every(
      (id) => worldSongs.any((s) => s.id == id && s.artistId == _player!.id),
    );
    if (!owned) return 'All tracks must be yours';
    final alreadyUsed = playerAlbums.any(
      (a) => a.songIds.any(songIds.contains),
    );
    if (alreadyUsed) return 'A selected track is already on an album';
    final cost = 1500.0;
    if (playerMoney < cost) return 'Need \$1500 to press the album';
    updatePlayerMoney(-cost);
    updatePlayerAttribute('stamina', -10);
    playerAlbums.add(Album(
      id: 'album_${DateTime.now().millisecondsSinceEpoch}',
      title: cleanTitle,
      artistId: _player!.id,
      songIds: List<String>.from(songIds),
      releasedWeek: weekOfMonth,
      releasedMonth: month,
      releasedYear: year,
    ));
    for (final id in songIds) {
      final song = worldSongs.firstWhere((s) => s.id == id);
      song.salesPotential = (song.salesPotential + 10).clamp(0.0, 100.0);
      song.viralFactor = (song.viralFactor + 6).clamp(0.0, 100.0);
    }
    updatePlayerFanCount(250);
    addPlayerXp(80);
    weeklyHeadlines.add('${_player!.name} dropped the album "$cleanTitle".');
    lastWeekEvents.add(GameEvent(
      id: 'album_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Album Out: $cleanTitle',
      description:
          'A full project hits the stores. Catalog tracks get a sales bump.',
      type: EventType.opportunity,
      severity: EventSeverity.high,
    ));
    notifyListeners();
    saveGame();
    return null;
  }

  String? requestCollab(String artistId) {
    if (_player == null) return 'No player';
    if (artistId == _player!.id) return 'Cannot collab with yourself';
    final partner = getArtistById(artistId);
    if (partner == null) return 'Artist not found';
    final stamina = _player!.attributes['stamina'] ?? 0;
    if (stamina < 18) return 'Too tired to record a feature';
    if (playerMoney < 400) return 'Need \$400 studio + split';
    if (hustlesThisWeek >= 2) return 'Already hustled enough this week';
    hustlesThisWeek++;
    updatePlayerAttribute('stamina', -18);
    updatePlayerMoney(-400);
    final quality = (((_player!.attributes['songwriting'] ?? 40) +
                (partner.attributes['popularity'] ?? 40)) /
            2)
        .clamp(25.0, 95.0);
    worldSongs.add(Song(
      id: 'song_${DateTime.now().millisecondsSinceEpoch}_ask_collab',
      title: '${_player!.name} & ${partner.name} - Link Up',
      artistId: _player!.id,
      popularityFactor: quality,
      viralFactor: (38 + Random().nextDouble() * 28).clamp(10.0, 90.0),
      salesPotential: (32 + Random().nextDouble() * 28).clamp(10.0, 90.0),
      genre: playerHomeGenre,
      isNewEntry: true,
    ));
    updateArtistAttribute(partner.id, 'networking', 3);
    updatePlayerAttribute('networking', 4);
    updatePlayerFanCount(180);
    addPlayerXp(35);
    _challenges?.updateProgress(ChallengeType.releaseSongs, 1);
    weeklyHeadlines.add('New collab: ${_player!.name} x ${partner.name}.');
    notifyListeners();
    saveGame();
    return null;
  }

  String? retirePlayerSong(String songId) {
    final idx = worldSongs.indexWhere(
      (s) => s.id == songId && s.artistId == _player?.id,
    );
    if (idx < 0) return 'Song not found';
    final song = worldSongs.removeAt(idx);
    weeklyHeadlines.add('"${song.title}" was pulled from active rotation.');
    notifyListeners();
    saveGame();
    return null;
  }

  bool isSongOnAlbum(String songId) =>
      playerAlbums.any((a) => a.songIds.contains(songId));

  void _runYearEndAwards() {
    if (worldSongs.isEmpty) return;
    final ranked = List<Song>.from(worldSongs)..sort(_compareByChartScore);
    final songOfYear = ranked.first;
    final artistOfYearId = ranked.take(10).fold<Map<String, double>>({}, (m, s) {
      m[s.artistId] = (m[s.artistId] ?? 0) + chartScore(s);
      return m;
    });
    final aotyId = artistOfYearId.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
    final aoty = getArtistById(aotyId);
    final soyArtist = getArtistById(songOfYear.artistId);

    void grant(Artist? artist, String award) {
      if (artist == null) return;
      artist.awardsWon.add(award);
      if (artist.id == _player?.id) {
        playerMoney += 7500;
        _checkAwardAchievements();
      }
      updateArtistAttribute(artist.id, 'popularity', 8);
      lastWeekEvents.add(GameEvent(
        id: 'year_award_${award}_${artist.id}_$year',
        title: '$award — ${year - 1}',
        description: '${artist.name} takes home $award.',
        type: EventType.award,
        severity: EventSeverity.high,
      ));
    }

    grant(soyArtist, 'Song of the Year (${songOfYear.title})');
    if (aoty != null && aoty.id != soyArtist?.id) {
      grant(aoty, 'Artist of the Year');
    } else if (aoty != null) {
      grant(aoty, 'Artist of the Year');
    }

    if (_player != null && playerSongs.isNotEmpty) {
      final debuts = playerSongs.where((s) => s.weeksSinceRelease <= 20);
      if (debuts.isNotEmpty && (_player!.attributes['popularity'] ?? 0) < 55) {
        grant(_player, 'Breakthrough Artist');
      }
    }
    weeklyHeadlines.add('Awards night closed the books on ${year - 1}.');
  }

  void _refreshChapterTitle() {
    if (_player == null) {
      currentChapter = 'Unsigned Hustle';
      return;
    }
    switch (_player!.labelTier) {
      case LabelTier.superstar:
        currentChapter = 'Arena Era';
        break;
      case LabelTier.major:
        currentChapter = 'Major League';
        break;
      case LabelTier.indie:
        currentChapter = 'Indie Rise';
        break;
      case LabelTier.unsigned:
        final weeks = (_player!.attributes['weeksSinceDebut'] ?? 0).toInt();
        if (weeks >= 12) {
          currentChapter = 'Breaking Through';
        } else if (weeks >= 4) {
          currentChapter = 'City Circuit';
        } else {
          currentChapter = 'Unsigned Hustle';
        }
        break;
    }
  }

  bool _beatDone(String id) => completedStoryBeats.contains(id);

  void _markBeat(String id) => completedStoryBeats.add(id);

  /// Narrative spine: debut → scandal → indie fork → rival feud → festival → viral → major fork.
  void _checkStoryBeats() {
    if (_player == null) return;
    final weeks = (_player!.attributes['weeksSinceDebut'] ?? 0).toInt();
    final songs = playerSongs.length;
    final pop = _player!.attributes['popularity'] ?? 0;
    final rival = rivals.isNotEmpty ? rivals.first : null;

    // Beat 1: Opening chapter (week 1)
    if (!_beatDone('opening_hustle') && weeks >= 1) {
      _markBeat('opening_hustle');
      lastWeekEvents.add(GameEvent(
        id: 'story_opening_$weeks',
        title: 'Chapter: Unsigned Hustle',
        description:
            'You are nobody with a dream and a cheap mic. One single could change everything — or vanish into the noise.',
        type: EventType.opportunity,
        severity: EventSeverity.medium,
        choices: const ['Write Tonight', 'Network Instead', 'Rest & Plan'],
        choiceOutcomes: const {
          'Write Tonight': {
            'songwriting': 5,
            'creativity': 4,
            'stamina': -8,
          },
          'Network Instead': {
            'networking': 5,
            'charisma': 3,
            'stamina': -5,
          },
          'Rest & Plan': {
            'discipline': 4,
            'happiness': 3,
            'stamina': 10,
          },
        },
      ));
    }

    // Beat 2: After first release
    if (!_beatDone('debut_single') && songs >= 1) {
      _markBeat('debut_single');
      lastWeekEvents.add(GameEvent(
        id: 'story_debut_$weeks',
        title: 'Debut Is Live',
        description:
            'Your first song is out. The industry barely notices — but a few local blogs do. How do you follow up?',
        type: EventType.opportunity,
        severity: EventSeverity.medium,
        choices: const ['Push Promo Hard', 'Start the Next Track', 'Play Every Bar'],
        choiceOutcomes: const {
          'Push Promo Hard': {
            'marketing': 6,
            'popularity': 3,
            '_money': -250,
            '_fans': 120,
          },
          'Start the Next Track': {
            'songwriting': 4,
            'production': 3,
            'discipline': 2,
          },
          'Play Every Bar': {
            'performance': 5,
            'stamina': -12,
            '_fans': 200,
            '_money': 150,
          },
        },
      ));
    }

    // Beat 3: First real scandal choice (~week 4)
    if (!_beatDone('first_scandal_arc') && weeks >= 4) {
      _markBeat('first_scandal_arc');
      lastWeekEvents.add(GameEvent(
        id: 'story_scandal_$weeks',
        title: 'The Clip',
        description:
            'An old argument video surfaces. It is not career-ending — yet. Your response will define the next chapter.',
        type: EventType.scandal,
        severity: EventSeverity.high,
        choices: const ['Own It', 'Lawyer Up', 'Flood the Feed'],
        choiceOutcomes: const {
          'Own It': {
            'reputation': 6,
            'controversy': -5,
            'happiness': -4,
            '_fans': -80,
          },
          'Lawyer Up': {
            'reputation': 2,
            'controversy': -8,
            '_money': -800,
            'discipline': 3,
          },
          'Flood the Feed': {
            'marketing': 5,
            'controversy': 8,
            'popularity': 5,
            '_fans': 300,
          },
        },
      ));
    }

    // Beat 4: Indie label fork (story-weighted, once)
    if (!_beatDone('indie_label_fork') &&
        _player!.labelTier == LabelTier.unsigned &&
        pop >= 22 &&
        songs >= 2) {
      _markBeat('indie_label_fork');
      lastWeekEvents.add(GameEvent(
        id: 'story_indie_fork_$weeks',
        title: 'Indie Offer on the Table',
        description:
            'Neon Harbor Records wants to sign you. Small advance, real radio relationships — and less creative control.',
        type: EventType.labelOffer,
        severity: EventSeverity.high,
        choices: const ['Take the Meeting', 'Hold Out', 'Leak the Interest'],
        choiceOutcomes: const {
          'Take the Meeting': {
            'networking': 6,
            'influence': 5,
            'popularity': 4,
            'marketing': 3,
          },
          'Hold Out': {
            'discipline': 5,
            'reputation': 3,
            'happiness': -2,
          },
          'Leak the Interest': {
            'marketing': 4,
            'controversy': 4,
            'popularity': 3,
            'reputation': -2,
          },
        },
      ));
    }

    // Beat 5: Rival feud ignites
    if (!_beatDone('rival_feud') && weeks >= 8 && rival != null) {
      _markBeat('rival_feud');
      lastWeekEvents.add(GameEvent(
        id: 'story_feud_$weeks',
        title: 'Feud: ${rival.name}',
        description:
            '${rival.name} claims you copied their sound. Fans are picking sides. This rivalry just became personal.',
        type: EventType.rivalry,
        severity: EventSeverity.high,
        choices: const ['Diss Track Energy', 'Stay Classy', 'Collab to End It'],
        choiceOutcomes: {
          'Diss Track Energy': {
            'controversy': 12,
            'popularity': 6,
            'creativity': 4,
            'reputation': -4,
            '_fans': 400,
          },
          'Stay Classy': {
            'reputation': 7,
            'discipline': 4,
            'happiness': 2,
          },
          'Collab to End It': {
            'networking': 6,
            'fan_connection': 5,
            'popularity': 3,
            'stamina': -10,
            '_money': -200,
          },
        },
      ));
    }

    // Beat 6: Festival breakthrough
    if (!_beatDone('festival_breakthrough') &&
        (weeks >= 12 || pop >= 35) &&
        songs >= 2) {
      _markBeat('festival_breakthrough');
      lastWeekEvents.add(GameEvent(
        id: 'story_festival_$weeks',
        title: 'Sunset Circuit Booking',
        description:
            'A mid-tier festival wants you on the second stage. Miss it and someone else takes the slot forever.',
        type: EventType.opportunity,
        severity: EventSeverity.high,
        choices: const ['Take the Slot', 'Negotiate Pay', 'Pass for Studio Time'],
        choiceOutcomes: const {
          'Take the Slot': {
            'popularity': 10,
            'performance': 6,
            'stamina': -30,
            '_fans': 1200,
            '_money': 2000,
          },
          'Negotiate Pay': {
            'networking': 4,
            'popularity': 5,
            'stamina': -20,
            '_money': 3500,
            '_fans': 600,
          },
          'Pass for Studio Time': {
            'songwriting': 6,
            'production': 5,
            'discipline': 3,
            'happiness': -3,
          },
        },
      ));
    }

    // Beat 7: Viral season
    final hasViralCandidate = playerSongs.any((s) => s.totalStreams >= 50000 || s.viralFactor >= 70);
    if (!_beatDone('viral_season') && hasViralCandidate) {
      _markBeat('viral_season');
      lastWeekEvents.add(GameEvent(
        id: 'story_viral_$weeks',
        title: 'Viral Season',
        description:
            'One of your tracks is catching algorithmic fire. Brands are DMing. This window closes fast.',
        type: EventType.opportunity,
        severity: EventSeverity.high,
        choices: const ['Ride the Wave', 'Brand Deal', 'Protect the Art'],
        choiceOutcomes: const {
          'Ride the Wave': {
            'marketing': 7,
            'popularity': 8,
            'stamina': -15,
            '_fans': 2000,
          },
          'Brand Deal': {
            '_money': 5000,
            'popularity': 4,
            'reputation': -3,
            'fan_connection': -2,
          },
          'Protect the Art': {
            'reputation': 6,
            'creativity': 5,
            'happiness': 4,
            'popularity': 2,
          },
        },
      ));
    }

    // Beat 8: Major label fork
    if (!_beatDone('major_label_fork') &&
        _player!.labelTier == LabelTier.indie &&
        pop >= 55) {
      _markBeat('major_label_fork');
      lastWeekEvents.add(GameEvent(
        id: 'story_major_$weeks',
        title: 'Major Label Fork',
        description:
            'Two majors want you. One promises stadiums. The other promises "artist-friendly" contracts. Choose your future.',
        type: EventType.labelOffer,
        severity: EventSeverity.high,
        choices: const ['Chase the Stadiums', 'Artist-Friendly Deal', 'Stay Indie Power'],
        choiceOutcomes: const {
          'Chase the Stadiums': {
            'influence': 10,
            'marketing': 8,
            'popularity': 6,
            'reputation': -2,
            '_money': 8000,
          },
          'Artist-Friendly Deal': {
            'influence': 6,
            'creativity': 5,
            'reputation': 5,
            'networking': 4,
            '_money': 4000,
          },
          'Stay Indie Power': {
            'discipline': 6,
            'fan_connection': 6,
            'happiness': 5,
            'reputation': 4,
          },
        },
      ));
    }

    _refreshChapterTitle();
  }

  void _initGenreHeat() {
    genreHeat.clear();
    for (final g in availableGenres) {
      genreHeat[g] = 35 + Random().nextDouble() * 30;
    }
    trendingGenre = availableGenres.reduce(
      (a, b) => (genreHeat[a] ?? 0) >= (genreHeat[b] ?? 0) ? a : b,
    );
  }

  void _updateGenreTrends() {
    final rng = Random();
    for (final g in availableGenres) {
      final current = genreHeat[g] ?? 40;
      genreHeat[g] = (current * 0.90 + rng.nextDouble() * 10).clamp(15.0, 100.0);
    }

    if (rng.nextDouble() < 0.40) {
      final surge = availableGenres[rng.nextInt(availableGenres.length)];
      genreHeat[surge] = ((genreHeat[surge] ?? 40) + 18 + rng.nextDouble() * 12)
          .clamp(15.0, 100.0);
      lastWeekEvents.add(GameEvent(
        id: 'genre_surge_${DateTime.now().millisecondsSinceEpoch}',
        title: '$surge Is Trending!',
        description:
            'Playlists and TikTok are flooding with $surge. Songs in that lane get a listening boost.',
        type: EventType.opportunity,
        severity: EventSeverity.medium,
      ));
    }

    trendingGenre = availableGenres.reduce(
      (a, b) => (genreHeat[a] ?? 0) >= (genreHeat[b] ?? 0) ? a : b,
    );
  }

  // ---------------------------
  // Event generation
  // ---------------------------
  void _generateWeeklyEvents() {
    final rng = Random();

    // Global industry flavor (passive)
    if (rng.nextDouble() < 0.2) {
      final eventTitle = rng.nextBool()
          ? 'Industry Music Festival'
          : 'New Music Streaming Platform Launched';
      final eventDescription = rng.nextBool()
          ? 'A major music festival is happening, boosting popularity for all artists!'
          : 'A new streaming platform is live, potentially changing listener habits.';
      lastWeekEvents.add(GameEvent(
        id: 'event_${DateTime.now().millisecondsSinceEpoch}_global',
        title: eventTitle,
        description: eventDescription,
        type: EventType.opportunity,
        severity: EventSeverity.medium,
      ));

      for (var artist in worldArtists) {
        updateArtistAttribute(artist.id, 'popularity', 2.0);
      }
    }

    // Viral boost (passive world news)
    if (worldSongs.isNotEmpty && rng.nextDouble() < 0.15) {
      final songToBoost = worldSongs[rng.nextInt(worldSongs.length)];
      final boostAmount = 10 + rng.nextDouble() * 20;
      songToBoost.viralFactor =
          (songToBoost.viralFactor + boostAmount).clamp(0.0, 100.0);
      lastWeekEvents.add(GameEvent(
        id: 'event_${DateTime.now().millisecondsSinceEpoch}_viral',
        title: '${songToBoost.title} Goes Viral!',
        description:
            '${songToBoost.title} is trending across social media, leading to a massive surge in listeners!',
        type: EventType.opportunity,
        severity: EventSeverity.high,
      ));
    }

    // NPC-only personal events (auto-applied). Player gets interactive versions below.
    for (var artist in worldArtists) {
      if (artist.id == _player?.id) continue;
      if (rng.nextDouble() < 0.08) {
        if (rng.nextBool()) {
          lastWeekEvents.add(GameEvent(
            id: 'event_${DateTime.now().millisecondsSinceEpoch}_npc_scandal_${artist.id}',
            title: '${artist.name} in Social Media Backlash',
            description: '${artist.name} is facing criticism for recent comments.',
            type: EventType.scandal,
            severity: EventSeverity.high,
          ));
          updateArtistAttribute(artist.id, 'reputation', -5.0);
          updateArtistAttribute(artist.id, 'controversy', 10.0);
        } else {
          lastWeekEvents.add(GameEvent(
            id: 'event_${DateTime.now().millisecondsSinceEpoch}_npc_opp_${artist.id}',
            title: '${artist.name} Featured on Discover Weekly',
            description:
                '${artist.name}\'s music is gaining traction on popular playlists.',
            type: EventType.opportunity,
            severity: EventSeverity.medium,
          ));
          updateArtistAttribute(artist.id, 'popularity', 5.0);
          updateArtistAttribute(artist.id, 'fan_connection', 3.0);
        }
      }
    }

    // NPC collab news (passive) — player collab is interactive
    if (worldArtists.length >= 2 && rng.nextDouble() < 0.04) {
      final npcs = worldArtists.where((a) => a.id != _player?.id).toList();
      if (npcs.length >= 2) {
        final artist1 = npcs[rng.nextInt(npcs.length)];
        Artist artist2;
        do {
          artist2 = npcs[rng.nextInt(npcs.length)];
        } while (artist2.id == artist1.id);

        final collabSong = Song(
          id: 'song_${DateTime.now().millisecondsSinceEpoch}_collab',
          title: '${artist1.name} & ${artist2.name} - Unity Track',
          artistId: artist1.id,
          popularityFactor:
              ((artist1.attributes['popularity'] ?? 10) +
                      (artist2.attributes['popularity'] ?? 10)) /
                  2,
          viralFactor: ((artist1.attributes['creativity'] ?? 5) +
                  (artist2.attributes['creativity'] ?? 5)) /
              2,
          salesPotential: ((artist1.attributes['marketing'] ?? 10) +
                  (artist2.attributes['marketing'] ?? 10)) /
              2,
          isNewEntry: true,
        );
        worldSongs.add(collabSong);
        lastWeekEvents.add(GameEvent(
          id: 'event_${DateTime.now().millisecondsSinceEpoch}_npc_collab',
          title: 'New Collaboration: ${artist1.name} & ${artist2.name}!',
          description:
              '${artist1.name} and ${artist2.name} have teamed up for a hot new single!',
          type: EventType.collaboration,
          severity: EventSeverity.medium,
        ));
      }
    }

    _generatePlayerChoiceEvents(rng);
    _generateRivalryPressureEvents(rng);
    notifyListeners();
  }

  void _assignRivals() {
    rivalIds.clear();
    final npcs = worldArtists.where((a) => a.id != _player?.id).toList();
    if (npcs.isEmpty) return;

    final candidates = npcs.where((a) {
      final pop = a.attributes['popularity'] ?? 0;
      return pop >= 12 && pop <= 60;
    }).toList();
    candidates.shuffle(Random());
    final picked = (candidates.isNotEmpty ? candidates : npcs).take(3).toList();
    rivalIds = picked.map((a) => a.id).toList();

    for (final rival in picked) {
      rival.attributes['popularity'] =
          ((rival.attributes['popularity'] ?? 20) + 8).clamp(15.0, 70.0);
      rival.attributes['marketing'] =
          ((rival.attributes['marketing'] ?? 20) + 10).clamp(20.0, 85.0);
      rival.attributes['creativity'] =
          ((rival.attributes['creativity'] ?? 20) + 8).clamp(20.0, 85.0);
    }

    lastWeekEvents.add(GameEvent(
      id: 'rivals_assigned_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Chart Rivals Lock In',
      description:
          '${picked.map((r) => r.name).join(', ')} are watching your lane. Expect competition.',
      type: EventType.rivalry,
      severity: EventSeverity.medium,
    ));
  }

  void _generateRivalryPressureEvents(Random rng) {
    if (_player == null || rivalIds.isEmpty) return;

    // Rival shade / chart war choice (~22%)
    if (rng.nextDouble() < 0.22) {
      final rival = rivals[rng.nextInt(rivals.length)];
      lastWeekEvents.add(GameEvent(
        id: 'rival_shade_${DateTime.now().millisecondsSinceEpoch}',
        title: '${rival.name} Throws Shade',
        description:
            '${rival.name} subtweeted your last drop. The timeline is watching.',
        type: EventType.rivalry,
        severity: EventSeverity.high,
        choices: const ['Clap Back', 'Ignore', 'Outwork Them'],
        choiceOutcomes: const {
          'Clap Back': {
            'controversy': 10,
            'popularity': 4,
            'reputation': -3,
            '_fans': 250,
          },
          'Ignore': {
            'discipline': 4,
            'reputation': 2,
            'happiness': -1,
          },
          'Outwork Them': {
            'songwriting': 3,
            'marketing': 3,
            'stamina': -10,
            'discipline': 2,
          },
        },
      ));
    }
  }

  /// Interactive decisions for the player (resolved in the week-end popup).
  void _generatePlayerChoiceEvents(Random rng) {
    if (_player == null) return;

    // Scandal response (~25%)
    if (rng.nextDouble() < 0.25) {
      lastWeekEvents.add(GameEvent(
        id: 'player_scandal_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Social Media Firestorm',
        description:
            'A clip of you went viral for the wrong reasons. How do you respond?',
        type: EventType.scandal,
        severity: EventSeverity.high,
        choices: const ['Apologize', 'Double Down', 'Stay Silent'],
        choiceOutcomes: const {
          'Apologize': {
            'reputation': 4,
            'controversy': -8,
            'happiness': -3,
            '_fans': -50,
          },
          'Double Down': {
            'controversy': 15,
            'reputation': -6,
            'popularity': 5,
            '_fans': 200,
          },
          'Stay Silent': {
            'reputation': -2,
            'controversy': 4,
            'discipline': 3,
          },
        },
      ));
    }

    // Collab invite from a relevant NPC (~20%)
    final npcs = worldArtists.where((a) => a.id != _player!.id).toList();
    if (npcs.isNotEmpty && rng.nextDouble() < 0.20) {
      final partner = npcs[rng.nextInt(npcs.length)];
      lastWeekEvents.add(GameEvent(
        id: 'player_collab_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Collab Invite: ${partner.name}',
        description:
            '${partner.name} wants to feature you on a single. Accepting costs stamina and \$300, but can explode streams.',
        type: EventType.collaboration,
        severity: EventSeverity.medium,
        choices: const ['Accept', 'Decline'],
        choiceOutcomes: const {
          'Accept': {
            'popularity': 6,
            'networking': 5,
            'fan_connection': 4,
            'stamina': -15,
            '_money': -300,
            '_fans': 400,
          },
          'Decline': {
            'reputation': 1,
            'happiness': -2,
          },
        },
      ));
    }

    // Festival / showcase offer (~18%)
    if (rng.nextDouble() < 0.18) {
      lastWeekEvents.add(GameEvent(
        id: 'player_festival_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Festival Slot Offer',
        description:
            'A regional festival offers you an opening slot. Big exposure, hard on stamina.',
        type: EventType.opportunity,
        severity: EventSeverity.medium,
        choices: const ['Take the Slot', 'Pass'],
        choiceOutcomes: const {
          'Take the Slot': {
            'popularity': 8,
            'performance': 4,
            'stamina': -25,
            '_money': 1200,
            '_fans': 800,
          },
          'Pass': {
            'discipline': 2,
            'happiness': -1,
          },
        },
      ));
    }

    // Label interest tease when unsigned (~15% if eligible)
    if (_player!.labelTier == LabelTier.unsigned &&
        (_player!.attributes['popularity'] ?? 0) >= 15 &&
        rng.nextDouble() < 0.15) {
      lastWeekEvents.add(GameEvent(
        id: 'player_label_scout_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Indie Scout Watching',
        description:
            'An indie A&R is circling your catalog. How do you play it?',
        type: EventType.labelOffer,
        severity: EventSeverity.medium,
        choices: const ['Lean Into Hype', 'Focus on Craft', 'Cash Out Promo'],
        choiceOutcomes: const {
          'Lean Into Hype': {
            'marketing': 6,
            'popularity': 4,
            'controversy': 3,
            '_money': -200,
          },
          'Focus on Craft': {
            'songwriting': 5,
            'production': 4,
            'discipline': 3,
            'stamina': -5,
          },
          'Cash Out Promo': {
            '_money': 800,
            'reputation': -3,
            'fan_connection': -2,
          },
        },
      ));
    }

    // Soft guarantee: if no interactive event yet, often add a small hustle choice
    if (!lastWeekEvents.any((e) => e.needsPlayerDecision) &&
        rng.nextDouble() < 0.5) {
      lastWeekEvents.add(GameEvent(
        id: 'player_street_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Street Team Idea',
        description:
            'Your friends want to flyer the city this weekend. Worth the hustle?',
        type: EventType.opportunity,
        severity: EventSeverity.low,
        choices: const ['Do It', 'Skip'],
        choiceOutcomes: const {
          'Do It': {
            'marketing': 3,
            'networking': 2,
            'stamina': -8,
            '_money': -100,
            '_fans': 150,
          },
          'Skip': {
            'happiness': 2,
          },
        },
      ));
    }
  }

  List<GameEvent> get pendingPlayerDecisions =>
      lastWeekEvents.where((e) => e.needsPlayerDecision).toList();

  /// Apply a player choice for an interactive event.
  bool resolveEventChoice(String eventId, String choice) {
    final index = lastWeekEvents.indexWhere((e) => e.id == eventId);
    if (index < 0) return false;
    final event = lastWeekEvents[index];
    if (!event.isInteractive || event.resolved) return false;
    if (!event.choices.contains(choice)) return false;

    final outcomes = event.choiceOutcomes[choice] ?? {};
    for (final entry in outcomes.entries) {
      final key = entry.key;
      final value = entry.value;
      if (key == '_money') {
        updatePlayerMoney(value);
      } else if (key == '_fans') {
        updatePlayerFanCount(value.round());
      } else {
        updatePlayerAttribute(key, value);
      }
    }

    // Accept collab: spawn a feature track with the named partner
    if (event.type == EventType.collaboration &&
        choice == 'Accept' &&
        _player != null) {
      final partnerName = event.title.replaceFirst('Collab Invite: ', '');
      Artist? partner;
      for (final a in worldArtists) {
        if (a.name == partnerName) {
          partner = a;
          break;
        }
      }
      if (partner != null && partner.id != _player!.id) {
        final quality = (((_player!.attributes['songwriting'] ?? 40) +
                    (partner.attributes['popularity'] ?? 40)) /
                2)
            .clamp(20.0, 95.0);
        worldSongs.add(Song(
          id: 'song_${DateTime.now().millisecondsSinceEpoch}_player_collab',
          title: '${_player!.name} & ${partner.name} - Spotlight',
          artistId: _player!.id,
          popularityFactor: quality,
          viralFactor: (40 + Random().nextDouble() * 30).clamp(10.0, 90.0),
          salesPotential: (35 + Random().nextDouble() * 30).clamp(10.0, 90.0),
          genre: 'Pop',
          isNewEntry: true,
        ));
        updateArtistAttribute(partner.id, 'popularity', 3.0);
        updateArtistAttribute(partner.id, 'networking', 2.0);
      }
    }

    event.selectedChoice = choice;
    event.resolved = true;
    notifyListeners();
    saveGame();
    return true;
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
      if (song.videoWeeksRemaining > 0) {
        song.videoWeeksRemaining--;
      }
    }

    worldSongs.sort(_compareByChartScore);

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
        _challenges?.updateChartRankProgress(currentRank);
        _checkChartAchievements(currentRank);

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

        // Rival stole a higher chart slot from your song this week
        if (playerSong.lastWeekRank != null) {
          for (final rivalId in rivalIds) {
            for (final rivalSong in worldSongs.where((s) => s.artistId == rivalId)) {
              final rivalRank = worldSongs.indexOf(rivalSong) + 1;
              if (rivalSong.lastWeekRank != null &&
                  rivalSong.lastWeekRank! > playerSong.lastWeekRank! &&
                  rivalRank < currentRank &&
                  rivalRank <= 30) {
                lastWeekEvents.add(GameEvent(
                  id: 'rival_overtake_${rivalSong.id}_${playerSong.id}',
                  title: '${getArtistById(rivalId)?.name ?? 'A rival'} Overtakes You',
                  description:
                      '"${rivalSong.title}" jumped ahead of "${playerSong.title}" on the charts (#$rivalRank vs #$currentRank).',
                  type: EventType.rivalry,
                  severity: EventSeverity.medium,
                ));
              }
            }
          }
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
    final viralSongsCandidates = worldSongs
        .where((song) =>
            song.totalStreams >= 100000 && song.weeksSinceRelease < 10)
        .toList();
    if (viralSongsCandidates.isNotEmpty && rng.nextDouble() < 0.12) {
      viralSongsCandidates.sort((a, b) => b.viralFactor.compareTo(a.viralFactor));
      final winningSong = viralSongsCandidates.first;
      final winningArtist = getArtistById(winningSong.artistId);

      if (winningArtist != null) {
        if (winningArtist.id == _player?.id) {
          playerMoney += 10000;
        }
        updateArtistAttribute(winningArtist.id, 'popularity', 10.0);
        winningArtist.awardsWon.add('Best Viral Song - $year');
        if (winningArtist.id == _player?.id) {
          _checkAwardAchievements();
        }

        lastWeekEvents.add(GameEvent(
          id: 'viral_award_${year}_${winningArtist.id}',
          title: '${winningArtist.name} Wins Best Viral Song!',
          description:
              '${winningArtist.name}\'s song "${winningSong.title}" has been awarded Best Viral Song of the year, earning them \$10,000 and a popularity boost!',
          type: EventType.award,
          severity: EventSeverity.high,
        ));

        final otherNominees = viralSongsCandidates
            .where((song) => song.artistId != winningArtist.id)
            .take(3)
            .toList();
        for (var nominatedSong in otherNominees) {
          final nominatedArtist = getArtistById(nominatedSong.artistId);
          if (nominatedArtist != null) {
            lastWeekEvents.add(GameEvent(
              id: 'viral_nominee_${year}_${nominatedArtist.id}',
              title: '${nominatedArtist.name} Nominated for Best Viral Song!',
              description:
                  '${nominatedArtist.name}\'s song "${nominatedSong.title}" has been nominated for Best Viral Song of the year!',
              type: EventType.award,
              severity: EventSeverity.low,
            ));
          }
        }
      }
    }

    notifyListeners();
  }

  void _checkChartAchievements(int currentRank) {
    if (_achievements == null || currentRank <= 0) return;
    // Progress APIs unlock when progress >= target (target is 10 / 1).
    if (currentRank <= 10) {
      _achievements!.updateProgress('top_ten', 10);
    }
    if (currentRank == 1) {
      _achievements!.updateProgress('number_one', 1);
    }
  }

  void _checkAwardAchievements() {
    if (_achievements == null || _player == null) return;
    final count = _player!.awardsWon.length;
    if (count >= 1) {
      _achievements!.updateProgress('first_award', 1);
    }
    if (count >= 5) {
      _achievements!.updateProgress('five_awards', count);
    } else if (count > 0) {
      _achievements!.updateProgress('five_awards', count);
    }
  }

  void _generateNPCSongs() {
    final rng = Random();
    final playerHasHotSong = playerSongs.any((s) => s.weeksSinceRelease <= 4);

    for (var artist in worldArtists) {
      if (artist.id == 'player') continue;

      final rival = isRival(artist.id);
      // Rivals drop much more often, especially when you're charting
      final releaseChance = (rival
              ? (playerHasHotSong ? 0.55 : 0.40)
              : 0.10) *
          worldHeat.clamp(0.8, 1.25);

      if (rng.nextDouble() < releaseChance) {
        final newSongTitle = _npcSongTitles[rng.nextInt(_npcSongTitles.length)];
        var popularityFactor =
            (artist.attributes['popularity'] ?? 10).clamp(10.0, 90.0);
        var viralFactor =
            (artist.attributes['creativity'] ?? 5).clamp(5.0, 70.0);
        var salesPotential =
            (artist.attributes['marketing'] ?? 10).clamp(10.0, 80.0);

        if (rival) {
          popularityFactor = (popularityFactor + 12).clamp(20.0, 95.0);
          viralFactor = (viralFactor + 15).clamp(15.0, 95.0);
          salesPotential = (salesPotential + 10).clamp(20.0, 95.0);
          if (playerHasHotSong) {
            viralFactor = (viralFactor + 10).clamp(20.0, 100.0);
          }
        }

        final newSong = Song(
          id: 'song_${DateTime.now().millisecondsSinceEpoch}_${artist.id}',
          title: rival ? '$newSongTitle (Rival Drop)' : newSongTitle,
          artistId: artist.id,
          popularityFactor: popularityFactor,
          viralFactor: viralFactor,
          salesPotential: salesPotential,
          isNewEntry: true,
          // Rivals chase the player's lane or the current trend
          genre: rival
              ? (rng.nextBool() ? playerDominantGenre : trendingGenre)
              : availableGenres[rng.nextInt(availableGenres.length)],
        );
        worldSongs.add(newSong);

        if (rival && playerHasHotSong) {
          lastWeekEvents.add(GameEvent(
            id: 'rival_drop_${DateTime.now().millisecondsSinceEpoch}_${artist.id}',
            title: '${artist.name} Drops Against You',
            description:
                '${artist.name} timed a new single to clash with your chart run.',
            type: EventType.rivalry,
            severity: EventSeverity.medium,
          ));
        }
      }
    }

    // NPC song retirement
    final songsToRetire = worldSongs.where((song) =>
        song.artistId != 'player' &&
        song.weeksSinceRelease > 12 &&
        song.weeklyListeners < 500 &&
        rng.nextDouble() < 0.05
    ).toList();

    for (var song in songsToRetire) {
      worldSongs.removeWhere((s) => s.id == song.id);
      lastWeekEvents.add(GameEvent(
        id: 'event_${DateTime.now().millisecondsSinceEpoch}_retire_${song.id}',
        title: '${getArtistById(song.artistId)?.name ?? 'An Artist'} Retires ${song.title}',
        description: '${getArtistById(song.artistId)?.name ?? 'An Artist'}\'s song "${song.title}" has run its course and been retired from active rotation.',
        type: EventType.scandal,
        severity: EventSeverity.low,
      ));
    }
  }

  /// Hot-chart blend: weekly listeners lead, lifetime streams still matter, age soft-caps old hits.
  double chartScore(Song song) {
    final weekly = song.weeklyListeners;
    final lifetime = song.totalStreams;
    final age = song.weeksSinceRelease;
    final agePenalty = age <= 2
        ? 1.18
        : age <= 6
            ? 1.0
            : age <= 12
                ? 0.78
                : age <= 20
                    ? 0.55
                    : 0.35;
    return (weekly * 3.2 + lifetime * 0.12) * agePenalty;
  }

  int _compareByChartScore(Song a, Song b) {
    final byScore = chartScore(b).compareTo(chartScore(a));
    if (byScore != 0) return byScore;
    final byWeekly = b.weeklyListeners.compareTo(a.weeklyListeners);
    if (byWeekly != 0) return byWeekly;
    return b.totalStreams.compareTo(a.totalStreams);
  }

  List<Song> getTopSongs(int limit) {
    List<Song> songsToConsider = worldSongs;
    if (currentGenreFilter != null) {
      if (currentGenreFilter == 'New Releases') {
        songsToConsider = worldSongs.where((song) => song.weeksSinceRelease <= 4).toList();
      } else {
        songsToConsider = worldSongs.where((song) => song.genre == currentGenreFilter).toList();
      }
    }

    songsToConsider = List<Song>.from(songsToConsider)..sort(_compareByChartScore);
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
    // Award XP for releasing a song
    addPlayerXp(50);
    if (song.artistId == _player?.id) {
      _challenges?.updateProgress(ChallengeType.releaseSongs, 1);
    }
    notifyListeners();
    saveGame();
  }
  
  void checkSongAchievements(AchievementService achievementService) {
    final playerSongCount = playerSongs.length;
    if (playerSongCount >= 1) {
      achievementService.incrementProgress('first_song');
    }
    if (playerSongCount >= 10) {
      achievementService.updateProgress('ten_songs', playerSongCount);
    }
    if (playerSongCount >= 50) {
      achievementService.updateProgress('fifty_songs', playerSongCount);
    }
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

    // Minigame / craft quality: maps 0..100 → ~0.55..1.45 so skill actually moves charts
    final quality = song.popularityFactor.clamp(0.0, 100.0);
    final qualityMultiplier = 0.55 + (quality / 100.0) * 0.90;

    // Soft length preference: ~3.0–3.8 min peaks; extremes slightly hurt
    final length = song.lengthMinutes.clamp(1.0, 8.0);
    final lengthDistance = (length - 3.4).abs();
    final lengthMultiplier = (1.08 - (lengthDistance * 0.06)).clamp(0.85, 1.08);

    // Rival chart pressure: rivals push harder when the player has a fresh single
    double rivalryMultiplier = 1.0;
    if (isRival(song.artistId)) {
      final playerHot = playerSongs.any((s) => s.weeksSinceRelease <= 5);
      rivalryMultiplier = playerHot ? 1.22 : 1.10;
    } else if (song.artistId == _player?.id) {
      // Slight underdog momentum when a rival is also hot this week
      final rivalHot = worldSongs.any(
        (s) => isRival(s.artistId) && s.weeksSinceRelease <= 3,
      );
      if (rivalHot) rivalryMultiplier = 1.05;
    }

    // Genre meta: hotter genres pull more weekly listeners
    final heat = genreHeatFor(song.genre);
    final genreMultiplier = 0.82 + (heat / 100.0) * 0.45; // ~0.82–1.27
    final onTrendBonus = song.genre == trendingGenre ? 1.08 : 1.0;
    final albumBoost = isSongOnAlbum(song.id) ? 1.14 : 1.0;
    final videoBoost = song.videoWeeksRemaining > 0 ? 1.32 : 1.0;
    final homeLaneBoost =
        song.artistId == _player?.id && song.genre == playerHomeGenre
            ? 1.06
            : 1.0;
    double fatigue = 1.0;
    if (song.artistId == _player?.id) {
      if (weekStartedBurnedOut) {
        fatigue = 0.78;
      } else {
        final stam = _player!.attributes['stamina'] ?? 80;
        if (stam < 20) {
          fatigue = 0.78;
        } else if (stam < 35) {
          fatigue = 0.90;
        }
      }
    }
    // Harder worlds: NPC/rival songs punch up; player unchanged
    final heatScale = song.artistId == _player?.id
        ? 1.0
        : worldHeat;

    double listeners = base *
        recencyBoost *
        (1 + viral) *
        controversyEffect *
        marketingBoost *
        qualityMultiplier *
        lengthMultiplier *
        rivalryMultiplier *
        genreMultiplier *
        onTrendBonus *
        albumBoost *
        videoBoost *
        homeLaneBoost *
        fatigue *
        heatScale;

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
  int playerXp = 0; // Player experience points

  void startNewGame(
    String playerName, {
    ArtistAppearance? appearance,
    String homeGenre = 'Pop',
    double difficulty = 1.0,
  }) {
    playerHomeGenre = availableGenres.contains(homeGenre) ? homeGenre : 'Pop';
    worldHeat = difficulty.clamp(0.8, 1.25);
    lastWeekRoyalties = 0;
    lastWeekRecap = '';
    weekStartedBurnedOut = false;
    _player = Artist(
      id: 'player',
      name: playerName,
      appearance: appearance ?? ArtistAppearance.defaults,
      labelTier: LabelTier.unsigned,
      attributes: {
        'popularity': 10,
        'reputation': 10,
        'happiness': 50,
        'talent': 10,
        'controversy': 0,
        'fan_connection': 10,
        'performance': playerHomeGenre == 'Rock' ? 58 : 50,
        'production': playerHomeGenre == 'Electronic' ? 52 : 40,
        'songwriting': playerHomeGenre == 'Indie' ? 62 : 55,
        'charisma': playerHomeGenre == 'Pop' ? 58 : 50,
        'marketing': 30,
        'networking': playerHomeGenre == 'Hip-Hop' ? 50 : 40,
        'creativity': 60,
        'discipline': playerHomeGenre == 'R&B' ? 58 : 50,
        'stamina': 80,
        'wealth': 10,
        'influence': 5,
        'weeksSinceDebut': 0,
      },
    );
    worldArtists.add(_player!); // Add player to worldArtists
    worldArtists.addAll(NPCArtists.generateNPCs()); // Add NPC artists to worldArtists
    playerMoney = 5000;
    playerFanCount = 100;
    playerXp = 0;
    _initGenreHeat();
    _assignRivals();
    saveGame();
    notifyListeners();
  }

  List<Song> get playerSongs => worldSongs.where((song) => song.artistId == _player?.id).toList();

  void addPlayerXp(int amount, {bool countTowardChallenges = true}) {
    final oldLevel = PlayerLevel.fromTotalXp(playerXp).level;
    playerXp += amount;
    final newLevel = PlayerLevel.fromTotalXp(playerXp).level;

    if (countTowardChallenges && newLevel > oldLevel) {
      _challenges?.updateProgress(ChallengeType.levelUp, newLevel - oldLevel);
    }
    notifyListeners();
  }
  
  PlayerLevel getPlayerLevel() {
    return PlayerLevel.fromTotalXp(playerXp);
  }

  void updatePlayerMoney(
    double amount, {
    AchievementService? achievementService,
    bool countTowardChallenges = true,
  }) {
    playerMoney += amount;

    // Award XP for earning money
    if (amount > 0) {
      addPlayerXp((amount / 100).toInt(), countTowardChallenges: countTowardChallenges);
      if (countTowardChallenges) {
        _challenges?.updateProgress(ChallengeType.earnMoney, amount.round());
      }
    }

    // Check money achievements
    if (achievementService != null) {
      if (playerMoney >= 10000) {
        achievementService.updateProgress('ten_thousand_money', playerMoney.toInt());
      }
      if (playerMoney >= 100000) {
        achievementService.updateProgress('hundred_thousand_money', playerMoney.toInt());
      }
    }

    notifyListeners();
  }

  void updatePlayerFanCount(int amount, {AchievementService? achievementService}) {
    playerFanCount += amount;

    // Award XP for gaining fans
    if (amount > 0) {
      addPlayerXp(amount ~/ 10);
      _challenges?.updateProgress(ChallengeType.gainFans, amount);
    }

    // Check fan achievements
    if (achievementService != null) {
      if (playerFanCount >= 1000) {
        achievementService.updateProgress('thousand_fans', playerFanCount);
      }
      if (playerFanCount >= 10000) {
        achievementService.updateProgress('ten_thousand_fans', playerFanCount);
      }
      if (playerFanCount >= 100000) {
        achievementService.updateProgress('hundred_thousand_fans', playerFanCount);
      }
    }

    notifyListeners();
  }

  // You might want to add a method to update specific player attributes
  void updatePlayerAttribute(String attribute, double change) {
    if (_player == null) return;
    _player!.attributes[attribute] = ((_player!.attributes[attribute] ?? 0) + change).clamp(0.0, 100.0);
    notifyListeners();
  }

  /// Whether the player meets gates to move to [target] from the previous tier.
  bool canUpgradeLabelTier(LabelTier target) {
    if (_player == null) return false;
    final current = _player!.labelTier;
    if (current.next != target) return false;

    final popularity = _player!.attributes['popularity'] ?? 0;
    final songs = playerSongs.length;
    final fans = playerFanCount;
    final awards = _player!.awardsWon.length;

    switch (target) {
      case LabelTier.indie:
        return popularity >= 25 && songs >= 5;
      case LabelTier.major:
        return popularity >= 60 && fans >= 50000 && awards >= 1;
      case LabelTier.superstar:
        return popularity >= 85 && fans >= 500000 && awards >= 3;
      case LabelTier.unsigned:
        return false;
    }
  }

  /// Upgrade player label. Returns false if requirements unmet.
  bool upgradeLabelTier(LabelTier target) {
    if (!canUpgradeLabelTier(target)) return false;
    _player!.labelTier = target;
    // Signing bump: influence + marketing unlock feel
    updatePlayerAttribute('influence', target == LabelTier.indie
        ? 5
        : target == LabelTier.major
            ? 10
            : 15);
    updatePlayerAttribute('marketing', target == LabelTier.indie
        ? 5
        : target == LabelTier.major
            ? 8
            : 12);
    lastWeekEvents.add(GameEvent(
      id: 'label_upgrade_${target.storageName}_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Signed: ${target.displayName}!',
      description:
          'You moved up to ${target.displayName}. Weekly income is now \$${target.weeklyIncome.toStringAsFixed(0)}.',
      type: EventType.labelOffer,
      severity: EventSeverity.high,
    ));
    notifyListeners();
    saveGame();
    return true;
  }

  /// Persist the active career to disk (Hive).
  Future<void> saveGame() async {
    if (_player == null || _saveBox == null) return;
    final payload = <String, dynamic>{
      'year': year,
      'month': month,
      'weekOfMonth': weekOfMonth,
      'playerMoney': playerMoney,
      'playerFanCount': playerFanCount,
      'playerChartPeak': playerChartPeak,
      'playerXp': playerXp,
      'trendingGenre': trendingGenre,
      'genreHeat': genreHeat,
      'rivalIds': rivalIds,
      'currentGenreFilter': currentGenreFilter,
      'chartViewMode': chartViewMode,
      'weeklyChartHistory': weeklyChartHistory,
      'completedStoryBeats': completedStoryBeats.toList(),
      'currentChapter': currentChapter,
      'playerAlbums': playerAlbums.map((a) => a.toMap()).toList(),
      'weeklyHeadlines': weeklyHeadlines,
      'lastWeekRecap': lastWeekRecap,
      'lastWeekRoyalties': lastWeekRoyalties,
      'hustlesThisWeek': hustlesThisWeek,
      'playerHomeGenre': playerHomeGenre,
      'worldHeat': worldHeat,
      'weekStartedBurnedOut': weekStartedBurnedOut,
      'worldArtists': worldArtists.map((a) => a.toMap()).toList(),
      'worldSongs': worldSongs.map((s) => s.toMap()).toList(),
      'playerId': _player!.id,
    };
    await _saveBox!.put(_saveSlotKey, jsonEncode(payload));
    notifyListeners();
  }

  /// Load career from disk. Returns false if no save / corrupt.
  bool loadGame() {
    final raw = _saveBox?.get(_saveSlotKey);
    if (raw == null) return false;

    try {
      final data = jsonDecode(raw as String) as Map<String, dynamic>;
      year = data['year'] as int? ?? 2025;
      month = data['month'] as int? ?? 1;
      weekOfMonth = data['weekOfMonth'] as int? ?? 1;
      playerMoney = (data['playerMoney'] as num?)?.toDouble() ?? 5000;
      playerFanCount = data['playerFanCount'] as int? ?? 100;
      playerChartPeak = data['playerChartPeak'] as int?;
      playerXp = data['playerXp'] as int? ?? 0;
      trendingGenre = data['trendingGenre'] as String? ?? 'Pop';
      currentGenreFilter = data['currentGenreFilter'] as String?;
      chartViewMode = data['chartViewMode'] as String? ?? 'songs';
      rivalIds = List<String>.from(data['rivalIds'] as List? ?? const []);
      completedStoryBeats
        ..clear()
        ..addAll(List<String>.from(data['completedStoryBeats'] as List? ?? const []));
      currentChapter = data['currentChapter'] as String? ?? 'Unsigned Hustle';
      lastWeekRecap = data['lastWeekRecap'] as String? ?? '';
      lastWeekRoyalties =
          (data['lastWeekRoyalties'] as num?)?.toDouble() ?? 0;
      hustlesThisWeek = data['hustlesThisWeek'] as int? ?? 0;
      playerHomeGenre = data['playerHomeGenre'] as String? ?? 'Pop';
      worldHeat = (data['worldHeat'] as num?)?.toDouble() ?? 1.0;
      weekStartedBurnedOut = data['weekStartedBurnedOut'] as bool? ?? false;
      weeklyHeadlines =
          List<String>.from(data['weeklyHeadlines'] as List? ?? const []);
      playerAlbums = (data['playerAlbums'] as List? ?? const [])
          .map((e) => Album.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();

      genreHeat
        ..clear()
        ..addAll(
          (data['genreHeat'] as Map? ?? {}).map(
            (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
          ),
        );

      weeklyChartHistory = List<Map<String, dynamic>>.from(
        (data['weeklyChartHistory'] as List? ?? const []).map(
          (e) => Map<String, dynamic>.from(e as Map),
        ),
      );

      worldArtists = (data['worldArtists'] as List? ?? const [])
          .map((e) => Artist.fromMap(_normalizeArtistMap(e as Map)))
          .toList();
      worldSongs = (data['worldSongs'] as List? ?? const [])
          .map((e) => Song.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();

      final playerId = data['playerId'] as String? ?? 'player';
      _player = getArtistById(playerId);
      if (_player == null && worldArtists.isNotEmpty) {
        _player = worldArtists.firstWhere(
          (a) => a.id == 'player',
          orElse: () => worldArtists.first,
        );
      }
      if (_player == null) return false;

      lastWeekEvents.clear();
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Map<String, dynamic> _normalizeArtistMap(Map raw) {
    final map = Map<String, dynamic>.from(raw);
    if (map['attributes'] is Map) {
      map['attributes'] = (map['attributes'] as Map).map(
        (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
      );
    }
    return map;
  }

  Future<bool> continueOrResume() async {
    if (isGameStarted) return true;
    return loadGame();
  }

  Future<void> deleteSave() async {
    await _saveBox?.delete(_saveSlotKey);
    notifyListeners();
  }

  // Reset game state
  void resetGame() {
    _player = null;
    worldSongs.clear();
    worldArtists.clear();
    rivalIds.clear();
    completedStoryBeats.clear();
    currentChapter = 'Unsigned Hustle';
    genreHeat.clear();
    trendingGenre = 'Pop';
    playerMoney = 0;
    playerFanCount = 0;
    playerChartPeak = null;
    year = 2025;
    month = 1;
    weekOfMonth = 1;
    lastWeekEvents.clear();
    weeklyChartHistory.clear();
    playerAlbums.clear();
    weeklyHeadlines.clear();
    lastWeekRecap = '';
    lastWeekRoyalties = 0;
    hustlesThisWeek = 0;
    playerHomeGenre = 'Pop';
    worldHeat = 1.0;
    weekStartedBurnedOut = false;
    deleteSave();
    notifyListeners();
  }
}
