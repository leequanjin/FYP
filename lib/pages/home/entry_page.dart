import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moodly/db/tables/journal_table.dart';
import 'package:moodly/models/JournalEntry.dart';

class EntryPage extends StatefulWidget {
  final String? existingText;
  final DateTime? date;

  const EntryPage({super.key, this.existingText, this.date});

  @override
  State<EntryPage> createState() => _EntryPageState();
}

class _EntryPageState extends State<EntryPage> {
  late TextEditingController _controller;
  late DateTime _entryDate;
  JournalEntry? _existingEntry;
  String _selectedMood = 'Okay';

  @override
  void initState() {
    super.initState();
    _entryDate = widget.date ?? DateTime.now();
    _controller = TextEditingController(text: widget.existingText ?? "");
    _loadExistingEntry();
  }

  void _loadExistingEntry() async {
    final entry = await JournalTable.getByDate(_entryDate);
    if (entry != null) {
      setState(() {
        _existingEntry = entry;
        _controller.text = entry.content ?? "";
        _selectedMood = entry.mood;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _pickMood() async {
    final moodOptions = {
      'Awesome!': Icons.sentiment_very_satisfied,
      'Great': Icons.sentiment_satisfied,
      'Okay': Icons.sentiment_neutral,
      'Bad': Icons.sentiment_dissatisfied,
      'Terrible...': Icons.sentiment_very_dissatisfied,
    };

    final moodColors = {
      'Awesome!': Colors.green,
      'Great': Colors.orange,
      'Okay': Colors.grey,
      'Bad': Colors.blue,
      'Terrible...': Colors.red,
    };

    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => ListView(
        children: moodOptions.entries.map(
              (entry) => ListTile(
            leading: Icon(entry.value, color: moodColors[entry.key]),
            title: Text(entry.key),
            onTap: () => Navigator.pop(ctx, entry.key),
          ),
        ).toList(),
      ),
    );

    if (selected != null) {
      setState(() {
        _selectedMood = selected;
      });
    }
  }

  String getFormattedDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')} ${_monthName(date.month)} ${date.year}";
  }

  String _monthName(int month) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App bar actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      label: const Text('Cancel'),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        final content = _controller.text.trim().isEmpty ? null : _controller.text.trim();

                        if (content == null && _selectedMood.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Please add content or select a mood.")),
                          );
                          return;
                        }

                        if (_existingEntry != null && _existingEntry!.id != null) {
                          await JournalTable.update(
                            _existingEntry!.id!,
                            content,
                            _entryDate,
                            _selectedMood,
                          );
                        } else {
                          final found = await JournalTable.getByDate(_entryDate);
                          if (found != null) {
                            await JournalTable.update(
                              found.id!,
                              content,
                              _entryDate,
                              _selectedMood,
                            );
                          } else {
                            await JournalTable.add(
                              content,
                              _entryDate,
                              _selectedMood,
                            );
                          }
                        }

                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Save'),
                    ),
                  ],
                ),
              ),

              // Header with date and AI chat button
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _entryDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null && picked != _entryDate) {
                          setState(() {
                            _entryDate = picked;
                            _controller.clear();
                            _existingEntry = null;
                            _selectedMood = 'Okay';
                          });
                          _loadExistingEntry();
                        }
                      },
                      child: Text(
                        getFormattedDate(_entryDate),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    FilledButton(
                      onPressed: () {
                        // TODO: AI chat logic
                      },
                      style: FilledButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                      ),
                      child: const Text("AI Chat"),
                    ),
                  ],
                ),
              ),

              // Text field for content
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.surfaceContainerLowest,
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _controller,
                    maxLines: null,
                    expands: true,
                    decoration: const InputDecoration.collapsed(
                      hintText: "Start writing your thoughts...",
                    ),
                  ),
                ),
              ),

              // Mood + Tags section
              Container(
                width: double.infinity,
                color: Theme.of(context).colorScheme.surfaceContainerLowest,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextButton.icon(
                      onPressed: _pickMood,
                      icon: const Icon(Icons.emoji_emotions_outlined),
                      label: Row(
                        children: [
                          const Text("Mood"),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              "($_selectedMood)",
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: () {
                        // TODO: Tags selector
                      },
                      icon: const Icon(Icons.sell_outlined),
                      label: const Text("Tags"),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),

              // Bottom row of icons
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      tooltip: 'Font Style',
                      onPressed: () {
                        // TODO: Font style
                      },
                      icon: const Icon(Icons.font_download),
                    ),
                    IconButton(
                      tooltip: 'Bulleted List',
                      onPressed: () {
                        // TODO: Bullet list
                      },
                      icon: const Icon(Icons.format_list_bulleted),
                    ),
                    IconButton(
                      tooltip: 'Bold Text',
                      onPressed: () {
                        // TODO: Bold text
                      },
                      icon: const Icon(Icons.format_bold),
                    ),
                    IconButton(
                      tooltip: 'Insert Image',
                      onPressed: () {
                        // TODO: Insert image
                      },
                      icon: const Icon(Icons.image),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
