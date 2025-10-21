import 'package:flutter/material.dart';
import '../../controllers/splash_controller.dart';
import '../../routes/app_routes.dart';
import '../../widgets/custom_button.dart';

class Splash3View extends StatelessWidget {
  const Splash3View({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = SplashController();

    return Scaffold(
      backgroundColor: const Color(0xFFEFE9C7),
      body: SafeArea(
        child: Column(
          children: [
            // Skip button (top right)
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 10.0, right: 16.0),
                child: GestureDetector(
                  onTap: () {
                    try {
                      controller.navigateToSignup(context);
                    } catch (e) {
                      // fallback if signup route not ready
                      controller.startSplashTimer(context, currentSplash: 2, duration: Duration.zero);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFE9C7),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Text(
                      "Skip",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const Spacer(),

            Image.asset("assets/screen2.jpg", height: 350),
            const SizedBox(height: 30),

            const Text(
              "Junior mode",
              style: TextStyle(
                fontSize: 22,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                "Perfect for the younger peeps.Fresh,tailored,and just-right content.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ),

            const Spacer(),

            // Next button
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 20.0, bottom: 30.0),
                child: CustomButton(
                  text: 'Next',
                  height: 50,
                  width: 140,
                  backgroundColor: const Color(0xFFF5F5DC),
                  onPressed: () {
                    controller.startSplashTimer(
                      context,
                      currentSplash: 3,
                      duration: Duration.zero,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
