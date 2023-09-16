import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:sponsite/screens/signIn_screen.dart';

String? sponsorID;
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
  final String timeStamp;

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
    required this.timeStamp, 
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
User? user = FirebaseAuth.instance.currentUser;


void check() {
  if (user != null) {
    sponsorID = user?.uid;
    print('Sponsor ID: $sponsorID');
  } else {
    print('User is not logged in.');
  }
}
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
          String timestampString = value['TimeStamp'] as String;
          String eventDatestring = value['Date'];
         DateTime? eventDate = DateTime.tryParse(eventDatestring as String);
         

          // Simulate the current time (for testing purposes)
          DateTime currentTime = DateTime.now();

          // Check if the event was added in the last 3 days
          if (eventDate!.isAfter(currentTime)) {
            events.add(Event(
              EventId: key,
              sponseeId: value['SponseeID'] as String? ?? '',
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
              timeStamp: timestampString, // Store the timestamp
            ));
          }
        });

        // Sort events based on the timeStamp (descending order)
        events.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));
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
       color: Color.fromARGB(255, 255, 255, 255),
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
  body:SingleChildScrollView( 
        physics: AlwaysScrollableScrollPhysics(),// Wrap your content in SingleChildScrollView to enable scrolling
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
                        color: Color.fromARGB(0, 255, 255, 255),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(96, 158, 158, 158),
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
                          Icon(Icons.search, color: Colors.grey),
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
                  SizedBox(height: 80),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                    
  Padding(
    padding: const EdgeInsets.only(left: 16), // Add left padding to the title
    child: Text(
      "Recent Events",
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 30,
        color: Color.fromARGB(255, 91, 79, 158), // Changed to purple
      ),
    ),
  ), // Add a comma here
  Positioned(
        top: kToolbarHeight + 40, // Adjust the top position as needed
        right: 16, // Adjust the right position as needed
        child: IconButton(
          icon: Icon(Icons.filter_list, color: Colors.grey), // Customize the icon
          onPressed: () {
            // Add your filter functionality here
          },
        ),
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
  child: Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCategoryText('All', selectedCategory == 'All'),
          _buildCategoryText('Education', false),
          _buildCategoryText('Cultural', false),
          _buildCategoryText('Financial Support', false),
        ],
      ),
      
    ],
  ),
),

            // SizedBox(height: 3),
              SizedBox(height: screenHeight-540,
              child:   Scrollbar(// Set this to true to always show the scrollbar
              child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(12,0,12.0,0), 
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
   child: Container(
    color:Color.fromARGB(255, 255, 255, 255),
  child: Card(
  elevation: 5,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(30),
  ),
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
      Container(
        decoration: BoxDecoration(color: Colors.white ,borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),)),
        //color: Colors.white, // Set the background color to white
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
                  color: Color.fromARGB(255, 91, 79, 158),
                ),
                SizedBox(width: 4),
                Text(
                  "${event.date}",
                  style: TextStyle(
                    fontSize: 18,
                    color: const Color.fromARGB(255, 0, 0, 0),
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
                  color: Color.fromARGB(255, 91, 79, 158),
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
                  ),
                )
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
                  shadowColor:Color.fromARGB(255, 91, 79, 158),
                  elevation: 3,
                  labelStyle: TextStyle(
                    color: Color.fromARGB(255, 91, 79, 158),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 10), // Add some space
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
             SizedBox(height: 20.5), // Add some space at the bottom
              Container(
                color: Colors.white, // Set the background color to white
                height: 12, // Adjust the height as needed
              ),
          ],
        ),
      ),
    ],
  ),
)
));

              },
            ),),
    
          )],
   
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
                  color: Color.fromARGB(255, 51, 45, 81),
                  image: DecorationImage(
                    image: event.imgURL.isNotEmpty
                        ? NetworkImage(event.imgURL)
                        : NetworkImage(
                            'https://media.istockphoto.com/id/1369748264/vector/abstract-white-background-geometric-texture.jpg?s=612x612&w=0&k=20&c=wFsN0D9Ifrw1-U8284OdjN25JJwvV9iKi9DdzVyMHEk='),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
  decoration: BoxDecoration(
    color: Color.fromARGB(255, 51, 45, 81),
    borderRadius: BorderRadius.only(
      bottomLeft: Radius.circular(20),
      bottomRight: Radius.circular(20),
    ),
  ),
  height: 75,
  padding: const EdgeInsets.fromLTRB(16, 0, 0, 0), // Adjust the padding as needed
  child: Row(
    children: [
      IconButton(
        icon: Icon(Icons.arrow_back),
        color: Colors.white,
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      Text(
        "Event Details",
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 24,
          color: Colors.white,
        ),
      ),
      SizedBox(width: 40), // Adjust the spacing as needed
    ],
  ),
)

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
                  child: Scrollbar(
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
                          // Info Rows
                          _buildInfoRow(Icons.location_on, event.location, "Location"),
                          _buildInfoRow(Icons.calendar_today, event.date, "Date"),
                          _buildInfoRow(Icons.access_time, event.time, "Time"),
                          _buildInfoRow(Icons.person, "${event.NumberOfAttendees}", "Attendees"),
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
                                backgroundColor: Color.fromARGB(255, 255, 255, 255),
                                shadowColor: Color.fromARGB(255, 91, 79, 158),
                                elevation: 3,
                                labelStyle: TextStyle(
                                  color: Color.fromARGB(255, 91, 79, 158),
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
                            child: SizedBox(
                              height: 55, //height of button
                              width: 190,
                              child: ElevatedButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return CustomDialog(
                                        event: event,
                                        parentContext: context,
                                        sponsorId: sponsorID,
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
                                //  primary: Color(0xFF6A62B6),
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
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 40,
            color: Color.fromARGB(255, 91, 79, 158),
          ),
          SizedBox(width: 10), // Adjust the spacing as needed
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              Text(
                text,
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}






class CustomDialog extends StatefulWidget {
  final Event event;
  final BuildContext? parentContext;
  final String? sponsorId;

  CustomDialog({
    required this.event,
    this.parentContext,
    required this.sponsorId,
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
        return Theme(
            data: Theme.of(context).copyWith(dialogBackgroundColor: Colors.white),
            child:
      AlertDialog(
          title: Text('Empty Offer'),
          // backgroundColor: Colors.white,
          content: Text(
              'Please select at least one category before sending the offer',style: TextStyle(fontSize: 20),),
          actions: [
             TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
              },
              child:const  Text('OK',style: TextStyle(color:Color.fromARGB(255,51,45,81), fontSize: 20),),
            ),
          ],
        ));
      },
    );
  }

  void _sendOffer() async {
    if (filters.isEmpty) {
      _showEmptyFormAlert();
    } else {
      List<String> selectedCategories = filters
          .map((category) => category.toString().split('.').last)
          .toList();

      // Create an Offer object
      Offer offer = Offer(
        EventId: widget.event.EventId,
        sponseeId: widget.event.sponseeId,
        sponsorId: widget.sponsorId ?? "", // Replace with the actual sponsor ID
        notes: notesController.text,
        Category: selectedCategories,
      );

      // Save the offer to the database
      DatabaseReference offersRef = database.child('offers');
      DatabaseReference newOfferRef = offersRef.push();

      await newOfferRef.set({
        "eventID": offer.EventId,
        "sponseeId": offer.sponseeId,
        "sponsorId": offer.sponsorId,
        "notes": offer.notes,
        "Filter": offer.Category,
      });

      setState(() {
        filters.clear();
      });
      Navigator.of(context).pop();
      showDialog(
                      context: context,
                      builder: (context) {
                        Future.delayed(Duration(seconds: 3), () {
                          Navigator.of(context).pop(true);
                        });
                        return Theme(
            data: Theme.of(context).copyWith(dialogBackgroundColor: Colors.white),
            child: AlertDialog(
                          content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Color.fromARGB(255, 91, 79, 158),
                                    size: 48,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Your offer was sent successfully!',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                        ));
                      }); 
                      child: Text(
                        'Send Offer',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      );
    }
  }

@override
Widget build(BuildContext context) {
  return Dialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 51, 45, 81),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'Offer',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  color: Colors.white,
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white, // Changed to white
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(children: [
                  Text(
                    'What do you want to offer?',
                    style: TextStyle(
                      fontSize: 23,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: 5),
                  Text(
                    '(*)',
                    style: TextStyle(
                      color: Color.fromARGB(255, 51, 45, 81),
                      fontSize: 18 ,
                    ),
                  ),],),
                  Wrap(
                    spacing: 9.0,
                    children: widget.event.Category.map((category) {
                      return FilterChip(
                        label: Text(
                          category,
                          style: TextStyle(color: Colors.white),
                        ),
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
                        backgroundColor: Color.fromARGB(255, 202, 202, 204),
                        labelStyle: TextStyle(
                          color: Color(0xFF4A42A1),
                        ),
                        elevation: 3,
                        selectedColor: Color(0xFF4A42A1),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 17),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                        width: 1.0,
                        
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: TextField(
                        controller: notesController,
                        maxLength: 600,
                        decoration: InputDecoration(
                          hintText: 'Enter notes or additional information',
                          border: InputBorder.none,
                        ),
                        style: TextStyle(fontSize: 20),
                        maxLines: 9,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        _sendOffer();
                          },
                      child: Text(
                        'Send Offer',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                         primary: Color.fromARGB(255, 91, 79, 158),
                        onPrimary: Colors.white,
                        elevation: 20,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}



}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
  ));
}
