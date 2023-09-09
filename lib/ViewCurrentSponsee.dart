import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:sponsite/eventDetail.dart';
import 'package:sponsite/widgets/bottom_navigation_bar.dart';
import 'package:sponsite/widgets/user_type_selector.dart';
import 'pastevents.dart';

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
      shadowColor: Color(0xFF6A62B6),
      elevation: 3,
      labelStyle: TextStyle(
        color: Color(0xFF6A62B6),
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
            color: Color(0xFF6A62B6),
          ),
        ),
        Icon(
          Icons.arrow_forward,
          size: 16, // Adjust the size as needed
          color: Color(0xFF6A62B6),
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
    bottomNavigationBar: const BottomNavBar(),
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
                letterSpacing: 10
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ViewCurrentSponsee()),
                );
              } else{
                Navigator.push(
                  context,
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
            events.add(Event(
              EventName: value['EventName'] as String? ?? '',
              EventType: value['EventType'] as String? ?? '',
              location: value['Location'] as String? ?? '',
              description: value['Description'] as String? ?? '',
              imgURL: value['img'] as String? ?? '',
              date: value['Date'] as String? ?? '',
              time: value['Time'] as String? ?? '',
              notes: value['notes'] as String? ?? '',
              benefits: value['benefits'] as String? ?? '',
              Category: categoryList,
            ));
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
  final String notes;
  final String benefits;
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
    required this.notes,
    required this.benefits,
  });
}
/*
class SegmentedButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  SegmentedButton({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: isSelected ? Color.fromARGB(255, 106, 33, 134) : Colors.white,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: Color.fromARGB(225, 106, 33, 134),
            width: 2.0,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: isSelected ? Colors.white : Color.fromARGB(225, 106, 33, 134),
            fontSize: 18,
          ),
        ),
      ),
    );
  }
  
} */
 

/*
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Color.fromARGB(255, 106, 33, 134),
        bottomNavigationBar: const NavigationExample(),
        body: Padding(
          padding: EdgeInsets.only(top: 100), // Adjust the top padding as needed
          child: Container(
            width: 800,
            height: 1340,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
              color: Color.fromRGBO(255, 255, 255, 1),
            ),
            child: Column(
              children: [
                SizedBox(
                  width: 144,
                  height: 31,
                  child: Align(
                    alignment: Alignment.topLeft, // Align to the left
                    child: Text(
                      'Current Events',
                      style: TextStyle(
                        color: Color(0xFF6A2186),
                        fontSize: 17,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.50,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    width: 612,
                    height: 165,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x3F000000),
                          blurRadius: 4,
                          offset: Offset(0, 4),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }} */
