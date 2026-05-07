import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/subject.dart';
import '../models/topic.dart';
import '../models/study_session.dart';
import 'hive_service.dart';

abstract class SyncService {
  Future<void> syncToRemote();
  Future<void> syncFromRemote();
}

/// Firebase Implementation for Cloud Sync
class FirebaseSyncService implements SyncService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Future<void> syncToRemote() async {
    try {
      final subjects = HiveService.getAllSubjects();
      final topics = HiveService.getAllTopics();
      final sessions = HiveService.getAllSessions();

      final batch = _db.batch();

      // Push Subjects
      for (final s in subjects) {
        batch.set(_db.collection('subjects').doc(s.id), s.toMap());
      }

      // Push Topics
      for (final t in topics) {
        batch.set(_db.collection('topics').doc(t.id), t.toMap());
      }

      // Push Sessions
      for (final s in sessions) {
        batch.set(_db.collection('sessions').doc(s.id), s.toMap());
      }

      await batch.commit();
      print('Successfully synced all local data to Firebase!');
    } catch (e) {
      print('Error syncing to Firebase: $e');
    }
  }

  @override
  Future<void> syncFromRemote() async {
    try {
      // 1. Fetch Subjects
      final subjectSnapshot = await _db.collection('subjects').get();
      for (final doc in subjectSnapshot.docs) {
        await HiveService.saveSubject(Subject.fromMap(doc.data()));
      }

      // 2. Fetch Topics
      final topicSnapshot = await _db.collection('topics').get();
      for (final doc in topicSnapshot.docs) {
        await HiveService.saveTopic(Topic.fromMap(doc.data()));
      }

      // 3. Fetch Sessions
      final sessionSnapshot = await _db.collection('sessions').get();
      for (final doc in sessionSnapshot.docs) {
        await HiveService.saveSession(StudySession.fromMap(doc.data()));
      }

      print('Successfully fetched data from Firebase!');
    } catch (e) {
      print('Error fetching from Firebase: $e');
    }
  }
}

/// A global instance to easily call sync functions.
final firebaseSync = FirebaseSyncService();
