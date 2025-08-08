import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:moodly/repositories/journal_repository.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  final List<String> moods = ['Awesome!', 'Great', 'Neutral', 'Bad', 'Terrible...'];
  Map<String, int> moodCounts = {};

  @override
  void initState() {
    super.initState();
    _loadMoodStats();
  }

  Future<void> _loadMoodStats() async {
    final entries = await JournalRepository.getAll();

    // Count occurrences of each mood
    final Map<String, int> counts = {
      for (var mood in moods) mood: 0
    };

    for (var entry in entries) {
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: moodCounts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 40,
                sections: _buildPieSections(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildLegend(),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections() {
    final colors = [
      Colors.green,
      Colors.lightGreen,
      Colors.grey,
      Colors.orange,
      Colors.red,
    ];

    final total = moodCounts.values.fold<int>(0, (sum, count) => sum + count);

    if (total == 0) {
      return [
        PieChartSectionData(
          value: 1,
          color: Colors.grey.shade300,
          title: 'No Data',
          radius: 60,
        ),
      ];
    }

    return List.generate(moods.length, (index) {
      final count = moodCounts[moods[index]] ?? 0;
      final percentage = total == 0 ? 0 : (count / total) * 100;

      return PieChartSectionData(
        color: colors[index],
        value: count.toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    });
  }

  Widget _buildLegend() {
    final colors = [
      Colors.green,
      Colors.lightGreen,
      Colors.grey,
      Colors.orange,
      Colors.red,
    ];

    return Column(
      children: List.generate(moods.length, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                color: colors[index],
              ),
              const SizedBox(width: 8),
              Text(moods[index]),
              const Spacer(),
              Text('${moodCounts[moods[index]] ?? 0}'),
            ],
          ),
        );
      }),
    );
  }
}
