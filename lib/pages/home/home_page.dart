import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moodly/db/tables/journal_table.dart';
import 'package:moodly/models/JournalEntry.dart';
import 'package:moodly/pages/home/entry_page.dart';
import 'package:moodly/pages/image/FullImagePage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> _months = [];
  final Map<String, List<JournalEntry>> _monthEntriesCache = {};
  final Map<String, bool> _loadingMonth = {};
  final Set<String> _expandedMonths = {};

  @override
  void initState() {
    super.initState();
    _loadMonths();
  }

  Future<void> _loadMonths() async {
    final allEntries = await JournalTable.getAll();

    final months = <String>{};
    for (var entry in allEntries) {
      final date = DateFormat('dd-MM-yyyy').parse(entry.date);
      months.add(DateFormat('MMM yyyy').format(date));
    }

    final sortedMonths = months.toList()
      ..sort(
        (a, b) => DateFormat(
          'MMM yyyy',
        ).parse(b).compareTo(DateFormat('MMM yyyy').parse(a)),
      );

    final currentMonth = DateFormat('MMM yyyy').format(DateTime.now());
    String? expandMonth;
    if (sortedMonths.contains(currentMonth)) {
      expandMonth = currentMonth;
    } else if (sortedMonths.isNotEmpty) {
      expandMonth = sortedMonths.first;
    }

    setState(() {
      _months = sortedMonths;
      if (expandMonth != null) {
        _expandedMonths.add(expandMonth);
        _loadingMonth[expandMonth] = true;
      }
    });

    if (expandMonth != null) {
      await _loadMonthEntries(expandMonth);
    }
  }

  Future<void> _loadMonthEntries(String monthKey) async {
    if (_monthEntriesCache.containsKey(monthKey)) return;

    setState(() => _loadingMonth[monthKey] = true);

    final allEntries = await JournalTable.getAll();
    final entries =
        allEntries.where((e) {
          final d = DateFormat('dd-MM-yyyy').parse(e.date);
          return DateFormat('MMM yyyy').format(d) == monthKey;
        }).toList()..sort(
          (a, b) => DateFormat(
            'dd-MM-yyyy',
          ).parse(b.date).compareTo(DateFormat('dd-MM-yyyy').parse(a.date)),
        );

    setState(() {
      _monthEntriesCache[monthKey] = entries;
      _loadingMonth[monthKey] = false;
    });
  }

  Future<void> _deleteEntry(int id, String monthKey) async {
    await JournalTable.delete(id);
    _monthEntriesCache.remove(monthKey);
    await _loadMonthEntries(monthKey);
  }

  Future<void> _navigateToEntryPage({String? text, DateTime? date}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EntryPage(existingText: text, date: date),
      ),
    );
    _monthEntriesCache.clear();
    _expandedMonths.clear();
    await _loadMonths();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: _months.length,
          itemBuilder: (context, index) {
            final month = _months[index];
            final expanded = _expandedMonths.contains(month);
            final entries = _monthEntriesCache[month] ?? const <JournalEntry>[];
            final isLoading = _loadingMonth[month] ?? false;

            return _CustomMonthTile(
              month: month,
              entries: entries,
              expanded: expanded,
              isLoading: isLoading,
              onToggle: () async {
                setState(() {
                  if (expanded) {
                    _expandedMonths.remove(month);
                  } else {
                    _expandedMonths.add(month);
                  }
                });

                if (!expanded && !_monthEntriesCache.containsKey(month)) {
                  await _loadMonthEntries(month);
                }
              },
              onTapEntry: (entry) {
                final date = DateFormat('dd-MM-yyyy').parse(entry.date);
                _navigateToEntryPage(text: entry.content, date: date);
              },
              onDeleteEntry: (entry) {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("Delete Entry"),
                    content: const Text(
                      "Are you sure you want to delete this entry?",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          await _deleteEntry(entry.id!, month);
                        },
                        child: const Text("Delete"),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            elevation: 2,
            onPressed: () => _navigateToEntryPage(),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}

class _CustomMonthTile extends StatelessWidget {
  final String month;
  final List<JournalEntry> entries;
  final bool expanded;
  final bool isLoading;
  final VoidCallback onToggle;
  final Function(JournalEntry) onTapEntry;
  final Function(JournalEntry) onDeleteEntry;

  const _CustomMonthTile({
    required this.month,
    required this.entries,
    required this.expanded,
    required this.isLoading,
    required this.onToggle,
    required this.onTapEntry,
    required this.onDeleteEntry,
  });

  IconData _getMoodIcon(String mood) {
    switch (mood) {
      case 'Awesome!':
        return Icons.sentiment_very_satisfied;
      case 'Great':
        return Icons.sentiment_satisfied;
      case 'Neutral':
        return Icons.sentiment_neutral;
      case 'Bad':
        return Icons.sentiment_dissatisfied;
      case 'Terrible...':
        return Icons.sentiment_very_dissatisfied;
      default:
        return Icons.emoji_emotions;
    }
  }

  Color _getMoodColor(String mood) {
    switch (mood) {
      case 'Awesome!':
        return Colors.green;
      case 'Great':
        return Colors.lightGreen;
      case 'Neutral':
        return Colors.blue;
      case 'Bad':
        return Colors.orange;
      case 'Terrible...':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  List<String> _validToShow(JournalEntry entry) {
    final thumbs = entry.thumbPaths;
    final src = thumbs.isNotEmpty ? thumbs : entry.imagePaths;
    return src
        .where((p) => p.trim().isNotEmpty && File(p).existsSync())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            child: Container(
              padding: const EdgeInsets.fromLTRB(36, 12, 24, 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    month,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (expanded) ...[
            const Divider(height: 1),

            if (entries.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'No entries',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              )
            else
              Column(
                children: [
                  for (int i = 0; i < entries.length; i++) ...[
                    _EntryTile(
                      entry: entries[i],
                      getMoodIcon: _getMoodIcon,
                      getMoodColor: _getMoodColor,
                      validToShow: _validToShow,
                      onTapEntry: onTapEntry,
                      onDeleteEntry: onDeleteEntry,
                    ),
                    if (i != entries.length - 1)
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: Theme.of(context).colorScheme.outlineVariant,
                        indent: 8,
                        endIndent: 8,
                      ),
                  ],
                ],
              ),
          ],
        ],
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  final JournalEntry entry;
  final IconData Function(String) getMoodIcon;
  final Color Function(String) getMoodColor;
  final List<String> Function(JournalEntry) validToShow;
  final Function(JournalEntry) onTapEntry;
  final Function(JournalEntry) onDeleteEntry;

  const _EntryTile({
    required this.entry,
    required this.getMoodIcon,
    required this.getMoodColor,
    required this.validToShow,
    required this.onTapEntry,
    required this.onDeleteEntry,
  });

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('dd-MM-yyyy').parse(entry.date);
    final mood = entry.mood;
    final toShow = validToShow(entry);

    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                getMoodIcon(mood),
                color: getMoodColor(mood),
                size: 32,
              ),
              title: Text(
                DateFormat('d MMMM, EEEE').format(date),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                (entry.content == null || entry.content!.isEmpty)
                    ? '(No content)'
                    : entry.content!.length > 100
                    ? '${entry.content!.substring(0, 100)}...'
                    : entry.content!,
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    onTapEntry(entry);
                  } else if (value == 'delete') {
                    onDeleteEntry(entry);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit Note')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ),
            if (toShow.isNotEmpty) ...[
              const SizedBox(height: 6),
              SizedBox(
                height: 140,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: toShow.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final path = toShow[i];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: GestureDetector(
                        onTap: () {
                          final full = entry.imagePaths;
                          final thumbs = entry.thumbPaths;

                          final showList = (thumbs.isNotEmpty ? thumbs : full);
                          final iInShowList = showList.indexOf(path);
                          final fullPath =
                              (iInShowList >= 0 && iInShowList < full.length)
                              ? full[iInShowList]
                              : path;

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FullImagePage(imagePath: fullPath),
                            ),
                          );
                        },
                        child: Image.file(
                          File(path),
                          width: 160,
                          height: 140,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
