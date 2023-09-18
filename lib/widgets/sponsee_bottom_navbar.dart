import 'package:flutter/material.dart';
import 'package:sponsite/ViewCurrentSponsee.dart';
import 'package:sponsite/screens/sponsee_screens/sponsee_chat_screen.dart';
import 'package:sponsite/screens/postEvent.dart';
import 'package:sponsite/screens/sponsee_screens/sponsee_profile_screen.dart';
import 'package:sponsite/screens/sponsee_screens/sponsee_home_screen.dart';

class SponseeBottomNavBar extends StatefulWidget {
  const SponseeBottomNavBar({Key? key}) : super(key: key);

  @override
  State<SponseeBottomNavBar> createState() => _SponseeBottomNavBarState();
}

class _SponseeBottomNavBarState extends State<SponseeBottomNavBar> {
  int currentPageIndex = 0;

  final List<Widget> _widgetOptions = [
    const SponseeHome(),
    const ViewCurrentSponsee(),
    const MyApp(),
    const SponseeChat(),
    const SponseeProfile()
  ];



  void _onItemTap(int index) {
    setState(() {
      currentPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: _widgetOptions.elementAt(currentPageIndex),
      bottomNavigationBar: BottomNavigationBar(
        //backgroundColor: Color.fromARGB(255, 51, 45, 81),
        selectedItemColor:  Colors.white,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home_rounded,
              size: 40,
              color: Colors.white,
            ),
            label: 'Home',
            backgroundColor: Color.fromARGB(255, 51, 45, 81),
            activeIcon:  Icon(
              Icons.home_rounded,
              size: 40,
              color: Color.fromARGB(255, 91, 79, 158),
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.calendar_month_rounded,
              size: 40,
              color: Colors.white,
            ),
            label: 'Events',
            activeIcon:  Icon(
              Icons.calendar_month_rounded,
              size: 40,
              color: Color.fromARGB(255, 91, 79, 158),
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.add_circle_rounded,
              size: 60,
              color: Colors.white,
            ),
            label: 'Post',
             activeIcon:  Icon(
              Icons.add_circle_rounded,
              size: 40,
              color: Color.fromARGB(255, 91, 79, 158),
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.chat_bubble,
              size: 40,
              color: Colors.white,
            ),
            label: 'Chat',
            activeIcon:  Icon(
              Icons.chat_bubble,
              size: 40,
              color: Color.fromARGB(255, 91, 79, 158),
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.account_circle,
              size: 40,
              color: Colors.white,
              
            ),
            label: 'Account',
            activeIcon:  Icon(
              Icons.account_circle,
              size: 40,
              color: Color.fromARGB(255, 91, 79, 158),
            ),
          )
        ],
        currentIndex: currentPageIndex,
        
        onTap: _onItemTap,
      ),
    );
  }
}
