import 'package:flutter/material.dart';
import '../models/study_session.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

/// A card widget for displaying a study session in the schedule.
class SessionCard extends StatelessWidget {
  final StudySession session;
  final String subjectName;
  final String topicName;
  final VoidCallback onToggleComplete;
  final VoidCallback onDelete;
  final Color accentColor;

  const SessionCard({
    super.key,
    required this.session,
    required this.subjectName,
    required this.topicName,
    required this.onToggleComplete,
    required this.onDelete,
    this.accentColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(session.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSizes.lg),
        decoration: BoxDecoration(
          color: AppColors.error.withAlpha(30),
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusSm),
        ),
        child: const Icon(Icons.delete_rounded, color: AppColors.error),
      ),
      confirmDismiss: (_) => showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Delete Session'),
          content: const Text('Delete this study session?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('Delete'),
            ),
          ],
        ),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 65,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(formatTime12h(session.startTime),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  const SizedBox(height: 2),
                  Text(formatDuration(session.durationMinutes), style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(children: [
              Container(width: 12, height: 12, decoration: BoxDecoration(color: session.isCompleted ? AppColors.success : accentColor, shape: BoxShape.circle, border: Border.all(color: Colors.white.withAlpha(40), width: 2))),
              Container(width: 2, height: 60, color: Colors.white.withAlpha(13)),
            ]),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.cardDark, borderRadius: BorderRadius.circular(AppSizes.borderRadiusSm), border: Border.all(color: session.isCompleted ? AppColors.success.withAlpha(40) : Colors.white.withAlpha(13))),
                child: Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(subjectName, style: TextStyle(color: accentColor, fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(topicName, style: Theme.of(context).textTheme.titleMedium?.copyWith(decoration: session.isCompleted ? TextDecoration.lineThrough : null, color: session.isCompleted ? AppColors.textHint : null), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ])),
                  GestureDetector(
                    onTap: onToggleComplete,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: session.isCompleted ? AppColors.success.withAlpha(30) : AppColors.surface, shape: BoxShape.circle),
                      child: Icon(session.isCompleted ? Icons.check_circle_rounded : Icons.circle_outlined, color: session.isCompleted ? AppColors.success : AppColors.textHint, size: 24),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
