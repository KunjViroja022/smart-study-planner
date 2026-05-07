import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/study_session.dart';
import '../services/hive_service.dart';

/// Provider for managing study sessions with Hive persistence.
class SessionProvider extends ChangeNotifier {
  List<StudySession> _sessions = [];
  final _uuid = const Uuid();

  List<StudySession> get sessions => List.unmodifiable(_sessions);

  /// Load all sessions from Hive.
  void loadSessions() {
    _sessions = HiveService.getAllSessions();
    _sessions.sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));
    notifyListeners();
  }

  /// Add a new study session.
  Future<void> addSession({
    required String subjectId,
    required String topicId,
    required DateTime scheduledDate,
    required String startTime,
    required int durationMinutes,
  }) async {
    final session = StudySession(
      id: _uuid.v4(),
      subjectId: subjectId,
      topicId: topicId,
      scheduledDate: scheduledDate,
      startTime: startTime,
      durationMinutes: durationMinutes,
      isCompleted: false,
      createdAt: DateTime.now(),
    );
    await HiveService.saveSession(session);
    _sessions.insert(0, session);
    _sessions.sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));
    notifyListeners();
  }

  /// Toggle session completion status.
  Future<void> toggleSessionCompletion(String id) async {
    final index = _sessions.indexWhere((s) => s.id == id);
    if (index == -1) return;

    final updated = _sessions[index].copyWith(
      isCompleted: !_sessions[index].isCompleted,
    );
    await HiveService.saveSession(updated);
    _sessions[index] = updated;
    notifyListeners();
  }

  /// Delete a session.
  Future<void> deleteSession(String id) async {
    await HiveService.deleteSession(id);
    _sessions.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  /// Get sessions for a specific date.
  List<StudySession> getSessionsByDate(DateTime date) {
    return _sessions.where((s) {
      return s.scheduledDate.year == date.year &&
          s.scheduledDate.month == date.month &&
          s.scheduledDate.day == date.day;
    }).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  /// Get sessions for a specific subject.
  List<StudySession> getSessionsBySubject(String subjectId) {
    return _sessions.where((s) => s.subjectId == subjectId).toList();
  }

  /// Get today's sessions.
  List<StudySession> get todaySessions => getSessionsByDate(DateTime.now());

  /// Get today's completed session count.
  int get todayCompletedCount =>
      todaySessions.where((s) => s.isCompleted).length;

  // ── Weekly Stats ──────────────────────────────────────────

  /// Get daily study minutes for the last 7 days.
  Map<DateTime, int> getWeeklyStudyMinutes() {
    final Map<DateTime, int> weekly = {};
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final day = DateTime(now.year, now.month, now.day - i);
      final daySessions = getSessionsByDate(day);
      final completedMinutes = daySessions
          .where((s) => s.isCompleted)
          .fold<int>(0, (sum, s) => sum + s.durationMinutes);
      weekly[day] = completedMinutes;
    }
    return weekly;
  }

  /// Total study minutes completed today.
  int get todayStudyMinutes {
    return todaySessions
        .where((s) => s.isCompleted)
        .fold<int>(0, (sum, s) => sum + s.durationMinutes);
  }

  /// Total study minutes completed overall.
  int get totalStudyMinutes {
    return _sessions
        .where((s) => s.isCompleted)
        .fold<int>(0, (sum, s) => sum + s.durationMinutes);
  }

  /// Get sessions that have events (for calendar markers).
  Set<DateTime> get sessionDates {
    return _sessions.map((s) {
      final d = s.scheduledDate;
      return DateTime(d.year, d.month, d.day);
    }).toSet();
  }
}
