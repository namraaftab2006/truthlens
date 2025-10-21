// lib/views/auth/login_view.dart
import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/custom_textfield.dart';
import '../../routes/app_routes.dart';
import '../home/home_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _authController = AuthController();
  bool _loading = false;

  static const Color paleBeige = Color(0xFFF5F5DC);
  static const Color buttonTeal = Color(0xFF1E5255);

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text;
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter email and password')));
      return;
    }

    setState(() => _loading = true);
    try {
      await _authController.signIn(email, password);
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeView()), (r) => false);
      }
    } catch (e) {
      final msg = e is String ? e : 'Login failed';
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => _loading = false);
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
        title: const Text('Log in', style: TextStyle(color: Colors.black87)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            children: [
              CustomTextField(
                controller: _emailCtrl,
                hintText: 'Email',
                textInputType: TextInputType.emailAddress,
                isPassword: false,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _passCtrl,
                hintText: 'Password',
                isPassword: true,
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonTeal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Log in', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
