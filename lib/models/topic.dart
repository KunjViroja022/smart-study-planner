/// Status of a topic's study progress.
enum TopicStatus { notStarted, inProgress, completed }

/// Represents a topic within a subject.
class Topic {
  final String id;
  final String subjectId;
  final String name;
  final int estimatedStudyMinutes;
  final TopicStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Topic({
    required this.id,
    required this.subjectId,
    required this.name,
    required this.estimatedStudyMinutes,
    this.status = TopicStatus.notStarted,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert to a Map for Hive storage.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subjectId': subjectId,
      'name': name,
      'estimatedStudyMinutes': estimatedStudyMinutes,
      'status': status.index,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create a Topic from a Hive map.
  factory Topic.fromMap(Map<String, dynamic> map) {
    return Topic(
      id: map['id'] as String,
      subjectId: map['subjectId'] as String,
      name: map['name'] as String,
      estimatedStudyMinutes: map['estimatedStudyMinutes'] as int,
      status: TopicStatus.values[map['status'] as int],
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  /// Create a copy with optional field overrides.
  Topic copyWith({
    String? name,
    int? estimatedStudyMinutes,
    TopicStatus? status,
    DateTime? updatedAt,
  }) {
    return Topic(
      id: id,
      subjectId: subjectId,
      name: name ?? this.name,
      estimatedStudyMinutes:
          estimatedStudyMinutes ?? this.estimatedStudyMinutes,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Human-readable status label.
  String get statusLabel {
    switch (status) {
      case TopicStatus.notStarted:
        return 'Not Started';
      case TopicStatus.inProgress:
        return 'In Progress';
      case TopicStatus.completed:
        return 'Completed';
    }
  }

  @override
  String toString() => 'Topic(id: $id, name: $name, status: $statusLabel)';
}
