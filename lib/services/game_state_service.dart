import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/artist.dart';
import '../models/artist_appearance.dart';
import '../models/song.dart';
import '../models/event.dart';
import '../models/label_tier.dart';
import '../models/record_label.dart';
import '../data/npc_artists.dart'; // Corrected import for NPCArtists
import '../data/record_labels.dart';
import '../models/player_level.dart';
import '../models/challenge.dart';
import '../models/album.dart';
import '../models/tour.dart';
import '../models/lifestyle.dart';
import '../models/studio_finish.dart';
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
  ActiveTour? activeTour;
  double lastWeekTourPay = 0;
  LabelDealStyle labelDealStyle = LabelDealStyle.standard;
  /// Named catalog label the player is signed to, or empty if unsigned.
  String playerLabelId = '';
  final List<RosterSigning> rosterSignings = [];
  final Map<String, int> labelPitchCooldowns = {};
  final Map<String, int> signOfferCooldowns = {};
  final Set<String> ownedAssetIds = {};
  final List<OwnedInvestment> investments = [];
  double lastWeekPassive = 0;
  double lastWeekUpkeep = 0;
  int dissCooldownWeeks = 0;
  int lastFestivalYearPlayed = 0;
  int pressCooldownWeeks = 0;
  int pressCoverWeeksRemaining = 0;
  bool fanClubFounded = false;
  int streetTeamWeeksRemaining = 0;
  double lastWeekFanClubUpkeep = 0;
  /// `network` · `scandal` · empty
  String afterpartyBuzz = '';
  int afterpartyBuzzWeeks = 0;
  int reissueCooldownWeeks = 0;
  int radioInterviewCooldownWeeks = 0;
  int radioLiveWeeksRemaining = 0;
  /// `perform` · `plug` · empty
  String radioLiveKind = '';
  String radioLiveSongId = '';
  int demoLeakCooldownWeeks = 0;
  int demoLeakHeatWeeks = 0;
  /// `lean` · `ignore` · empty
  String demoLeakKind = '';
  String leakedDemoTitle = '';
  int producerBeefCooldownWeeks = 0;
  int producerCreditWeeks = 0;
  /// `apologize` · `clapback` · empty
  String producerBeefKind = '';
  String beefProducerName = '';
  String beefSongId = '';
  int mentorCosignCooldownWeeks = 0;
  int mentorCosignWeeks = 0;
  /// `feature` · `advice` · empty
  String mentorCosignKind = '';
  String mentorCosignArtistId = '';
  String mentorCosignSongId = '';
  int meetGreetCooldownWeeks = 0;
  int meetGreetWeeks = 0;
  /// `charge` · `free` · empty
  String meetGreetKind = '';
  int danceChallengeCooldownWeeks = 0;
  int danceChallengeWeeks = 0;
  /// `join` · `mock` · empty
  String danceChallengeKind = '';
  String danceChallengeSongId = '';
  int brandDealCooldownWeeks = 0;
  int brandDealWeeks = 0;
  /// `take` · `negotiate` · empty
  String brandDealKind = '';
  String brandSponsorName = '';
  int chartWagerCooldownWeeks = 0;
  int chartWagerWeeks = 0;
  /// `double` · `protect` · empty
  String chartWagerKind = '';
  String chartWagerSongId = '';
  int chartWagerStartRank = 0;
  int rivalTruceCooldownWeeks = 0;
  int rivalTruceWeeks = 0;
  /// `alliance` · `spy` · empty
  String rivalTruceKind = '';
  String rivalTruceRivalId = '';
  int documentaryCooldownWeeks = 0;
  int documentaryWeeks = 0;
  /// `access` · `privacy` · empty
  String documentaryKind = '';
  String documentaryCrewName = '';
  int therapyPodcastCooldownWeeks = 0;
  int therapyPodcastWeeks = 0;
  /// `open` · `deflect` · empty
  String therapyPodcastKind = '';
  String therapyPodcastName = '';
  int collabDmCooldownWeeks = 0;
  int collabDmWeeks = 0;
  /// `accept` · `teaser` · empty
  String collabDmKind = '';
  String collabDmArtistId = '';
  String collabDmSongId = '';

  int stalkerFanCooldownWeeks = 0;
  int stalkerFanWeeks = 0;
  /// `ro` · `soft` · `engage` · empty
  String stalkerFanKind = '';
  int merchDropCooldownWeeks = 0;
  int merchDropWeeks = 0;
  /// `premium` · `mass` · empty
  String merchDropKind = '';
  int tourBusCooldownWeeks = 0;
  int tourBusWeeks = 0;
  /// `fix` · `diy` · `cancel` · empty
  String tourBusKind = '';
  int awardsCampCooldownWeeks = 0;
  int awardsCampWeeks = 0;
  /// `campaign` · `chill` · empty
  String awardsCampKind = '';
  int genrePivotCooldownWeeks = 0;
  int genrePivotWeeks = 0;
  /// `lean` · `deny` · `double` · empty
  String genrePivotKind = '';
  int arenaSlotCooldownWeeks = 0;
  int arenaSlotWeeks = 0;
  /// `support` · `hold` · empty
  String arenaSlotKind = '';
  int fanTheoryCooldownWeeks = 0;
  int fanTheoryWeeks = 0;
  /// `confirm` · `deny` · `feed` · empty
  String fanTheoryKind = '';
  int blacklistCooldownWeeks = 0;
  int blacklistWeeks = 0;
  /// `address` · `ignore` · `clapback` · empty
  String blacklistKind = '';
  int comebackCooldownWeeks = 0;
  int comebackWeeks = 0;
  /// `intimate` · `maximal` · empty
  String comebackKind = '';
  int charityCooldownWeeks = 0;
  int charityWeeks = 0;
  /// `donate` · `match` · empty
  String charityKind = '';

  int get fanClubMembers => fanClubFounded
      ? (playerFanCount * 0.14).round().clamp(12, 9999999)
      : 0;

  double get fanClubUpkeep =>
      fanClubFounded ? 90 + playerFanCount * 0.025 : 0;

  double _fanConvertBoost(Song song) {
    if (song.artistId != _player?.id) return 1.0;
    var m = 1.0;
    if (fanClubFounded && lastWeekFanClubUpkeep > 0) m *= 1.07;
    if (streetTeamWeeksRemaining > 0) {
      m *= 1.0 + (playerFanCount / 90000).clamp(0.06, 0.18);
    }
    return m;
  }

  bool get hasPendingPress => lastWeekEvents.any(
        (e) => e.id.startsWith('press_week::') && e.needsPlayerDecision,
      );

  bool get hasPendingRadio => lastWeekEvents.any(
        (e) => e.id.startsWith('radio_live::') && e.needsPlayerDecision,
      );

  bool get canSitRadio {
    if (_player == null) return false;
    if (radioInterviewCooldownWeeks > 0 || hasPendingRadio) return false;
    if (playerSongs.isEmpty) return false;
    return (_player!.attributes['popularity'] ?? 0) >= 12;
  }

  String get radioStation {
    const stations = ['Hot 97', 'BBC 1Xtra', 'Power 105', 'Kiss FM', 'Capital'];
    return stations[(year + month * 2 + weekOfMonth) % stations.length];
  }

  String get demoLeakBanner {
    if (demoLeakHeatWeeks <= 0) return '';
    if (demoLeakKind == 'lean') {
      return 'Demo leak hype — +13% streams (${demoLeakHeatWeeks}w)';
    }
    return 'Ignored leak fallout — −12% streams (${demoLeakHeatWeeks}w)';
  }

  bool get hasPendingProducerBeef => lastWeekEvents.any(
        (e) => e.id.startsWith('producer_beef::') && e.needsPlayerDecision,
      );

  bool get hasPendingMentorCosign => lastWeekEvents.any(
        (e) => e.id.startsWith('mentor_cosign::') && e.needsPlayerDecision,
      );

  bool get hasPendingMeetGreet => lastWeekEvents.any(
        (e) => e.id.startsWith('meet_greet::') && e.needsPlayerDecision,
      );

  bool get canHostMeetGreet {
    if (_player == null) return false;
    if (meetGreetCooldownWeeks > 0 || hasPendingMeetGreet) return false;
    return fanClubFounded || playerFanCount >= 400;
  }

  String get meetGreetBanner {
    if (meetGreetWeeks <= 0) return '';
    if (meetGreetKind == 'free') {
      return 'Superfan love — +9% streams (${meetGreetWeeks}w)';
    }
    return 'Ticketed meet — +5% streams (${meetGreetWeeks}w)';
  }

  bool get hasPendingDanceChallenge => lastWeekEvents.any(
        (e) => e.id.startsWith('dance_challenge::') && e.needsPlayerDecision,
      );

  bool get canJoinDanceTrend {
    if (_player == null || playerSongs.isEmpty) return false;
    if (danceChallengeCooldownWeeks > 0 || hasPendingDanceChallenge) {
      return false;
    }
    return (_player!.attributes['popularity'] ?? 0) >= 15 ||
        playerSongs.any((s) => s.viralFactor >= 35);
  }

  String get danceChallengeBanner {
    if (danceChallengeWeeks <= 0) return '';
    Song? song;
    for (final s in worldSongs) {
      if (s.id == danceChallengeSongId) {
        song = s;
        break;
      }
    }
    final title = song?.title ?? 'your track';
    if (danceChallengeKind == 'join') {
      return 'Dance trend on "$title" — +14% (${danceChallengeWeeks}w)';
    }
    return 'Mock trend on "$title" — +10% (${danceChallengeWeeks}w)';
  }

  bool get hasPendingBrandDeal => lastWeekEvents.any(
        (e) => e.id.startsWith('brand_deal::') && e.needsPlayerDecision,
      );

  bool get canReviewBrandDeal {
    if (_player == null) return false;
    if (brandDealCooldownWeeks > 0 || hasPendingBrandDeal) return false;
    return (_player!.attributes['popularity'] ?? 0) >= 25;
  }

  String get brandDealBanner {
    if (brandDealWeeks <= 0) return '';
    if (brandDealKind == 'negotiate') {
      return '$brandSponsorName deal — +8% streams (${brandDealWeeks}w)';
    }
    return '$brandSponsorName deal — +6% streams (${brandDealWeeks}w)';
  }

  int? get bestPlayerChartRank {
    if (playerSongs.isEmpty) return null;
    var best = 999;
    for (final s in playerSongs) {
      final r = worldSongs.indexOf(s) + 1;
      if (r < best) best = r;
    }
    return best == 999 ? null : best;
  }

  bool get hasPendingChartWager => lastWeekEvents.any(
        (e) => e.id.startsWith('chart_wager::') && e.needsPlayerDecision,
      );

  bool get canChartWager {
    if (_player == null || playerSongs.isEmpty) return false;
    if (chartWagerCooldownWeeks > 0 || hasPendingChartWager) return false;
    final rank = bestPlayerChartRank;
    return rank != null && rank <= 25;
  }

  String get chartWagerBanner {
    if (chartWagerWeeks <= 0) return '';
    Song? song;
    for (final s in worldSongs) {
      if (s.id == chartWagerSongId) {
        song = s;
        break;
      }
    }
    final title = song?.title ?? 'chart run';
    if (chartWagerKind == 'double') {
      return 'Doubled down on "$title" — +12% (${chartWagerWeeks}w)';
    }
    return 'Protected "$title" — +7% (${chartWagerWeeks}w)';
  }

  bool get hasPendingRivalTruce => lastWeekEvents.any(
        (e) => e.id.startsWith('rival_truce::') && e.needsPlayerDecision,
      );

  bool get canOfferRivalTruce {
    if (_player == null || rivalIds.isEmpty) return false;
    if (rivalTruceCooldownWeeks > 0 || hasPendingRivalTruce) return false;
    return true;
  }

  String get rivalTruceBanner {
    if (rivalTruceWeeks <= 0) return '';
    final rival = getArtistById(rivalTruceRivalId);
    if (rivalTruceKind == 'alliance') {
      return 'Truce with ${rival?.name ?? 'rival'} — +6% streams (${rivalTruceWeeks}w)';
    }
    return 'Spying on ${rival?.name ?? 'rival'} — +9% streams (${rivalTruceWeeks}w)';
  }

  bool get hasPendingDocumentary => lastWeekEvents.any(
        (e) => e.id.startsWith('doc_crew::') && e.needsPlayerDecision,
      );

  bool get canOfferDocumentary {
    if (_player == null) return false;
    if (documentaryCooldownWeeks > 0 || hasPendingDocumentary) return false;
    return (_player!.attributes['popularity'] ?? 0) >= 20;
  }

  String get documentaryBanner {
    if (documentaryWeeks <= 0) return '';
    final crew = documentaryCrewName.isNotEmpty
        ? documentaryCrewName
        : 'Documentary crew';
    if (documentaryKind == 'access') {
      return '$crew filming — +11% streams (${documentaryWeeks}w)';
    }
    return '$crew limited access — +7% streams (${documentaryWeeks}w)';
  }

  bool get hasPendingTherapyPodcast => lastWeekEvents.any(
        (e) => e.id.startsWith('therapy_pod::') && e.needsPlayerDecision,
      );

  bool get canOfferTherapyPodcast {
    if (_player == null) return false;
    if (therapyPodcastCooldownWeeks > 0 || hasPendingTherapyPodcast) {
      return false;
    }
    final pop = _player!.attributes['popularity'] ?? 0;
    final controversy = _player!.attributes['controversy'] ?? 0;
    return pop >= 18 || controversy >= 8;
  }

  String get therapyPodcastBanner {
    if (therapyPodcastWeeks <= 0) return '';
    final show = therapyPodcastName.isNotEmpty
        ? therapyPodcastName
        : 'Therapy podcast';
    if (therapyPodcastKind == 'open') {
      return '$show episode — +8% streams (${therapyPodcastWeeks}w)';
    }
    return '$show clip — +5% streams (${therapyPodcastWeeks}w)';
  }

  bool get hasPendingCollabDm => lastWeekEvents.any(
        (e) => e.id.startsWith('collab_dm::') && e.needsPlayerDecision,
      );

  bool get canOfferCollabDm {
    if (_player == null) return false;
    if (collabDmCooldownWeeks > 0 || hasPendingCollabDm) return false;
    if (playerSongs.isEmpty) return false;
    return (_player!.attributes['popularity'] ?? 0) >= 22;
  }

  String get collabDmBanner {
    if (collabDmWeeks <= 0) return '';
    final artist = getArtistById(collabDmArtistId);
    Song? song;
    for (final s in worldSongs) {
      if (s.id == collabDmSongId) {
        song = s;
        break;
      }
    }
    final title = song?.title ?? 'track';
    if (collabDmKind == 'accept') {
      return '${artist?.name ?? 'Artist'} collab — "$title" +14% (${collabDmWeeks}w)';
    }
    return 'Leaked ${artist?.name ?? 'artist'} teaser — "$title" +10% (${collabDmWeeks}w)';
  }

  bool get hasPendingStalkerFan => lastWeekEvents.any(
        (e) => e.id.startsWith('stalker_fan::') && e.needsPlayerDecision,
      );

  bool get canOfferStalkerFan {
    if (_player == null) return false;
    if (stalkerFanCooldownWeeks > 0 || hasPendingStalkerFan) return false;
    final pop = _player!.attributes['popularity'] ?? 0;
    return pop >= 25 || playerFanCount >= 800;
  }

  String get stalkerFanBanner {
    if (stalkerFanWeeks <= 0) return '';
    if (stalkerFanKind == 'ro') {
      return 'Restraining order heat — +6% catalog (${stalkerFanWeeks}w)';
    }
    if (stalkerFanKind == 'soft') {
      return 'Soft block boundary — +5% catalog (${stalkerFanWeeks}w)';
    }
    return 'Engaged stalker drama — +9% catalog (${stalkerFanWeeks}w)';
  }

  bool get hasPendingMerchDrop => lastWeekEvents.any(
        (e) => e.id.startsWith('merch_drop::') && e.needsPlayerDecision,
      );

  bool get canOfferMerchDrop {
    if (_player == null) return false;
    if (merchDropCooldownWeeks > 0 || hasPendingMerchDrop) return false;
    return (_player!.attributes['popularity'] ?? 0) >= 20;
  }

  String get merchDropBanner {
    if (merchDropWeeks <= 0) return '';
    if (merchDropKind == 'premium') {
      return 'Premium merch drop — +8% streams (${merchDropWeeks}w)';
    }
    return 'Mass-market merch — +6% streams (${merchDropWeeks}w)';
  }

  bool get hasPendingTourBus => lastWeekEvents.any(
        (e) => e.id.startsWith('tour_bus::') && e.needsPlayerDecision,
      );

  bool get canOfferTourBus {
    if (_player == null) return false;
    if (tourBusCooldownWeeks > 0 || hasPendingTourBus) return false;
    return (_player!.attributes['popularity'] ?? 0) >= 15;
  }

  String get tourBusBanner {
    if (tourBusWeeks <= 0) return '';
    if (tourBusKind == 'fix') {
      return 'Tour bus fixed — +7% streams (${tourBusWeeks}w)';
    }
    return 'DIY bus repair buzz — +5% streams (${tourBusWeeks}w)';
  }

  bool get hasPendingAwardsCamp => lastWeekEvents.any(
        (e) => e.id.startsWith('awards_camp::') && e.needsPlayerDecision,
      );

  bool get canOfferAwardsCamp {
    if (_player == null) return false;
    if (awardsCampCooldownWeeks > 0 || hasPendingAwardsCamp) return false;
    return (_player!.attributes['popularity'] ?? 0) >= 30;
  }

  String get awardsCampBanner {
    if (awardsCampWeeks <= 0) return '';
    if (awardsCampKind == 'campaign') {
      return 'Awards campaign night — +12% streams (${awardsCampWeeks}w)';
    }
    return 'Chill awards night — +7% streams (${awardsCampWeeks}w)';
  }

  bool get hasPendingGenrePivot => lastWeekEvents.any(
        (e) => e.id.startsWith('genre_pivot::') && e.needsPlayerDecision,
      );

  bool get canOfferGenrePivot {
    if (_player == null) return false;
    if (genrePivotCooldownWeeks > 0 || hasPendingGenrePivot) return false;
    return (_player!.attributes['popularity'] ?? 0) >= 18;
  }

  String get genrePivotBanner {
    if (genrePivotWeeks <= 0) return '';
    if (genrePivotKind == 'lean') {
      return 'Genre pivot rumor lean — +8% streams (${genrePivotWeeks}w)';
    }
    if (genrePivotKind == 'deny') {
      return 'Rumor denied — +5% streams (${genrePivotWeeks}w)';
    }
    return 'Double-down pivot — +11% streams (${genrePivotWeeks}w)';
  }

  bool get hasPendingArenaSlot => lastWeekEvents.any(
        (e) => e.id.startsWith('arena_slot::') && e.needsPlayerDecision,
      );

  bool get canOfferArenaSlot {
    if (_player == null) return false;
    if (arenaSlotCooldownWeeks > 0 || hasPendingArenaSlot) return false;
    return (_player!.attributes['popularity'] ?? 0) >= 28;
  }

  String get arenaSlotBanner {
    if (arenaSlotWeeks <= 0) return '';
    if (arenaSlotKind == 'support') {
      return 'Arena support slot — +9% streams (${arenaSlotWeeks}w)';
    }
    return 'Holding for headliner — +6% streams (${arenaSlotWeeks}w)';
  }

  bool get hasPendingFanTheory => lastWeekEvents.any(
        (e) => e.id.startsWith('fan_theory::') && e.needsPlayerDecision,
      );

  bool get canOfferFanTheory {
    if (_player == null) return false;
    if (fanTheoryCooldownWeeks > 0 || hasPendingFanTheory) return false;
    final pop = _player!.attributes['popularity'] ?? 0;
    return pop >= 16 || playerFanCount >= 500;
  }

  String get fanTheoryBanner {
    if (fanTheoryWeeks <= 0) return '';
    if (fanTheoryKind == 'confirm') {
      return 'Fan theory confirmed — +7% streams (${fanTheoryWeeks}w)';
    }
    if (fanTheoryKind == 'deny') {
      return 'Theory denied — +4% streams (${fanTheoryWeeks}w)';
    }
    return 'Feeding the theory — +10% streams (${fanTheoryWeeks}w)';
  }

  bool get hasPendingBlacklist => lastWeekEvents.any(
        (e) =>
            e.id.startsWith('blacklist_rumor::') && e.needsPlayerDecision,
      );

  bool get canOfferBlacklist {
    if (_player == null) return false;
    if (blacklistCooldownWeeks > 0 || hasPendingBlacklist) return false;
    final pop = _player!.attributes['popularity'] ?? 0;
    final controversy = _player!.attributes['controversy'] ?? 0;
    return controversy >= 10 || pop >= 25;
  }

  String get blacklistBanner {
    if (blacklistWeeks <= 0) return '';
    if (blacklistKind == 'address') {
      return 'Blacklist addressed — +6% streams (${blacklistWeeks}w)';
    }
    return 'Clap-back heat — +9% streams (${blacklistWeeks}w)';
  }

  bool get hasPendingComeback => lastWeekEvents.any(
        (e) =>
            e.id.startsWith('comeback_concept::') && e.needsPlayerDecision,
      );

  bool get canOfferComeback {
    if (_player == null) return false;
    if (comebackCooldownWeeks > 0 || hasPendingComeback) return false;
    final pop = _player!.attributes['popularity'] ?? 0;
    final weeks = (_player!.attributes['weeksSinceDebut'] ?? 0);
    return pop >= 35 || weeks >= 40;
  }

  String get comebackBanner {
    if (comebackWeeks <= 0) return '';
    if (comebackKind == 'intimate') {
      return 'Intimate comeback concept — +8% streams (${comebackWeeks}w)';
    }
    return 'Maximalist comeback — +12% streams (${comebackWeeks}w)';
  }

  bool get hasPendingCharity => lastWeekEvents.any(
        (e) =>
            e.id.startsWith('charity_single::') && e.needsPlayerDecision,
      );

  bool get canOfferCharity {
    if (_player == null) return false;
    if (charityCooldownWeeks > 0 || hasPendingCharity) return false;
    return (_player!.attributes['popularity'] ?? 0) >= 22;
  }

  String get charityBanner {
    if (charityWeeks <= 0) return '';
    if (charityKind == 'donate') {
      return 'Charity single proceeds — +7% streams (${charityWeeks}w)';
    }
    return 'Matched charity push — +9% streams (${charityWeeks}w)';
  }

  String get mentorCosignBanner {
    if (mentorCosignWeeks <= 0) return '';
    final mentor = getArtistById(mentorCosignArtistId);
    if (mentorCosignKind == 'feature') {
      Song? song;
      for (final s in worldSongs) {
        if (s.id == mentorCosignSongId) {
          song = s;
          break;
        }
      }
      return '${mentor?.name ?? 'Mentor'} cosign — "${song?.title ?? 'feature'}" +12% (${mentorCosignWeeks}w)';
    }
    return '${mentor?.name ?? 'Mentor'} advice — +6% catalog (${mentorCosignWeeks}w)';
  }

  String get producerBeefBanner {
    if (producerCreditWeeks <= 0) return '';
    if (producerBeefKind == 'apologize') {
      return 'Producer peace — +7% catalog (${producerCreditWeeks}w)';
    }
    Song? song;
    for (final s in worldSongs) {
      if (s.id == beefSongId) {
        song = s;
        break;
      }
    }
    return 'Credit war on "${song?.title ?? 'the track'}" — +15% (${producerCreditWeeks}w)';
  }

  bool get hasPendingDemoLeak => lastWeekEvents.any(
        (e) => e.id.startsWith('demo_leak::') && e.needsPlayerDecision,
      );

  String get radioLiveBanner {
    if (radioLiveWeeksRemaining <= 0) return '';
    if (radioLiveKind == 'plug') {
      Song? song;
      for (final s in worldSongs) {
        if (s.id == radioLiveSongId) {
          song = s;
          break;
        }
      }
      return '${radioStation} plug — "${song?.title ?? 'the single'}" +16% (${radioLiveWeeksRemaining}w)';
    }
    return '${radioStation} live session — +8% catalog (${radioLiveWeeksRemaining}w)';
  }

  bool get canSitPress {
    if (_player == null) return false;
    if (pressCooldownWeeks > 0 || hasPendingPress) return false;
    return (_player!.attributes['popularity'] ?? 0) >= 15;
  }

  String get pressMagazine {
    const mags = ['Billboard', 'Rolling Stone', 'The Fader', 'Complex', 'NME'];
    return mags[(year + month + weekOfMonth) % mags.length];
  }

  double get afterpartyStreamBoost {
    if (afterpartyBuzzWeeks <= 0) return 1.0;
    if (afterpartyBuzz == 'scandal') return 1.14;
    if (afterpartyBuzz == 'network') return 1.09;
    return 1.0;
  }

  String get afterpartyBanner {
    if (afterpartyBuzzWeeks <= 0) return '';
    if (afterpartyBuzz == 'scandal') {
      return 'Afterparty scandal heat — +14% streams (${afterpartyBuzzWeeks}w)';
    }
    return 'Afterparty networking heat — +9% streams (${afterpartyBuzzWeeks}w)';
  }

  bool get isFestivalSeason => month >= 6 && month <= 8;

  bool get canPlayFestival =>
      isFestivalSeason && lastFestivalYearPlayed != year;

  double get effectiveRoyaltyKeep {
    if (_player == null || _player!.labelTier == LabelTier.unsigned) {
      return 1.0;
    }
    return (_player!.labelTier.royaltyKeep + labelDealStyle.keepAdjust)
        .clamp(0.40, 0.95);
  }

  double get effectiveWeeklyStipend {
    if (_player == null) return 0;
    if (_player!.labelTier == LabelTier.unsigned) {
      return _player!.labelTier.weeklyIncome;
    }
    return _player!.labelTier.weeklyIncome * labelDealStyle.stipendMultiplier;
  }

  double get weeklyAssetUpkeep {
    var sum = 0.0;
    for (final id in ownedAssetIds) {
      sum += LuxuryAsset.byId(id)?.weeklyUpkeep ?? 0;
    }
    return sum;
  }

  double projectedInvestmentYield({double? royalties}) {
    final roy = royalties ?? lastWeekRoyalties;
    var sum = 0.0;
    for (final owned in investments) {
      final v = InvestmentVehicle.byId(owned.vehicleId);
      if (v == null) continue;
      sum += v.weeklyYield(
        principal: owned.principal,
        fans: playerFanCount,
        royalties: roy,
      );
    }
    return sum;
  }

  double get lifestyleNetWorth {
    var assets = 0.0;
    for (final id in ownedAssetIds) {
      assets += (LuxuryAsset.byId(id)?.price ?? 0) * 0.7;
    }
    var principal = 0.0;
    for (final owned in investments) {
      principal += owned.principal;
    }
    return playerMoney + assets + principal;
  }

  bool ownsAsset(String id) => ownedAssetIds.contains(id);

  OwnedInvestment? investmentFor(String vehicleId) {
    for (final owned in investments) {
      if (owned.vehicleId == vehicleId) return owned;
    }
    return null;
  }

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
    if (dissCooldownWeeks > 0) dissCooldownWeeks--;
    if (pressCooldownWeeks > 0) pressCooldownWeeks--;
    if (reissueCooldownWeeks > 0) reissueCooldownWeeks--;
    if (radioInterviewCooldownWeeks > 0) radioInterviewCooldownWeeks--;
    if (demoLeakCooldownWeeks > 0) demoLeakCooldownWeeks--;
    if (producerBeefCooldownWeeks > 0) producerBeefCooldownWeeks--;
    if (mentorCosignCooldownWeeks > 0) mentorCosignCooldownWeeks--;
    if (meetGreetCooldownWeeks > 0) meetGreetCooldownWeeks--;
    if (danceChallengeCooldownWeeks > 0) danceChallengeCooldownWeeks--;
    if (brandDealCooldownWeeks > 0) brandDealCooldownWeeks--;
    if (chartWagerCooldownWeeks > 0) chartWagerCooldownWeeks--;
    if (rivalTruceCooldownWeeks > 0) rivalTruceCooldownWeeks--;
    if (documentaryCooldownWeeks > 0) documentaryCooldownWeeks--;
    if (therapyPodcastCooldownWeeks > 0) therapyPodcastCooldownWeeks--;
    if (collabDmCooldownWeeks > 0) collabDmCooldownWeeks--;

    if (stalkerFanCooldownWeeks > 0) stalkerFanCooldownWeeks--;
    if (merchDropCooldownWeeks > 0) merchDropCooldownWeeks--;
    if (tourBusCooldownWeeks > 0) tourBusCooldownWeeks--;
    if (awardsCampCooldownWeeks > 0) awardsCampCooldownWeeks--;
    if (genrePivotCooldownWeeks > 0) genrePivotCooldownWeeks--;
    if (arenaSlotCooldownWeeks > 0) arenaSlotCooldownWeeks--;
    if (fanTheoryCooldownWeeks > 0) fanTheoryCooldownWeeks--;
    if (blacklistCooldownWeeks > 0) blacklistCooldownWeeks--;
    if (comebackCooldownWeeks > 0) comebackCooldownWeeks--;
    if (charityCooldownWeeks > 0) charityCooldownWeeks--;
    _tickCooldownMap(labelPitchCooldowns);
    _tickCooldownMap(signOfferCooldowns);

    // New week: drop last week's cards, then build this week's.
    lastWeekEvents.clear();
    weeklyHeadlines.clear();
    weekStartedBurnedOut = false;
    lastWeekTourPay = 0;

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
      updatePlayerMoney(effectiveWeeklyStipend);
      // Merch / street sales scale with fans + wealth
      final wealth = _player!.attributes['wealth'] ?? 10;
      final merch = (playerFanCount * 0.04) + (wealth * 8);
      updatePlayerMoney(merch);
      _player!.attributes['wealth'] =
          (wealth + (playerFanCount / 50000)).clamp(0.0, 100.0);

      lastWeekFanClubUpkeep = 0;
      if (fanClubFounded) {
        final due = fanClubUpkeep;
        if (playerMoney >= due) {
          updatePlayerMoney(-due);
          lastWeekFanClubUpkeep = due;
        } else {
          weeklyHeadlines.add(
            'Fan club bills bounced. Street kids still show, streams dip this week.',
          );
          lastWeekEvents.add(GameEvent(
            id: 'fanclub_bounce_${DateTime.now().millisecondsSinceEpoch}',
            title: 'Fan Club Unpaid',
            description:
                'You couldn\'t cover club upkeep (\$${due.toStringAsFixed(0)}). Convert boost is off until you pay next week.',
            type: EventType.scandal,
            severity: EventSeverity.low,
          ));
        }
      }

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

      _advanceTourWeek();
    }

    _updateGenreTrends();
    _generateWeeklyEvents(); // Generate events for the current week
    _checkStoryBeats();
    _generateNPCSongs(); // Generate new songs from NPCs
    _simulateRosterWeek();
    if (yearRolled) {
      _runYearEndAwards();
      _queueAwardAfterparty();
    }

    _queuePendingListeningParties();
    _checkUnclearedSamples();
    // Recalculate charts after events
    recalculateCharts();
    _payStreamRoyalties();
    _settleLifestyle();
    _buildWeeklyRecap();
    saveGame();
  }

  /// Streaming payouts: weekly listeners convert to money; label takes a cut.
  void _payStreamRoyalties() {
    lastWeekRoyalties = 0;
    if (_player == null) return;
    const perStream = 0.0038;
    final streams = playerSongs.fold<double>(
      0,
      (sum, song) => song.released ? sum + song.weeklyListeners : sum,
    );
    lastWeekRoyalties = streams * perStream * effectiveRoyaltyKeep;

    var rosterCut = 0.0;
    for (final signing in activeRoster) {
      final cut = signing.playerCut;
      for (final song in worldSongs) {
        if (!song.released || song.artistId != signing.artistId) continue;
        rosterCut += song.weeklyListeners * perStream * cut;
      }
    }
    lastWeekRoyalties += rosterCut;

    if (lastWeekRoyalties > 0) {
      updatePlayerMoney(lastWeekRoyalties);
      weeklyHeadlines.add(
        rosterCut > 0
            ? 'Streaming paid \$${lastWeekRoyalties.toStringAsFixed(0)} this week (imprint \$${rosterCut.toStringAsFixed(0)}).'
            : 'Streaming paid \$${lastWeekRoyalties.toStringAsFixed(0)} this week.',
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
    final playlistHits =
        playerSongs.where((s) => s.playlistWeeksRemaining > 0).length;
    if (playlistHits > 0) {
      parts.add(
        '$playlistHits playlist${playlistHits == 1 ? '' : 's'} running',
      );
    }
    if (lastWeekTourPay > 0) {
      parts.add('Tour \$${lastWeekTourPay.toStringAsFixed(0)}');
    } else if (isOnTour) {
      parts.add('On tour: ${activeTour!.name} · ${activeTour!.weeksRemaining}w');
    }
    if (lastWeekPassive > 0) {
      parts.add('Investments \$${lastWeekPassive.toStringAsFixed(0)}');
    }
    if (lastWeekUpkeep > 0) {
      parts.add('Lifestyle bills \$${lastWeekUpkeep.toStringAsFixed(0)}');
    }
    if (_player!.labelTier != LabelTier.unsigned) {
      parts.add(
        '${labelDealStyle.displayName} deal · keep ${(effectiveRoyaltyKeep * 100).toStringAsFixed(0)}%',
      );
    }
    if (isFestivalSeason) {
      parts.add(
        canPlayFestival
            ? 'Festival circuit open'
            : 'Festival slot already played',
      );
    }
    if (pressCoverWeeksRemaining > 0) {
      parts.add('Magazine cover boosting ${pressCoverWeeksRemaining}w');
    }
    final uncleared = playerSongs
        .where((s) => s.usesSample && !s.sampleCleared && !s.sampleTakedown)
        .length;
    if (uncleared > 0) {
      parts.add('$uncleared uncleared sample${uncleared == 1 ? '' : 's'}');
    }
    if (playerSongs.any((s) => s.sampleTakedown)) {
      parts.add('A track was taken down');
    }
    if (fanClubFounded) {
      parts.add('Fan club ${fanClubMembers} · upkeep \$${lastWeekFanClubUpkeep.toStringAsFixed(0)}');
    }
    if (streetTeamWeeksRemaining > 0) {
      parts.add('Street team ${streetTeamWeeksRemaining}w');
    }
    if (playerSongs.any(inDebutWindow)) {
      parts.add('Debut window — pitch radio now');
    }
    if (afterpartyBuzzWeeks > 0) {
      parts.add(afterpartyBanner);
    }
    if (reissueCooldownWeeks > 0) {
      parts.add('Reissue cooldown ${reissueCooldownWeeks}w');
    }
    if (playerSongs.any((s) => s.deluxeIssued && inDebutWindow(s))) {
      parts.add('Deluxe is in its impact week');
    }
    if (playerSongs.any((s) => s.sourceSongId.isNotEmpty && inDebutWindow(s))) {
      parts.add('Remix debut — pitch it');
    }
    final partyHits =
        playerSongs.where((s) => s.listeningPartyWeeks > 0).length;
    if (partyHits > 0) {
      parts.add('$partyHits listening part${partyHits == 1 ? 'y' : 'ies'} boosting');
    }
    if (playerSongs.any((s) => s.listeningParty == 'pending')) {
      parts.add('Listening party still pending');
    }
    if (radioLiveWeeksRemaining > 0) {
      parts.add(radioLiveBanner);
    }
    if (demoLeakHeatWeeks > 0) {
      parts.add(demoLeakBanner);
    }
    if (producerCreditWeeks > 0) {
      parts.add(producerBeefBanner);
    }
    if (mentorCosignWeeks > 0) {
      parts.add(mentorCosignBanner);
    }
    if (meetGreetWeeks > 0) {
      parts.add(meetGreetBanner);
    }
    if (danceChallengeWeeks > 0) {
      parts.add(danceChallengeBanner);
    }
    if (brandDealWeeks > 0) {
      parts.add(brandDealBanner);
    }
    if (chartWagerWeeks > 0) {
      parts.add(chartWagerBanner);
    }
    if (rivalTruceWeeks > 0) {
      parts.add(rivalTruceBanner);
    }
    if (documentaryWeeks > 0) {
      parts.add(documentaryBanner);
    }
    if (therapyPodcastWeeks > 0) {
      parts.add(therapyPodcastBanner);
    }
    if (collabDmWeeks > 0) {
      parts.add(collabDmBanner);
    }

    if (stalkerFanWeeks > 0) {
      parts.add(stalkerFanBanner);
    }
    if (merchDropWeeks > 0) {
      parts.add(merchDropBanner);
    }
    if (tourBusWeeks > 0) {
      parts.add(tourBusBanner);
    }
    if (awardsCampWeeks > 0) {
      parts.add(awardsCampBanner);
    }
    if (genrePivotWeeks > 0) {
      parts.add(genrePivotBanner);
    }
    if (arenaSlotWeeks > 0) {
      parts.add(arenaSlotBanner);
    }
    if (fanTheoryWeeks > 0) {
      parts.add(fanTheoryBanner);
    }
    if (blacklistWeeks > 0) {
      parts.add(blacklistBanner);
    }
    if (comebackWeeks > 0) {
      parts.add(comebackBanner);
    }
    if (charityWeeks > 0) {
      parts.add(charityBanner);
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

  String? foundFanClub() {
    if (_player == null) return 'No player';
    if (fanClubFounded) return 'Fan club already exists';
    const cost = 1800.0;
    if (playerMoney < cost) return 'Need \$1800 to launch a fan club';
    if ((_player!.attributes['popularity'] ?? 0) < 12) {
      return 'Need 12 popularity to start a club';
    }
    updatePlayerMoney(-cost);
    fanClubFounded = true;
    lastWeekFanClubUpkeep = 1;
    updatePlayerAttribute('fan_connection', 6);
    updatePlayerFanCount(80);
    weeklyHeadlines.add(
      '${_player!.name} launched a fan club. Members convert listens every week.',
    );
    lastWeekEvents.add(GameEvent(
      id: 'fanclub_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Fan Club Live',
      description:
          'Street team + newsletter are yours. Weekly upkeep; members turn into streams.',
      type: EventType.opportunity,
      severity: EventSeverity.medium,
    ));
    addPlayerXp(20);
    notifyListeners();
    saveGame();
    return null;
  }

  String? runStreetTeam() {
    if (_player == null) return 'No player';
    if (hustlesThisWeek >= 2) return 'Already hustled enough this week';
    final stamina = _player!.attributes['stamina'] ?? 0;
    if (stamina < 10) return 'Too tired to run the streets';
    final cost = (100 + playerFanCount * 0.03).clamp(100.0, 700.0);
    if (playerMoney < cost) {
      return 'Need \$${cost.toStringAsFixed(0)} for flyers and merch tables';
    }
    hustlesThisWeek++;
    updatePlayerAttribute('stamina', -10);
    updatePlayerMoney(-cost);
    updatePlayerAttribute('fan_connection', 3);
    updatePlayerAttribute('marketing', 2);
    final newFans = (playerFanCount * 0.012).round().clamp(25, 450);
    updatePlayerFanCount(newFans);
    streetTeamWeeksRemaining = 2;
    weeklyHeadlines.add(
      '${_player!.name}\'s street team hit the block. Fans convert to streams for 2 weeks.',
    );
    addPlayerXp(16);
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
    if (song.playlistWeeksRemaining > 0) {
      return 'Already on a playlist (${song.playlistWeeksRemaining}w left)';
    }
    final cost = 350.0 + (_player!.labelTier.index * 150);
    if (playerMoney < cost) {
      return 'Need \$${cost.toStringAsFixed(0)} to pitch radio';
    }
    updatePlayerMoney(-cost);
    updatePlayerAttribute('marketing', 2);

    final debutStack = inDebutWindow(song);
    final marketing = _player!.attributes['marketing'] ?? 30;
    final chance = (0.52 +
            (marketing / 200) +
            (_player!.labelTier.index * 0.08) +
            (debutStack ? 0.10 : 0))
        .clamp(0.45, 0.95);
    if (Random().nextDouble() > chance) {
      weeklyHeadlines.add('Radio passed on "${song.title}".');
      lastWeekEvents.add(GameEvent(
        id: 'radio_pass_${song.id}_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Radio Pass',
        description:
            'Programmers passed on "${song.title}". Marketing helps the next pitch.',
        type: EventType.opportunity,
        severity: EventSeverity.low,
      ));
      notifyListeners();
      saveGame();
      return 'Radio passed this time. Try again later.';
    }

    var weeks = playlistPlacementWeeks();
    if (debutStack) weeks += 1;
    song.playlistWeeksRemaining = weeks;
    song.viralFactor = (song.viralFactor +
            12 +
            Random().nextDouble() * 10 +
            (debutStack ? 8 : 0))
        .clamp(0.0, 100.0);
    song.salesPotential =
        (song.salesPotential + 8 + (debutStack ? 4 : 0)).clamp(0.0, 100.0);
    weeklyHeadlines.add(
      debutStack
          ? 'Impact add: "${song.title}" stacked with debut heat — $weeks weeks.'
          : 'Playlist add: "${song.title}" locked for $weeks weeks.',
    );
    lastWeekEvents.add(GameEvent(
      id: 'radio_pitch_${song.id}_${DateTime.now().millisecondsSinceEpoch}',
      title: debutStack ? 'Debut + Playlist Stack' : 'Playlist Placement',
      description: debutStack
          ? '"${song.title}" hit playlists in its debut window. Extra week, extra viral, stacked recency.'
          : '"${song.title}" is on a mid-day playlist for $weeks weeks. Streams get a bump while it lasts.',
      type: EventType.opportunity,
      severity: debutStack ? EventSeverity.high : EventSeverity.medium,
    ));
    addPlayerXp(20);
    notifyListeners();
    saveGame();
    return null;
  }

  int playlistPlacementWeeks() {
    final tier = _player?.labelTier.index ?? 0;
    return tier >= 2 ? 3 : 2;
  }

  /// First chart week + the week after release (post-recalc age is 0 or 1).
  bool inDebutWindow(Song song) => song.weeksSinceRelease <= 1;

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

  bool isRemixTrack(Song song) => song.sourceSongId.isNotEmpty;

  bool canDeluxeReissue(Song song) {
    if (_player == null || song.artistId != _player!.id) return false;
    if (song.deluxeIssued || isRemixTrack(song) || song.sampleTakedown) {
      return false;
    }
    return song.weeksSinceRelease >= 5;
  }

  bool canDropRemix(Song song) {
    if (_player == null || song.artistId != _player!.id) return false;
    if (song.hasRemix || isRemixTrack(song) || song.sampleTakedown) {
      return false;
    }
    return song.weeksSinceRelease >= 5;
  }

  double deluxeReissueCost() {
    final tier = _player?.labelTier.index ?? 0;
    return 720.0 + (tier * 220);
  }

  double remixDropCost() {
    final tier = _player?.labelTier.index ?? 0;
    return 1100.0 + (tier * 280);
  }

  String? reissueDeluxe(String songId) {
    if (_player == null) return 'No player';
    if (reissueCooldownWeeks > 0) {
      return 'Studio is still wrapping the last reissue ($reissueCooldownWeeks w)';
    }
    Song? song;
    for (final s in worldSongs) {
      if (s.id == songId) {
        song = s;
        break;
      }
    }
    if (song == null || !canDeluxeReissue(song)) {
      return 'Need a catalog original (5+ weeks) that has not been deluxe\'d';
    }
    final cost = deluxeReissueCost();
    if (playerMoney < cost) {
      return 'Need \$${cost.toStringAsFixed(0)} for a deluxe reissue';
    }
    final stamina = _player!.attributes['stamina'] ?? 0;
    if (stamina < 12) return 'Too tired to cut a deluxe';

    updatePlayerMoney(-cost);
    updatePlayerAttribute('stamina', -12);
    updatePlayerAttribute('songwriting', 2);
    song.deluxeIssued = true;
    song.weeksSinceRelease = 0;
    song.isNewEntry = true;
    song.listeningParty = 'pending';
    song.listeningPartyWeeks = 0;
    song.popularityFactor = (song.popularityFactor + 6).clamp(0.0, 100.0);
    song.viralFactor =
        (song.viralFactor + 10 + Random().nextDouble() * 6).clamp(0.0, 100.0);
    song.salesPotential = (song.salesPotential + 5).clamp(0.0, 100.0);
    reissueCooldownWeeks = 2;
    weeklyHeadlines.add(
      'Deluxe reissue: "${song.title}" is back in the debut window.',
    );
    lastWeekEvents.add(GameEvent(
      id: 'deluxe_${song.id}_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Deluxe Reissue',
      description:
          '"${song.title}" got new mixes and a fresh chart week. Pitch radio while it is hot.',
      type: EventType.opportunity,
      severity: EventSeverity.medium,
    ));
    addPlayerXp(20);
    notifyListeners();
    saveGame();
    return null;
  }

  String? dropRemix(String songId) {
    if (_player == null) return 'No player';
    if (reissueCooldownWeeks > 0) {
      return 'Studio is still wrapping the last reissue ($reissueCooldownWeeks w)';
    }
    Song? song;
    for (final s in worldSongs) {
      if (s.id == songId) {
        song = s;
        break;
      }
    }
    if (song == null || !canDropRemix(song)) {
      return 'Need a catalog original (5+ weeks) with no remix yet';
    }
    final cost = remixDropCost();
    if (playerMoney < cost) {
      return 'Need \$${cost.toStringAsFixed(0)} to cut a remix';
    }
    final stamina = _player!.attributes['stamina'] ?? 0;
    if (stamina < 16) return 'Too tired to cut a remix';

    updatePlayerMoney(-cost);
    updatePlayerAttribute('stamina', -16);
    updatePlayerAttribute('songwriting', 3);
    updatePlayerAttribute('marketing', 2);
    song.hasRemix = true;
    final remix = Song(
      id: 'remix_${song.id}_${DateTime.now().millisecondsSinceEpoch}',
      title: '${song.title} (Remix)',
      artistId: _player!.id,
      popularityFactor: (song.popularityFactor + 4).clamp(20.0, 96.0),
      viralFactor: (song.viralFactor * 0.55 + 28 + Random().nextDouble() * 12)
          .clamp(15.0, 95.0),
      salesPotential: (song.salesPotential * 0.7 + 18).clamp(15.0, 90.0),
      genre: song.genre,
      lengthMinutes: (song.lengthMinutes + 0.35).clamp(2.4, 6.5),
      studioFinish: 'polish',
      sourceSongId: song.id,
      usesSample: song.usesSample,
      sampleCleared: song.sampleCleared,
      isNewEntry: true,
      listeningParty: 'pending',
    );
    worldSongs.add(remix);
    reissueCooldownWeeks = 2;
    weeklyHeadlines.add(
      'Remix drop: "${remix.title}" hits as a new chart entry.',
    );
    lastWeekEvents.add(GameEvent(
      id: 'remix_${remix.id}',
      title: 'Remix Drop',
      description:
          '"${remix.title}" is a new debut. The original stays on the board.',
      type: EventType.opportunity,
      severity: EventSeverity.high,
    ));
    addPlayerXp(28);
    notifyListeners();
    saveGame();
    return null;
  }

  double _listeningPartyBoost(Song song) {
    if (song.listeningPartyWeeks <= 0) return 1.0;
    if (song.listeningParty == 'fans') return 1.14;
    if (song.listeningParty == 'press') return 1.10;
    return 1.0;
  }

  double _radioLiveBoost(Song song) {
    if (radioLiveWeeksRemaining <= 0 || song.artistId != _player?.id) {
      return 1.0;
    }
    if (radioLiveKind == 'perform') return 1.08;
    if (radioLiveKind == 'plug' && song.id == radioLiveSongId) return 1.16;
    return 1.0;
  }

  double _demoLeakBoost(Song song) {
    if (demoLeakHeatWeeks <= 0 || song.artistId != _player?.id) return 1.0;
    if (demoLeakKind == 'lean') return 1.13;
    if (demoLeakKind == 'ignore') return 0.88;
    return 1.0;
  }

  String _randomDemoTitle() {
    const names = [
      'Midnight Draft',
      'Voicemail Hook',
      'Untitled Session',
      'Garage Take 2',
      'Phone Memo',
    ];
    return '${names[Random().nextInt(names.length)]} (${playerDominantGenre})';
  }

  String? resolveDemoLeak(String choice, {bool fromEvent = false}) {
    if (_player == null) return 'No player';
    if (!fromEvent && hasPendingDemoLeak) {
      return 'Finish the leak event first';
    }

    final title = leakedDemoTitle.isNotEmpty
        ? leakedDemoTitle
        : _randomDemoTitle();
    switch (choice) {
      case 'Pay to Kill':
        final cost = 950.0 + (_player!.labelTier.index * 200);
        if (!fromEvent && playerMoney < cost) {
          return 'Need \$${cost.toStringAsFixed(0)} to kill the leak';
        }
        if (playerMoney >= cost) updatePlayerMoney(-cost);
        updatePlayerAttribute('reputation', 4);
        updatePlayerAttribute('controversy', -6);
        updatePlayerAttribute('happiness', -2);
        demoLeakHeatWeeks = 0;
        demoLeakKind = '';
        weeklyHeadlines.add(
          '${_player!.name} paid to scrub "$title" off the blogs.',
        );
        break;
      case 'Lean In':
        updatePlayerAttribute('controversy', 9);
        updatePlayerAttribute('popularity', 7);
        updatePlayerAttribute('marketing', 3);
        updatePlayerFanCount(420 + Random().nextInt(200));
        demoLeakKind = 'lean';
        demoLeakHeatWeeks = 2;
        if (playerSongs.isNotEmpty) {
          final hot = playerSongs.reduce(
            (a, b) => a.weeklyListeners >= b.weeklyListeners ? a : b,
          );
          hot.viralFactor = (hot.viralFactor + 12).clamp(0.0, 100.0);
        }
        weeklyHeadlines.add(
          '${_player!.name} leaned into "$title" — the leak is a campaign now.',
        );
        break;
      default:
        updatePlayerAttribute('controversy', 11);
        updatePlayerAttribute('reputation', -7);
        updatePlayerAttribute('happiness', -5);
        updatePlayerFanCount(-160);
        demoLeakKind = 'ignore';
        demoLeakHeatWeeks = 1;
        weeklyHeadlines.add(
          '"$title" keeps spreading. ${_player!.name} said nothing.',
        );
        break;
    }

    demoLeakCooldownWeeks = 5;
    leakedDemoTitle = '';
    if (!fromEvent) {
      lastWeekEvents.add(GameEvent(
        id: 'demo_leak_done_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Demo Leak: $choice',
        description: choice == 'Pay to Kill'
            ? 'Lawyers got it down. The vault stays closed.'
            : choice == 'Lean In'
                ? 'The leak is fuel. Streams spike for two weeks.'
                : 'Silence made it worse. Catalog dips this week.',
        type: EventType.scandal,
        severity: EventSeverity.high,
      ));
    }
    addPlayerXp(18);
    notifyListeners();
    saveGame();
    return null;
  }

  String _randomProducerName() {
    const names = [
      'DJ Phantom',
      'Beat Architect',
      '808 King',
      'Room Tone',
      'The Crate Digger',
    ];
    return names[Random().nextInt(names.length)];
  }

  double _producerBeefBoost(Song song) {
    if (producerCreditWeeks <= 0 || song.artistId != _player?.id) return 1.0;
    if (producerBeefKind == 'apologize') return 1.07;
    if (producerBeefKind == 'clapback' && song.id == beefSongId) return 1.15;
    return 1.0;
  }

  String? resolveProducerBeef(String choice, {bool fromEvent = false}) {
    if (_player == null) return 'No player';
    if (!fromEvent && hasPendingProducerBeef) {
      return 'Finish the producer beef first';
    }

    final producer = beefProducerName.isNotEmpty
        ? beefProducerName
        : _randomProducerName();
    Song? song;
    for (final s in worldSongs) {
      if (s.id == beefSongId) {
        song = s;
        break;
      }
    }

    switch (choice) {
      case 'Apologize':
        updatePlayerAttribute('reputation', 5);
        updatePlayerAttribute('controversy', -4);
        updatePlayerAttribute('production', 4);
        updatePlayerAttribute('fan_connection', 2);
        updatePlayerAttribute('happiness', -3);
        producerBeefKind = 'apologize';
        producerCreditWeeks = 2;
        weeklyHeadlines.add(
          '${_player!.name} apologized to $producer. The session is back on.',
        );
        break;
      case 'Clap Back':
        updatePlayerAttribute('controversy', 12);
        updatePlayerAttribute('popularity', 5);
        updatePlayerAttribute('reputation', -5);
        updatePlayerAttribute('discipline', 2);
        updatePlayerFanCount(320 + Random().nextInt(180));
        producerBeefKind = 'clapback';
        producerCreditWeeks = 2;
        if (song != null) {
          song.viralFactor = (song.viralFactor + 10).clamp(0.0, 100.0);
        }
        weeklyHeadlines.add(
          '${_player!.name} clapped back at $producer on the timeline.',
        );
        break;
      default:
        final cost = 1050.0 + (_player!.labelTier.index * 180);
        if (!fromEvent && playerMoney < cost) {
          return 'Need \$${cost.toStringAsFixed(0)} to buy silence';
        }
        if (playerMoney >= cost) updatePlayerMoney(-cost);
        updatePlayerAttribute('controversy', -8);
        updatePlayerAttribute('reputation', 2);
        updatePlayerAttribute('happiness', -2);
        producerBeefKind = '';
        producerCreditWeeks = 0;
        beefSongId = '';
        weeklyHeadlines.add(
          '${_player!.name} paid $producer to go quiet.',
        );
        break;
    }

    producerBeefCooldownWeeks = 4;
    beefProducerName = '';
    if (!fromEvent) {
      lastWeekEvents.add(GameEvent(
        id: 'producer_beef_done_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Producer Beef: $choice',
        description: choice == 'Apologize'
            ? 'Credits settled. Production runs smoother.'
            : choice == 'Clap Back'
                ? 'The beef is content. That track spikes.'
                : 'NDA signed. The thread dies down.',
        type: EventType.scandal,
        severity: EventSeverity.high,
      ));
    }
    addPlayerXp(16);
    notifyListeners();
    saveGame();
    return null;
  }

  double _meetGreetBoost(Song song) {
    if (meetGreetWeeks <= 0 || song.artistId != _player?.id) return 1.0;
    if (meetGreetKind == 'free') return 1.09;
    if (meetGreetKind == 'charge') return 1.05;
    return 1.0;
  }

  String? resolveMeetGreet(String choice, {bool fromEvent = false}) {
    if (_player == null) return 'No player';
    if (!fromEvent) {
      if (meetGreetCooldownWeeks > 0) {
        return 'Fans need a breather ($meetGreetCooldownWeeks w)';
      }
      if (hasPendingMeetGreet) return 'Finish the meet event first';
      if (!fanClubFounded && playerFanCount < 400) {
        return 'Need a fan club or 400 fans';
      }
    }

    switch (choice) {
      case 'Charge Tickets':
        final pay = (playerFanCount * 0.85 + 450).clamp(450.0, 3800.0);
        updatePlayerMoney(pay);
        updatePlayerAttribute('stamina', -10);
        updatePlayerAttribute('controversy', 4);
        updatePlayerAttribute('reputation', -2);
        updatePlayerAttribute('marketing', 2);
        meetGreetKind = 'charge';
        meetGreetWeeks = 2;
        weeklyHeadlines.add(
          '${_player!.name} charged \$${pay.toStringAsFixed(0)} at a superfan meet.',
        );
        break;
      case 'Free Meetup':
        final stamina = _player!.attributes['stamina'] ?? 0;
        if (!fromEvent && stamina < 12) return 'Too tired for a free meetup';
        updatePlayerAttribute('stamina', -14);
        updatePlayerAttribute('fan_connection', 6);
        updatePlayerAttribute('happiness', 5);
        updatePlayerFanCount(320 + Random().nextInt(220));
        meetGreetKind = 'free';
        meetGreetWeeks = 2;
        weeklyHeadlines.add(
          '${_player!.name} did a free superfan meet — the room cried.',
        );
        break;
      default:
        updatePlayerAttribute('fan_connection', -4);
        updatePlayerAttribute('happiness', -3);
        updatePlayerAttribute('discipline', 2);
        meetGreetKind = '';
        meetGreetWeeks = 0;
        weeklyHeadlines.add(
          '${_player!.name} skipped the meet & greet. Fans noticed.',
        );
        break;
    }

    meetGreetCooldownWeeks = 4;
    if (!fromEvent) {
      lastWeekEvents.add(GameEvent(
        id: 'meet_greet_done_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Meet & Greet: $choice',
        description: choice == 'Charge Tickets'
            ? 'Cash in hand. Some fans feel priced out.'
            : choice == 'Free Meetup'
                ? 'Loyalty spike. Streams feel it for two weeks.'
                : 'You stayed off the floor.',
        type: EventType.opportunity,
        severity: EventSeverity.medium,
      ));
    }
    addPlayerXp(choice == 'Skip' ? 8 : 18);
    notifyListeners();
    saveGame();
    return null;
  }

  Song? _pickDanceTrendSong() {
    if (playerSongs.isEmpty) return null;
    final debut = playerSongs.where(inDebutWindow).toList();
    if (debut.isNotEmpty) {
      return debut.reduce(
        (a, b) => a.viralFactor >= b.viralFactor ? a : b,
      );
    }
    return playerSongs.reduce(
      (a, b) => a.viralFactor >= b.viralFactor ? a : b,
    );
  }

  double _danceChallengeBoost(Song song) {
    if (danceChallengeWeeks <= 0 ||
        song.id != danceChallengeSongId ||
        song.artistId != _player?.id) {
      return 1.0;
    }
    if (danceChallengeKind == 'join') return 1.14;
    if (danceChallengeKind == 'mock') return 1.10;
    return 1.0;
  }

  String? resolveDanceChallenge(String choice, {bool fromEvent = false}) {
    if (_player == null) return 'No player';
    if (!fromEvent) {
      if (danceChallengeCooldownWeeks > 0) {
        return 'That trend already ran ($danceChallengeCooldownWeeks w)';
      }
      if (hasPendingDanceChallenge) return 'Finish the challenge event first';
      if (playerSongs.isEmpty) return 'Release a song first';
    }

    final song = _pickDanceTrendSong();
    if (song == null) return 'No song to attach the trend to';

    switch (choice) {
      case 'Join the Trend':
        final stamina = _player!.attributes['stamina'] ?? 0;
        if (!fromEvent && stamina < 10) return 'Too tired to film the dance';
        updatePlayerAttribute('stamina', -12);
        updatePlayerAttribute('marketing', 4);
        updatePlayerAttribute('charisma', 3);
        updatePlayerAttribute('performance', 2);
        song.viralFactor = (song.viralFactor + 15).clamp(0.0, 100.0);
        danceChallengeKind = 'join';
        danceChallengeWeeks = 2;
        danceChallengeSongId = song.id;
        updatePlayerFanCount(280 + Random().nextInt(200));
        weeklyHeadlines.add(
          '${_player!.name} joined the dance trend for "${song.title}".',
        );
        break;
      case 'Mock It':
        updatePlayerAttribute('controversy', 8);
        updatePlayerAttribute('popularity', 6);
        updatePlayerAttribute('reputation', -4);
        updatePlayerAttribute('charisma', 2);
        song.viralFactor = (song.viralFactor + 12).clamp(0.0, 100.0);
        danceChallengeKind = 'mock';
        danceChallengeWeeks = 1;
        danceChallengeSongId = song.id;
        updatePlayerFanCount(180 + Random().nextInt(140));
        weeklyHeadlines.add(
          '${_player!.name} mocked the dance trend — clips still spread.',
        );
        break;
      default:
        updatePlayerAttribute('discipline', 2);
        updatePlayerAttribute('fan_connection', -2);
        danceChallengeKind = '';
        danceChallengeWeeks = 0;
        danceChallengeSongId = '';
        weeklyHeadlines.add(
          '${_player!.name} ignored the dance challenge.',
        );
        break;
    }

    danceChallengeCooldownWeeks = 3;
    if (!fromEvent) {
      lastWeekEvents.add(GameEvent(
        id: 'dance_done_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Dance Challenge: $choice',
        description: choice == 'Join the Trend'
            ? 'Your take is everywhere. "${song.title}" rides the algo.'
            : choice == 'Mock It'
                ? 'Petty, viral, messy. The track still bumps.'
                : 'You stayed off TikTok this week.',
        type: EventType.opportunity,
        severity: EventSeverity.medium,
      ));
    }
    addPlayerXp(choice == 'Ignore' ? 6 : 20);
    notifyListeners();
    saveGame();
    return null;
  }

  String _randomBrandName() {
    const brands = [
      'Neon Energy',
      'Pulse Wear',
      'StreamBox',
      'Hype Cola',
      'Glow Cosmetics',
    ];
    return brands[Random().nextInt(brands.length)];
  }

  double _brandDealBoost(Song song) {
    if (brandDealWeeks <= 0 || song.artistId != _player?.id) return 1.0;
    if (brandDealKind == 'negotiate') return 1.08;
    if (brandDealKind == 'take') return 1.06;
    return 1.0;
  }

  String? resolveBrandSponsorship(String choice, {bool fromEvent = false}) {
    if (_player == null) return 'No player';
    if (!fromEvent) {
      if (brandDealCooldownWeeks > 0) {
        return 'Brands are cooling off ($brandDealCooldownWeeks w)';
      }
      if (hasPendingBrandDeal) return 'Finish the sponsorship event first';
      if ((_player!.attributes['popularity'] ?? 0) < 25) {
        return 'Need 25 popularity for brand deals';
      }
    }

    final brand = brandSponsorName.isNotEmpty
        ? brandSponsorName
        : _randomBrandName();
    final basePay = 3200.0 + (_player!.labelTier.index * 900) +
        (playerFanCount * 0.04);

    switch (choice) {
      case 'Take the Deal':
        updatePlayerMoney(basePay);
        updatePlayerAttribute('marketing', 3);
        updatePlayerAttribute('reputation', -4);
        updatePlayerAttribute('fan_connection', -2);
        brandDealKind = 'take';
        brandDealWeeks = 3;
        brandSponsorName = brand;
        weeklyHeadlines.add(
          '${_player!.name} signed a \$${basePay.toStringAsFixed(0)} $brand deal.',
        );
        break;
      case 'Negotiate':
        final net = _player!.attributes['networking'] ?? 30;
        final win = Random().nextDouble() < (0.45 + net / 250);
        final pay = win ? basePay * 1.35 : basePay * 0.75;
        updatePlayerMoney(pay);
        updatePlayerAttribute('networking', 5);
        updatePlayerAttribute('marketing', 4);
        updatePlayerAttribute('reputation', win ? -2 : -5);
        brandDealKind = 'negotiate';
        brandDealWeeks = 2;
        brandSponsorName = brand;
        weeklyHeadlines.add(
          win
              ? '${_player!.name} negotiated $brand up to \$${pay.toStringAsFixed(0)}.'
              : '$brand lowballed ${_player!.name} — still took \$${pay.toStringAsFixed(0)}.',
        );
        break;
      default:
        updatePlayerAttribute('reputation', 4);
        updatePlayerAttribute('fan_connection', 3);
        updatePlayerAttribute('happiness', 2);
        updatePlayerAttribute('discipline', 2);
        brandDealKind = '';
        brandDealWeeks = 0;
        brandSponsorName = '';
        weeklyHeadlines.add(
          '${_player!.name} declined $brand. Fans respect the independence.',
        );
        break;
    }

    brandDealCooldownWeeks = 5;
    if (!fromEvent && choice != 'Decline') {
      brandSponsorName = brand;
    }
    if (!fromEvent) {
      lastWeekEvents.add(GameEvent(
        id: 'brand_done_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Brand Deal: $choice',
        description: choice == 'Take the Deal'
            ? 'Logo on everything. Checks clear, authenticity dips.'
            : choice == 'Negotiate'
                ? 'You pushed the room. Deal terms reflect it.'
                : 'You walked. The brand moved on.',
        type: EventType.opportunity,
        severity: EventSeverity.high,
      ));
    }
    addPlayerXp(choice == 'Decline' ? 10 : 24);
    notifyListeners();
    saveGame();
    return null;
  }

  Song? _pickChartWagerSong() {
    if (playerSongs.isEmpty) return null;
    Song? best;
    var bestRank = 999;
    for (final s in playerSongs) {
      final r = worldSongs.indexOf(s) + 1;
      if (r < bestRank) {
        bestRank = r;
        best = s;
      }
    }
    return best;
  }

  double _chartWagerBoost(Song song) {
    if (chartWagerWeeks <= 0 ||
        song.id != chartWagerSongId ||
        song.artistId != _player?.id) {
      return 1.0;
    }
    if (chartWagerKind == 'double') return 1.12;
    if (chartWagerKind == 'protect') return 1.07;
    return 1.0;
  }

  String? resolveChartWager(String choice, {bool fromEvent = false}) {
    if (_player == null) return 'No player';
    if (!fromEvent) {
      if (chartWagerCooldownWeeks > 0) {
        return 'Chart wager cooling off ($chartWagerCooldownWeeks w)';
      }
      if (hasPendingChartWager) return 'Finish the wager event first';
      final rank = bestPlayerChartRank;
      if (rank == null || rank > 25) {
        return 'Need a Top 25 song to wager on';
      }
    }

    final song = _pickChartWagerSong();
    if (song == null) return 'No chart song to back';
    final rank = worldSongs.indexOf(song) + 1;

    switch (choice) {
      case 'Double Down':
        const stake = 900.0;
        if (!fromEvent && playerMoney < stake) {
          return 'Need \$900 to double down';
        }
        if (playerMoney >= stake) updatePlayerMoney(-stake);
        updatePlayerAttribute('stamina', -10);
        updatePlayerAttribute('marketing', 6);
        updatePlayerAttribute('discipline', 2);
        chartWagerKind = 'double';
        chartWagerWeeks = 2;
        chartWagerSongId = song.id;
        chartWagerStartRank = rank;
        song.viralFactor = (song.viralFactor + 8).clamp(0.0, 100.0);
        weeklyHeadlines.add(
          '${_player!.name} doubled down on "${song.title}" at #$rank.',
        );
        break;
      case 'Protect the Streak':
        const cost = 350.0;
        if (!fromEvent && playerMoney < cost) {
          return 'Need \$350 to protect the streak';
        }
        if (playerMoney >= cost) updatePlayerMoney(-cost);
        updatePlayerAttribute('reputation', 3);
        updatePlayerAttribute('discipline', 4);
        updatePlayerAttribute('fan_connection', 2);
        chartWagerKind = 'protect';
        chartWagerWeeks = 2;
        chartWagerSongId = song.id;
        chartWagerStartRank = rank;
        weeklyHeadlines.add(
          '${_player!.name} protected the "${song.title}" streak at #$rank.',
        );
        break;
      default:
        updatePlayerAttribute('happiness', 2);
        chartWagerKind = '';
        chartWagerWeeks = 0;
        chartWagerSongId = '';
        chartWagerStartRank = 0;
        weeklyHeadlines.add(
          '${_player!.name} sat out the chart wager.',
        );
        break;
    }

    chartWagerCooldownWeeks = 4;
    if (!fromEvent) {
      lastWeekEvents.add(GameEvent(
        id: 'chart_wager_done_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Chart Wager: $choice',
        description: choice == 'Double Down'
            ? 'All-in promo on "${song.title}". Big swing.'
            : choice == 'Protect the Streak'
                ? 'Safe spend to hold the lane.'
                : 'You let the streak ride without a bet.',
        type: EventType.opportunity,
        severity: EventSeverity.high,
      ));
    }
    addPlayerXp(choice == 'Sit Out' ? 8 : 22);
    notifyListeners();
    saveGame();
    return null;
  }

  double _rivalTruceBoost(Song song) {
    if (rivalTruceWeeks <= 0 || song.artistId != _player?.id) return 1.0;
    if (rivalTruceKind == 'alliance') return 1.06;
    if (rivalTruceKind == 'spy') return 1.09;
    return 1.0;
  }

  bool _rivalTruceBlocks(String rivalId) =>
      rivalTruceKind == 'alliance' &&
      rivalTruceWeeks > 0 &&
      rivalTruceRivalId == rivalId;

  String? resolveRivalTruce(String choice,
      {bool fromEvent = false, String? rivalId}) {
    if (_player == null) return 'No player';
    if (!fromEvent) {
      if (rivalTruceCooldownWeeks > 0) {
        return 'Truce talks cooling off ($rivalTruceCooldownWeeks w)';
      }
      if (hasPendingRivalTruce) return 'Finish the truce event first';
      if (rivalIds.isEmpty) return 'No rivals to deal with';
    }

    final pick = rivalId ??
        (rivalTruceRivalId.isNotEmpty
            ? rivalTruceRivalId
            : rivalIds[Random().nextInt(rivalIds.length)]);
    final rival = getArtistById(pick);
    if (rival == null) return 'Rival not found';

    switch (choice) {
      case 'Form Alliance':
        updatePlayerAttribute('networking', 6);
        updatePlayerAttribute('reputation', 4);
        updatePlayerAttribute('fan_connection', 3);
        updateArtistAttribute(pick, 'networking', 4);
        updateArtistAttribute(pick, 'popularity', 2);
        rivalTruceKind = 'alliance';
        rivalTruceWeeks = 3;
        rivalTruceRivalId = pick;
        weeklyHeadlines.add(
          '${_player!.name} and ${rival.name} called a truce.',
        );
        break;
      case 'Spy on Them':
        updatePlayerMoney(650);
        updatePlayerAttribute('marketing', 5);
        updatePlayerAttribute('controversy', 5);
        updatePlayerAttribute('discipline', 2);
        rivalTruceKind = 'spy';
        rivalTruceWeeks = 2;
        rivalTruceRivalId = pick;
        weeklyHeadlines.add(
          '${_player!.name} is watching ${rival.name}\'s rollout.',
        );
        break;
      default:
        updatePlayerAttribute('discipline', 3);
        updatePlayerAttribute('controversy', 2);
        updatePlayerAttribute('happiness', 2);
        updateArtistAttribute(pick, 'popularity', 3);
        rivalTruceKind = '';
        rivalTruceWeeks = 0;
        rivalTruceRivalId = '';
        weeklyHeadlines.add(
          '${_player!.name} refused ${rival.name}\'s truce.',
        );
        break;
    }

    rivalTruceCooldownWeeks = 5;
    if (!fromEvent) {
      lastWeekEvents.add(GameEvent(
        id: 'rival_truce_done_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Rival Truce: $choice',
        description: choice == 'Form Alliance'
            ? 'Chart war pauses with ${rival.name}.'
            : choice == 'Spy on Them'
                ? 'Intel on ${rival.name} — messy but useful.'
                : '${rival.name} will remember the snub.',
        type: EventType.rivalry,
        severity: EventSeverity.high,
      ));
    }
    addPlayerXp(choice == 'Refuse Truce' ? 10 : 20);
    notifyListeners();
    saveGame();
    return null;
  }

  String _randomDocCrewName() {
    const crews = [
      'Behind the Beat Films',
      'Rise Doc Co',
      'Unfiltered Lens',
      'Chart Diaries',
      'The Come Up Crew',
    ];
    return crews[Random().nextInt(crews.length)];
  }

  double _documentaryBoost(Song song) {
    if (documentaryWeeks <= 0 || song.artistId != _player?.id) return 1.0;
    if (documentaryKind == 'access') return 1.11;
    if (documentaryKind == 'privacy') return 1.07;
    return 1.0;
  }

  String? resolveDocumentaryCrew(String choice, {bool fromEvent = false}) {
    if (_player == null) return 'No player';
    if (!fromEvent) {
      if (documentaryCooldownWeeks > 0) {
        return 'Crews are scouting elsewhere ($documentaryCooldownWeeks w)';
      }
      if (hasPendingDocumentary) return 'Finish the documentary event first';
      if ((_player!.attributes['popularity'] ?? 0) < 20) {
        return 'Need 20 popularity for documentary interest';
      }
    }

    final crew = documentaryCrewName.isNotEmpty
        ? documentaryCrewName
        : _randomDocCrewName();

    switch (choice) {
      case 'Grant Full Access':
        updatePlayerAttribute('marketing', 6);
        updatePlayerAttribute('networking', 5);
        updatePlayerAttribute('controversy', 7);
        updatePlayerAttribute('stamina', -10);
        updatePlayerAttribute('happiness', -4);
        documentaryKind = 'access';
        documentaryWeeks = 4;
        documentaryCrewName = crew;
        weeklyHeadlines.add(
          '$crew is filming every move in ${_player!.name}\'s rise.',
        );
        break;
      case 'Limit Privacy':
        updatePlayerAttribute('marketing', 4);
        updatePlayerAttribute('reputation', 3);
        updatePlayerAttribute('controversy', 2);
        updatePlayerAttribute('stamina', -4);
        updatePlayerAttribute('discipline', 2);
        documentaryKind = 'privacy';
        documentaryWeeks = 3;
        documentaryCrewName = crew;
        weeklyHeadlines.add(
          '${_player!.name} gave $crew controlled access.',
        );
        break;
      default:
        updatePlayerAttribute('reputation', 5);
        updatePlayerAttribute('fan_connection', 4);
        updatePlayerAttribute('discipline', 3);
        updatePlayerAttribute('happiness', 3);
        documentaryKind = '';
        documentaryWeeks = 0;
        documentaryCrewName = '';
        weeklyHeadlines.add(
          '${_player!.name} shut the door on $crew.',
        );
        break;
    }

    documentaryCooldownWeeks = 5;
    if (!fromEvent && choice != 'Deny Crew') {
      documentaryCrewName = crew;
    }
    if (!fromEvent) {
      lastWeekEvents.add(GameEvent(
        id: 'doc_done_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Documentary: $choice',
        description: choice == 'Grant Full Access'
            ? 'Cameras everywhere. The story gets huge — and messy.'
            : choice == 'Limit Privacy'
                ? 'You curate the narrative. Less heat, still buzz.'
                : 'No crew. You keep the mystery.',
        type: EventType.opportunity,
        severity: EventSeverity.high,
      ));
    }
    addPlayerXp(choice == 'Deny Crew' ? 10 : 22);
    notifyListeners();
    saveGame();
    return null;
  }

  String _randomTherapyPodcastName() {
    const shows = [
      'Off the Record',
      'Feelings & Frequencies',
      'The Unfiltered Hour',
      'Soft Launch Podcast',
      'Couch Confessions',
    ];
    return shows[Random().nextInt(shows.length)];
  }

  double _therapyPodcastBoost(Song song) {
    if (therapyPodcastWeeks <= 0 || song.artistId != _player?.id) return 1.0;
    if (therapyPodcastKind == 'open') return 1.08;
    if (therapyPodcastKind == 'deflect') return 1.05;
    return 1.0;
  }

  String? resolveTherapyPodcast(String choice, {bool fromEvent = false}) {
    if (_player == null) return 'No player';
    if (!fromEvent) {
      if (therapyPodcastCooldownWeeks > 0) {
        return 'Podcast bookings cooling off ($therapyPodcastCooldownWeeks w)';
      }
      if (hasPendingTherapyPodcast) {
        return 'Finish the podcast invite first';
      }
      final pop = _player!.attributes['popularity'] ?? 0;
      final controversy = _player!.attributes['controversy'] ?? 0;
      if (pop < 18 && controversy < 8) {
        return 'Need 18 popularity or 8 controversy for podcast buzz';
      }
    }

    final show = therapyPodcastName.isNotEmpty
        ? therapyPodcastName
        : _randomTherapyPodcastName();

    switch (choice) {
      case 'Open Up':
        updatePlayerAttribute('fan_connection', 8);
        updatePlayerAttribute('happiness', 5);
        updatePlayerAttribute('reputation', 3);
        updatePlayerAttribute('controversy', 4);
        updatePlayerAttribute('charisma', 3);
        therapyPodcastKind = 'open';
        therapyPodcastWeeks = 3;
        therapyPodcastName = show;
        weeklyHeadlines.add(
          '${_player!.name} got vulnerable on $show — fans are talking.',
        );
        break;
      case 'Deflect':
        updatePlayerAttribute('marketing', 4);
        updatePlayerAttribute('charisma', 4);
        updatePlayerAttribute('reputation', 2);
        updatePlayerAttribute('discipline', 2);
        therapyPodcastKind = 'deflect';
        therapyPodcastWeeks = 2;
        therapyPodcastName = show;
        weeklyHeadlines.add(
          '${_player!.name} kept it polished on $show.',
        );
        break;
      default:
        updatePlayerAttribute('discipline', 4);
        updatePlayerAttribute('reputation', 3);
        updatePlayerAttribute('fan_connection', -2);
        updatePlayerAttribute('happiness', 2);
        therapyPodcastKind = '';
        therapyPodcastWeeks = 0;
        therapyPodcastName = '';
        weeklyHeadlines.add(
          '${_player!.name} pulled out of $show at the last minute.',
        );
        break;
    }

    therapyPodcastCooldownWeeks = 5;
    if (!fromEvent && choice != 'Cancel Appearance') {
      therapyPodcastName = show;
    }
    if (!fromEvent) {
      lastWeekEvents.add(GameEvent(
        id: 'therapy_done_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Therapy Podcast: $choice',
        description: choice == 'Open Up'
            ? 'Raw honesty. Relatable — and a little risky.'
            : choice == 'Deflect'
                ? 'You stayed on message. Safe clip, smaller splash.'
                : 'No episode. You kept the walls up.',
        type: EventType.opportunity,
        severity: EventSeverity.medium,
      ));
    }
    addPlayerXp(choice == 'Cancel Appearance' ? 8 : 18);
    notifyListeners();
    saveGame();
    return null;
  }

  Artist? _pickCollabDmArtist() {
    if (_player == null) return null;
    final candidates = worldArtists
        .where((a) =>
            a.id != _player!.id &&
            !rivalIds.contains(a.id) &&
            (a.attributes['popularity'] ?? 0) >= 30)
        .toList();
    if (candidates.isEmpty) return null;
    candidates.sort((a, b) =>
        (b.attributes['popularity'] ?? 0).compareTo(a.attributes['popularity'] ?? 0));
    final pool = candidates.take(6).toList();
    return pool[Random().nextInt(pool.length)];
  }

  Song? _pickCollabTargetSong() {
    if (playerSongs.isEmpty) return null;
    Song? best;
    var bestRank = 999;
    for (final s in playerSongs) {
      final r = worldSongs.indexOf(s) + 1;
      if (r < bestRank) {
        bestRank = r;
        best = s;
      }
    }
    return best ?? playerSongs.first;
  }

  double _collabDmBoost(Song song) {
    if (collabDmWeeks <= 0 ||
        song.id != collabDmSongId ||
        song.artistId != _player?.id) {
      return 1.0;
    }
    if (collabDmKind == 'accept') return 1.14;
    if (collabDmKind == 'teaser') return 1.10;
    return 1.0;
  }

  String? resolveCollabDm(String choice, {bool fromEvent = false}) {
    if (_player == null) return 'No player';
    if (!fromEvent) {
      if (collabDmCooldownWeeks > 0) {
        return 'Collab inbox quiet ($collabDmCooldownWeeks w)';
      }
      if (hasPendingCollabDm) return 'Finish the collab DM first';
      if (playerSongs.isEmpty) return 'Need a song to collab on';
      if ((_player!.attributes['popularity'] ?? 0) < 22) {
        return 'Need 22 popularity for collab DMs';
      }
    }

    final artist =
        getArtistById(collabDmArtistId) ?? _pickCollabDmArtist();
    if (artist == null) return 'No collab artist available';
    final song = _pickCollabTargetSong();
    if (song == null) return 'No song to feature';

    switch (choice) {
      case 'Accept Collab':
        if (!fromEvent) {
          final stamina = _player!.attributes['stamina'] ?? 0;
          if (stamina < 14) return 'Too tired for a collab session';
          if (playerMoney < 400) return 'Need \$400 for studio time';
        }
        updatePlayerAttribute('stamina', -14);
        if (playerMoney >= 400) updatePlayerMoney(-400);
        updatePlayerAttribute('networking', 6);
        updatePlayerAttribute('popularity', 4);
        updatePlayerAttribute('marketing', 3);
        updateArtistAttribute(artist.id, 'networking', 3);
        updateArtistAttribute(artist.id, 'popularity', 2);
        song.viralFactor = (song.viralFactor + 6).clamp(0.0, 100.0);
        collabDmKind = 'accept';
        collabDmWeeks = 3;
        collabDmSongId = song.id;
        collabDmArtistId = artist.id;
        updatePlayerFanCount(350 + Random().nextInt(250));
        weeklyHeadlines.add(
          '${artist.name} and ${_player!.name} locked a collab on "${song.title}".',
        );
        break;
      case 'Leak Teaser':
        updatePlayerAttribute('marketing', 5);
        updatePlayerAttribute('controversy', 6);
        updatePlayerAttribute('fan_connection', 3);
        updateArtistAttribute(artist.id, 'popularity', -2);
        updateArtistAttribute(artist.id, 'controversy', 3);
        song.viralFactor = (song.viralFactor + 10).clamp(0.0, 100.0);
        collabDmKind = 'teaser';
        collabDmWeeks = 2;
        collabDmSongId = song.id;
        collabDmArtistId = artist.id;
        weeklyHeadlines.add(
          '${_player!.name} leaked a ${artist.name} collab snippet.',
        );
        break;
      default:
        updatePlayerAttribute('discipline', 3);
        updatePlayerAttribute('happiness', 2);
        updatePlayerAttribute('reputation', -3);
        updatePlayerAttribute('controversy', 2);
        updateArtistAttribute(artist.id, 'popularity', 2);
        collabDmKind = '';
        collabDmWeeks = 0;
        collabDmSongId = '';
        collabDmArtistId = artist.id;
        weeklyHeadlines.add(
          '${_player!.name} left ${artist.name}\'s DM on read.',
        );
        break;
    }

    collabDmCooldownWeeks = 5;
    if (!fromEvent && choice != 'Ghost Them') {
      collabDmArtistId = artist.id;
    }
    if (!fromEvent) {
      lastWeekEvents.add(GameEvent(
        id: 'collab_dm_done_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Collab DM: $choice',
        description: choice == 'Accept Collab'
            ? 'Studio booked with ${artist.name}. The feature buzz is real.'
            : choice == 'Leak Teaser'
                ? 'Snippet out early. Hype up, trust down.'
                : '${artist.name} might post the screenshots.',
        type: EventType.collaboration,
        severity: EventSeverity.high,
      ));
    }
    addPlayerXp(choice == 'Ghost Them' ? 8 : 20);
    notifyListeners();
    saveGame();
    return null;
  }


  double _stalkerFanBoost(Song song) {
    if (stalkerFanWeeks <= 0 || song.artistId != _player?.id) return 1.0;
    if (stalkerFanKind == 'ro') return 1.06;
    if (stalkerFanKind == 'soft') return 1.05;
    if (stalkerFanKind == 'engage') return 1.09;
    return 1.0;
  }

  String? resolveStalkerFan(String choice, {bool fromEvent = false}) {
    if (_player == null) return 'No player';
    if (!fromEvent) {
      if (stalkerFanCooldownWeeks > 0) {
        return 'Fan safety quiet ($stalkerFanCooldownWeeks w)';
      }
      if (hasPendingStalkerFan) return 'Finish the stalker fan event first';
      final pop = _player!.attributes['popularity'] ?? 0;
      if (pop < 25 && playerFanCount < 800) {
        return 'Need 25 popularity or 800 fans for stalker incidents';
      }
    }

    switch (choice) {
      case 'Restraining Order':
        if (!fromEvent && playerMoney < 800) {
          return 'Need \$800 for legal fees';
        }
        if (playerMoney >= 800) updatePlayerMoney(-800);
        updatePlayerAttribute('discipline', 6);
        updatePlayerAttribute('reputation', 4);
        updatePlayerAttribute('happiness', -5);
        stalkerFanKind = 'ro';
        stalkerFanWeeks = 3;
        weeklyHeadlines.add(
          '${_player!.name} filed a restraining order on a stalker fan.',
        );
        break;
      case 'Soft Block':
        updatePlayerAttribute('discipline', 4);
        updatePlayerAttribute('happiness', 3);
        stalkerFanKind = 'soft';
        stalkerFanWeeks = 2;
        weeklyHeadlines.add(
          '${_player!.name} soft-blocked a creepy superfan.',
        );
        break;
      default:
        updatePlayerAttribute('controversy', 7);
        updatePlayerAttribute('fan_connection', 5);
        updatePlayerAttribute('reputation', -4);
        stalkerFanKind = 'engage';
        stalkerFanWeeks = 2;
        weeklyHeadlines.add(
          '${_player!.name} engaged a stalker fan — messy headlines follow.',
        );
        break;
    }

    stalkerFanCooldownWeeks = 5;
    if (!fromEvent) {
      lastWeekEvents.add(GameEvent(
        id: 'stalker_done_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Stalker Fan: $choice',
        description: choice == 'Restraining Order'
            ? 'Legal boundary set. Safer, colder vibe.'
            : choice == 'Soft Block'
                ? 'Quiet distance. You keep the peace.'
                : 'You leaned into the chaos. Streams and drama.',
        type: EventType.scandal,
        severity: EventSeverity.high,
      ));
    }
    addPlayerXp(choice == 'Soft Block' ? 12 : 18);
    notifyListeners();
    saveGame();
    return null;
  }

  double _merchDropBoost(Song song) {
    if (merchDropWeeks <= 0 || song.artistId != _player?.id) return 1.0;
    if (merchDropKind == 'premium') return 1.08;
    if (merchDropKind == 'mass') return 1.06;
    return 1.0;
  }

  String? resolveMerchDrop(String choice, {bool fromEvent = false}) {
    if (_player == null) return 'No player';
    if (!fromEvent) {
      if (merchDropCooldownWeeks > 0) {
        return 'Merch warehouse cooling ($merchDropCooldownWeeks w)';
      }
      if (hasPendingMerchDrop) return 'Finish the merch drop first';
      if ((_player!.attributes['popularity'] ?? 0) < 20) {
        return 'Need 20 popularity for a merch drop';
      }
    }

    switch (choice) {
      case 'Premium Drop':
        if (!fromEvent && playerMoney < 1200) {
          return 'Need \$1200 for premium merch';
        }
        if (playerMoney >= 1200) updatePlayerMoney(-1200);
        updatePlayerMoney((1800 + Random().nextInt(600)).toDouble());
        updatePlayerFanCount(180 + Random().nextInt(120));
        updatePlayerAttribute('networking', 4);
        updatePlayerAttribute('marketing', 3);
        merchDropKind = 'premium';
        merchDropWeeks = 3;
        weeklyHeadlines.add(
          '${_player!.name} dropped limited vinyl and premium merch.',
        );
        break;
      case 'Mass Market':
        if (!fromEvent && playerMoney < 500) {
          return 'Need \$500 for mass merch';
        }
        if (playerMoney >= 500) updatePlayerMoney(-500);
        updatePlayerMoney((1400 + Random().nextInt(500)).toDouble());
        updatePlayerFanCount(90 + Random().nextInt(80));
        updatePlayerAttribute('marketing', 4);
        updatePlayerAttribute('reputation', -2);
        merchDropKind = 'mass';
        merchDropWeeks = 2;
        weeklyHeadlines.add(
          '${_player!.name} flooded shops with mass-market merch.',
        );
        break;
      default:
        updatePlayerAttribute('discipline', 3);
        updatePlayerAttribute('happiness', 3);
        merchDropKind = '';
        merchDropWeeks = 0;
        weeklyHeadlines.add(
          '${_player!.name} skipped the merch drop window.',
        );
        break;
    }

    merchDropCooldownWeeks = 5;
    if (!fromEvent) {
      lastWeekEvents.add(GameEvent(
        id: 'merch_done_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Merch Drop: $choice',
        description: choice == 'Premium Drop'
            ? 'Limited run sold. Cred and cash.'
            : choice == 'Mass Market'
                ? 'Volume up, cool factor down a notch.'
                : 'No drop. You kept inventory tight.',
        type: EventType.opportunity,
        severity: EventSeverity.medium,
      ));
    }
    addPlayerXp(choice == 'Skip Drop' ? 8 : 16);
    notifyListeners();
    saveGame();
    return null;
  }

  double _tourBusBoost(Song song) {
    if (tourBusWeeks <= 0 || song.artistId != _player?.id) return 1.0;
    if (tourBusKind == 'fix') return 1.07;
    if (tourBusKind == 'diy') return 1.05;
    return 1.0;
  }

  String? resolveTourBus(String choice, {bool fromEvent = false}) {
    if (_player == null) return 'No player';
    if (!fromEvent) {
      if (tourBusCooldownWeeks > 0) {
        return 'Tour logistics quiet ($tourBusCooldownWeeks w)';
      }
      if (hasPendingTourBus) return 'Finish the tour bus event first';
      if ((_player!.attributes['popularity'] ?? 0) < 15) {
        return 'Need 15 popularity for tour bus drama';
      }
    }

    switch (choice) {
      case 'Pay for Fix':
        if (!fromEvent && playerMoney < 1500) {
          return 'Need \$1500 for the mechanic';
        }
        if (playerMoney >= 1500) updatePlayerMoney(-1500);
        updatePlayerAttribute('happiness', 4);
        updatePlayerAttribute('discipline', 2);
        tourBusKind = 'fix';
        tourBusWeeks = 2;
        weeklyHeadlines.add(
          '${_player!.name} paid to fix the tour bus and kept the dates.',
        );
        break;
      case 'DIY Repair':
        updatePlayerAttribute('stamina', -14);
        updatePlayerAttribute('marketing', 3);
        if (Random().nextBool()) {
          tourBusKind = 'diy';
          tourBusWeeks = 2;
          updatePlayerAttribute('happiness', 3);
          weeklyHeadlines.add(
            '${_player!.name} DIY-fixed the bus — road-warrior lore.',
          );
        } else {
          tourBusKind = '';
          tourBusWeeks = 0;
          updatePlayerAttribute('controversy', 5);
          updatePlayerMoney((200 + Random().nextInt(150)).toDouble());
          weeklyHeadlines.add(
            '${_player!.name}\'s DIY bus fix failed — viral flop clips.',
          );
        }
        break;
      default:
        updatePlayerMoney(-600);
        updatePlayerFanCount(-40);
        updatePlayerAttribute('discipline', 4);
        tourBusKind = 'cancel';
        tourBusWeeks = 0;
        weeklyHeadlines.add(
          '${_player!.name} cancelled dates after the tour bus died.',
        );
        break;
    }

    tourBusCooldownWeeks = 5;
    if (!fromEvent) {
      lastWeekEvents.add(GameEvent(
        id: 'tourbus_done_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Tour Bus: $choice',
        description: choice == 'Pay for Fix'
            ? 'Mechanic paid. Shows go on.'
            : choice == 'DIY Repair'
                ? 'You rolled the dice under the chassis.'
                : 'Refunds and apologies. Discipline up.',
        type: EventType.opportunity,
        severity: EventSeverity.medium,
      ));
    }
    addPlayerXp(choice == 'Cancel Dates' ? 10 : 16);
    notifyListeners();
    saveGame();
    return null;
  }

  double _awardsCampBoost(Song song) {
    if (awardsCampWeeks <= 0 || song.artistId != _player?.id) return 1.0;
    if (awardsCampKind == 'campaign') return 1.12;
    if (awardsCampKind == 'chill') return 1.07;
    return 1.0;
  }

  String? resolveAwardsCamp(String choice, {bool fromEvent = false}) {
    if (_player == null) return 'No player';
    if (!fromEvent) {
      if (awardsCampCooldownWeeks > 0) {
        return 'Awards circuit quiet ($awardsCampCooldownWeeks w)';
      }
      if (hasPendingAwardsCamp) return 'Finish awards night first';
      if ((_player!.attributes['popularity'] ?? 0) < 30) {
        return 'Need 30 popularity for awards campaign night';
      }
    }

    switch (choice) {
      case 'Full Campaign':
        if (!fromEvent && playerMoney < 2000) {
          return 'Need \$2000 for a full campaign night';
        }
        if (playerMoney >= 2000) updatePlayerMoney(-2000);
        updatePlayerAttribute('stamina', -12);
        updatePlayerAttribute('marketing', 6);
        updatePlayerAttribute('networking', 6);
        updatePlayerAttribute('controversy', 4);
        awardsCampKind = 'campaign';
        awardsCampWeeks = 3;
        weeklyHeadlines.add(
          '${_player!.name} ran a full awards-night campaign.',
        );
        break;
      case 'Keep It Chill':
        updatePlayerAttribute('happiness', 5);
        updatePlayerAttribute('networking', 4);
        awardsCampKind = 'chill';
        awardsCampWeeks = 2;
        weeklyHeadlines.add(
          '${_player!.name} kept awards night low-key and charming.',
        );
        break;
      default:
        updatePlayerAttribute('discipline', 4);
        updatePlayerAttribute('happiness', 3);
        awardsCampKind = '';
        awardsCampWeeks = 0;
        weeklyHeadlines.add(
          '${_player!.name} skipped awards campaign night.',
        );
        break;
    }

    awardsCampCooldownWeeks = 6;
    if (!fromEvent) {
      lastWeekEvents.add(GameEvent(
        id: 'awards_done_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Awards Night: $choice',
        description: choice == 'Full Campaign'
            ? 'Tables bought, speeches practiced, drama included.'
            : choice == 'Keep It Chill'
                ? 'Soft presence. Warm buzz.'
                : 'Home early. Restored.',
        type: EventType.opportunity,
        severity: EventSeverity.high,
      ));
    }
    addPlayerXp(choice == 'Skip Night' ? 8 : 22);
    notifyListeners();
    saveGame();
    return null;
  }

  double _genrePivotBoost(Song song) {
    if (genrePivotWeeks <= 0 || song.artistId != _player?.id) return 1.0;
    if (genrePivotKind == 'lean') return 1.08;
    if (genrePivotKind == 'deny') return 1.05;
    if (genrePivotKind == 'double') return 1.11;
    return 1.0;
  }

  String? resolveGenrePivot(String choice, {bool fromEvent = false}) {
    if (_player == null) return 'No player';
    if (!fromEvent) {
      if (genrePivotCooldownWeeks > 0) {
        return 'Genre rumor quiet ($genrePivotCooldownWeeks w)';
      }
      if (hasPendingGenrePivot) return 'Finish the genre rumor first';
      if ((_player!.attributes['popularity'] ?? 0) < 18) {
        return 'Need 18 popularity for genre pivot rumors';
      }
    }

    switch (choice) {
      case 'Lean Into It':
        updatePlayerAttribute('marketing', 5);
        final g = playerDominantGenre;
        genreHeat[g] = ((genreHeat[g] ?? 40) + 6).clamp(15.0, 100.0);
        genrePivotKind = 'lean';
        genrePivotWeeks = 3;
        weeklyHeadlines.add(
          '${_player!.name} leaned into the $g pivot rumor.',
        );
        break;
      case 'Deny the Rumor':
        updatePlayerAttribute('reputation', 4);
        updatePlayerAttribute('discipline', 3);
        genrePivotKind = 'deny';
        genrePivotWeeks = 2;
        weeklyHeadlines.add(
          '${_player!.name} denied a genre-pivot rumor.',
        );
        break;
      default:
        if (!fromEvent && playerMoney < 600) {
          return 'Need \$600 to double down on the pivot';
        }
        if (playerMoney >= 600) updatePlayerMoney(-600);
        updatePlayerAttribute('controversy', 6);
        updatePlayerAttribute('stamina', -8);
        updatePlayerAttribute('marketing', 4);
        genrePivotKind = 'double';
        genrePivotWeeks = 2;
        weeklyHeadlines.add(
          '${_player!.name} doubled down on a wild genre pivot.',
        );
        break;
    }

    genrePivotCooldownWeeks = 5;
    if (!fromEvent) {
      lastWeekEvents.add(GameEvent(
        id: 'genre_pivot_done_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Genre Rumor: $choice',
        description: choice == 'Lean Into It'
            ? 'You own the rumor. Heat follows.'
            : choice == 'Deny the Rumor'
                ? 'Stay in lane. Cred intact.'
                : 'All-in rebrand energy.',
        type: EventType.opportunity,
        severity: EventSeverity.medium,
      ));
    }
    addPlayerXp(choice == 'Deny the Rumor' ? 12 : 18);
    notifyListeners();
    saveGame();
    return null;
  }

  double _arenaSlotBoost(Song song) {
    if (arenaSlotWeeks <= 0 || song.artistId != _player?.id) return 1.0;
    if (arenaSlotKind == 'support') return 1.09;
    if (arenaSlotKind == 'hold') return 1.06;
    return 1.0;
  }

  String? resolveArenaSlot(String choice, {bool fromEvent = false}) {
    if (_player == null) return 'No player';
    if (!fromEvent) {
      if (arenaSlotCooldownWeeks > 0) {
        return 'Arena bookers quiet ($arenaSlotCooldownWeeks w)';
      }
      if (hasPendingArenaSlot) return 'Finish the arena slot first';
      if ((_player!.attributes['popularity'] ?? 0) < 28) {
        return 'Need 28 popularity for arena support slots';
      }
    }

    switch (choice) {
      case 'Take Support Slot':
        updatePlayerMoney((2200 + Random().nextInt(800)).toDouble());
        updatePlayerFanCount(280 + Random().nextInt(200));
        updatePlayerAttribute('stamina', -10);
        updatePlayerAttribute('networking', 5);
        updatePlayerAttribute('performance', 3);
        arenaSlotKind = 'support';
        arenaSlotWeeks = 3;
        weeklyHeadlines.add(
          '${_player!.name} took an arena support slot.',
        );
        break;
      case 'Hold for Headliner':
        updatePlayerAttribute('networking', 4);
        updatePlayerAttribute('discipline', 4);
        arenaSlotKind = 'hold';
        arenaSlotWeeks = 2;
        weeklyHeadlines.add(
          '${_player!.name} held out for a headliner slot.',
        );
        break;
      default:
        updatePlayerAttribute('happiness', 3);
        updatePlayerAttribute('discipline', 3);
        arenaSlotKind = '';
        arenaSlotWeeks = 0;
        weeklyHeadlines.add(
          '${_player!.name} passed on the arena offer.',
        );
        break;
    }

    arenaSlotCooldownWeeks = 5;
    if (!fromEvent) {
      lastWeekEvents.add(GameEvent(
        id: 'arena_done_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Arena Slot: $choice',
        description: choice == 'Take Support Slot'
            ? 'Big stage, opening set, instant fans.'
            : choice == 'Hold for Headliner'
                ? 'Patient play. Bookers remember.'
                : 'No arena this month.',
        type: EventType.opportunity,
        severity: EventSeverity.high,
      ));
    }
    addPlayerXp(choice == 'Pass' ? 8 : 20);
    notifyListeners();
    saveGame();
    return null;
  }

  double _fanTheoryBoost(Song song) {
    if (fanTheoryWeeks <= 0 || song.artistId != _player?.id) return 1.0;
    if (fanTheoryKind == 'confirm') return 1.07;
    if (fanTheoryKind == 'deny') return 1.04;
    if (fanTheoryKind == 'feed') return 1.10;
    return 1.0;
  }

  String? resolveFanTheory(String choice, {bool fromEvent = false}) {
    if (_player == null) return 'No player';
    if (!fromEvent) {
      if (fanTheoryCooldownWeeks > 0) {
        return 'Fan theories cooling ($fanTheoryCooldownWeeks w)';
      }
      if (hasPendingFanTheory) return 'Finish the fan theory first';
      final pop = _player!.attributes['popularity'] ?? 0;
      if (pop < 16 && playerFanCount < 500) {
        return 'Need 16 popularity or 500 fans for theory rabbit holes';
      }
    }

    switch (choice) {
      case 'Confirm Theory':
        updatePlayerAttribute('fan_connection', 6);
        updatePlayerAttribute('happiness', 3);
        updatePlayerAttribute('reputation', 2);
        fanTheoryKind = 'confirm';
        fanTheoryWeeks = 2;
        weeklyHeadlines.add(
          '${_player!.name} confirmed a wild fan theory.',
        );
        break;
      case 'Deny Theory':
        updatePlayerAttribute('discipline', 4);
        updatePlayerAttribute('reputation', 3);
        fanTheoryKind = 'deny';
        fanTheoryWeeks = 2;
        weeklyHeadlines.add(
          '${_player!.name} shut down a fan theory rabbit hole.',
        );
        break;
      default:
        updatePlayerAttribute('controversy', 5);
        updatePlayerAttribute('marketing', 5);
        updatePlayerAttribute('fan_connection', 4);
        fanTheoryKind = 'feed';
        fanTheoryWeeks = 3;
        weeklyHeadlines.add(
          '${_player!.name} fed the fan theory machine.',
        );
        break;
    }

    fanTheoryCooldownWeeks = 5;
    if (!fromEvent) {
      lastWeekEvents.add(GameEvent(
        id: 'fan_theory_done_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Fan Theory: $choice',
        description: choice == 'Confirm Theory'
            ? 'Mystery solved. Fans feel seen.'
            : choice == 'Deny Theory'
                ? 'Walls up. Lore stays murky.'
                : 'The timeline goes feral.',
        type: EventType.opportunity,
        severity: EventSeverity.medium,
      ));
    }
    addPlayerXp(choice == 'Deny Theory' ? 10 : 16);
    notifyListeners();
    saveGame();
    return null;
  }

  double _blacklistBoost(Song song) {
    if (blacklistWeeks <= 0 || song.artistId != _player?.id) return 1.0;
    if (blacklistKind == 'address') return 1.06;
    if (blacklistKind == 'clapback') return 1.09;
    return 1.0;
  }

  String? resolveBlacklistRumor(String choice, {bool fromEvent = false}) {
    if (_player == null) return 'No player';
    if (!fromEvent) {
      if (blacklistCooldownWeeks > 0) {
        return 'Blacklist chatter quiet ($blacklistCooldownWeeks w)';
      }
      if (hasPendingBlacklist) return 'Finish the blacklist rumor first';
      final pop = _player!.attributes['popularity'] ?? 0;
      final controversy = _player!.attributes['controversy'] ?? 0;
      if (controversy < 10 && pop < 25) {
        return 'Need 10 controversy or 25 popularity for blacklist rumors';
      }
    }

    switch (choice) {
      case 'Address It':
        if (!fromEvent && playerMoney < 400) {
          return 'Need \$400 for PR';
        }
        if (playerMoney >= 400) updatePlayerMoney(-400);
        updatePlayerAttribute('reputation', 5);
        updatePlayerAttribute('controversy', -4);
        blacklistKind = 'address';
        blacklistWeeks = 3;
        weeklyHeadlines.add(
          '${_player!.name} addressed a social blacklist rumor.',
        );
        break;
      case 'Ignore It':
        updatePlayerAttribute('discipline', 4);
        updatePlayerAttribute('happiness', 2);
        blacklistKind = 'ignore';
        blacklistWeeks = 0;
        weeklyHeadlines.add(
          '${_player!.name} ignored a blacklist rumor.',
        );
        break;
      default:
        updatePlayerAttribute('controversy', 6);
        updatePlayerAttribute('marketing', 4);
        updatePlayerAttribute('reputation', -3);
        blacklistKind = 'clapback';
        blacklistWeeks = 2;
        weeklyHeadlines.add(
          '${_player!.name} clapped back at blacklist whispers.',
        );
        break;
    }

    blacklistCooldownWeeks = 5;
    if (!fromEvent) {
      lastWeekEvents.add(GameEvent(
        id: 'blacklist_done_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Blacklist: $choice',
        description: choice == 'Address It'
            ? 'PR statement out. Waters calm.'
            : choice == 'Ignore It'
                ? 'Silence. Discipline holds.'
                : 'Clap back viral. Messy heat.',
        type: EventType.scandal,
        severity: EventSeverity.high,
      ));
    }
    addPlayerXp(choice == 'Ignore It' ? 8 : 16);
    notifyListeners();
    saveGame();
    return null;
  }

  double _comebackBoost(Song song) {
    if (comebackWeeks <= 0 || song.artistId != _player?.id) return 1.0;
    if (comebackKind == 'intimate') return 1.08;
    if (comebackKind == 'maximal') return 1.12;
    return 1.0;
  }

  String? resolveComebackConcept(String choice, {bool fromEvent = false}) {
    if (_player == null) return 'No player';
    if (!fromEvent) {
      if (comebackCooldownWeeks > 0) {
        return 'Comeback planning quiet ($comebackCooldownWeeks w)';
      }
      if (hasPendingComeback) return 'Finish the comeback concept first';
      final pop = _player!.attributes['popularity'] ?? 0;
      final weeks = (_player!.attributes['weeksSinceDebut'] ?? 0);
      if (pop < 35 && weeks < 40) {
        return 'Need 35 popularity or 40 weeks since debut';
      }
    }

    switch (choice) {
      case 'Intimate Concept':
        updatePlayerAttribute('songwriting', 5);
        updatePlayerAttribute('fan_connection', 5);
        updatePlayerAttribute('happiness', 4);
        comebackKind = 'intimate';
        comebackWeeks = 3;
        weeklyHeadlines.add(
          '${_player!.name} sketched an intimate comeback album concept.',
        );
        break;
      case 'Maximalist Concept':
        if (!fromEvent && playerMoney < 2500) {
          return 'Need \$2500 for a maximalist concept';
        }
        if (playerMoney >= 2500) updatePlayerMoney(-2500);
        updatePlayerAttribute('stamina', -15);
        updatePlayerAttribute('marketing', 6);
        updatePlayerAttribute('controversy', 4);
        comebackKind = 'maximal';
        comebackWeeks = 3;
        weeklyHeadlines.add(
          '${_player!.name} greenlit a maximalist comeback spectacle.',
        );
        break;
      default:
        updatePlayerAttribute('discipline', 4);
        updatePlayerAttribute('happiness', 3);
        comebackKind = '';
        comebackWeeks = 0;
        weeklyHeadlines.add(
          '${_player!.name} delayed the comeback album concept.',
        );
        break;
    }

    comebackCooldownWeeks = 6;
    if (!fromEvent) {
      lastWeekEvents.add(GameEvent(
        id: 'comeback_done_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Comeback: $choice',
        description: choice == 'Intimate Concept'
            ? 'Soft songs, close fans, long game.'
            : choice == 'Maximalist Concept'
                ? 'Big budget, big risk, big noise.'
                : 'Project on ice. Head clear.',
        type: EventType.opportunity,
        severity: EventSeverity.high,
      ));
    }
    addPlayerXp(choice == 'Delay Project' ? 10 : 22);
    notifyListeners();
    saveGame();
    return null;
  }

  double _charityBoost(Song song) {
    if (charityWeeks <= 0 || song.artistId != _player?.id) return 1.0;
    if (charityKind == 'donate') return 1.07;
    if (charityKind == 'match') return 1.09;
    return 1.0;
  }

  String? resolveCharitySingle(String choice, {bool fromEvent = false}) {
    if (_player == null) return 'No player';
    if (!fromEvent) {
      if (charityCooldownWeeks > 0) {
        return 'Charity calendar quiet ($charityCooldownWeeks w)';
      }
      if (hasPendingCharity) return 'Finish the charity single first';
      if ((_player!.attributes['popularity'] ?? 0) < 22) {
        return 'Need 22 popularity for a charity single push';
      }
    }

    switch (choice) {
      case 'Donate Proceeds':
        final give = playerMoney >= 2000
            ? (playerMoney * 0.4).clamp(800.0, 2000.0)
            : 800.0;
        if (!fromEvent && playerMoney < give) {
          return 'Need enough cash to donate proceeds';
        }
        if (playerMoney >= give) updatePlayerMoney(-give);
        updatePlayerAttribute('reputation', 6);
        updatePlayerAttribute('fan_connection', 5);
        charityKind = 'donate';
        charityWeeks = 3;
        weeklyHeadlines.add(
          '${_player!.name} donated charity-single proceeds.',
        );
        break;
      case 'Match Donations':
        if (!fromEvent && playerMoney < 1200) {
          return 'Need \$1200 to match donations';
        }
        if (playerMoney >= 1200) updatePlayerMoney(-1200);
        updatePlayerAttribute('reputation', 5);
        updatePlayerAttribute('networking', 4);
        charityKind = 'match';
        charityWeeks = 2;
        weeklyHeadlines.add(
          '${_player!.name} matched fan donations on a charity single.',
        );
        break;
      default:
        updatePlayerAttribute('reputation', -2);
        updatePlayerAttribute('discipline', 3);
        charityKind = '';
        charityWeeks = 0;
        weeklyHeadlines.add(
          '${_player!.name} skipped the charity single push.',
        );
        break;
    }

    charityCooldownWeeks = 5;
    if (!fromEvent) {
      lastWeekEvents.add(GameEvent(
        id: 'charity_done_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Charity: $choice',
        description: choice == 'Donate Proceeds'
            ? 'Cash out, goodwill in.'
            : choice == 'Match Donations'
                ? 'You matched the community. Cred rises.'
                : 'No charity this week. Mild side-eye.',
        type: EventType.opportunity,
        severity: EventSeverity.medium,
      ));
    }
    addPlayerXp(choice == 'Skip Charity' ? 8 : 18);
    notifyListeners();
    saveGame();
    return null;
  }

  Artist? _pickMentorNpc() {
    if (_player == null) return null;
    final candidates = worldArtists
        .where((a) =>
            a.id != _player!.id &&
            (a.attributes['popularity'] ?? 0) >= 45)
        .toList()
      ..sort((a, b) =>
          (b.attributes['popularity'] ?? 0)
              .compareTo(a.attributes['popularity'] ?? 0));
    if (candidates.isEmpty) return null;
    return candidates.first;
  }

  double _mentorCosignBoost(Song song) {
    if (mentorCosignWeeks <= 0 || song.artistId != _player?.id) return 1.0;
    if (mentorCosignKind == 'advice') return 1.06;
    if (mentorCosignKind == 'feature' && song.id == mentorCosignSongId) {
      return 1.12;
    }
    return 1.0;
  }

  String? resolveMentorCosign(String choice, {bool fromEvent = false}) {
    if (_player == null) return 'No player';
    if (!fromEvent && hasPendingMentorCosign) {
      return 'Finish the mentor offer first';
    }

    final mentor = getArtistById(mentorCosignArtistId) ?? _pickMentorNpc();
    if (mentor == null) return 'No mentor available';

    switch (choice) {
      case 'Feature Verse':
        if (!fromEvent) {
          final stamina = _player!.attributes['stamina'] ?? 0;
          if (stamina < 16) return 'Too tired to record the feature';
          if (playerMoney < 350) return 'Need \$350 for the session';
        }
        updatePlayerAttribute('stamina', -16);
        if (playerMoney >= 350) updatePlayerMoney(-350);
        final quality = (((_player!.attributes['songwriting'] ?? 40) +
                    (mentor.attributes['popularity'] ?? 50)) /
                1.6)
            .clamp(35.0, 96.0);
        final feature = Song(
          id: 'song_${DateTime.now().millisecondsSinceEpoch}_mentor',
          title: '${mentor.name} ft. ${_player!.name} - Cosign',
          artistId: _player!.id,
          popularityFactor: quality,
          viralFactor: (45 + Random().nextDouble() * 25).clamp(15.0, 95.0),
          salesPotential: (40 + Random().nextDouble() * 25).clamp(15.0, 90.0),
          genre: playerHomeGenre,
          studioFinish: 'polish',
          isNewEntry: true,
          listeningParty: 'pending',
        );
        worldSongs.add(feature);
        mentorCosignKind = 'feature';
        mentorCosignWeeks = 2;
        mentorCosignSongId = feature.id;
        mentorCosignArtistId = mentor.id;
        updateArtistAttribute(mentor.id, 'networking', 4);
        updatePlayerAttribute('networking', 5);
        updatePlayerAttribute('popularity', 4);
        updatePlayerFanCount(500 + Random().nextInt(300));
        _challenges?.updateProgress(ChallengeType.releaseSongs, 1);
        weeklyHeadlines.add(
          '${mentor.name} cosigned ${_player!.name} on "${feature.title}".',
        );
        break;
      case 'Take Advice':
        updatePlayerAttribute('songwriting', 5);
        updatePlayerAttribute('discipline', 3);
        updatePlayerAttribute('reputation', 3);
        updatePlayerAttribute('networking', 2);
        mentorCosignKind = 'advice';
        mentorCosignWeeks = 2;
        mentorCosignSongId = '';
        mentorCosignArtistId = mentor.id;
        weeklyHeadlines.add(
          '${mentor.name} pulled ${_player!.name} aside for a studio talk.',
        );
        break;
      default:
        updatePlayerAttribute('happiness', 2);
        updatePlayerAttribute('reputation', -1);
        mentorCosignKind = '';
        mentorCosignWeeks = 0;
        mentorCosignSongId = '';
        weeklyHeadlines.add(
          '${_player!.name} passed on ${mentor.name}\'s cosign.',
        );
        break;
    }

    mentorCosignCooldownWeeks = 5;
    if (!fromEvent) {
      lastWeekEvents.add(GameEvent(
        id: 'mentor_cosign_done_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Mentor: $choice',
        description: choice == 'Feature Verse'
            ? 'The feature is out. Their audience is watching.'
            : choice == 'Take Advice'
                ? 'Notes landed. Your next sessions hit cleaner.'
                : 'You kept your lane. They will remember.',
        type: EventType.collaboration,
        severity: EventSeverity.high,
      ));
    }
    addPlayerXp(choice == 'Feature Verse' ? 32 : 14);
    notifyListeners();
    saveGame();
    return null;
  }

  void _queuePendingListeningParties() {
    if (_player == null) return;
    for (final song in playerSongs) {
      if (song.listeningParty != 'pending') continue;
      if (!inDebutWindow(song)) {
        song.listeningParty = 'skip';
        continue;
      }
      final id = 'listen_party::${song.id}';
      if (lastWeekEvents.any((e) => e.id == id)) continue;
      lastWeekEvents.add(GameEvent(
        id: id,
        title: 'Listening Party: ${song.title}',
        description:
            'Throw a room for "${song.title}" this week — press for reviews, fans for word of mouth, or keep the drop quiet.',
        type: EventType.opportunity,
        severity: EventSeverity.high,
        choices: const ['Invite Press', 'Invite Fans', 'Quiet Drop'],
        choiceOutcomes: const {
          'Quiet Drop': {
            'discipline': 2,
          },
        },
      ));
    }
  }

  String? runListeningParty(String songId, String choice,
      {bool fromEvent = false}) {
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
    if (song.listeningParty != 'pending' && song.listeningParty.isNotEmpty) {
      return 'That drop already had its party';
    }

    if (choice == 'Invite Press') {
      const cost = 160.0;
      if (!fromEvent && playerMoney < cost) {
        return 'Need \$160 to host press';
      }
      final stamina = _player!.attributes['stamina'] ?? 0;
      if (!fromEvent && stamina < 8) return 'Too tired to host press';
      if (playerMoney >= cost) updatePlayerMoney(-cost);
      updatePlayerAttribute('stamina', -8);
      updatePlayerAttribute('reputation', 3);
      updatePlayerAttribute('marketing', 2);
      song.listeningParty = 'press';
      song.listeningPartyWeeks = 2;
      song.viralFactor = (song.viralFactor + 6).clamp(0.0, 100.0);
      weeklyHeadlines.add(
        'Press listening party for "${song.title}" — reviews incoming.',
      );
    } else if (choice == 'Invite Fans') {
      const cost = 280.0;
      if (!fromEvent && playerMoney < cost) {
        return 'Need \$280 for a fan party';
      }
      final stamina = _player!.attributes['stamina'] ?? 0;
      if (!fromEvent && stamina < 12) return 'Too tired to host fans';
      if (playerMoney >= cost) updatePlayerMoney(-cost);
      updatePlayerAttribute('stamina', -12);
      updatePlayerAttribute('fan_connection', 4);
      updatePlayerFanCount(220 + Random().nextInt(160));
      song.listeningParty = 'fans';
      song.listeningPartyWeeks = 2;
      song.viralFactor = (song.viralFactor + 8).clamp(0.0, 100.0);
      weeklyHeadlines.add(
        'Fan listening party for "${song.title}" — the room was loud.',
      );
    } else {
      song.listeningParty = 'skip';
      song.listeningPartyWeeks = 0;
      if (!fromEvent) updatePlayerAttribute('discipline', 2);
      weeklyHeadlines.add(
        '${_player!.name} let "${song.title}" drop quiet.',
      );
    }
    notifyListeners();
    saveGame();
    return null;
  }

  String? playFestivalSlot({bool fromEvent = false}) {
    if (_player == null) return 'No player';
    if (!isFestivalSeason) return 'Festival circuit runs June–August';
    if (lastFestivalYearPlayed == year) {
      return 'You already played this summer';
    }
    if (!fromEvent) {
      final stamina = _player!.attributes['stamina'] ?? 0;
      if (stamina < 20) return 'Too tired for a festival set';
    }
    updatePlayerAttribute('stamina', -22);
    updatePlayerAttribute('popularity', 8);
    updatePlayerAttribute('performance', 4);
    updatePlayerAttribute('fan_connection', 3);
    final pay = 2500.0 + (_player!.labelTier.index * 1500);
    updatePlayerMoney(pay);
    updatePlayerFanCount(900 + (_player!.attributes['popularity'] ?? 10).round() * 8);
    _challenges?.updateProgress(ChallengeType.performShows, 1);
    if (playerSongs.isNotEmpty) {
      final best = playerSongs.reduce(
        (a, b) => a.weeklyListeners >= b.weeklyListeners ? a : b,
      );
      best.viralFactor = (best.viralFactor + 12).clamp(0.0, 100.0);
    }
    lastFestivalYearPlayed = year;
    weeklyHeadlines.add(
      '${_player!.name} owned the summer festival slot. Door \$${pay.toStringAsFixed(0)}.',
    );
    if (!fromEvent) {
      lastWeekEvents.add(GameEvent(
        id: 'festival_played_${year}_$weekOfMonth',
        title: 'Festival Set',
        description:
            'You took the exclusive summer slot. Crowds, cash, and a viral bump on your hottest track.',
        type: EventType.opportunity,
        severity: EventSeverity.high,
      ));
    }
    addPlayerXp(40);
    notifyListeners();
    saveGame();
    return null;
  }

  String? runPressInterview(String stance, {bool fromEvent = false}) {
    if (_player == null) return 'No player';
    if (!fromEvent) {
      if (pressCooldownWeeks > 0) {
        return 'Press is cooling off ($pressCooldownWeeks w)';
      }
      if ((_player!.attributes['popularity'] ?? 0) < 15) {
        return 'Need 15 popularity for a cover story';
      }
      if (hasPendingPress) {
        return 'Finish the press event first';
      }
    }

    final mag = pressMagazine;
    switch (stance) {
      case 'Play It Safe':
        updatePlayerAttribute('reputation', 7);
        updatePlayerAttribute('controversy', -4);
        updatePlayerAttribute('marketing', 4);
        updatePlayerFanCount(280);
        pressCoverWeeksRemaining = 2;
        weeklyHeadlines.add(
          '$mag ran a clean cover on ${_player!.name}. Reputation up.',
        );
        break;
      case 'Spill the Tea':
        updatePlayerAttribute('controversy', 12);
        updatePlayerAttribute('popularity', 6);
        updatePlayerAttribute('reputation', -6);
        updatePlayerAttribute('marketing', 3);
        updatePlayerFanCount(850);
        pressCoverWeeksRemaining = 2;
        if (playerSongs.isNotEmpty) {
          final best = playerSongs.reduce(
            (a, b) => a.weeklyListeners >= b.weeklyListeners ? a : b,
          );
          best.viralFactor = (best.viralFactor + 10).clamp(0.0, 100.0);
        }
        weeklyHeadlines.add(
          '$mag cover went messy. ${_player!.name} is everywhere — and so is the backlash.',
        );
        break;
      default:
        updatePlayerAttribute('discipline', 3);
        updatePlayerAttribute('happiness', -3);
        weeklyHeadlines.add(
          '${_player!.name} killed the $mag interview. No cover this cycle.',
        );
        break;
    }

    pressCooldownWeeks = 4;
    if (!fromEvent) {
      lastWeekEvents.add(GameEvent(
        id: 'press_done_${DateTime.now().millisecondsSinceEpoch}',
        title: '$mag: $stance',
        description: stance == 'Cancel'
            ? 'You walked. The editors will remember.'
            : 'The issue hits stands. Cover heat lasts two weeks.',
        type: EventType.opportunity,
        severity: EventSeverity.high,
      ));
    }
    addPlayerXp(22);
    notifyListeners();
    saveGame();
    return null;
  }

  Song? bestRadioPlugSong() {
    if (playerSongs.isEmpty) return null;
    final debut = playerSongs.where(inDebutWindow).toList();
    final pool = debut.isNotEmpty ? debut : playerSongs;
    return pool.reduce(
      (a, b) => a.weeklyListeners >= b.weeklyListeners ? a : b,
    );
  }

  String? runRadioInterview(String stance, {bool fromEvent = false}) {
    if (_player == null) return 'No player';
    if (!fromEvent) {
      if (radioInterviewCooldownWeeks > 0) {
        return 'Radio is cooling off ($radioInterviewCooldownWeeks w)';
      }
      if (playerSongs.isEmpty) return 'Release a song first';
      if ((_player!.attributes['popularity'] ?? 0) < 12) {
        return 'Need 12 popularity for a live slot';
      }
      if (hasPendingRadio) return 'Finish the radio event first';
    }

    final station = radioStation;
    final plug = bestRadioPlugSong();
    switch (stance) {
      case 'Perform Live':
        updatePlayerAttribute('stamina', -14);
        updatePlayerAttribute('performance', 5);
        updatePlayerAttribute('charisma', 3);
        updatePlayerAttribute('popularity', 4);
        updatePlayerFanCount(160 + Random().nextInt(120));
        radioLiveKind = 'perform';
        radioLiveSongId = '';
        radioLiveWeeksRemaining = 2;
        weeklyHeadlines.add(
          '${_player!.name} went live on $station. The session is in rotation.',
        );
        break;
      case 'Plug the Single':
        updatePlayerAttribute('stamina', -8);
        updatePlayerAttribute('marketing', 4);
        updatePlayerAttribute('charisma', 2);
        if (plug != null) {
          plug.viralFactor = (plug.viralFactor + 10).clamp(0.0, 100.0);
          if (plug.playlistWeeksRemaining < 2) {
            plug.playlistWeeksRemaining = 2;
          }
          radioLiveSongId = plug.id;
        }
        radioLiveKind = 'plug';
        radioLiveWeeksRemaining = 2;
        weeklyHeadlines.add(
          plug == null
              ? '$station let ${_player!.name} talk the catalog.'
              : '$station plugged "${plug.title}" after the interview.',
        );
        break;
      default:
        updatePlayerAttribute('happiness', -8);
        updatePlayerAttribute('reputation', -3);
        updatePlayerAttribute('controversy', 4);
        updatePlayerFanCount(-80);
        radioLiveKind = '';
        radioLiveSongId = '';
        radioLiveWeeksRemaining = 0;
        weeklyHeadlines.add(
          '${_player!.name} froze on $station. Clips are already out.',
        );
        break;
    }

    radioInterviewCooldownWeeks = 3;
    if (!fromEvent) {
      lastWeekEvents.add(GameEvent(
        id: 'radio_live_done_${DateTime.now().millisecondsSinceEpoch}',
        title: '$station: $stance',
        description: stance == 'Freeze'
            ? 'Dead air. The hosts moved on.'
            : 'The live hit is circulating for two weeks.',
        type: EventType.opportunity,
        severity: EventSeverity.high,
      ));
    }
    addPlayerXp(20);
    notifyListeners();
    saveGame();
    return null;
  }

  bool get isOnTour => (activeTour?.weeksRemaining ?? 0) > 0;

  String? bookTour(String packageId) {
    if (_player == null) return 'No player';
    if (isOnTour) {
      return 'Already on the ${activeTour!.name} (${activeTour!.weeksRemaining}w left)';
    }
    final pack = TourPackage.byId(packageId);
    if (pack == null) return 'Unknown tour';
    final pop = _player!.attributes['popularity'] ?? 0;
    if (pop < pack.popularityRequired) {
      return 'Need ${pack.popularityRequired} popularity';
    }
    if (_player!.labelTier.index < pack.minLabel.index) {
      return 'Need ${pack.minLabel.displayName} to book this tour';
    }
    final stamina = _player!.attributes['stamina'] ?? 0;
    if (stamina < pack.staminaCost) {
      return 'Too tired to hit the road';
    }
    activeTour = ActiveTour(
      packageId: pack.id,
      name: pack.name,
      weeksRemaining: pack.weeks,
      weeksTotal: pack.weeks,
    );
    weeklyHeadlines.add(
      '${_player!.name} booked the ${pack.name} — ${pack.weeks} weeks on the road.',
    );
    lastWeekEvents.add(GameEvent(
      id: 'tour_book_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Tour Booked: ${pack.name}',
      description:
          'First stop loads in next week. Expect merch spikes and a stamina hit each stop.',
      type: EventType.opportunity,
      severity: EventSeverity.medium,
    ));
    addPlayerXp(18);
    notifyListeners();
    saveGame();
    return null;
  }

  void _advanceTourWeek() {
    lastWeekTourPay = 0;
    final tour = activeTour;
    if (_player == null || tour == null || tour.weeksRemaining <= 0) {
      if (tour != null && tour.weeksRemaining <= 0) activeTour = null;
      return;
    }
    final pack = TourPackage.byId(tour.packageId);
    if (pack == null) {
      activeTour = null;
      return;
    }

    final city = tour.currentCity;
    final merch = pack.weeklyMerch + (playerFanCount * 0.09);
    final pay = pack.weeklyPay + merch;
    lastWeekTourPay = pay;
    updatePlayerMoney(pay);
    updatePlayerFanCount(pack.weeklyFans);
    updatePlayerAttribute('stamina', -pack.staminaCost);
    updatePlayerAttribute('performance', 1.2);
    updatePlayerAttribute('fan_connection', 0.8);
    _challenges?.updateProgress(ChallengeType.performShows, 1);

    weeklyHeadlines.add(
      '${_player!.name} played $city on the ${tour.name}. Merch \$${merch.toStringAsFixed(0)}.',
    );
    lastWeekEvents.add(GameEvent(
      id: 'tour_stop_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Tour Stop: $city',
      description:
          '${tour.name} night ${tour.weeksTotal - tour.weeksRemaining + 1}/${tour.weeksTotal}. '
          'Door \$${pack.weeklyPay.toStringAsFixed(0)} + merch \$${merch.toStringAsFixed(0)}. '
          'Stamina −${pack.staminaCost.toStringAsFixed(0)}.',
      type: EventType.opportunity,
      severity: EventSeverity.medium,
    ));

    tour.weeksRemaining--;
    tour.stopIndex++;
    if (tour.weeksRemaining <= 0) {
      updatePlayerAttribute('popularity', 3);
      updatePlayerAttribute('reputation', 2);
      lastWeekEvents.add(GameEvent(
        id: 'tour_wrap_${DateTime.now().millisecondsSinceEpoch}',
        title: '${tour.name} Wrapped',
        description:
            'The bus is home. Popularity and reputation ticked up from the run.',
        type: EventType.award,
        severity: EventSeverity.medium,
      ));
      weeklyHeadlines.add('${_player!.name} wrapped the ${tour.name}.');
      activeTour = null;
    }
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
      featuredArtistIds: [partner.id],
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

  String? dropDissTrack(String rivalId, {bool fromEvent = false}) {
    if (_player == null) return 'No player';
    if (!isRival(rivalId)) return 'That artist is not your rival';
    final rival = getArtistById(rivalId);
    if (rival == null) return 'Rival not found';
    if (dissCooldownWeeks > 0) {
      return 'Last diss is still circulating ($dissCooldownWeeks w)';
    }
    if (!fromEvent) {
      final stamina = _player!.attributes['stamina'] ?? 0;
      if (stamina < 16) return 'Too tired to cut a diss';
      if (playerMoney < 150) return 'Need \$150 for the session';
      if (hustlesThisWeek >= 2) return 'Already hustled enough this week';
      hustlesThisWeek++;
      updatePlayerMoney(-150);
      updatePlayerAttribute('stamina', -16);
    } else {
      updatePlayerAttribute('stamina', -10);
    }

    final quality = (((_player!.attributes['songwriting'] ?? 40) +
                (_player!.attributes['controversy'] ?? 10) +
                20) /
            2)
        .clamp(30.0, 96.0);
    final titles = [
      '${rival.name} Who?',
      'Receipts (${rival.name})',
      'Open Letter',
      'Clapback',
    ];
    final title = titles[Random().nextInt(titles.length)];
    worldSongs.add(Song(
      id: 'song_${DateTime.now().millisecondsSinceEpoch}_diss',
      title: title,
      artistId: _player!.id,
      popularityFactor: quality,
      viralFactor: (55 + Random().nextDouble() * 30).clamp(40.0, 98.0),
      salesPotential: (28 + Random().nextDouble() * 22).clamp(10.0, 80.0),
      genre: playerHomeGenre,
      isNewEntry: true,
    ));
    updatePlayerAttribute('controversy', 8);
    updatePlayerAttribute('popularity', 3);
    updatePlayerAttribute('reputation', -3);
    updateArtistAttribute(rival.id, 'reputation', -4);
    updateArtistAttribute(rival.id, 'controversy', 6);
    updatePlayerFanCount(220);
    addPlayerXp(28);
    _challenges?.updateProgress(ChallengeType.releaseSongs, 1);
    dissCooldownWeeks = 3;
    weeklyHeadlines.add(
      '${_player!.name} dropped a diss aimed at ${rival.name}.',
    );
    if (!fromEvent) {
      lastWeekEvents.add(GameEvent(
        id: 'diss_${rival.id}_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Diss Dropped: $title',
        description:
            'You clapped back at ${rival.name}. High viral, messy reputation.',
        type: EventType.rivalry,
        severity: EventSeverity.high,
      ));
    }
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

  void _queueAwardAfterparty() {
    if (_player == null || worldSongs.isEmpty) return;
    final invited = playerSongs.isNotEmpty ||
        (_player!.attributes['popularity'] ?? 0) >= 12;
    if (!invited) return;
    if (lastWeekEvents.any((e) => e.id.startsWith('award_afterparty::'))) {
      return;
    }
    final won = lastWeekEvents.any(
      (e) =>
          e.type == EventType.award &&
          e.id.startsWith('year_award_') &&
          e.id.contains(_player!.id),
    );
    lastWeekEvents.add(GameEvent(
      id: 'award_afterparty::$year',
      title: won ? "Winner's Afterparty" : 'Awards Afterparty Invite',
      description: won
          ? 'You walked off stage with hardware. The afterparty is packed with A&Rs, rivals, and cameras. How do you close the night?'
          : "You didn't take home a trophy, but every label is still in the room. Network, go scorched-earth, or slip out early?",
      type: EventType.opportunity,
      severity: EventSeverity.high,
      choices: const ['Work the Room', 'Go Nuclear', 'Slip Out Early'],
      choiceOutcomes: const {
        'Work the Room': {
          'networking': 8,
          'reputation': 4,
          'charisma': 3,
          'stamina': -14,
          '_money': -180,
          '_fans': 180,
        },
        'Go Nuclear': {
          'controversy': 12,
          'popularity': 7,
          'reputation': -6,
          'happiness': -4,
          'stamina': -18,
          '_money': -420,
          '_fans': 420,
        },
        'Slip Out Early': {
          'stamina': 16,
          'happiness': 6,
          'discipline': 3,
        },
      },
    ));
  }

  void _resolveAfterparty(String choice) {
    if (_player == null) return;
    if (choice == 'Work the Room') {
      afterpartyBuzz = 'network';
      afterpartyBuzzWeeks = 3;
      weeklyHeadlines.add(
        '${_player!.name} closed awards night working every table.',
      );
      final npcs = worldArtists.where((a) => a.id != _player!.id).toList();
      if (npcs.isNotEmpty) {
        final a = npcs[Random().nextInt(npcs.length)];
        updateArtistAttribute(a.id, 'networking', 2);
        weeklyHeadlines.add(
          '${a.name} clocked the handshake. A&R chatter follows.',
        );
      }
    } else if (choice == 'Go Nuclear') {
      afterpartyBuzz = 'scandal';
      afterpartyBuzzWeeks = 2;
      weeklyHeadlines.add(
        '${_player!.name} turned the afterparty into a headline.',
      );
    } else {
      afterpartyBuzz = '';
      afterpartyBuzzWeeks = 0;
      weeklyHeadlines.add(
        '${_player!.name} skipped the afterparty and slept.',
      );
    }
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

    if (isFestivalSeason) {
      for (final g in availableGenres) {
        final bump = (g == 'Pop' || g == 'Electronic' || g == 'Hip-Hop')
            ? 10.0
            : 4.0;
        genreHeat[g] = ((genreHeat[g] ?? 40) + bump).clamp(15.0, 100.0);
      }
      trendingGenre = availableGenres.reduce(
        (a, b) => (genreHeat[a] ?? 0) >= (genreHeat[b] ?? 0) ? a : b,
      );
    }
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
          featuredArtistIds: [artist2.id],
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

    // Rival truce offer (~20% if rivals exist)
    if (rivalIds.isNotEmpty &&
        rivalTruceCooldownWeeks == 0 &&
        !hasPendingRivalTruce &&
        rng.nextDouble() < 0.20) {
      rivalTruceRivalId = rivalIds[rng.nextInt(rivalIds.length)];
      final rival = getArtistById(rivalTruceRivalId);
      lastWeekEvents.add(GameEvent(
        id: 'rival_truce::$rivalTruceRivalId',
        title: 'Truce Offer: ${rival?.name ?? 'A rival'}',
        description:
            '${rival?.name ?? 'A rival'} wants to talk. Form an alliance, spy, or refuse.',
        type: EventType.rivalry,
        severity: EventSeverity.high,
        choices: const ['Form Alliance', 'Spy on Them', 'Refuse Truce'],
        choiceOutcomes: const {},
      ));
    }

    // Documentary crew follow (~18% if notable)
    if ((_player!.attributes['popularity'] ?? 0) >= 20 &&
        documentaryCooldownWeeks == 0 &&
        !hasPendingDocumentary &&
        rng.nextDouble() < 0.18) {
      documentaryCrewName = _randomDocCrewName();
      lastWeekEvents.add(GameEvent(
        id: 'doc_crew::$year-$month-$weekOfMonth',
        title: '$documentaryCrewName Wants Access',
        description:
            '$documentaryCrewName wants to follow your rise. Grant access, limit privacy, or deny.',
        type: EventType.opportunity,
        severity: EventSeverity.high,
        choices: const ['Grant Full Access', 'Limit Privacy', 'Deny Crew'],
        choiceOutcomes: const {},
      ));
    }

    // Therapy podcast invite (~17% if stressed or famous)
    final pop = _player!.attributes['popularity'] ?? 0;
    final controversy = _player!.attributes['controversy'] ?? 0;
    if ((pop >= 18 || controversy >= 8) &&
        therapyPodcastCooldownWeeks == 0 &&
        !hasPendingTherapyPodcast &&
        rng.nextDouble() < 0.17) {
      therapyPodcastName = _randomTherapyPodcastName();
      lastWeekEvents.add(GameEvent(
        id: 'therapy_pod::$year-$month-$weekOfMonth',
        title: '$therapyPodcastName Invite',
        description:
            '$therapyPodcastName wants you for a therapy-style episode. Open up, deflect, or cancel.',
        type: EventType.opportunity,
        severity: EventSeverity.medium,
        choices: const ['Open Up', 'Deflect', 'Cancel Appearance'],
        choiceOutcomes: const {},
      ));
    }

    // Surprise collab DM (~18% if charting)
    if (pop >= 22 &&
        playerSongs.isNotEmpty &&
        collabDmCooldownWeeks == 0 &&
        !hasPendingCollabDm &&
        rng.nextDouble() < 0.18) {
      final collabArtist = _pickCollabDmArtist();
      if (collabArtist != null) {
        collabDmArtistId = collabArtist.id;
        lastWeekEvents.add(GameEvent(
          id: 'collab_dm::${collabArtist.id}',
          title: 'Collab DM: ${collabArtist.name}',
          description:
              '${collabArtist.name} slid into your DMs. Accept, ghost, or leak a teaser.',
          type: EventType.collaboration,
          severity: EventSeverity.high,
          choices: const ['Accept Collab', 'Ghost Them', 'Leak Teaser'],
          choiceOutcomes: const {},
        ));
      }
    }

    // Stalker fan incident (~16%)
    if ((pop >= 25 || playerFanCount >= 800) &&
        stalkerFanCooldownWeeks == 0 &&
        !hasPendingStalkerFan &&
        rng.nextDouble() < 0.16) {
      lastWeekEvents.add(GameEvent(
        id: 'stalker_fan::$year-$month-$weekOfMonth',
        title: 'Stalker Fan Incident',
        description:
            'A fan crossed the line. Restraining order, soft block, or engage?',
        type: EventType.scandal,
        severity: EventSeverity.high,
        choices: const ['Restraining Order', 'Soft Block', 'Engage'],
        choiceOutcomes: const {},
      ));
    }

    // Vinyl / merch drop (~18%)
    if (pop >= 20 &&
        merchDropCooldownWeeks == 0 &&
        !hasPendingMerchDrop &&
        rng.nextDouble() < 0.18) {
      lastWeekEvents.add(GameEvent(
        id: 'merch_drop::$year-$month-$weekOfMonth',
        title: 'Merch Drop Window',
        description:
            'Warehouse is ready. Premium drop, mass market, or skip?',
        type: EventType.opportunity,
        severity: EventSeverity.medium,
        choices: const ['Premium Drop', 'Mass Market', 'Skip Drop'],
        choiceOutcomes: const {},
      ));
    }

    // Tour bus breakdown (~15%)
    if (pop >= 15 &&
        tourBusCooldownWeeks == 0 &&
        !hasPendingTourBus &&
        rng.nextDouble() < 0.15) {
      lastWeekEvents.add(GameEvent(
        id: 'tour_bus::$year-$month-$weekOfMonth',
        title: 'Tour Bus Breakdown',
        description:
            'The bus died on the highway. Pay for fix, DIY, or cancel dates?',
        type: EventType.opportunity,
        severity: EventSeverity.medium,
        choices: const ['Pay for Fix', 'DIY Repair', 'Cancel Dates'],
        choiceOutcomes: const {},
      ));
    }

    // Awards campaign night (~14%)
    if (pop >= 30 &&
        awardsCampCooldownWeeks == 0 &&
        !hasPendingAwardsCamp &&
        rng.nextDouble() < 0.14) {
      lastWeekEvents.add(GameEvent(
        id: 'awards_camp::$year-$month-$weekOfMonth',
        title: 'Awards Campaign Night',
        description:
            'Tables are open. Full campaign, keep it chill, or skip?',
        type: EventType.opportunity,
        severity: EventSeverity.high,
        choices: const ['Full Campaign', 'Keep It Chill', 'Skip Night'],
        choiceOutcomes: const {},
      ));
    }

    // Genre pivot rumor (~17%)
    if (pop >= 18 &&
        genrePivotCooldownWeeks == 0 &&
        !hasPendingGenrePivot &&
        rng.nextDouble() < 0.17) {
      lastWeekEvents.add(GameEvent(
        id: 'genre_pivot::$year-$month-$weekOfMonth',
        title: 'Genre Pivot Rumor',
        description:
            'Blogs say you are switching lanes. Lean in, deny, or double down?',
        type: EventType.opportunity,
        severity: EventSeverity.medium,
        choices: const ['Lean Into It', 'Deny the Rumor', 'Double Down'],
        choiceOutcomes: const {},
      ));
    }

    // Arena support slot (~16%)
    if (pop >= 28 &&
        arenaSlotCooldownWeeks == 0 &&
        !hasPendingArenaSlot &&
        rng.nextDouble() < 0.16) {
      lastWeekEvents.add(GameEvent(
        id: 'arena_slot::$year-$month-$weekOfMonth',
        title: 'Arena Support Slot',
        description:
            'An arena opener opened up. Take it, hold for headliner, or pass?',
        type: EventType.opportunity,
        severity: EventSeverity.high,
        choices: const ['Take Support Slot', 'Hold for Headliner', 'Pass'],
        choiceOutcomes: const {},
      ));
    }

    // Fan theory rabbit hole (~18%)
    if ((pop >= 16 || playerFanCount >= 500) &&
        fanTheoryCooldownWeeks == 0 &&
        !hasPendingFanTheory &&
        rng.nextDouble() < 0.18) {
      lastWeekEvents.add(GameEvent(
        id: 'fan_theory::$year-$month-$weekOfMonth',
        title: 'Fan Theory Rabbit Hole',
        description:
            'A theory is trending. Confirm, deny, or feed it?',
        type: EventType.opportunity,
        severity: EventSeverity.medium,
        choices: const ['Confirm Theory', 'Deny Theory', 'Feed the Theory'],
        choiceOutcomes: const {},
      ));
    }

    // Social blacklist rumor (~15%)
    if ((controversy >= 10 || pop >= 25) &&
        blacklistCooldownWeeks == 0 &&
        !hasPendingBlacklist &&
        rng.nextDouble() < 0.15) {
      lastWeekEvents.add(GameEvent(
        id: 'blacklist_rumor::$year-$month-$weekOfMonth',
        title: 'Social Blacklist Rumor',
        description:
            'Whispers say you are blacklisted. Address it, ignore it, or clap back?',
        type: EventType.scandal,
        severity: EventSeverity.high,
        choices: const ['Address It', 'Ignore It', 'Clap Back'],
        choiceOutcomes: const {},
      ));
    }

    // Comeback album concept (~12%)
    final weeksDebut = (_player!.attributes['weeksSinceDebut'] ?? 0);
    if ((pop >= 35 || weeksDebut >= 40) &&
        comebackCooldownWeeks == 0 &&
        !hasPendingComeback &&
        rng.nextDouble() < 0.12) {
      lastWeekEvents.add(GameEvent(
        id: 'comeback_concept::$year-$month-$weekOfMonth',
        title: 'Comeback Album Concept',
        description:
            'A-list writers want a concept. Intimate, maximalist, or delay?',
        type: EventType.opportunity,
        severity: EventSeverity.high,
        choices: const [
          'Intimate Concept',
          'Maximalist Concept',
          'Delay Project'
        ],
        choiceOutcomes: const {},
      ));
    }

    // Charity single push (~16%)
    if (pop >= 22 &&
        charityCooldownWeeks == 0 &&
        !hasPendingCharity &&
        rng.nextDouble() < 0.16) {
      lastWeekEvents.add(GameEvent(
        id: 'charity_single::$year-$month-$weekOfMonth',
        title: 'Charity Single Push',
        description:
            'A cause wants your single. Donate proceeds, match donations, or skip?',
        type: EventType.opportunity,
        severity: EventSeverity.medium,
        choices: const ['Donate Proceeds', 'Match Donations', 'Skip Charity'],
        choiceOutcomes: const {},
      ));
    }


    // Chart streak wager (~22% if charting)
    final wagerRank = bestPlayerChartRank;
    if (wagerRank != null &&
        wagerRank <= 25 &&
        chartWagerCooldownWeeks == 0 &&
        !hasPendingChartWager &&
        rng.nextDouble() < 0.22) {
      final song = _pickChartWagerSong();
      if (song != null) {
        chartWagerSongId = song.id;
        lastWeekEvents.add(GameEvent(
          id: 'chart_wager::$year-$month-$weekOfMonth',
          title: 'Chart Streak Wager',
          description:
              '"${song.title}" is #$wagerRank. Double down, protect the streak, or sit out.',
          type: EventType.opportunity,
          severity: EventSeverity.high,
          choices: const [
            'Double Down',
            'Protect the Streak',
            'Sit Out',
          ],
          choiceOutcomes: const {},
        ));
      }
    }

    // Brand sponsorship pitch (~20% if marketable)
    if ((_player!.attributes['popularity'] ?? 0) >= 25 &&
        brandDealCooldownWeeks == 0 &&
        !hasPendingBrandDeal &&
        rng.nextDouble() < 0.20) {
      brandSponsorName = _randomBrandName();
      lastWeekEvents.add(GameEvent(
        id: 'brand_deal::$year-$month-$weekOfMonth',
        title: '$brandSponsorName Sponsorship',
        description:
            '$brandSponsorName wants your face on a campaign. Take it, negotiate, or decline.',
        type: EventType.opportunity,
        severity: EventSeverity.high,
        choices: const ['Take the Deal', 'Negotiate', 'Decline'],
        choiceOutcomes: const {},
      ));
    }

    // Viral dance challenge (~25% if you have heat)
    if (playerSongs.isNotEmpty &&
        danceChallengeCooldownWeeks == 0 &&
        !hasPendingDanceChallenge &&
        ((_player!.attributes['popularity'] ?? 0) >= 15 ||
            playerSongs.any((s) => s.viralFactor >= 35)) &&
        rng.nextDouble() < 0.25) {
      final trendSong = _pickDanceTrendSong();
      if (trendSong != null) {
        danceChallengeSongId = trendSong.id;
        lastWeekEvents.add(GameEvent(
          id: 'dance_challenge::$year-$month-$weekOfMonth',
          title: 'Viral Dance Challenge',
          description:
              'A dance is blowing up to "${trendSong.title}". Join it, mock it, or ignore.',
          type: EventType.opportunity,
          severity: EventSeverity.high,
          choices: const ['Join the Trend', 'Mock It', 'Ignore'],
          choiceOutcomes: const {},
        ));
      }
    }

    // Superfan meet & greet (~22% if fanbase exists)
    if ((fanClubFounded || playerFanCount >= 400) &&
        meetGreetCooldownWeeks == 0 &&
        !hasPendingMeetGreet &&
        rng.nextDouble() < 0.22) {
      lastWeekEvents.add(GameEvent(
        id: 'meet_greet::$year-$month-$weekOfMonth',
        title: 'Superfan Meet & Greet',
        description:
            'Your core fans want a floor session. Charge tickets, do it free, or skip.',
        type: EventType.opportunity,
        severity: EventSeverity.medium,
        choices: const ['Charge Tickets', 'Free Meetup', 'Skip'],
        choiceOutcomes: const {},
      ));
    }

    // Mentor cosign (~18% if rising)
    if ((_player!.attributes['popularity'] ?? 0) >= 18 &&
        playerSongs.isNotEmpty &&
        mentorCosignCooldownWeeks == 0 &&
        !hasPendingMentorCosign &&
        rng.nextDouble() < 0.18) {
      final mentor = _pickMentorNpc();
      if (mentor != null) {
        mentorCosignArtistId = mentor.id;
        lastWeekEvents.add(GameEvent(
          id: 'mentor_cosign::${mentor.id}',
          title: 'Mentor Cosign: ${mentor.name}',
          description:
              '${mentor.name} noticed your run. Drop a feature verse, take studio advice, or pass.',
          type: EventType.collaboration,
          severity: EventSeverity.high,
          choices: const ['Feature Verse', 'Take Advice', 'Pass'],
          choiceOutcomes: const {},
        ));
      }
    }

    // Producer credit fight (~20% if you have releases)
    if (playerSongs.isNotEmpty &&
        producerBeefCooldownWeeks == 0 &&
        !hasPendingProducerBeef &&
        rng.nextDouble() < 0.20) {
      beefProducerName = _randomProducerName();
      final target = playerSongs.reduce(
        (a, b) => a.weeklyListeners >= b.weeklyListeners ? a : b,
      );
      beefSongId = target.id;
      lastWeekEvents.add(GameEvent(
        id: 'producer_beef::$year-$month-$weekOfMonth',
        title: 'Producer Credit Fight',
        description:
            '$beefProducerName says they made "${target.title}" and wants a public credit. Apologize, clap back, or buy silence.',
        type: EventType.scandal,
        severity: EventSeverity.high,
        choices: const ['Apologize', 'Clap Back', 'Buy Silence'],
        choiceOutcomes: const {},
      ));
    }

    // Unreleased demo leak (~22% if catalog exists)
    if (playerSongs.length >= 2 &&
        demoLeakCooldownWeeks == 0 &&
        !hasPendingDemoLeak &&
        rng.nextDouble() < 0.22) {
      leakedDemoTitle = _randomDemoTitle();
      lastWeekEvents.add(GameEvent(
        id: 'demo_leak::$year-$month-$weekOfMonth',
        title: 'Unreleased Demo Leaked',
        description:
            'Someone posted "$leakedDemoTitle" online. Pay to kill it, lean in and ride the buzz, or ignore it.',
        type: EventType.scandal,
        severity: EventSeverity.high,
        choices: const ['Pay to Kill', 'Lean In', 'Ignore'],
        choiceOutcomes: const {},
      ));
    }

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

    // Summer circuit: one exclusive slot per year (June–August)
    if (isFestivalSeason &&
        month == 6 &&
        weekOfMonth == 1 &&
        lastFestivalYearPlayed != year) {
      lastWeekEvents.add(GameEvent(
        id: 'summer_festival::$year',
        title: 'Summer Festival Circuit',
        description:
            'The circuit is open through August. One exclusive slot this year — take it or sit it out.',
        type: EventType.opportunity,
        severity: EventSeverity.high,
        choices: const ['Book the Slot', 'Sit This Summer'],
        choiceOutcomes: const {
          'Sit This Summer': {
            'discipline': 2,
            'happiness': -2,
          },
        },
      ));
    }

    // Off-season regional showcase (~18%)
    if (!isFestivalSeason && rng.nextDouble() < 0.18) {
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

    // Live radio interview (~30% if eligible)
    if (canSitRadio && rng.nextDouble() < 0.30) {
      final plug = bestRadioPlugSong();
      lastWeekEvents.add(GameEvent(
        id: 'radio_live::$year-$month-$weekOfMonth',
        title: '$radioStation Live Slot',
        description: plug == null
            ? '$radioStation wants you live. Perform, freeze, or talk the catalog.'
            : '$radioStation wants you live. Perform a session, freeze on air, or plug "${plug.title}".',
        type: EventType.opportunity,
        severity: EventSeverity.high,
        choices: const ['Perform Live', 'Plug the Single', 'Freeze'],
        choiceOutcomes: const {},
      ));
    }

    // Press week / magazine cover (~28% if eligible)
    if (canSitPress && rng.nextDouble() < 0.28) {
      lastWeekEvents.add(GameEvent(
        id: 'press_week::$year-$month-$weekOfMonth',
        title: '$pressMagazine Cover Interview',
        description:
            '$pressMagazine wants you on the cover. Play it safe, spill tea, or cancel.',
        type: EventType.opportunity,
        severity: EventSeverity.high,
        choices: const ['Play It Safe', 'Spill the Tea', 'Cancel'],
        choiceOutcomes: const {},
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

    if (event.type == EventType.rivalry &&
        choice == 'Drop a Diss' &&
        event.id.startsWith('rival_overtake::')) {
      final rivalId = event.id.substring('rival_overtake::'.length);
      if (rivalId.isNotEmpty) {
        dropDissTrack(rivalId, fromEvent: true);
      }
    }

    if (event.id.startsWith('summer_festival::') &&
        choice == 'Book the Slot') {
      playFestivalSlot(fromEvent: true);
    }

    if (event.id.startsWith('press_week::')) {
      runPressInterview(choice, fromEvent: true);
    }

    if (event.id.startsWith('radio_live::')) {
      runRadioInterview(choice, fromEvent: true);
    }

    if (event.id.startsWith('award_afterparty::')) {
      _resolveAfterparty(choice);
    }

    if (event.id.startsWith('listen_party::')) {
      final songId = event.id.substring('listen_party::'.length);
      runListeningParty(songId, choice, fromEvent: true);
    }

    if (event.id.startsWith('demo_leak::')) {
      resolveDemoLeak(choice, fromEvent: true);
    }

    if (event.id.startsWith('producer_beef::')) {
      resolveProducerBeef(choice, fromEvent: true);
    }

    if (event.id.startsWith('mentor_cosign::')) {
      final mentorId = event.id.substring('mentor_cosign::'.length);
      if (mentorId.isNotEmpty) mentorCosignArtistId = mentorId;
      resolveMentorCosign(choice, fromEvent: true);
    }

    if (event.id.startsWith('meet_greet::')) {
      resolveMeetGreet(choice, fromEvent: true);
    }

    if (event.id.startsWith('dance_challenge::')) {
      resolveDanceChallenge(choice, fromEvent: true);
    }

    if (event.id.startsWith('brand_deal::')) {
      resolveBrandSponsorship(choice, fromEvent: true);
    }

    if (event.id.startsWith('chart_wager::')) {
      resolveChartWager(choice, fromEvent: true);
    }

    if (event.id.startsWith('rival_truce::')) {
      final rivalId = event.id.substring('rival_truce::'.length);
      if (rivalId.isNotEmpty) rivalTruceRivalId = rivalId;
      resolveRivalTruce(choice, fromEvent: true);
    }

    if (event.id.startsWith('doc_crew::')) {
      resolveDocumentaryCrew(choice, fromEvent: true);
    }

    if (event.id.startsWith('therapy_pod::')) {
      resolveTherapyPodcast(choice, fromEvent: true);
    }

    if (event.id.startsWith('collab_dm::')) {
      final artistId = event.id.substring('collab_dm::'.length);
      if (artistId.isNotEmpty) collabDmArtistId = artistId;
      resolveCollabDm(choice, fromEvent: true);
    }

    if (event.id.startsWith('stalker_fan::')) {
      resolveStalkerFan(choice, fromEvent: true);
    }

    if (event.id.startsWith('merch_drop::')) {
      resolveMerchDrop(choice, fromEvent: true);
    }

    if (event.id.startsWith('tour_bus::')) {
      resolveTourBus(choice, fromEvent: true);
    }

    if (event.id.startsWith('awards_camp::')) {
      resolveAwardsCamp(choice, fromEvent: true);
    }

    if (event.id.startsWith('genre_pivot::')) {
      resolveGenrePivot(choice, fromEvent: true);
    }

    if (event.id.startsWith('arena_slot::')) {
      resolveArenaSlot(choice, fromEvent: true);
    }

    if (event.id.startsWith('fan_theory::')) {
      resolveFanTheory(choice, fromEvent: true);
    }

    if (event.id.startsWith('blacklist_rumor::')) {
      resolveBlacklistRumor(choice, fromEvent: true);
    }

    if (event.id.startsWith('comeback_concept::')) {
      resolveComebackConcept(choice, fromEvent: true);
    }

    if (event.id.startsWith('charity_single::')) {
      resolveCharitySingle(choice, fromEvent: true);
    }


    event.selectedChoice = choice;
    event.resolved = true;
    notifyListeners();
    saveGame();
    return true;
  }


  void _queueRivalClapback(String rivalId, String why) {
    if (dissCooldownWeeks > 0) return;
    if (_rivalTruceBlocks(rivalId)) return;
    if (lastWeekEvents.any((e) => e.id.startsWith('rival_overtake::'))) return;
    final rival = getArtistById(rivalId);
    lastWeekEvents.add(GameEvent(
      id: 'rival_overtake::$rivalId',
      title: '${rival?.name ?? 'A rival'} Is Ahead',
      description: '$why Drop a diss, stay quiet, or tip the hat?',
      type: EventType.rivalry,
      severity: EventSeverity.high,
      choices: const ['Drop a Diss', 'Stay Quiet', 'Tip the Hat'],
      choiceOutcomes: const {
        'Drop a Diss': {
          'controversy': 4,
          'popularity': 2,
        },
        'Stay Quiet': {
          'discipline': 4,
          'happiness': -3,
        },
        'Tip the Hat': {
          'reputation': 5,
          'fan_connection': 3,
          'happiness': 2,
        },
      },
    ));
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
      if (!song.released) {
        song.weeklyListeners = 0;
        continue;
      }
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
      if (song.playlistWeeksRemaining > 0) {
        song.playlistWeeksRemaining--;
      }
      if (song.listeningPartyWeeks > 0) {
        song.listeningPartyWeeks--;
      }
    }
    if (pressCoverWeeksRemaining > 0) {
      pressCoverWeeksRemaining--;
    }
    if (streetTeamWeeksRemaining > 0) {
      streetTeamWeeksRemaining--;
    }
    if (afterpartyBuzzWeeks > 0) {
      afterpartyBuzzWeeks--;
      if (afterpartyBuzzWeeks == 0) afterpartyBuzz = '';
    }
    if (radioLiveWeeksRemaining > 0) {
      radioLiveWeeksRemaining--;
      if (radioLiveWeeksRemaining == 0) {
        radioLiveKind = '';
        radioLiveSongId = '';
      }
    }
    if (demoLeakHeatWeeks > 0) {
      demoLeakHeatWeeks--;
      if (demoLeakHeatWeeks == 0) demoLeakKind = '';
    }
    if (producerCreditWeeks > 0) {
      producerCreditWeeks--;
      if (producerCreditWeeks == 0) {
        producerBeefKind = '';
        beefSongId = '';
      }
    }
    if (mentorCosignWeeks > 0) {
      mentorCosignWeeks--;
      if (mentorCosignWeeks == 0) {
        mentorCosignKind = '';
        mentorCosignSongId = '';
      }
    }
    if (meetGreetWeeks > 0) {
      meetGreetWeeks--;
      if (meetGreetWeeks == 0) meetGreetKind = '';
    }
    if (danceChallengeWeeks > 0) {
      danceChallengeWeeks--;
      if (danceChallengeWeeks == 0) {
        danceChallengeKind = '';
        danceChallengeSongId = '';
      }
    }
    if (brandDealWeeks > 0) {
      brandDealWeeks--;
      if (brandDealWeeks == 0) {
        brandDealKind = '';
        brandSponsorName = '';
      }
    }
    if (chartWagerWeeks > 0) {
      chartWagerWeeks--;
      if (chartWagerWeeks == 0) {
        chartWagerKind = '';
        chartWagerSongId = '';
        chartWagerStartRank = 0;
      }
    }
    if (rivalTruceWeeks > 0) {
      rivalTruceWeeks--;
      if (rivalTruceWeeks == 0) {
        rivalTruceKind = '';
        rivalTruceRivalId = '';
      }
    }
    if (documentaryWeeks > 0) {
      documentaryWeeks--;
      if (documentaryWeeks == 0) {
        documentaryKind = '';
        documentaryCrewName = '';
      }
    }
    if (therapyPodcastWeeks > 0) {
      therapyPodcastWeeks--;
      if (therapyPodcastWeeks == 0) {
        therapyPodcastKind = '';
        therapyPodcastName = '';
      }
    }
    if (collabDmWeeks > 0) {
      collabDmWeeks--;
      if (collabDmWeeks == 0) {
        collabDmKind = '';
        collabDmSongId = '';
        collabDmArtistId = '';
      }
    }

    if (stalkerFanWeeks > 0) {
      stalkerFanWeeks--;
      if (stalkerFanWeeks == 0) {
        stalkerFanKind = '';
      }
    }
    if (merchDropWeeks > 0) {
      merchDropWeeks--;
      if (merchDropWeeks == 0) {
        merchDropKind = '';
      }
    }
    if (tourBusWeeks > 0) {
      tourBusWeeks--;
      if (tourBusWeeks == 0) {
        tourBusKind = '';
      }
    }
    if (awardsCampWeeks > 0) {
      awardsCampWeeks--;
      if (awardsCampWeeks == 0) {
        awardsCampKind = '';
      }
    }
    if (genrePivotWeeks > 0) {
      genrePivotWeeks--;
      if (genrePivotWeeks == 0) {
        genrePivotKind = '';
      }
    }
    if (arenaSlotWeeks > 0) {
      arenaSlotWeeks--;
      if (arenaSlotWeeks == 0) {
        arenaSlotKind = '';
      }
    }
    if (fanTheoryWeeks > 0) {
      fanTheoryWeeks--;
      if (fanTheoryWeeks == 0) {
        fanTheoryKind = '';
      }
    }
    if (blacklistWeeks > 0) {
      blacklistWeeks--;
      if (blacklistWeeks == 0) {
        blacklistKind = '';
      }
    }
    if (comebackWeeks > 0) {
      comebackWeeks--;
      if (comebackWeeks == 0) {
        comebackKind = '';
      }
    }
    if (charityWeeks > 0) {
      charityWeeks--;
      if (charityWeeks == 0) {
        charityKind = '';
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
                _queueRivalClapback(
                  rivalId,
                  '"${rivalSong.title}" jumped ahead of "${playerSong.title}" (#$rivalRank vs #$currentRank).',
                );
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

        if (chartWagerKind == 'double' &&
            chartWagerWeeks > 0 &&
            playerSong.id == chartWagerSongId &&
            chartWagerStartRank > 0 &&
            currentRank > chartWagerStartRank + 4) {
          updatePlayerAttribute('controversy', 4);
          updatePlayerAttribute('happiness', -4);
          weeklyHeadlines.add(
            'The "${playerSong.title}" wager is bleeding — rank slipped to #$currentRank.',
          );
          chartWagerKind = 'protect';
        }
      }
    }

    if (_player != null &&
        dissCooldownWeeks == 0 &&
        !lastWeekEvents.any((e) => e.id.startsWith('rival_overtake::'))) {
      final playerBest = bestChartRankFor(_player!.id);
      for (final rival in rivals) {
        final rivalBest = bestChartRankFor(rival.id);
        if (rivalBest != null &&
            rivalBest <= 20 &&
            (playerBest == null || rivalBest < playerBest)) {
          _queueRivalClapback(
            rival.id,
            '${rival.name} is sitting at #$rivalBest'
            '${playerBest == null ? ' while you are off-chart' : ' (you #$playerBest)'}.',
          );
          break;
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
      if (isOnRoster(artist.id)) continue;

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
        song.released &&
        song.artistId != 'player' &&
        !isOnRoster(song.artistId) &&
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

    songsToConsider = List<Song>.from(
      songsToConsider.where((song) => song.released),
    )..sort(_compareByChartScore);
    return songsToConsider.take(limit).toList();
  }

  double getArtistCumulativeStreams(String artistId) {
    return worldSongs.where((song) => song.released && song.creditsArtist(artistId)).fold(0.0, (sum, song) => sum + song.totalStreams);
  }

  List<Artist> getTopArtists(int limit) {
    // Calculate cumulative streams for each artist
    Map<String, double> artistStreams = {};
    for (var song in worldSongs) {
      if (!song.released) continue;
      artistStreams.update(song.artistId, (value) => value + song.totalStreams, ifAbsent: () => song.totalStreams);
      for (final feat in song.featuredArtistIds) {
        artistStreams.update(feat, (value) => value + song.totalStreams * 0.4, ifAbsent: () => song.totalStreams * 0.4);
      }
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

  double ghostwriterFee() {
    final tier = _player?.labelTier.index ?? 0;
    return 700.0 + (tier * 250);
  }

  double sampleClearanceFee() {
    final tier = _player?.labelTier.index ?? 0;
    return 900.0 + (tier * 400);
  }

  double songReleaseCost({
    required bool marketingBoost,
    required StudioFinish finish,
    bool ghostwriter = false,
    bool sampleClearance = false,
  }) {
    final base = marketingBoost ? 1000.0 : 500.0;
    final ghost = ghostwriter ? ghostwriterFee() : 0.0;
    final sample = sampleClearance ? sampleClearanceFee() : 0.0;
    return (base + finish.extraCost + ghost + sample).clamp(150.0, 12000.0);
  }

  void _checkUnclearedSamples() {
    if (_player == null) return;
    for (final song in playerSongs) {
      if (!song.usesSample || song.sampleCleared || song.sampleTakedown) {
        continue;
      }
      final chance =
          (0.10 + song.weeksSinceRelease * 0.03).clamp(0.10, 0.36);
      if (Random().nextDouble() > chance) continue;
      song.sampleTakedown = true;
      song.playlistWeeksRemaining = 0;
      song.videoWeeksRemaining = 0;
      song.viralFactor = (song.viralFactor * 0.35).clamp(0.0, 100.0);
      song.salesPotential = (song.salesPotential * 0.4).clamp(0.0, 100.0);
      updatePlayerAttribute('reputation', -5);
      updatePlayerAttribute('controversy', 8);
      weeklyHeadlines.add(
        'Takedown: "${song.title}" got pulled over an uncleared sample.',
      );
      lastWeekEvents.add(GameEvent(
        id: 'sample_takedown_${song.id}_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Sample Takedown: ${song.title}',
        description:
            'Rights holders yanked "${song.title}" off DSPs. Streams collapse. Clear next time.',
        type: EventType.scandal,
        severity: EventSeverity.high,
      ));
    }
  }

  String? clearSongSample(String songId) {
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
    if (!song.usesSample) return 'That track has no sample';
    if (song.sampleTakedown) return 'Already taken down — too late to clear';
    if (song.sampleCleared) return 'Sample already cleared';
    final fee = sampleClearanceFee();
    if (playerMoney < fee) {
      return 'Need \$${fee.toStringAsFixed(0)} to clear the sample';
    }
    updatePlayerMoney(-fee);
    song.sampleCleared = true;
    song.viralFactor = (song.viralFactor + 6).clamp(0.0, 100.0);
    weeklyHeadlines.add(
      'Sample on "${song.title}" is cleared. The hook stays up.',
    );
    notifyListeners();
    saveGame();
    return null;
  }

  /// Chance a hired pen leaks. Higher controversy = sloppier NDAs.
  /// Returns true if the leak hit so UI can ask how to spin it.
  bool resolveGhostwriterLeak(Song song) {
    if (!song.ghostwritten || _player == null) return false;
    final controversy = _player!.attributes['controversy'] ?? 0;
    final chance = (0.18 + controversy / 350).clamp(0.18, 0.42);
    if (Random().nextDouble() > chance) {
      weeklyHeadlines.add(
        '"${song.title}" was penned quietly. The room stayed sealed.',
      );
      return false;
    }
    updatePlayerAttribute('reputation', -8);
    updatePlayerAttribute('controversy', 12);
    updatePlayerAttribute('happiness', -4);
    weeklyHeadlines.add(
      'Leak: "${song.title}" was ghostwritten. The timeline is roasting ${_player!.name}.',
    );
    notifyListeners();
    saveGame();
    return true;
  }

  void resolveGhostwriterSpin(String choice) {
    switch (choice) {
      case 'Own It':
        updatePlayerAttribute('reputation', 3);
        updatePlayerAttribute('discipline', 2);
        updatePlayerAttribute('controversy', -4);
        break;
      case 'Deny Everything':
        updatePlayerAttribute('controversy', 6);
        updatePlayerAttribute('popularity', 2);
        updatePlayerAttribute('reputation', -4);
        break;
      case 'Pay for Silence':
        updatePlayerMoney(-1200);
        updatePlayerAttribute('controversy', -6);
        updatePlayerAttribute('happiness', -2);
        break;
    }
    weeklyHeadlines.add('Ghostwriter spin: $choice.');
    notifyListeners();
    saveGame();
  }

  void addSong(Song song) {
    worldSongs.add(song);
    // Award XP for releasing a song
    addPlayerXp(50);
    if (song.artistId == _player?.id) {
      if (song.listeningParty.isEmpty) song.listeningParty = 'pending';
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

    double recencyBoost;
    if (song.weeksSinceRelease == 0) {
      recencyBoost = 1.72;
    } else if (song.weeksSinceRelease == 1) {
      recencyBoost = 1.48;
    } else if (song.weeksSinceRelease == 2) {
      recencyBoost = 1.28;
    } else {
      recencyBoost = 1.0 - (song.weeksSinceRelease * 0.03).clamp(0.0, 0.5);
    }

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
        (s) =>
            isRival(s.artistId) &&
            s.weeksSinceRelease <= 3 &&
            !_rivalTruceBlocks(s.artistId),
      );
      if (rivalHot) rivalryMultiplier = 1.05;
    }

    // Genre meta: hotter genres pull more weekly listeners
    final heat = genreHeatFor(song.genre);
    final genreMultiplier = 0.82 + (heat / 100.0) * 0.45; // ~0.82–1.27
    final onTrendBonus = song.genre == trendingGenre ? 1.08 : 1.0;
    final albumBoost = isSongOnAlbum(song.id) ? 1.14 : 1.0;
    final videoBoost = song.videoWeeksRemaining > 0 ? 1.32 : 1.0;
    var playlistBoost = 1.0;
    if (song.playlistWeeksRemaining > 0) {
      playlistBoost = 1.22;
      if (inDebutWindow(song)) playlistBoost *= 1.16;
    }
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
        playlistBoost *
        homeLaneBoost *
        fatigue *
        heatScale *
        (isFestivalSeason ? 1.08 : 1.0) *
        (song.artistId == _player?.id && pressCoverWeeksRemaining > 0
            ? 1.12
            : 1.0) *
        (song.artistId == _player?.id ? afterpartyStreamBoost : 1.0) *
        _radioLiveBoost(song) *
        _demoLeakBoost(song) *
        _producerBeefBoost(song) *
        _mentorCosignBoost(song) *
        _meetGreetBoost(song) *
        _danceChallengeBoost(song) *
        _brandDealBoost(song) *
        _chartWagerBoost(song) *
        _rivalTruceBoost(song) *
        _documentaryBoost(song) *
        _therapyPodcastBoost(song) *
        _collabDmBoost(song) *
        _stalkerFanBoost(song) *
        _merchDropBoost(song) *
        _tourBusBoost(song) *
        _awardsCampBoost(song) *
        _genrePivotBoost(song) *
        _arenaSlotBoost(song) *
        _fanTheoryBoost(song) *
        _blacklistBoost(song) *
        _comebackBoost(song) *
        _charityBoost(song) *
        _listeningPartyBoost(song) *
        (song.sampleTakedown
            ? 0.22
            : song.usesSample
                ? (song.sampleCleared ? 1.08 : 1.14)
                : 1.0) *
        _fanConvertBoost(song);

    final jitter = (rng.nextDouble() - 0.5) * 0.15;
    listeners *= (1 + jitter);

    if (song.sampleTakedown) {
      listeners = listeners.clamp(8.0, 400.0);
    } else if (listeners < 50) {
      listeners = (50 + rng.nextInt(150)).toDouble();
    }

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
    lastWeekTourPay = 0;
    lastWeekPassive = 0;
    lastWeekUpkeep = 0;
    ownedAssetIds.clear();
    investments.clear();
    activeTour = null;
    labelDealStyle = LabelDealStyle.standard;
    playerLabelId = '';
    rosterSignings.clear();
    labelPitchCooldowns.clear();
    signOfferCooldowns.clear();
    dissCooldownWeeks = 0;
    lastFestivalYearPlayed = 0;
    pressCooldownWeeks = 0;
    pressCoverWeeksRemaining = 0;
    fanClubFounded = false;
    streetTeamWeeksRemaining = 0;
    lastWeekFanClubUpkeep = 0;
    afterpartyBuzz = '';
    afterpartyBuzzWeeks = 0;
    reissueCooldownWeeks = 0;
    radioInterviewCooldownWeeks = 0;
    radioLiveWeeksRemaining = 0;
    radioLiveKind = '';
    radioLiveSongId = '';
    demoLeakCooldownWeeks = 0;
    demoLeakHeatWeeks = 0;
    demoLeakKind = '';
    leakedDemoTitle = '';
    producerBeefCooldownWeeks = 0;
    producerCreditWeeks = 0;
    producerBeefKind = '';
    beefProducerName = '';
    beefSongId = '';
    mentorCosignCooldownWeeks = 0;
    mentorCosignWeeks = 0;
    mentorCosignKind = '';
    mentorCosignArtistId = '';
    mentorCosignSongId = '';
    meetGreetCooldownWeeks = 0;
    meetGreetWeeks = 0;
    meetGreetKind = '';
    danceChallengeCooldownWeeks = 0;
    danceChallengeWeeks = 0;
    danceChallengeKind = '';
    danceChallengeSongId = '';
    brandDealCooldownWeeks = 0;
    brandDealWeeks = 0;
    brandDealKind = '';
    brandSponsorName = '';
    chartWagerCooldownWeeks = 0;
    chartWagerWeeks = 0;
    chartWagerKind = '';
    chartWagerSongId = '';
    chartWagerStartRank = 0;
    rivalTruceCooldownWeeks = 0;
    rivalTruceWeeks = 0;
    rivalTruceKind = '';
    rivalTruceRivalId = '';
    documentaryCooldownWeeks = 0;
    documentaryWeeks = 0;
    documentaryKind = '';
    documentaryCrewName = '';
    therapyPodcastCooldownWeeks = 0;
    therapyPodcastWeeks = 0;
    therapyPodcastKind = '';
    therapyPodcastName = '';
    collabDmCooldownWeeks = 0;
    collabDmWeeks = 0;
    collabDmKind = '';
    collabDmArtistId = '';
    collabDmSongId = '';

    stalkerFanCooldownWeeks = 0;
    stalkerFanWeeks = 0;
    stalkerFanKind = '';
    merchDropCooldownWeeks = 0;
    merchDropWeeks = 0;
    merchDropKind = '';
    tourBusCooldownWeeks = 0;
    tourBusWeeks = 0;
    tourBusKind = '';
    awardsCampCooldownWeeks = 0;
    awardsCampWeeks = 0;
    awardsCampKind = '';
    genrePivotCooldownWeeks = 0;
    genrePivotWeeks = 0;
    genrePivotKind = '';
    arenaSlotCooldownWeeks = 0;
    arenaSlotWeeks = 0;
    arenaSlotKind = '';
    fanTheoryCooldownWeeks = 0;
    fanTheoryWeeks = 0;
    fanTheoryKind = '';
    blacklistCooldownWeeks = 0;
    blacklistWeeks = 0;
    blacklistKind = '';
    comebackCooldownWeeks = 0;
    comebackWeeks = 0;
    comebackKind = '';
    charityCooldownWeeks = 0;
    charityWeeks = 0;
    charityKind = '';
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
    _ensureNamedLabels();
    playerMoney = 5000;
    playerFanCount = 100;
    playerXp = 0;
    _initGenreHeat();
    _assignRivals();
    saveGame();
    notifyListeners();
  }

  List<Song> get playerSongs => worldSongs
      .where((song) => song.artistId == _player?.id)
      .toList();

  List<RosterSigning> get activeRoster =>
      rosterSignings.where((s) => s.active).toList();

  bool isOnRoster(String artistId) =>
      activeRoster.any((s) => s.artistId == artistId);

  RosterSigning? rosterFor(String artistId) {
    for (final signing in activeRoster) {
      if (signing.artistId == artistId) return signing;
    }
    return null;
  }

  RecordLabel? labelById(String? id) {
    if (id == null || id.isEmpty) return null;
    if (id == RecordLabels.playerImprintId && _player != null) {
      return RecordLabels.playerImprint(_player!.name, _player!.labelTier);
    }
    return RecordLabels.byId(id);
  }

  RecordLabel? labelForArtist(Artist artist) {
    if (isOnRoster(artist.id) || artist.labelId == RecordLabels.playerImprintId) {
      return RecordLabels.playerImprint(
        _player?.name ?? 'Player',
        _player?.labelTier ?? LabelTier.indie,
      );
    }
    if (artist.id == _player?.id && playerLabelId.isNotEmpty) {
      return labelById(playerLabelId);
    }
    return labelById(artist.labelId);
  }

  String labelDisplayName(Artist? artist) {
    if (artist == null) return 'Unsigned';
    final named = labelForArtist(artist);
    if (named != null) return named.name;
    return artist.labelTier.displayName;
  }

  String songCredit(Song song) {
    final primary = getArtistById(song.artistId)?.name ?? 'Unknown';
    if (song.featuredArtistIds.isEmpty) return primary;
    final feats = song.featuredArtistIds
        .map((id) => getArtistById(id)?.name ?? '')
        .where((name) => name.isNotEmpty)
        .toList();
    if (feats.isEmpty) return primary;
    return '$primary ft. ${feats.join(', ')}';
  }

  List<RecordLabel> visibleLabels() {
    return RecordLabels.allVisible(
      playerName: _player?.name ?? 'Player',
      playerTier: _player?.labelTier ?? LabelTier.unsigned,
    );
  }

  List<Artist> artistsOnLabel(String labelId) {
    if (labelId == RecordLabels.playerImprintId) {
      return worldArtists.where((a) => isOnRoster(a.id)).toList();
    }
    return worldArtists
        .where((a) => a.labelId == labelId && a.id != _player?.id)
        .toList();
  }

  List<Song> catalogSongsFor(String artistId) {
    return worldSongs.where((song) => song.creditsArtist(artistId)).toList();
  }

  List<Song> get managedCatalog {
    final ids = <String>{if (_player != null) _player!.id};
    for (final signing in activeRoster) {
      ids.add(signing.artistId);
    }
    return worldSongs.where((song) => ids.any(song.creditsArtist)).toList();
  }

  void _tickCooldownMap(Map<String, int> map) {
    final keys = map.keys.toList();
    for (final key in keys) {
      final next = (map[key] ?? 0) - 1;
      if (next <= 0) {
        map.remove(key);
      } else {
        map[key] = next;
      }
    }
  }

  void _ensureNamedLabels() {
    for (final artist in worldArtists) {
      if (artist.id == _player?.id) continue;
      if (isOnRoster(artist.id)) {
        artist.labelId = RecordLabels.playerImprintId;
        continue;
      }
      if (artist.labelId.isEmpty && artist.labelTier != LabelTier.unsigned) {
        artist.labelId = RecordLabels.assignIdFor(artist);
      }
    }
    if (_player != null &&
        playerLabelId.isEmpty &&
        _player!.labelTier != LabelTier.unsigned) {
      _assignPlayerToNamedLabel(_player!.labelTier);
    }
  }

  void _assignPlayerToNamedLabel(LabelTier tier, {String? preferredId}) {
    if (_player == null || tier == LabelTier.unsigned) {
      playerLabelId = '';
      _player?.labelId = '';
      return;
    }
    final preferred = RecordLabels.byId(preferredId);
    if (preferred != null && preferred.tier == tier) {
      playerLabelId = preferred.id;
      _player!.labelId = preferred.id;
      return;
    }
    final current = RecordLabels.byId(playerLabelId);
    if (current != null && current.tier == tier) {
      _player!.labelId = current.id;
      return;
    }
    final pool = RecordLabels.forTier(tier);
    if (pool.isEmpty) return;
    final pick = pool[(_player!.id.hashCode.abs()) % pool.length];
    playerLabelId = pick.id;
    _player!.labelId = pick.id;
  }

  String? pitchTrackToLabel(
    String songId,
    String labelId, {
    LabelDealStyle deal = LabelDealStyle.standard,
    bool forceAccept = false,
    Random? rng,
  }) {
    if (_player == null) return 'No player';
    final label = RecordLabels.byId(labelId);
    if (label == null) return 'Label not found';
    Song? song;
    for (final s in worldSongs) {
      if (s.id == songId) {
        song = s;
        break;
      }
    }
    if (song == null || song.artistId != _player!.id) {
      return 'Pick one of your tracks';
    }
    if (!song.released) return 'Release the demo first';
    final cool = labelPitchCooldowns[labelId] ?? 0;
    if (cool > 0) return 'A&R already heard you ($cool w)';
    if (playerMoney < label.pitchCost) {
      return 'Need \$${label.pitchCost} to submit';
    }

    final pop = _player!.attributes['popularity'] ?? 0;
    if (label.tier == LabelTier.major &&
        song.totalStreams < 20000 &&
        pop < 40) {
      return 'Need 20k streams on this track or 40 popularity';
    }
    if (label.tier == LabelTier.superstar &&
        song.totalStreams < 100000 &&
        pop < 70) {
      return 'Need 100k streams on this track or 70 popularity';
    }
    if (label.tier == LabelTier.indie && playerSongs.where((s) => s.released).isEmpty) {
      return 'Need a released song';
    }

    updatePlayerMoney(-label.pitchCost.toDouble());
    labelPitchCooldowns[labelId] = RecordLabels.pitchCooldownWeeks;

    var chance = 0.18 +
        (song.popularityFactor / 220) +
        (song.viralFactor / 280) +
        pop / 250;
    if (song.totalStreams >= 50000) chance += 0.12;
    if (song.totalStreams >= 20000) chance += 0.06;
    if (label.tier == LabelTier.major) chance -= 0.12;
    if (label.tier == LabelTier.superstar) chance -= 0.22;
    chance = chance.clamp(0.08, 0.88);

    final roll = rng ?? Random();
    final landed = forceAccept || roll.nextDouble() < chance;
    if (!landed) {
      weeklyHeadlines.add('${label.name} passed on "${song.title}".');
      notifyListeners();
      saveGame();
      return '${label.name} passed on "${song.title}"';
    }

    final alreadyHere = playerLabelId == label.id;
    final sameOrLower = _player!.labelTier.index >= label.tier.index;
    if (alreadyHere || sameOrLower) {
      song.playlistWeeksRemaining =
          (song.playlistWeeksRemaining + 3).clamp(0, 8);
      song.viralFactor = (song.viralFactor + 8).clamp(0, 100);
      weeklyHeadlines.add(
        '${label.name} added "${song.title}" to their playlist circuit.',
      );
      lastWeekEvents.add(GameEvent(
        id: 'pitch_boost_${label.id}_${DateTime.now().millisecondsSinceEpoch}',
        title: '${label.name} Playlist Add',
        description:
            '"${song.title}" is spinning on ${label.name} playlists for 3 weeks.',
        type: EventType.labelOffer,
        severity: EventSeverity.medium,
      ));
      notifyListeners();
      saveGame();
      return null;
    }

    _player!.labelTier = label.tier;
    labelDealStyle = deal;
    _assignPlayerToNamedLabel(label.tier, preferredId: label.id);
    final advance = deal.signingAdvance(label.tier);
    if (advance > 0) updatePlayerMoney(advance);
    updatePlayerAttribute('influence', label.tier == LabelTier.indie ? 5 : 10);
    updatePlayerAttribute('marketing', label.tier == LabelTier.indie ? 5 : 8);
    weeklyHeadlines.add(
      '${_player!.name} signed with ${label.name} (${deal.displayName}).',
    );
    lastWeekEvents.add(GameEvent(
      id: 'pitch_sign_${label.id}_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Signed: ${label.name}',
      description:
          'They picked up "${song.title}". ${deal.displayName} deal. Advance \$${advance.toStringAsFixed(0)}.',
      type: EventType.labelOffer,
      severity: EventSeverity.high,
    ));
    notifyListeners();
    saveGame();
    return null;
  }

  String? signArtist(
    String artistId,
    LabelDealStyle deal, {
    double? artistKeep,
    bool forceAccept = false,
  }) {
    if (_player == null) return 'No player';
    if (artistId == _player!.id) return 'You already run this imprint';
    final artist = getArtistById(artistId);
    if (artist == null) return 'Artist not found';
    if (isOnRoster(artistId)) return 'Already on your roster';
    if (activeRoster.length >= RecordLabels.maxRosterSize) {
      return 'Roster full (${RecordLabels.maxRosterSize})';
    }
    final pop = _player!.attributes['popularity'] ?? 0;
    if (pop < 22 && _player!.labelTier == LabelTier.unsigned) {
      return 'Need 22 popularity to sign artists';
    }
    if (artist.labelTier == LabelTier.major &&
        _player!.labelTier.index < LabelTier.indie.index) {
      return 'Need Indie to poach a major-label act';
    }
    if (artist.labelTier == LabelTier.superstar &&
        _player!.labelTier.index < LabelTier.major.index) {
      return 'Need Major to poach a superstar act';
    }

    final keep = (artistKeep ?? RosterSigning.artistKeepForDeal(deal))
        .clamp(0.20, 0.85);
    final eval = evaluateRosterContract(artist, keep);
    if (!forceAccept && !eval.acceptable) {
      return eval.suggestion == null
          ? eval.message
          : '${eval.message} ${eval.suggestion}';
    }

    final cost = eval.signingCost;
    if (playerMoney < cost) {
      return 'Need \$${cost.toStringAsFixed(0)} for this contract';
    }

    updatePlayerMoney(-cost);
    rosterSignings.add(RosterSigning(
      artistId: artistId,
      deal: RosterSigning.closestDeal(keep),
      signedYear: year,
      signedMonth: month,
      signedWeek: weekOfMonth,
      customPlayerCut: eval.playerCut,
    ));
    artist.labelId = RecordLabels.playerImprintId;
    if (artist.labelTier == LabelTier.unsigned) {
      artist.labelTier = LabelTier.indie;
    }
    updatePlayerAttribute('influence', 4);
    updatePlayerAttribute('networking', 3);
    weeklyHeadlines.add(
      '${artist.name} signed with ${_player!.name} Records · they keep ${(keep * 100).round()}%.',
    );
    lastWeekEvents.add(GameEvent(
      id: 'roster_sign_${artistId}_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Signed: ${artist.name}',
      description:
          '${artist.name} keeps ${(keep * 100).round()}% of streams. '
          'Roster ${activeRoster.length}/${RecordLabels.maxRosterSize}.',
      type: EventType.labelOffer,
      severity: EventSeverity.high,
    ));
    notifyListeners();
    saveGame();
    return null;
  }

  ContractEvaluation evaluateRosterContract(Artist artist, double artistKeep) {
    return RosterSigning.evaluate(
      artistName: artist.name,
      tier: artist.labelTier,
      popularity: artist.attributes['popularity'] ?? 10,
      artistKeep: artistKeep,
    );
  }

  String? renameRosterArtist(String artistId, String rawName) {
    if (_player == null) return 'No player';
    if (!isOnRoster(artistId)) return 'Only signed artists can be renamed';
    final artist = getArtistById(artistId);
    if (artist == null) return 'Artist not found';
    final name = rawName.trim();
    if (name.length < 2) return 'Name needs at least 2 letters';
    if (name.length > 24) return 'Keep the name under 24 characters';
    artist.name = name;
    notifyListeners();
    saveGame();
    return null;
  }

  String? updateRosterAppearance(String artistId, ArtistAppearance appearance) {
    if (_player == null) return 'No player';
    if (!isOnRoster(artistId)) {
      return 'Only signed artists can change their look';
    }
    final artist = getArtistById(artistId);
    if (artist == null) return 'Artist not found';
    artist.appearance = appearance;
    notifyListeners();
    saveGame();
    return null;
  }

  String? commissionRosterDemo(
    String artistId, {
    String? collabArtistId,
  }) {
    if (_player == null) return 'No player';
    if (!isOnRoster(artistId)) return 'Not on your roster';
    final artist = getArtistById(artistId);
    if (artist == null) return 'Artist not found';
    if (hustlesThisWeek >= 2) return 'Already hustled enough this week';
    const cost = 400.0;
    if (playerMoney < cost) return 'Need \$400 studio time';
    final stamina = _player!.attributes['stamina'] ?? 0;
    if (stamina < 10) return 'Too tired to run a session';

    String? featureId = collabArtistId;
    if (featureId != null && featureId.isNotEmpty) {
      if (featureId == artistId) return 'Pick a different collab partner';
      final partner = getArtistById(featureId);
      if (partner == null) return 'Collab partner not found';
    } else {
      featureId = null;
    }

    hustlesThisWeek++;
    updatePlayerMoney(-cost);
    updatePlayerAttribute('stamina', -10);
    _spawnRosterTrack(artist, featureId: featureId, released: false);
    notifyListeners();
    saveGame();
    return null;
  }

  String? releaseRosterSong(String songId) {
    if (_player == null) return 'No player';
    Song? song;
    for (final s in worldSongs) {
      if (s.id == songId) {
        song = s;
        break;
      }
    }
    if (song == null) return 'Song not found';
    if (song.released) return 'Already released';
    final managed = song.artistId == _player!.id ||
        isOnRoster(song.artistId) ||
        song.featuredArtistIds.any(isOnRoster) ||
        song.featuredArtistIds.contains(_player!.id);
    if (!managed) return 'That demo is not on your imprint';
    const cost = 350.0;
    if (playerMoney < cost) return 'Need \$350 to release';
    updatePlayerMoney(-cost);
    song.released = true;
    song.weeksSinceRelease = 0;
    song.isNewEntry = true;
    song.listeningParty = 'pending';
    updatePlayerFanCount(80);
    addPlayerXp(40);
    _challenges?.updateProgress(ChallengeType.releaseSongs, 1);
    weeklyHeadlines.add(
      '${_player!.name} Records released "${song.title}" (${songCredit(song)}).',
    );
    notifyListeners();
    saveGame();
    return null;
  }

  void _simulateRosterWeek() {
    if (_player == null || activeRoster.isEmpty) return;
    final rng = Random();
    for (final signing in activeRoster) {
      final artist = getArtistById(signing.artistId);
      if (artist == null) continue;
      final pending = worldSongs
          .where((s) => s.artistId == artist.id && !s.released)
          .length;
      if (pending < 2 && rng.nextDouble() < 0.42) {
        _spawnRosterTrack(artist, released: false, rng: rng);
      }
      if (rng.nextDouble() < 0.18) {
        final partner = _pickRosterCollabPartner(artist.id, rng);
        if (partner != null) {
          _spawnRosterTrack(
            artist,
            featureId: partner.id,
            released: false,
            rng: rng,
          );
        }
      }
    }
  }

  Artist? _pickRosterCollabPartner(String artistId, Random rng) {
    final roll = rng.nextDouble();
    if (roll < 0.40 && _player != null) return _player;
    if (roll < 0.70) {
      final teammates = activeRoster
          .where((s) => s.artistId != artistId)
          .map((s) => getArtistById(s.artistId))
          .whereType<Artist>()
          .toList();
      if (teammates.isNotEmpty) {
        return teammates[rng.nextInt(teammates.length)];
      }
    }
    final outsiders = worldArtists
        .where((a) => a.id != artistId && a.id != _player?.id && !isOnRoster(a.id))
        .toList();
    if (outsiders.isEmpty) return _player;
    return outsiders[rng.nextInt(outsiders.length)];
  }

  void _spawnRosterTrack(
    Artist artist, {
    String? featureId,
    required bool released,
    Random? rng,
  }) {
    final roll = rng ?? Random();
    final feature = featureId == null ? null : getArtistById(featureId);
    final title = feature == null
        ? _npcSongTitles[roll.nextInt(_npcSongTitles.length)]
        : '${artist.name} & ${feature.name} - ${_npcSongTitles[roll.nextInt(_npcSongTitles.length)]}';
    final pop = ((artist.attributes['popularity'] ?? 20) +
            (feature?.attributes['popularity'] ?? 0) * 0.35)
        .clamp(18.0, 92.0);
    worldSongs.add(Song(
      id: 'song_${DateTime.now().millisecondsSinceEpoch}_${artist.id}',
      title: title,
      artistId: artist.id,
      featuredArtistIds: feature == null ? const [] : [feature.id],
      popularityFactor: pop,
      viralFactor: (artist.attributes['creativity'] ?? 20).clamp(10.0, 80.0),
      salesPotential: (artist.attributes['marketing'] ?? 20).clamp(10.0, 80.0),
      genre: availableGenres[roll.nextInt(availableGenres.length)],
      isNewEntry: released,
      released: released,
    ));
    if (!released) {
      weeklyHeadlines.add(
        '${artist.name} cut a demo${feature == null ? '' : ' with ${feature.name}'} for ${_player?.name ?? 'you'} Records.',
      );
    }
  }

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

  /// Upgrade player label with a deal fork. Returns false if requirements unmet.
  bool upgradeLabelTier(
    LabelTier target, {
    LabelDealStyle deal = LabelDealStyle.standard,
  }) {
    if (!canUpgradeLabelTier(target)) return false;
    _player!.labelTier = target;
    labelDealStyle = deal;
    _assignPlayerToNamedLabel(target);
    final advance = deal.signingAdvance(target);
    if (advance > 0) {
      updatePlayerMoney(advance);
    }
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
      title: 'Signed: ${target.displayName} · ${deal.displayName}',
      description:
          'Advance \$${advance.toStringAsFixed(0)}. Weekly stipend \$${effectiveWeeklyStipend.toStringAsFixed(0)}. '
          'You keep ${(effectiveRoyaltyKeep * 100).toStringAsFixed(0)}% of streams.',
      type: EventType.labelOffer,
      severity: EventSeverity.high,
    ));
    weeklyHeadlines.add(
      '${_player!.name} signed a ${deal.displayName} ${target.displayName} deal.',
    );
    notifyListeners();
    saveGame();
    return true;
  }

  String? buyLuxury(String assetId) {
    if (_player == null) return 'No player';
    final asset = LuxuryAsset.byId(assetId);
    if (asset == null) return 'Unknown item';
    if (ownedAssetIds.contains(assetId)) return 'Already own this';
    final pop = _player!.attributes['popularity'] ?? 0;
    if (pop < asset.popularityRequired) {
      return 'Need ${asset.popularityRequired} popularity';
    }
    if (!labelMeets(_player!.labelTier, asset.minLabel)) {
      return 'Need ${asset.minLabel.displayName}';
    }
    if (playerMoney < asset.price) {
      return 'Need \$${asset.price.toStringAsFixed(0)}';
    }
    updatePlayerMoney(-asset.price);
    ownedAssetIds.add(assetId);
    if (asset.popularity != 0) {
      updatePlayerAttribute('popularity', asset.popularity);
    }
    if (asset.wealth != 0) updatePlayerAttribute('wealth', asset.wealth);
    if (asset.influence != 0) {
      updatePlayerAttribute('influence', asset.influence);
    }
    if (asset.charisma != 0) updatePlayerAttribute('charisma', asset.charisma);
    weeklyHeadlines.add('${_player!.name} bought a ${asset.name}.');
    addPlayerXp((asset.price / 500).toInt().clamp(8, 80));
    notifyListeners();
    saveGame();
    return null;
  }

  String? investMoney(String vehicleId, double amount) {
    if (_player == null) return 'No player';
    final vehicle = InvestmentVehicle.byId(vehicleId);
    if (vehicle == null) return 'Unknown investment';
    if (!labelMeets(_player!.labelTier, vehicle.minLabel)) {
      return 'Need ${vehicle.minLabel.displayName}';
    }
    if (amount <= 0) return 'Enter an amount';
    final existing = investmentFor(vehicleId);
    if (existing == null && amount < vehicle.minBuy) {
      return 'Min \$${vehicle.minBuy.toStringAsFixed(0)}';
    }
    if (existing != null && amount < 500) return 'Min \$500 top-up';
    if (playerMoney < amount) {
      return 'Need \$${amount.toStringAsFixed(0)}';
    }
    updatePlayerMoney(-amount);
    if (existing == null) {
      investments.add(OwnedInvestment(vehicleId: vehicleId, principal: amount));
      if (vehicle.productionBump != 0) {
        updatePlayerAttribute('production', vehicle.productionBump);
      }
      if (vehicle.marketingBump != 0) {
        updatePlayerAttribute('marketing', vehicle.marketingBump);
      }
      if (vehicle.influenceBump != 0) {
        updatePlayerAttribute('influence', vehicle.influenceBump);
      }
      weeklyHeadlines.add(
        '${_player!.name} opened ${vehicle.name} with \$${amount.toStringAsFixed(0)}.',
      );
    } else {
      existing.principal += amount;
      weeklyHeadlines.add(
        '${_player!.name} added \$${amount.toStringAsFixed(0)} to ${vehicle.name}.',
      );
    }
    addPlayerXp((amount / 400).toInt().clamp(5, 60));
    notifyListeners();
    saveGame();
    return null;
  }

  String? cashOutInvestment(String vehicleId) {
    if (_player == null) return 'No player';
    final existing = investmentFor(vehicleId);
    if (existing == null || existing.principal <= 0) {
      return 'Nothing to cash out';
    }
    final refund = existing.principal * 0.90;
    investments.removeWhere((o) => o.vehicleId == vehicleId);
    updatePlayerMoney(refund);
    weeklyHeadlines.add(
      '${_player!.name} cashed out ${InvestmentVehicle.byId(vehicleId)?.name ?? 'an investment'} for \$${refund.toStringAsFixed(0)}.',
    );
    notifyListeners();
    saveGame();
    return null;
  }

  void _settleLifestyle() {
    lastWeekPassive = 0;
    lastWeekUpkeep = 0;
    if (_player == null) return;

    lastWeekPassive = projectedInvestmentYield(royalties: lastWeekRoyalties);
    if (lastWeekPassive > 0) {
      updatePlayerMoney(lastWeekPassive);
      weeklyHeadlines.add(
        'Investments paid \$${lastWeekPassive.toStringAsFixed(0)} this week.',
      );
    }

    lastWeekUpkeep = weeklyAssetUpkeep;
    if (lastWeekUpkeep > 0) {
      updatePlayerMoney(-lastWeekUpkeep);
      weeklyHeadlines.add(
        'Lifestyle bills \$${lastWeekUpkeep.toStringAsFixed(0)}.',
      );
    }

    if (playerMoney < 0) {
      updatePlayerAttribute('happiness', -5);
      updatePlayerAttribute('controversy', 2);
      weeklyHeadlines.add(
        '${_player!.name} bounced a bill. Tabloids clock the broke flex.',
      );
    }
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
      'lastWeekTourPay': lastWeekTourPay,
      'lastWeekPassive': lastWeekPassive,
      'lastWeekUpkeep': lastWeekUpkeep,
      'ownedAssetIds': ownedAssetIds.toList(),
      'investments': investments.map((e) => e.toMap()).toList(),
      'activeTour': activeTour?.toMap(),
      'labelDealStyle': labelDealStyle.name,
      'dissCooldownWeeks': dissCooldownWeeks,
      'lastFestivalYearPlayed': lastFestivalYearPlayed,
      'pressCooldownWeeks': pressCooldownWeeks,
      'pressCoverWeeksRemaining': pressCoverWeeksRemaining,
      'fanClubFounded': fanClubFounded,
      'streetTeamWeeksRemaining': streetTeamWeeksRemaining,
      'lastWeekFanClubUpkeep': lastWeekFanClubUpkeep,
      'afterpartyBuzz': afterpartyBuzz,
      'afterpartyBuzzWeeks': afterpartyBuzzWeeks,
      'reissueCooldownWeeks': reissueCooldownWeeks,
      'radioInterviewCooldownWeeks': radioInterviewCooldownWeeks,
      'radioLiveWeeksRemaining': radioLiveWeeksRemaining,
      'radioLiveKind': radioLiveKind,
      'radioLiveSongId': radioLiveSongId,
      'demoLeakCooldownWeeks': demoLeakCooldownWeeks,
      'demoLeakHeatWeeks': demoLeakHeatWeeks,
      'demoLeakKind': demoLeakKind,
      'leakedDemoTitle': leakedDemoTitle,
      'producerBeefCooldownWeeks': producerBeefCooldownWeeks,
      'producerCreditWeeks': producerCreditWeeks,
      'producerBeefKind': producerBeefKind,
      'beefProducerName': beefProducerName,
      'beefSongId': beefSongId,
      'mentorCosignCooldownWeeks': mentorCosignCooldownWeeks,
      'mentorCosignWeeks': mentorCosignWeeks,
      'mentorCosignKind': mentorCosignKind,
      'mentorCosignArtistId': mentorCosignArtistId,
      'mentorCosignSongId': mentorCosignSongId,
      'meetGreetCooldownWeeks': meetGreetCooldownWeeks,
      'meetGreetWeeks': meetGreetWeeks,
      'meetGreetKind': meetGreetKind,
      'danceChallengeCooldownWeeks': danceChallengeCooldownWeeks,
      'danceChallengeWeeks': danceChallengeWeeks,
      'danceChallengeKind': danceChallengeKind,
      'danceChallengeSongId': danceChallengeSongId,
      'brandDealCooldownWeeks': brandDealCooldownWeeks,
      'brandDealWeeks': brandDealWeeks,
      'brandDealKind': brandDealKind,
      'brandSponsorName': brandSponsorName,
      'chartWagerCooldownWeeks': chartWagerCooldownWeeks,
      'chartWagerWeeks': chartWagerWeeks,
      'chartWagerKind': chartWagerKind,
      'chartWagerSongId': chartWagerSongId,
      'chartWagerStartRank': chartWagerStartRank,
      'rivalTruceCooldownWeeks': rivalTruceCooldownWeeks,
      'rivalTruceWeeks': rivalTruceWeeks,
      'rivalTruceKind': rivalTruceKind,
      'rivalTruceRivalId': rivalTruceRivalId,
      'documentaryCooldownWeeks': documentaryCooldownWeeks,
      'documentaryWeeks': documentaryWeeks,
      'documentaryKind': documentaryKind,
      'documentaryCrewName': documentaryCrewName,
      'therapyPodcastCooldownWeeks': therapyPodcastCooldownWeeks,
      'therapyPodcastWeeks': therapyPodcastWeeks,
      'therapyPodcastKind': therapyPodcastKind,
      'therapyPodcastName': therapyPodcastName,
      'collabDmCooldownWeeks': collabDmCooldownWeeks,
      'collabDmWeeks': collabDmWeeks,
      'collabDmKind': collabDmKind,
      'collabDmArtistId': collabDmArtistId,
      'collabDmSongId': collabDmSongId,

      'stalkerFanCooldownWeeks': stalkerFanCooldownWeeks,
      'stalkerFanWeeks': stalkerFanWeeks,
      'stalkerFanKind': stalkerFanKind,
      'merchDropCooldownWeeks': merchDropCooldownWeeks,
      'merchDropWeeks': merchDropWeeks,
      'merchDropKind': merchDropKind,
      'tourBusCooldownWeeks': tourBusCooldownWeeks,
      'tourBusWeeks': tourBusWeeks,
      'tourBusKind': tourBusKind,
      'awardsCampCooldownWeeks': awardsCampCooldownWeeks,
      'awardsCampWeeks': awardsCampWeeks,
      'awardsCampKind': awardsCampKind,
      'genrePivotCooldownWeeks': genrePivotCooldownWeeks,
      'genrePivotWeeks': genrePivotWeeks,
      'genrePivotKind': genrePivotKind,
      'arenaSlotCooldownWeeks': arenaSlotCooldownWeeks,
      'arenaSlotWeeks': arenaSlotWeeks,
      'arenaSlotKind': arenaSlotKind,
      'fanTheoryCooldownWeeks': fanTheoryCooldownWeeks,
      'fanTheoryWeeks': fanTheoryWeeks,
      'fanTheoryKind': fanTheoryKind,
      'blacklistCooldownWeeks': blacklistCooldownWeeks,
      'blacklistWeeks': blacklistWeeks,
      'blacklistKind': blacklistKind,
      'comebackCooldownWeeks': comebackCooldownWeeks,
      'comebackWeeks': comebackWeeks,
      'comebackKind': comebackKind,
      'charityCooldownWeeks': charityCooldownWeeks,
      'charityWeeks': charityWeeks,
      'charityKind': charityKind,
      'playerLabelId': playerLabelId,
      'rosterSignings': rosterSignings.map((s) => s.toMap()).toList(),
      'labelPitchCooldowns': labelPitchCooldowns,
      'signOfferCooldowns': signOfferCooldowns,
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
      lastWeekTourPay = (data['lastWeekTourPay'] as num?)?.toDouble() ?? 0;
      lastWeekPassive = (data['lastWeekPassive'] as num?)?.toDouble() ?? 0;
      lastWeekUpkeep = (data['lastWeekUpkeep'] as num?)?.toDouble() ?? 0;
      ownedAssetIds
        ..clear()
        ..addAll(List<String>.from(data['ownedAssetIds'] as List? ?? const []));
      investments
        ..clear()
        ..addAll(
          (data['investments'] as List? ?? const []).map(
            (e) => OwnedInvestment.fromMap(Map<String, dynamic>.from(e as Map)),
          ),
        );
      final tourRaw = data['activeTour'];
      activeTour = tourRaw is Map
          ? ActiveTour.fromMap(Map<String, dynamic>.from(tourRaw))
          : null;
      labelDealStyle = LabelDealStyleX.fromName(data['labelDealStyle'] as String?);
      dissCooldownWeeks = data['dissCooldownWeeks'] as int? ?? 0;
      lastFestivalYearPlayed = data['lastFestivalYearPlayed'] as int? ?? 0;
      pressCooldownWeeks = data['pressCooldownWeeks'] as int? ?? 0;
      pressCoverWeeksRemaining = data['pressCoverWeeksRemaining'] as int? ?? 0;
      fanClubFounded = data['fanClubFounded'] as bool? ?? false;
      streetTeamWeeksRemaining = data['streetTeamWeeksRemaining'] as int? ?? 0;
      lastWeekFanClubUpkeep =
          (data['lastWeekFanClubUpkeep'] as num?)?.toDouble() ?? 0;
      afterpartyBuzz = data['afterpartyBuzz'] as String? ?? '';
      afterpartyBuzzWeeks = data['afterpartyBuzzWeeks'] as int? ?? 0;
      reissueCooldownWeeks = data['reissueCooldownWeeks'] as int? ?? 0;
      radioInterviewCooldownWeeks =
          data['radioInterviewCooldownWeeks'] as int? ?? 0;
      radioLiveWeeksRemaining = data['radioLiveWeeksRemaining'] as int? ?? 0;
      radioLiveKind = data['radioLiveKind'] as String? ?? '';
      radioLiveSongId = data['radioLiveSongId'] as String? ?? '';
      demoLeakCooldownWeeks = data['demoLeakCooldownWeeks'] as int? ?? 0;
      demoLeakHeatWeeks = data['demoLeakHeatWeeks'] as int? ?? 0;
      demoLeakKind = data['demoLeakKind'] as String? ?? '';
      leakedDemoTitle = data['leakedDemoTitle'] as String? ?? '';
      producerBeefCooldownWeeks =
          data['producerBeefCooldownWeeks'] as int? ?? 0;
      producerCreditWeeks = data['producerCreditWeeks'] as int? ?? 0;
      producerBeefKind = data['producerBeefKind'] as String? ?? '';
      beefProducerName = data['beefProducerName'] as String? ?? '';
      beefSongId = data['beefSongId'] as String? ?? '';
      mentorCosignCooldownWeeks =
          data['mentorCosignCooldownWeeks'] as int? ?? 0;
      mentorCosignWeeks = data['mentorCosignWeeks'] as int? ?? 0;
      mentorCosignKind = data['mentorCosignKind'] as String? ?? '';
      mentorCosignArtistId = data['mentorCosignArtistId'] as String? ?? '';
      mentorCosignSongId = data['mentorCosignSongId'] as String? ?? '';
      meetGreetCooldownWeeks = data['meetGreetCooldownWeeks'] as int? ?? 0;
      meetGreetWeeks = data['meetGreetWeeks'] as int? ?? 0;
      meetGreetKind = data['meetGreetKind'] as String? ?? '';
      danceChallengeCooldownWeeks =
          data['danceChallengeCooldownWeeks'] as int? ?? 0;
      danceChallengeWeeks = data['danceChallengeWeeks'] as int? ?? 0;
      danceChallengeKind = data['danceChallengeKind'] as String? ?? '';
      danceChallengeSongId = data['danceChallengeSongId'] as String? ?? '';
      brandDealCooldownWeeks = data['brandDealCooldownWeeks'] as int? ?? 0;
      brandDealWeeks = data['brandDealWeeks'] as int? ?? 0;
      brandDealKind = data['brandDealKind'] as String? ?? '';
      brandSponsorName = data['brandSponsorName'] as String? ?? '';
      chartWagerCooldownWeeks = data['chartWagerCooldownWeeks'] as int? ?? 0;
      chartWagerWeeks = data['chartWagerWeeks'] as int? ?? 0;
      chartWagerKind = data['chartWagerKind'] as String? ?? '';
      chartWagerSongId = data['chartWagerSongId'] as String? ?? '';
      chartWagerStartRank = data['chartWagerStartRank'] as int? ?? 0;
      rivalTruceCooldownWeeks = data['rivalTruceCooldownWeeks'] as int? ?? 0;
      rivalTruceWeeks = data['rivalTruceWeeks'] as int? ?? 0;
      rivalTruceKind = data['rivalTruceKind'] as String? ?? '';
      rivalTruceRivalId = data['rivalTruceRivalId'] as String? ?? '';
      documentaryCooldownWeeks = data['documentaryCooldownWeeks'] as int? ?? 0;
      documentaryWeeks = data['documentaryWeeks'] as int? ?? 0;
      documentaryKind = data['documentaryKind'] as String? ?? '';
      documentaryCrewName = data['documentaryCrewName'] as String? ?? '';
      therapyPodcastCooldownWeeks =
          data['therapyPodcastCooldownWeeks'] as int? ?? 0;
      therapyPodcastWeeks = data['therapyPodcastWeeks'] as int? ?? 0;
      therapyPodcastKind = data['therapyPodcastKind'] as String? ?? '';
      therapyPodcastName = data['therapyPodcastName'] as String? ?? '';
      collabDmCooldownWeeks = data['collabDmCooldownWeeks'] as int? ?? 0;
      collabDmWeeks = data['collabDmWeeks'] as int? ?? 0;
      collabDmKind = data['collabDmKind'] as String? ?? '';
      collabDmArtistId = data['collabDmArtistId'] as String? ?? '';
      collabDmSongId = data['collabDmSongId'] as String? ?? '';

      stalkerFanCooldownWeeks = data['stalkerFanCooldownWeeks'] as int? ?? 0;
      stalkerFanWeeks = data['stalkerFanWeeks'] as int? ?? 0;
      stalkerFanKind = data['stalkerFanKind'] as String? ?? '';
      merchDropCooldownWeeks = data['merchDropCooldownWeeks'] as int? ?? 0;
      merchDropWeeks = data['merchDropWeeks'] as int? ?? 0;
      merchDropKind = data['merchDropKind'] as String? ?? '';
      tourBusCooldownWeeks = data['tourBusCooldownWeeks'] as int? ?? 0;
      tourBusWeeks = data['tourBusWeeks'] as int? ?? 0;
      tourBusKind = data['tourBusKind'] as String? ?? '';
      awardsCampCooldownWeeks = data['awardsCampCooldownWeeks'] as int? ?? 0;
      awardsCampWeeks = data['awardsCampWeeks'] as int? ?? 0;
      awardsCampKind = data['awardsCampKind'] as String? ?? '';
      genrePivotCooldownWeeks = data['genrePivotCooldownWeeks'] as int? ?? 0;
      genrePivotWeeks = data['genrePivotWeeks'] as int? ?? 0;
      genrePivotKind = data['genrePivotKind'] as String? ?? '';
      arenaSlotCooldownWeeks = data['arenaSlotCooldownWeeks'] as int? ?? 0;
      arenaSlotWeeks = data['arenaSlotWeeks'] as int? ?? 0;
      arenaSlotKind = data['arenaSlotKind'] as String? ?? '';
      fanTheoryCooldownWeeks = data['fanTheoryCooldownWeeks'] as int? ?? 0;
      fanTheoryWeeks = data['fanTheoryWeeks'] as int? ?? 0;
      fanTheoryKind = data['fanTheoryKind'] as String? ?? '';
      blacklistCooldownWeeks = data['blacklistCooldownWeeks'] as int? ?? 0;
      blacklistWeeks = data['blacklistWeeks'] as int? ?? 0;
      blacklistKind = data['blacklistKind'] as String? ?? '';
      comebackCooldownWeeks = data['comebackCooldownWeeks'] as int? ?? 0;
      comebackWeeks = data['comebackWeeks'] as int? ?? 0;
      comebackKind = data['comebackKind'] as String? ?? '';
      charityCooldownWeeks = data['charityCooldownWeeks'] as int? ?? 0;
      charityWeeks = data['charityWeeks'] as int? ?? 0;
      charityKind = data['charityKind'] as String? ?? '';
      playerLabelId = data['playerLabelId'] as String? ?? '';
      rosterSignings
        ..clear()
        ..addAll(
          (data['rosterSignings'] as List? ?? const []).map(
            (e) => RosterSigning.fromMap(Map<String, dynamic>.from(e as Map)),
          ),
        );
      labelPitchCooldowns
        ..clear()
        ..addAll(_stringIntMap(data['labelPitchCooldowns']));
      signOfferCooldowns
        ..clear()
        ..addAll(_stringIntMap(data['signOfferCooldowns']));
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

      _ensureNamedLabels();

      lastWeekEvents.clear();
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Map<String, int> _stringIntMap(dynamic raw) {
    if (raw is! Map) return {};
    return raw.map(
      (k, v) => MapEntry(k.toString(), (v as num).toInt()),
    );
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
    lastWeekTourPay = 0;
    lastWeekPassive = 0;
    lastWeekUpkeep = 0;
    ownedAssetIds.clear();
    investments.clear();
    activeTour = null;
    labelDealStyle = LabelDealStyle.standard;
    playerLabelId = '';
    rosterSignings.clear();
    labelPitchCooldowns.clear();
    signOfferCooldowns.clear();
    dissCooldownWeeks = 0;
    lastFestivalYearPlayed = 0;
    pressCooldownWeeks = 0;
    pressCoverWeeksRemaining = 0;
    fanClubFounded = false;
    streetTeamWeeksRemaining = 0;
    lastWeekFanClubUpkeep = 0;
    afterpartyBuzz = '';
    afterpartyBuzzWeeks = 0;
    reissueCooldownWeeks = 0;
    radioInterviewCooldownWeeks = 0;
    radioLiveWeeksRemaining = 0;
    radioLiveKind = '';
    radioLiveSongId = '';
    demoLeakCooldownWeeks = 0;
    demoLeakHeatWeeks = 0;
    demoLeakKind = '';
    leakedDemoTitle = '';
    producerBeefCooldownWeeks = 0;
    producerCreditWeeks = 0;
    producerBeefKind = '';
    beefProducerName = '';
    beefSongId = '';
    mentorCosignCooldownWeeks = 0;
    mentorCosignWeeks = 0;
    mentorCosignKind = '';
    mentorCosignArtistId = '';
    mentorCosignSongId = '';
    meetGreetCooldownWeeks = 0;
    meetGreetWeeks = 0;
    meetGreetKind = '';
    danceChallengeCooldownWeeks = 0;
    danceChallengeWeeks = 0;
    danceChallengeKind = '';
    danceChallengeSongId = '';
    brandDealCooldownWeeks = 0;
    brandDealWeeks = 0;
    brandDealKind = '';
    brandSponsorName = '';
    chartWagerCooldownWeeks = 0;
    chartWagerWeeks = 0;
    chartWagerKind = '';
    chartWagerSongId = '';
    chartWagerStartRank = 0;
    rivalTruceCooldownWeeks = 0;
    rivalTruceWeeks = 0;
    rivalTruceKind = '';
    rivalTruceRivalId = '';
    documentaryCooldownWeeks = 0;
    documentaryWeeks = 0;
    documentaryKind = '';
    documentaryCrewName = '';
    therapyPodcastCooldownWeeks = 0;
    therapyPodcastWeeks = 0;
    therapyPodcastKind = '';
    therapyPodcastName = '';
    collabDmCooldownWeeks = 0;
    collabDmWeeks = 0;
    collabDmKind = '';
    collabDmArtistId = '';
    collabDmSongId = '';

    stalkerFanCooldownWeeks = 0;
    stalkerFanWeeks = 0;
    stalkerFanKind = '';
    merchDropCooldownWeeks = 0;
    merchDropWeeks = 0;
    merchDropKind = '';
    tourBusCooldownWeeks = 0;
    tourBusWeeks = 0;
    tourBusKind = '';
    awardsCampCooldownWeeks = 0;
    awardsCampWeeks = 0;
    awardsCampKind = '';
    genrePivotCooldownWeeks = 0;
    genrePivotWeeks = 0;
    genrePivotKind = '';
    arenaSlotCooldownWeeks = 0;
    arenaSlotWeeks = 0;
    arenaSlotKind = '';
    fanTheoryCooldownWeeks = 0;
    fanTheoryWeeks = 0;
    fanTheoryKind = '';
    blacklistCooldownWeeks = 0;
    blacklistWeeks = 0;
    blacklistKind = '';
    comebackCooldownWeeks = 0;
    comebackWeeks = 0;
    comebackKind = '';
    charityCooldownWeeks = 0;
    charityWeeks = 0;
    charityKind = '';
    deleteSave();
    notifyListeners();
  }
}
