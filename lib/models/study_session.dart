/// Represents a scheduled study session.
class StudySession {
  final String id;
  final String subjectId;
  final String topicId;
  final DateTime scheduledDate;
  final String startTime; // Format: "HH:mm"
  final int durationMinutes;
  final bool isCompleted;
  final DateTime createdAt;

  StudySession({
    required this.id,
    required this.subjectId,
    required this.topicId,
    required this.scheduledDate,
    required this.startTime,
    required this.durationMinutes,
    this.isCompleted = false,
    required this.createdAt,
  });

  /// Convert to a Map for Hive storage.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subjectId': subjectId,
      'topicId': topicId,
      'scheduledDate': scheduledDate.toIso8601String(),
      'startTime': startTime,
      'durationMinutes': durationMinutes,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create a StudySession from a Hive map.
  factory StudySession.fromMap(Map<String, dynamic> map) {
    return StudySession(
      id: map['id'] as String,
      subjectId: map['subjectId'] as String,
      topicId: map['topicId'] as String,
      scheduledDate: DateTime.parse(map['scheduledDate'] as String),
      startTime: map['startTime'] as String,
      durationMinutes: map['durationMinutes'] as int,
      isCompleted: map['isCompleted'] as bool,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  /// Create a copy with optional field overrides.
  StudySession copyWith({
    String? subjectId,
    String? topicId,
    DateTime? scheduledDate,
    String? startTime,
    int? durationMinutes,
    bool? isCompleted,
  }) {
    return StudySession(
      id: id,
      subjectId: subjectId ?? this.subjectId,
      topicId: topicId ?? this.topicId,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      startTime: startTime ?? this.startTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
    );
  }

  @override
  String toString() =>
      'StudySession(id: $id, subject: $subjectId, date: $scheduledDate)';
}
