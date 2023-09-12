import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        backgroundColor: Color.fromARGB(255, 51, 45, 81),
        body:  Center(
          child: CircularProgressIndicator(
            color:  Color.fromARGB(255, 255, 255, 255),
            strokeWidth: 10,
          ),
        ),
     
    );
  }
}
