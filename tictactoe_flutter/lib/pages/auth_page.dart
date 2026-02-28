import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme.dart';
import '../supabase_service.dart';
import '../widgets/toast.dart';

class AuthPage extends StatefulWidget {
  final VoidCallback onBack;
  final void Function(dynamic user) onAuth;

  const AuthPage({super.key, required this.onBack, required this.onAuth});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  String _mode = 'login'; // 'login' | 'register'
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  final _toast = ToastController();

  @override
  void initState() {
    super.initState();
    _toast.bind(setState);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_emailCtrl.text.trim().isEmpty || _passCtrl.text.trim().isEmpty) {
      _toast.show('Please fill all fields');
      return;
    }
    setState(() => _loading = true);
    try {
      if (_mode == 'login') {
        final res = await signIn(_emailCtrl.text.trim(), _passCtrl.text.trim());
        if (res.user != null) widget.onAuth(res.user);
      } else {
        final res = await signUp(_emailCtrl.text.trim(), _passCtrl.text.trim());
        _toast.show('Account created! Check your email to confirm.');
        if (res.user != null) widget.onAuth(res.user);
      }
    } catch (e) {
      final msg =
          e is AuthException
              ? e.message
              : 'Network error. Please check your connection.';
      _toast.show(msg);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BackButton2(onTap: widget.onBack),
                const SizedBox(height: 16),
                Text(
                  _mode == 'login' ? '🔐 Sign In' : '🔐 Create Account',
                  style: AppTextStyles.title,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Online multiplayer requires an account',
                  style: AppTextStyles.subtitle,
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: SingleChildScrollView(
                    child: GlowCard(
                      glowColor: AppColors.primary,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Email field
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Email', style: AppTextStyles.label),
                              const SizedBox(height: 6),
                              _StyledInput(
                                controller: _emailCtrl,
                                hint: 'you@email.com',
                                keyboardType: TextInputType.emailAddress,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Password field
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Password',
                                style: AppTextStyles.label,
                              ),
                              const SizedBox(height: 6),
                              _StyledInput(
                                controller: _passCtrl,
                                hint: '••••••••',
                                obscure: true,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Submit button
                          GlowButton(
                            text:
                                _loading
                                    ? '⏳ Please wait…'
                                    : _mode == 'login'
                                    ? '→ Sign In'
                                    : '→ Create Account',
                            onTap: _loading ? null : _handleSubmit,
                            block: true,
                          ),
                          const SizedBox(height: 12),
                          // Toggle mode
                          TextButton(
                            onPressed:
                                () => setState(() {
                                  _mode =
                                      _mode == 'login' ? 'register' : 'login';
                                }),
                            child: Text(
                              _mode == 'login'
                                  ? "Don't have an account? Sign Up"
                                  : 'Already have an account? Login',
                              style: const TextStyle(
                                color: AppColors.muted,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ToastOverlay(message: _toast.message),
        ],
      ),
    );
  }
}

class _StyledInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final TextInputType? keyboardType;

  const _StyledInput({
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.muted),
        filled: true,
        fillColor: AppColors.surface2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
