import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://xcewrxwbprwxsegctoqf.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhjZXdyeHdicHJ3eHNlZ2N0b3FmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQ4ODA5NjgsImV4cCI6MjA1MDQ1Njk2OH0.ZDIUZlY-iuDmdLYmhp847q_wuAOkKrDY0roJ1OxEqEM',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dagangan POS',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF6A11CB),
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white
          ),
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
        ),
      ),
      initialRoute: '/login',
      routes: appRoutes,
    );
  }
}
