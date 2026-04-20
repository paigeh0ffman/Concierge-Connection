/* Login page

Authors: Paige Hoffman

Citations: flutter.dev, Claude.ai
 */

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:concierge_app/pages/doctor/DoctorHomePage.dart';
import 'package:concierge_app/pages/patient/PatientHomePage.dart';

final supabase = Supabase.instance.client;

// ── Create new account ──────────────────────────────
Future<void> signUp(String email, String password) async {
  final response = await supabase.auth.signUp(email: email, password: password);
  final user = response.user;
  if (user != null) {
    await supabase.from('profiles').insert({
      'id': user.id,
      'email': email,
      'role': 'doctor',
    });
  }
}

// ── Sign in to account ──────────────────────────────
Future<void> signIn(String email, String password) async {
  await supabase.auth.signInWithPassword(email: email, password: password);
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  final _formKey   = GlobalKey<FormState>();

  bool _isLogin = true;
  bool _loading  = false;
  bool _obscure  = true;
  String? _errorMsg;

  static const _bg          = Color(0xFF0D0D14);
  static const _card        = Color(0xFF16161F);
  static const _accent      = Color(0xFF00C9A7);
  static const _accentDim   = Color(0xFF007F6B);
  static const _textPrimary = Color(0xFFF0F0F6);
  static const _textMuted   = Color(0xFF6B6B80);
  static const _border      = Color(0xFF2A2A38);

// ── Completely remove elements from UI display ──────────────────────────────
  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

// ── Submit login request ─────────────────────────────────────────
  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() { _loading = true; _errorMsg = null; });
    try {
      if (_isLogin) {
        await signIn(_emailCtrl.text.trim(), _passCtrl.text.trim());
      } else {
        await signUp(_emailCtrl.text.trim(), _passCtrl.text.trim());
      }
      if (mounted) {
        final userId = supabase.auth.currentUser!.id;
        final profile = await supabase
            .from('profiles')
            .select('role')
            .eq('id', userId)
            .single();
        final role = profile['role'] as String;
        if (mounted) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (_) => role == 'doctor'
                ? const DoctorHomePage()
                : const PatientHomePage(),
          ));
        }
      }
    } on AuthException catch (e) {
      setState(() => _errorMsg = e.message);
    } catch (e) {
      setState(() => _errorMsg = 'Unexpected error. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Title ──────────────────────────────
                    Row(
                      children: [
                        Image.asset("assets/temp_logo.png", scale: 10),
                        Text("Welcome to Concierge Connection"),
                      ],
                    ),
                    Text(
                      _isLogin ? 'Sign in' : 'Create account',
                      style: const TextStyle(
                        color: _textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isLogin ? 'Welcome back.' : 'Get started.',
                      style: const TextStyle(color: _textMuted, fontSize: 14),
                    ),
                    const SizedBox(height: 32),

                    // ── Email ──────────────────────────────
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: _textPrimary, fontSize: 14),
                      decoration: _field('Email'),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (!v.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // ── Password ───────────────────────────
                    TextFormField(
                      controller: _passCtrl,
                      obscureText: _obscure,
                      style: const TextStyle(color: _textPrimary, fontSize: 14),
                      decoration: _field('Password').copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility_off_outlined
                                     : Icons.visibility_outlined,
                            color: _textMuted, size: 18,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (v.length < 6) return 'Minimum 6 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // ── Error ──────────────────────────────
                    if (_errorMsg != null) ...[
                      Text(_errorMsg!,
                          style: const TextStyle(
                              color: Color(0xFFFF5C5C), fontSize: 12)),
                      const SizedBox(height: 12),
                    ],

                    // ── Submit ─────────────────────────────
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accent,
                          disabledBackgroundColor: _accentDim,
                          foregroundColor: _bg,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 18, height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Color(0xFF0D0D14)))
                            : Text(_isLogin ? 'Sign in' : 'Create account',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 14)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Toggle ─────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isLogin ? "Don't have an account? "
                                   : 'Already have an account? ',
                          style: const TextStyle(
                              color: _textMuted, fontSize: 13),
                        ),
                        GestureDetector(
                          onTap: () => setState(() {
                            _isLogin = !_isLogin;
                            _errorMsg = null;
                          }),
                          child: Text(
                            _isLogin ? 'Sign up' : 'Sign in',
                            style: const TextStyle(
                                color: _accent,
                                fontSize: 13,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _field(String label) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _textMuted, fontSize: 13),
        filled: true,
        fillColor: _card,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _accent, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFFF5C5C))),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFFF5C5C), width: 1.5)),
        errorStyle: const TextStyle(color: Color(0xFFFF5C5C), fontSize: 11),
      );
}