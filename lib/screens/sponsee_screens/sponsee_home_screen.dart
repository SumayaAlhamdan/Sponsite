import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sponsite/screens/postEvent.dart';
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
void setUpPushNotifications() async {
final fcm = FirebaseMessaging.instance ;
  await fcm.requestPermission();
  fcm
     .subscribeToTopic(user!.uid);
}
 @override
  void initState() {
    super.initState();
    check();
    setUpPushNotifications();
    //FirebaseMessaging.onMessage.listen(_onMessageHandler);
    //FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
   //Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // print("Foreground Message: ${message.data}");
//}

//Future<void> _onMessageHandler(RemoteMessage message) async {
  //print("Backgorund Message: ${message.data}");
//}
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
