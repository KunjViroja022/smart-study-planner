import 'package:hive_flutter/hive_flutter.dart';
import '../models/subject.dart';
import '../models/topic.dart';
import '../models/study_session.dart';
import '../utils/constants.dart';

/// Service for all Hive local storage operations.
class HiveService {
  /// Initialize Hive and open all boxes.
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(HiveBoxes.subjects);
    await Hive.openBox(HiveBoxes.topics);
    await Hive.openBox(HiveBoxes.sessions);
    await Hive.openBox(HiveBoxes.syncQueue);
  }

  // ── Subject CRUD ──────────────────────────────────────────

  static Box get _subjectBox => Hive.box(HiveBoxes.subjects);

  /// Get all subjects from local storage.
  static List<Subject> getAllSubjects() {
    return _subjectBox.values
        .map((e) => Subject.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Save or update a subject.
  static Future<void> saveSubject(Subject subject) async {
    await _subjectBox.put(subject.id, subject.toMap());
  }

  /// Delete a subject by ID.
  static Future<void> deleteSubject(String id) async {
    await _subjectBox.delete(id);
  }

  // ── Topic CRUD ────────────────────────────────────────────

  static Box get _topicBox => Hive.box(HiveBoxes.topics);

  /// Get all topics from local storage.
  static List<Topic> getAllTopics() {
    return _topicBox.values
        .map((e) => Topic.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Get topics for a specific subject.
  static List<Topic> getTopicsBySubject(String subjectId) {
    return getAllTopics()
        .where((t) => t.subjectId == subjectId)
        .toList();
  }

  /// Save or update a topic.
  static Future<void> saveTopic(Topic topic) async {
    await _topicBox.put(topic.id, topic.toMap());
  }

  /// Delete a topic by ID.
  static Future<void> deleteTopic(String id) async {
    await _topicBox.delete(id);
  }

  /// Delete all topics for a subject (cascade delete).
  static Future<void> deleteTopicsBySubject(String subjectId) async {
    final topics = getTopicsBySubject(subjectId);
    for (final topic in topics) {
      await _topicBox.delete(topic.id);
    }
  }

  // ── Session CRUD ──────────────────────────────────────────

  static Box get _sessionBox => Hive.box(HiveBoxes.sessions);

  /// Get all study sessions from local storage.
  static List<StudySession> getAllSessions() {
    return _sessionBox.values
        .map((e) => StudySession.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Save or update a session.
  static Future<void> saveSession(StudySession session) async {
    await _sessionBox.put(session.id, session.toMap());
  }

  /// Delete a session by ID.
  static Future<void> deleteSession(String id) async {
    await _sessionBox.delete(id);
  }

  /// Delete all sessions for a subject (cascade delete).
  static Future<void> deleteSessionsBySubject(String subjectId) async {
    final sessions =
        getAllSessions().where((s) => s.subjectId == subjectId).toList();
    for (final session in sessions) {
      await _sessionBox.delete(session.id);
    }
  }

  /// Delete all sessions for a topic (cascade delete).
  static Future<void> deleteSessionsByTopic(String topicId) async {
    final sessions =
        getAllSessions().where((s) => s.topicId == topicId).toList();
    for (final session in sessions) {
      await _sessionBox.delete(session.id);
    }
  }

  // ── Sync Queue ────────────────────────────────────────────

  static Box get _syncBox => Hive.box(HiveBoxes.syncQueue);

  /// Add an operation to the sync queue for later Firebase sync.
  static Future<void> addToSyncQueue(Map<String, dynamic> operation) async {
    await _syncBox.add(operation);
  }

  /// Get all pending sync operations.
  static List<Map<String, dynamic>> getPendingSyncOps() {
    return _syncBox.values
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  /// Clear all pending sync operations after successful sync.
  static Future<void> clearSyncQueue() async {
    await _syncBox.clear();
  }
}
