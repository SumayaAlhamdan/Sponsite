import 'package:flutter/material.dart';
import 'package:sponsite/screens/admin_screens/admin_home_screen.dart';
import 'package:sponsite/screens/admin_screens/displayUsers.dart';


class AdminBottomNavBar extends StatefulWidget {
  const AdminBottomNavBar({Key? key}) : super(key: key);

  @override
  State<AdminBottomNavBar> createState() => _AdminBottomNavBarState();
}

class _AdminBottomNavBarState extends State<AdminBottomNavBar> {
  int currentPageIndex = 0;

  final List<Widget> _widgetOptions = [
    AdminPanel(),
    DisplayUsers(),
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
            activeIcon:  Icon(
              Icons.home_rounded,
              size: 40,
              color: Color.fromARGB(255, 91, 79, 158),
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.manage_accounts,
              size: 40,
              color: Colors.white,
            ),
            label: 'Users',
            activeIcon:  Icon(  
              Icons.manage_accounts,
              size: 40,
              color: Color.fromARGB(255, 91, 79, 158),
            ),
          ),
        ],
        currentIndex: currentPageIndex,
        
        onTap: _onItemTap,
      ),
    );
  }
}


