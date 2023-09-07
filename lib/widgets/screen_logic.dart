import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sponsite/screens/auth_screen.dart';
import 'package:sponsite/screens/sponsee_screens/sponsee_home_screen.dart';
import 'package:sponsite/screens/sponsor_screens/sponsor_home_screen.dart';

class ScreenLogic {
  static Future<Widget> getUserHomeScreen(userUid) async {
    //final user = FirebaseAuth.instance.currentUser;
    print('here1');

    // if (user != null) {
    //   final userUid = user.uid;
    print('here2');
    print(userUid);
    DatabaseReference sponsorsRef =
        FirebaseDatabase.instance.reference().child('Sponsors').child(userUid);
    DatabaseReference sponseesRef =
        FirebaseDatabase.instance.reference().child('Sponsees').child(userUid);

    DataSnapshot sponsorsSnapshot = await sponsorsRef.get();
    DataSnapshot sponseesSnapshot = await sponseesRef.get();
     print(sponseesSnapshot.value);
     print(sponsorsSnapshot.value);
    if (sponsorsSnapshot.value != null) {
       print('--');
      return const SponsorHome();
    } else if (sponseesSnapshot.value != null) {
       print('==');
      return const SponseeHome();
    }
     print('/////');
    return const AuthScreen();
  }
}


