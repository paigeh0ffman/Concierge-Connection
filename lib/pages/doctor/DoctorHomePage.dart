/* Practitioner home overview w/ patient registration

Authors: Paige Hoffman

Citations: flutter.dev, Claude.ai
 */

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:concierge_app/pages/doctor/DoctorTracker.dart';
import 'package:concierge_app/pages/doctor/DoctorChat.dart';
import 'package:concierge_app/widgets/NavBar.dart';

final supabase = Supabase.instance.client;

Future<void> registerPatient(String email, String password) async {
  final response = await supabase.functions.invoke(
    'create-patient',
    body: {'email': email, 'password': password},
  );
  if (response.status != 200) throw Exception('Registration failed');
}

class DoctorHomePage extends StatefulWidget {
  const DoctorHomePage({super.key});

  @override
  State<DoctorHomePage> createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends State<DoctorHomePage>
    with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  final _formKey   = GlobalKey<FormState>();

  bool _loading = false;
  bool _obscure = true;
  String? _errorMsg;

  late final AnimationController _animCtrl;
  late final Animation<double>   _fadeAnim;
  late final Animation<Offset>   _slideAnim;

  static const _bg          = Color(0xFF0D0D14);
  static const _card        = Color(0xFF16161F);
  static const _accent      = Color(0xFF00C9A7);
  static const _accentDim   = Color(0xFF007F6B);
  static const _textPrimary = Color(0xFFF0F0F6);
  static const _textMuted   = Color(0xFF6B6B80);
  static const _border      = Color(0xFF2A2A38);

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim  = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
            begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    if (index == 1) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const DoctorChatPage()));
    } else if (index == 2) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const DoctorTrackerPage()));
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() { _loading = true; _errorMsg = null; });
    try {
      await registerPatient(_emailCtrl.text.trim(), _passCtrl.text.trim());
      if (mounted) {
        _emailCtrl.clear();
        _passCtrl.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Patient registered successfully!'),
            backgroundColor: Color(0xFF00C9A7),
          ),
        );
      }
    } on AuthException catch (e) {
      setState(() => _errorMsg = e.message);
    } catch (e) {
      setState(() => _errorMsg = 'Unexpected error. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _inputDecor(String label, IconData icon) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _textMuted, fontSize: 13),
        prefixIcon: Icon(icon, color: _textMuted, size: 18),
        filled: true,
        fillColor: const Color(0xFF1E1E2A),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _accent, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFFF5C5C))),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFFF5C5C), width: 1.5)),
        errorStyle: const TextStyle(color: Color(0xFFFF5C5C), fontSize: 11),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          Positioned(
            top: -80, right: -60,
            child: _Orb(color: _accent.withOpacity(0.12), size: 260),
          ),
          Positioned(
            bottom: -100, left: -80,
            child: _Orb(color: const Color(0xFF7B61FF).withOpacity(0.10), size: 300),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: Column(
                              children: [
                                Container(
                                  width: 56, height: 56,
                                  decoration: BoxDecoration(
                                    color: _accent.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: _accent.withOpacity(0.3)),
                                  ),
                                  child: const Icon(Icons.person_add_rounded,
                                      color: _accent, size: 28),
                                ),
                                const SizedBox(height: 20),
                                const Text('Register Patient',
                                    style: TextStyle(
                                      color: _textPrimary,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.5,
                                    )),
                                const SizedBox(height: 6),
                                const Text('Create a new patient account',
                                    style: TextStyle(color: _textMuted, fontSize: 14)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 36),
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: _card,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: _border),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                )
                              ],
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  TextFormField(
                                    controller: _emailCtrl,
                                    keyboardType: TextInputType.emailAddress,
                                    style: const TextStyle(
                                        color: _textPrimary, fontSize: 14),
                                    decoration: _inputDecor(
                                        'Patient email', Icons.mail_outline_rounded),
                                    validator: (v) {
                                      if (v == null || v.isEmpty) return 'Required';
                                      if (!v.contains('@')) return 'Enter a valid email';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 14),
                                  TextFormField(
                                    controller: _passCtrl,
                                    obscureText: _obscure,
                                    style: const TextStyle(
                                        color: _textPrimary, fontSize: 14),
                                    decoration: _inputDecor(
                                            'Temporary password', Icons.lock_outline_rounded)
                                        .copyWith(
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscure
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          color: _textMuted, size: 18,
                                        ),
                                        onPressed: () =>
                                            setState(() => _obscure = !_obscure),
                                      ),
                                    ),
                                    validator: (v) {
                                      if (v == null || v.isEmpty) return 'Required';
                                      if (v.length < 6) return 'Minimum 6 characters';
                                      return null;
                                    },
                                  ),
                                  if (_errorMsg != null) ...[
                                    const SizedBox(height: 14),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFF5C5C).withOpacity(0.10),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: const Color(0xFFFF5C5C).withOpacity(0.3)),
                                      ),
                                      child: Row(children: [
                                        const Icon(Icons.error_outline,
                                            color: Color(0xFFFF5C5C), size: 16),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(_errorMsg!,
                                              style: const TextStyle(
                                                  color: Color(0xFFFF5C5C), fontSize: 12)),
                                        ),
                                      ]),
                                    ),
                                  ],
                                  const SizedBox(height: 22),
                                  SizedBox(
                                    height: 50,
                                    child: ElevatedButton(
                                      onPressed: _loading ? null : _submit,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _accent,
                                        disabledBackgroundColor: _accentDim,
                                        foregroundColor: const Color(0xFF0D0D14),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12)),
                                        elevation: 0,
                                      ),
                                      child: _loading
                                          ? const SizedBox(
                                              width: 20, height: 20,
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Color(0xFF0D0D14)))
                                          : const Text('Register Patient',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 15,
                                                letterSpacing: 0.2,
                                              )),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavBar(
        selectedIndex: 0,
        onTap: _onNavTap,
        isDoctor: true,
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({required this.color, required this.size});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}