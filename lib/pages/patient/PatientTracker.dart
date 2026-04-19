/* Patient data view
Authors: Dhwani Parekh, Paige Hoffman
Citations: flutter.dev
*/

import 'package:flutter/material.dart';
import 'package:concierge_app/widgets/NavBar.dart';
import 'package:concierge_app/pages/patient/PatientHomePage.dart';
import 'package:concierge_app/pages/patient/PatientChat.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PatientTrackerPage extends StatefulWidget {
  const PatientTrackerPage({super.key});

  @override
  State<PatientTrackerPage> createState() => _PatientTrackerPageState();
}

class _PatientTrackerPageState extends State<PatientTrackerPage> {

  // ── Migraine fields ───────────────────────────────────────
  int _pain = 0;
  double _timeElapsed = 0;
  bool _aura = false;
  bool _tinnitus = false;
  int _nausea = 0;
  int _photosensitivity = 0;
  final _notesCtrl = TextEditingController();

  bool _saving = false;
  bool _saved  = false;

  static const _bg          = Color(0xFF0D0D14);
  static const _cardColor   = Color(0xFF16161F);
  static const _accent      = Color(0xFF00C9A7);
  static const _textPrimary = Color(0xFFF0F0F6);
  static const _textMuted   = Color(0xFF6B6B80);
  static const _borderColor = Color(0xFF2A2A38);
  static const _red         = Color(0xFFFF5C5C);
  static const _amber       = Color(0xFFFFB347);

  Color _painColor(int v) =>
      v <= 3 ? _accent : v <= 6 ? _amber : _red;

  void _onNavTap(int index) {
    if (index == 0) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const PatientHomePage()));
    } else if (index == 1) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const PatientChatPage()));
    }
  }

  int _calculateHealthScore() {
    final raw = 100
        - (_pain * 6)
        - (_nausea * 3)
        - (_photosensitivity * 3)
        - (_aura ? 10 : 0)
        - (_tinnitus ? 5 : 0);
    return raw.clamp(0, 100);
  }

  Future<void> _save() async {
    setState(() { _saving = true; });
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      await Supabase.instance.client.from('logs').insert({
        'user_id': userId,
        'date': DateTime.now().toIso8601String().split('T')[0],
        'pain': _pain,
        'time_elapsed': _timeElapsed,
        'aura': _aura,
        'tinnitus': _tinnitus,
        'nausea': _nausea,
        'photosensitivity': _photosensitivity,
        'notes': _notesCtrl.text.trim(),
        'health_score': _calculateHealthScore(),
      });
      if (mounted) setState(() { _saved = true; });
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) setState(() { _saved = false; });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not save: $e'),
            backgroundColor: _red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() { _saving = false; });
    }
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  String _todayDate() {
    final now = DateTime.now();
    const months = ['','January','February','March','April','May',
      'June','July','August','September','October','November','December'];
    const days = ['','Monday','Tuesday','Wednesday',
      'Thursday','Friday','Saturday','Sunday'];
    return '${days[now.weekday]}, ${months[now.month]} ${now.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavBar(
        selectedIndex: 2,
        onTap: _onNavTap,
        isDoctor: false,
      ),
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Migraine Tracker',
              style: TextStyle(
                color: _textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(_todayDate(),
              style: const TextStyle(
                color: _textMuted, fontSize: 12)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Pain + Duration ──────────────────────────────
            _sectionLabel('Pain'),
            _buildCard([
              _sliderRow(
                label: 'Pain intensity',
                value: _pain.toDouble(),
                min: 0, max: 10, divisions: 10,
                display: '$_pain / 10',
                color: _painColor(_pain),
                onChanged: (v) =>
                    setState(() => _pain = v.round()),
              ),
              _divider(),
              _sliderRow(
                label: 'Time elapsed (hours)',
                value: _timeElapsed,
                min: 0, max: 72, divisions: 144,
                display: '${_timeElapsed.toStringAsFixed(1)} h',
                color: _accent,
                onChanged: (v) => setState(() =>
                    _timeElapsed =
                        double.parse(v.toStringAsFixed(1))),
              ),
            ]),

            const SizedBox(height: 16),

            // ── Yes/No Symptoms ──────────────────────────────
            _sectionLabel('Symptoms present'),
            _buildCard([
              _toggleRow(
                label: 'Aura',
                subtitle: 'Visual disturbances before migraine',
                value: _aura,
                onChanged: (v) => setState(() => _aura = v),
              ),
              _divider(),
              _toggleRow(
                label: 'Tinnitus',
                subtitle: 'Ringing or buzzing in ears',
                value: _tinnitus,
                onChanged: (v) => setState(() => _tinnitus = v),
              ),
            ]),

            const SizedBox(height: 16),

            // ── Severity ─────────────────────────────────────
            _sectionLabel('Severity'),
            _buildCard([
              _sliderRow(
                label: 'Nausea',
                value: _nausea.toDouble(),
                min: 0, max: 10, divisions: 10,
                display: '$_nausea / 10',
                color: _painColor(_nausea),
                onChanged: (v) =>
                    setState(() => _nausea = v.round()),
              ),
              _divider(),
              _sliderRow(
                label: 'Photosensitivity',
                value: _photosensitivity.toDouble(),
                min: 0, max: 10, divisions: 10,
                display: '$_photosensitivity / 10',
                color: _painColor(_photosensitivity),
                onChanged: (v) => setState(
                    () => _photosensitivity = v.round()),
              ),
            ]),

            const SizedBox(height: 16),

            // ── Notes ────────────────────────────────────────
            _sectionLabel('Notes for your doctor'),
            _buildCard([
              _textField(
                ctrl: _notesCtrl,
                label: 'Additional observations',
                hint:
                    'Triggers, medications taken, anything unusual...',
                icon: Icons.notes_outlined,
                maxLines: 4,
              ),
            ]),

            const SizedBox(height: 24),

            // ── Save ─────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: (_saving || _saved) ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _saved
                      ? const Color(0xFF1A3D2E) : _accent,
                  disabledBackgroundColor: _saved
                      ? const Color(0xFF1A3D2E)
                      : const Color(0xFF007F6B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _saving
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF0D0D14),
                        ),
                      )
                    : Text(
                        _saved ? '✓  Saved!' : "Save today's log",
                        style: TextStyle(
                          color: _saved
                              ? _accent
                              : const Color(0xFF0D0D14),
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(text.toUpperCase(),
      style: const TextStyle(
        color: _textMuted, fontSize: 11,
        fontWeight: FontWeight.w600, letterSpacing: 0.8,
      ),
    ),
  );

  Widget _divider() =>
      const Divider(color: _borderColor, height: 20);

  Widget _buildCard(List<Widget> children) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: _cardColor,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _borderColor),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    ),
  );

  Widget _sliderRow({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String display,
    required Color color,
    required ValueChanged<double> onChanged,
  }) => Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(
            color: _textMuted, fontSize: 13,
            fontWeight: FontWeight.w500)),
          Text(display, style: TextStyle(
            color: color, fontSize: 14,
            fontWeight: FontWeight.w700)),
        ],
      ),
      SliderTheme(
        data: SliderTheme.of(context).copyWith(
          activeTrackColor: color,
          inactiveTrackColor: _borderColor,
          thumbColor: color,
          overlayColor: color.withValues(alpha: 0.15),
          trackHeight: 3,
        ),
        child: Slider(
          value: value, min: min, max: max,
          divisions: divisions, onChanged: onChanged,
        ),
      ),
    ],
  );

  Widget _toggleRow({
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) => Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(
              color: _textPrimary, fontSize: 14,
              fontWeight: FontWeight.w500)),
            Text(subtitle, style: const TextStyle(
              color: _textMuted, fontSize: 12)),
          ],
        ),
      ),
      Switch(
        value: value,
        onChanged: onChanged,
        activeColor: _accent,
      ),
    ],
  );

  Widget _textField({
    required TextEditingController ctrl,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(
        color: _textMuted, fontSize: 12,
        fontWeight: FontWeight.w500)),
      const SizedBox(height: 6),
      TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        style: const TextStyle(color: _textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: _textMuted, fontSize: 13),
          prefixIcon: Icon(icon, color: _textMuted, size: 18),
          filled: true,
          fillColor: const Color(0xFF1E1E2A),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: _accent, width: 1.5),
          ),
        ),
      ),
    ],
  );
}