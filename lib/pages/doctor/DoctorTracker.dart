/* Practitioner data view by patient
Authors: Paige Hoffman, Dhwani Parekh
Citations: flutter.dev
*/
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:concierge_app/widgets/NavBar.dart';
import 'package:concierge_app/pages/doctor/DoctorHomePage.dart';
import 'package:concierge_app/pages/doctor/DoctorChat.dart';
import 'package:concierge_app/services/insights.dart';

class DoctorTrackerPage extends StatefulWidget {
  const DoctorTrackerPage({super.key});
  @override
  State<DoctorTrackerPage> createState() => _DoctorTrackerPageState();
}

class _DoctorTrackerPageState extends State<DoctorTrackerPage> {
  static const _bg          = Color(0xFF0D0D14);
  static const _card        = Color(0xFF16161F);
  static const _accent      = Color(0xFF00C9A7);
  static const _textPrimary = Color(0xFFF0F0F6);
  static const _textMuted   = Color(0xFF6B6B80);
  static const _border      = Color(0xFF2A2A38);
  static const _red         = Color(0xFFFF5C5C);
  static const _amber       = Color(0xFFFFB347);

  List<Map<String, dynamic>> _patientList = [];
  String? _selectedPatientId;
  String? _selectedPatientName;
  List<Map<String, dynamic>> _patientLogs = [];
  MigraineInsights? _insights;
  bool _loadingPatients = true;
  bool _loadingLogs = false;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    try {
      final doctorId =
          Supabase.instance.client.auth.currentUser!.id;
      final response = await Supabase.instance.client
          .from('doctor_patients')
          .select('patient_id, profiles(id, full_name)')
          .eq('doctor_id', doctorId);
      if (mounted) setState(() {
        _patientList = (response as List).map((r) => {
          'id': r['profiles']['id'] as String,
          'name': r['profiles']['full_name'] ?? 'Unknown',
        }).toList();
        _loadingPatients = false;
      });
    } catch (e) {
      if (mounted) setState(() => _loadingPatients = false);
    }
  }

  Future<void> _loadPatientLogs(String patientId) async {
    setState(() => _loadingLogs = true);
    try {
      final logs = await Supabase.instance.client
          .from('logs')
          .select('*')
          .eq('user_id', patientId)
          .order('date', ascending: true);
      final logList = List<Map<String, dynamic>>.from(logs);
      if (mounted) setState(() {
        _patientLogs = logList;
        _insights = analyzeMigraineLogs(logList);
        _loadingLogs = false;
      });
    } catch (e) {
      if (mounted) setState(() => _loadingLogs = false);
    }
  }

  void _onNavTap(int index) {
    if (index == 0) Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => const DoctorHomePage()));
    if (index == 1) Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => const DoctorChatPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _card,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Patient Tracker',
            style: TextStyle(
                color: _textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w600)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _border)),
      ),
      bottomNavigationBar: NavBar(
          selectedIndex: 2, onTap: _onNavTap, isDoctor: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Patient selector ─────────────────────────────
            _loadingPatients
                ? const Center(child: CircularProgressIndicator(
                    color: Color(0xFF00C9A7)))
                : Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                        color: _card,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _border)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        hint: const Text('Select a patient',
                            style: TextStyle(
                                color: _textMuted, fontSize: 13)),
                        value: _selectedPatientId,
                        dropdownColor: _card,
                        isExpanded: true,
                        icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: _textMuted,
                            size: 18),
                        style: const TextStyle(
                            color: _textPrimary, fontSize: 13),
                        onChanged: (id) {
                          final patient = _patientList
                              .firstWhere((p) => p['id'] == id);
                          setState(() {
                            _selectedPatientId = id;
                            _selectedPatientName = patient['name'];
                          });
                          _loadPatientLogs(id!);
                        },
                        items: _patientList
                            .map((p) => DropdownMenuItem<String>(
                                  value: p['id'] as String,
                                  child: Text(p['name'] as String),
                                ))
                            .toList(),
                      ),
                    ),
                  ),

            const SizedBox(height: 16),

            // ── No patient selected ──────────────────────────
            if (_selectedPatientId == null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _border)),
                child: Column(children: const [
                  Text('👨‍⚕️', style: TextStyle(fontSize: 48)),
                  SizedBox(height: 16),
                  Text('Select a patient',
                      style: TextStyle(
                          color: _textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  Text(
                      'Choose a patient above to view their migraine insights.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: _textMuted,
                          fontSize: 13,
                          height: 1.5)),
                ]),
              ),

            // ── Loading ──────────────────────────────────────
            ] else if (_loadingLogs) ...[
              const SizedBox(height: 60),
              const Center(child: CircularProgressIndicator(
                  color: Color(0xFF00C9A7))),

            // ── No logs ──────────────────────────────────────
            ] else if (_patientLogs.isEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _border)),
                child: Text(
                    '${_selectedPatientName ?? "This patient"} has no logs yet.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: _textMuted, fontSize: 14)),
              ),

            // ── Dashboard ────────────────────────────────────
            ] else ...[

              // Patient name header
              Text(_selectedPatientName ?? '',
                  style: const TextStyle(
                      color: _textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('${_insights!.totalLogged} logs recorded',
                  style: const TextStyle(
                      color: _textMuted, fontSize: 13)),
              const SizedBox(height: 16),

              // Health score
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _border)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _bigStat(
                        'Health Score',
                        '${_insights!.avgHealthScore.round()}',
                        _insights!.avgHealthScore < 40
                            ? _red
                            : _insights!.avgHealthScore < 70
                                ? _amber
                                : _accent),
                    _bigStat('Total Logs',
                        '${_insights!.totalLogged}', _textPrimary),
                    _bigStat('Aura Episodes',
                        '${_insights!.auraCount}', _textPrimary),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Stat row
              Row(children: [
                Expanded(child: _statCard('Avg Pain',
                    _insights!.avgPain.toStringAsFixed(1), '/10')),
                const SizedBox(width: 8),
                Expanded(child: _statCard('Avg Nausea',
                    _insights!.avgNausea.toStringAsFixed(1), '/10')),
                const SizedBox(width: 8),
                Expanded(child: _statCard('Avg Duration',
                    _insights!.avgTimeElapsed.toStringAsFixed(1), 'h')),
              ]),
              const SizedBox(height: 16),

              // Flags
              _label('PATTERNS DETECTED'),
              const SizedBox(height: 8),
              if (_insights!.flags.isEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: const Color(0xFF0F2A1F),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: const Color(0xFF1A5C3A))),
                  child: const Row(children: [
                    Icon(Icons.check_circle_outline,
                        color: Color(0xFF00C9A7), size: 16),
                    SizedBox(width: 8),
                    Text('No patterns of concern detected.',
                        style: TextStyle(
                            color: Color(0xFF00C9A7), fontSize: 13)),
                  ]),
                ),
              ] else ...[
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
                          Row(children: [
                            Container(
                                width: 8,
                                height: 8,
                                margin:
                                    const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                    color: f.level == 'red'
                                        ? _red
                                        : _amber,
                                    shape: BoxShape.circle)),
                            Text(f.label,
                                style: TextStyle(
                                    color: f.level == 'red'
                                        ? _red
                                        : _amber,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                          ]),
                          const SizedBox(height: 4),
                          Text(f.detail,
                              style: const TextStyle(
                                  color: _textMuted,
                                  fontSize: 12,
                                  height: 1.4)),
                        ],
                      ),
                    )),
              ],
              const SizedBox(height: 16),

              // Notes
              if (_insights!.recentNotes.isNotEmpty) ...[
                _label('PATIENT NOTES'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: _card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _border)),
                  child: Column(
                    children: _insights!.recentNotes.map((note) {
                      final parts = note.split('  ');
                      final date = parts[0];
                      final text =
                          parts.length > 1 ? parts[1] : note;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(date,
                                style: const TextStyle(
                                    color: _accent,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(width: 10),
                            Expanded(
                                child: Text(text,
                                    style: const TextStyle(
                                        color: _textMuted,
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                        height: 1.4))),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Flag button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _showFlagDialog,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: _red,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                      padding:
                          const EdgeInsets.symmetric(vertical: 14)),
                  child: const Text('Flag for appointment',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ],
        ),
      ),
    );
  }

  void _showFlagDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _card,
        title: const Text('Flag patient',
            style: TextStyle(color: _textPrimary)),
        content: TextField(
          controller: ctrl,
          style: const TextStyle(color: _textPrimary),
          decoration: const InputDecoration(
              hintText: 'Message to patient...',
              hintStyle: TextStyle(color: _textMuted)),
          maxLines: 3,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel',
                  style: TextStyle(color: _textMuted))),
          ElevatedButton(
            onPressed: () async {
              if (_selectedPatientId != null &&
                  ctrl.text.trim().isNotEmpty) {
                await Supabase.instance.client
                    .from('flags')
                    .insert({
                  'doctor_id': Supabase
                      .instance.client.auth.currentUser!.id,
                  'patient_id': _selectedPatientId,
                  'message': ctrl.text.trim(),
                });
                if (mounted) Navigator.pop(context);
                if (mounted)
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Patient flagged for appointment'),
                          backgroundColor: Color(0xFF00C9A7)));
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: _red, elevation: 0),
            child: const Text('Send flag',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(
          color: _textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8));

  Widget _bigStat(String label, String value, Color color) => Column(
        children: [
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 32,
                  fontWeight: FontWeight.w700)),
          Text(label,
              style: const TextStyle(color: _textMuted, fontSize: 11)),
        ],
      );

  Widget _statCard(String label, String value, String suffix) =>
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _border)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    color: _textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            RichText(
                text: TextSpan(children: [
              TextSpan(
                  text: value,
                  style: const TextStyle(
                      color: _textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700)),
              TextSpan(
                  text: suffix,
                  style: const TextStyle(
                      color: _textMuted, fontSize: 11)),
            ])),
          ],
        ),
      );
}