
import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  final double width;
  final double height;

  const LogoWidget({super.key, this.width = 200, this.height = 200});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/logo.jpg',
      width: width,
      height: height,
      fit: BoxFit.contain,
    );
  }
}
