import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:sponsite/screens/signIn_screen.dart';
import 'package:sponsite/screens/splash_screen.dart';
import 'package:sponsite/screens/sponsee_screens/ViewCurrentSponsee.dart';
import 'package:sponsite/screens/sponsee_screens/sponsee_chat_screen.dart';
import 'package:sponsite/screens/sponsor_screens/ViewOffersSponsor.dart';
import 'package:sponsite/widgets/screen_logic.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.getInitialMessage();
  FirebaseMessaging.onBackgroundMessage(
      await _firebaseMessagingBackgroundHandler);
  runApp(MaterialApp(
        theme: ThemeData(useMaterial3: true, 
        fontFamily: 'Urbanist',),

//     theme:ThemeData(
//         // Set your desired font family or other theme configurations
//         primaryColor: Color.fromARGB(255, 91, 79, 158),
//        fontFamily: 'Urbanist',
//   textTheme: TextTheme(
//     // Define text field's specific style
//     subtitle1: TextStyle(color: Colors.purple), // Change text color to purple
//   ),
//   inputDecorationTheme: InputDecorationTheme(
//     // Set decoration properties for text fields
//     focusedBorder: OutlineInputBorder(
//       borderSide: BorderSide(color: Colors.purple), // Change border color when focused
//     ),
//     enabledBorder: OutlineInputBorder(
//       borderSide: BorderSide(color: Colors.purple.withOpacity(0.5)), // Change border color
//     ),
//     labelStyle: TextStyle(color: Colors.purple), // Change label color to purple
//   ),
// ),

        // Add other theme configurations here as needed
    
      
    navigatorKey: navigatorKey,
    home: StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        } else if (snapshot.hasData) {
          final user = snapshot.data!;
          return FutureBuilder<Widget>(
            future: ScreenLogic.getUserHomeScreen(user.uid),
            builder: (context, homeScreenSnapshot) {
              if (homeScreenSnapshot.connectionState ==
                  ConnectionState.waiting) {
                // While waiting for the home screen determination, show a loading indicator.
                return const SplashScreen();
              } else if (homeScreenSnapshot.hasData) {
                // Return the determined home screen widget.

                return homeScreenSnapshot.data!;
              } else {
                // If no data is available, show the AuthScreen.
                return const SignIn();
                // AuthScreen();
              }
            },
          );
        } else {
          return const SignIn();
          //AuthScreen();
        }
      },
    ),
  ));
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  final String clickAction = message.data['click_action'];
  final String notif_type = message.data['notif_type'];

  if (clickAction == 'FLUTTER_NOTIFICATION_CLICK') {
    if (notif_type == 'status') {
      
      
      
      navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (context) => ViewOffersSponsor(),
        ),
      );
    } else if (notif_type == 'offer') {
     //_SponseeBottomNavBarState.changeTap(3);//SponseeBottomNavBar
      navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (context) => ViewCurrentSponsee(),
        ),
      );
    }
    } else if (notif_type == 'chat') {
     //_SponseeBottomNavBarState.changeTap(3);//SponseeBottomNavBar

      navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (context) => SponseeChat(),
        ),
      );
    }
  }

