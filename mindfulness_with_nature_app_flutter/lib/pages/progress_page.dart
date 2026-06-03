import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/mood_stress_tracker_service.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  final MoodStressTrackerService _trackerService = MoodStressTrackerService();

  List<MoodStressEntry> _entries = [];
  bool _isLoading = true;
  bool _isSaving = false;
  String? _loadError;

  int _moodValue = 5;
  int _stressValue = 5;

  late DateTime _selectedMonth;
  bool _webDisclosureShown = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month);
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final entries = await _trackerService
          .loadEntries()
          .timeout(const Duration(seconds: 8));

      if (!mounted) return;
      setState(() => _entries = entries);
      _showWebDisclosureIfNeeded();
    } on TimeoutException {
      if (!mounted) return;
      setState(() {
        _loadError = 'Loading took too long. Please try again.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadError = 'Unable to load your progress right now.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showWebDisclosureIfNeeded() {
    if (!kIsWeb || _webDisclosureShown || !mounted) {
      return;
    }

    _webDisclosureShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Web tracking notice'),
            content: const Text(
              'On web, mood/stress tracking is not saved between browser '
              'sessions and is not limited to once per day. Install the app '
              'for full tracking behavior.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    });
  }

  Future<void> _saveEntry() async {
    if (_isSaving) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final canAdd = await _trackerService.canAddToday();
      if (!canAdd) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('You can save one mood/stress entry per day on mobile.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      await _trackerService.addEntry(mood: _moodValue, stress: _stressValue);
      await _loadEntries();

      if (!mounted) return;
      final now = DateTime.now();
      setState(() => _selectedMonth = DateTime(now.year, now.month));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Entry saved.'),
          backgroundColor: Color(0xFF556B2F),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save entry. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  /// Returns entries for [month] sorted oldest-first.
  List<MoodStressEntry> _monthEntries(DateTime month) {
    final filtered = _entries
        .where(
          (e) =>
              e.timestamp.year == month.year &&
              e.timestamp.month == month.month,
        )
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return filtered;
  }

  Set<int> _availableMonthKeys() {
    return _entries
        .map((e) => e.timestamp.year * 100 + e.timestamp.month)
        .toSet();
  }

  bool _canGoPrevMonth() {
    final keys = _availableMonthKeys();
    final prev = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    return keys.contains(prev.year * 100 + prev.month);
  }

  bool _canGoNextMonth() {
    final keys = _availableMonthKeys();
    final next = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    return keys.contains(next.year * 100 + next.month);
  }

  String _monthLabel(DateTime month) {
    const names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${names[month.month - 1]} ${month.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _loadError != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _loadError!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF2C1F14),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _loadEntries,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        const Center(
                          child: Text(
                            'Progress',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C1F14),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        _buildTrackerCard(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildTrackerCard() {
    final monthData = _monthEntries(_selectedMonth);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EAE0),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'Mood and Stress Tracker',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2C1F14),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Mood: $_moodValue / 10',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2C1F14),
            ),
          ),
          Slider(
            value: _moodValue.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            activeColor: const Color(0xFF5B4FCF),
            onChanged: (v) => setState(() => _moodValue = v.round()),
          ),
          const SizedBox(height: 8),
          Text(
            'Stress: $_stressValue / 10',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2C1F14),
            ),
          ),
          Slider(
            value: _stressValue.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            activeColor: const Color(0xFFE57373),
            onChanged: (v) => setState(() => _stressValue = v.round()),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveEntry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B5C3E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Save Entry'),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              IconButton(
                onPressed: _canGoPrevMonth()
                    ? () {
                        setState(() {
                          _selectedMonth = DateTime(
                              _selectedMonth.year, _selectedMonth.month - 1);
                        });
                      }
                    : null,
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    _monthLabel(_selectedMonth),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C1F14),
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: _canGoNextMonth()
                    ? () {
                        setState(() {
                          _selectedMonth = DateTime(
                              _selectedMonth.year, _selectedMonth.month + 1);
                        });
                      }
                    : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (monthData.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'No mood/stress entries for this month yet.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF6B5C3E),
                  fontSize: 14,
                ),
              ),
            )
          else ...[
            // Legend
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      color: Color(0xFF5B4FCF),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Mood',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF5B4FCF),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE57373),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Stress',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFFE57373),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 360,
              child: LineChart(_buildChartData(monthData)),
            ),
          ],
        ],
      ),
    );
  }

  /// Builds a chart from raw [entries] ordered by timestamp.
  /// Each entry is one dot; entries on the same day are spread by index so
  /// every point is always individually visible on the x-axis.
  LineChartData _buildChartData(List<MoodStressEntry> entries) {
    // Assign a sequential x value (1-based) per entry so every dot is
    // distinct even when multiple entries share the same calendar day.
    final moodSpots = List.generate(
      entries.length,
      (i) => FlSpot((i + 1).toDouble(), entries[i].mood.toDouble()),
    );
    final stressSpots = List.generate(
      entries.length,
      (i) => FlSpot((i + 1).toDouble(), entries[i].stress.toDouble()),
    );

    final count = entries.length.toDouble();

    // Build bottom-axis labels: show the calendar day for each entry.
    final dayLabels = {
      for (var i = 0; i < entries.length; i++) i + 1: entries[i].timestamp.day
    };

    return LineChartData(
      minX: 1,
      maxX: count < 2 ? 2 : count,
      minY: 1,
      maxY: 10,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (_) =>
            FlLine(color: const Color(0xFFE0D8CD), strokeWidth: 0.8),
        getDrawingVerticalLine: (_) =>
            FlLine(color: const Color(0xFFEDE8E0), strokeWidth: 0.5),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xFFCDC2B2)),
      ),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            reservedSize: 28,
            getTitlesWidget: (value, meta) {
              if (value < 1 || value > 10) return const SizedBox.shrink();
              return Text(
                value.toInt().toString(),
                style: const TextStyle(fontSize: 10, color: Color(0xFF6B5C3E)),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          axisNameWidget: const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Text(
              'Day of month',
              style: TextStyle(fontSize: 10, color: Color(0xFF9E8E72)),
            ),
          ),
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: (value, meta) {
              final idx = value.toInt();
              final day = dayLabels[idx];
              if (day == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  day.toString(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF6B5C3E),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: moodSpots,
          isCurved: true,
          curveSmoothness: 0.3,
          color: const Color(0xFF5B4FCF),
          barWidth: 2.5,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
              radius: 5,
              color: const Color(0xFF5B4FCF),
              strokeWidth: 2,
              strokeColor: Colors.white,
            ),
          ),
          belowBarData: BarAreaData(
            show: true,
            color: const Color(0xFF5B4FCF).withOpacity(0.08),
          ),
        ),
        LineChartBarData(
          spots: stressSpots,
          isCurved: true,
          curveSmoothness: 0.3,
          color: const Color(0xFFE57373),
          barWidth: 2.5,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
              radius: 5,
              color: const Color(0xFFE57373),
              strokeWidth: 2,
              strokeColor: Colors.white,
            ),
          ),
          belowBarData: BarAreaData(
            show: true,
            color: const Color(0xFFE57373).withOpacity(0.06),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (spots) {
            return spots.map((spot) {
              final idx = spot.x.toInt();
              final day = dayLabels[idx];
              final label = spot.barIndex == 0 ? 'Mood' : 'Stress';
              final dayStr = day != null ? ' (day $day)' : '';
              return LineTooltipItem(
                '$label: ${spot.y.toStringAsFixed(1)}$dayStr',
                const TextStyle(color: Colors.white, fontSize: 12),
              );
            }).toList();
          },
        ),
      ),
    );
  }
}
