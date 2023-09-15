import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sponsite/widgets/bottom_navigation_bar.dart';
import 'package:sponsite/screens/postEvent.dart';
import 'package:sponsite/widgets/sponsee_bottom_navbar.dart';
User? user = FirebaseAuth.instance.currentUser;
String? sponseeID;
void doSomething() {
  runApp(const MyApp());
  print("hi");
}
void check() {
  if (user != null) {
    sponseeID = user?.uid;
    print('Sponsee ID: $sponseeID');
  } else {
    print('User is not logged in.');
  }
}
class SponseeHome extends StatefulWidget {

  const SponseeHome({super.key});
@override
  _SponseeHomeState createState() => _SponseeHomeState();
}
class _SponseeHomeState extends State<SponseeHome> {

 @override
  void initState() {
    super.initState();
    check();
  }
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
