// lib/controllers/splash_controller.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

/// Controller for splash screens.
/// Handles timed navigation between splash screens and signup view.
/// Each splash screen remains responsible for its own UI and animation.
class SplashController {
  /// Starts a timer and navigates to the next splash based on [currentSplash].
  void startSplashTimer(
      BuildContext context, {
        required int currentSplash,
        Duration duration = const Duration(seconds: 3),
      }) {
    Timer(duration, () {
      if (!context.mounted) return;

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

  /// Navigate instantly to signup screen (for skip buttons or manual use)
  void navigateToSignup(BuildContext context) {
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.signup);
  }

  /// Generic navigation method to move to any named route.
  void navigateTo(BuildContext context, String routeName) {
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, routeName);
  }
}
