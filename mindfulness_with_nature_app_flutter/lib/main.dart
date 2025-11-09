import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/auth_service.dart';
import 'services/mood_service.dart';
import 'services/places_service.dart';
import 'services/notification_service.dart';
import 'pages/login_page.dart';
import 'pages/dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  
  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(
          create: (_) => MoodService(prefs),
        ),
        ChangeNotifierProvider(
          create: (_) => PlacesService(prefs),
        ),
        ChangeNotifierProvider(create: (_) => NotificationService()),
      ],
      child: MaterialApp(
        title: 'Mindfulness with Nature',
        theme: ThemeData(
          primarySwatch: Colors.green,
          useMaterial3: true,
        ),
        home: Consumer<AuthService>(
          builder: (context, auth, _) {
            return auth.isLoggedIn ? const DashboardPage() : const LoginPage();
          },
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}