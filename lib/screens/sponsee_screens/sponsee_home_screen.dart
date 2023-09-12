import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sponsite/widgets/bottom_navigation_bar.dart';
import 'package:sponsite/screens/postEvent.dart';
import 'package:sponsite/widgets/sponsee_bottom_navbar.dart';

void doSomething() {
  runApp(const MyApp());
  print("hi");
}

class SponseeHome extends StatelessWidget {
  const SponseeHome({super.key});

  @override
  Widget build(context) {
    return MaterialApp(
      home:const  Scaffold(
        body:  Center(child: Text("Sponsee Home Page")),
         //bottomNavigationBar:  SponseeBottomNavBar(),
      ),
      theme: ThemeData(
        useMaterial3: true,
      ),
    );
  }
}
