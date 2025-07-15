import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moodly/db/tables/journal_table.dart';
import 'package:moodly/models/JournalEntry.dart';
import 'package:moodly/pages/home/entry_page.dart';
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
      case 'Okay':
        return Colors.grey;
      case 'Bad':
        return Colors.blue;
      case 'Terrible...':
        return Colors.red;
      default:
        return Colors.transparent;
    }
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
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
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
                          if (entry != null && entry.mood != null) {
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
                      onFormatChanged: (format) {
                        if (_calendarFormat != format) {
                          setState(() {
                            _calendarFormat = format;
                          });
                        }
                      },
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // 📝 Entry Card
                _selectedEntry != null
                    ? Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.outlineVariant,
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedEntry!.content?.isNotEmpty == true
                                    ? _selectedEntry!.content!
                                    : "(No content)",
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.edit, size: 18),
                                  label: const Text("Edit"),
                                  onPressed: () {
                                    final parsedDate = DateFormat(
                                      'dd-MM-yyyy',
                                    ).parse(_selectedEntry!.date);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => EntryPage(
                                          existingText: _selectedEntry!.content,
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
                      )
                    : Center(
                        child: Text(
                          "No entry for this day.",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
