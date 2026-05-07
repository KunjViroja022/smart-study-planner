import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/topic.dart';
import '../services/hive_service.dart';

/// Provider for managing topics with Hive persistence.
class TopicProvider extends ChangeNotifier {
  List<Topic> _topics = [];
  final _uuid = const Uuid();

  List<Topic> get topics => List.unmodifiable(_topics);

  /// Load all topics from Hive.
  void loadTopics() {
    _topics = HiveService.getAllTopics();
    notifyListeners();
  }

  /// Get topics for a specific subject.
  List<Topic> getTopicsBySubject(String subjectId) {
    return _topics.where((t) => t.subjectId == subjectId).toList();
  }

  /// Add a new topic.
  Future<void> addTopic({
    required String subjectId,
    required String name,
    required int estimatedStudyMinutes,
  }) async {
    final now = DateTime.now();
    final topic = Topic(
      id: _uuid.v4(),
      subjectId: subjectId,
      name: name.trim(),
      estimatedStudyMinutes: estimatedStudyMinutes,
      status: TopicStatus.notStarted,
      createdAt: now,
      updatedAt: now,
    );
    await HiveService.saveTopic(topic);
    _topics.add(topic);
    notifyListeners();
  }

  /// Update an existing topic.
  Future<void> updateTopic({
    required String id,
    String? name,
    int? estimatedStudyMinutes,
    TopicStatus? status,
  }) async {
    final index = _topics.indexWhere((t) => t.id == id);
    if (index == -1) return;

    final updated = _topics[index].copyWith(
      name: name?.trim(),
      estimatedStudyMinutes: estimatedStudyMinutes,
      status: status,
      updatedAt: DateTime.now(),
    );
    await HiveService.saveTopic(updated);
    _topics[index] = updated;
    notifyListeners();
  }

  /// Cycle a topic's status: notStarted → inProgress → completed.
  Future<void> cycleTopicStatus(String id) async {
    final index = _topics.indexWhere((t) => t.id == id);
    if (index == -1) return;

    final current = _topics[index].status;
    TopicStatus next;
    switch (current) {
      case TopicStatus.notStarted:
        next = TopicStatus.inProgress;
        break;
      case TopicStatus.inProgress:
        next = TopicStatus.completed;
        break;
      case TopicStatus.completed:
        next = TopicStatus.notStarted;
        break;
    }
    await updateTopic(id: id, status: next);
  }

  /// Delete a topic and cascade-delete its sessions.
  Future<void> deleteTopic(String id) async {
    await HiveService.deleteTopic(id);
    await HiveService.deleteSessionsByTopic(id);
    _topics.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  /// Delete all topics for a subject.
  Future<void> deleteTopicsBySubject(String subjectId) async {
    await HiveService.deleteTopicsBySubject(subjectId);
    _topics.removeWhere((t) => t.subjectId == subjectId);
    notifyListeners();
  }

  /// Get topic by ID.
  Topic? getTopicById(String id) {
    try {
      return _topics.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get topic name by ID (safe).
  String getTopicName(String id) {
    return getTopicById(id)?.name ?? 'Unknown Topic';
  }

  // ── Computed Stats ──────────────────────────────────────────

  /// Total topic count.
  int get totalTopics => _topics.length;

  /// Count of completed topics.
  int get completedTopics =>
      _topics.where((t) => t.status == TopicStatus.completed).length;

  /// Count of pending topics (not completed).
  int get pendingTopics =>
      _topics.where((t) => t.status != TopicStatus.completed).length;

  /// Count of in-progress topics.
  int get inProgressTopics =>
      _topics.where((t) => t.status == TopicStatus.inProgress).length;

  /// Overall completion percentage across all topics.
  double get overallCompletion {
    if (_topics.isEmpty) return 0.0;
    return (completedTopics / _topics.length) * 100;
  }

  /// Completion percentage for a specific subject.
  double getSubjectCompletion(String subjectId) {
    final subjectTopics = getTopicsBySubject(subjectId);
    if (subjectTopics.isEmpty) return 0.0;
    final completed =
        subjectTopics.where((t) => t.status == TopicStatus.completed).length;
    return (completed / subjectTopics.length) * 100;
  }

  /// Get the next suggested topic to study.
  /// Logic: Find the subject with the lowest completion, then pick its first incomplete topic.
  Topic? getSuggestedNextTopic(List<String> subjectIds) {
    if (subjectIds.isEmpty || _topics.isEmpty) return null;

    // Sort subjects by completion percentage (ascending)
    final sorted = [...subjectIds];
    sorted.sort((a, b) {
      final compA = getSubjectCompletion(a);
      final compB = getSubjectCompletion(b);
      return compA.compareTo(compB);
    });

    // From the least complete subject, find first incomplete topic
    for (final subjectId in sorted) {
      final subjectTopics = getTopicsBySubject(subjectId);
      final incomplete = subjectTopics.where(
        (t) => t.status != TopicStatus.completed,
      );
      if (incomplete.isNotEmpty) {
        // Prefer "in progress" topics first, then "not started"
        final inProg = incomplete.where(
          (t) => t.status == TopicStatus.inProgress,
        );
        if (inProg.isNotEmpty) return inProg.first;
        return incomplete.first;
      }
    }
    return null;
  }

  /// Get subjects sorted by completion (ascending) for priority view.
  List<String> getSubjectsByPriority(List<String> subjectIds) {
    final sorted = [...subjectIds];
    sorted.sort((a, b) {
      final compA = getSubjectCompletion(a);
      final compB = getSubjectCompletion(b);
      return compA.compareTo(compB);
    });
    return sorted;
  }
}
