import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:carousel_slider/carousel_slider.dart';
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
  final String? notes;
  final String? benefits;

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
    this.notes,
    this.benefits,
  });
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
              imgURL: value['img'] as String? ?? '',
              date: value['Date'] as String? ?? '',
              time: value['Time'] as String? ?? ' ',
              Category: categoryList,
              notes: value['Notes'] as String?,
              benefits: value['Benefits'] as String?,
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
      return SizedBox(
      height: 220, 
      child:  Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 140, 99, 133), // Customize the card background color
          borderRadius: BorderRadius.circular(30),

        
        ),
        padding: EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ' ${event.EventName}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24, // Increased title font size
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12), // Increased the height between title and description
            Text(
              '${event.EventType}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18, // Increased description font size
              ),
            ),
            SizedBox(height: 12), // Increased the height between title and description
            Text(
              '${event.location}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15, // Increased description font size
              ),
            ),
          ],
        ),
      ),);
    }).toList();

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 255, 255, 255),
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
                            style: TextStyle(color: Color(0xFF5B4F9E)), // Button color
                            decoration: InputDecoration(
                              hintText: 'Search for an event',
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        Icon(Icons.search, color: Color(0xFF5B4F9E)), // Button color
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 255, 255, 255),
            ),
            child: Column(
              children: [
                SizedBox(height: 14),
                CarouselSlider(
                  items: promoCards,
                  options: CarouselOptions(
                    height: 150,
                    aspectRatio: 1.5,
                    autoPlay: true,
                    enlargeCenterPage: true,
                    autoPlayInterval: Duration(seconds: 3),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Recent Events",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        color: Color(0xFF5B4F9E), // Button color
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.filter_list,
                             color: Colors.white, // Button color
                          ),
                          onPressed: () {
                            // Handle filter action
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),
              ],
            ),
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
          Expanded(
            child: GridView.builder(
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
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color : Color.fromARGB(255, 255, 255, 255),//cards color 

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: screenHeight * 0.17,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                            image: DecorationImage(
                              image: NetworkImage(event.imgURL),
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
                                    color : Color.fromARGB(255, 91, 79, 158),
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
                              SizedBox(height: 10),
                              Wrap(
                              spacing: 4,
  children: event.Category.map((category) {
    return Chip(
      label: Text(category),
      backgroundColor: Colors.white,
      shadowColor: Color.fromARGB(255, 235, 140, 140), // Button color
      elevation: 3,
      shape: RoundedRectangleBorder(
        // Set the border to none
        borderRadius: BorderRadius.circular(20), // Adjust the border radius as needed
      ),
    );
  }).toList(),
),
  
                              SizedBox(height: 10),

                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const BottomNavBar(),
        ],
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
              color: isSelected ? Color(0xFF5B4F9E) : Colors.grey, // Button color
              decoration: isSelected ? TextDecoration.underline : null,
              decorationColor: Color(0xFF5B4F9E), // Button color
              decorationThickness: 2,
            ),
          ),
          SizedBox(height: 2),
          isSelected
              ? Container(
                  width: 30,
                  height: 2,
                  color: Color(0xFF5B4F9E), // Button color
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
              Image.network(
                event.imgURL,
                height: 400,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back),
                      color: Color(0xFF5B4F9E), // Button color
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    Text(
                      "Event Details",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
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
                              color: Color(0xFF5B4F9E), // Button color
                            ),
                            SizedBox(width: 4),
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
                              Icons.access_time,
                              size: 25,
                              color: Colors.purple,
                            ),
                            SizedBox(width: 4),
                            Text(
                              "${event.date}, ${event.time}",
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
                          spacing: 8,
                          children: event.Category.map((category) {
                            return Chip(
                              label: Text(category),
                              backgroundColor: Color(0xFF5B4F9E), // Button color
                              shadowColor: Color(0xFF5B4F9E), // Button color
                              elevation: 3,
                              labelStyle: TextStyle(
                                color: Colors.white,
                              ),
                            );
                          }).toList(),
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
                          event.notes ?? "No notes available",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black87,
                          ),
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
                        Center(
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
                              'Send an offer',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: Color(0xFF5B4F9E), // Button color
                              onPrimary: Colors.white,
                              elevation: 10,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
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
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                primary: Color(0xFF5B4F9E), // Button color
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
                    backgroundColor: Color(0xFF5B4F9E), // Button color
                    selectedColor: Color(0xFF5B4F9E), // Button color
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
                        color: Color(0xFF5B4F9E), width: 2.0), // Button color
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
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                primary: Color(0xFF5B4F9E), // Button color
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
    home: user != null ? SponsorHomePage() : Login(),
  ));
}

class Login extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 40.0, left: 15.0),
            child: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          SizedBox(height: 50.0),
          Center(
            child: Text(
              'Login',
              style: TextStyle(
                fontSize: 36.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5B4F9E), // Button color
              ),
            ),
          ),
          SizedBox(height: 30.0),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.0),
            child: Column(
              children: [
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: 'Email',
                  ),
                ),
                SizedBox(height: 20.0),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Password',
                  ),
                ),
                SizedBox(height: 30.0),
                ElevatedButton(
                  onPressed: () {
                    // Implement login logic here
                  },
                  child: Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF5B4F9E), // Button color
                    onPrimary: Colors.white,
                    elevation: 20,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                TextButton(
                  onPressed: () {
                    // Implement forgot password logic here
                  },
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: Color(0xFF5B4F9E), // Button color
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
