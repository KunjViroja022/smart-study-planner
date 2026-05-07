import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../providers/subject_provider.dart';
import '../providers/topic_provider.dart';
import '../providers/session_provider.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../utils/validators.dart';
import '../widgets/session_card.dart';

class StudySchedulingScreen extends StatefulWidget {
  const StudySchedulingScreen({super.key});

  @override
  State<StudySchedulingScreen> createState() => _StudySchedulingScreenState();
}

class _StudySchedulingScreenState extends State<StudySchedulingScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;

  @override
  Widget build(BuildContext context) {
    return Consumer3<SubjectProvider, TopicProvider, SessionProvider>(
      builder: (context, subjectProv, topicProv, sessionProv, _) {
        final daySessions = sessionProv.getSessionsByDate(_selectedDay);
        final colorIndex = <String, int>{};
        var ci = 0;
        for (final s in subjectProv.subjects) {
          colorIndex[s.id] = ci++ % AppColors.chartColors.length;
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(title: const Text('Schedule')),
          body: Column(
            children: [
              // Calendar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: AppColors.cardDark, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withAlpha(13))),
                child: TableCalendar(
                  firstDay: DateTime.utc(2024, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  calendarFormat: _calendarFormat,
                  onFormatChanged: (format) => setState(() => _calendarFormat = format),
                  onDaySelected: (selected, focused) => setState(() { _selectedDay = selected; _focusedDay = focused; }),
                  eventLoader: (day) {
                    final d = DateTime(day.year, day.month, day.day);
                    return sessionProv.sessionDates.contains(d) ? ['event'] : [];
                  },
                  calendarStyle: CalendarStyle(
                    defaultTextStyle: const TextStyle(color: AppColors.textPrimary),
                    weekendTextStyle: const TextStyle(color: AppColors.textSecondary),
                    outsideTextStyle: const TextStyle(color: AppColors.textHint),
                    todayDecoration: BoxDecoration(color: AppColors.primary.withAlpha(40), shape: BoxShape.circle),
                    selectedDecoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    markerDecoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                    markerSize: 5,
                    markersMaxCount: 1,
                  ),
                  headerStyle: const HeaderStyle(
                    titleTextStyle: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
                    formatButtonTextStyle: TextStyle(color: AppColors.primary, fontSize: 12),
                    formatButtonDecoration: BoxDecoration(border: Border.fromBorderSide(BorderSide(color: AppColors.primary)), borderRadius: BorderRadius.all(Radius.circular(8))),
                    leftChevronIcon: Icon(Icons.chevron_left, color: AppColors.textPrimary),
                    rightChevronIcon: Icon(Icons.chevron_right, color: AppColors.textPrimary),
                  ),
                  daysOfWeekStyle: const DaysOfWeekStyle(weekdayStyle: TextStyle(color: AppColors.textHint, fontSize: 12), weekendStyle: TextStyle(color: AppColors.textHint, fontSize: 12)),
                ),
              ),
              const SizedBox(height: 16),
              // Date header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(isToday(_selectedDay) ? 'Today\'s Sessions' : DateFormat('MMMM d, y').format(_selectedDay), style: Theme.of(context).textTheme.titleLarge),
                    Text('${daySessions.length} session${daySessions.length == 1 ? '' : 's'}', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Sessions list
              Expanded(
                child: daySessions.isEmpty
                    ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.event_available_rounded, size: 56, color: AppColors.textHint.withAlpha(80)),
                        const SizedBox(height: 12),
                        Text('No sessions scheduled', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textHint)),
                        const SizedBox(height: 4),
                        Text('Tap + to schedule a study session', style: Theme.of(context).textTheme.bodySmall),
                      ]))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: daySessions.length,
                        itemBuilder: (context, index) {
                          final session = daySessions[index];
                          final color = AppColors.chartColors[colorIndex[session.subjectId] ?? 0];
                          return SessionCard(
                            session: session,
                            subjectName: subjectProv.getSubjectName(session.subjectId),
                            topicName: topicProv.getTopicName(session.topicId),
                            accentColor: color,
                            onToggleComplete: () => sessionProv.toggleSessionCompletion(session.id),
                            onDelete: () => sessionProv.deleteSession(session.id),
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: subjectProv.subjects.isEmpty ? () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add subjects and topics first'))) : () => _showAddSessionDialog(context, subjectProv, topicProv, sessionProv),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Session'),
          ),
        );
      },
    );
  }

  void _showAddSessionDialog(BuildContext context, SubjectProvider subjectProv, TopicProvider topicProv, SessionProvider sessionProv) {
    String? selectedSubjectId;
    String? selectedTopicId;
    TimeOfDay selectedTime = TimeOfDay.now();
    final durationController = TextEditingController(text: '60');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final subjectTopics = selectedSubjectId != null ? topicProv.getTopicsBySubject(selectedSubjectId!) : <dynamic>[];
          return AlertDialog(
            title: const Text('Schedule Session'),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  // Subject dropdown
                  DropdownButtonFormField<String>(
                    value: selectedSubjectId,
                    decoration: const InputDecoration(labelText: 'Subject'),
                    items: subjectProv.subjects.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                    onChanged: (val) => setDialogState(() { selectedSubjectId = val; selectedTopicId = null; }),
                    validator: (val) => val == null ? 'Please select a subject' : null,
                  ),
                  const SizedBox(height: 12),
                  // Topic dropdown
                  DropdownButtonFormField<String>(
                    value: selectedTopicId,
                    decoration: const InputDecoration(labelText: 'Topic'),
                    items: subjectTopics.map((t) => DropdownMenuItem(value: t.id as String, child: Text(t.name as String))).toList(),
                    onChanged: (val) => setDialogState(() => selectedTopicId = val),
                    validator: (val) => val == null ? 'Please select a topic' : null,
                  ),
                  const SizedBox(height: 12),
                  // Time picker
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Start Time', style: TextStyle(fontSize: 14)),
                    trailing: TextButton(
                      onPressed: () async {
                        final time = await showTimePicker(context: ctx, initialTime: selectedTime);
                        if (time != null) setDialogState(() => selectedTime = time);
                      },
                      child: Text(selectedTime.format(ctx), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  // Duration
                  TextFormField(controller: durationController, decoration: const InputDecoration(labelText: 'Duration (minutes)'), keyboardType: TextInputType.number, validator: Validators.sessionDuration),
                ]),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    final timeStr = '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
                    sessionProv.addSession(subjectId: selectedSubjectId!, topicId: selectedTopicId!, scheduledDate: _selectedDay, startTime: timeStr, durationMinutes: int.parse(durationController.text.trim()));
                    Navigator.of(ctx).pop();
                  }
                },
                child: const Text('Schedule'),
              ),
            ],
          );
        },
      ),
    );
  }
}
