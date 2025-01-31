import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:meet/firebase_options.dart';
import 'package:meet/login.dart';
import 'package:meet/voice_assistant.dart';
import 'package:meet/screens/calendar_screen.dart'; // Import the calendar screen
import 'package:meet/screens/front_screen.dart'; // Import the FrontScreen widget
import 'package:meet/screens/notes_screen.dart';
import 'package:meet/screens/translator_screen.dart';
import 'package:meet/screens/ai_speech.dart'; // Import the AISpeechPage widget
import 'package:meet/screens/schedule_meeting_screen.dart';
import 'package:meet/models/meeting.dart';
import 'package:meet/screens/home_screen.dart'; // Import HomeScreen
import 'package:meet/screens/network_screen.dart'; // Import NetworkScreen
import 'package:meet/screens/settings_screen.dart'; // Import SettingsScreen

// Splash Screen
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    await Future.delayed(Duration(seconds: 3)); // Splash screen duration
    Navigator.pushReplacementNamed(context, '/front_screen'); // Navigate to front screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 11, 88, 176), // Entire background is now blue
      body: Center(
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 11, 88, 176), // Container background is also blue
            borderRadius: BorderRadius.circular(15),
          ),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Plan',
                  style: TextStyle(
                    fontSize: 65,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // "Plan" in white
                    letterSpacing: 2,
                  ),
                ),
                TextSpan(
                  text: 'it',
                  style: TextStyle(
                    fontSize: 65,
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // "it" in black
                    letterSpacing: 2,
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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meet App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Set the initial route to the splash screen
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(), // Splash screen route
        '/front_screen': (context) => FrontScreen(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => HomeScreen(), // Home screen route
        '/voice': (context) => VoiceAssistantScreen(),
        '/calendar': (context) => CalendarScreen(), // Calendar screen route
        '/audio': (context) => VoiceAssistantScreen(),
        '/insights': (context) => NotesScreen(),
        '/translator': (context) => TranslatorScreen(),
        '/ai-speech': (context) => AISpeechPage(),
        '/schedule-meeting': (context) => ScheduleMeetingScreen(),
        '/network': (context) => NetworkScreen(), // Network screen route
        '/settings': (context) => SettingsScreen(), // Settings screen route
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to Flutter Demo!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/voice');
              },
              child: Text('Go to Voice Assistant'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/calendar'); // Add this button
              },
              child: Text('Go to Calendar'),
            ),
          ],
        ),
      ),
    );
  }
}