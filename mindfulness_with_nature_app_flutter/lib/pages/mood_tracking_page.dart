import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/mood_entry.dart';
import '../services/mood_service.dart';
import '../services/auth_service.dart';

class MoodTrackingPage extends StatefulWidget {
  const MoodTrackingPage({super.key});

  @override
  State<MoodTrackingPage> createState() => _MoodTrackingPageState();
}

class _MoodTrackingPageState extends State<MoodTrackingPage> {
  final _formKey = GlobalKey<FormState>();
  int _moodLevel = 3;
  int _stressLevel = 3;
  final _notesController = TextEditingController();
  bool _showHistory = true;

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFFDC2626), // Error red
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF87A96B), // Sage Green
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> _saveMoodEntry() async {
    if (!Provider.of<AuthService>(context, listen: false).isLoggedIn) {
      _showErrorSnackBar('Please log in to save mood entries');
      return;
    }

    final authService = Provider.of<AuthService>(context, listen: false);
    final moodService = Provider.of<MoodService>(context, listen: false);

    final entry = MoodEntry(
      timestamp: DateTime.now(),
      moodLevel: _moodLevel,
      stressLevel: _stressLevel,
      notes: _notesController.text.trim(),
      userId: authService.userEmail!,
    );

    try {
      await moodService.addEntry(entry);

      if (mounted) {
        // Reset the form
        setState(() {
          _moodLevel = 3;
          _stressLevel = 3;
          _notesController.clear();
        });

        _showSuccessSnackBar('Mood entry saved successfully!');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to save mood entry');
      }
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F4E9), // Pale Sand
      appBar: AppBar(
        title: Text(
          'Mood & Stress Tracking',
          style: TextStyle(
            color: Color(0xFF2E5E3A), // Deep Forest
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Color(0xFF87A96B), // Sage Green
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFD1E5F0), // Pale Sky Blue
                    Color(0xFFF8F4E9), // Pale Sand
                ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF87A96B).withOpacity(0.1),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(0xFF87A96B).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.psychology, color: Color(0xFF87A96B), size: 20),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'How are you feeling today?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2E5E3A), // Deep Forest
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Track your emotional wellbeing and stress levels to build mindfulness awareness',
                    style: TextStyle(
                      color: Color(0xFF708090), // Slate
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Mood Entry Form
            Form(
              key: _formKey,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current State',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E5E3A), // Deep Forest
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Mood Level Section
                    _buildEmotionSection(
                      title: 'Mood Level',
                      value: _moodLevel,
                      onChanged: (value) => setState(() => _moodLevel = value.round()),
                      getLabel: _getMoodLabel,
                      getEmoji: _getMoodEmoji,
                      color: Color(0xFF87A96B), // Sage Green
                    ),

                    const SizedBox(height: 24),

                    // Stress Level Section
                    _buildEmotionSection(
                      title: 'Stress Level',
                      value: _stressLevel,
                      onChanged: (value) => setState(() => _stressLevel = value.round()),
                      getLabel: _getStressLabel,
                      getEmoji: _getStressEmoji,
                      color: Color(0xFFA2C4D9), // Soft Sky Blue
                    ),

                    const SizedBox(height: 24),

                    // Notes Field
                    Text(
                      'Notes (Optional)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF36454F), // Charcoal
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        hintText: 'What\'s influencing your mood today?',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Color(0xFFB8C9A9)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Color(0xFFB8C9A9)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Color(0xFF87A96B), width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      maxLines: 3,
                    ),

                    const SizedBox(height: 24),

                    // Submit Button
                    Consumer<AuthService>(
                      builder: (context, authService, child) {
                        return SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: authService.isLoading ? null : _saveMoodEntry,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF87A96B), // Sage Green
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: authService.isLoading
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.save, size: 20),
                                      SizedBox(width: 8),
                                      Text(
                                        'Save Entry',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // History Section Toggle
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Color(0xFFD8E4D3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'View Mood History',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E5E3A),
                    ),
                  ),
                  Switch(
                    value: _showHistory,
                    onChanged: (value) => setState(() => _showHistory = value),
                    activeColor: Color(0xFF87A96B),
                  ),
                ],
              ),
            ),

            if (_showHistory) ...[
              const SizedBox(height: 16),
              _buildHistorySection(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionSection({
    required String title,
    required int value,
    required Function(double) onChanged,
    required String Function(int) getLabel,
    required String Function(int) getEmoji,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF36454F), // Charcoal
              ),
            ),
            Spacer(),
            Text(
              getLabel(value),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Text(
                getEmoji(value),
                style: TextStyle(fontSize: 32),
              ),
              const SizedBox(height: 12),
              Slider(
                value: value.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                onChanged: onChanged,
                activeColor: color,
                inactiveColor: color.withOpacity(0.3),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(5, (index) {
                  final level = index + 1;
                  return Column(
                    children: [
                      Text(
                        getEmoji(level),
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 4),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: value == level ? color : color.withOpacity(0.3),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistorySection() {
    return Consumer<MoodService>(
      builder: (context, moodService, child) {
        final entries = moodService.entries;
        
        if (entries.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(Icons.auto_graph, size: 48, color: Color(0xFFB8C9A9)),
                SizedBox(height: 16),
                Text(
                  'No mood entries yet',
                  style: TextStyle(
                    color: Color(0xFF708090),
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Start tracking to see your emotional patterns',
                  style: TextStyle(
                    color: Color(0xFFB8B8B8),
                    fontSize: 14,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Mood History',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E5E3A),
                    ),
                  ),
                  Spacer(),
                  Text(
                    '${entries.length} entries',
                    style: TextStyle(
                      color: Color(0xFF708090),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: _buildMoodChart(entries),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMoodChart(List<MoodEntry> entries) {
    final sortedEntries = entries.toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    if (sortedEntries.length < 2) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart, size: 48, color: Color(0xFFB8C9A9)),
            SizedBox(height: 16),
            Text(
              'Add more entries to see trends',
              style: TextStyle(color: Color(0xFF708090)),
            ),
          ],
        ),
      );
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Color(0xFFE2E8F0),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < sortedEntries.length) {
                  final date = sortedEntries[value.toInt()].timestamp;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('MM/dd').format(date),
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF708090),
                      ),
                    ),
                  );
                }
                return const Text('');
              },
              reservedSize: 32,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF708090),
                  ),
                );
              },
              reservedSize: 28,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Color(0xFFE2E8F0), width: 1),
        ),
        lineBarsData: [
          // Mood line
          LineChartBarData(
            spots: List.generate(sortedEntries.length, (index) {
              return FlSpot(
                index.toDouble(), 
                sortedEntries[index].moodLevel.toDouble()
              );
            }),
            isCurved: true,
            color: Color(0xFF87A96B), // Sage Green
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  Color(0xFF87A96B).withOpacity(0.3),
                  Color(0xFF87A96B).withOpacity(0.1),
                ],
              ),
            ),
          ),
          // Stress line
          LineChartBarData(
            spots: List.generate(sortedEntries.length, (index) {
              return FlSpot(
                index.toDouble(),
                sortedEntries[index].stressLevel.toDouble()
              );
            }),
            isCurved: true,
            color: Color(0xFFA2C4D9), // Soft Sky Blue
            barWidth: 3,
            dotData: const FlDotData(show: true),
          ),
        ],
        minX: 0,
        maxX: (sortedEntries.length - 1).toDouble(),
        minY: 1,
        maxY: 5,
      ),
    );
  }

  String _getMoodLabel(int level) {
    switch (level) {
      case 1: return 'Very Low';
      case 2: return 'Low';
      case 3: return 'Neutral';
      case 4: return 'Good';
      case 5: return 'Great';
      default: return 'Unknown';
    }
  }

  String _getMoodEmoji(int level) {
    switch (level) {
      case 1: return '😢';
      case 2: return '😕';
      case 3: return '😐';
      case 4: return '🙂';
      case 5: return '😊';
      default: return '😐';
    }
  }

  String _getStressLabel(int level) {
    switch (level) {
      case 1: return 'Very Low';
      case 2: return 'Low';
      case 3: return 'Medium';
      case 4: return 'High';
      case 5: return 'Very High';
      default: return 'Unknown';
    }
  }

  String _getStressEmoji(int level) {
    switch (level) {
      case 1: return '😌';
      case 2: return '🙂';
      case 3: return '😐';
      case 4: return '😟';
      case 5: return '😰';
      default: return '😐';
    }
  }
}