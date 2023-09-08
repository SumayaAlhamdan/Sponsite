import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sponsite'),
      ),
      body: const Center(
        child: CircularProgressIndicator(
          color:  Color.fromARGB(255, 87, 11, 117),
          strokeWidth: 10,
        ),
      ),
    );
  }
}
