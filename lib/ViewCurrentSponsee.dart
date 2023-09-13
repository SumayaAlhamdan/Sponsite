import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:sponsite/eventDetail.dart';
import 'package:sponsite/widgets/user_type_selector.dart';
import 'pastevents.dart';

User? user = FirebaseAuth.instance.currentUser;
String? sponseeID;

void check() {
  if (user != null) {
    sponseeID = user?.uid;
    print('Sponsee ID: $sponseeID');
  } else {
    print('User is not logged in.');
  }
}

class ViewCurrentSponsee extends StatefulWidget {
  const ViewCurrentSponsee({Key? key}) : super(key: key);

  @override
  _ViewCurrentSponseeState createState() => _ViewCurrentSponseeState();
}

class _ViewCurrentSponseeState extends State<ViewCurrentSponsee> {
  List<Event> events = [];
  int selectedTabIndex = 0;
  final DatabaseReference dbRef =
      FirebaseDatabase.instance.reference().child('sponseeEvents');

  @override
  void initState() {
    super.initState();
    _loadEventsFromFirebase();
  }
  Widget listItem({required Event event}) {
  return Container(
    margin: const EdgeInsets.all(10),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: Color.fromARGB(255, 255, 255, 255),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2), // Add a blurred shadow
          blurRadius: 10,
          spreadRadius: 2,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Smaller picture on the top
        Container(
          width: double.infinity,
          height: 180, // Adjust the height as needed
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              event.imgURL,
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Event details below the image
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.EventName,
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 24,
                    color: Colors.black87,
                  ),
                  SizedBox(width: 5),
                  Text(
                    event.date,
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              Wrap(
  spacing: 8,
  children: event.Category.map((category) {
    return Chip(
      label: Text(category.trim()),
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      shadowColor: Color.fromARGB(255,91,79,158),
      elevation: 3,
      labelStyle: TextStyle(
        color: Color.fromARGB(255,91,79,158),
      ),
    );
  }).toList(),
),
              const SizedBox(
                height: 10,
              ),
              Align(
  alignment: Alignment.bottomRight,
  child: GestureDetector(
    onTap: () {
      final categoriesString = event.Category.join(', ');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => eventDetail(
            DetailKey: event.EventName,
            location: event.location,
            fullDesc: event.description,
            img: event.imgURL,
            date: event.date,
            Type: event.EventType,
            Category: categoriesString,
            time: event.time,
            notes: event.notes,
            benefits: event.benefits,
          ),
        ),
      );
    },
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          'more details',
          style: TextStyle(
            fontSize: 16,
            fontStyle: FontStyle.italic,
            color: Color.fromARGB(255,91,79,158),
          ),
        ),
        Icon(
          Icons.arrow_forward,
          size: 16, // Adjust the size as needed
          color: Color.fromARGB(255,91,79,158),
        ),
      ],
    ),
  ),
),

            ],
          ),
        ),
      ],
    ),
  );
}@override
Widget build(BuildContext context) {
  return Scaffold(
    // bottomNavigationBar: const SponseeBottomNavBar(),
    //BottomNavBar(),
    backgroundColor: Colors.white,
    appBar: AppBar(
      backgroundColor: Colors.white,
      elevation: 0, // Remove the elevation shadow
    ),
    body: SafeArea(
      child: Padding(
        padding: EdgeInsets.only(top: 10),
        child: Column(
          children: [
            Text(
              'My Events',
              style: TextStyle(
                height: 0,
                fontSize: 35,
                fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(
              height: 100,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 50.0),
            ),
            SizedBox(
              height: 20,
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                ),
                itemCount: events.length,
                itemBuilder: (BuildContext context, int index) {
                  Event event = events[index];
                  return listItem(event: event);
                },
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
          initialSelection: selectedTabIndex == 0
              ? eventType.current
              : eventType.past,
          onSelectionChanged: (eventType selection) {
            setState(() {
              selectedTabIndex = selection == eventType.current ? 0 : 1;
              if (selectedTabIndex == eventType.current) {
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: (context) => const ViewCurrentSponsee()),
  );
} else {
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


  void _loadEventsFromFirebase() {
    check();
  dbRef.onValue.listen((event) {
    if (event.snapshot.value != null) {
      setState(() {
        events.clear();
        Map<dynamic, dynamic> eventData =
            event.snapshot.value as Map<dynamic, dynamic>;
        eventData.forEach((key, value) {
          var categoryList = (value['Category'] as List<dynamic>)
              .map((category) => category.toString())
              .toList();
          // Check if the event belongs to the current user (sponsee)
          if (value['SponseeID'] == sponseeID) {
            events.add(Event(
              EventName: value['EventName'] as String? ?? '',
              EventType: value['EventType'] as String? ?? '',
              location: value['Location'] as String? ?? '',
              description: value['Description'] as String? ?? '',
              imgURL: value['img'] as String? ?? '',
              date: value['Date'] as String? ?? '',
              time: value['Time'] as String? ?? '',
              notes: value['Notes'] as String? ?? '',
              benefits: value['Benefits'] as String? ?? '',
              Category: categoryList,
            ));
          }
        });
      });
    }
  });
}

}


class Event {
  final String EventName;
  final String EventType;
  final String location;
  final String description;
  final String imgURL;
  final String date;
  final String time;
  final String? notes;
  final String? benefits;
  final List<String> Category;

  Event({
    required this.EventName,
    required this.EventType,
    required this.location,
    required this.description,
    required this.imgURL,
    required this.date,
    required this.time,
    required this.Category, 
     this.notes,
     this.benefits,
  });
}
