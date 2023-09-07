import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sponsite/widgets/bottom_navigation_bar.dart';

void doSomething() {
  print("hi");
}

class SponseeHome extends StatelessWidget {
  const SponseeHome({super.key});

  @override
  Widget build(context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: const Text("hi sponsee"),
        bottomNavigationBar: const BottomNavBar(),
        floatingActionButton: const FloatingActionButton.large(
            shape: CircleBorder(),
            backgroundColor: Color.fromARGB(255, 106, 33, 134),
            onPressed: doSomething,
            child: Icon(
              Icons.add_circle,
              color: Colors.white,
            )),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        appBar: AppBar(
          actions: [
            IconButton(
              iconSize: 40,
              onPressed: () {
                 FirebaseAuth.instance.signOut();
                // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AuthScreen()));

                // Future<void> signOutUser() async {
                //   try {
                //     await FirebaseAuth.instance.signOut();
                //     // You can navigate to the login or home screen after successful logout
                //     // Navigator.pushReplacement(
                //     //     context,
                //     //     MaterialPageRoute(
                //     //         builder: (context) => const AuthScreen()));
                //   } catch (e) {
                //     print('Error during sign out: $e');
                //   }
                // }

                // signOutUser();
              },
              icon: const Icon(Icons.power_settings_new, color: Colors.black),
            ),
          ],
          backgroundColor: const Color.fromARGB(255, 168, 112, 205),
          title: const Text('Sponsee!'),
        ),
      ),
      theme: ThemeData(
        // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    );
  }
}
