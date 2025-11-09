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
  
  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _submitEntry(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      try {
        final authService = Provider.of<AuthService>(context, listen: false);
        if (authService.userEmail == null) {
          debugPrint('MoodTracking: Error - User email is null');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: User not logged in')),
          );
          return;
        }

        final moodService = Provider.of<MoodService>(context, listen: false);
        final entry = MoodEntry(
          timestamp: DateTime.now(),
          moodLevel: _moodLevel,
          stressLevel: _stressLevel,
          notes: _notesController.text.trim(),
          userId: authService.userEmail!,
        );

        debugPrint('MoodTracking: Submitting entry - Mood: $_moodLevel, Stress: $_stressLevel');
        moodService.addEntry(entry);
        _notesController.clear();
        
        setState(() {}); // Trigger a rebuild to refresh the chart
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mood entry saved!')),
        );
      } catch (e) {
        debugPrint('MoodTracking: Error saving entry - $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving mood entry: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood & Stress Tracking'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mood Entry Form
            Form(
              key: _formKey,
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'How are you feeling?',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      
                      // Mood Slider
                      Text(
                        'Mood Level: ${_moodLevel.toString()}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Slider(
                        value: _moodLevel.toDouble(),
                        min: 1,
                        max: 5,
                        divisions: 4,
                        label: _getMoodLabel(_moodLevel),
                        onChanged: (value) => setState(() => _moodLevel = value.round()),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Stress Slider
                      Text(
                        'Stress Level: ${_stressLevel.toString()}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Slider(
                        value: _stressLevel.toDouble(),
                        min: 1,
                        max: 5,
                        divisions: 4,
                        label: _getStressLabel(_stressLevel),
                        onChanged: (value) => setState(() => _stressLevel = value.round()),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Notes Field
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notes (optional)',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Submit Button
                      Consumer2<AuthService, MoodService>(
                        builder: (context, authService, moodService, _) {
                          return SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (!authService.isLoggedIn) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please log in to save mood entries'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                final entry = MoodEntry(
                                  timestamp: DateTime.now(),
                                  moodLevel: _moodLevel,
                                  stressLevel: _stressLevel,
                                  notes: _notesController.text.trim(),
                                  userId: authService.userEmail!,
                                );

                                await moodService.addEntry(entry);

                                if (!mounted) return;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Mood entry saved successfully!'),
                                    backgroundColor: Colors.green[700],
                                  ),
                                );

                                // Reset the form
                                setState(() {
                                  _moodLevel = 3;
                                  _stressLevel = 3;
                                  _notesController.clear();
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[700],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: const Text('Save Entry'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // History Chart
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Mood History',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: Consumer<MoodService>(
                        builder: (context, moodService, child) {
                          final entries = moodService.entries;
                          if (entries.isEmpty) {
                            return const Center(
                              child: Text('No mood entries yet'),
                            );
                          }
                          return _buildMoodChart(entries);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMoodLabel(int level) {
    switch (level) {
      case 1: return '😢 Very Bad';
      case 2: return '😕 Bad';
      case 3: return '😐 Okay';
      case 4: return '🙂 Good';
      case 5: return '😊 Great';
      default: return 'Unknown';
    }
  }

  String _getStressLabel(int level) {
    switch (level) {
      case 1: return '😌 Very Low';
      case 2: return '🙂 Low';
      case 3: return '😐 Medium';
      case 4: return '😟 High';
      case 5: return '😰 Very High';
      default: return 'Unknown';
    }
  }

  Widget _buildMoodChart(List<MoodEntry> entries) {
    // Sort entries by timestamp
    final sortedEntries = entries.toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    if (sortedEntries.length < 2) {
      return const Center(
        child: Text('Add more entries to see your mood trend'),
      );
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < sortedEntries.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('MM/dd').format(sortedEntries[value.toInt()].timestamp),
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          // Mood line
          LineChartBarData(
            spots: List.generate(sortedEntries.length, (index) {
              return FlSpot(index.toDouble(), sortedEntries[index].moodLevel.toDouble());
            }),
            isCurved: true,
            color: Colors.green[700],
            barWidth: 3,
            dotData: FlDotData(show: true),
          ),
          // Stress line
          LineChartBarData(
            spots: List.generate(sortedEntries.length, (index) {
              return FlSpot(index.toDouble(), sortedEntries[index].stressLevel.toDouble());
            }),
            isCurved: true,
            color: Colors.red[400],
            barWidth: 3,
            dotData: FlDotData(show: true),
          ),
        ],
        minX: 0,
        maxX: (sortedEntries.length - 1).toDouble(),
        minY: 1,
        maxY: 5,
      ),
    );
  }
}