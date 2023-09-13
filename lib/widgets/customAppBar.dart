import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  final String title;
  CustomAppBar({Key? key, required this.title}) ;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40.0),
          bottomRight: Radius.circular(40.0),
        ),
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Color.fromARGB(255, 91, 79, 158),
            Color.fromARGB(255, 51, 45, 81),
          ],
        ),
      ),
      child: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(top:12.0),
          child: Center(
            child: Text(
              title,
              style: TextStyle(color: Colors.white , fontSize: 35 , fontWeight: FontWeight.w300), // Text color
            ),
          ),
        ),
        backgroundColor: Colors.transparent, // Transparent app bar background
        elevation: 0, // Remove the shadow
        automaticallyImplyLeading: false,  // Hide the back button
        /*actions: [
          // Add your app bar actions here
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Handle search action
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Handle notifications action
            },
          ),
        ],*/
      ),
    );
  }
}