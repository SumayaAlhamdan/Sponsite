import 'package:flutter/material.dart';
import 'package:sponsite/screens/admin_screens/admin_home_screen.dart';
import 'package:sponsite/screens/admin_screens/displayUsers.dart';
import 'package:sponsite/screens/admin_screens/admin_categories.dart';


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
    AdminCategories(),
  ];    



  void _onItemTap(int index) {
    setState(() {
      currentPageIndex = index;
    });
  }
Widget editCategory() {
  return Container(
    margin: EdgeInsets.fromLTRB(16.0, 32.0, 16.0, 16.0), // Increased top margin
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SizedBox(), // Empty expanded widget to push the button to the right
            ),
            Align(
              alignment: Alignment.centerRight, // Align to the right
              child: ElevatedButton(
                onPressed: _showTextInputDialog,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                    const Color.fromARGB(255, 51, 45, 81),
                  ),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
                child: Text(
                  'Add New Category',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.0), // Add space between the button and category items

        // Rest of your widget content...
      ],
    ),
  );
}

}


