import 'package:flutter/material.dart';
import 'package:sponsite/ViewCurrentSponsee.dart';
import 'package:sponsite/screens/sponsee_screens/sponsee_chat_screen.dart';
import 'package:sponsite/screens/postEvent.dart';
import 'package:sponsite/screens/sponsor_screens/sponsor_profile_screen.dart';
import 'package:sponsite/screens/sponsee_screens/sponsee_home_screen.dart';
import 'package:sponsite/screens/sponsor_screens/sponsor_chat_screen.dart';

class SponsorBottomNavBar extends StatefulWidget {
  const SponsorBottomNavBar({super.key});

  @override
  State<SponsorBottomNavBar> createState() => _SponsorBottomNavBarState();
}

class _SponsorBottomNavBarState extends State<SponsorBottomNavBar> {
  int currentPageIndex = 0;

  // final List<Widget> _widgetOptions =[
  //   const SponseeHome(),
  //   const ViewCurrentSponsee(),
  //   const MyApp(),
  //   const ChatScreen(),
  //   const ProfilePage()

  // ];
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
              blurRadius: 10),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
        child: NavigationBar(
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          onDestinationSelected: (int index) {
            setState(() {
              currentPageIndex = index;
            });

            switch (index) {
              case 0:
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const SponseeHome()),
                );

                break;
              case 1:
                // Navigator.of(context).pushReplacement(
                //   MaterialPageRoute(
                //       builder: (context) => const ViewCurrentSponsee()),
                //);
                break;
              case 2:
                // Navigator.of(context).pushReplacement(
                //   MaterialPageRoute(builder: (context) => const MyApp()),
                // );

                break;
              case 3:
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const SponsorChat()),
                );
                break;
              case 4:
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const SponsorProfile()),
                );

                break;
            }
          },
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          indicatorColor: Color.fromARGB(134, 214, 214, 215),
          height: 60,
          selectedIndex: currentPageIndex,
          destinations: const <Widget>[
            NavigationDestination(
              // selectedIcon: Icon(Icons.home,size: 40,color: Color.fromARGB(255, 51, 45, 81),),
              icon: Icon(
                Icons.home_rounded,
                size: 40,
                color: Color.fromARGB(255, 51, 45, 81),
              ),
              label: '',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.calendar_month_rounded,
                size: 40,
                color: Color.fromARGB(255, 51, 45, 81),
              ),
              label: '',
            ),
            // NavigationDestination(
            //   selectedIcon: Icon(Icons.add_box_rounded,size: 40,color: Color.fromARGB(255, 51, 45, 81),),
            //   icon: Icon(Icons.add_box_outlined,size: 40,color: Color.fromARGB(255, 51, 45, 81),),
            //   label: '',
            // ),
            NavigationDestination(
              selectedIcon: Icon(
                Icons.add_circle_rounded,
                size: 60,
                color: Color.fromARGB(255, 51, 45, 81),
              ),
              icon: Icon(
                Icons.add_circle_rounded,
                size: 60,
                color: Color.fromARGB(255, 51, 45, 81),
              ),
              label: '',
            ),
            NavigationDestination(
              selectedIcon: Icon(
                Icons.chat_bubble,
                size: 40,
                color: Color.fromARGB(255, 51, 45, 81),
              ),
              icon: Icon(
                Icons.chat_bubble,
                size: 40,
                color: Color.fromARGB(255, 51, 45, 81),
              ),
              label: '',
            ),
            NavigationDestination(
              selectedIcon: Icon(
                Icons.account_circle,
                size: 40,
                color: Color.fromARGB(255, 51, 45, 81),
              ),
              icon: Icon(
                Icons.account_circle,
                size: 40,
                color: Color.fromARGB(255, 51, 45, 81),
              ),
              label: '',
            )
          ],
        ),
      ),
    );
  }
}
