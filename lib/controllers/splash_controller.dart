import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../routes/app_routes.dart';
import '../../views/home/home_view.dart';

class SplashController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void startSplashTimer(
      BuildContext context, {
        required int currentSplash,
        Duration duration = const Duration(seconds: 3),
      }) {
    Timer(duration, () async {
      if (!context.mounted) return;

      final user = _auth.currentUser;

      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeView()),
        );
        return;
      }

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

  void navigateToSignup(BuildContext context) {
    Navigator.pushReplacementNamed(context, AppRoutes.signup);
  }

  Future<void> signOut(BuildContext context) async {
    await _auth.signOut();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(
        context, AppRoutes.splash1, (route) => false);
  }
}
