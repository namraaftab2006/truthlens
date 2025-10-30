import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/news_controller.dart';
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
    return ChangeNotifierProvider(
      create: (_) => NewsController(),
      child: MaterialApp(
        title: 'TruthLens+',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: Constants.backgroundColor,
          appBarTheme: const AppBarTheme(
            backgroundColor: Constants.accentColor,
            foregroundColor: Colors.white,
          ),
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: Constants.accentColor,
            secondary: Constants.likeColor,
          ),
        ),
        routes: AppRoutes.routes,
        initialRoute: AppRoutes.splash1,
        onUnknownRoute: (settings) => MaterialPageRoute(
          builder: (_) => const Splash1View(),
        ),
      ),
    );
  }
}
