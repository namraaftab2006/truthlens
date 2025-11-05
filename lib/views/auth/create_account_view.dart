// lib/views/auth/create_account_view.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/custom_textfield.dart';
import '../home/home_view.dart';
import 'dart:math';

class CreateAccountView extends StatefulWidget {
  const CreateAccountView({super.key});

  @override
  State<CreateAccountView> createState() => _CreateAccountViewState();
}

class _CreateAccountViewState extends State<CreateAccountView> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _captchaCtrl = TextEditingController();
  final _authController = AuthController();

  bool _loading = false;

  static const Color paleBeige = Color(0xFFEFE9C7);
  static const Color buttonTeal = Color(0xFF1E5255);

  int _num1 = 0;
  int _num2 = 0;
  int _expectedAnswer = 0;

  @override
  void initState() {
    super.initState();
    _generateCaptcha();
  }

  void _generateCaptcha() {
    final random = Random();
    _num1 = random.nextInt(9) + 1;
    _num2 = random.nextInt(9) + 1;
    _expectedAnswer = _num1 + _num2;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _captchaCtrl.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final user = await _authController.createAccount(
        _nameCtrl.text.trim(),
        _emailCtrl.text.trim(),
        _passCtrl.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome, ${user.displayName ?? 'User'}!'),
          backgroundColor: Colors.green,
        ),
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomeView()),
                (route) => false,
          );
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_handleFirebaseError(e)),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String? _validateName(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Enter your name' : null;

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Enter email';
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(v.trim())) return 'Enter a valid email';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Enter password';
    if (v.length < 6) return 'Password must be at least 6 characters';
    if (!RegExp(r'(?=.*[A-Z])').hasMatch(v)) {
      return 'Password must contain an uppercase letter';
    }
    if (!RegExp(r'(?=.*[a-z])').hasMatch(v)) {
      return 'Password must contain a lowercase letter';
    }
    if (!RegExp(r'(?=.*[0-9])').hasMatch(v)) {
      return 'Password must contain a number';
    }
    if (!RegExp(r'(?=.*[!@#\$&*~])').hasMatch(v)) {
      return 'Password must contain a special character (!@#\$&*~)';
    }
    return null;
  }

  String? _validateCaptcha(String? v) {
    if (v == null || v.isEmpty) return 'Enter captcha answer';
    if (int.tryParse(v) != _expectedAnswer) return 'Captcha incorrect';
    return null;
  }

  String _handleFirebaseError(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'This email is already registered.';
        case 'invalid-email':
          return 'Invalid email format.';
        case 'weak-password':
          return 'Password is too weak.';
        default:
          return e.message ?? 'Account creation failed.';
      }
    } else {
      return e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: paleBeige,
      appBar: AppBar(
        backgroundColor: paleBeige,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text('Create account',
            style: TextStyle(color: Colors.black87)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                CustomTextField(
                  controller: _nameCtrl,
                  hintText: 'Full name',
                  validator: _validateName,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _emailCtrl,
                  hintText: 'Email',
                  validator: _validateEmail,
                  textInputType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _passCtrl,
                  hintText: 'Password',
                  validator: _validatePassword,
                  isPassword: true,
                ),
                const SizedBox(height: 14),
                Text('Solve the CAPTCHA: $_num1 + $_num2 = ?',
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _captchaCtrl,
                  hintText: 'Enter answer',
                  validator: _validateCaptcha,
                  textInputType: TextInputType.number,
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _createAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonTeal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      'Create account',
                      style:
                      TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
