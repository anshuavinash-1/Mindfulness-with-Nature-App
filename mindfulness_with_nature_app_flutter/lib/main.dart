import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'firebase_options.dart';
import 'pages/splash_screen.dart';
import 'service/notification_service.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  tz.initializeTimeZones();
  final String timeZone = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZone));

  final notificationService = NotificationService();
  await notificationService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<NotificationService>.value(
          value: notificationService,
        ),
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: const MindfulnessApp(),
    ),
  );
}

class MindfulnessApp extends StatelessWidget {
  const MindfulnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mindfulness with Nature',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xffdde3c2),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF374834),
          foregroundColor: Colors.white,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
