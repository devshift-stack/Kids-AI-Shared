import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Zentraler Error Handling Service für Kids AI Apps
class ErrorHandlingService {
  static final ErrorHandlingService _instance = ErrorHandlingService._internal();
  factory ErrorHandlingService() => _instance;
  ErrorHandlingService._internal();
  
  final List<AppError> _errorLog = [];
  final _errorController = StreamController<AppError>.broadcast();
  
  Stream<AppError> get errorStream => _errorController.stream;
  List<AppError> get errorLog => List.unmodifiable(_errorLog);
  
  /// Initialisiert globales Error Handling
  void initialize() {
    FlutterError.onError = (details) {
      _handleFlutterError(details);
    };
    
    PlatformDispatcher.instance.onError = (error, stack) {
      _handlePlatformError(error, stack);
      return true;
    };
  }
  
  void _handleFlutterError(FlutterErrorDetails details) {
    final error = AppError(
      type: ErrorType.flutter,
      message: details.exceptionAsString(),
      stackTrace: details.stack,
      context: details.context?.toString(),
    );
    _logError(error);
  }
  
  void _handlePlatformError(Object error, StackTrace stack) {
    final appError = AppError(
      type: ErrorType.platform,
      message: error.toString(),
      stackTrace: stack,
    );
    _logError(appError);
  }
  
  /// Loggt einen Fehler
  void _logError(AppError error) {
    _errorLog.add(error);
    _errorController.add(error);
    
    // Max 100 Fehler behalten
    if (_errorLog.length > 100) {
      _errorLog.removeAt(0);
    }
    
    if (kDebugMode) {
      print('═══════════════════════════════════════');
      print('ERROR [${error.type.name}]: ${error.message}');
      if (error.context != null) {
        print('Context: ${error.context}');
      }
      print('═══════════════════════════════════════');
    }
  }
  
  /// Behandelt einen API/Network Fehler
  AppError handleNetworkError(dynamic error, {String? context}) {
    String message;
    ErrorSeverity severity;
    
    if (error.toString().contains('SocketException') ||
        error.toString().contains('Connection refused')) {
      message = 'Keine Internetverbindung';
      severity = ErrorSeverity.warning;
    } else if (error.toString().contains('TimeoutException')) {
      message = 'Zeitüberschreitung - bitte versuche es erneut';
      severity = ErrorSeverity.warning;
    } else if (error.toString().contains('403') || 
               error.toString().contains('401')) {
      message = 'Zugriff verweigert';
      severity = ErrorSeverity.error;
    } else if (error.toString().contains('404')) {
      message = 'Nicht gefunden';
      severity = ErrorSeverity.warning;
    } else if (error.toString().contains('500')) {
      message = 'Server-Fehler - bitte später versuchen';
      severity = ErrorSeverity.error;
    } else {
      message = 'Ein Fehler ist aufgetreten';
      severity = ErrorSeverity.error;
    }
    
    final appError = AppError(
      type: ErrorType.network,
      message: message,
      originalError: error.toString(),
      context: context,
      severity: severity,
    );
    
    _logError(appError);
    return appError;
  }
  
  /// Behandelt einen Firebase Fehler
  AppError handleFirebaseError(dynamic error, {String? context}) {
    String message;
    
    final errorStr = error.toString().toLowerCase();
    
    if (errorStr.contains('permission-denied')) {
      message = 'Keine Berechtigung';
    } else if (errorStr.contains('unavailable')) {
      message = 'Service nicht verfügbar';
    } else if (errorStr.contains('not-found')) {
      message = 'Daten nicht gefunden';
    } else if (errorStr.contains('already-exists')) {
      message = 'Existiert bereits';
    } else {
      message = 'Datenbank-Fehler';
    }
    
    final appError = AppError(
      type: ErrorType.firebase,
      message: message,
      originalError: error.toString(),
      context: context,
    );
    
    _logError(appError);
    return appError;
  }
  
  /// Behandelt einen allgemeinen Fehler
  AppError handleError(
    dynamic error, {
    String? context,
    ErrorType type = ErrorType.general,
    ErrorSeverity severity = ErrorSeverity.error,
  }) {
    final appError = AppError(
      type: type,
      message: _getUserFriendlyMessage(error),
      originalError: error.toString(),
      context: context,
      severity: severity,
    );
    
    _logError(appError);
    return appError;
  }
  
  String _getUserFriendlyMessage(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    
    if (errorStr.contains('network') || errorStr.contains('socket')) {
      return 'Verbindungsproblem';
    } else if (errorStr.contains('timeout')) {
      return 'Zeitüberschreitung';
    } else if (errorStr.contains('permission')) {
      return 'Keine Berechtigung';
    } else if (errorStr.contains('not found') || errorStr.contains('404')) {
      return 'Nicht gefunden';
    }
    
    return 'Ein Fehler ist aufgetreten';
  }
  
  /// Zeigt einen kinderfreundlichen Fehler-Dialog
  void showErrorDialog(BuildContext context, AppError error) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              _getErrorIcon(error.severity),
              color: _getErrorColor(error.severity),
              size: 32,
            ),
            const SizedBox(width: 12),
            const Text('Ups!'),
          ],
        ),
        content: Text(
          error.userMessage,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
          if (error.canRetry)
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                error.onRetry?.call();
              },
              child: const Text('Nochmal'),
            ),
        ],
      ),
    );
  }
  
  /// Zeigt eine Snackbar mit Fehlermeldung
  void showErrorSnackbar(BuildContext context, AppError error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _getErrorIcon(error.severity),
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(error.userMessage)),
          ],
        ),
        backgroundColor: _getErrorColor(error.severity),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        action: error.canRetry
            ? SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: () => error.onRetry?.call(),
              )
            : null,
      ),
    );
  }
  
  IconData _getErrorIcon(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.info:
        return Icons.info_outline;
      case ErrorSeverity.warning:
        return Icons.warning_amber;
      case ErrorSeverity.error:
        return Icons.error_outline;
      case ErrorSeverity.critical:
        return Icons.dangerous;
    }
  }
  
  Color _getErrorColor(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.info:
        return Colors.blue;
      case ErrorSeverity.warning:
        return Colors.orange;
      case ErrorSeverity.error:
        return Colors.red;
      case ErrorSeverity.critical:
        return Colors.red.shade900;
    }
  }
  
  /// Löscht alle Fehler-Logs
  void clearErrorLog() {
    _errorLog.clear();
  }
  
  void dispose() {
    _errorController.close();
  }
}

/// App Error Model
class AppError {
  final ErrorType type;
  final String message;
  final String? originalError;
  final StackTrace? stackTrace;
  final String? context;
  final ErrorSeverity severity;
  final DateTime timestamp;
  final VoidCallback? onRetry;
  
  AppError({
    required this.type,
    required this.message,
    this.originalError,
    this.stackTrace,
    this.context,
    this.severity = ErrorSeverity.error,
    this.onRetry,
  }) : timestamp = DateTime.now();
  
  String get userMessage => message;
  bool get canRetry => onRetry != null;
}

enum ErrorType {
  flutter,
  platform,
  network,
  firebase,
  validation,
  general,
}

enum ErrorSeverity {
  info,
  warning,
  error,
  critical,
}

// Provider
final errorHandlingServiceProvider = Provider<ErrorHandlingService>((ref) {
  return ErrorHandlingService();
});

/// Extension für einfaches Error Handling in async Funktionen
extension AsyncErrorHandling<T> on Future<T> {
  Future<T?> handleErrors({
    required ErrorHandlingService errorService,
    String? context,
    VoidCallback? onRetry,
  }) async {
    try {
      return await this;
    } catch (e) {
      errorService.handleError(
        e,
        context: context,
      );
      return null;
    }
  }
}
