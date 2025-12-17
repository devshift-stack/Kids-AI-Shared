import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kids_ai_shared/src/sync/offline_sync_service.dart';

void main() {
  group('SyncAction', () {
    group('toMap/fromMap Roundtrip', () {
      test('erhaelt alle Daten bei Roundtrip', () {
        final original = SyncAction(
          type: SyncAction.create,
          collection: 'users',
          documentId: 'doc-123',
          data: {'name': 'Test', 'age': 25},
        );

        final map = original.toMap();
        final restored = SyncAction.fromMap(map);

        expect(restored.type, equals(original.type));
        expect(restored.collection, equals(original.collection));
        expect(restored.documentId, equals(original.documentId));
        expect(restored.data['name'], equals('Test'));
        expect(restored.data['age'], equals(25));
      });

      test('handled null documentId', () {
        final original = SyncAction(
          type: SyncAction.create,
          collection: 'users',
          data: {'name': 'Test'},
        );

        final map = original.toMap();
        final restored = SyncAction.fromMap(map);

        expect(restored.documentId, isNull);
      });

      test('setzt createdAt automatisch', () {
        final action = SyncAction(
          type: SyncAction.update,
          collection: 'items',
          data: {},
        );

        expect(action.createdAt, isNotNull);
        expect(
          action.createdAt.difference(DateTime.now()).inSeconds.abs(),
          lessThan(2),
        );
      });
    });

    group('Static Constants', () {
      test('create ist "create"', () {
        expect(SyncAction.create, equals('create'));
      });

      test('update ist "update"', () {
        expect(SyncAction.update, equals('update'));
      });

      test('delete ist "delete"', () {
        expect(SyncAction.delete, equals('delete'));
      });
    });
  });

  group('CacheEntry', () {
    group('toMap/fromMap Roundtrip', () {
      test('erhaelt alle Daten bei Roundtrip', () {
        final timestamp = DateTime.now();
        final original = CacheEntry(
          data: {'key': 'value', 'count': 42},
          timestamp: timestamp,
        );

        final map = original.toMap();
        final restored = CacheEntry.fromMap(map);

        expect(restored.data['key'], equals('value'));
        expect(restored.data['count'], equals(42));
        expect(
          restored.timestamp.difference(timestamp).inSeconds.abs(),
          lessThan(1),
        );
      });

      test('handled leere data', () {
        final original = CacheEntry(
          data: {},
          timestamp: DateTime.now(),
        );

        final map = original.toMap();
        final restored = CacheEntry.fromMap(map);

        expect(restored.data, isEmpty);
      });
    });
  });

  group('OfflineSyncService', () {
    late OfflineSyncService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      service = OfflineSyncService();
      await service.initialize();
    });

    group('Online Status', () {
      test('isOnline ist true per Default', () {
        expect(service.isOnline, isTrue);
      });

      test('setOnlineStatus aendert Status', () {
        service.setOnlineStatus(false);
        expect(service.isOnline, isFalse);

        service.setOnlineStatus(true);
        expect(service.isOnline, isTrue);
      });
    });

    group('Pending Actions', () {
      test('pendingActionsCount ist 0 initial', () {
        expect(service.pendingActionsCount, equals(0));
      });

      test('queueAction erhoeht pendingActionsCount', () async {
        // Erst offline setzen, damit nicht sofort gesynced wird
        service.setOnlineStatus(false);

        await service.queueAction(SyncAction(
          type: SyncAction.create,
          collection: 'test',
          data: {'key': 'value'},
        ));

        expect(service.pendingActionsCount, equals(1));
      });

      test('mehrere Actions koennen gequeued werden', () async {
        service.setOnlineStatus(false);

        await service.queueAction(SyncAction(
          type: SyncAction.create,
          collection: 'test1',
          data: {},
        ));
        await service.queueAction(SyncAction(
          type: SyncAction.update,
          collection: 'test2',
          data: {},
        ));
        await service.queueAction(SyncAction(
          type: SyncAction.delete,
          collection: 'test3',
          data: {},
        ));

        expect(service.pendingActionsCount, equals(3));
      });
    });

    group('Syncing', () {
      test('isSyncing ist false initial', () {
        expect(service.isSyncing, isFalse);
      });

      test('syncPendingActions macht nichts wenn offline', () async {
        service.setOnlineStatus(false);

        await service.queueAction(SyncAction(
          type: SyncAction.create,
          collection: 'test',
          data: {},
        ));

        await service.syncPendingActions();

        // Sollte nichts synced haben weil offline
        expect(service.pendingActionsCount, equals(1));
      });

      test('syncPendingActions macht nichts wenn keine Actions', () async {
        await service.syncPendingActions();

        expect(service.pendingActionsCount, equals(0));
      });
    });

    group('Caching', () {
      test('cacheData und getCachedData funktionieren', () async {
        await service.cacheData('test-key', {'name': 'Test', 'count': 5});

        final cached = service.getCachedData('test-key');

        expect(cached, isNotNull);
        expect(cached!.data['name'], equals('Test'));
        expect(cached.data['count'], equals(5));
      });

      test('getCachedData gibt null fuer unbekannten Key', () {
        final cached = service.getCachedData('unknown-key');

        expect(cached, isNull);
      });

      test('isCacheValid gibt true fuer frischen Cache', () async {
        await service.cacheData('test-key', {'value': 1});

        expect(
          service.isCacheValid('test-key', maxAge: const Duration(hours: 1)),
          isTrue,
        );
      });

      test('isCacheValid gibt false fuer unbekannten Key', () {
        expect(
          service.isCacheValid('unknown-key'),
          isFalse,
        );
      });

      test('clearCache entfernt alle Cache-Eintraege', () async {
        await service.cacheData('key1', {'a': 1});
        await service.cacheData('key2', {'b': 2});

        await service.clearCache();

        expect(service.getCachedData('key1'), isNull);
        expect(service.getCachedData('key2'), isNull);
      });
    });

    group('getWithCache', () {
      test('nutzt Cache wenn offline', () async {
        await service.cacheData('test-key', {'cached': true});
        service.setOnlineStatus(false);

        var fetchCalled = false;
        final result = await service.getWithCache(
          'test-key',
          () async {
            fetchCalled = true;
            return {'fetched': true};
          },
        );

        // Sollte Cache nutzen, nicht fetchen
        // Bei offline wird nicht gefetcht
        expect(result?['cached'], isTrue);
      });

      test('gibt null wenn kein Cache und offline', () async {
        service.setOnlineStatus(false);

        final result = await service.getWithCache(
          'unknown-key',
          () async => {'fetched': true},
        );

        expect(result, isNull);
      });
    });

    group('onSyncAction Callback', () {
      test('kann gesetzt werden', () {
        service.onSyncAction = (action) async {
          return true;
        };

        expect(service.onSyncAction, isNotNull);
      });
    });
  });
}
