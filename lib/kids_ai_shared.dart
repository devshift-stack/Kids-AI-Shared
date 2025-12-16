/// Shared library for Kids AI educational apps
library kids_ai_shared;

// ============================================================
// AUDIO SERVICES - Text-to-Speech (Ausgabe)
// ============================================================
export 'src/audio/pre_recorded_audio_service.dart';
export 'src/audio/fluent_tts_service.dart';
export 'src/audio/tts_provider.dart';
export 'src/audio/tts_cache_manager.dart';
export 'src/audio/tts_config.dart';

// ============================================================
// AUDIO SERVICES - Speech-to-Text (Eingabe)
// ============================================================
export 'src/audio/recording_config.dart';
export 'src/audio/recording_service.dart';
export 'src/audio/stt_provider.dart';

// ============================================================
// THEME
// ============================================================
export 'src/theme/colors.dart';
export 'src/theme/typography.dart';
export 'src/theme/spacing.dart';
export 'src/theme/gradients.dart';

// ============================================================
// WIDGETS
// ============================================================
export 'src/widgets/kid_button.dart';
export 'src/widgets/kid_card.dart';
export 'src/widgets/kid_avatar.dart';
