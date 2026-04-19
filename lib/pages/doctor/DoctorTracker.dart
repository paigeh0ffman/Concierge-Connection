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
  // ── Theme ───────────────────────────────────────────────────
  static const _bg          = Color(0xFF0D0D14);
  static const _card        = Color(0xFF16161F);
  static const _accent      = Color(0xFF00C9A7);
  static const _textPrimary = Color(0xFFF0F0F6);
  static const _textMuted   = Color(0xFF6B6B80);
  static const _border      = Color(0xFF2A2A38);

  // ── Dropdown state ──────────────────────────────────────────
  String _selectedPeriod  = 'Week';
  String? _selectedPatient;
  String? _selectedSymptom;

  final _periods   = ['Week', 'Month', 'Year'];
  final _patients  = ['Alice Johnson', 'Bob Smith', 'Carol White'];
  final _symptoms  = ['Pain', 'Fatigue', 'Nausea', 'Anxiety'];

  // ── Nav ─────────────────────────────────────────────────────
  void _onNavTap(int index) {
    if (index == 0) Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => const DoctorHomePage()));
    if (index == 1) Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => const DoctorChatPage()));
  }

  // ── Helpers ─────────────────────────────────────────────────
  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(
                color: _textMuted, fontSize: 11, letterSpacing: 0.8)),
      );

  Widget _dropdown<T>({
    required String hint,
    required T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _border),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            hint: Text(hint,
                style: const TextStyle(color: _textMuted, fontSize: 13)),
            value: value,
            dropdownColor: _card,
            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                color: _textMuted, size: 18),
            style: const TextStyle(color: _textPrimary, fontSize: 13),
            isExpanded: true,
            onChanged: onChanged,
            items: items
                .map((e) => DropdownMenuItem(value: e, child: Text(e.toString())))
                .toList(),
          ),
        ),
      );

  Widget _placeholder(String label, {double height = 200}) => Container(
        height: height,
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border),
        ),
        child: Center(
          child: Text(label,
              style: const TextStyle(color: _textMuted, fontSize: 13)),
        ),
      );

  // ── Build ────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _card,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: const Text('Tracker',
            style: TextStyle(
                color: _textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _border),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Row 1: Chart + Patient Notes ──────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left — chart + period dropdown
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _dropdown<String>(
                        hint: 'Select Period',
                        value: _selectedPeriod,
                        items: _periods,
                        onChanged: (v) => setState(() => _selectedPeriod = v!),
                      ),
                      const SizedBox(height: 8),
                      _placeholder('Pain severity chart', height: 220),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Right — patient notes + patient dropdown
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _dropdown<String>(
                        hint: 'Select Patient',
                        value: _selectedPatient,
                        items: _patients,
                        onChanged: (v) => setState(() => _selectedPatient = v),
                      ),
                      const SizedBox(height: 8),
                      _placeholder('Patient notes', height: 220),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Row 2: Flags + Calendar ────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left — blank / flags
                Expanded(
                  flex: 5,
                  child: _placeholder('Flags (coming soon)', height: 180),
                ),
                const SizedBox(width: 12),
                // Right — calendar + symptom dropdown
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _dropdown<String>(
                        hint: 'Select Symptom',
                        value: _selectedSymptom,
                        items: _symptoms,
                        onChanged: (v) => setState(() => _selectedSymptom = v),
                      ),
                      const SizedBox(height: 8),
                      _placeholder('Calendar', height: 140),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavBar(
        selectedIndex: 2,
        onTap: _onNavTap,
        isDoctor: true,
      ),
    );
  }
}