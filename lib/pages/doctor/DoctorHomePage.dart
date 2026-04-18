/* Practitioner home overview

Authors: Paige Hoffman

Citations: flutter.dev
 */
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:concierge_app/widgets/NavBar.dart';
import 'package:concierge_app/pages/doctor/DoctorTracker.dart';
import 'package:concierge_app/pages/doctor/DoctorChat.dart';

class DoctorHomePage extends StatefulWidget {
  const DoctorHomePage({super.key});

  @override
  State<DoctorHomePage> createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends State<DoctorHomePage> {
  void _onNavTap(int index){
    if (index == 1) {
      Navigator.pushReplacement(context,
      MaterialPageRoute(builder: (_) => const DoctorChatPage()));
    } else if (index == 2){
      Navigator.pushReplacement(context,
      MaterialPageRoute(builder: (_) => const DoctorTrackerPage()));
    };
  }

  @override 
  Widget build(BuildContext context){
    return Scaffold(
      body: Center(child: Text('Doctor Home')),
      bottomNavigationBar: NavBar(
        selectedIndex: 0,
        onTap: _onNavTap,
        isDoctor: true,
      ),
    );
  }
}