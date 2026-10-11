import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;

  const AppLogo({super.key, this.size = 72});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        'assets/app_logo.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }
}
