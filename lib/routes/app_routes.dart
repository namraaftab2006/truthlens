// lib/routes/app_routes.dart
import 'package:flutter/material.dart';
import '../views/splash/splash1_view.dart';
import '../views/splash/splash2_view.dart';
import '../views/splash/splash3_view.dart';
import '../views/splash/splash4_view.dart';
import '../views/auth/signup_view.dart';
import '../views/auth/login_view.dart';
import '../views/auth/create_account_view.dart';
import '../views/home/home_view.dart';

class AppRoutes {
  static const String splash1 = '/';
  static const String splash2 = '/splash2';
  static const String splash3 = '/splash3';
  static const String splash4 = '/splash4';
  static const String signup = '/signup';
  static const String login = '/login';
  static const String createAccount = '/create-account';
  static const String home = '/home';

  static Map<String, WidgetBuilder> get routes {
    return {
      splash1: (_) => const Splash1View(),
      splash2: (_) => const Splash2View(),
      splash3: (_) => const Splash3View(),
      splash4: (_) => const Splash4View(),
      signup: (_) => const SignupView(),
      login: (_) => const LoginView(),
      createAccount: (_) => const CreateAccountView(),
      home: (_) => const HomeView(),
    };
  }
}
