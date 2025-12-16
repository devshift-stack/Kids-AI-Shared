import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Offline-Sync Service für Kids AI Apps
/// Speichert Daten lokal und synchronisiert bei Verbindung
class OfflineSyncService extends ChangeNotifier {
  static const String _pendingActionsKey = 'pending_sync_actions';
  static const String _cachePrefix = 'cache_';
  
  SharedPreferences? _prefs;
  
  bool _isOnline = true;
  bool _isSyncing = false;
  List<SyncAction> _pendingActions = [];
  
  bool get isOnline => _isOnline;
  bool get isSyncing => _isSyncing;
  int get pendingActionsCount => _pendingActions.length;
  
  /// Initialisiert den Service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadPendingActions();
    notifyListeners();
  }
  
  Future<void> _loadPendingActions() async {
    final json = _prefs?.getString(_pendingActionsKey);
    if (json != null) {
      try {
        final list = jsonDecode(json) as List;
        _pendingActions = list.map((e) => SyncAction.fromMap(e)).toList();
      } catch (e) {
        _pendingActions = [];
      }
    }
  }
  
  Future<void> _savePendingActions() async {
    final json = jsonEncode(_pendingActions.map((e) => e.toMap()).toList());
    await _prefs?.setString(_pendingActionsKey, json);
  }
  
  /// Setzt Online-Status
  void setOnlineStatus(bool online) {
    final wasOffline = !_isOnline;
    _isOnline = online;
    
    if (wasOffline && _isOnline) {
      syncPendingActions();
    }
    
    notifyListeners();
  }
  
  /// Speichert eine Aktion für späteren Sync
  Future<void> queueAction(SyncAction action) async {
    _pendingActions.add(action);
    await _savePendingActions();
    
    if (kDebugMode) {
      print('OfflineSync: Queued action ${action.type} for ${action.collection}');
    }
    
    notifyListeners();
    
    if (_isOnline) {
      await syncPendingActions();
    }
  }
  
  /// Synchronisiert alle ausstehenden Aktionen
  Future<void> syncPendingActions() async {
    if (_isSyncing || !_isOnline || _pendingActions.isEmpty) return;
    
    _isSyncing = true;
    notifyListeners();
    
    final actionsToSync = List<SyncAction>.from(_pendingActions);
    final successfulActions = <SyncAction>[];
    
    for (final action in actionsToSync) {
      try {
        final success = await _executeSyncAction(action);
        if (success) {
          successfulActions.add(action);
          if (kDebugMode) {
            print('OfflineSync: Synced ${action.type} for ${action.collection}');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('OfflineSync: Failed to sync ${action.type}: $e');
        }
      }
    }
    
    // Erfolgreiche Aktionen entfernen
    for (final action in successfulActions) {
      _pendingActions.remove(action);
    }
    await _savePendingActions();
    
    _isSyncing = false;
    notifyListeners();
  }
  
  /// Führt eine Sync-Aktion aus
  Future<bool> _executeSyncAction(SyncAction action) async {
    if (onSyncAction != null) {
      return await onSyncAction!(action);
    }
    return false;
  }
  
  /// Callback für Sync-Aktionen (wird von App gesetzt)
  Future<bool> Function(SyncAction action)? onSyncAction;
  
  // ============================================================
  // CACHING
  // ============================================================
  
  /// Speichert Daten im lokalen Cache
  Future<void> cacheData(String key, Map<String, dynamic> data) async {
    final cacheEntry = CacheEntry(
      data: data,
      timestamp: DateTime.now(),
    );
    await _prefs?.setString('$_cachePrefix$key', jsonEncode(cacheEntry.toMap()));
  }
  
  /// Holt Daten aus dem lokalen Cache
  CacheEntry? getCachedData(String key) {
    final json = _prefs?.getString('$_cachePrefix$key');
    if (json == null) return null;
    
    try {
      return CacheEntry.fromMap(jsonDecode(json));
    } catch (e) {
      return null;
    }
  }
  
  /// Prüft ob Cache gültig ist
  bool isCacheValid(String key, {Duration maxAge = const Duration(hours: 1)}) {
    final entry = getCachedData(key);
    if (entry == null) return false;
    return DateTime.now().difference(entry.timestamp) < maxAge;
  }
  
  /// Holt Daten mit Cache-Fallback
  Future<Map<String, dynamic>?> getWithCache(
    String key,
    Future<Map<String, dynamic>?> Function() fetchFn, {
    Duration maxAge = const Duration(hours: 1),
  }) async {
    // Wenn online und Cache abgelaufen, fetch
    if (_isOnline && !isCacheValid(key, maxAge: maxAge)) {
      try {
        final data = await fetchFn();
        if (data != null) {
          await cacheData(key, data);
          return data;
        }
      } catch (e) {
        if (kDebugMode) {
          print('OfflineSync: Fetch failed, using cache: $e');
        }
      }
    }
    
    // Fallback auf Cache
    return getCachedData(key)?.data;
  }
  
  /// Löscht den gesamten Cache
  Future<void> clearCache() async {
    final keys = _prefs?.getKeys().where((k) => k.startsWith(_cachePrefix)) ?? [];
    for (final key in keys) {
      await _prefs?.remove(key);
    }
  }
}

/// Sync Action Model
class SyncAction {
  final String type;
  final String collection;
  final String? documentId;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  
  SyncAction({
    required this.type,
    required this.collection,
    this.documentId,
    required this.data,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
  
  factory SyncAction.fromMap(Map<String, dynamic> map) {
    return SyncAction(
      type: map['type'] ?? '',
      collection: map['collection'] ?? '',
      documentId: map['documentId'],
      data: Map<String, dynamic>.from(map['data'] ?? {}),
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
  
  Map<String, dynamic> toMap() => {
    'type': type,
    'collection': collection,
    'documentId': documentId,
    'data': data,
    'createdAt': createdAt.toIso8601String(),
  };
  
  static const String create = 'create';
  static const String update = 'update';
  static const String delete = 'delete';
}

/// Cache Entry Model
class CacheEntry {
  final Map<String, dynamic> data;
  final DateTime timestamp;
  
  CacheEntry({required this.data, required this.timestamp});
  
  factory CacheEntry.fromMap(Map<String, dynamic> map) => CacheEntry(
    data: Map<String, dynamic>.from(map['data'] ?? {}),
    timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
  );
  
  Map<String, dynamic> toMap() => {
    'data': data,
    'timestamp': timestamp.toIso8601String(),
  };
}

// Providers
final offlineSyncServiceProvider = ChangeNotifierProvider<OfflineSyncService>((ref) {
  return OfflineSyncService();
});

final isOnlineProvider = Provider<bool>((ref) {
  return ref.watch(offlineSyncServiceProvider).isOnline;
});

final pendingActionsCountProvider = Provider<int>((ref) {
  return ref.watch(offlineSyncServiceProvider).pendingActionsCount;
});
