import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:sponsite/screens/signIn_screen.dart';
import 'package:sponsite/widgets/bottom_navigation_bar.dart';

User? user = FirebaseAuth.instance.currentUser;
String? sponsorID;

void check() {
  if (user != null) {
    sponsorID = user?.uid;
    print('Sponsor ID: $sponsorID');
  } else {
    print('User is not logged in.');
  }
}

class Offer {
  final String EventId;
  final String sponseeId;
  final String sponsorId;
  final List<String> Category;
  final String notes;

  Offer({
    required this.EventId,
    required this.sponseeId,
    required this.sponsorId,
    required this.Category,
    required this.notes,
  });
}

class Event {
  final String EventId;
  final String sponseeId;
  final String EventName;
  final String EventType;
  final String location;
  final String imgURL;
  final String date;
  final String time;
  final List<String> Category;
  final String notes;
  final String? benefits;
  final String  NumberOfAttendees ; 

  Event({
    required this.EventId,
    required this.sponseeId,
    required this.EventName,
    required this.EventType,
    required this.location,
    required this.imgURL,
    required this.date,
    required this.time,
    required this.Category,
     required  this.notes,
    this.benefits,
    required this.NumberOfAttendees, 
  });
}
class CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    int curveHeight = 40;
    Offset controlPoint = Offset(size.width / 2, size.height + curveHeight);
    Offset endPoint = Offset(size.width, size.height - curveHeight);

    Path path = Path()
      ..lineTo(0, size.height - curveHeight)
      ..quadraticBezierTo(controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy)
      ..lineTo(size.width, 0)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
class SponsorHomePage extends StatefulWidget {
  @override
  _SponsorHomePageState createState() => _SponsorHomePageState();
}

class _SponsorHomePageState extends State<SponsorHomePage> {
  List<Event> events = [];
  String selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    check();
    _loadEventsFromFirebase();
  }

  void _loadEventsFromFirebase() {
    final DatabaseReference database = FirebaseDatabase.instance.ref();
    database.child('sponseeEvents').onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          events.clear();
          Map<dynamic, dynamic> eventData =
              event.snapshot.value as Map<dynamic, dynamic>;

          eventData.forEach((key, value) {
            // Check if value['Category'] is a list
            List<String> categoryList = [];
            if (value['Category'] is List<dynamic>) {
              categoryList = (value['Category'] as List<dynamic>)
                  .map((category) => category.toString())
                  .toList();
            }

            events.add(Event(
              EventId: key,
              sponseeId: value['sponseeId'] as String? ?? '',
              EventName: value['EventName'] as String? ?? '',
              EventType: value['EventType'] as String? ?? '',
              location: value['Location'] as String? ?? '',
              imgURL: value['img'] as String? ?? 'https://png.pngtree.com/templates/sm/20180611/sm_5b1edb6d03c39.jpg',
              date: value['Date'] as String? ?? '',
              time: value['Time'] as String? ?? ' ',
              Category: categoryList,
              notes: value['Notes'] as String? ?? 'There are no notes available',
              benefits: value['Benefits'] as String?,
              NumberOfAttendees: value['NumberOfAttendees'] as String? ?? '', 
            ));
          });
        });
      }
    });
  }

  List<Event> getFilteredEvents() {
    if (selectedCategory == 'All') {
      return events;
    } else {
      return events
          .where((event) => event.Category.contains(selectedCategory))
          .toList();
    }
  }


@override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    Random random = Random();
Set<int> displayedEventIDs = Set<int>();
List<Widget> promoCards = List.generate(5, (index) {
  if (events.isEmpty || displayedEventIDs.length == events.length) {
    return Container(); // Return an empty container if events list is empty
  }

  int randomIndex;
  do {
    randomIndex = random.nextInt(events.length);
  } while (displayedEventIDs.contains(randomIndex));

  // Add the randomIndex to the displayedEventIndices set
  displayedEventIDs.add(randomIndex);
  Event event = events[randomIndex];
    return Container(
    height: 220, // Set the desired fixed height
    width: 300,  // Set the desired fixed width
    child: Card(
      elevation: 0, 
      child: Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 255, 255, 255),// Customize the card background color
        borderRadius: BorderRadius.circular(25),
        image: DecorationImage(
        image: event.imgURL.isNotEmpty
        ? NetworkImage(event.imgURL)
         : NetworkImage('https://media.istockphoto.com/id/1369748264/vector/abstract-white-background-geometric-texture.jpg?s=612x612&w=0&k=20&c=wFsN0D9Ifrw1-U8284OdjN25JJwvV9iKi9DdzVyMHEk='),
         fit: BoxFit.cover,
         ),
                              ),
        padding: EdgeInsets.fromLTRB(7, 5, 0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // children: [
          //   Text(
          //     ' ${event.EventName}',
          //     style: TextStyle(
          //       color: Color.fromARGB(255, 51, 45, 81),
          //       fontSize: 24, // Increased title font size
                
          //     ),
          //   ),
          //   SizedBox(height: 12), // Increased the height between title and description
          //   Text(
          //     '${event.EventType}',
          //     style: TextStyle(
          //       color: Color.fromARGB(255, 51, 45, 81),
          //       fontSize: 18, // Increased description font size
          //     ),
          //   ),
          //   SizedBox(height: 12), // Increased the height between title and description
          //   Text(
          //     '${event.location}',
          //     maxLines: 2, // Set the maximum number of lines
          //     overflow: TextOverflow.ellipsis, // Add ellipsis (...) if text overflows
          //     style: TextStyle(
          //       color: Color.fromARGB(255, 51, 45, 81),
          //       fontSize: 15, // Increased description font size
          //     ),
          //   ),
          // ],
        ),
      ),));
    }).toList();

 return Scaffold(
      body: SingleChildScrollView( // Wrap your content in SingleChildScrollView to enable scrolling
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const  Color.fromARGB(255, 51, 45, 81),
              ),
              child: Column(
                children: [
                  SizedBox(height: 33),
                  Center(
                    child: Container(
                      width: 430,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            offset: Offset(0, 2),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              style: TextStyle(color: Color.fromARGB(255,91,79,158)),
                              decoration: InputDecoration(
                                hintText: 'Search for an event',
                                hintStyle: TextStyle(color: Colors.grey),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          Icon(Icons.search, color: Color(0xFF6A62B6)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                ],
              ),
            ),
            // SizedBox(height: ),
            
      //       Container(
      //         padding: EdgeInsets.symmetric(horizontal: 16),
      //         decoration: BoxDecoration(
      //   borderRadius: BorderRadius.only(
      //     bottomLeft: Radius.circular(150.0),
      //     bottomRight: Radius.circular(150.0),
      //   ),
      //   gradient: LinearGradient(
      //     begin: Alignment.bottomCenter,
      //     end: Alignment.topCenter,
      //     colors: [
      //       Color.fromARGB(255, 91, 79, 158),
      //       Color.fromARGB(255, 51, 45, 81),
      //     ],
      //   ),
      // ),
      Stack(
  children: [
    Container(
      height: 200,
      color: Color.fromARGB(255, 255, 255, 255),
    ),
   ClipPath(
  clipper: CurveClipper(),
  child: Container(
     decoration: BoxDecoration(
    gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Color.fromARGB(255, 91, 79, 158),
            Color.fromARGB(255, 51, 45, 81),
          ],
        ),
     ),
    height: 240.0,
  ),
),

              Column(
                children: [
                  SizedBox(height: 20),
                  CarouselSlider(
                    items: promoCards,
                    options: CarouselOptions(
                      height: 170,// You can adjust this value to control the height
                      aspectRatio: 1.7, // Set your desired aspect ratio for width and height
                      autoPlay: true,
                      enlargeCenterPage: true,
                      autoPlayInterval: Duration(seconds: 3),
                    ),
                  ),
                  SizedBox(height: 26),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Recent Events",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                          color: Color.fromARGB(255,91,79,158), // Changed to purple
                          // Removed the underline
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.filter_list,
                              color: Color.fromARGB(255,91,79,158),// Changed to purple
                            ),
                            onPressed: () {
                              // Handle filter action
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                ],
              ),
             ],
),
            Container(
              height: 40,
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCategoryText('All', selectedCategory == 'All'),
                  _buildCategoryText('Education', false),
                  _buildCategoryText('Cultural', false),
                  _buildCategoryText('Financial Support', false),
                ],
              ),
            ),
            // SizedBox(height: 3),
                SizedBox(height: screenHeight-540,
              child: GridView.builder(
              shrinkWrap: true, // Add this to allow GridView to scroll inside SingleChildScrollView
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: getFilteredEvents().length,
              itemBuilder: (context, index) {
                Event event = getFilteredEvents()[index];

                return GestureDetector(
                  onTap: () {
                    // Navigate to the event details page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            RecentEventsDetails(event: event),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    color: Color.fromARGB(255, 255, 255, 255),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: screenHeight * 0.19,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                           image: DecorationImage(
                              image: event.imgURL.isNotEmpty
                                  ? NetworkImage(event.imgURL)
                                  : NetworkImage('https://media.istockphoto.com/id/1369748264/vector/abstract-white-background-geometric-texture.jpg?s=612x612&w=0&k=20&c=wFsN0D9Ifrw1-U8284OdjN25JJwvV9iKi9DdzVyMHEk='),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.EventName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: const Color.fromARGB(255, 0, 0, 0),
                                ),
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 18,
                                    color: Color.fromARGB(255,91,79,158),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    "${event.date}",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: const Color.fromARGB(
                                          255, 0, 0, 0),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 21,
                                    color: Color.fromARGB(255,91,79,158),
                                  ),
                                  SizedBox(width: 4),
                                   Expanded(
                                  child: Text(
                                    event.location,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: const Color.fromARGB(255, 0, 0, 0),
                                    ),
                                    overflow: TextOverflow.ellipsis, // Add this line
                                    maxLines: 1, // Add this line
                                  ),)
                                ],
                              ),
                                SizedBox(height: 10),
                              Wrap(
                                spacing: 4,
                                children: event.Category.map((category) {
                                  return Chip(
                                    label: Text(category),
                                    backgroundColor:
                                    Color.fromARGB(255, 255, 255, 255),
                                    shadowColor: Color(0xFF6A62B6),
                                    elevation: 3,
                                    labelStyle: TextStyle(
                                      color: Color.fromARGB(255,91,79,158),
                                    ),
                                  );
                                }).toList(),
                              ),
                              SizedBox(height: 10),
                              Center(
                                
                              ),
                            ],
                          ),
                        ),
                      Row(
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
                      ],

                    ),
                  ),
                );
              },
            ),),
            const BottomNavBar(),
    
          ],
   
        ),
        
      ),
     
    );
  }
  Widget _buildCategoryText(String category, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = category;
        });
      },
      child: Column(
        children: [
          Text(
            category,
            style: TextStyle(
              fontSize: 16,
              color: isSelected ? Color.fromARGB(255,91,79,158) : Colors.grey, // Button color
              decoration: isSelected ? TextDecoration.underline : null,
              decorationColor: Color.fromARGB(255,91,79,158), // Button color
              decorationThickness: 2,
            ),
          ),
          SizedBox(height: 2),
          isSelected
              ? Container(
                  width: 30,
                  height: 2,
                  color: Color.fromARGB(255,91,79,158), // Button color
                )
              : SizedBox(height: 2),
        ],
      ),
    );
  }
}

class RecentEventsDetails extends StatelessWidget {
  final Event event;

  RecentEventsDetails({required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.topLeft,
            children: [
              Container(
                height: 440,
                width: double.infinity,
                decoration: BoxDecoration(
                  color:  Color.fromARGB(255, 51, 45, 81),
                  image: DecorationImage(
                    image: event.imgURL.isNotEmpty
                        ? NetworkImage(event.imgURL)
                        : NetworkImage('https://media.istockphoto.com/id/1369748264/vector/abstract-white-background-geometric-texture.jpg?s=612x612&w=0&k=20&c=wFsN0D9Ifrw1-U8284OdjN25JJwvV9iKi9DdzVyMHEk='),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
             Padding(
  padding: const EdgeInsets.all(16.0),
             ),
Container(
 color:  Color.fromARGB(255, 51, 45, 81),
 height: 75,
 padding: const EdgeInsets.fromLTRB(0,25,0,0),
  child: Row(
    children: [
      IconButton(
        icon: Icon(Icons.arrow_back),
        color: Color.fromARGB(255, 139, 134, 167),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      
      Text(
        "Event Details",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24,
          color: Color.fromARGB(255, 255, 255, 255),
        ),
      ),
      SizedBox(width: 40), // Adjust the spacing as needed
    ],
  ),
             ),
            ],
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20),
                        Text(
                          event.EventName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          event.EventType,
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.black87,
                          ),
                        ),
                        Divider(height: 30, thickness: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 40,
                              color: Color.fromARGB(255, 91, 79, 158),
                            ),
                            SizedBox(width: 10), // Adjust the spacing as needed
                            Text(
                              event.location,
                              style: TextStyle(
                                fontSize: 22,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),

                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 40,
                              color: Color.fromARGB(255, 91, 79, 158),
                            ),
                            SizedBox(width: 10), // Adjust the spacing as needed
                            Text(
                              event.date,
                              style: TextStyle(
                                fontSize: 22,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        Row(
  children: [
    Icon(
      Icons.access_time,
      size: 40,
      color: Color.fromARGB(255, 91, 79, 158),
    ),
    SizedBox(width: 1), // Adjust the spacing as needed
    Text(
      " ${event.time}",
      style: TextStyle(
        fontSize: 22,
        color: Colors.black87,
      ),
    ),
  ],
),
  Row(
                            children: [
                              Icon(
                                Icons.person,
                                size: 40,
                                color: Color.fromARGB(255, 91, 79, 158),
                              ),
                              SizedBox(width: 10), // Adjust the spacing as needed
                              Text(
                                "${event.NumberOfAttendees}",
                                style: TextStyle(
                                  fontSize: 22,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        SizedBox(height: 20),

                        Text(
                          "Categories",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 10),
                        Wrap(
                                spacing: 4,
                                children: event.Category.map((category) {
                                  return Chip(
                                    label: Text(category),
                                    backgroundColor:
                                    Color.fromARGB(255, 255, 255, 255),
                                    shadowColor: Color(0xFF6A62B6),
                                    elevation: 3,
                                    labelStyle: TextStyle(
                                      color: Color.fromARGB(255,91,79,158),
                                    ),
                                  );
                                }).toList(),
                              ),
                        SizedBox(height: 20),
                        Text(
                          "Benefits",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          event.benefits ?? "No benefits available",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          "Notes",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          (event.notes != null && event.notes.isNotEmpty)
                              ? event.notes
                              : "There are no notes available",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 20),
                        
                        Center(
                         child:  SizedBox( 
                          height:55, //height of button
                          width:190,
                          child: ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return CustomDialog(
                                    event: event,
                                    parentContext: context,
                                    sponsorID: '',
                                  );
                                },
                              );
                            },
                            child: Text(
                              'Send offer',
                              style: TextStyle(
                                fontSize: 25,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: Color.fromARGB(255, 91, 79, 158),
                              onPrimary: Colors.white,
                              elevation: 10,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              
                            ),
                          ),
                         ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}





class CustomDialog extends StatefulWidget {
  final Event event;
  final BuildContext? parentContext;
  final String? sponsorID;

  CustomDialog({
    required this.event,
    this.parentContext,
    required this.sponsorID,
  });

  @override
  _CustomDialogState createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  Set<String> filters = <String>{};
  TextEditingController notesController = TextEditingController();

  final DatabaseReference database = FirebaseDatabase.instance.ref();

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  void _showEmptyFormAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Empty Offer'),
          content: Text(
              'Please select at least one category and enter some notes before sending the offer'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'OK',
                style: TextStyle(fontSize: 20),
              ),
              style: ElevatedButton.styleFrom(
                primary: Color.fromARGB(255,51,45,81), // Button color
                onPrimary: Colors.white,
                elevation: 20,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _sendOffer() async {
    if (filters.isEmpty || notesController.text.isEmpty) {
      _showEmptyFormAlert();
    } else {
      List<String> selectedCategories = filters
          .map((category) => category.toString().split('.').last)
          .toList();

      // Create an Offer object
      Offer offer = Offer(
        EventId: widget.event.EventId,
        sponseeId: "sponseeID",
        sponsorId: widget.sponsorID ?? "", // Replace with the actual sponsor ID
        notes: notesController.text,
        Category: selectedCategories,
      );

      // Save the offer to the database
      DatabaseReference offersRef = database.child('offers');
      DatabaseReference newOfferRef = offersRef.push();

      await newOfferRef.set({
        "eventName": offer.EventId,
        "sponseeId": offer.sponseeId,
        "sponsorId": offer.sponsorId,
        "notes": offer.notes,
        "Filter": offer.Category,
      });

      setState(() {
        filters.clear();
      });
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Offer', style: TextStyle(fontSize: 30)),
          Container(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.only(top: 1, right: 1),
              child: IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
        ],
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 70.0, vertical: 40.0),
      content: SingleChildScrollView(
        child: Container(
          width: 380,
          height: 470,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Wrap(
                spacing: 9.0,
                children: widget.event.Category.map((category) {
                  return FilterChip(
                    label: Text(category),
                    selected: filters.contains(category),
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          filters.add(category);
                        } else {
                          filters.remove(category);
                        }
                      });
                    },
                    backgroundColor: Color.fromARGB(255, 168, 164, 194), // Button color
                    selectedColor: Color.fromARGB(255,91,79,158), // Button color
                    labelStyle: TextStyle(
                      color: Colors.white,
                    ),
                    elevation: 3,
                  );
                }).toList(),
              ),
              SizedBox(height: 15),
              TextField(
                controller: notesController,
                decoration: InputDecoration(
                  hintText: 'Enter notes or additional information',
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Color.fromARGB(255,91,79,158)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  ),
                ),
                maxLines: 15,
              ),
            ],
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(bottom: 30.0),
          child: Center(
            child: ElevatedButton(
              onPressed: _sendOffer,
              child: Text(
                'Send Offer',
                style: TextStyle(fontSize: 20,),
              ),
              style: ElevatedButton.styleFrom(
                primary: Color.fromARGB(255,91,79,158), // Button color
                onPrimary: Colors.white,
                elevation: 20,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    theme: ThemeData(
      primaryColor: Color(0xFF5B4F9E), // Button color
    ),
    home: user != null ? SponsorHomePage() : SignIn(),
  ));
}