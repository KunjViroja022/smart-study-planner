/// Form validation utilities.
class Validators {
  /// Validate that a field is not empty.
  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate subject name.
  static String? subjectName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Subject name is required';
    }
    if (value.trim().length < 2) {
      return 'Subject name must be at least 2 characters';
    }
    if (value.trim().length > 50) {
      return 'Subject name must be less than 50 characters';
    }
    return null;
  }

  /// Validate topic name.
  static String? topicName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Topic name is required';
    }
    if (value.trim().length < 2) {
      return 'Topic name must be at least 2 characters';
    }
    if (value.trim().length > 100) {
      return 'Topic name must be less than 100 characters';
    }
    return null;
  }

  /// Validate estimated study time.
  static String? studyTime(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Estimated study time is required';
    }
    final minutes = int.tryParse(value.trim());
    if (minutes == null) {
      return 'Please enter a valid number';
    }
    if (minutes <= 0) {
      return 'Study time must be greater than 0';
    }
    if (minutes > 480) {
      return 'Study time cannot exceed 8 hours (480 minutes)';
    }
    return null;
  }

  /// Validate session duration.
  static String? sessionDuration(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Duration is required';
    }
    final minutes = int.tryParse(value.trim());
    if (minutes == null) {
      return 'Please enter a valid number';
    }
    if (minutes <= 0) {
      return 'Duration must be greater than 0';
    }
    if (minutes > 480) {
      return 'Duration cannot exceed 8 hours (480 minutes)';
    }
    return null;
  }

  /// Check for duplicate subject name in a list.
  static String? duplicateSubject(
    String? value,
    List<String> existingNames, [
    String? excludeId,
  ]) {
    final name = value?.trim().toLowerCase();
    if (name == null || name.isEmpty) return null;
    final isDuplicate = existingNames.any(
      (existing) => existing.toLowerCase() == name,
    );
    if (isDuplicate) {
      return 'A subject with this name already exists';
    }
    return null;
  }
}
