import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/subject_provider.dart';
import '../providers/topic_provider.dart';
import '../models/topic.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<SubjectProvider, TopicProvider>(
      builder: (context, subjectProv, topicProv, _) {
        final completed = topicProv.completedTopics;
        final inProgress = topicProv.inProgressTopics;
        final notStarted = topicProv.totalTopics - completed - inProgress;

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(title: const Text('Progress')),
          body: topicProv.totalTopics == 0
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.bar_chart_rounded, size: 80, color: AppColors.textHint.withAlpha(80)),
                  const SizedBox(height: 16),
                  Text('No Progress Data', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.textHint)),
                  const SizedBox(height: 8),
                  Text('Add subjects and topics to track progress', style: Theme.of(context).textTheme.bodyMedium),
                ]))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    // Donut chart
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: AppColors.cardDark, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withAlpha(13))),
                      child: Column(children: [
                        Text('Topic Status Distribution', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 200,
                          child: PieChart(PieChartData(
                            sectionsSpace: 3,
                            centerSpaceRadius: 50,
                            sections: [
                              if (completed > 0) PieChartSectionData(value: completed.toDouble(), title: '$completed', color: AppColors.completed, radius: 40, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                              if (inProgress > 0) PieChartSectionData(value: inProgress.toDouble(), title: '$inProgress', color: AppColors.inProgress, radius: 40, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                              if (notStarted > 0) PieChartSectionData(value: notStarted.toDouble(), title: '$notStarted', color: AppColors.notStarted, radius: 40, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                            ],
                          )),
                        ),
                        const SizedBox(height: 16),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                          _legendItem('Completed', AppColors.completed, completed),
                          _legendItem('In Progress', AppColors.inProgress, inProgress),
                          _legendItem('Not Started', AppColors.notStarted, notStarted),
                        ]),
                      ]),
                    ),
                    const SizedBox(height: 24),
                    // Subject-wise progress
                    Text('Subject-wise Progress', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    ...subjectProv.subjects.map((subject) {
                      final completion = topicProv.getSubjectCompletion(subject.id);
                      final subTopics = topicProv.getTopicsBySubject(subject.id);
                      final completedCount = subTopics.where((t) => t.status == TopicStatus.completed).length;
                      final priorityColor = getPriorityColor(completion);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(color: AppColors.cardDark, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withAlpha(13))),
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          leading: Container(width: 4, height: 40, decoration: BoxDecoration(color: priorityColor, borderRadius: BorderRadius.circular(2))),
                          title: Row(children: [
                            Expanded(child: Text(subject.name, style: Theme.of(context).textTheme.titleMedium)),
                            Text('$completedCount/${subTopics.length}', style: TextStyle(color: priorityColor, fontWeight: FontWeight.bold)),
                          ]),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: completion / 100, minHeight: 6, backgroundColor: AppColors.surface, valueColor: AlwaysStoppedAnimation(priorityColor))),
                          ),
                          children: subTopics.map((topic) {
                            final statusColor = getStatusColor(topic.status);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(children: [
                                Icon(getStatusIcon(topic.status), color: statusColor, size: 18),
                                const SizedBox(width: 10),
                                Expanded(child: Text(topic.name, style: Theme.of(context).textTheme.bodyMedium?.copyWith(decoration: topic.status == TopicStatus.completed ? TextDecoration.lineThrough : null, color: topic.status == TopicStatus.completed ? AppColors.textHint : AppColors.textPrimary))),
                                Text(formatDuration(topic.estimatedStudyMinutes), style: Theme.of(context).textTheme.bodySmall),
                              ]),
                            );
                          }).toList(),
                        ),
                      );
                    }),
                    const SizedBox(height: 80),
                  ]),
                ),
        );
      },
    );
  }

  Widget _legendItem(String label, Color color, int count) {
    return Row(children: [
      Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
      const SizedBox(width: 6),
      Text('$label ($count)', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
    ]);
  }
}
