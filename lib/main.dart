import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/LoginPage.dart';
import 'theme.dart';

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
      title: 'Concierge Connection',
      debugShowCheckedModeBanner: false,
      theme: lightThemeMode(context),
      darkTheme: darkThemeMode(context),
      themeMode: ThemeMode.light,
      home: LoginPage(),
    );
  }
}