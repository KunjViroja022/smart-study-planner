import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/topic_provider.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import '../utils/helpers.dart';
import '../widgets/topic_tile.dart';

class TopicManagementScreen extends StatelessWidget {
  final String subjectId;
  final String subjectName;

  const TopicManagementScreen({super.key, required this.subjectId, required this.subjectName});

  @override
  Widget build(BuildContext context) {
    return Consumer<TopicProvider>(
      builder: (context, topicProv, _) {
        final topics = topicProv.getTopicsBySubject(subjectId);
        final completion = topicProv.getSubjectCompletion(subjectId);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(title: Text(subjectName)),
          body: Column(
            children: [
              // Progress header
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [getPriorityColor(completion).withAlpha(40), AppColors.cardDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withAlpha(13)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('${topics.length} Topics', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 8),
                        ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: completion / 100, minHeight: 8, backgroundColor: AppColors.surface, valueColor: AlwaysStoppedAnimation(getPriorityColor(completion)))),
                        const SizedBox(height: 4),
                        Text('${completion.toInt()}% complete', style: Theme.of(context).textTheme.bodySmall),
                      ]),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(color: getPriorityColor(completion).withAlpha(25), borderRadius: BorderRadius.circular(8)),
                      child: Text(getPriorityLabel(completion), style: TextStyle(color: getPriorityColor(completion), fontWeight: FontWeight.w600, fontSize: 12)),
                    ),
                  ],
                ),
              ),
              // Topics list
              Expanded(
                child: topics.isEmpty
                    ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.topic_rounded, size: 64, color: AppColors.textHint.withAlpha(80)),
                        const SizedBox(height: 16),
                        Text('No topics yet', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.textHint)),
                        const SizedBox(height: 8),
                        Text('Add topics to track your progress', style: Theme.of(context).textTheme.bodyMedium),
                      ]))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: topics.length,
                        itemBuilder: (context, index) {
                          final topic = topics[index];
                          return TopicTile(
                            topic: topic,
                            onStatusTap: () => topicProv.cycleTopicStatus(topic.id),
                            onEdit: () => _showTopicDialog(context, topicProv, topic: topic),
                            onDelete: () {
                              topicProv.deleteTopic(topic.id);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${topic.name} deleted')));
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showTopicDialog(context, topicProv),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Topic'),
          ),
        );
      },
    );
  }

  void _showTopicDialog(BuildContext context, TopicProvider provider, {dynamic topic}) {
    final isEdit = topic != null;
    final nameController = TextEditingController(text: isEdit ? topic.name : '');
    final timeController = TextEditingController(text: isEdit ? topic.estimatedStudyMinutes.toString() : '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEdit ? 'Edit Topic' : 'Add Topic'),
        content: Form(
          key: formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(controller: nameController, autofocus: true, decoration: const InputDecoration(labelText: 'Topic Name', hintText: 'e.g., Calculus Basics'), validator: Validators.topicName),
            const SizedBox(height: 12),
            TextFormField(controller: timeController, decoration: const InputDecoration(labelText: 'Estimated Time (minutes)', hintText: 'e.g., 60'), keyboardType: TextInputType.number, validator: Validators.studyTime),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                if (isEdit) {
                  provider.updateTopic(id: topic.id, name: nameController.text, estimatedStudyMinutes: int.parse(timeController.text.trim()));
                } else {
                  provider.addTopic(subjectId: subjectId, name: nameController.text, estimatedStudyMinutes: int.parse(timeController.text.trim()));
                }
                Navigator.of(ctx).pop();
              }
            },
            child: Text(isEdit ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }
}
