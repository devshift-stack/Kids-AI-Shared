import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Sound-Effekte für Kids AI Spiele
/// Fröhliche, kindgerechte Sounds für Feedback und Gamification

/// Sound-Effekt Kategorien
enum SoundCategory {
  /// Erfolg/Richtig
  success,

  /// Fehler/Falsch
  error,

  /// UI-Interaktion
  ui,

  /// Spiel-Sounds
  game,

  /// Belohnungen
  reward,

  /// Ambient/Hintergrund
  ambient,
}

/// Vordefinierte Sound-Effekte
enum SoundEffect {
  // Success
  correct,
  levelUp,
  achievement,
  starCollect,
  applause,

  // Error
  wrong,
  tryAgain,
  oops,

  // UI
  buttonTap,
  buttonHover,
  swipe,
  pop,
  whoosh,

  // Game
  countdown,
  timerTick,
  gameStart,
  gameOver,
  bonus,

  // Reward
  coinCollect,
  chestOpen,
  fanfare,
  sparkle,

  // Ambient
  bubbles,
  magic,
  nature,
}

/// Sound-Effekt Konfiguration
class SoundConfig {
  const SoundConfig({
    required this.effect,
    required this.path,
    this.category = SoundCategory.ui,
    this.volume = 1.0,
    this.loop = false,
  });

  final SoundEffect effect;
  final String path;
  final SoundCategory category;
  final double volume;
  final bool loop;
}

/// Sound Effects Service
class SoundEffectsService {
  SoundEffectsService._();

  static SoundEffectsService? _instance;

  static SoundEffectsService get instance {
    _instance ??= SoundEffectsService._();
    return _instance!;
  }

  // Audio Players Pool
  final Map<SoundEffect, AudioPlayer> _players = {};
  final AudioPlayer _ambientPlayer = AudioPlayer();

  // State
  bool _isInitialized = false;
  bool _isMuted = false;
  double _masterVolume = 1.0;
  final Map<SoundCategory, double> _categoryVolumes = {};

  // Sound-Konfigurationen
  static const Map<SoundEffect, SoundConfig> _soundConfigs = {
    // Success
    SoundEffect.correct: SoundConfig(
      effect: SoundEffect.correct,
      path: 'sounds/success/correct.mp3',
      category: SoundCategory.success,
    ),
    SoundEffect.levelUp: SoundConfig(
      effect: SoundEffect.levelUp,
      path: 'sounds/success/level_up.mp3',
      category: SoundCategory.success,
    ),
    SoundEffect.achievement: SoundConfig(
      effect: SoundEffect.achievement,
      path: 'sounds/success/achievement.mp3',
      category: SoundCategory.success,
    ),
    SoundEffect.starCollect: SoundConfig(
      effect: SoundEffect.starCollect,
      path: 'sounds/success/star.mp3',
      category: SoundCategory.success,
    ),
    SoundEffect.applause: SoundConfig(
      effect: SoundEffect.applause,
      path: 'sounds/success/applause.mp3',
      category: SoundCategory.success,
    ),

    // Error
    SoundEffect.wrong: SoundConfig(
      effect: SoundEffect.wrong,
      path: 'sounds/error/wrong.mp3',
      category: SoundCategory.error,
      volume: 0.7,
    ),
    SoundEffect.tryAgain: SoundConfig(
      effect: SoundEffect.tryAgain,
      path: 'sounds/error/try_again.mp3',
      category: SoundCategory.error,
      volume: 0.7,
    ),
    SoundEffect.oops: SoundConfig(
      effect: SoundEffect.oops,
      path: 'sounds/error/oops.mp3',
      category: SoundCategory.error,
      volume: 0.6,
    ),

    // UI
    SoundEffect.buttonTap: SoundConfig(
      effect: SoundEffect.buttonTap,
      path: 'sounds/ui/tap.mp3',
      category: SoundCategory.ui,
      volume: 0.5,
    ),
    SoundEffect.buttonHover: SoundConfig(
      effect: SoundEffect.buttonHover,
      path: 'sounds/ui/hover.mp3',
      category: SoundCategory.ui,
      volume: 0.3,
    ),
    SoundEffect.swipe: SoundConfig(
      effect: SoundEffect.swipe,
      path: 'sounds/ui/swipe.mp3',
      category: SoundCategory.ui,
      volume: 0.4,
    ),
    SoundEffect.pop: SoundConfig(
      effect: SoundEffect.pop,
      path: 'sounds/ui/pop.mp3',
      category: SoundCategory.ui,
      volume: 0.5,
    ),
    SoundEffect.whoosh: SoundConfig(
      effect: SoundEffect.whoosh,
      path: 'sounds/ui/whoosh.mp3',
      category: SoundCategory.ui,
      volume: 0.4,
    ),

    // Game
    SoundEffect.countdown: SoundConfig(
      effect: SoundEffect.countdown,
      path: 'sounds/game/countdown.mp3',
      category: SoundCategory.game,
    ),
    SoundEffect.timerTick: SoundConfig(
      effect: SoundEffect.timerTick,
      path: 'sounds/game/tick.mp3',
      category: SoundCategory.game,
      volume: 0.3,
    ),
    SoundEffect.gameStart: SoundConfig(
      effect: SoundEffect.gameStart,
      path: 'sounds/game/start.mp3',
      category: SoundCategory.game,
    ),
    SoundEffect.gameOver: SoundConfig(
      effect: SoundEffect.gameOver,
      path: 'sounds/game/game_over.mp3',
      category: SoundCategory.game,
    ),
    SoundEffect.bonus: SoundConfig(
      effect: SoundEffect.bonus,
      path: 'sounds/game/bonus.mp3',
      category: SoundCategory.game,
    ),

    // Reward
    SoundEffect.coinCollect: SoundConfig(
      effect: SoundEffect.coinCollect,
      path: 'sounds/reward/coin.mp3',
      category: SoundCategory.reward,
    ),
    SoundEffect.chestOpen: SoundConfig(
      effect: SoundEffect.chestOpen,
      path: 'sounds/reward/chest.mp3',
      category: SoundCategory.reward,
    ),
    SoundEffect.fanfare: SoundConfig(
      effect: SoundEffect.fanfare,
      path: 'sounds/reward/fanfare.mp3',
      category: SoundCategory.reward,
    ),
    SoundEffect.sparkle: SoundConfig(
      effect: SoundEffect.sparkle,
      path: 'sounds/reward/sparkle.mp3',
      category: SoundCategory.reward,
      volume: 0.6,
    ),

    // Ambient
    SoundEffect.bubbles: SoundConfig(
      effect: SoundEffect.bubbles,
      path: 'sounds/ambient/bubbles.mp3',
      category: SoundCategory.ambient,
      volume: 0.3,
      loop: true,
    ),
    SoundEffect.magic: SoundConfig(
      effect: SoundEffect.magic,
      path: 'sounds/ambient/magic.mp3',
      category: SoundCategory.ambient,
      volume: 0.4,
    ),
    SoundEffect.nature: SoundConfig(
      effect: SoundEffect.nature,
      path: 'sounds/ambient/nature.mp3',
      category: SoundCategory.ambient,
      volume: 0.3,
      loop: true,
    ),
  };

  // Getters
  bool get isMuted => _isMuted;
  double get masterVolume => _masterVolume;

  /// Initialisiert den Service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Standard-Lautstärken für Kategorien
    for (final category in SoundCategory.values) {
      _categoryVolumes[category] = 1.0;
    }

    _isInitialized = true;
  }

  /// Spielt einen Sound-Effekt ab
  Future<void> play(SoundEffect effect) async {
    if (_isMuted) return;

    final config = _soundConfigs[effect];
    if (config == null) return;

    try {
      // Player aus Pool oder neu erstellen
      var player = _players[effect];
      if (player == null) {
        player = AudioPlayer();
        _players[effect] = player;
      }

      // Lautstärke berechnen
      final categoryVolume = _categoryVolumes[config.category] ?? 1.0;
      final volume = config.volume * categoryVolume * _masterVolume;

      await player.setVolume(volume);
      await player.setReleaseMode(
        config.loop ? ReleaseMode.loop : ReleaseMode.release,
      );
      await player.play(AssetSource(config.path));
    } catch (e) {
      if (kDebugMode) {
        print('Sound play error: $e');
      }
    }
  }

  /// Stoppt einen Sound-Effekt
  Future<void> stop(SoundEffect effect) async {
    final player = _players[effect];
    if (player != null) {
      await player.stop();
    }
  }

  /// Stoppt alle Sounds
  Future<void> stopAll() async {
    for (final player in _players.values) {
      await player.stop();
    }
    await _ambientPlayer.stop();
  }

  /// Setzt Master-Lautstärke
  void setMasterVolume(double volume) {
    _masterVolume = volume.clamp(0.0, 1.0);
  }

  /// Setzt Kategorie-Lautstärke
  void setCategoryVolume(SoundCategory category, double volume) {
    _categoryVolumes[category] = volume.clamp(0.0, 1.0);
  }

  /// Schaltet Mute um
  void toggleMute() {
    _isMuted = !_isMuted;
    if (_isMuted) {
      stopAll();
    }
  }

  /// Setzt Mute-Status
  void setMuted(bool muted) {
    _isMuted = muted;
    if (_isMuted) {
      stopAll();
    }
  }

  /// Gibt Ressourcen frei
  Future<void> dispose() async {
    await stopAll();
    for (final player in _players.values) {
      await player.dispose();
    }
    _players.clear();
    await _ambientPlayer.dispose();
  }
}

/// Schnelle Hilfsfunktionen
Future<void> playSound(SoundEffect effect) =>
    SoundEffectsService.instance.play(effect);

Future<void> playCorrectSound() =>
    SoundEffectsService.instance.play(SoundEffect.correct);

Future<void> playWrongSound() =>
    SoundEffectsService.instance.play(SoundEffect.wrong);

Future<void> playButtonSound() =>
    SoundEffectsService.instance.play(SoundEffect.buttonTap);

Future<void> playCoinSound() =>
    SoundEffectsService.instance.play(SoundEffect.coinCollect);

Future<void> playLevelUpSound() =>
    SoundEffectsService.instance.play(SoundEffect.levelUp);
