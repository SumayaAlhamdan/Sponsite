import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sponsite/screens/auth_screen.dart';
import 'package:sponsite/screens/splash_screen.dart';
import 'package:sponsite/screens/sponsee_screens/sponsee_home_screen.dart';
import 'package:sponsite/screens/sponsor_screens/sponsor_home_screen.dart';

class ScreenLogic extends StatefulWidget {
  @override
  _ScreenLogicState createState() => _ScreenLogicState();
}

class _ScreenLogicState extends State<ScreenLogic> {
  String? userRole;

  @override
  // void initState() {
  //   super.initState();
  //   checkUserRole();
  // }

  Future<void> checkUserRole(userUid) async {
    DatabaseReference sponsorsRef =
        FirebaseDatabase.instance.reference().child('Sponsors').child(userUid);
    DatabaseReference sponseesRef =
        FirebaseDatabase.instance.reference().child('Sponsees').child(userUid);

    DataSnapshot sponsorsSnapshot = await sponsorsRef.get();
    DataSnapshot sponseesSnapshot = await sponseesRef.get();
    print('sponsor value');
    print(sponsorsSnapshot.value);
    print('sponsee value');
    print(sponseesSnapshot.value);
    if (sponsorsSnapshot.value != null)
      setState(() {
        userRole = 'Sponsor';
      });
    else if (sponseesSnapshot.value != null)
      setState(() {
        userRole = 'Sponsee';
      });
  }

  @override
  Widget build(BuildContext context) {
   return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, snapshot) {
          // if (snapshot.connectionState == ConnectionState.waiting) {
          //   return const SplashScreen();
          // }
          if (snapshot.hasData) {
            final user = snapshot.data;
            final userUid = user!.uid;

            checkUserRole(userUid);

            if (userRole == 'Sponsor') {
              return const SponsorHome();
            } else if (userRole == 'Sponsee') {
              return const SponseeHome();
            }
          }
          return const AuthScreen();
        });

    // if (userRole == null) {
    //   return const SplashScreen();
    // } else if (userRole == 'Sponsor') {
    //   return const SponsorHome();
    // } else if (userRole == 'Sponsee') {
    //   return const SponseeHome();
    // } else {
    //   return const AuthScreen('Sponsees');
    // }
  }
}
