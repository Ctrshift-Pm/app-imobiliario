import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  final double height;
  const LogoWidget({this.height = 100, super.key});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: height / 2,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset(
          'assets/images/logo.png',
        ),
      ),
    );
  }
}