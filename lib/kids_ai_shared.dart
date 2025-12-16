/// Shared library for Kids AI educational apps
///
/// Dieses Package enthält:
/// - Theme (Farben, Typography, Spacing, Shadows, Gradients)
/// - Widgets (KidButton, KidCard, KidAvatar)
///
/// Usage:
/// ```dart
/// import 'package:kids_ai_shared/kids_ai_shared.dart';
///
/// // Theme verwenden
/// MaterialApp(
///   theme: KidsTheme.light,
/// );
///
/// // Widgets verwenden
/// KidButton(label: 'Start', onPressed: () {});
/// KidCard(child: Text('Hello'));
/// KidAvatar(name: 'Max', age: 5);
/// ```
library kids_ai_shared;

// Theme exports
export 'src/theme/theme.dart';

// Widget exports
export 'src/widgets/kid_button.dart';
export 'src/widgets/kid_card.dart';
export 'src/widgets/kid_avatar.dart';
