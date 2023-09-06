import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sponsite/widgets/bottom_navigation_bar.dart';


void doSomething() {
  print("hi");
}
class SponsorHome extends StatelessWidget{
 const SponsorHome({super.key});

  @override
  Widget build(context){
    return  MaterialApp(
      home: MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body:const Text("hi sponsee"),
        bottomNavigationBar: const BottomNavBar(),
        floatingActionButton: const FloatingActionButton.large(
            shape: CircleBorder(),
            backgroundColor:Color.fromARGB(255, 106, 33, 134),
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
            },
            icon:const Icon(
              Icons.power_settings_new,
              color: Colors.black
            ),
          ),
        ],
          backgroundColor: const Color.fromARGB(255, 168, 112, 205),
          title: Text('Sponsee!'),
        ),
      ),
      theme: ThemeData(
        // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      )
    );
    
  }

}