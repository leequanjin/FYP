import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moodly/db/tables/journal_table.dart';
import 'package:moodly/models/JournalEntry.dart';
import 'package:moodly/pages/home/entry_page.dart';
import 'package:moodly/pages/image/FullImagePage.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  JournalEntry? _selectedEntry;
  Map<String, JournalEntry> _entryMap = {}; // key = yyyy-MM-dd

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadAllEntries();
  }

  void _loadAllEntries() async {
    final entries = await JournalTable.getAll();
    final map = <String, JournalEntry>{};
    for (var entry in entries) {
      map[entry.date] = entry;
    }

    setState(() {
      _entryMap = map;
    });

    _loadJournalEntry(_selectedDay!);
  }

  void _loadJournalEntry(DateTime day) {
    final key = DateFormat('dd-MM-yyyy').format(day);
    setState(() {
      _selectedEntry = _entryMap[key];
    });
  }

  Color _getMoodColor(String? mood) {
    switch (mood) {
      case 'Awesome!':
        return Colors.green;
      case 'Great':
        return Colors.orange;
      case 'Neutral':
        return Colors.grey;
      case 'Bad':
        return Colors.blue;
      case 'Terrible...':
        return Colors.red;
      default:
        return Colors.transparent;
    }
  }

  List<String> _validToShow(JournalEntry entry) {
    final thumbs = entry.thumbPaths;
    final src = thumbs.isNotEmpty ? thumbs : entry.imagePaths;
    return src
        .where((p) => p.trim().isNotEmpty && File(p).existsSync())
        .toList();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      _loadJournalEntry(selectedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.expand(), // ensure it fills the screen
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                // 📅 Calendar Card
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                      width: 1,
                    ),
                  ),
                  color: Theme.of(context).colorScheme.surface,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                    child: TableCalendar(
                      firstDay: DateTime.utc(2010, 10, 20),
                      lastDay: DateTime.utc(2040, 10, 20),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) =>
                          isSameDay(_selectedDay, day),
                      calendarFormat: _calendarFormat,
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      headerStyle: HeaderStyle(
                        titleCentered: true,
                        formatButtonVisible: false,
                        titleTextStyle: Theme.of(context).textTheme.titleMedium!
                            .copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                        leftChevronIcon: Icon(
                          Icons.chevron_left,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        rightChevronIcon: Icon(
                          Icons.chevron_right,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      daysOfWeekStyle: DaysOfWeekStyle(
                        weekdayStyle: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        weekendStyle: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      daysOfWeekHeight: 32,
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.tertiaryContainer,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        selectedDecoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        defaultDecoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        weekendDecoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        defaultTextStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                        weekendTextStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                        todayTextStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                        selectedTextStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                        cellMargin: const EdgeInsets.all(4),
                        isTodayHighlighted: true,
                        outsideDaysVisible: false,
                      ),
                      calendarBuilders: CalendarBuilders(
                        markerBuilder: (context, date, _) {
                          final key = DateFormat('dd-MM-yyyy').format(date);
                          final entry = _entryMap[key];
                          if (entry != null) {
                            return Positioned(
                              bottom: 12,
                              child: Container(
                                height: 3,
                                width: 24,
                                decoration: BoxDecoration(
                                  color: _getMoodColor(entry.mood),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                      onDaySelected: _onDaySelected,
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                      width: 1,
                    ),
                  ),
                  child: Container(
                    color: Theme.of(context).colorScheme.surface,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_selectedEntry != null && _validToShow(_selectedEntry!).isNotEmpty) ...[
                            SizedBox(
                              height: 140,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: _validToShow(_selectedEntry!).length,
                                separatorBuilder: (_, __) => const SizedBox(width: 8),
                                itemBuilder: (context, i) {
                                  final path = _validToShow(_selectedEntry!)[i];
                                  final full = _selectedEntry!.imagePaths;
                                  final thumbs = _selectedEntry!.thumbPaths;
                                  final showList = (thumbs.isNotEmpty ? thumbs : full);
                                  final iInShowList = showList.indexOf(path);
                                  final fullPath = (iInShowList >= 0 && iInShowList < full.length)
                                      ? full[iInShowList]
                                      : path;

                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: GestureDetector(
                                      onTap: () {
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
                            const SizedBox(height: 12),
                          ],
                          const SizedBox(height: 12),
                          Text(
                            _selectedEntry?.content?.isNotEmpty == true
                                ? _selectedEntry!.content!
                                : "(Empty Entry)",
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),

                          Align(
                            alignment: Alignment.centerRight,
                            child: FilledButton.icon(
                              icon: const Icon(Icons.edit, size: 18),
                              label: const Text("Edit"),
                              onPressed: () {
                                final parsedDate = _selectedEntry != null
                                    ? DateFormat('dd-MM-yyyy').parse(_selectedEntry!.date)
                                    : _focusedDay;

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EntryPage(
                                      existingText: _selectedEntry?.content ?? '',
                                      date: parsedDate,
                                    ),
                                  ),
                                ).then((_) => _loadAllEntries());
                              },
                            ),
                          ),
                        ],
                      ),

                    ),
                  ),
                )

              ],
            ),
          ),
        ),
      ),
    );
  }
}
