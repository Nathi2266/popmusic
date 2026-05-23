import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../data/character_customization_data.dart';
import '../models/artist_appearance.dart';

class ArtistCharacterAvatar extends StatelessWidget {
  final ArtistAppearance appearance;
  final double size;

  const ArtistCharacterAvatar({
    super.key,
    required this.appearance,
    this.size = 240,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.25,
      child: CustomPaint(
        painter: _ArtistCharacterPainter(appearance: appearance),
      ),
    );
  }
}

class _ArtistCharacterPainter extends CustomPainter {
  final ArtistAppearance appearance;

  _ArtistCharacterPainter({required this.appearance});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final scale = size.width / 220;
    canvas.save();
    canvas.translate(centerX, size.height * 0.08);

    _drawStageGlow(canvas, size, scale);
    _drawBody(canvas, scale);
    _drawHead(canvas, scale);
    _drawHair(canvas, scale);
    _drawFace(canvas, scale);
    _drawAccessory(canvas, scale);

    canvas.restore();
  }

  void _drawStageGlow(Canvas canvas, Size size, double scale) {
    final glowRect = Rect.fromCenter(
      center: Offset(0, 250 * scale),
      width: 170 * scale,
      height: 28 * scale,
    );
    canvas.drawOval(
      glowRect,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFe94560).withValues(alpha: 0.35),
            const Color(0xFFe94560).withValues(alpha: 0),
          ],
        ).createShader(glowRect),
    );
  }

  void _drawBody(Canvas canvas, double scale) {
    final skin = CharacterCustomizationData.skinToneColor(appearance.skinToneIndex);
    final outfit = CharacterCustomizationData.outfitColor(appearance.outfitColorIndex);
    final outfitDark = CharacterCustomizationData.outfitSecondaryColor(
      appearance.outfitColorIndex,
    );

    final bodyScale = switch (appearance.bodyTypeIndex) {
      0 => 0.92,
      2 => 1.08,
      _ => 1.0,
    };

    final legPaint = Paint()..color = _pantsColor(outfit, outfitDark);
    final shoePaint = Paint()..color = const Color(0xFF1A1A24);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(-18 * scale * bodyScale, 205 * scale),
          width: 28 * scale * bodyScale,
          height: 88 * scale,
        ),
        Radius.circular(14 * scale),
      ),
      legPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(18 * scale * bodyScale, 205 * scale),
          width: 28 * scale * bodyScale,
          height: 88 * scale,
        ),
        Radius.circular(14 * scale),
      ),
      legPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(-18 * scale * bodyScale, 248 * scale),
          width: 34 * scale,
          height: 16 * scale,
        ),
        Radius.circular(8 * scale),
      ),
      shoePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(18 * scale * bodyScale, 248 * scale),
          width: 34 * scale,
          height: 16 * scale,
        ),
        Radius.circular(8 * scale),
      ),
      shoePaint,
    );

    _drawOutfit(canvas, scale, outfit, outfitDark, bodyScale);

    final armPaint = Paint()..color = skin;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(-52 * scale * bodyScale, 145 * scale),
          width: 18 * scale,
          height: 72 * scale,
        ),
        Radius.circular(10 * scale),
      ),
      armPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(52 * scale * bodyScale, 145 * scale),
          width: 18 * scale,
          height: 72 * scale,
        ),
        Radius.circular(10 * scale),
      ),
      armPaint,
    );

    canvas.drawCircle(Offset(-52 * scale * bodyScale, 186 * scale), 10 * scale, armPaint);
    canvas.drawCircle(Offset(52 * scale * bodyScale, 186 * scale), 10 * scale, armPaint);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(0, 108 * scale),
          width: 24 * scale,
          height: 18 * scale,
        ),
        Radius.circular(8 * scale),
      ),
      Paint()..color = skin.withValues(alpha: 0.95),
    );
  }

  Color _pantsColor(Color outfit, Color outfitDark) {
    return switch (appearance.outfitStyleIndex) {
      0 || 4 => outfitDark,
      1 => const Color(0xFF111827),
      _ => Color.lerp(outfitDark, Colors.black, 0.25)!,
    };
  }

  void _drawOutfit(
    Canvas canvas,
    double scale,
    Color outfit,
    Color outfitDark,
    double bodyScale,
  ) {
    final torsoRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(0, 138 * scale),
        width: 86 * scale * bodyScale,
        height: 92 * scale,
      ),
      Radius.circular(20 * scale),
    );

    switch (appearance.outfitStyleIndex) {
      case 0:
        _drawStreetwear(canvas, scale, torsoRect, outfit, outfitDark, bodyScale);
      case 1:
        _drawStageOutfit(canvas, scale, torsoRect, outfit, outfitDark, bodyScale);
      case 3:
        _drawLuxuryOutfit(canvas, scale, torsoRect, outfit, outfitDark, bodyScale);
      case 4:
        _drawPunkOutfit(canvas, scale, torsoRect, outfit, outfitDark, bodyScale);
      case 5:
        _drawVintageOutfit(canvas, scale, torsoRect, outfit, outfitDark, bodyScale);
      default:
        _drawCasualOutfit(canvas, scale, torsoRect, outfit, outfitDark, bodyScale);
    }
  }

  void _drawCasualOutfit(
    Canvas canvas,
    double scale,
    RRect torsoRect,
    Color outfit,
    Color outfitDark,
    double bodyScale,
  ) {
    canvas.drawRRect(torsoRect, Paint()..color = outfit);
    canvas.drawLine(
      Offset(0, 98 * scale),
      Offset(0, 182 * scale),
      Paint()
        ..color = outfitDark
        ..strokeWidth = 2 * scale,
    );
  }

  void _drawStreetwear(
    Canvas canvas,
    double scale,
    RRect torsoRect,
    Color outfit,
    Color outfitDark,
    double bodyScale,
  ) {
    canvas.drawRRect(torsoRect, Paint()..color = outfitDark);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(0, 145 * scale),
          width: 72 * scale * bodyScale,
          height: 70 * scale,
        ),
        Radius.circular(16 * scale),
      ),
      Paint()..color = outfit,
    );
    canvas.drawCircle(
      Offset(0, 118 * scale),
      8 * scale,
      Paint()..color = Colors.white.withValues(alpha: 0.8),
    );
  }

  void _drawStageOutfit(
    Canvas canvas,
    double scale,
    RRect torsoRect,
    Color outfit,
    Color outfitDark,
    double bodyScale,
  ) {
    canvas.drawRRect(torsoRect, Paint()..color = outfit);
    final shineRect = Rect.fromLTWH(
      -28 * scale * bodyScale,
      102 * scale,
      24 * scale,
      78 * scale,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(shineRect, Radius.circular(12 * scale)),
      Paint()..color = Colors.white.withValues(alpha: 0.18),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(0, 182 * scale),
          width: 70 * scale * bodyScale,
          height: 12 * scale,
        ),
        Radius.circular(6 * scale),
      ),
      Paint()..color = outfitDark,
    );
  }

  void _drawLuxuryOutfit(
    Canvas canvas,
    double scale,
    RRect torsoRect,
    Color outfit,
    Color outfitDark,
    double bodyScale,
  ) {
    canvas.drawRRect(torsoRect, Paint()..color = outfitDark);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(0, 142 * scale),
          width: 64 * scale * bodyScale,
          height: 76 * scale,
        ),
        Radius.circular(14 * scale),
      ),
      Paint()..color = outfit,
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, 102 * scale)
        ..lineTo(-12 * scale, 118 * scale)
        ..lineTo(12 * scale, 118 * scale)
        ..close(),
      Paint()..color = Colors.white.withValues(alpha: 0.75),
    );
  }

  void _drawPunkOutfit(
    Canvas canvas,
    double scale,
    RRect torsoRect,
    Color outfit,
    Color outfitDark,
    double bodyScale,
  ) {
    canvas.drawRRect(torsoRect, Paint()..color = outfit);
    final spikePaint = Paint()..color = Colors.white.withValues(alpha: 0.85);
    for (var i = -2; i <= 2; i++) {
      canvas.drawPath(
        Path()
          ..moveTo(i * 14 * scale, 102 * scale)
          ..lineTo(i * 14 * scale - 6 * scale, 92 * scale)
          ..lineTo(i * 14 * scale + 6 * scale, 92 * scale)
          ..close(),
        spikePaint,
      );
    }
    canvas.drawLine(
      Offset(-20 * scale * bodyScale, 130 * scale),
      Offset(18 * scale * bodyScale, 165 * scale),
      Paint()
        ..color = outfitDark
        ..strokeWidth = 3 * scale,
    );
  }

  void _drawVintageOutfit(
    Canvas canvas,
    double scale,
    RRect torsoRect,
    Color outfit,
    Color outfitDark,
    double bodyScale,
  ) {
    canvas.drawRRect(torsoRect, Paint()..color = outfit);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(0, 108 * scale),
          width: 92 * scale * bodyScale,
          height: 24 * scale,
        ),
        Radius.circular(8 * scale),
      ),
      Paint()..color = outfitDark,
    );
    canvas.drawCircle(
      Offset(0, 132 * scale),
      4 * scale,
      Paint()..color = const Color(0xFFFFD700),
    );
  }

  void _drawHead(Canvas canvas, double scale) {
    final skin = CharacterCustomizationData.skinToneColor(appearance.skinToneIndex);
    canvas.drawCircle(
      Offset(0, 62 * scale),
      34 * scale,
      Paint()..color = skin,
    );
    canvas.drawCircle(
      Offset(0, 62 * scale),
      34 * scale,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 * scale,
    );
  }

  void _drawHair(Canvas canvas, double scale) {
    final hair = CharacterCustomizationData.hairColor(appearance.hairColorIndex);
    final paint = Paint()..color = hair;

    switch (appearance.hairStyleIndex) {
      case 1:
        canvas.drawPath(
          Path()
            ..addOval(Rect.fromCircle(center: Offset(0, 48 * scale), radius: 36 * scale))
            ..addRect(Rect.fromLTWH(-34 * scale, 48 * scale, 68 * scale, 58 * scale)),
          paint,
        );
      case 2:
        for (var i = 0; i < 8; i++) {
          final angle = (i / 8) * math.pi * 2;
          canvas.drawCircle(
            Offset(
              math.cos(angle) * 30 * scale,
              52 * scale + math.sin(angle) * 24 * scale,
            ),
            12 * scale,
            paint,
          );
        }
      case 3:
        canvas.drawCircle(Offset(0, 52 * scale), 30 * scale, paint);
      case 4:
        canvas.drawCircle(Offset(0, 48 * scale), 42 * scale, paint);
      case 5:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(-22 * scale, 58 * scale),
              width: 14 * scale,
              height: 72 * scale,
            ),
            Radius.circular(7 * scale),
          ),
          paint,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(22 * scale, 58 * scale),
              width: 14 * scale,
              height: 72 * scale,
            ),
            Radius.circular(7 * scale),
          ),
          paint,
        );
        canvas.drawArc(
          Rect.fromCircle(center: Offset(0, 50 * scale), radius: 34 * scale),
          math.pi,
          math.pi,
          true,
          paint,
        );
      case 6:
        canvas.drawArc(
          Rect.fromCircle(center: Offset(0, 50 * scale), radius: 34 * scale),
          math.pi * 1.05,
          math.pi * 0.9,
          true,
          paint,
        );
        canvas.drawCircle(Offset(0, 18 * scale), 14 * scale, paint);
      default:
        canvas.drawArc(
          Rect.fromCircle(center: Offset(0, 52 * scale), radius: 34 * scale),
          math.pi * 1.05,
          math.pi * 0.9,
          true,
          paint,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(0, 42 * scale),
              width: 62 * scale,
              height: 24 * scale,
            ),
            Radius.circular(12 * scale),
          ),
          paint,
        );
    }
  }

  void _drawFace(Canvas canvas, double scale) {
    final eyePaint = Paint()..color = const Color(0xFF2A2030);
    canvas.drawCircle(Offset(-12 * scale, 64 * scale), 3.5 * scale, eyePaint);
    canvas.drawCircle(Offset(12 * scale, 64 * scale), 3.5 * scale, eyePaint);

    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(0, 74 * scale),
        width: 14 * scale,
        height: 8 * scale,
      ),
      0.1,
      math.pi - 0.2,
      false,
      Paint()
        ..color = const Color(0xFF8B4A42)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 * scale
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawCircle(
      Offset(-22 * scale, 72 * scale),
      5 * scale,
      Paint()..color = const Color(0xFFFF8A80).withValues(alpha: 0.25),
    );
    canvas.drawCircle(
      Offset(22 * scale, 72 * scale),
      5 * scale,
      Paint()..color = const Color(0xFFFF8A80).withValues(alpha: 0.25),
    );
  }

  void _drawAccessory(Canvas canvas, double scale) {
    switch (appearance.accessoryIndex) {
      case 1:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(0, 64 * scale),
              width: 44 * scale,
              height: 14 * scale,
            ),
            Radius.circular(7 * scale),
          ),
          Paint()..color = Colors.black.withValues(alpha: 0.85),
        );
      case 2:
        canvas.drawArc(
          Rect.fromCircle(center: Offset(0, 46 * scale), radius: 36 * scale),
          math.pi * 1.05,
          math.pi * 0.9,
          true,
          Paint()..color = CharacterCustomizationData.outfitColor(appearance.outfitColorIndex),
        );
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(0, 34 * scale),
            width: 8 * scale,
            height: 18 * scale,
          ),
          Paint()..color = CharacterCustomizationData.outfitColor(appearance.outfitColorIndex),
        );
      case 3:
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(0, 96 * scale),
            width: 28 * scale,
            height: 18 * scale,
          ),
          0,
          math.pi,
          false,
          Paint()
            ..color = const Color(0xFFFFD700)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3 * scale,
        );
      case 4:
        canvas.drawCircle(
          Offset(-34 * scale, 68 * scale),
          3 * scale,
          Paint()..color = const Color(0xFFFFD700),
        );
        canvas.drawCircle(
          Offset(34 * scale, 68 * scale),
          3 * scale,
          Paint()..color = const Color(0xFFFFD700),
        );
      case 5:
        canvas.drawArc(
          Rect.fromCircle(center: Offset(0, 50 * scale), radius: 38 * scale),
          math.pi * 0.95,
          math.pi * 1.1,
          false,
          Paint()
            ..color = const Color(0xFF2A2A38)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 7 * scale
            ..strokeCap = StrokeCap.round,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(-42 * scale, 62 * scale),
              width: 16 * scale,
              height: 24 * scale,
            ),
            Radius.circular(8 * scale),
          ),
          Paint()..color = const Color(0xFF2A2A38),
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(42 * scale, 62 * scale),
              width: 16 * scale,
              height: 24 * scale,
            ),
            Radius.circular(8 * scale),
          ),
          Paint()..color = const Color(0xFF2A2A38),
        );
      case 6:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(48 * scale, 118 * scale),
              width: 16 * scale,
              height: 28 * scale,
            ),
            Radius.circular(8 * scale),
          ),
          Paint()..color = const Color(0xFF444444),
        );
        canvas.drawCircle(
          Offset(48 * scale, 104 * scale),
          10 * scale,
          Paint()..color = const Color(0xFF777777),
        );
    }
  }

  @override
  bool shouldRepaint(covariant _ArtistCharacterPainter oldDelegate) {
    return oldDelegate.appearance != appearance;
  }
}
