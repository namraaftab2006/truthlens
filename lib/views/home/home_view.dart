// lib/views/home/home_view.dart
import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final AuthController _authController = AuthController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TruthLens+ Home'),
        actions: [
          IconButton(
            onPressed: () async {
              await _authController.signOut();
              if (context.mounted) Navigator.pushReplacementNamed(context, AppRoutes.splash1);
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: const Center(
        child: Text('Welcome to TruthLens+ (Home)'),
      ),
    );
  }
}
