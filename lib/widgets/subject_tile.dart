import 'package:flutter/material.dart';
import '../models/subject.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

/// A card tile for displaying a subject with its completion info.
class SubjectTile extends StatelessWidget {
  final Subject subject;
  final double completionPercent;
  final int topicCount;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const SubjectTile({
    super.key,
    required this.subject,
    required this.completionPercent,
    required this.topicCount,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final priorityColor = getPriorityColor(completionPercent);
    final priorityLabel = getPriorityLabel(completionPercent);

    return Dismissible(
      key: Key(subject.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSizes.lg),
        decoration: BoxDecoration(
          color: AppColors.error.withAlpha(30),
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        ),
        child: const Icon(Icons.delete_rounded, color: AppColors.error, size: 28),
      ),
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSizes.sm),
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            border: Border.all(color: Colors.white.withAlpha(13)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Subject icon
                  Container(
                    padding: const EdgeInsets.all(AppSizes.sm + 2),
                    decoration: BoxDecoration(
                      color: priorityColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(AppSizes.borderRadiusSm),
                    ),
                    child: Icon(
                      Icons.menu_book_rounded,
                      color: priorityColor,
                      size: AppSizes.iconMd,
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm + 4),
                  // Subject info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subject.name,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSizes.xs),
                        Text(
                          '$topicCount ${topicCount == 1 ? 'topic' : 'topics'}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  // Priority badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.sm + 2,
                      vertical: AppSizes.xs,
                    ),
                    decoration: BoxDecoration(
                      color: priorityColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(AppSizes.borderRadiusSm),
                    ),
                    child: Text(
                      priorityLabel,
                      style: TextStyle(
                        color: priorityColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.xs),
                  // Edit button
                  IconButton(
                    icon: const Icon(Icons.edit_rounded, size: 18),
                    color: AppColors.textHint,
                    onPressed: onEdit,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.sm + 4),
              // Progress bar
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: completionPercent / 100,
                        minHeight: 6,
                        backgroundColor: AppColors.surface,
                        valueColor: AlwaysStoppedAnimation<Color>(priorityColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm + 4),
                  Text(
                    '${completionPercent.toInt()}%',
                    style: TextStyle(
                      color: priorityColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Subject'),
        content: Text(
          'Delete "${subject.name}" and all its topics and sessions? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
