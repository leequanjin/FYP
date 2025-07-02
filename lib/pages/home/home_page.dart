import 'package:flutter/material.dart';
import 'package:moodly/pages/home/entry_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  MonthCard(month: "Mar 2024", entries: ["03 Sun"]),
                  MonthCard(
                    month: "Feb 2024",
                    entries: ["29 Thu", "28 Wed", "26 Mon"],
                  ),
                  MonthCard(
                    month: "Jan 2024",
                    entries: ["29 Thu", "28 Wed", "26 Mon"],
                  ),
                  MonthCard(
                    month: "Dec 2023",
                    entries: ["29 Thu", "28 Wed", "26 Mon"],
                  ),
                  SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            elevation: 2,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EntryPage()),
              );
            },
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}

class MonthCard extends StatelessWidget {
  final String month;
  final List<String> entries;

  const MonthCard({super.key, required this.month, required this.entries});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Text(
              month,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),

          ...List.generate(entries.length * 2 - 1, (index) {
            if (index.isEven) {
              final entryIndex = index ~/ 2;
              return Material(
                color: Theme.of(context).colorScheme.surface,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EntryPage(
                          existingText: "Previously written content",
                          date: DateTime(2024, 3, 3),
                        ),
                      ),
                    );
                  },
                  child: ListTile(
                    title: Text(
                      entries[entryIndex],
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                  ),
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
