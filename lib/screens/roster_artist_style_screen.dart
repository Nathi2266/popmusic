import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/character_customization_data.dart';
import '../models/artist_appearance.dart';
import '../services/game_state_service.dart';
import '../utils/toast_service.dart';
import '../widgets/artist_character_avatar.dart';
import '../widgets/character_option_selector.dart';

class RosterArtistStyleScreen extends StatefulWidget {
  final String artistId;

  const RosterArtistStyleScreen({super.key, required this.artistId});

  @override
  State<RosterArtistStyleScreen> createState() =>
      _RosterArtistStyleScreenState();
}

class _RosterArtistStyleScreenState extends State<RosterArtistStyleScreen> {
  late final TextEditingController _nameController;
  late ArtistAppearance _appearance;
  var _ready = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final game = Provider.of<GameStateService>(context, listen: false);
      final artist = game.getArtistById(widget.artistId);
      if (artist == null) return;
      setState(() {
        _nameController.text = artist.name;
        _appearance = artist.appearance;
        _ready = true;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameStateService>(
      builder: (context, game, _) {
        final artist = game.getArtistById(widget.artistId);
        if (artist == null) {
          return Scaffold(
            appBar: AppBar(title: Text('Style')),
            body: const Center(child: Text('Artist not found')),
          );
        }
        if (!_ready) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Artist style'),
                          ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text('Name & look'),
                      ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: ArtistCharacterAvatar(
                  appearance: _appearance,
                  size: 160,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                maxLength: 24,
                decoration: InputDecoration(
                  labelText: 'Stage name',
                  labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.72)),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  counterStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'OUTFIT',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              CharacterOptionSelector(
                title: 'Look',
                options: CharacterCustomizationData.outfitStyles,
                selectedIndex: _appearance.outfitStyleIndex,
                onSelected: (value) => setState(
                  () => _appearance =
                      _appearance.copyWith(outfitStyleIndex: value),
                ),
              ),
              const SizedBox(height: 18),
              CharacterOptionSelector(
                title: 'Color',
                options: CharacterCustomizationData.outfitColors,
                selectedIndex: _appearance.outfitColorIndex,
                onSelected: (value) => setState(
                  () => _appearance =
                      _appearance.copyWith(outfitColorIndex: value),
                ),
              ),
              const SizedBox(height: 18),
              CharacterOptionSelector(
                title: 'Accessory',
                options: CharacterCustomizationData.accessories,
                selectedIndex: _appearance.accessoryIndex,
                onSelected: (value) => setState(
                  () =>
                      _appearance = _appearance.copyWith(accessoryIndex: value),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final nameErr = game.renameRosterArtist(
                      widget.artistId,
                      _nameController.text,
                    );
                    if (nameErr != null) {
                      ToastService().showError(nameErr);
                      return;
                    }
                    final lookErr = game.updateRosterAppearance(
                      widget.artistId,
                      _appearance,
                    );
                    if (lookErr != null) {
                      ToastService().showError(lookErr);
                      return;
                    }
                    ToastService().showSuccess('Look saved');
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.check),
                  label: Text('Save name & outfit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
