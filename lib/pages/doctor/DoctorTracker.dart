/* Practitioner data view by patient

Authors: Paige Hoffman

Citations: flutter.dev
 */
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:concierge_app/widgets/NavBar.dart';
import 'package:concierge_app/pages/doctor/DoctorHomePage.dart';
import 'package:concierge_app/pages/doctor/DoctorChat.dart';

class DoctorTrackerPage extends StatefulWidget {
  const DoctorTrackerPage({super.key});

  @override
  State<DoctorTrackerPage> createState() => _DoctorTrackerPageState();
}

class _DoctorTrackerPageState extends State<DoctorTrackerPage> {
  void _onNavTap(int index){
    if (index == 1) {
      Navigator.pushReplacement(context,
      MaterialPageRoute(builder: (_) => const DoctorChatPage()));
    } else if (index == 0){
      Navigator.pushReplacement(context,
      MaterialPageRoute(builder: (_) => const DoctorHomePage()));
    };
  }

  @override 
  Widget build(BuildContext context){
    return Scaffold(
      body: Center(child: Text('Doctor Tracker')),
      bottomNavigationBar: NavBar(
        selectedIndex: 2,
        onTap: _onNavTap,
        isDoctor: true,
      ),
    );
  }
}