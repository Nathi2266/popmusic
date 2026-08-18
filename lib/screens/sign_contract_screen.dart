import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/record_labels.dart';
import '../models/label_tier.dart';
import '../models/record_label.dart';
import '../services/game_state_service.dart';
import '../utils/toast_service.dart';
import '../widgets/artist_character_avatar.dart';

class SignContractScreen extends StatefulWidget {
  final String artistId;

  const SignContractScreen({super.key, required this.artistId});

  @override
  State<SignContractScreen> createState() => _SignContractScreenState();
}

class _SignContractScreenState extends State<SignContractScreen> {
  double _artistKeep = RosterSigning.artistKeepForDeal(LabelDealStyle.standard);

  @override
  Widget build(BuildContext context) {
    return Consumer<GameStateService>(
      builder: (context, game, _) {
        final artist = game.getArtistById(widget.artistId);
        if (artist == null) {
          return Scaffold(
            appBar: AppBar(title: Text('Contract')),
            body: const Center(child: Text('Artist not found')),
          );
        }

        final eval = game.evaluateRosterContract(artist, _artistKeep);
        final minPct = (eval.minArtistKeep * 100).round();
        final offeredPct = (_artistKeep * 100).round();
        final rosterFull =
            game.activeRoster.length >= RecordLabels.maxRosterSize;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text('Signing Contract'),
                      ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: ArtistCharacterAvatar(
                  appearance: artist.appearance,
                  size: 140,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                artist.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${artist.labelTier.displayName} · Pop '
                '${(artist.attributes['popularity'] ?? 0).toStringAsFixed(0)}% · '
                'expects ≥ $minPct% royalties',
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.72), fontSize: 14),
              ),
              const SizedBox(height: 20),
              Text(
                'ROYALTY SPLIT',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This is what they keep of their streams. You keep the rest.',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54), fontSize: 13),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: LabelDealStyle.values.map((deal) {
                  final keep = RosterSigning.artistKeepForDeal(deal);
                  final selected = (keep - _artistKeep).abs() < 0.011;
                  return ChoiceChip(
                    label: Text(
                      '${deal.displayName} · ${(keep * 100).round()}%',
                    ),
                    selected: selected,
                    selectedColor: Theme.of(context).colorScheme.primary,
                    labelStyle: TextStyle(
                      color: selected
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.72),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    onSelected: (_) => setState(() => _artistKeep = keep),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              Semantics(
                label: 'Artist royalties $offeredPct percent',
                value: '$offeredPct percent',
                slider: true,
                child: Slider(
                  value: _artistKeep,
                  min: 0.20,
                  max: 0.85,
                  divisions: 65,
                  activeColor: const Color(0xFFFFD700),
                  label: '$offeredPct%',
                  onChanged: (value) => setState(() => _artistKeep = value),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'They keep $offeredPct%',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  ),
                  Text(
                    'You keep ${((1 - _artistKeep) * 100).round()}%',
                    style: TextStyle(color: Color(0xFFFFD700)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: eval.acceptable
                      ? const Color(0xFF66BB6A).withAlpha(40)
                      : Theme.of(context).colorScheme.primary.withAlpha(40),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: eval.acceptable
                        ? const Color(0xFF66BB6A)
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eval.acceptable ? 'They will sign' : 'Deal is too small',
                      style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      eval.message,
                      style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface, height: 1.35),
                    ),
                    if (eval.suggestion != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        eval.suggestion!,
                        style: TextStyle(
                          color: Color(0xFFFFD700),
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () => setState(
                          () => _artistKeep = eval.minArtistKeep,
                        ),
                        child: Text('Raise to $minPct%'),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Signing bonus \$${eval.signingCost.toStringAsFixed(0)}',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.72)),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: rosterFull || !eval.acceptable
                      ? null
                      : () {
                          final err = game.signArtist(
                            widget.artistId,
                            RosterSigning.closestDeal(_artistKeep),
                            artistKeep: _artistKeep,
                          );
                          if (err != null) {
                            ToastService().showError(err);
                            return;
                          }
                          ToastService().showSuccess('${artist.name} signed');
                          Navigator.pop(context);
                        },
                  icon: Icon(Icons.edit_note),
                  label: Text(
                    rosterFull
                        ? 'Roster full (${RecordLabels.maxRosterSize})'
                        : eval.acceptable
                            ? 'Sign ${artist.name}'
                            : 'Adjust the contract first',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    disabledBackgroundColor: Theme.of(context).colorScheme.surface,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
