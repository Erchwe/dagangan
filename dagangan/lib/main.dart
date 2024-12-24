import 'package:flutter/material.dart';
import 'package:dagangan/core/supabase_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dagangan/screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await SupabaseConfig.init();
  
  runApp(const DaganganApp());
}

class DaganganApp extends StatelessWidget {
  const DaganganApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dagangan App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
      ),
      home: const LoginScreen(),
    );
  }
}
