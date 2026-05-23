import 'package:flutter/material.dart';

class ArtistAppearance {
  final int skinToneIndex;
  final int hairStyleIndex;
  final int hairColorIndex;
  final int outfitStyleIndex;
  final int outfitColorIndex;
  final int accessoryIndex;
  final int bodyTypeIndex;

  const ArtistAppearance({
    this.skinToneIndex = 2,
    this.hairStyleIndex = 0,
    this.hairColorIndex = 0,
    this.outfitStyleIndex = 0,
    this.outfitColorIndex = 0,
    this.accessoryIndex = 0,
    this.bodyTypeIndex = 1,
  });

  static const defaults = ArtistAppearance();

  ArtistAppearance copyWith({
    int? skinToneIndex,
    int? hairStyleIndex,
    int? hairColorIndex,
    int? outfitStyleIndex,
    int? outfitColorIndex,
    int? accessoryIndex,
    int? bodyTypeIndex,
  }) {
    return ArtistAppearance(
      skinToneIndex: skinToneIndex ?? this.skinToneIndex,
      hairStyleIndex: hairStyleIndex ?? this.hairStyleIndex,
      hairColorIndex: hairColorIndex ?? this.hairColorIndex,
      outfitStyleIndex: outfitStyleIndex ?? this.outfitStyleIndex,
      outfitColorIndex: outfitColorIndex ?? this.outfitColorIndex,
      accessoryIndex: accessoryIndex ?? this.accessoryIndex,
      bodyTypeIndex: bodyTypeIndex ?? this.bodyTypeIndex,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'skinToneIndex': skinToneIndex,
      'hairStyleIndex': hairStyleIndex,
      'hairColorIndex': hairColorIndex,
      'outfitStyleIndex': outfitStyleIndex,
      'outfitColorIndex': outfitColorIndex,
      'accessoryIndex': accessoryIndex,
      'bodyTypeIndex': bodyTypeIndex,
    };
  }

  factory ArtistAppearance.fromMap(Map<String, dynamic> map) {
    return ArtistAppearance(
      skinToneIndex: map['skinToneIndex'] ?? 2,
      hairStyleIndex: map['hairStyleIndex'] ?? 0,
      hairColorIndex: map['hairColorIndex'] ?? 0,
      outfitStyleIndex: map['outfitStyleIndex'] ?? 0,
      outfitColorIndex: map['outfitColorIndex'] ?? 0,
      accessoryIndex: map['accessoryIndex'] ?? 0,
      bodyTypeIndex: map['bodyTypeIndex'] ?? 1,
    );
  }
}

class CharacterOption<T> {
  final String label;
  final T value;
  final Color? previewColor;
  final IconData? icon;

  const CharacterOption({
    required this.label,
    required this.value,
    this.previewColor,
    this.icon,
  });
}
