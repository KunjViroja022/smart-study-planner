import 'package:flutter/material.dart';
import '../models/topic.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

/// A tile widget for displaying a topic with its status and estimated time.
class TopicTile extends StatelessWidget {
  final Topic topic;
  final VoidCallback onStatusTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TopicTile({
    super.key,
    required this.topic,
    required this.onStatusTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = getStatusColor(topic.status);
    final statusIcon = getStatusIcon(topic.status);

    return Dismissible(
      key: Key(topic.id),
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
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.sm),
        padding: const EdgeInsets.all(AppSizes.sm + 4),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusSm),
          border: Border.all(color: Colors.white.withAlpha(13)),
        ),
        child: Row(
          children: [
            // Status toggle button
            GestureDetector(
              onTap: onStatusTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(AppSizes.sm),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(statusIcon, color: statusColor, size: 22),
              ),
            ),
            const SizedBox(width: AppSizes.sm + 4),
            // Topic info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topic.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      decoration: topic.status == TopicStatus.completed
                          ? TextDecoration.lineThrough
                          : null,
                      color: topic.status == TopicStatus.completed
                          ? AppColors.textHint
                          : null,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 14,
                        color: AppColors.textHint,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        formatDuration(topic.estimatedStudyMinutes),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: AppSizes.sm + 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withAlpha(20),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          topic.statusLabel,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Edit button
            IconButton(
              icon: const Icon(Icons.edit_rounded, size: 18),
              color: AppColors.textHint,
              onPressed: onEdit,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Topic'),
        content: Text(
          'Delete "${topic.name}"? Related sessions will also be removed.',
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
