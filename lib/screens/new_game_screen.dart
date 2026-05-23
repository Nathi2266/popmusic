import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/character_customization_data.dart';
import '../models/artist_appearance.dart';
import '../services/game_state_service.dart';
import '../utils/toast_service.dart';
import '../widgets/artist_character_avatar.dart';
import '../widgets/character_option_selector.dart';
import 'game_screen.dart';

class NewGameScreen extends StatefulWidget {
  const NewGameScreen({super.key});

  @override
  State<NewGameScreen> createState() => _NewGameScreenState();
}

class _NewGameScreenState extends State<NewGameScreen> {
  final _nameController = TextEditingController();
  ArtistAppearance _appearance = ArtistAppearance.defaults;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _updateAppearance(ArtistAppearance Function(ArtistAppearance current) update) {
    setState(() => _appearance = update(_appearance));
  }

  void _startGame() {
    if (_nameController.text.trim().isEmpty) {
      ToastService().showError('Please enter your artist name');
      return;
    }

    final gameState = Provider.of<GameStateService>(context, listen: false);
    gameState.startNewGame(
      _nameController.text.trim(),
      appearance: _appearance,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const GameScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Your Artist'),
        backgroundColor: const Color(0xFF16213e),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1a1a2e),
              Color(0xFF16213e),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _CharacterPreviewCard(appearance: _appearance),
                      const SizedBox(height: 24),
                      const Text(
                        'Artist Name',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _nameController,
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          hintText: 'Enter your stage name',
                          hintStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.35),
                          ),
                          filled: true,
                          fillColor: const Color(0xFF2a2a3e),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      _CustomizationPanel(
                        title: 'APPEARANCE',
                        children: [
                          CharacterOptionSelector(
                            title: 'Skin Tone',
                            options: CharacterCustomizationData.skinTones,
                            selectedIndex: _appearance.skinToneIndex,
                            onSelected: (value) => _updateAppearance(
                              (current) => current.copyWith(skinToneIndex: value),
                            ),
                          ),
                          const SizedBox(height: 18),
                          CharacterOptionSelector(
                            title: 'Body Type',
                            options: CharacterCustomizationData.bodyTypes,
                            selectedIndex: _appearance.bodyTypeIndex,
                            onSelected: (value) => _updateAppearance(
                              (current) => current.copyWith(bodyTypeIndex: value),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _CustomizationPanel(
                        title: 'HAIR',
                        children: [
                          CharacterOptionSelector(
                            title: 'Hair Style',
                            options: CharacterCustomizationData.hairStyles,
                            selectedIndex: _appearance.hairStyleIndex,
                            onSelected: (value) => _updateAppearance(
                              (current) => current.copyWith(hairStyleIndex: value),
                            ),
                          ),
                          const SizedBox(height: 18),
                          CharacterOptionSelector(
                            title: 'Hair Color',
                            options: CharacterCustomizationData.hairColors,
                            selectedIndex: _appearance.hairColorIndex,
                            onSelected: (value) => _updateAppearance(
                              (current) => current.copyWith(hairColorIndex: value),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _CustomizationPanel(
                        title: 'STYLE',
                        children: [
                          CharacterOptionSelector(
                            title: 'Outfit',
                            options: CharacterCustomizationData.outfitStyles,
                            selectedIndex: _appearance.outfitStyleIndex,
                            onSelected: (value) => _updateAppearance(
                              (current) => current.copyWith(outfitStyleIndex: value),
                            ),
                          ),
                          const SizedBox(height: 18),
                          CharacterOptionSelector(
                            title: 'Outfit Color',
                            options: CharacterCustomizationData.outfitColors,
                            selectedIndex: _appearance.outfitColorIndex,
                            onSelected: (value) => _updateAppearance(
                              (current) => current.copyWith(outfitColorIndex: value),
                            ),
                          ),
                          const SizedBox(height: 18),
                          CharacterOptionSelector(
                            title: 'Accessory',
                            options: CharacterCustomizationData.accessories,
                            selectedIndex: _appearance.accessoryIndex,
                            onSelected: (value) => _updateAppearance(
                              (current) => current.copyWith(accessoryIndex: value),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: SizedBox(
                  height: 58,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _startGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFe94560),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                    ),
                    child: const Text(
                      'START CAREER',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.4,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CharacterPreviewCard extends StatelessWidget {
  final ArtistAppearance appearance;

  const _CharacterPreviewCard({required this.appearance});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.08),
            Colors.white.withValues(alpha: 0.03),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFe94560).withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'YOUR ARTIST',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 8),
          ArtistCharacterAvatar(appearance: appearance, size: 210),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _PreviewTag(
                label: CharacterCustomizationData.skinTones[
                        appearance.skinToneIndex.clamp(
                          0,
                          CharacterCustomizationData.skinTones.length - 1,
                        )]
                    .label,
              ),
              _PreviewTag(
                label: CharacterCustomizationData.hairStyles[
                        appearance.hairStyleIndex.clamp(
                          0,
                          CharacterCustomizationData.hairStyles.length - 1,
                        )]
                    .label,
              ),
              _PreviewTag(
                label: CharacterCustomizationData.outfitStyles[
                        appearance.outfitStyleIndex.clamp(
                          0,
                          CharacterCustomizationData.outfitStyles.length - 1,
                        )]
                    .label,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PreviewTag extends StatelessWidget {
  final String label;

  const _PreviewTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.75),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _CustomizationPanel extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _CustomizationPanel({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.5,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}
