import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moodly/db/tables/journal_table.dart';
import 'package:moodly/models/JournalEntry.dart';
import 'package:moodly/pages/home/entry_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, List<JournalEntry>> _groupedEntries = {};

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  void _loadEntries() async {
    final entries = await JournalTable.getAll();
    final grouped = <String, List<JournalEntry>>{};

    for (var entry in entries) {
      final date = DateFormat('dd-MM-yyyy').parse(entry.date);
      final key = DateFormat('MMM yyyy').format(date);

      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(entry);
    }

    for (var list in grouped.values) {
      list.sort(
        (a, b) => DateFormat(
          'dd-MM-yyyy',
        ).parse(b.date).compareTo(DateFormat('dd-MM-yyyy').parse(a.date)),
      );
    }

    setState(() {
      _groupedEntries = grouped;
    });
  }

  void _deleteEntry(int id) async {
    await JournalTable.delete(id);
    _loadEntries();
  }

  void _navigateToEntryPage({String? text, DateTime? date}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EntryPage(existingText: text, date: date),
      ),
    );
    _loadEntries();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.only(bottom: 80),
          children: _groupedEntries.entries.map((e) {
            return MonthCard(
              month: e.key,
              entries: e.value,
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
                        onPressed: () {
                          Navigator.pop(ctx);
                          _deleteEntry(entry.id!);
                        },
                        child: const Text("Delete"),
                      ),
                    ],
                  ),
                );
              },
            );
          }).toList(),
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

class MonthCard extends StatelessWidget {
  final String month;
  final List<JournalEntry> entries;
  final Function(JournalEntry) onTapEntry;
  final Function(JournalEntry) onDeleteEntry;

  const MonthCard({
    super.key,
    required this.month,
    required this.entries,
    required this.onTapEntry,
    required this.onDeleteEntry,
  });

  IconData _getMoodIcon(String mood) {
    switch (mood) {
      case 'Awesome!':
        return Icons.sentiment_very_satisfied;
      case 'Great':
        return Icons.sentiment_satisfied;
      case 'Okay':
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
        return Colors.orange;
      case 'Okay':
        return Colors.grey;
      case 'Bad':
        return Colors.blue;
      case 'Terrible...':
        return Colors.red;
      default:
        return Colors.orange;
    }
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
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Center(
              child: Text(
                month,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          ...List.generate(entries.length * 2 - 1, (index) {
            if (index.isEven) {
              final entry = entries[index ~/ 2];
              final date = DateFormat('dd-MM-yyyy').parse(entry.date);
              final mood = entry.mood;

              return ListTile(
                leading: Icon(
                  _getMoodIcon(mood),
                  color: _getMoodColor(mood),
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
                    } else if (value == 'photo') {
                      // TODO: Add photo logic
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit Note'),
                    ),
                    const PopupMenuItem(
                      value: 'photo',
                      child: Text('Add Photo'),
                    ),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              );
            } else {
              return Divider(
                height: 1,
                thickness: 1,
                color: Theme.of(context).colorScheme.outlineVariant,
                indent: 8,
                endIndent: 8,
              );
            }
          }),
        ],
      ),
    );
  }
}
