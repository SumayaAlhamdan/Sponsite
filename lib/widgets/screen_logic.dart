import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sponsite/screens/admin_screens/admin_home_screen.dart';
import 'package:sponsite/screens/signIn_screen.dart';
import 'package:sponsite/screens/sponsee_screens/sponsee_home_screen.dart';
import 'package:sponsite/screens/sponsor_screens/sponsor_home_screen.dart';
import 'package:sponsite/widgets/admin_bottom_navbar.dart';
import 'package:sponsite/widgets/sponsee_bottom_navbar.dart';
import 'package:sponsite/widgets/sponsor_botton_navbar.dart';

class ScreenLogic {
  ScreenLogic(String userId);

  static Future<Widget> getUserHomeScreen(userUid) async {
    DatabaseReference sponsorsRef =
        FirebaseDatabase.instance.reference().child('Sponsors').child(userUid);
    DatabaseReference sponseesRef =
        FirebaseDatabase.instance.reference().child('Sponsees').child(userUid);
         DatabaseReference adminsRef =
        FirebaseDatabase.instance.reference().child('Admins').child(userUid);

    DataSnapshot sponsorsSnapshot = await sponsorsRef.get();
    DataSnapshot sponseesSnapshot = await sponseesRef.get();
        DataSnapshot adminsSnapshot = await adminsRef.get();

     print(sponsorsSnapshot.value);
     print('bbbbbbbbbbbbbbbbbbb');
      print(sponseesSnapshot.value);
      print('im hereeeeeeeeeeeeeeeeee');
    if (sponsorsSnapshot.value != null) {
     
      return 
      //SponsorHomePage();
       Stack(
        children: [SponsorHomePage(), SponsorBottomNavBar()],
      );
    } else if (sponseesSnapshot.value != null) {
     
      return 
      //const SponseeHome();
      const Stack(
        children: [SponseeHome(), SponseeBottomNavBar()],
      );
    }
    else if(adminsSnapshot.value != null){
      return  Stack(
        children: [AdminPanel(), AdminBottomNavBar()],
      );
    }

    return const SignIn();
  }
}
