import '../services/hive_service.dart';

/// Abstract sync service interface.
/// Structured to support Firebase integration later.
///
/// To add Firebase sync:
/// 1. Create a `FirebaseSyncService` that implements this interface
/// 2. Replace `LocalSyncService` with `FirebaseSyncService` in main.dart
/// 3. Implement the actual Firebase Firestore operations
abstract class SyncService {
  /// Sync all pending changes to remote.
  Future<void> syncToRemote();

  /// Pull latest changes from remote.
  Future<void> syncFromRemote();

  /// Check if there are pending sync operations.
  bool hasPendingSync();

  /// Get the count of pending operations.
  int pendingSyncCount();
}

/// Local-only sync service (no-op implementation).
/// This is used when Firebase is not configured.
class LocalSyncService implements SyncService {
  @override
  Future<void> syncToRemote() async {
    // No-op: data is already stored locally in Hive.
    // When Firebase is added, this will push pending changes.
  }

  @override
  Future<void> syncFromRemote() async {
    // No-op: all data is local.
    // When Firebase is added, this will pull latest data.
  }

  @override
  bool hasPendingSync() {
    return HiveService.getPendingSyncOps().isNotEmpty;
  }

  @override
  int pendingSyncCount() {
    return HiveService.getPendingSyncOps().length;
  }
}

// ─── FIREBASE IMPLEMENTATION (Future) ───────────────────────
//
// class FirebaseSyncService implements SyncService {
//   @override
//   Future<void> syncToRemote() async {
//     final pendingOps = HiveService.getPendingSyncOps();
//     for (final op in pendingOps) {
//       final type = op['type'] as String;
//       final collection = op['collection'] as String;
//       final data = op['data'] as Map<String, dynamic>;
//       final id = op['id'] as String;
//
//       switch (type) {
//         case 'create':
//         case 'update':
//           await FirebaseFirestore.instance
//               .collection(collection)
//               .doc(id)
//               .set(data);
//           break;
//         case 'delete':
//           await FirebaseFirestore.instance
//               .collection(collection)
//               .doc(id)
//               .delete();
//           break;
//       }
//     }
//     await HiveService.clearSyncQueue();
//   }
//
//   @override
//   Future<void> syncFromRemote() async {
//     // Pull subjects, topics, sessions from Firestore
//     // and update local Hive storage
//   }
//
//   @override
//   bool hasPendingSync() {
//     return HiveService.getPendingSyncOps().isNotEmpty;
//   }
//
//   @override
//   int pendingSyncCount() {
//     return HiveService.getPendingSyncOps().length;
//   }
// }
