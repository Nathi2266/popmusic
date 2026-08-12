import 'package:flutter_test/flutter_test.dart';
import 'package:popmusic/models/lifestyle.dart';
import 'package:popmusic/models/label_tier.dart';
import 'package:popmusic/services/game_state_service.dart';

void main() {
  late GameStateService game;

  setUp(() {
    game = GameStateService();
    game.startNewGame('Tester');
  });

  test('catalog yield math', () {
    final merch = InvestmentVehicle.byId('merch_co')!;
    final pay = merch.weeklyYield(
      principal: 8000,
      fans: 1000,
      royalties: 200,
    );
    expect(pay, closeTo(8000 * 0.0035 + 1000 * 0.025, 0.01));
  });

  test('cannot buy luxury twice or without cash', () {
    expect(game.buyLuxury('gold_chain'), contains('Need'));
    game.playerMoney = 20000;
    expect(game.buyLuxury('gold_chain'), isNull);
    expect(game.ownsAsset('gold_chain'), isTrue);
    expect(game.buyLuxury('gold_chain'), 'Already own this');
    expect(game.weeklyAssetUpkeep, 25);
  });

  test('hypercar is label gated', () {
    game.playerMoney = 2000000;
    game.player!.attributes['popularity'] = 80;
    expect(game.buyLuxury('hypercar'), 'Need Major');
  });

  test('index fund min buy, top-up, weekly settle, cash out', () {
    game.playerMoney = 10000;
    expect(game.investMoney('index', 1000), contains('Min'));
    expect(game.investMoney('index', 2500), isNull);
    expect(game.investmentFor('index')!.principal, 2500);
    expect(game.investMoney('index', 400), 'Min \$500 top-up');
    expect(game.investMoney('index', 1500), isNull);
    expect(game.investmentFor('index')!.principal, 4000);

    final before = game.playerMoney;
    game.proceedWeek();
    expect(game.lastWeekPassive, greaterThan(0));
    expect(game.playerMoney, greaterThan(before));

    final cash = game.playerMoney;
    expect(game.cashOutInvestment('index'), isNull);
    expect(game.investmentFor('index'), isNull);
    expect(game.playerMoney, closeTo(cash + 4000 * 0.90, 0.01));
  });

  test('studio needs indie', () {
    game.playerMoney = 50000;
    expect(game.investMoney('studio', 18000), 'Need Indie');
    game.player!.labelTier = LabelTier.indie;
    expect(game.investMoney('studio', 18000), isNull);
  });

  test('upkeep can bounce bills', () {
    game.ownedAssetIds.add('yacht');
    game.playerMoney = 10;
    game.proceedWeek();
    expect(game.lastWeekUpkeep, 7000);
    expect(game.playerMoney, lessThan(0));
  });
}
