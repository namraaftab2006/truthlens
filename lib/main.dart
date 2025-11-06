import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/news_controller.dart';
import 'controllers/theme_controller.dart';
import 'routes/app_routes.dart';
import 'views/splash/splash1_view.dart';
import 'utils/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const NewsApp());
}

class NewsApp extends StatelessWidget {
  const NewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NewsController()),
        ChangeNotifierProvider(create: (_) => ThemeController()),
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeController, child) {
          return MaterialApp(
            title: 'TruthLens+',
            debugShowCheckedModeBanner: false,
            theme: themeController.currentTheme,
            darkTheme: themeController.currentTheme, // unified handling
            themeMode: ThemeMode.light, // avoid system override
            routes: AppRoutes.routes,
            initialRoute: AppRoutes.splash1,
            onUnknownRoute: (settings) =>
                MaterialPageRoute(builder: (_) => const Splash1View()),
          );
        },
      ),
    );
  }
}
