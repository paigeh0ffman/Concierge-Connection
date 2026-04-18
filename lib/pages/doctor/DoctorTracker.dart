/* Practitioner data view by patient

Authors: Paige Hoffman

Citations: flutter.dev
 */
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DoctorTrackerPage extends StatelessWidget {
  const DoctorTrackerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Doctor Tracker')),
    );
  }
}