import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/subject_provider.dart';
import '../providers/topic_provider.dart';
import '../providers/session_provider.dart';
import '../services/sync_service.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../widgets/stats_card.dart';
import '../widgets/circular_progress.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<SubjectProvider, TopicProvider, SessionProvider>(
      builder: (context, subjectProv, topicProv, sessionProv, _) {
        final weeklyData = sessionProv.getWeeklyStudyMinutes();
        final suggestedTopic = topicProv.getSuggestedNextTopic(
          subjectProv.subjects.map((s) => s.id).toList(),
        );

        return CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 100,
              floating: true,
              pinned: false,
              backgroundColor: Colors.transparent,
              actions: [
                IconButton(
                  icon: const Icon(Icons.cloud_upload_rounded, color: AppColors.primary),
                  tooltip: 'Sync to Cloud',
                  onPressed: () async {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Syncing data to Firebase...')),
                    );
                    await firebaseSync.syncToRemote();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sync complete!')),
                      );
                    }
                  },
                ),
                const SizedBox(width: 8),
              ],
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(getGreeting(), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.normal)),
                    const Text('Study Dashboard', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Stats Grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.4,
                    children: [
                      StatsCard(title: 'Subjects', value: '${subjectProv.subjects.length}', icon: Icons.menu_book_rounded, iconColor: AppColors.primary),
                      StatsCard(title: 'Completed', value: '${topicProv.completedTopics}', icon: Icons.check_circle_rounded, iconColor: AppColors.success),
                      StatsCard(title: 'Pending', value: '${topicProv.pendingTopics}', icon: Icons.pending_actions_rounded, iconColor: AppColors.warning),
                      StatsCard(title: 'Study Time', value: formatDuration(sessionProv.totalStudyMinutes), icon: Icons.timer_rounded, iconColor: AppColors.accent),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Overall Progress
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: AppColors.cardDark, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withAlpha(13))),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Overall Progress', style: Theme.of(context).textTheme.titleLarge),
                            Text('${topicProv.completedTopics}/${topicProv.totalTopics} topics', style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                        const SizedBox(height: 20),
                        CircularProgress(
                          percentage: topicProv.overallCompletion,
                          size: 140,
                          progressColor: _getProgressColor(topicProv.overallCompletion),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Weekly Study Chart
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: AppColors.cardDark, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withAlpha(13))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Weekly Study Progress', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 4),
                        Text('Minutes studied per day', style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(height: 20),
                        SizedBox(height: 180, child: _buildWeeklyChart(weeklyData)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Suggested Next Topic
                  if (suggestedTopic != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: AppColors.accentGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: AppColors.accent.withAlpha(60), blurRadius: 12, offset: const Offset(0, 4))],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: Colors.white.withAlpha(30), borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.lightbulb_rounded, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Suggested Next', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
                                const SizedBox(height: 2),
                                Text(suggestedTopic.name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                                Text('${subjectProv.getSubjectName(suggestedTopic.subjectId)} • ${formatDuration(suggestedTopic.estimatedStudyMinutes)}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Priority Subjects
                  if (subjectProv.subjects.isNotEmpty) ...[
                    Text('Priority Subjects', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text('Subjects needing the most attention', style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 12),
                    ...topicProv.getSubjectsByPriority(subjectProv.subjects.map((s) => s.id).toList()).take(3).map((subjectId) {
                      final subject = subjectProv.getSubjectById(subjectId);
                      if (subject == null) return const SizedBox.shrink();
                      final completion = topicProv.getSubjectCompletion(subjectId);
                      final priorityColor = getPriorityColor(completion);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: AppColors.cardDark, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withAlpha(13))),
                        child: Row(
                          children: [
                            Container(width: 4, height: 40, decoration: BoxDecoration(color: priorityColor, borderRadius: BorderRadius.circular(2))),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(subject.name, style: Theme.of(context).textTheme.titleMedium),
                                const SizedBox(height: 4),
                                ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: completion / 100, minHeight: 5, backgroundColor: AppColors.surface, valueColor: AlwaysStoppedAnimation(priorityColor))),
                              ]),
                            ),
                            const SizedBox(width: 12),
                            Text('${completion.toInt()}%', style: TextStyle(color: priorityColor, fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                      );
                    }),
                  ],

                  // Empty State
                  if (subjectProv.subjects.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(Icons.school_rounded, size: 64, color: AppColors.textHint.withAlpha(80)),
                          const SizedBox(height: 16),
                          Text('No subjects yet', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.textHint)),
                          const SizedBox(height: 8),
                          Text('Add your first subject to get started!', style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ),
                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        );
      },
    );
  }

  Color _getProgressColor(double percent) {
    if (percent < 30) return AppColors.error;
    if (percent < 70) return AppColors.warning;
    return AppColors.success;
  }

  Widget _buildWeeklyChart(Map<DateTime, int> weeklyData) {
    final entries = weeklyData.entries.toList();
    final maxY = entries.fold<double>(60, (max, e) => e.value > max ? e.value.toDouble() : max);

    return BarChart(
      BarChartData(
        maxY: maxY + 20,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem('${rod.toY.toInt()} min', const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12));
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 35, getTitlesWidget: (value, meta) => Text('${value.toInt()}', style: const TextStyle(color: AppColors.textHint, fontSize: 10)))),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
            if (value.toInt() < entries.length) {
              return Padding(padding: const EdgeInsets.only(top: 8), child: Text(formatDayName(entries[value.toInt()].key), style: const TextStyle(color: AppColors.textHint, fontSize: 10, fontWeight: FontWeight.w500)));
            }
            return const Text('');
          })),
        ),
        gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: maxY / 4, getDrawingHorizontalLine: (value) => FlLine(color: Colors.white.withAlpha(10), strokeWidth: 1)),
        borderData: FlBorderData(show: false),
        barGroups: entries.asMap().entries.map((entry) {
          final isToday = entry.key == entries.length - 1;
          return BarChartGroupData(x: entry.key, barRods: [
            BarChartRodData(toY: entry.value.value.toDouble(), width: 20, borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
              gradient: isToday ? const LinearGradient(colors: [AppColors.accent, AppColors.accentLight], begin: Alignment.bottomCenter, end: Alignment.topCenter)
                : const LinearGradient(colors: [AppColors.primary, AppColors.primaryLight], begin: Alignment.bottomCenter, end: Alignment.topCenter)),
          ]);
        }).toList(),
      ),
    );
  }
}
