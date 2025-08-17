import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moodly/db/tables/tag_table.dart';
import 'package:moodly/models/JournalEntry.dart';
import 'package:moodly/pages/home/chat_page.dart';
import 'package:moodly/pages/image/FullImagePage.dart';
import 'package:moodly/repositories/journal_repository.dart';
import 'package:moodly/utils/thumbnail_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

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
  final ImagePicker _picker = ImagePicker();

  JournalEntry? _existingEntry;
  String _selectedMood = 'Neutral';
  List<String> _tags = [];

  final List<String> _imagePaths = [];
  final List<String> _thumbPaths = [];

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
        _imagePaths.addAll(entry.imagePaths);
        _thumbPaths.addAll(entry.thumbPaths);
      });
    }
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final appDir = await getApplicationDocumentsDirectory();
    final fileName =
        "${DateTime.now().millisecondsSinceEpoch}_${p.basename(picked.path)}";
    final newPath = p.join(appDir.path, fileName);
    final copiedFile = await File(picked.path).copy(newPath);

    final thumbPath = await ThumbnailHelper.createThumb(copiedFile.path);

    setState(() {
      _imagePaths.add(copiedFile.path);
      _thumbPaths.add(thumbPath);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final content =
    _controller.text.trim().isEmpty ? null : _controller.text.trim();

    await JournalRepository.upsert(
      id: _existingEntry?.id,
      content: content,
      date: _entryDate,
      mood: _selectedMood,
      tags: _tags,
      imagePaths: _imagePaths,
      thumbPaths: _thumbPaths,
    );

    if (!mounted) return;
    Navigator.pop(context);
  }

  void _pickMood() async {
    final moodOptions = {
      'Awesome!': Icons.sentiment_very_satisfied,
      'Great': Icons.sentiment_satisfied,
      'Neutral': Icons.sentiment_neutral,
      'Bad': Icons.sentiment_dissatisfied,
      'Terrible...': Icons.sentiment_very_dissatisfied,
    };

    final moodColors = {
      'Awesome!': Colors.green,
      'Great': Colors.lightGreen,
      'Neutral': Colors.blue,
      'Bad': Colors.orange,
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

  Future<void> _removeImageAt(int index) async {
    try {
      if (index >= 0 && index < _imagePaths.length) {
        final f = File(_imagePaths[index]);
        if (await f.exists()) await f.delete();
      }
      if (index >= 0 && index < _thumbPaths.length) {
        final t = File(_thumbPaths[index]);
        if (await t.exists()) await t.delete();
      }
    } catch (_) {}

    setState(() {
      _imagePaths.removeAt(index);
      _thumbPaths.removeAt(index);
    });
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

              // Header with date + add image
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                            _selectedMood = 'Neutral';
                            _tags = [];
                            _imagePaths.clear();
                            _thumbPaths.clear();
                          });
                          _loadExistingEntry();
                        }
                      },
                      child: Text(
                        getFormattedDate(_entryDate),
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimaryContainer,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          tooltip: "Add Image",
                          icon: const Icon(
                              Icons.add_photo_alternate_outlined),
                          onPressed: _pickImage,
                        ),
                        IconButton(
                          tooltip: "AI Chat",
                          icon: const Icon(Icons.android),
                          onPressed: () async {
                            final summary = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ChatPage()),
                            );

                            if (summary != null && summary is Map<String, dynamic>) {
                              final text = summary['summary'] as String?;
                              final mood = summary['mood'] as String?;
                              final tags = (summary['tags'] as List?)?.cast<String>();

                              setState(() {
                                final currentText = _controller.text.trim();
                                if (text != null && text.isNotEmpty) {
                                  _controller.text = currentText.isEmpty
                                      ? text
                                      : "$currentText\n\n$text";
                                }
                                if (mood != null && mood.isNotEmpty) _selectedMood = mood;
                                if (tags != null && tags.isNotEmpty) _tags = tags;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Text field + thumbs
              Expanded(
                child: Container(
                  color:
                  Theme.of(context).colorScheme.surfaceContainerLowest,
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_thumbPaths.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: List.generate(_thumbPaths.length, (i) {
                              final thumb = _thumbPaths[i];
                              final full = (i < _imagePaths.length)
                                  ? _imagePaths[i]
                                  : _imagePaths.isNotEmpty
                                  ? _imagePaths.first
                                  : thumb;

                              return Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              FullImagePage(imagePath: full),
                                        ),
                                      );
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        File(thumb),
                                        height: 120,
                                        width: 120,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close,
                                        color: Colors.red),
                                    onPressed: () => _removeImageAt(i),
                                  ),
                                ],
                              );
                            }),
                          ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _controller,
                          maxLines: null,
                          decoration: const InputDecoration.collapsed(
                            hintText: "Start writing your thoughts...",
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Mood + Tags
              if (!keyboardOpen)
                Column(
                  children: [
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: Theme.of(context)
                          .colorScheme
                          .outlineVariant,
                      indent: 8,
                      endIndent: 8,
                    ),
                    Container(
                      width: double.infinity,
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerLowest,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton.icon(
                                onPressed: _editTags,
                                icon: const Icon(Icons.sell_outlined),
                                label: Text("Tags (${_tags.length})"),
                              ),
                              TextButton.icon(
                                onPressed: _pickMood,
                                icon: const Icon(
                                    Icons.emoji_emotions_outlined),
                                label: Text(_selectedMood),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (_tags.isNotEmpty)
                            Wrap(
                              spacing: 8,
                              runSpacing: -4,
                              children: _tags
                                  .map(
                                    (t) => FilterChip(
                                  label: Text(t),
                                  selected: true,
                                  onSelected: (_) => _editTags(),
                                ),
                              )
                                  .toList(),
                            ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ],
                ),
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
                    child: Text('Select tags',
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () =>
                        Navigator.pop(context, _selected.toList()),
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
                    horizontal: 12, vertical: 8),
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
