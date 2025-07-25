import 'package:flutter/material.dart';
import 'package:moodly/db/tables/tag_table.dart';
import 'package:moodly/models/JournalEntry.dart';
import 'package:moodly/repositories/journal_repository.dart';

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
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    _entryDate = widget.date ?? DateTime.now();
    _controller = TextEditingController(text: widget.existingText ?? "");
    _loadExistingEntry();
  }

  Future<void> _loadExistingEntry() async {
    final entry = await JournalRepository.getByDate(_entryDate);
    if (!mounted) return;
    if (entry != null) {
      setState(() {
        _existingEntry = entry;
        _controller.text = entry.content ?? "";
        _selectedMood = entry.mood;
        _tags = [...entry.tags];
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final content = _controller.text.trim().isEmpty
        ? null
        : _controller.text.trim();

    await JournalRepository.upsert(
      id: _existingEntry?.id,
      content: content,
      date: _entryDate,
      mood: _selectedMood,
      tags: _tags,
    );

    if (!mounted) return;
    Navigator.pop(context);
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
        children: moodOptions.entries
            .map(
              (entry) => ListTile(
                leading: Icon(entry.value, color: moodColors[entry.key]),
                title: Text(entry.key),
                onTap: () => Navigator.pop(ctx, entry.key),
              ),
            )
            .toList(),
      ),
    );

    if (selected != null) {
      setState(() => _selectedMood = selected);
    }
  }

  Future<void> _editTags() async {
    final all = await TagTable.getAllNames();
    final result = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      builder: (_) =>
          _PredefinedTagPicker(allTags: all, initiallySelected: _tags.toSet()),
    );

    if (result != null) {
      setState(() => _tags = result);
    }
  }

  String getFormattedDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')} ${_monthName(date.month)} ${date.year}";
  }

  String _monthName(int month) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
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
                      onPressed: _save,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
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
                            _tags = [];
                          });
                          _loadExistingEntry();
                        }
                      },
                      child: Text(
                        getFormattedDate(_entryDate),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
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
              if (!keyboardOpen)
                Column(
                  children: [
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: Theme.of(context).colorScheme.outlineVariant,
                      indent: 8,
                      endIndent: 8,
                    ),
                    Container(
                      width: double.infinity,
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerLowest,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton.icon(
                                onPressed: _editTags,
                                icon: const Icon(Icons.sell_outlined),
                                label: Text("Tags (${_tags.length})"),
                              ),
                              TextButton.icon(
                                onPressed: _pickMood,
                                icon: const Icon(Icons.emoji_emotions_outlined),
                                label: Text(
                                  _selectedMood,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (_tags.isNotEmpty)
                            Wrap(
                              spacing: 8,
                              runSpacing: -4,
                              children: _tags.map((t) {
                                return FilterChip(
                                  label: Text(t),
                                  selected: true,
                                  onSelected: (_) => _editTags(),
                                );
                              }).toList(),
                            ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ],
                ),

              // Bottom row of icons
              // Padding(
              //   padding: const EdgeInsets.symmetric(vertical: 4.0),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //     children: [
              //       IconButton(
              //         tooltip: 'Font Style',
              //         onPressed: () {},
              //         icon: const Icon(Icons.font_download),
              //       ),
              //       IconButton(
              //         tooltip: 'Bulleted List',
              //         onPressed: () {},
              //         icon: const Icon(Icons.format_list_bulleted),
              //       ),
              //       IconButton(
              //         tooltip: 'Bold Text',
              //         onPressed: () {},
              //         icon: const Icon(Icons.format_bold),
              //       ),
              //       IconButton(
              //         tooltip: 'Insert Image',
              //         onPressed: () {},
              //         icon: const Icon(Icons.image),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PredefinedTagPicker extends StatefulWidget {
  final List<String> allTags;
  final Set<String> initiallySelected;

  const _PredefinedTagPicker({
    required this.allTags,
    required this.initiallySelected,
  });

  @override
  State<_PredefinedTagPicker> createState() => _PredefinedTagPickerState();
}

class _PredefinedTagPickerState extends State<_PredefinedTagPicker> {
  late final Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = {...widget.initiallySelected};
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.45,
        minChildSize: 0.3,
        maxChildSize: 0.95,
        builder: (_, controller) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      'Select tags',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, _selected.toList()),
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                controller: controller,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Wrap(
                  spacing: 8,
                  runSpacing: -4,
                  children: widget.allTags.map((t) {
                    final selected = _selected.contains(t);
                    return FilterChip(
                      label: Text(t),
                      selected: selected,
                      onSelected: (v) {
                        setState(() {
                          if (v) {
                            _selected.add(t);
                          } else {
                            _selected.remove(t);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
