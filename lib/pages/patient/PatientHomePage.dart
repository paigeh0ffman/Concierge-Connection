/* Patient home overview
Authors: Paige Hoffman, Dhwani Parekh
Citations: flutter.dev
*/
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:concierge_app/widgets/NavBar.dart';
import 'package:concierge_app/pages/patient/PatientTracker.dart';
import 'package:concierge_app/pages/patient/PatientChat.dart';
import 'package:concierge_app/services/insights.dart';

class PatientHomePage extends StatefulWidget {
  const PatientHomePage({super.key});
  @override
  State<PatientHomePage> createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage> {
  final supabase = Supabase.instance.client;
  MigraineInsights? _insights;
  bool _loading = true;
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final userId = supabase.auth.currentUser!.id;
      final profile = await supabase
          .from('profiles').select('full_name')
          .eq('id', userId).maybeSingle();
      final logs = await supabase
          .from('logs').select('*')
          .eq('user_id', userId)
          .order('date', ascending: true);
      final insights = analyzeMigraineLogs(
          List<Map<String, dynamic>>.from(logs));
      if (mounted) setState(() {
        _userName = profile?['full_name'] ?? 'there';
        _insights = insights;
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onNavTap(int index) {
    if (index == 1) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const PatientChatPage()));
    } else if (index == 2) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const PatientTrackerPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D14),
      bottomNavigationBar: NavBar(
        selectedIndex: 0, onTap: _onNavTap, isDoctor: false),
      body: _loading
          ? const Center(child: CircularProgressIndicator(
              color: Color(0xFF00C9A7)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hello, $_userName',
                    style: const TextStyle(
                      color: Color(0xFFF0F0F6),
                      fontSize: 24, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(
                    _insights == null || _insights!.totalLogged == 0
                        ? 'Start logging to see your insights'
                        : 'Here\'s your migraine summary',
                    style: const TextStyle(
                      color: Color(0xFF6B6B80), fontSize: 14)),
                  const SizedBox(height: 24),

                  if (_insights != null && _insights!.totalLogged > 0) ...[
                    // Health score
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16161F),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF2A2A38))),
                      child: Column(children: [
                        const Text('Average Health Score',
                          style: TextStyle(
                            color: Color(0xFF6B6B80), fontSize: 13)),
                        const SizedBox(height: 12),
                        Text('${_insights!.avgHealthScore.round()}',
                          style: const TextStyle(
                            color: Color(0xFF00C9A7),
                            fontSize: 56, fontWeight: FontWeight.w700)),
                        Text('Based on ${_insights!.totalLogged} logs',
                          style: const TextStyle(
                            color: Color(0xFF6B6B80), fontSize: 12)),
                      ]),
                    ),
                    const SizedBox(height: 16),

                    // Stat cards
                    Row(
  children: [
    Expanded(child: _statCard('Avg Pain',
      _insights!.avgPain.toStringAsFixed(1), '/10')),
    const SizedBox(width: 10),
    Expanded(child: _statCard('Avg Nausea',
      _insights!.avgNausea.toStringAsFixed(1), '/10')),
  ],
),
const SizedBox(height: 10),
Row(
  children: [
    Expanded(child: _statCard('Aura Episodes',
      '${_insights!.auraCount}', ' times')),
    const SizedBox(width: 10),
    Expanded(child: _statCard('Avg Duration',
      _insights!.avgTimeElapsed.toStringAsFixed(1), 'h')),
  ],
),

                    // Symptom bars
                    const Text('SYMPTOM BREAKDOWN',
                      style: TextStyle(
                        color: Color(0xFF6B6B80), fontSize: 11,
                        fontWeight: FontWeight.w600, letterSpacing: 0.8)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16161F),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF2A2A38))),
                      child: Column(children: [
                        _symptomBar('Pain', _insights!.avgPain, 10),
                        _symptomBar('Nausea', _insights!.avgNausea, 10),
                        _symptomBar('Photosensitivity',
                          _insights!.avgPhotosensitivity, 10),
                      ]),
                    ),
                    const SizedBox(height: 16),

                    // Flags
                    if (_insights!.flags.isNotEmpty) ...[
                      const Text('PATTERNS DETECTED',
                        style: TextStyle(
                          color: Color(0xFF6B6B80), fontSize: 11,
                          fontWeight: FontWeight.w600, letterSpacing: 0.8)),
                      const SizedBox(height: 10),
                      ..._insights!.flags.map((f) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: f.level == 'red'
                              ? const Color(0xFF2A1515)
                              : const Color(0xFF2A2010),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: f.level == 'red'
                                ? const Color(0xFF5A2020)
                                : const Color(0xFF5A4A10))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(f.label, style: TextStyle(
                              color: f.level == 'red'
                                  ? const Color(0xFFFF5C5C)
                                  : const Color(0xFFFFB347),
                              fontSize: 13, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text(f.detail, style: const TextStyle(
                              color: Color(0xFF6B6B80),
                              fontSize: 12, height: 1.4)),
                          ],
                        ),
                      )),
                    ],

                    // Recent notes
                    if (_insights!.recentNotes.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text('RECENT NOTES',
                        style: TextStyle(
                          color: Color(0xFF6B6B80), fontSize: 11,
                          fontWeight: FontWeight.w600, letterSpacing: 0.8)),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF16161F),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF2A2A38))),
                        child: Column(
                          children: _insights!.recentNotes.map((note) {
                            final parts = note.split('  ');
                            final date = parts[0];
                            final text = parts.length > 1 ? parts[1] : note;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(date, style: const TextStyle(
                                    color: Color(0xFF00C9A7),
                                    fontSize: 11, fontWeight: FontWeight.w600)),
                                  const SizedBox(width: 10),
                                  Expanded(child: Text(text,
                                    style: const TextStyle(
                                      color: Color(0xFF6B6B80),
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                      height: 1.4))),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],

                  ] else ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16161F),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF2A2A38))),
                      child: Column(children: [
                        const Text('🧠', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 16),
                        const Text('No logs yet', style: TextStyle(
                          color: Color(0xFFF0F0F6),
                          fontSize: 18, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        const Text(
                          'Start tracking your migraines to see patterns here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF6B6B80),
                            fontSize: 13, height: 1.5)),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => Navigator.pushReplacement(context,
                            MaterialPageRoute(
                              builder: (_) => const PatientTrackerPage())),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00C9A7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                            elevation: 0),
                          child: const Text('Log today\'s migraine',
                            style: TextStyle(
                              color: Color(0xFF0D0D14),
                              fontWeight: FontWeight.w600)),
                        ),
                      ]),
                    ),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _statCard(String label, String value, String suffix) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFF16161F),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFF2A2A38))),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label, style: const TextStyle(
          color: Color(0xFF6B6B80), fontSize: 11,
          fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        RichText(text: TextSpan(children: [
          TextSpan(text: value, style: const TextStyle(
            color: Color(0xFFF0F0F6),
            fontSize: 22, fontWeight: FontWeight.w700)),
          TextSpan(text: suffix, style: const TextStyle(
            color: Color(0xFF6B6B80), fontSize: 12)),
        ])),
      ],
    ),
  );

  Widget _symptomBar(String label, double value, double max) {
    final pct = value / max;
    final color = pct > 0.7
        ? const Color(0xFFFF5C5C)
        : pct > 0.4
            ? const Color(0xFFFFB347)
            : const Color(0xFF00C9A7);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(
              color: Color(0xFF6B6B80), fontSize: 12,
              fontWeight: FontWeight.w500)),
            Text(value.toStringAsFixed(1), style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: const Color(0xFF2A2A38),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ]),
    );
  }
}