import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  final String title;

  CustomAppBar({required this.title});

  @override
  Widget build(BuildContext context) {
    if(title != "Create Google Calendar Event"){
    return Container(
      height: 95,
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 51, 45, 81),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40.0),
          bottomRight: Radius.circular(40.0),
        ),
      ),
      child: AppBar(
        title: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back),
              alignment: Alignment.topLeft,
              color: Colors.white,
              iconSize:40,  
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),  
            SizedBox(width: 235 ),  
            Expanded(     
                  child: Text(  
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Urbanist'
                  ),  
                ),  
              ),  
          ],  
        ),
        backgroundColor: Colors.transparent, // Transparent app bar background
        elevation: 0, // Remove the shadow
        automaticallyImplyLeading: false, // Hide the back button
      ),
    );
  }
  else{
     return Container(
      height: 95,
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 51, 45, 81),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40.0),
          bottomRight: Radius.circular(40.0),
        ),
      ),
      child: AppBar(
        title: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back),
              alignment: Alignment.topLeft,
              color: Colors.white,
              iconSize:30,  
              onPressed: () {
                Navigator.of(context).pop();
              },        
            ),            
            SizedBox(width: 120),  
            Expanded(     
                  child: Text(  
                  title,  
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w500,
                  ),  
                ),  
              ),  
          ],  
        ),
        backgroundColor: Colors.transparent, // Transparent app bar background
        elevation: 0, // Remove the shadow
        automaticallyImplyLeading: false, // Hide the back button
      ),
    );
  }
  }
}
