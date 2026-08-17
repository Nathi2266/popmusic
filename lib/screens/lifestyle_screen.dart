import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/lifestyle.dart';
import '../models/label_tier.dart';
import '../services/game_state_service.dart';
import '../utils/toast_service.dart';

class LifestyleScreen extends StatefulWidget {
  const LifestyleScreen({super.key});

  @override
  State<LifestyleScreen> createState() => _LifestyleScreenState();
}

class _LifestyleScreenState extends State<LifestyleScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<GameStateService>(
      builder: (context, game, _) {
        final player = game.player;
        if (player == null) {
          return const Scaffold(
            body: Center(child: Text('No player data')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Lifestyle'),
                      ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: _MoneyStrip(game: game),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _TabChip(
                        label: 'Assets',
                        selected: _tab == 0,
                        onTap: () => setState(() => _tab = 0),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _TabChip(
                        label: 'Invest',
                        selected: _tab == 1,
                        onTap: () => setState(() => _tab = 1),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _tab == 0
                    ? _AssetsList(game: game)
                    : _InvestList(game: game),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MoneyStrip extends StatelessWidget {
  final GameStateService game;

  const _MoneyStrip({required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Theme.of(context).colorScheme.surface, Theme.of(context).colorScheme.surface],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFD700).withAlpha(80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cash \$${game.playerMoney.toStringAsFixed(0)}',
            style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Net worth \$${game.lifestyleNetWorth.toStringAsFixed(0)} · '
            'Passive \$${game.projectedInvestmentYield().toStringAsFixed(0)}/wk · '
            'Bills \$${game.weeklyAssetUpkeep.toStringAsFixed(0)}/wk',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.72), fontSize: 13),
          ),
          if (game.lastWeekPassive > 0 || game.lastWeekUpkeep > 0) ...[
            const SizedBox(height: 6),
            Text(
              'Last week: +\$${game.lastWeekPassive.toStringAsFixed(0)} '
              '− \$${game.lastWeekUpkeep.toStringAsFixed(0)}',
              style: TextStyle(color: Color(0xFFFFD700), fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? Colors.white : Colors.white70,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _AssetsList extends StatelessWidget {
  final GameStateService game;

  const _AssetsList({required this.game});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Text(
          'Flex cash on jewelry, cars, houses, and toys. '
          'Each piece is unique. Upkeep hits every week. Wealth bump feeds merch.',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54), fontSize: 13),
        ),
        const SizedBox(height: 12),
        ...LuxuryCategory.values.map((cat) {
          final items =
              LuxuryAsset.catalog.where((a) => a.category == cat).toList();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: Text(
                  cat.displayName.toUpperCase(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    fontSize: 13,
                  ),
                ),
              ),
              ...items.map((asset) => _AssetCard(asset: asset, game: game)),
            ],
          );
        }),
      ],
    );
  }
}

class _AssetCard extends StatelessWidget {
  final LuxuryAsset asset;
  final GameStateService game;

  const _AssetCard({required this.asset, required this.game});

  @override
  Widget build(BuildContext context) {
    final owned = game.ownsAsset(asset.id);
    final player = game.player!;
    final pop = player.attributes['popularity'] ?? 0;
    final gated = pop < asset.popularityRequired ||
        !labelMeets(player.labelTier, asset.minLabel);
    final canPay = game.playerMoney >= asset.price;
    final gateText = [
      if (asset.popularityRequired > 0) '${asset.popularityRequired} pop',
      if (asset.minLabel != LabelTier.unsigned) asset.minLabel.displayName,
    ].join(' · ');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: owned
              ? const Color(0xFFFFD700)
              : Colors.white24,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  asset.name,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '\$${asset.price.toStringAsFixed(0)}',
                style: TextStyle(
                  color: canPay || owned
                      ? const Color(0xFFFFD700)
                      : Colors.white38,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            asset.blurb,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.72), fontSize: 13),
          ),
          const SizedBox(height: 6),
          Text(
            'Upkeep \$${asset.weeklyUpkeep.toStringAsFixed(0)}/wk'
            '${_statLine(asset)}'
            '${gateText.isEmpty ? '' : ' · $gateText'}',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54), fontSize: 12),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: owned
                ? Text(
                    'OWNED',
                    style: TextStyle(
                      color: Color(0xFFFFD700),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  )
                : TextButton(
                    onPressed: gated
                        ? null
                        : () {
                            final err = game.buyLuxury(asset.id);
                            if (err != null) {
                              ToastService().showError(err);
                            } else {
                              ToastService().showSuccess('Bought ${asset.name}');
                            }
                          },
                    child: Text(
                      gated ? 'Locked' : 'Buy',
                      style: TextStyle(
                        color: gated
                            ? Colors.white38
                            : Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  String _statLine(LuxuryAsset asset) {
    final bits = <String>[];
    if (asset.popularity != 0) {
      bits.add('+${asset.popularity.toStringAsFixed(0)} pop');
    }
    if (asset.wealth != 0) {
      bits.add('+${asset.wealth.toStringAsFixed(0)} wealth');
    }
    if (asset.charisma != 0) {
      bits.add('+${asset.charisma.toStringAsFixed(0)} charisma');
    }
    if (asset.influence != 0) {
      bits.add('+${asset.influence.toStringAsFixed(0)} influence');
    }
    if (bits.isEmpty) return '';
    return ' · ${bits.join(' · ')}';
  }
}

class _InvestList extends StatelessWidget {
  final GameStateService game;

  const _InvestList({required this.game});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Text(
          'Park cash in funds and businesses. Yield hits every week. '
          'Cash out at 90% if you need the money back.',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54), fontSize: 13),
        ),
        const SizedBox(height: 12),
        ...InvestmentVehicle.catalog.map(
          (v) => _InvestCard(vehicle: v, game: game),
        ),
      ],
    );
  }
}

class _InvestCard extends StatelessWidget {
  final InvestmentVehicle vehicle;
  final GameStateService game;

  const _InvestCard({required this.vehicle, required this.game});

  @override
  Widget build(BuildContext context) {
    final owned = game.investmentFor(vehicle.id);
    final player = game.player!;
    final gated = !labelMeets(player.labelTier, vehicle.minLabel);
    final projected = vehicle.weeklyYield(
      principal: owned?.principal ?? vehicle.minBuy,
      fans: game.playerFanCount,
      royalties: game.lastWeekRoyalties,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: owned != null
              ? const Color(0xFF4CAF50).withAlpha(180)
              : Colors.white24,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            vehicle.name,
            style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            vehicle.blurb,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.72), fontSize: 13),
          ),
          const SizedBox(height: 6),
          Text(
            owned == null
                ? 'Min \$${vehicle.minBuy.toStringAsFixed(0)} · '
                    '~${(vehicle.weeklyRate * 100).toStringAsFixed(2)}%/wk'
                    '${vehicle.minLabel == LabelTier.unsigned ? '' : ' · ${vehicle.minLabel.displayName}'}'
                    ' · ~\$${projected.toStringAsFixed(0)}/wk at min'
                : 'In \$${owned.principal.toStringAsFixed(0)} · '
                    '~\$${vehicle.weeklyYield(principal: owned.principal, fans: game.playerFanCount, royalties: game.lastWeekRoyalties).toStringAsFixed(0)}/wk',
            style: TextStyle(color: Color(0xFF4CAF50), fontSize: 12),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (owned != null)
                TextButton(
                  onPressed: () {
                    final err = game.cashOutInvestment(vehicle.id);
                    if (err != null) {
                      ToastService().showError(err);
                    } else {
                      ToastService().showSuccess('Cashed out ${vehicle.name}');
                    }
                  },
                  child: Text(
                    'Cash out 90%',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54)),
                  ),
                ),
              TextButton(
                onPressed: gated
                    ? null
                    : () => _promptInvest(context, game, vehicle, owned != null),
                child: Text(
                  gated
                      ? 'Need ${vehicle.minLabel.displayName}'
                      : owned == null
                          ? 'Invest'
                          : 'Add cash',
                  style: TextStyle(
                    color: gated ? Colors.white38 : Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _promptInvest(
    BuildContext context,
    GameStateService game,
    InvestmentVehicle vehicle,
    bool toppingUp,
  ) {
    final min = toppingUp ? 500.0 : vehicle.minBuy;
    final cash = game.playerMoney;
    showDialog<void>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController(
          text: min.toStringAsFixed(0),
        );
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            toppingUp ? 'Add to ${vehicle.name}' : 'Open ${vehicle.name}',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cash \$${cash.toStringAsFixed(0)}. Min \$${min.toStringAsFixed(0)}.',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.72), fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'Amount',
                  labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54)),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _preset(controller, min),
                  if (cash >= min * 2) _preset(controller, min * 2),
                  if (cash >= min * 5) _preset(controller, min * 5),
                  if (cash >= min) _preset(controller, cash),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final amount = double.tryParse(controller.text.trim()) ?? 0;
                Navigator.pop(ctx);
                final err = game.investMoney(vehicle.id, amount);
                if (err != null) {
                  ToastService().showError(err);
                } else {
                  ToastService().showSuccess(
                    'Parked \$${amount.toStringAsFixed(0)}',
                  );
                }
              },
              child: Text(
                'Confirm',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _preset(TextEditingController controller, double value) {
    return ActionChip(
      label: Text('\$${value.toStringAsFixed(0)}'),
      onPressed: () => controller.text = value.toStringAsFixed(0),
    );
  }
}
