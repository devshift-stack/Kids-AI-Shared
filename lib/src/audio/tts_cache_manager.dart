import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'tts_config.dart';

/// Cache Manager für TTS Audio-Dateien
/// Speichert generierte Audio-Dateien lokal für sofortige Wiedergabe
class TtsCacheManager {
  static TtsCacheManager? _instance;
  static TtsCacheManager get instance => _instance ??= TtsCacheManager._();
  TtsCacheManager._();

  Directory? _cacheDir;
  final Map<String, File> _memoryCache = {};

  /// Initialisiert den Cache
  Future<void> init() async {
    final appDir = await getApplicationDocumentsDirectory();
    _cacheDir = Directory('${appDir.path}/tts_cache');

    if (!await _cacheDir!.exists()) {
      await _cacheDir!.create(recursive: true);
    }

    // Lade existierende Cache-Dateien in Memory-Cache
    await _loadExistingCache();

    // Bereinige alten Cache
    await _cleanOldCache();
  }

  /// Lädt existierende Cache-Dateien
  Future<void> _loadExistingCache() async {
    if (_cacheDir == null) return;

    try {
      final files = await _cacheDir!.list().toList();
      for (final entity in files) {
        if (entity is File && entity.path.endsWith('.mp3')) {
          final key = entity.path.split('/').last.replaceAll('.mp3', '');
          _memoryCache[key] = entity;
        }
      }
      print('TTS Cache: ${_memoryCache.length} Dateien geladen');
    } catch (e) {
      print('Cache laden fehlgeschlagen: $e');
    }
  }

  /// Bereinigt Cache-Dateien älter als [TtsConfig.cacheDurationDays]
  Future<void> _cleanOldCache() async {
    if (_cacheDir == null) return;

    try {
      final now = DateTime.now();
      final maxAge = Duration(days: TtsConfig.cacheDurationDays);
      final files = await _cacheDir!.list().toList();

      for (final entity in files) {
        if (entity is File) {
          final stat = await entity.stat();
          if (now.difference(stat.modified) > maxAge) {
            await entity.delete();
            final key = entity.path.split('/').last.replaceAll('.mp3', '');
            _memoryCache.remove(key);
          }
        }
      }
    } catch (e) {
      print('Cache bereinigen fehlgeschlagen: $e');
    }
  }

  /// Generiert einen eindeutigen Cache-Key für Text + Sprache
  String _generateKey(String text, String language) {
    final input = '$language:$text';
    final bytes = utf8.encode(input);
    final hash = md5.convert(bytes);
    return hash.toString();
  }

  /// Prüft ob Audio im Cache existiert
  bool hasCache(String text, String language) {
    final key = _generateKey(text, language);
    return _memoryCache.containsKey(key);
  }

  /// Holt Audio aus dem Cache
  Future<File?> getFromCache(String text, String language) async {
    final key = _generateKey(text, language);

    // Memory-Cache prüfen
    if (_memoryCache.containsKey(key)) {
      final file = _memoryCache[key]!;
      if (await file.exists()) {
        return file;
      } else {
        _memoryCache.remove(key);
      }
    }

    // Disk-Cache prüfen
    if (_cacheDir != null) {
      final file = File('${_cacheDir!.path}/$key.mp3');
      if (await file.exists()) {
        _memoryCache[key] = file;
        return file;
      }
    }

    return null;
  }

  /// Speichert Audio im Cache
  Future<File?> saveToCache(
    String text,
    String language,
    Uint8List audioData,
  ) async {
    if (_cacheDir == null) await init();

    try {
      final key = _generateKey(text, language);
      final file = File('${_cacheDir!.path}/$key.mp3');

      await file.writeAsBytes(audioData);
      _memoryCache[key] = file;

      return file;
    } catch (e) {
      print('Cache speichern fehlgeschlagen: $e');
      return null;
    }
  }

  /// Lädt häufige Phrasen in den Cache vor
  Future<void> preloadPhrases(
    String language,
    Future<Uint8List?> Function(String text, String language) synthesizeFunc,
  ) async {
    final phrases = TtsConfig.commonPhrases[language] ?? [];

    print('Preloading ${phrases.length} Phrasen für $language...');

    int loaded = 0;
    for (final phrase in phrases) {
      // Bereits im Cache?
      if (hasCache(phrase, language)) {
        loaded++;
        continue;
      }

      // Generieren und cachen
      final audio = await synthesizeFunc(phrase, language);
      if (audio != null) {
        await saveToCache(phrase, language, audio);
        loaded++;
      }

      // Kurze Pause um API nicht zu überlasten
      await Future.delayed(const Duration(milliseconds: 100));
    }

    print('Preloading abgeschlossen: $loaded/${phrases.length}');
  }

  /// Cache-Statistiken
  Future<CacheStats> getStats() async {
    if (_cacheDir == null) {
      return CacheStats(fileCount: 0, totalSizeBytes: 0);
    }

    int totalSize = 0;
    int fileCount = 0;

    try {
      final files = await _cacheDir!.list().toList();
      for (final entity in files) {
        if (entity is File) {
          final stat = await entity.stat();
          totalSize += stat.size;
          fileCount++;
        }
      }
    } catch (e) {
      print('Stats Fehler: $e');
    }

    return CacheStats(fileCount: fileCount, totalSizeBytes: totalSize);
  }

  /// Löscht den gesamten Cache
  Future<void> clearCache() async {
    if (_cacheDir == null) return;

    try {
      final files = await _cacheDir!.list().toList();
      for (final entity in files) {
        if (entity is File) {
          await entity.delete();
        }
      }
      _memoryCache.clear();
      print('TTS Cache gelöscht');
    } catch (e) {
      print('Cache löschen fehlgeschlagen: $e');
    }
  }
}

/// Cache-Statistiken
class CacheStats {
  final int fileCount;
  final int totalSizeBytes;

  const CacheStats({
    required this.fileCount,
    required this.totalSizeBytes,
  });

  double get totalSizeMb => totalSizeBytes / (1024 * 1024);

  @override
  String toString() =>
      'CacheStats(files: $fileCount, size: ${totalSizeMb.toStringAsFixed(2)} MB)';
}
