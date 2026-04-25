import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/preview_screen.dart';
import 'screens/result_screen.dart';
import 'screens/feedback_screen.dart';
import 'screens/history_screen.dart';

// Entry point of the app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DetectDermApp());
}

class DetectDermApp extends StatelessWidget {
  const DetectDermApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DetectDerm',
      debugShowCheckedModeBanner: false, // Hide debug banner

      // App theme - green color for health app
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32), // Dark green
        ),
        useMaterial3: true,
      ),

      // First screen when app opens
      initialRoute: '/',

      // Simple routes (no arguments needed)
      routes: {
        '/':         (context) => const SplashScreen(),
        '/login':    (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home':     (context) => const HomeScreen(),
        '/history':  (context) => const HistoryScreen(),
      },

      // Dynamic routes (arguments needed)
      onGenerateRoute: (settings) {

        // Preview screen - receives image path
        if (settings.name == '/preview') {
          final imagePath = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => PreviewScreen(imagePath: imagePath),
          );
        }

        // Result screen - receives prediction result
        if (settings.name == '/result') {
          final result = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => ResultScreen(result: result),
          );
        }

        // Feedback screen - receives scan id
        if (settings.name == '/feedback') {
          final scanId = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) => FeedbackScreen(scanId: scanId),
          );
        }

        return null;
      },
    );
  }
}