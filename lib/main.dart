import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sih_health_monitor_app/screens/auth_wrapper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// The main entry point for the application.
Future<void> main() async {
  // Ensure that the Flutter binding is initialized before calling Supabase.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase with your project URL and anon key.
  // IMPORTANT: Replace these placeholder values with your actual Supabase credentials.
  await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,  );

  // Run the main app widget.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Monitor',
      theme: ThemeData(
        // We use Colors.teal as the primary theme color for a professional, health-tech feel.
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      // The AuthWrapper is the first widget in our UI tree.
      // It will decide which screen to show based on the user's login status.
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}
