import 'package:flutter/material.dart';
import 'package:sponsite/screens/sponsee_screens/ViewCurrentSponsee.dart';
import 'package:sponsite/widgets/user_type_selector.dart';

class pastevents extends StatefulWidget {
  const pastevents({Key? key}) : super(key: key);

  @override
  _pastevents createState() => _pastevents();
}

class _pastevents extends State<pastevents> {
  int selectedTabIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //bottomNavigationBar: const BottomNavBar(),
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // Remove the elevation shadow
      ),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: 10),
          child: Column(
            children: [
              Text(
                'My Events',
                style: TextStyle(
                  height: 0,
                  fontSize: 35,
                  //letterSpacing: 10,
                ),
              ),
              SizedBox(
                height: 300,
              ),
              Center(
                child: Text(
                  'No past events',
                  style: TextStyle(
                    height: 15,
                    color: Color.fromARGB(255,91,79,158),
                    fontSize: 25,
                   // letterSpacing: 5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 200), // Adjust the top padding as needed
        child: SizedBox(
          width: 250, // Set the button width to 250
          height: 50, // Set a constant height for the button
          child: SingleChoice(
            initialSelection: selectedTabIndex == 1
                ? eventType.past
                : eventType.current,
            onSelectionChanged: (eventType selection) {
              setState(() {
                // Update selectedTabIndex based on the selection
                if (selection == eventType.current) {
                  selectedTabIndex = 1;
                } else {
                  selectedTabIndex = 0;
                }

                // Navigate based on selectedTabIndex
                if (selectedTabIndex == 1) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (context) => const ViewCurrentSponsee()),
                  );
                }  else {
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: (context) => const pastevents()),
  );
}

  });
},

        ),
      ),
    ),
            );
  }
}