import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/subject.dart';
import '../services/hive_service.dart';

/// Provider for managing subjects with Hive persistence.
class SubjectProvider extends ChangeNotifier {
  List<Subject> _subjects = [];
  final _uuid = const Uuid();

  List<Subject> get subjects => List.unmodifiable(_subjects);

  /// Load all subjects from Hive.
  void loadSubjects() {
    _subjects = HiveService.getAllSubjects();
    _subjects.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    notifyListeners();
  }

  /// Add a new subject.
  Future<void> addSubject(String name) async {
    final now = DateTime.now();
    final subject = Subject(
      id: _uuid.v4(),
      name: name.trim(),
      createdAt: now,
      updatedAt: now,
    );
    await HiveService.saveSubject(subject);
    _subjects.insert(0, subject);
    notifyListeners();
  }

  /// Update an existing subject.
  Future<void> updateSubject(String id, String newName) async {
    final index = _subjects.indexWhere((s) => s.id == id);
    if (index == -1) return;

    final updated = _subjects[index].copyWith(
      name: newName.trim(),
      updatedAt: DateTime.now(),
    );
    await HiveService.saveSubject(updated);
    _subjects[index] = updated;
    notifyListeners();
  }

  /// Delete a subject and cascade-delete its topics and sessions.
  Future<void> deleteSubject(String id) async {
    await HiveService.deleteSubject(id);
    await HiveService.deleteTopicsBySubject(id);
    await HiveService.deleteSessionsBySubject(id);
    _subjects.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  /// Get a subject by ID.
  Subject? getSubjectById(String id) {
    try {
      return _subjects.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get subject name by ID (safe).
  String getSubjectName(String id) {
    return getSubjectById(id)?.name ?? 'Unknown Subject';
  }

  /// Check if a subject name already exists.
  bool subjectNameExists(String name, [String? excludeId]) {
    return _subjects.any(
      (s) => s.name.toLowerCase() == name.trim().toLowerCase() && s.id != excludeId,
    );
  }
}
