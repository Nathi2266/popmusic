import 'package:flutter/material.dart';
import '../models/artist_appearance.dart';

class CharacterCustomizationData {
  static const skinTones = [
    CharacterOption(label: 'Porcelain', value: 0, previewColor: Color(0xFFFFE0D0)),
    CharacterOption(label: 'Light', value: 1, previewColor: Color(0xFFF1C9A5)),
    CharacterOption(label: 'Warm', value: 2, previewColor: Color(0xFFD9A066)),
    CharacterOption(label: 'Tan', value: 3, previewColor: Color(0xFFC68642)),
    CharacterOption(label: 'Brown', value: 4, previewColor: Color(0xFF8D5524)),
    CharacterOption(label: 'Deep', value: 5, previewColor: Color(0xFF5C3317)),
    CharacterOption(label: 'Ebony', value: 6, previewColor: Color(0xFF3B2213)),
  ];

  static const hairStyles = [
    CharacterOption(label: 'Short', value: 0, icon: Icons.content_cut),
    CharacterOption(label: 'Long', value: 1, icon: Icons.waves),
    CharacterOption(label: 'Curly', value: 2, icon: Icons.blur_circular),
    CharacterOption(label: 'Buzz', value: 3, icon: Icons.circle_outlined),
    CharacterOption(label: 'Afro', value: 4, icon: Icons.bubble_chart),
    CharacterOption(label: 'Braids', value: 5, icon: Icons.view_stream),
    CharacterOption(label: 'Ponytail', value: 6, icon: Icons.arrow_upward),
  ];

  static const hairColors = [
    CharacterOption(label: 'Black', value: 0, previewColor: Color(0xFF1A1410)),
    CharacterOption(label: 'Brown', value: 1, previewColor: Color(0xFF5C3A21)),
    CharacterOption(label: 'Auburn', value: 2, previewColor: Color(0xFF8B3A2A)),
    CharacterOption(label: 'Blonde', value: 3, previewColor: Color(0xFFE6C27A)),
    CharacterOption(label: 'Platinum', value: 4, previewColor: Color(0xFFF5F0E8)),
    CharacterOption(label: 'Red', value: 5, previewColor: Color(0xFFB83232)),
    CharacterOption(label: 'Pink', value: 6, previewColor: Color(0xFFE94560)),
    CharacterOption(label: 'Blue', value: 7, previewColor: Color(0xFF3D5AFE)),
    CharacterOption(label: 'Purple', value: 8, previewColor: Color(0xFF7B1FA2)),
  ];

  static const outfitStyles = [
    CharacterOption(label: 'Streetwear', value: 0, icon: Icons.checkroom),
    CharacterOption(label: 'Stage', value: 1, icon: Icons.star),
    CharacterOption(label: 'Casual', value: 2, icon: Icons.weekend),
    CharacterOption(label: 'Luxury', value: 3, icon: Icons.diamond),
    CharacterOption(label: 'Punk', value: 4, icon: Icons.bolt),
    CharacterOption(label: 'Vintage', value: 5, icon: Icons.album),
  ];

  static const outfitColors = [
    CharacterOption(label: 'Coral', value: 0, previewColor: Color(0xFFe94560)),
    CharacterOption(label: 'Midnight', value: 1, previewColor: Color(0xFF16213e)),
    CharacterOption(label: 'Gold', value: 2, previewColor: Color(0xFFFFB347)),
    CharacterOption(label: 'Emerald', value: 3, previewColor: Color(0xFF2ECC71)),
    CharacterOption(label: 'Violet', value: 4, previewColor: Color(0xFF9B59B6)),
    CharacterOption(label: 'Ice', value: 5, previewColor: Color(0xFFECF0F1)),
    CharacterOption(label: 'Crimson', value: 6, previewColor: Color(0xFFC0392B)),
    CharacterOption(label: 'Teal', value: 7, previewColor: Color(0xFF1ABC9C)),
  ];

  static const accessories = [
    CharacterOption(label: 'None', value: 0, icon: Icons.block),
    CharacterOption(label: 'Shades', value: 1, icon: Icons.visibility_off),
    CharacterOption(label: 'Cap', value: 2, icon: Icons.sports_baseball),
    CharacterOption(label: 'Chain', value: 3, icon: Icons.link),
    CharacterOption(label: 'Earrings', value: 4, icon: Icons.hearing),
    CharacterOption(label: 'Headphones', value: 5, icon: Icons.headphones),
    CharacterOption(label: 'Mic', value: 6, icon: Icons.mic),
  ];

  static const bodyTypes = [
    CharacterOption(label: 'Slim', value: 0, icon: Icons.height),
    CharacterOption(label: 'Average', value: 1, icon: Icons.person),
    CharacterOption(label: 'Athletic', value: 2, icon: Icons.fitness_center),
  ];

  static Color skinToneColor(int index) {
    return skinTones[index.clamp(0, skinTones.length - 1)].previewColor!;
  }

  static Color hairColor(int index) {
    return hairColors[index.clamp(0, hairColors.length - 1)].previewColor!;
  }

  static Color outfitColor(int index) {
    return outfitColors[index.clamp(0, outfitColors.length - 1)].previewColor!;
  }

  static Color outfitSecondaryColor(int index) {
    final base = outfitColor(index);
    return Color.lerp(base, Colors.black, 0.35)!;
  }
}
