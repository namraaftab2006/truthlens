import 'package:flutter/material.dart';
import '../../controllers/splash_controller.dart';

class Splash1View extends StatefulWidget {
  const Splash1View({super.key});

  @override
  State<Splash1View> createState() => _Splash1ViewState();
}

class _Splash1ViewState extends State<Splash1View> {
  final SplashController _controller = SplashController();

  @override
  void initState() {
    super.initState();
    // controller handles timer + navigation; setState isn't required here but kept in view for UI updates if needed
    _controller.startSplashTimer(context, currentSplash: 1, duration: const Duration(seconds: 3));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/splashscreen.jpg"),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}