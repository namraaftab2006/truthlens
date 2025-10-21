import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'routes/app_routes.dart';
import 'views/splash/splash1_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const NewsApp());
}

class NewsApp extends StatelessWidget {
  const NewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TruthLens+',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.blue,
      ),
      // Use named routes from AppRoutes for easier MVC navigation
      routes: AppRoutes.routes,
      initialRoute: AppRoutes.splash1,
      // fallback in case route not found
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (_) => const Splash1View(),
      ),
    );
  }
}
