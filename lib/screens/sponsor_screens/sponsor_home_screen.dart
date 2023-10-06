import 'dart:math';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:sponsite/screens/sponsee_screens/sponsee_home_screen.dart';
import 'package:sponsite/screens/sponsor_screens/sendOffer.dart';

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
  final String NumberOfAttendees;
  final String timeStamp;
  String sponseeImage;
  String sponseeName;

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
    required this.notes,
    this.benefits,
    required this.NumberOfAttendees,
    required this.timeStamp,
    required this.sponseeImage,
    required this.sponseeName,
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
      ..quadraticBezierTo(
          controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy)
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
  String? mtoken = " ";
  User? user = FirebaseAuth.instance.currentUser;

  void check() {
    if (user != null) {
      sponsorID = user?.uid;
      print('Sponsor ID: $sponsorID');
    } else {
      print('User is not logged in.');
    }
  }

  void setUpPushNotifications() async {
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission();
  }

  @override
  void initState() {
    super.initState();
    check();
    setUpPushNotifications();
    _loadEventsFromFirebase();
  }

  void _loadEventsFromFirebase() async {
    final DatabaseReference database = FirebaseDatabase.instance.ref();
    Map<String, String> sponseeNames = {};
    Map<String, String> sponseeImages = {};

    database.child('sponseeEvents').onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          events.clear();
          Map<dynamic, dynamic> eventData =
              event.snapshot.value as Map<dynamic, dynamic>;

          eventData.forEach((key, value) {
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
                notes:
                    value['Notes'] as String? ?? 'There are no notes available',
                benefits: value['Benefits'] as String?,
                NumberOfAttendees: value['NumberOfAttendees'] as String? ?? '',
                timeStamp: timestampString,
                sponseeImage: '',
                sponseeName: '',
              ));
            }
          });
          events.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));
        });
        database.child('Sponsees').onValue.listen((sponsee) {
          if (sponsee.snapshot.value != null) {
            Map<dynamic, dynamic> sponsorData =
                sponsee.snapshot.value as Map<dynamic, dynamic>;

            sponsorData.forEach((key, value) {
              sponseeNames[key] = value['Name'] as String? ?? '';
              sponseeImages[key] = value['Picture'] as String? ?? '';
            });

            for (var event in events) {
              event.sponseeName = sponseeNames[event.sponseeId] ?? '';
              event.sponseeImage = sponseeImages[event.sponseeId] ?? '';
            }
          }
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
          width: 300, // Set the desired fixed width
          child: Card(
            elevation: 0,
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(25),
                image: DecorationImage(
                  image: event.imgURL.isNotEmpty
                      ? NetworkImage(event.imgURL)
                      : const NetworkImage(
                          'https://media.istockphoto.com/id/1369748264/vector/abstract-white-background-geometric-texture.jpg?s=612x612&w=0&k=20&c=wFsN0D9Ifrw1-U8284OdjN25JJwvV9iKi9DdzVyMHEk='),
                  fit: BoxFit.cover,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(7, 5, 0, 0),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
            ),
          ));
    }).toList();

    return Scaffold(
      body: SingleChildScrollView(
        physics:
            const AlwaysScrollableScrollPhysics(), // Wrap your content in SingleChildScrollView to enable scrolling
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
                              style: TextStyle(
                                  color: Color.fromARGB(255, 91, 79, 158)),
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
                        height:
                            170, // You can adjust this value to control the height
                        aspectRatio:
                            1.7, // Set your desired aspect ratio for width and height
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
                          padding: EdgeInsets.only(
                              left: 16), // Add left padding to the title
                          child: Text(
                            "Recent Events",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                              color: Color.fromARGB(
                                  255, 91, 79, 158), // Changed to purple
                            ),
                          ),
                        ), // Add a comma here
                        Positioned(
                          top: kToolbarHeight +
                              40, // Adjust the top position as needed
                          right: 16, // Adjust the right position as needed
                          child: IconButton(
                            icon: const Icon(Icons.filter_list,
                                color: Colors.grey), // Customize the icon
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
            SizedBox(
              height: screenHeight - 580,
              child: Scrollbar(
                // Set this to true to always show the scrollbar
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12.0, 0),
                  shrinkWrap:
                      true, // Add this to allow GridView to scroll inside SingleChildScrollView
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
                              builder: (context) => RecentEventsDetails(
                                sponsorID: sponsorID,
                                EventId: event.EventId,
                                sponseeId: event.sponseeId,
                                EventName: event.EventName,
                                EventType: event.EventType,
                                location: event.location,
                                imgURL: event.imgURL,
                                startDate: event.startDate,
                                endDate: event.endDate,
                                startTime: event.startTime,
                                endTime: event.endTime,
                                Category: event.Category,
                                notes: event.notes,
                                benefits: event.benefits,
                                NumberOfAttendees: event.NumberOfAttendees,
                                timeStamp: event.timeStamp,
                                sponseeImage: event.sponseeImage,
                                sponseeName: event.sponseeName,
                              ),
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
                                height: screenHeight * 0.14,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
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
                                    color: Colors.white,
                                    borderRadius: BorderRadius.vertical(
                                      bottom: Radius.circular(30),
                                    )),
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
                                          color:
                                              Color.fromARGB(255, 91, 79, 158),
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
                                        if (event.NumberOfAttendees != null &&
                                            event.NumberOfAttendees.isNotEmpty)
                                          const Icon(
                                            Icons.people,
                                            size: 21,
                                            color: Color.fromARGB(
                                                255, 91, 79, 158),
                                          ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            event.NumberOfAttendees,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              color:
                                                  Color.fromARGB(255, 0, 0, 0),
                                            ),
                                            overflow: TextOverflow
                                                .ellipsis, // Add this line
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
                                        children:
                                            event.Category.map((category) {
                                          return Chip(
                                            label: Text(category),
                                            backgroundColor:
                                                const Color.fromARGB(
                                                    255, 255, 255, 255),
                                            shadowColor: const Color.fromARGB(
                                                255, 91, 79, 158),
                                            elevation: 3,
                                            labelStyle: const TextStyle(
                                              color: Color.fromARGB(
                                                  255, 91, 79, 158),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                    const SizedBox(
                                        height: 10), // Add some space
                                    const Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          'more details',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontStyle: FontStyle.italic,
                                            color: Color.fromARGB(
                                                255, 91, 79, 158),
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward,
                                          size: 16, // Adjust the size as needed
                                          color:
                                              Color.fromARGB(255, 91, 79, 158),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                        height:
                                            41.9), // Add some space at the bottom
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ));
                  },
                ),
              ),
            )
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
              color: isSelected
                  ? const Color.fromARGB(255, 91, 79, 158)
                  : Colors.grey, // Button color
              decoration: isSelected ? TextDecoration.underline : null,
              decorationColor:
                  const Color.fromARGB(255, 91, 79, 158), // Button color
              decorationThickness: 2,
            ),
          ),
          const SizedBox(height: 2),
          isSelected
              ? Container(
                  width: 30,
                  height: 2,
                  color: const Color.fromARGB(255, 91, 79, 158), // Button color
                )
              : const SizedBox(height: 2),
        ],
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MaterialApp());
}
