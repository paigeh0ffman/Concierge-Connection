/* Patient data view

Authors: Paige Hoffman, Dhwani Parekh

Citations: flutter.dev
 */


import 'package:flutter/material.dart';

class PatientTrackerPage extends StatefulWidget {
  const PatientTrackerPage({super.key});

  @override
  State<PatientTrackerPage> createState() => _PatientTrackerPageState();
}

class _PatientTrackerPageState extends State<PatientTrackerPage> {

  int _pain = 2;
  int _fatigue = 2;
  int _mood = 7;
  double _sleep = 7.5;
  double _fever = 98.2;

  final _dietCtrl     = TextEditingController();
  final _exerciseCtrl = TextEditingController();
  final _notesCtrl    = TextEditingController();

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

  Color _painColor(int v)    => v <= 3 ? _accent : v <= 6 ? _amber : _red;
  Color _moodColor(int v)    => v >= 7 ? _accent : v >= 4 ? _amber : _red;
  Color _feverColor(double v) => v < 99 ? _accent : v < 100.4 ? _amber : _red;

  Future<void> _save() async {
    setState(() { _saving = true; });
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) setState(() { _saving = false; _saved = true; });
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) setState(() { _saved = false; });
  }

  @override
  void dispose() {
    _dietCtrl.dispose();
    _exerciseCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  String _todayDate() {
    final now = DateTime.now();
    const months = ['','January','February','March','April','May','June',
      'July','August','September','October','November','December'];
    const days = ['','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
    return '${days[now.weekday]}, ${months[now.month]} ${now.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Today's Check-in",
              style: TextStyle(
                color: _textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              _todayDate(),
              style: const TextStyle(color: _textMuted, fontSize: 12),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            _sectionLabel('How are you feeling?'),
            _buildCard([
              _sliderRow(
                label: 'Pain level',
                value: _pain.toDouble(),
                min: 0, max: 10, divisions: 10,
                display: '$_pain / 10',
                color: _painColor(_pain),
                onChanged: (v) => setState(() => _pain = v.round()),
              ),
              _divider(),
              _sliderRow(
                label: 'Fatigue level',
                value: _fatigue.toDouble(),
                min: 0, max: 10, divisions: 10,
                display: '$_fatigue / 10',
                color: _painColor(_fatigue),
                onChanged: (v) => setState(() => _fatigue = v.round()),
              ),
              _divider(),
              _sliderRow(
                label: 'Mood',
                value: _mood.toDouble(),
                min: 0, max: 10, divisions: 10,
                display: '$_mood / 10',
                color: _moodColor(_mood),
                onChanged: (v) => setState(() => _mood = v.round()),
              ),
              _divider(),
              _sliderRow(
                label: 'Sleep last night',
                value: _sleep,
                min: 0, max: 12, divisions: 24,
                display: '${_sleep.toStringAsFixed(1)} h',
                color: _accent,
                onChanged: (v) => setState(() => _sleep = v),
              ),
              _divider(),
              _sliderRow(
                label: 'Fever (°F)',
                value: _fever,
                min: 96, max: 104, divisions: 80,
                display: '${_fever.toStringAsFixed(1)} °F',
                color: _feverColor(_fever),
                onChanged: (v) => setState(
                  () => _fever = double.parse(v.toStringAsFixed(1))),
              ),
            ]),

            const SizedBox(height: 16),
            _sectionLabel('Lifestyle'),
            _buildCard([
              _textField(
                ctrl: _dietCtrl,
                label: 'Diet today',
                hint: 'e.g. Rice, soup, vegetables...',
                icon: Icons.restaurant_outlined,
              ),
              const SizedBox(height: 12),
              _textField(
                ctrl: _exerciseCtrl,
                label: 'Exercise',
                hint: 'e.g. 30min walk, yoga, none...',
                icon: Icons.directions_run_outlined,
              ),
            ]),

            const SizedBox(height: 16),
            _sectionLabel('Notes for your doctor'),
            _buildCard([
              _textField(
                ctrl: _notesCtrl,
                label: 'Any symptoms or observations',
                hint: 'How are you feeling overall?',
                icon: Icons.notes_outlined,
                maxLines: 4,
              ),
            ]),

            const SizedBox(height: 24),

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
                          color: _saved ? _accent : const Color(0xFF0D0D14),
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
    child: Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: _textMuted, fontSize: 11,
        fontWeight: FontWeight.w600, letterSpacing: 0.8,
      ),
    ),
  );

  Widget _divider() => const Divider(color: _borderColor, height: 16);

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
            color: _textMuted, fontSize: 13, fontWeight: FontWeight.w500)),
          Text(display, style: TextStyle(
            color: color, fontSize: 14, fontWeight: FontWeight.w700)),
        ],
      ),
      SliderTheme(
        data: SliderTheme.of(context).copyWith(
          activeTrackColor: color,
          inactiveTrackColor: _borderColor,
          thumbColor: color,
          overlayColor: color.withOpacity(0.15),
          trackHeight: 3,
        ),
        child: Slider(
          value: value, min: min, max: max,
          divisions: divisions, onChanged: onChanged,
        ),
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
        color: _textMuted, fontSize: 12, fontWeight: FontWeight.w500)),
      const SizedBox(height: 6),
      TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        style: const TextStyle(color: _textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: _textMuted, fontSize: 13),
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
            borderSide: const BorderSide(color: _accent, width: 1.5),
          ),
        ),
      ),
    ],
  );
}