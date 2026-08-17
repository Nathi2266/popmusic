import 'package:flutter_test/flutter_test.dart';
import 'package:popmusic/data/record_labels.dart';
import 'package:popmusic/models/artist.dart';
import 'package:popmusic/models/artist_appearance.dart';
import 'package:popmusic/models/label_tier.dart';
import 'package:popmusic/models/record_label.dart';
import 'package:popmusic/models/song.dart';
import 'package:popmusic/services/game_state_service.dart';

void main() {
  late GameStateService game;

  setUp(() {
    game = GameStateService();
    game.startNewGame('Tester');
    game.player!.attributes['popularity'] = 45;
    game.player!.attributes['reputation'] = 50;
    game.playerMoney = 200000;
  });

  Artist signableNpc() {
    return game.worldArtists.firstWhere(
      (a) =>
          a.id != 'player' &&
          !game.isOnRoster(a.id) &&
          a.labelTier.index <= LabelTier.indie.index,
    );
  }

  test('world labels exist and NPCs are assigned', () {
    expect(RecordLabels.catalog.length, 8);
    expect(RecordLabels.catalog.every((l) => l.ceoName.isNotEmpty), isTrue);
    final npcs = game.worldArtists.where((a) => a.id.startsWith('npc_'));
    expect(npcs.length, 150);
    final signedNpcs = game.worldArtists.where(
      (a) => a.id != 'player' && a.labelTier != LabelTier.unsigned,
    );
    expect(signedNpcs.every((a) => a.labelId.isNotEmpty), isTrue);
    expect(game.visibleLabels().length, RecordLabels.catalog.length + 1);
  });

  test('label CEO can book a gig for the signed player', () {
    final label = RecordLabels.catalog.firstWhere((l) => l.tier == LabelTier.indie);
    game.playerLabelId = label.id;
    game.player!.labelId = label.id;
    game.player!.labelTier = LabelTier.indie;
    final before = game.playerMoney;
    final msg = game.requestLabelManagement(
      labelId: label.id,
      action: LabelMgmtAction.bookGig,
    );
    expect(msg.toLowerCase(), contains('booked'));
    expect(game.playerMoney, greaterThan(before));
    expect(game.labelMgmtCooldown(label.id, LabelMgmtAction.bookGig), greaterThan(0));
  });

  test('cannot sign yourself or exceed five artists', () {
    expect(game.signArtist('player', LabelDealStyle.standard), contains('imprint'));

    for (var i = 0; i < RecordLabels.maxRosterSize; i++) {
      final artist = signableNpc();
      expect(
        game.signArtist(artist.id, LabelDealStyle.ownership, forceAccept: true),
        isNull,
      );
    }
    expect(game.activeRoster.length, RecordLabels.maxRosterSize);

    final extra = game.worldArtists.firstWhere(
      (a) => a.id != 'player' && !game.isOnRoster(a.id),
    );
    expect(game.signArtist(extra.id, LabelDealStyle.standard), contains('Roster full'));
  });

  test('signed artist demos sit off the charts until released', () {
    final artist = signableNpc();
    expect(
      game.signArtist(artist.id, LabelDealStyle.standard, forceAccept: true),
      isNull,
    );
    expect(game.commissionRosterDemo(artist.id), isNull);
    final demo = game.worldSongs.last;
    expect(demo.released, isFalse);
    expect(demo.artistId, artist.id);
    expect(game.getTopSongs(50).any((s) => s.id == demo.id), isFalse);
    expect(game.catalogSongsFor(artist.id), contains(demo));

    expect(game.releaseRosterSong(demo.id), isNull);
    expect(demo.released, isTrue);
    expect(game.getTopSongs(50).any((s) => s.id == demo.id), isTrue);
  });

  test('collab demo credits player and signed artist', () {
    final artist = signableNpc();
    game.signArtist(artist.id, LabelDealStyle.standard, forceAccept: true);
    expect(
      game.commissionRosterDemo(artist.id, collabArtistId: 'player'),
      isNull,
    );
    final demo = game.worldSongs.last;
    expect(demo.creditsArtist('player'), isTrue);
    expect(demo.creditsArtist(artist.id), isTrue);
    expect(game.songCredit(demo), contains('ft.'));
  });

  test('pitching a track can sign the player to a named indie label', () {
    game.worldSongs.add(Song(
      id: 'pitch_hit',
      title: 'Harbor Night',
      artistId: 'player',
      popularityFactor: 88,
      viralFactor: 70,
      released: true,
    ));
    expect(
      game.pitchTrackToLabel(
        'pitch_hit',
        'cassette_heart',
        deal: LabelDealStyle.ownership,
        forceAccept: true,
      ),
      isNull,
    );
    expect(game.playerLabelId, 'cassette_heart');
    expect(game.player!.labelTier, LabelTier.indie);
    expect(game.labelDealStyle, LabelDealStyle.ownership);
    expect(
      game.pitchTrackToLabel('pitch_hit', 'cassette_heart'),
      contains('A&R already heard you'),
    );
  });

  test('too-small royalty is rejected with a suggestion and no cash taken', () {
    final artist = signableNpc();
    artist.labelTier = LabelTier.major;
    artist.attributes['popularity'] = 80;
    game.player!.labelTier = LabelTier.indie;
    final cash = game.playerMoney;
    final err = game.signArtist(
      artist.id,
      LabelDealStyle.advance,
      artistKeep: 0.30,
    );
    expect(err, isNotNull);
    expect(err, contains('too small'));
    expect(err, contains('at least'));
    expect(game.playerMoney, cash);
    expect(game.isOnRoster(artist.id), isFalse);
  });

  test('meeting the royalty floor signs the artist', () {
    final artist = signableNpc();
    artist.labelTier = LabelTier.unsigned;
    artist.attributes['popularity'] = 10;
    expect(
      game.signArtist(
        artist.id,
        LabelDealStyle.standard,
        artistKeep: 0.55,
      ),
      isNull,
    );
    expect(game.isOnRoster(artist.id), isTrue);
    expect(game.rosterFor(artist.id)!.artistKeep, closeTo(0.55, 0.011));
  });

  test('signed artist can be renamed and dressed', () {
    final artist = signableNpc();
    game.signArtist(
      artist.id,
      LabelDealStyle.ownership,
      forceAccept: true,
    );
    expect(game.renameRosterArtist(artist.id, 'Nova Vox'), isNull);
    expect(artist.name, 'Nova Vox');
    expect(game.renameRosterArtist(artist.id, 'x'), contains('2 letters'));

    const look = ArtistAppearance(
      outfitStyleIndex: 3,
      outfitColorIndex: 2,
      accessoryIndex: 3,
    );
    expect(game.updateRosterAppearance(artist.id, look), isNull);
    expect(artist.appearance.outfitStyleIndex, 3);
    expect(artist.appearance.outfitColorIndex, 2);
    expect(artist.appearance.accessoryIndex, 3);

    final outsider = game.worldArtists.firstWhere(
      (a) => a.id != 'player' && !game.isOnRoster(a.id),
    );
    expect(game.renameRosterArtist(outsider.id, 'Nope'), contains('Only signed'));
  });
}
