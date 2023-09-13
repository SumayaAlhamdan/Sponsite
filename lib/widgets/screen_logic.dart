import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sponsite/screens/signIn_screen.dart';
import 'package:sponsite/screens/sponsee_screens/sponsee_home_screen.dart';
import 'package:sponsite/screens/sponsor_screens/sponsor_home_screen.dart';
import 'package:sponsite/widgets/sponsee_bottom_navbar.dart';
import 'package:sponsite/widgets/sponsor_botton_navbar.dart';

class ScreenLogic {
  static Future<Widget> getUserHomeScreen(userUid) async {
    DatabaseReference sponsorsRef =
        FirebaseDatabase.instance.reference().child('Sponsors').child(userUid);
    DatabaseReference sponseesRef =
        FirebaseDatabase.instance.reference().child('Sponsees').child(userUid);

    DataSnapshot sponsorsSnapshot = await sponsorsRef.get();
    DataSnapshot sponseesSnapshot = await sponseesRef.get();

    if (sponsorsSnapshot.value != null) {
      return 
      //SponsorHomePage();
      Stack(
        children: [SponsorHomePage(), const SponsorBottomNavBar()],
      );
    } else if (sponseesSnapshot.value != null) {
      return 
      //const SponseeHome();
      Stack(
        children: [SponseeHome(), SponseeBottomNavBar()],
      );
    }

    return const SignIn();
  }
}
