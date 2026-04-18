/* Practitioner messenger view

Authors: Paige Hoffman

Citations: flutter.dev
 */
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:concierge_app/widgets/NavBar.dart';
import 'package:concierge_app/pages/doctor/DoctorHomePage.dart';
import 'package:concierge_app/pages/doctor/DoctorTracker.dart';

class DoctorChatPage extends StatefulWidget {
  const DoctorChatPage({super.key});

  @override
  State<DoctorChatPage> createState() => _DoctorChatPageState();
}

class _DoctorChatPageState extends State<DoctorChatPage> {
  void _onNavTap(int index){
    if (index == 0) {
      Navigator.pushReplacement(context,
      MaterialPageRoute(builder: (_) => const DoctorHomePage()));
    } else if (index == 2){
      Navigator.pushReplacement(context,
      MaterialPageRoute(builder: (_) => const DoctorTrackerPage()));
    };
  }

  @override 
  Widget build(BuildContext context){
    return Scaffold(
      body: Center(child: Text('Doctor Chat')),
      bottomNavigationBar: NavBar(
        selectedIndex: 1,
        onTap: _onNavTap,
        isDoctor: true,
      ),
    );
  }
}