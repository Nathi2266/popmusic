import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'theme_music_config.dart';

/// Returns a local filesystem path to the theme track when available.
///
/// Prefer an existing on-device cache, then (in debug) the repo's web/audio copy,
/// otherwise download once into app documents.
Future<String?> resolveLocalThemePath() async {
  final dir = await getApplicationDocumentsDirectory();
  final cache = File('${dir.path}/theme_music.mp3');
  if (await cache.exists() && await cache.length() > 0) {
    return cache.path;
  }

  if (!kReleaseMode) {
    for (final path in const [
      'assets/audio/theme_music.mp3',
      'web/audio/theme_music.mp3',
      'assets/audio/Under The Sun II (Jazz_Feel).mp3',
    ]) {
      final file = File(path);
      if (await file.exists() && await file.length() > 0) {
        await file.copy(cache.path);
        return cache.path;
      }
    }
  }

  final url = ThemeMusicConfig.remoteUrl;
  if (url.isEmpty) return null;

  try {
    final response = await http.get(Uri.parse(url)).timeout(
          const Duration(seconds: 45),
        );
    if (response.statusCode != 200 || response.bodyBytes.isEmpty) {
      return null;
    }
    await cache.writeAsBytes(response.bodyBytes, flush: true);
    return cache.path;
  } catch (e) {
    debugPrint('Theme music download failed: $e');
    return null;
  }
}
