import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:carousel_slider/carousel_slider.dart';

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
  final String startDate;
  final String endDate;
  final String startTime;
  final String endTime;
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
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
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
  const SponsorHomePage({super.key});

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
          String eventStartDatestring = value['startDate'];
          String eventEndtDatestring = value['endDate'];
          DateTime? eventStartDate = DateTime.tryParse(eventStartDatestring);
          DateTime? eventEndDate = DateTime.tryParse(eventEndtDatestring);

          // Simulate the current time (for testing purposes)
          DateTime currentTime = DateTime.now();

      
          if (eventStartDate!.isAfter(currentTime)) {
            events.add(Event(
              EventId: key,
              sponseeId: value['SponseeID'] as String? ?? '',
              EventName: value['EventName'] as String? ?? '',
              EventType: value['EventType'] as String? ?? '',
              location: value['Location'] as String? ?? '',
              imgURL: value['img'] as String? ?? "",
              startDate: value['startDate'] as String? ?? '',
              endDate: value['endDate'] as String? ?? '',
              startTime: value['startTime'] as String? ?? ' ',
              endTime: value['endTime'] as String? ?? ' ',
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
Set<int> displayedEventIDs = <int>{};
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
    return SizedBox(
    height: 220, // Set the desired fixed height
    width: 300,  // Set the desired fixed width
    child: Card(
      elevation: 0, 
      child: Container(
      decoration: BoxDecoration(
       color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(25),
        image: DecorationImage(
        image: event.imgURL.isNotEmpty
        ? NetworkImage(event.imgURL)
         : const NetworkImage('https://media.istockphoto.com/id/1369748264/vector/abstract-white-background-geometric-texture.jpg?s=612x612&w=0&k=20&c=wFsN0D9Ifrw1-U8284OdjN25JJwvV9iKi9DdzVyMHEk='),
         fit: BoxFit.cover,
         ),
                              ),
        padding: const EdgeInsets.fromLTRB(7, 5, 0, 0),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
      ),));
    }).toList();


  return Scaffold(
  body:SingleChildScrollView( 
        physics: const AlwaysScrollableScrollPhysics(),// Wrap your content in SingleChildScrollView to enable scrolling
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 51, 45, 81),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 33),
                  Center(
                    child: Container(
                      width: 430,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(0, 255, 255, 255),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromARGB(96, 158, 158, 158),
                            offset: Offset(0, 2),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      child: const Row(
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
                  const SizedBox(height: 40),
                ],
              ),
            ),
      Stack(
  children: [
    Container(
      height: 200,
      color: const Color.fromARGB(255, 255, 255, 255),
    ),
   ClipPath(
  clipper: CurveClipper(),
  child: Container(
     decoration: const BoxDecoration(
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
                  const SizedBox(height: 20),
                  CarouselSlider(
                    items: promoCards,
                    options: CarouselOptions(
                      height: 170,// You can adjust this value to control the height
                      aspectRatio: 1.7, // Set your desired aspect ratio for width and height
                      autoPlay: true,
                      enlargeCenterPage: true,
                      autoPlayInterval: const Duration(seconds: 3),
                    ),
                  ),
                  const SizedBox(height: 80),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                    
  const Padding(
    padding: EdgeInsets.only(left: 16), // Add left padding to the title
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
          icon: const Icon(Icons.filter_list, color: Colors.grey), // Customize the icon
          onPressed: () {
            // Add your filter functionality here
          },
        ),
      ),
  
],

                  ),
                  const SizedBox(height: 16),
                ],
              ),
             ],
),
          Container(
  height: 40,
  padding: const EdgeInsets.symmetric(horizontal: 16),
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
              SizedBox(height: screenHeight-590,
              child:   Scrollbar(// Set this to true to always show the scrollbar
              child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(12,0,12.0,0), 
              shrinkWrap: true, // Add this to allow GridView to scroll inside SingleChildScrollView
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        height: screenHeight * 0.15,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(16),
          ),
          image: DecorationImage(
            image: event.imgURL.isNotEmpty
                ? NetworkImage(event.imgURL)
                : const NetworkImage('https://media.istockphoto.com/id/1369748264/vector/abstract-white-background-geometric-texture.jpg?s=612x612&w=0&k=20&c=wFsN0D9Ifrw1-U8284OdjN25JJwvV9iKi9DdzVyMHEk='),
            fit: BoxFit.cover,
          ),
        ),
      ),
      Container(
        decoration: const BoxDecoration(borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),)),
        //color: Colors.white, // Set the background color to white
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.EventName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: Color.fromARGB(255, 91, 79, 158),
                ),
                const SizedBox(width: 4),
                Text(
                  "${event.startDate} - ${event.endDate}",
                  style: TextStyle(
                    fontSize: 18,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 21,
                  color: Color.fromARGB(255, 91, 79, 158),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    event.location,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                    overflow: TextOverflow.ellipsis, // Add this line
                    maxLines: 1, // Add this line
                  ),
                )
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
             height: 100,
            child: Wrap(
              spacing: 4,
              children: event.Category.map((category) {
                return Chip(
                  label: Text(category),
                  backgroundColor:
                  const Color.fromARGB(255, 255, 255, 255),
                  shadowColor:const Color.fromARGB(255, 91, 79, 158),
                  elevation: 3,
                  labelStyle: const TextStyle(
                    color: Color.fromARGB(255, 91, 79, 158),
                  ),
                );
              }).toList(),
            ),),
            const SizedBox(height: 10), // Add some space
            const Row(
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
             const SizedBox(height: 20.5), // Add some space at the bottom
          ],
        ),
      ),
    ],
  ),

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
              color: isSelected ? const Color.fromARGB(255,91,79,158) : Colors.grey, // Button color
              decoration: isSelected ? TextDecoration.underline : null,
              decorationColor: const Color.fromARGB(255,91,79,158), // Button color
              decorationThickness: 2,
            ),
          ),
          const SizedBox(height: 2),
          isSelected
              ? Container(
                  width: 30,
                  height: 2,
                  color: const Color.fromARGB(255,91,79,158), // Button color
                )
              : const SizedBox(height: 2),
        ],
      ),
    );
  }
}

class RecentEventsDetails extends StatelessWidget {
  final Event event;

  const RecentEventsDetails({super.key, required this.event});

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
                  color: const Color.fromARGB(255, 51, 45, 81),
                  image: DecorationImage(
                    image: event.imgURL.isNotEmpty
                        ? NetworkImage(event.imgURL)
                        : const NetworkImage(
                            'https://media.istockphoto.com/id/1369748264/vector/abstract-white-background-geometric-texture.jpg?s=612x612&w=0&k=20&c=wFsN0D9Ifrw1-U8284OdjN25JJwvV9iKi9DdzVyMHEk='),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
  decoration: const BoxDecoration(
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
        icon: const Icon(Icons.arrow_back),
        color: Colors.white,
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      const Text(
        "Event Details",
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 24,
          color: Colors.white,
        ),
      ),
      const SizedBox(width: 40), // Adjust the spacing as needed
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
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
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
                          const SizedBox(height: 20),
                          Text(
                            event.EventName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 32,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            event.EventType,
                            style: const TextStyle(
                              fontSize: 22,
                              color: Colors.black87,
                            ),
                          ),
                          const Divider(height: 30, thickness: 2),
                          // Info Rows
                          _buildInfoRow(Icons.location_on, event.location, "Location"),
                          _buildInfoRow(Icons.calendar_today, "${event.startDate} - ${event.endDate}", "Date"),
                          _buildInfoRow(Icons.access_time, "${event.startTime}-${event.endTime}", "Time"),
                          _buildInfoRow(Icons.person, event.NumberOfAttendees, "Attendees"),
                          const SizedBox(height: 20),
                  
                          const Text(
                            "Categories",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 4,
                            children: event.Category.map((category) {
                              return Chip(
                                label: Text(category),
                                backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                                shadowColor: const Color.fromARGB(255, 91, 79, 158),
                                elevation: 3,
                                labelStyle: const TextStyle(
                                  color: Color.fromARGB(255, 91, 79, 158),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),
                  
                          const Text(
                            "Benefits",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            event.benefits ?? "No benefits available",
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 20),
                  
                          const Text(
                            "Notes",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            (event.notes.isNotEmpty)
                                ? event.notes
                                : "There are no notes available",
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 20),
                  
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
                                style: ElevatedButton.styleFrom(
                                 backgroundColor: const Color.fromARGB(255, 91, 79, 158),
                                //  primary: Color(0xFF6A62B6),
                                  elevation: 10,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: const Text(
                                  'Send offer',
                                  style: TextStyle(
                                    fontSize: 25,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
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
            color: const Color.fromARGB(255, 91, 79, 158),
          ),
          const SizedBox(width: 10), // Adjust the spacing as needed
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              Text(
                text,
                style: const TextStyle(
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

  const CustomDialog({super.key, 
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
          title: const Text('Empty Offer'),
          // backgroundColor: Colors.white,
          content: const Text(
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
                        Future.delayed(const Duration(seconds: 3), () {
                          Navigator.of(context).pop(true);
                        });
                        return Theme(
            data: Theme.of(context).copyWith(dialogBackgroundColor: Colors.white),
            child: const AlertDialog(
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
                      child: const Text(
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
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 51, 45, 81),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Padding(
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
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  color: Colors.white,
                ),
              ],
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.white, // Changed to white
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Row(children: [
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
                          style: const TextStyle(color: Colors.white),
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
                        backgroundColor: const Color.fromARGB(255, 202, 202, 204),
                        labelStyle: const TextStyle(
                          color: Color(0xFF4A42A1),
                        ),
                        elevation: 3,
                        selectedColor: const Color(0xFF4A42A1),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 17),
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
                        decoration: const InputDecoration(
                          hintText: 'Enter notes or additional information',
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(fontSize: 20),
                        maxLines: 9,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        _sendOffer();
                          },
                      style: ElevatedButton.styleFrom(
                         foregroundColor: Colors.white, backgroundColor: const Color.fromARGB(255, 91, 79, 158),
                        elevation: 20,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Send Offer',
                        style: TextStyle(
                          fontSize: 20,
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
  runApp(const MaterialApp(
  ));
}
