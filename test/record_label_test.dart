import 'package:flutter_test/flutter_test.dart';
import 'package:popmusic/data/record_labels.dart';
import 'package:popmusic/models/artist.dart';
import 'package:popmusic/models/label_tier.dart';
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
    final signedNpcs = game.worldArtists.where(
      (a) => a.id != 'player' && a.labelTier != LabelTier.unsigned,
    );
    expect(signedNpcs.every((a) => a.labelId.isNotEmpty), isTrue);
    expect(game.visibleLabels().length, RecordLabels.catalog.length + 1);
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
}
