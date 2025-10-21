// lib/views/auth/create_account_view.dart
import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/custom_textfield.dart';
import '../home/home_view.dart';

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
  final _authController = AuthController();

  bool _loading = false;

  static const Color paleBeige = Color(0xFFF5F5DC);
  static const Color buttonTeal = Color(0xFF1E5255);

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text;

    try {
      await _authController.createAccount(name, email, password);
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeView()), (route) => false);
      }
    } catch (e) {
      final msg = e is String ? e : 'Account creation failed';
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String? _validateName(String? v) => (v == null || v.trim().isEmpty) ? 'Enter your name' : null;
  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Enter email';
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(v.trim())) return 'Enter a valid email';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Enter password';
    if (v.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: paleBeige,
      appBar: AppBar(
        backgroundColor: paleBeige,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text('Create account', style: TextStyle(color: Colors.black87)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Name
                CustomTextField(
                  controller: _nameCtrl,
                  hintText: 'Full name',
                  validator: _validateName,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),

                // Email
                CustomTextField(
                  controller: _emailCtrl,
                  hintText: 'Email',
                  validator: _validateEmail,
                  textInputType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 14),

                // Password
                CustomTextField(
                  controller: _passCtrl,
                  hintText: 'Password',
                  validator: _validatePassword,
                  isPassword: true,
                ),
                const SizedBox(height: 22),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _createAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonTeal,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Create account', style: TextStyle(fontSize: 16, color: Colors.white)),
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
