import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sponsite/screens/sponsor_screens/sponsor_profile_screen.dart';
import 'package:sponsite/screens/signIn_screen.dart';
import 'package:sponsite/screens/signUp_screen.dart';
import 'package:sponsite/screens/splash_screen.dart';
import 'package:sponsite/screens/sponsor_screens/sponsor_home_screen.dart';
import 'package:sponsite/widgets/screen_logic.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    theme: ThemeData(useMaterial3: true),
   
     home: 
    StreamBuilder(
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
