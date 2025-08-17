import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:moodly/repositories/journal_repository.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  final List<String> moods = [
    'Awesome!',
    'Great',
    'Neutral',
    'Bad',
    'Terrible...',
  ];

  Map<String, int> moodCounts = {};
  int? touchedIndex;
  int? highlightedIndex;
  List<dynamic> _allEntries = [];
  List<int> _years = [];
  int? _selectedYear;
  int? _selectedMonth;

  @override
  void initState() {
    super.initState();
    _loadAllEntries();
  }

  Future<void> _loadAllEntries() async {
    final entries = await JournalRepository.getAll();
    _allEntries = entries;

    final yearsSet = <int>{};
    for (var entry in entries) {
      try {
        final date = DateFormat('dd-MM-yyyy').parse(entry.date);
        yearsSet.add(date.year);
      } catch (_) {}
    }

    _years = yearsSet.toList()..sort();
    _applyFilters();
  }

  void _applyFilters() {
    final Map<String, int> counts = {for (var mood in moods) mood: 0};

    for (var entry in _allEntries) {
      DateTime? date;
      try {
        date = DateFormat('dd-MM-yyyy').parse(entry.date);
      } catch (_) {
        continue;
      }

      if (_selectedYear != null && date.year != _selectedYear) continue;
      if (_selectedMonth != null && date.month != _selectedMonth) continue;

      if (counts.containsKey(entry.mood)) {
        counts[entry.mood] = counts[entry.mood]! + 1;
      }
    }

    setState(() {
      moodCounts = counts;
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = moodCounts.values.fold<int>(0, (sum, count) => sum + count);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildFilterBar(),
          const SizedBox(height: 20),
          moodCounts.isEmpty
              ? const Expanded(
            child: Center(child: CircularProgressIndicator()),
          )
              : Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Mood Distribution",
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 250,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 50,
                        borderData: FlBorderData(show: false),
                        sections: _buildPieSections(total),
                        pieTouchData: PieTouchData(
                          touchCallback: (event, response) {
                            if (response == null ||
                                response.touchedSection == null) {
                              setState(() {
                                touchedIndex = null;
                                highlightedIndex = null;
                              });
                              return;
                            }

                            final index = response
                                .touchedSection!
                                .touchedSectionIndex;

                            if (event is FlLongPressStart ||
                                event is FlLongPressMoveUpdate ||
                                event is FlPanUpdateEvent) {
                              setState(() {
                                highlightedIndex = index;
                              });
                            } else if (event is FlLongPressEnd ||
                                event is FlPanEndEvent ||
                                event is FlTapUpEvent) {
                              setState(() {
                                highlightedIndex = null;
                              });
                            }

                            if (event.isInterestedForInteractions) {
                              setState(() {
                                touchedIndex = index;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildLegend(total),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<int?>(
            value: _selectedYear,
            decoration: const InputDecoration(labelText: "Year"),
            items: [
              DropdownMenuItem(
                value: null,
                child: const Text(
                  "All Years",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ..._years.map(
                    (year) => DropdownMenuItem(
                  value: year,
                  child: Text(
                    year.toString(),
                    style: const TextStyle(fontWeight: FontWeight.normal),
                  ),
                ),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _selectedYear = value;
                _selectedMonth = null;
              });
              _applyFilters();
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonFormField<int?>(
            value: _selectedMonth,
            decoration: const InputDecoration(labelText: "Month"),
            items: [
              DropdownMenuItem(
                value: null,
                child: Text(
                  "All Months",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _selectedYear == null ? Colors.grey : null,
                  ),
                ),
              ),
              ...List.generate(12, (i) {
                final monthName = DateFormat.MMMM().format(DateTime(0, i + 1));
                return DropdownMenuItem(
                  value: i + 1,
                  child: Text(
                    monthName,
                    style: const TextStyle(fontWeight: FontWeight.normal),
                  ),
                );
              }),
            ],
            onChanged: _selectedYear == null
                ? null
                : (value) {
              setState(() {
                _selectedMonth = value;
              });
              _applyFilters();
            },
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildPieSections(int total) {
    final colors = [
      Colors.green,
      Colors.lightGreen,
      Colors.blue,
      Colors.orange,
      Colors.red,
    ];

    if (total == 0) {
      return [
        PieChartSectionData(
          value: 1,
          color: Theme.of(context).colorScheme.secondaryContainer,
          title: 'No Data',
          titleStyle: TextStyle(color: Theme.of(context).colorScheme.onSecondaryContainer,),
          radius: 60,
        ),
      ];
    }

    return List.generate(moods.length, (index) {
      final count = moodCounts[moods[index]] ?? 0;
      final percentage = (count / total) * 100;
      final isTouched = index == touchedIndex;

      return PieChartSectionData(
        color: colors[index],
        value: count.toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',
        radius: isTouched ? 75 : 65,
        titleStyle: TextStyle(
          fontSize: isTouched ? 18 : 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      );
    });
  }

  Widget _buildLegend(int total) {
    final colors = [
      Colors.green,
      Colors.lightGreen,
      Colors.blue,
      Colors.orange,
      Colors.red,
    ];

    return Column(
      children: List.generate(moods.length, (index) {
        final count = moodCounts[moods[index]] ?? 0;
        final percentage = total == 0 ? 0 : (count / total) * 100;
        final isHighlighted = highlightedIndex == index;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: isHighlighted
                ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1)
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: colors[index],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  moods[index],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              SizedBox(
                width: 30,
                child: Text(
                  "$count",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              SizedBox(
                width: 60,
                child: Text(
                  "(${percentage.toStringAsFixed(1)}%)",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
