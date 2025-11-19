// lib/main.dart
import 'package:flutter/material.dart';

void main() {
  runApp(MindfulnessApp());
}

class MindfulnessApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mindfulness with Nature',
      theme: ThemeData(
        // Color Scheme
        primaryColor: Color(0xFF87A96B), // Sage Green
        primaryColorLight: Color(0xFFB8C9A9), // Soft Sage
        primaryColorDark: Color(0xFF2E5E3A), // Deep Forest
        scaffoldBackgroundColor: Color(0xFFF8F4E9), // Pale Sand
        canvasColor: Colors.white,
        
        // App Bar Theme
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF36454F), // Charcoal
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Color(0xFF87A96B)),
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF36454F),
          ),
        ),
        
        // Text Theme
        textTheme: TextTheme(
          displayLarge: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Color(0xFF36454F),
          ),
          displayMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Color(0xFF36454F),
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xFF708090), // Slate
            height: 1.5,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF708090),
          ),
          titleMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF36454F),
          ),
        ),
        
        // Button Theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF87A96B), // Sage Green
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
        ),
        
        // Card Theme
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: EdgeInsets.zero,
        ),
        
        // Input Decoration Theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
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
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F4E9), // Pale Sand
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good Morning',
                        style: TextStyle(
                          color: Color(0xFF87A96B),
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Find Your Peace',
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                    ],
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFB8C9A9), // Soft Sage
                    ),
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 32),
              
              // Welcome Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(24),
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
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Begin Your Journey',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E5E3A), // Deep Forest
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Take a moment to breathe and connect with nature. Start with a short meditation or explore nature sounds.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MeditationScreen()),
                        );
                      },
                      child: Text('Start Meditating'),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 24),
              
              // Quick Actions
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.6,
                children: [
                  _buildActionCard(
                    icon: Icons.self_improvement,
                    label: 'Meditate',
                    color: Color(0xFF87A96B), // Sage Green
                  ),
                  _buildActionCard(
                    icon: Icons.forest,
                    label: 'Nature',
                    color: Color(0xFFA2C4D9), // Soft Sky Blue
                  ),
                  _buildActionCard(
                    icon: Icons.book,
                    label: 'Journal',
                    color: Color(0xFFE6D7B8), // Sand
                  ),
                  _buildActionCard(
                    icon: Icons.bar_chart,
                    label: 'Progress',
                    color: Color(0xFFB8C9A9), // Soft Sage
                  ),
                ],
              ),
              
              SizedBox(height: 32),
              
              // Recent Sessions
              Text(
                'Recent Sessions',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildSessionItem('Morning Calm', '10 min', 'Today'),
                      Divider(height: 24, color: Color(0xFFD8E4D3)),
                      _buildSessionItem('Forest Walk', '15 min', 'Yesterday'),
                      Divider(height: 24, color: Color(0xFFD8E4D3)),
                      _buildSessionItem('Breathing Exercise', '5 min', '2 days ago'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: 0,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF87A96B),
          unselectedItemColor: Color(0xFFB8B8B8),
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.self_improvement_outlined),
              activeIcon: Icon(Icons.self_improvement),
              label: 'Meditate',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.eco_outlined),
              activeIcon: Icon(Icons.eco),
              label: 'Nature',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'Progress',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Card(
      child: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
          foregroundColor: color,
          padding: EdgeInsets.all(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionItem(String title, String duration, String date) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Color(0xFFD1E5F0), // Pale Sky Blue
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.self_improvement, color: Color(0xFFA2C4D9), size: 20),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(duration),
      trailing: Text(
        date,
        style: TextStyle(
          fontSize: 12,
          color: Color(0xFFB8B8B8),
        ),
      ),
    );
  }
}

class MeditationScreen extends StatelessWidget {
  const MeditationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F4E9),
      appBar: AppBar(
        title: Text('Meditation'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Meditation Player
            Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Circular Progress
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFD1E5F0),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: 0.7,
                            strokeWidth: 4,
                            color: Color(0xFF87A96B),
                            backgroundColor: Color(0xFFB8C9A9),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '10:00',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'minutes',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFB8B8B8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    
                    // Controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.skip_previous, size: 28),
                          color: Color(0xFF87A96B),
                        ),
                        SizedBox(width: 16),
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF87A96B),
                          ),
                          child: IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.play_arrow, size: 32, color: Colors.white),
                          ),
                        ),
                        SizedBox(width: 16),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.skip_next, size: 28),
                          color: Color(0xFF87A96B),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 24),
            
            // Meditation Sessions
            Text(
              'Meditation Sessions',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            SizedBox(height: 16),
            
            Column(
              children: [
                _buildMeditationSession(
                  'Morning Calm',
                  '10 min',
                  'Start your day with peace',
                  Color(0xFFA2C4D9),
                ),
                SizedBox(height: 12),
                _buildMeditationSession(
                  'Forest Walk',
                  '15 min',
                  'Connect with nature sounds',
                  Color(0xFF87A96B),
                ),
                SizedBox(height: 12),
                _buildMeditationSession(
                  'Breathing Space',
                  '5 min',
                  'Quick breathing exercise',
                  Color(0xFFE6D7B8),
                ),
                SizedBox(height: 12),
                _buildMeditationSession(
                  'Deep Relaxation',
                  '20 min',
                  'Full body relaxation',
                  Color(0xFFB8C9A9),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeditationSession(
    String title,
    String duration,
    String description,
    Color color,
  ) {
    return Card(
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.self_improvement, color: Colors.white, size: 24),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(description),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Color(0xFFD8E4D3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            duration,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF87A96B),
            ),
          ),
        ),
        onTap: () {},
      ),
    );
  }
}