import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subject_provider.dart';
import '../providers/topic_provider.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import '../widgets/subject_tile.dart';
import 'topic_management_screen.dart';

class SubjectManagementScreen extends StatelessWidget {
  const SubjectManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<SubjectProvider, TopicProvider>(
      builder: (context, subjectProv, topicProv, _) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(title: const Text('Subjects'), actions: [
            IconButton(icon: const Icon(Icons.sort_rounded), onPressed: () {}, tooltip: 'Sort'),
          ]),
          body: subjectProv.subjects.isEmpty
              ? _buildEmptyState(context)
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: subjectProv.subjects.length,
                  itemBuilder: (context, index) {
                    final subject = subjectProv.subjects[index];
                    final completion = topicProv.getSubjectCompletion(subject.id);
                    final topicCount = topicProv.getTopicsBySubject(subject.id).length;
                    return SubjectTile(
                      subject: subject,
                      completionPercent: completion,
                      topicCount: topicCount,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TopicManagementScreen(subjectId: subject.id, subjectName: subject.name))),
                      onEdit: () => _showSubjectDialog(context, subjectProv, subject: subject),
                      onDelete: () {
                        subjectProv.deleteSubject(subject.id);
                        topicProv.deleteTopicsBySubject(subject.id);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${subject.name} deleted')));
                      },
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showSubjectDialog(context, subjectProv),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Subject'),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.menu_book_rounded, size: 80, color: AppColors.textHint.withAlpha(80)),
        const SizedBox(height: 16),
        Text('No Subjects Yet', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.textHint)),
        const SizedBox(height: 8),
        Text('Tap the button below to add your first subject', style: Theme.of(context).textTheme.bodyMedium),
      ]),
    );
  }

  void _showSubjectDialog(BuildContext context, SubjectProvider provider, {dynamic subject}) {
    final isEdit = subject != null;
    final controller = TextEditingController(text: isEdit ? subject.name : '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEdit ? 'Edit Subject' : 'Add Subject'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Subject Name', hintText: 'e.g., Mathematics'),
            validator: (val) {
              final nameErr = Validators.subjectName(val);
              if (nameErr != null) return nameErr;
              final existingNames = provider.subjects.where((s) => !isEdit || s.id != subject.id).map((s) => s.name).toList();
              return Validators.duplicateSubject(val, existingNames);
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                if (isEdit) {
                  provider.updateSubject(subject.id, controller.text);
                } else {
                  provider.addSubject(controller.text);
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
