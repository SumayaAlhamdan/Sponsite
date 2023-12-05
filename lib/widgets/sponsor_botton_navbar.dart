import 'package:flutter/material.dart';
import 'package:sponsite/screens/chat_service.dart';
import 'package:sponsite/screens/sponsor_screens/ViewOffersSponsor.dart';
import 'package:sponsite/screens/sponsor_screens/sponsor_chat_screen.dart';
import 'package:sponsite/screens/sponsor_screens/sponsor_home_screen.dart';
import 'package:sponsite/screens/sponsor_screens/sponsor_profile_screen.dart';

class SponsorBottomNavBar extends StatefulWidget {
  const SponsorBottomNavBar({Key? key}) : super(key: key);

  @override
  State<SponsorBottomNavBar> createState() => _SponseeBottomNavBarState();
}

class _SponseeBottomNavBarState extends State<SponsorBottomNavBar> {
  int currentPageIndex = 0;

  final List<Widget> _widgetOptions = [
      SponsorHomePage(),  
    const ViewOffersSponsor(),
    const SponsorChat(),    
     SponsorProfile()
  ];



  void _onItemTap(int index) {
    setState(() {
      currentPageIndex = index;
         if (index == 3) {
        // Chat tab index
        ChatService.notification_ = false; // Set to false when Chat tab is tapped
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: _widgetOptions.elementAt(currentPageIndex),
       bottomNavigationBar: Stack(
        children: [
 BottomNavigationBar(
        backgroundColor: Color.fromARGB(255, 51, 45, 81),
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
              Icons.handshake_outlined,
              size: 40, 
              color: Colors.white,
            ),
            label: 'Offers',  
            activeIcon:  Icon(
              Icons.handshake_outlined,
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
      if (ChatService.notification_)
            Positioned(
              // Position the red circle indicator
              top: 10, // Adjust this value as needed
              right: 25, // Adjust this value as needed
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                ),
              ),
            ),
            ],
    ),

    );
  }
}
