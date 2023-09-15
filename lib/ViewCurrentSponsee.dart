import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:sponsite/eventDetail.dart';
import 'package:sponsite/widgets/customAppBar.dart';
import 'package:sponsite/widgets/user_type_selector.dart';

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
              event.imgURL.isNotEmpty
                  ? event.imgURL
                  : 'https://media.istockphoto.com/id/1369748264/vector/abstract-white-background-geometric-texture.jpg?s=612x612&w=0&k=20&c=wFsN0D9Ifrw1-U8284OdjN25JJwvV9iKi9DdzVyMHEk=',
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
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 5,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 24,
                        color:Color.fromARGB(255, 91, 79, 158),
                      ),
                      SizedBox(width: 5),
                      Text(
                        event.date,
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 24,
                        color: Color.fromARGB(255, 91, 79, 158),
                      ),
                      SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          event.location,
                          style: TextStyle(fontSize: 18),
                           overflow: TextOverflow.ellipsis
                        ),
                      ),
                    ],
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
                    shadowColor: Color.fromARGB(255, 91, 79, 158),
                    elevation: 3,
                    labelStyle: TextStyle(
                      color: Color.fromARGB(255, 91, 79, 158),
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
                          NumberOfAttendees: event.NumberOfAttendees,
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
                          color: Color.fromARGB(255, 91, 79, 158),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward,
                        size: 16, // Adjust the size as needed
                        color: Color.fromARGB(255, 91, 79, 158),
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
    appBar: PreferredSize(
      preferredSize: Size.fromHeight(100.0), // Adjust the height as needed
      child: CustomAppBar(title: 'My Events',),
    ),
    body: SafeArea(
      child: Padding(
        padding: EdgeInsets.only(top: 15),
        child: Column(
          children: [
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
              child: Scrollbar(
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: BouncingScrollPhysics(), // Enable scrolling for the GridView
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.9,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: events.length,
                  itemBuilder: (BuildContext context, int index) {
                    Event event = events[index];
                    return listItem(event: event);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
    floatingActionButton: Padding(
      padding: const EdgeInsets.only(top: 170), // Adjust the top padding as needed
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
                // Handle the case when "Past" is selected
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
              imgURL: value['img'] as String? ?? 'https://png.pngtree.com/templates/sm/20180611/sm_5b1edb6d03c39.jpg' ,
              date: value['Date'] as String? ?? '',
              time: value['Time'] as String? ?? '',
              notes: value['Notes'] as String? ?? 'There are no notes available',
              benefits: value['Benefits'] as String? ?? '',
              NumberOfAttendees: value['NumberOfAttendees'] as String? ?? '' ,
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
  final String notes;
  final String? benefits;
  final String NumberOfAttendees ;
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
    required this.NumberOfAttendees,
     required this.notes,
     this.benefits,
  });
}
