import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// A glassmorphism-style stats card for the dashboard.
class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final LinearGradient? gradient;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor = AppColors.primary,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null ? AppColors.cardDark : null,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        border: Border.all(color: Colors.white.withAlpha(20)),
        boxShadow: gradient != null
            ? [
                BoxShadow(
                  color: gradient!.colors.first.withAlpha(40),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.sm),
            decoration: BoxDecoration(
              color: iconColor.withAlpha(30),
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusSm),
            ),
            child: Icon(icon, color: iconColor, size: AppSizes.iconMd),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            value,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
