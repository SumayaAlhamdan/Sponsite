import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  final String title;
  const CustomAppBar({super.key, required this.title}) ;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 51, 45, 81),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40.0),
          bottomRight: Radius.circular(40.0),
        ),
      ),
      child: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(top: 12.0, left: 30.0),
          child: Text(
            title,
            style: const TextStyle(color: Colors.white , fontSize: 35 , fontWeight: FontWeight.w400), // Text color
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