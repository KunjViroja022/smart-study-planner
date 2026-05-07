import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subject_provider.dart';
import '../providers/topic_provider.dart';
import '../models/topic.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class SearchFilterScreen extends StatefulWidget {
  const SearchFilterScreen({super.key});

  @override
  State<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  String _searchQuery = '';
  String? _filterSubjectId;
  TopicStatus? _filterStatus;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<SubjectProvider, TopicProvider>(
      builder: (context, subjectProv, topicProv, _) {
        var filtered = topicProv.topics.toList();

        // Apply search
        if (_searchQuery.isNotEmpty) {
          filtered = filtered.where((t) => t.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
        }
        // Apply subject filter
        if (_filterSubjectId != null) {
          filtered = filtered.where((t) => t.subjectId == _filterSubjectId).toList();
        }
        // Apply status filter
        if (_filterStatus != null) {
          filtered = filtered.where((t) => t.status == _filterStatus).toList();
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(title: const Text('Search & Filter')),
          body: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search topics...',
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textHint),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(icon: const Icon(Icons.clear_rounded, color: AppColors.textHint), onPressed: () { _searchController.clear(); setState(() => _searchQuery = ''); })
                        : null,
                  ),
                ),
              ),
              // Filter chips
              SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    // Subject filter
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(_filterSubjectId != null ? subjectProv.getSubjectName(_filterSubjectId!) : 'All Subjects'),
                        selected: _filterSubjectId != null,
                        onSelected: (_) => _showSubjectFilter(context, subjectProv),
                        avatar: const Icon(Icons.menu_book_rounded, size: 16),
                      ),
                    ),
                    // Status filters
                    ...[
                      (TopicStatus.completed, 'Completed', AppColors.completed),
                      (TopicStatus.inProgress, 'In Progress', AppColors.inProgress),
                      (TopicStatus.notStarted, 'Not Started', AppColors.notStarted),
                    ].map((item) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(item.$2),
                        selected: _filterStatus == item.$1,
                        selectedColor: item.$3.withAlpha(40),
                        onSelected: (selected) => setState(() => _filterStatus = selected ? item.$1 : null),
                      ),
                    )),
                    // Clear all
                    if (_filterSubjectId != null || _filterStatus != null)
                      ActionChip(
                        label: const Text('Clear All'),
                        avatar: const Icon(Icons.clear_all_rounded, size: 16),
                        onPressed: () => setState(() { _filterSubjectId = null; _filterStatus = null; }),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Results count
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(children: [
                  Text('${filtered.length} result${filtered.length == 1 ? '' : 's'}', style: Theme.of(context).textTheme.bodySmall),
                ]),
              ),
              const SizedBox(height: 8),
              // Results list
              Expanded(
                child: filtered.isEmpty
                    ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.search_off_rounded, size: 64, color: AppColors.textHint.withAlpha(80)),
                        const SizedBox(height: 16),
                        Text('No results found', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textHint)),
                        const SizedBox(height: 8),
                        Text('Try adjusting your search or filters', style: Theme.of(context).textTheme.bodySmall),
                      ]))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final topic = filtered[index];
                          final statusColor = getStatusColor(topic.status);
                          final subjectName = subjectProv.getSubjectName(topic.subjectId);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(color: AppColors.cardDark, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withAlpha(13))),
                            child: Row(children: [
                              Icon(getStatusIcon(topic.status), color: statusColor, size: 22),
                              const SizedBox(width: 12),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                _highlightText(topic.name, _searchQuery, context),
                                const SizedBox(height: 4),
                                Row(children: [
                                  Text(subjectName, style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w500)),
                                  const SizedBox(width: 8),
                                  Icon(Icons.timer_outlined, size: 12, color: AppColors.textHint),
                                  const SizedBox(width: 2),
                                  Text(formatDuration(topic.estimatedStudyMinutes), style: Theme.of(context).textTheme.bodySmall),
                                ]),
                              ])),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: statusColor.withAlpha(20), borderRadius: BorderRadius.circular(6)),
                                child: Text(topic.statusLabel, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600)),
                              ),
                            ]),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _highlightText(String text, String query, BuildContext context) {
    if (query.isEmpty) return Text(text, style: Theme.of(context).textTheme.titleMedium);
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final start = lowerText.indexOf(lowerQuery);
    if (start == -1) return Text(text, style: Theme.of(context).textTheme.titleMedium);

    return RichText(text: TextSpan(style: Theme.of(context).textTheme.titleMedium, children: [
      TextSpan(text: text.substring(0, start)),
      TextSpan(text: text.substring(start, start + query.length), style: const TextStyle(backgroundColor: Color(0x406C63FF), color: AppColors.primary)),
      TextSpan(text: text.substring(start + query.length)),
    ]));
  }

  void _showSubjectFilter(BuildContext context, SubjectProvider subjectProv) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Column(mainAxisSize: MainAxisSize.min, children: [
        const Padding(padding: EdgeInsets.all(16), child: Text('Filter by Subject', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
        ListTile(leading: const Icon(Icons.all_inclusive_rounded), title: const Text('All Subjects'), selected: _filterSubjectId == null,
          onTap: () { setState(() => _filterSubjectId = null); Navigator.pop(ctx); }),
        ...subjectProv.subjects.map((s) => ListTile(
          leading: const Icon(Icons.menu_book_rounded),
          title: Text(s.name),
          selected: _filterSubjectId == s.id,
          onTap: () { setState(() => _filterSubjectId = s.id); Navigator.pop(ctx); },
        )),
        const SizedBox(height: 16),
      ]),
    );
  }
}
