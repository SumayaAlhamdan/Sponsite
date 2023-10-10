import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sponsite/screens/signIn_screen.dart';
import 'package:sponsite/screens/splash_screen.dart';
import 'package:sponsite/screens/sponsee_screens/ViewCurrentSponsee.dart';
import 'package:sponsite/screens/sponsor_screens/ViewOffersSponsor.dart';
import 'package:sponsite/screens/sponsor_screens/offerDetail.dart';
import 'package:sponsite/widgets/screen_logic.dart';
import 'package:path_provider/path_provider.dart'; // Import path_provider.

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.getInitialMessage();
   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(MaterialApp(
    theme: ThemeData(useMaterial3: true),
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
  final String clickAction = message.data['click_action'];
  final String notif_type = message.data['notif_type'];

  if (clickAction == 'FLUTTER_NOTIFICATION_CLICK' && notif_type == 'status') {
    final String offerId = message.data['offerId'];

    // Use the navigator key to navigate to the specific page.
    navigatorKey.currentState!.push(
      MaterialPageRoute(
        builder: (context) => ViewOffersSponsor(),
      ),
    );
  }
  else if(clickAction == 'FLUTTER_NOTIFICATION_CLICK' && notif_type == 'offer'){
    navigatorKey.currentState!.push(
      MaterialPageRoute(
        builder: (context) => ViewCurrentSponsee(),
      ),
    );
  }
}

