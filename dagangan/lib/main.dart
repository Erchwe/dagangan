import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import 'package:supabase_flutter/supabase_flutter.dart';
import 'routes/app_routes.dart';
import 'theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://xcewrxwbprwxsegctoqf.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhjZXdyeHdicHJ3eHNlZ2N0b3FmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQ4ODA5NjgsImV4cCI6MjA1MDQ1Njk2OH0.ZDIUZlY-iuDmdLYmhp847q_wuAOkKrDY0roJ1OxEqEM',
  );

  // Bungkus aplikasi dengan ProviderScope
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final theme = ref.watch(themeDataProvider);
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Dagangan POS',
          theme: theme,
          initialRoute: '/login',
          routes: appRoutes,
        );
      },
    );
  }
}
