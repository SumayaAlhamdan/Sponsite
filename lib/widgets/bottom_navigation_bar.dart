import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sponsite/screens/sponsee_screens/ViewCurrentSponsee.dart';
import 'package:sponsite/screens/sponsee_screens/sponsee_home_screen.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});
  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

User? user = FirebaseAuth.instance.currentUser;
String? sponseeID;
void check() {
  if (user != null) {
    sponseeID = user?.uid;
    print('Sponsee ID: $sponseeID');
  } else {
    print('User is not logged in.');
  }
}
class _BottomNavBarState extends State<BottomNavBar> {
  int currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    check();
  }

  @override
  Widget build(context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(30), topLeft: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(111, 0, 0, 0),
            spreadRadius: 0,
            blurRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        child: NavigationBar(
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          onDestinationSelected: (int index) {
            if (index == 1 && sponseeID != null) {
              //currentPageIndex = index;
              // Only navigate to the calendar page if the user is a sponsee
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const ViewCurrentSponsee()),
              );
            } else {
              setState(() {
                currentPageIndex = index;
              });
            } 
            if (index == 0 && sponseeID != null) {
              //currentPageIndex = index;
              // Only navigate to the home page if the user is a sponsee
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const SponseeHome()),
              );
            } else {
              setState(() {
                currentPageIndex = index;
              });
            } 
            

          },
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          indicatorColor: const Color.fromARGB(134, 214, 214, 215),
          height: 60,
          selectedIndex: currentPageIndex,
          destinations: const <Widget>[
            NavigationDestination(
              icon: Icon(
                Icons.home_rounded,
                size: 40,
                color: Color(0xFF6A62B6),
              ),
              label: '',
            ),
            NavigationDestination(
              selectedIcon: Icon( 
                Icons.calendar_month_rounded,
                size: 40,
                color: Color(0xFF6A62B6), 
              ),
              icon: Icon(
                Icons.calendar_month_rounded,
                size: 40,
                color: Color(0xFF6A62B6),
              ),
              label: '',
            ),
            NavigationDestination(
              selectedIcon: Icon(
                Icons.add_circle_rounded,
                size: 60,
                color: Color(0xFF6A62B6),
              ),
              icon: Icon(
                Icons.add_circle_rounded,
                size: 60,
                color: Color(0xFF6A62B6),
              ),
              label: '',
            ),
            NavigationDestination(
              selectedIcon: Icon(
                Icons.chat_bubble,
                size: 40,
                color: Color(0xFF6A62B6),
              ),
              icon: Icon(
                Icons.chat_bubble_outline,
                size: 40,
                color: Color(0xFF6A62B6),
              ),
              label: '',
            ),
            NavigationDestination(
              selectedIcon: Icon(
                Icons.account_circle,
                size: 40,
                color: Color(0xFF6A62B6),
              ),
              icon: Icon(
                Icons.account_circle,
                size: 40,
                color: Color(0xFF6A62B6),
              ),
              label: '',
            )
          ],
        ),
      ),
    );
  }
}

