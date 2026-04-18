import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/LoginPage.dart';
import 'pages/patient/patient_tracker.dart'; //Debug

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://qzdulhuwlddqrewczhum.supabase.co',
    anonKey: 'sb_publishable_W-ev4KxvcXhNMoGK6GcSqw_YoozaTu2',
  );

  runApp(MyApp());
  }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00C9A7)),
        useMaterial3: true,
      ),
      home: LoginPage(),
    );
  }
}