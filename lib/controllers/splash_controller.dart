import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../routes/app_routes.dart';
import '../../views/home/home_view.dart';

class SplashController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Starts a splash timer and navigates to the next screen accordingly.
  void startSplashTimer(
      BuildContext context, {
        required int currentSplash,
        Duration duration = const Duration(seconds: 3),
      }) {
    Timer(duration, () async {
      if (!context.mounted) return;

      // ✅ Check if user is already logged in
      final user = _auth.currentUser;

      if (user != null) {
        // 🔹 If logged in, directly go to HomeView (skip splash flow)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeView()),
        );
        return;
      }

      // 🔹 Continue normal splash flow if not logged in
      switch (currentSplash) {
        case 1:
          Navigator.pushReplacementNamed(context, AppRoutes.splash2);
          break;
        case 2:
          Navigator.pushReplacementNamed(context, AppRoutes.splash3);
          break;
        case 3:
          Navigator.pushReplacementNamed(context, AppRoutes.splash4);
          break;
        case 4:
          Navigator.pushReplacementNamed(context, AppRoutes.signup);
          break;
        default:
          Navigator.pushReplacementNamed(context, AppRoutes.signup);
      }
    });
  }

  /// Direct navigation helper (optional, not required)
  void navigateToSignup(BuildContext context) {
    Navigator.pushReplacementNamed(context, AppRoutes.signup);
  }

  /// Optional method to log out user (can be used later)
  Future<void> signOut(BuildContext context) async {
    await _auth.signOut();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(
        context, AppRoutes.splash1, (route) => false);
  }
}
