import 'package:flutter/material.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int currentPageIndex = 0;

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
          },
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          indicatorColor: Color.fromARGB(134, 214, 214, 215),
          height: 100,
          selectedIndex: currentPageIndex,
          destinations: const <Widget>[
            NavigationDestination(
              // selectedIcon: Icon(Icons.home,size: 40,color: Color.fromARGB(255, 106, 33, 134)),
              icon: Icon(Icons.home_rounded,
                  size: 40, color: Color.fromARGB(255, 106, 33, 134)),
              label: '',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_rounded,
                  size: 40, color: Color.fromARGB(255, 106, 33, 134)),
              label: '',
            ),
            // NavigationDestination(
            //   selectedIcon: Icon(Icons.add_box_rounded,size: 40,color: Color.fromARGB(255, 106, 33, 134)),
            //   icon: Icon(Icons.add_box_outlined,size: 40,color: Color.fromARGB(255, 106, 33, 134)),
            //   label: '',
            // ),
            NavigationDestination(
              selectedIcon: Icon(Icons.chat_bubble,
                  size: 40, color: Color.fromARGB(255, 106, 33, 134)),
              icon: Icon(Icons.chat_bubble_outline,
                  size: 40, color: Color.fromARGB(255, 106, 33, 134)),
              label: '',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.account_circle,
                  size: 40, color: Color.fromARGB(255, 106, 33, 134)),
              icon: Icon(Icons.account_circle,
                  size: 40, color: Color.fromARGB(255, 106, 33, 134)),
              label: '',
            )
          ],
        ),
      ),
    );
  }
}
