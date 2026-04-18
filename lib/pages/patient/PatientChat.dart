/* Patient-side messenger view

Authors: Paige Hoffman

Citations: flutter.dev
 */
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:concierge_app/widgets/NavBar.dart';
import 'package:concierge_app/pages/patient/PatientTracker.dart';
import 'package:concierge_app/pages/patient/PatientHomePage.dart';

class PatientChatPage extends StatefulWidget {
  const PatientChatPage({super.key});

  @override
  State<PatientChatPage> createState() => _PatientChatPageState();
}

class _PatientChatPageState extends State<PatientChatPage> {
  void _onNavTap(int index){
    if (index == 0) {
      Navigator.pushReplacement(context,
      MaterialPageRoute(builder: (_) => const PatientHomePage()));
    } else if (index == 2){
      Navigator.pushReplacement(context,
      MaterialPageRoute(builder: (_) => const PatientTrackerPage()));
    };
  }

  @override 
  Widget build(BuildContext context){
    return Scaffold(
      body: Center(child: Text('Patient Chat')),
      bottomNavigationBar: NavBar(
        selectedIndex: 1,
        onTap: _onNavTap,
        isDoctor: false,
      ),
    );
  }
}