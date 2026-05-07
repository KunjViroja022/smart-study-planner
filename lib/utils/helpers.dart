import 'package:intl/intl.dart';
import '../models/topic.dart';
import 'constants.dart';
import 'package:flutter/material.dart';

/// Format a DateTime to a readable date string.
String formatDate(DateTime date) {
  return DateFormat('MMM dd, yyyy').format(date);
}

/// Format a DateTime to a short date string.
String formatDateShort(DateTime date) {
  return DateFormat('MMM dd').format(date);
}

/// Format a DateTime to a day name (e.g., "Mon").
String formatDayName(DateTime date) {
  return DateFormat('E').format(date);
}

/// Format minutes into a human-readable duration (e.g., "2h 30m").
String formatDuration(int minutes) {
  if (minutes < 60) return '${minutes}m';
  final hours = minutes ~/ 60;
  final mins = minutes % 60;
  if (mins == 0) return '${hours}h';
  return '${hours}h ${mins}m';
}

/// Format a time string (HH:mm) to 12-hour format.
String formatTime12h(String time24) {
  try {
    final parts = time24.split(':');
    final hour = int.parse(parts[0]);
    final minute = parts[1];
    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$hour12:$minute $period';
  } catch (_) {
    return time24;
  }
}

/// Get the color for a topic status.
Color getStatusColor(TopicStatus status) {
  switch (status) {
    case TopicStatus.notStarted:
      return AppColors.notStarted;
    case TopicStatus.inProgress:
      return AppColors.inProgress;
    case TopicStatus.completed:
      return AppColors.completed;
  }
}

/// Get the icon for a topic status.
IconData getStatusIcon(TopicStatus status) {
  switch (status) {
    case TopicStatus.notStarted:
      return Icons.radio_button_unchecked;
    case TopicStatus.inProgress:
      return Icons.timelapse_rounded;
    case TopicStatus.completed:
      return Icons.check_circle_rounded;
  }
}

/// Get the priority label based on completion percentage.
String getPriorityLabel(double completionPercent) {
  if (completionPercent < 30) return 'Needs Attention';
  if (completionPercent < 70) return 'In Progress';
  return 'On Track';
}

/// Get the priority color based on completion percentage.
Color getPriorityColor(double completionPercent) {
  if (completionPercent < 30) return AppColors.error;
  if (completionPercent < 70) return AppColors.warning;
  return AppColors.success;
}

/// Check if a date is today.
bool isToday(DateTime date) {
  final now = DateTime.now();
  return date.year == now.year &&
      date.month == now.month &&
      date.day == now.day;
}

/// Get a greeting based on the time of day.
String getGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good Morning';
  if (hour < 17) return 'Good Afternoon';
  return 'Good Evening';
}
