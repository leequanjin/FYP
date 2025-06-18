import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.existingText ?? "");
    _entryDate = widget.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String getFormattedDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')} "
        "${_monthName(date.month)} "
        "${date.year}";
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
    return Scaffold(
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
                      onPressed: () {
                        // TODO: Save logic
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Save'),
                    ),
                  ],
                ),
              ),

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
                    Text(
                      getFormattedDate(_entryDate),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    FilledButton(
                      onPressed: () {},
                      style: FilledButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                      ), // TODO: AI Chat button logic
                      child: const Text("AI Chat"),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.surfaceContainerLowest,
                  child: Padding(
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
              ),

              Container(
                width: double.infinity,
                color: Theme.of(context).colorScheme.surfaceContainerLowest,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        // TODO: Open Mood Picker
                      },
                      icon: const Icon(Icons.emoji_emotions_outlined),
                      label: const Text("Mood"),
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: () {
                        // TODO: Open Tag Selector
                      },
                      icon: const Icon(Icons.sell_outlined),
                      label: const Text("Tags"),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      tooltip: 'Font Style',
                      onPressed: () {
                        // TODO: Font style logic
                      },
                      icon: const Icon(Icons.font_download),
                    ),
                    IconButton(
                      tooltip: 'Texture',
                      onPressed: () {
                        // TODO: Texture logic
                      },
                      icon: const Icon(Icons.texture),
                    ),
                    IconButton(
                      tooltip: 'Align Text',
                      onPressed: () {
                        // TODO: Text alignment logic
                      },
                      icon: const Icon(Icons.format_align_center),
                    ),
                    IconButton(
                      tooltip: 'Insert Image',
                      onPressed: () {
                        // TODO: Image insert logic
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
