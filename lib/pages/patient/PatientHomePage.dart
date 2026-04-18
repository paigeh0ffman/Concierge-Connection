/* Patient home overview

Authors: Paige Hoffman

Citations: flutter.dev
 */
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:concierge_app/widgets/NavBar.dart';
import 'package:concierge_app/pages/patient/PatientTracker.dart';
import 'package:concierge_app/pages/patient/PatientChat.dart';

class PatientHomePage extends StatefulWidget {
  const PatientHomePage({super.key});

  @override
  State<PatientHomePage> createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage> {
  void _onNavTap(int index){
    if (index == 1) {
      Navigator.pushReplacement(context,
      MaterialPageRoute(builder: (_) => const PatientChatPage()));
    } else if (index == 2){
      Navigator.pushReplacement(context,
      MaterialPageRoute(builder: (_) => const PatientTrackerPage()));
    };
  }

  @override 
  Widget build(BuildContext context){
    return Scaffold(
      body: Center(child: Text('Patient Home')),
      bottomNavigationBar: NavBar(
        selectedIndex: 0,
        onTap: _onNavTap,
        isDoctor: false,
      ),
    );
  }
}