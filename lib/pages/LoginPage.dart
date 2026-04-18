/* Login page

Authors: Paige Hoffman

Citations: flutter.dev, Claude.ai
 */

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

// Auth functions
Future<void> signUp(String email, String password) async {
  final response = await supabase.auth.signUp(
    email: email,
    password: password,
  );

  final user = response.user;

  if (user != null) {
    await supabase.from('profiles').insert({
      'id': user.id,
      'email': email,
      'role': 'patient',
    });
  }
}

Future<void> signIn(String email, String password) async {
  await supabase.auth.signInWithPassword(email: email, password: password);
}

Future<void> signOut() async {
  await supabase.auth.signOut();
}

// ─────────────────────────────────────────────
//  LoginPage
// ─────────────────────────────────────────────
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLogin = true;
  bool _loading = false;
  bool _obscure = true;
  String? _errorMsg;

  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _loading = true;
      _errorMsg = null;
    });
    try {
      if (_isLogin) {
        await signIn(_emailCtrl.text.trim(), _passCtrl.text.trim());
      } else {
        await signUp(_emailCtrl.text.trim(), _passCtrl.text.trim());
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isLogin ? 'Signed in successfully!' : 'Account created!',
            ),
            backgroundColor: const Color(0xFF00C9A7),
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

  void _toggle() {
    setState(() {
      _isLogin = !_isLogin;
      _errorMsg = null;
    });
    _animCtrl
      ..reset()
      ..forward();
  }

  // ── Decoration helpers ──────────────────────────────────────
  static const _bg = Color(0xFF0D0D14);
  static const _card = Color(0xFF16161F);
  static const _accent = Color(0xFF00C9A7);
  static const _accentDim = Color(0xFF007F6B);
  static const _textPrimary = Color(0xFFF0F0F6);
  static const _textMuted = Color(0xFF6B6B80);
  static const _border = Color(0xFF2A2A38);

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
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF5C5C)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF5C5C), width: 1.5),
        ),
        errorStyle: const TextStyle(color: Color(0xFFFF5C5C), fontSize: 11),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // ── Background gradient orbs ─────────────────────
          Positioned(
            top: -80,
            right: -60,
            child: _Orb(color: _accent.withOpacity(0.12), size: 260),
          ),
          Positioned(
            bottom: -100,
            left: -80,
            child: _Orb(color: const Color(0xFF7B61FF).withOpacity(0.10), size: 300),
          ),
          // ── Main content ─────────────────────────────────
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
                          // ── Logo / wordmark ────────────────
                          Center(
                            child: Column(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: _accent.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                        color: _accent.withOpacity(0.3)),
                                  ),
                                  child: const Icon(_SupaIcon.bolt,
                                      color: _accent, size: 28),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  _isLogin ? 'Welcome back' : 'Create account',
                                  style: const TextStyle(
                                    color: _textPrimary,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _isLogin
                                      ? 'Sign in to continue'
                                      : 'Get started for free',
                                  style: const TextStyle(
                                      color: _textMuted, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 36),

                          // ── Card ───────────────────────────
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
                                  // Email
                                  TextFormField(
                                    controller: _emailCtrl,
                                    keyboardType: TextInputType.emailAddress,
                                    style: const TextStyle(
                                        color: _textPrimary, fontSize: 14),
                                    decoration:
                                        _inputDecor('Email address', Icons.mail_outline_rounded),
                                    validator: (v) {
                                      if (v == null || v.isEmpty) return 'Required';
                                      if (!v.contains('@')) return 'Enter a valid email';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 14),

                                  // Password
                                  TextFormField(
                                    controller: _passCtrl,
                                    obscureText: _obscure,
                                    style: const TextStyle(
                                        color: _textPrimary, fontSize: 14),
                                    decoration: _inputDecor(
                                            'Password', Icons.lock_outline_rounded)
                                        .copyWith(
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscure
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          color: _textMuted,
                                          size: 18,
                                        ),
                                        onPressed: () =>
                                            setState(() => _obscure = !_obscure),
                                      ),
                                    ),
                                    validator: (v) {
                                      if (v == null || v.isEmpty) return 'Required';
                                      if (v.length < 6)
                                        return 'Minimum 6 characters';
                                      return null;
                                    },
                                  ),

                                  // Forgot password (login only)
                                  if (_isLogin) ...[
                                    const SizedBox(height: 8),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: () {},
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          minimumSize: Size.zero,
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: const Text(
                                          'Forgot password?',
                                          style: TextStyle(
                                              color: _accent, fontSize: 12),
                                        ),
                                      ),
                                    ),
                                  ],

                                  // Error message
                                  if (_errorMsg != null) ...[
                                    const SizedBox(height: 14),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 10),
                                      decoration: BoxDecoration(
                                        color:
                                            const Color(0xFFFF5C5C).withOpacity(0.10),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: const Color(0xFFFF5C5C)
                                                .withOpacity(0.3)),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.error_outline,
                                              color: Color(0xFFFF5C5C), size: 16),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              _errorMsg!,
                                              style: const TextStyle(
                                                  color: Color(0xFFFF5C5C),
                                                  fontSize: 12),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],

                                  const SizedBox(height: 22),

                                  // Submit button
                                  SizedBox(
                                    height: 50,
                                    child: ElevatedButton(
                                      onPressed: _loading ? null : _submit,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _accent,
                                        disabledBackgroundColor:
                                            _accentDim,
                                        foregroundColor: const Color(0xFF0D0D14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: _loading
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Color(0xFF0D0D14),
                                              ),
                                            )
                                          : Text(
                                              _isLogin ? 'Sign in' : 'Create account',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 15,
                                                letterSpacing: 0.2,
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ── Toggle sign-in / sign-up ───────
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _isLogin
                                    ? "Don't have an account? "
                                    : 'Already have an account? ',
                                style: const TextStyle(
                                    color: _textMuted, fontSize: 13),
                              ),
                              GestureDetector(
                                onTap: _toggle,
                                child: Text(
                                  _isLogin ? 'Sign up' : 'Sign in',
                                  style: const TextStyle(
                                    color: _accent,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // ── Powered by Supabase badge ──────
                          Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Powered by ',
                                    style: TextStyle(
                                        color: _textMuted, fontSize: 11)),
                                const Text('Supabase',
                                    style: TextStyle(
                                        color: _accent,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600)),
                              ],
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
    );
  }
}

// ── Orb helper ──────────────────────────────────────────────────
class _Orb extends StatelessWidget {
  const _Orb({required this.color, required this.size});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

// ── Icon shim (uses built-in icons, no extra package needed) ────
class _SupaIcon {
  static const IconData bolt = Icons.bolt_rounded;
}