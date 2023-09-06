// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

// import 'package:sponsite/Sponsor.dart';
// import 'package:sponsite/Sponsee.dart';
import 'package:sponsite/screens/auth_screen.dart';
import 'package:sponsite/screens/splash_screen.dart';
import 'package:sponsite/screens/first_choosing_screen.dart';
import 'package:sponsite/screens/sponsee_screens/sponsee_home_screen.dart';
import 'package:sponsite/screens/sponsor_screens/sponsor_home_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:sponsite/widgets/screen_logic.dart';


// DataSnapshot sponsorsSnapshot =DataSnapshot.child("");
//       DataSnapshot sponseesSnapshot = await sponseesRef.get();
//       void getSnapshot() async{
//         DataSnapshot sponsorsSnapshot = await sponsorsRef.get();
//       DataSnapshot sponseesSnapshot = await sponseesRef.get();
//       }

// void _toggleObscured() {
//     setState(() {
//       _obscured = !_obscured;
//     });
//   }
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(title: 'Sponsite', home: ScreenLogic()));
}
//         stream: FirebaseAuth.instance.authStateChanges(),
//         builder: (ctx, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const SplashScreen();
//           }
//            if (snapshot.hasData) {
//             print('1');
//           final user = snapshot.data;

//           if (user != null) {
//             print('2');
//             // Assuming you have a unique identifier for each user, such as 'uid'
//             final userUid = user.uid;
//             checkUserRole(userUid);
//             print(userUid);
//             // Check if the user exists in the sponsors tree
//             // DatabaseReference sponsorsRef = FirebaseDatabase.instance.reference().child('Sponsors').child(userUid);
//             // DatabaseReference sponseesRef = FirebaseDatabase.instance.reference().child('Sponsees').child(userUid);

//             //      DataSnapshot sponsorsSnapshot = await sponsorsRef.get();
//             // DataSnapshot sponseesSnapshot = await sponseesRef.get();
//             print("user role $userRole" );
//             if (userRole == 'Sponsor') {
//               print('4');
//               return const SponsorHome();
//             } else if (userRole == 'Sponsee') {
//               print('5');
//               return const SponseeHome();
//             }
//             // print(user);
//             // print(userUid);
//             // print(sponseesRef);
//             // print(sponsorsRef);

//             // if(sponseesRef != null){
//             //   print("sponsee not null yayyy!!!!!!!");
//             // }
//             //   if(sponsorsRef != null){
//             //   print("sponsor not null yayyy!!!!!!!");
//             // }
//             // if (snapshot.hasData) {
//             //   return const SponseeHome();
//             // }
//           }
//            }
//           return const AuthScreen("Sponsees");
//         }),
//   ));
// }

// Future<void> checkUserRole(userUid) async {
// print('3');

//     DatabaseReference sponsorsRef =
//         FirebaseDatabase.instance.reference().child('Sponsors').child(userUid);
//     DatabaseReference sponseesRef =
//         FirebaseDatabase.instance.reference().child('Sponsees').child(userUid);
    
//     DataSnapshot sponsorsSnapshot = await sponsorsRef.get();
//     DataSnapshot sponseesSnapshot = await sponseesRef.get();
//     print('sponsor value');
//     print(sponsorsSnapshot.value);
//     print('sponsee value');
//     print(sponseesSnapshot.value);
//     if (sponsorsSnapshot.value != null) 
        
//         userRole = 'Sponsor';
     
//      else if (sponseesSnapshot.value != null) 
//        userRole = 'Sponsee';
//    }
    
