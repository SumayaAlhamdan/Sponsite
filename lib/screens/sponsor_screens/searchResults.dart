import 'dart:math';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:googleapis/cloudsearch/v1.dart';
import 'package:sponsite/screens/sponsee_screens/sponsee_home_screen.dart';
import 'package:sponsite/screens/sponsor_screens/filter.dart';
import 'package:sponsite/screens/sponsor_screens/sendOffer.dart';
import 'package:sponsite/screens/sponsor_screens/sponsor_home_screen.dart';
import 'package:sponsite/screens/view_others_profile.dart';
import 'package:sponsite/widgets/sponsor_botton_navbar.dart';
import 'dart:async';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:googleapis/streetviewpublish/v1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  String City;

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
    required this.City,
  });
}

class ResultPage extends StatefulWidget {
  final String searchText;

  ResultPage({Key? key, required this.searchText}) : super(key: key);

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  List<Event> events = [];
  String selectedCategory = 'All';
  String? mtoken = " ";
  User? user = FirebaseAuth.instance.currentUser;
  TextEditingController searchController = TextEditingController();
  List<Event> searchedEvents = []; // List to store searched events
  String originalSearchText =
      ''; // Create a variable to store the original search text
  int minAttendees = 0;
  int maxAttendees = 200000;
  List<String> selectedCategories = [];
  int FminAttendees = 0;
  int FmaxAttendees = 200000;
  List<String> FselectedCategories = [];
  List<String> FselectedCities = [];
  List<String> eventTypesList = [];
  List<Map<String, dynamic>> sponsors = [];
  List<Map<String, dynamic>> sponsees = [];
  List<Map<String, dynamic>> filteredSponsors = [];
  List<Map<String, dynamic>> filteredSponsees = [];
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  Future<List<String>> fetchEventTypes() async {
    final eventTypes = <String>[];

    try {
      final DatabaseEvent dataSnapshot =
          await FirebaseDatabase.instance.reference().child('EventType').once();

      if (dataSnapshot.snapshot.value != null) {
        final Map<dynamic, dynamic> eventTypesMap =
            dataSnapshot.snapshot.value as Map<dynamic, dynamic>;

        eventTypesMap.forEach((key, value) {
          eventTypes.add(value.toString());
        });
      }
    } catch (e) {
      print('Error fetching event types: $e');
    }

    return eventTypes;
  }

  Future<void> fetchEventTypesFromDatabase() async {
    final eventTypes = await fetchEventTypes();

    // Prepend "All" to the eventTypesList
    eventTypes.insert(0, "All");

    setState(() {
      eventTypesList = eventTypes;
      print("all index" + eventTypesList[0]);
    });
  }

  void _searchEventsByName(String eventName) {
    // Filter events based on the first letters of every word in the event name
    searchedEvents = events.where((event) {
      final words = event.EventName.split(' ');
      for (final word in words) {
        if (word.isNotEmpty &&
            word.toLowerCase().startsWith(eventName.toLowerCase())) {
          return true;
        }
      }
      return false;
    }).toList();
    if (selectedCategory != "All")
      searchedEvents = searchedEvents
          .where((event) => event.EventType == selectedCategory)
          .toList();
  }

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
    searchController = TextEditingController();
    searchController.text = widget.searchText;
    originalSearchText = widget.searchText;
    fetchEventTypesFromDatabase();
    fetchSponsors().listen((sponsorsData) {
      setState(() {
        sponsors = sponsorsData;
        filteredSponsors = sponsors;
      });
    });
    fetchSponsees().listen((sponseesData) {
      setState(() {
        sponsees = sponseesData;
        filteredSponsees = sponsees;
      });
    });
  }

  Stream<List<Map<String, dynamic>>> fetchSponsors() {
    DatabaseReference sponRef = _database.child('Sponsors');
    return sponRef.onValue.map(
      (event) {
        List<Map<String, dynamic>> Sponsors = [];
        DataSnapshot dataSnapshot = event.snapshot;

        try {
          if (dataSnapshot.value != null) {
            Map<dynamic, dynamic>? dataMap = dataSnapshot.value as Map?;

            if (dataMap != null) {
              dataMap.forEach((key, value) async {
                if (value is Map<dynamic, dynamic>) {
                  Map<String, dynamic> data = {
                    'ID': key,
                    'Name': value['Name'] ?? '',
                    'Email': value['Email'] ?? '',
                    'Bio': value['Bio'] ?? '',
                    'Picture': value['Picture'],
                    'Type': 'Sponsor',
                    'Deleted': value['Deleted'] ?? false,
                  };
                  if (user?.uid == data['ID'] || data['Deleted']) {
                  } else {
                    Sponsors.add(data);
                  }
                }
              });
            }
          }
        } catch (e) {
          print('Error occurred: $e');
        }
        print(Sponsors);
        return Sponsors;
      },
    );
  }

  Stream<List<Map<String, dynamic>>> fetchSponsees() {
    DatabaseReference sponRef = _database.child('Sponsees');
    return sponRef.onValue.map(
      (event) {
        List<Map<String, dynamic>> Sponsees = [];
        DataSnapshot dataSnapshot = event.snapshot;

        try {
          if (dataSnapshot.value != null) {
            Map<dynamic, dynamic>? dataMap = dataSnapshot.value as Map?;

            if (dataMap != null) {
              dataMap.forEach((key, value) async {
                if (value is Map<dynamic, dynamic>) {
                  Map<String, dynamic> data = {
                    'ID': key,
                    'Name': value['Name'] ?? '',
                    'Email': value['Email'] ?? '',
                    'Bio': value['Bio'] ?? '',
                    'Picture': value['Picture'],
                    'Type': 'Sponsee',
                    'Deleted': value['Deleted'] ?? false,
                  };
                  if (user?.uid == data['ID'] || data['Deleted']) {
                    print('deleted or user');
                  } else {
                    Sponsees.add(data);
                  }
                }
              });
            }
          }
        } catch (e) {
          print('Error occurred: $e');
        }
        return Sponsees;
      },
    );
  }

  void filterUsers(String searchText) {
    // Trim leading and trailing whitespaces from the input text
    searchText = searchText.trim();

    // Update the state to trigger a rebuild with the filtered data
    setState(() {
      // Filter sponsors based on the 'Name' property
      filteredSponsors = sponsors.where((user) {
        final words = user['Name']?.split(' ') ?? [];
        return words.any((word) =>
            word.isNotEmpty &&
            word.toLowerCase().startsWith(searchText.toLowerCase()));
      }).toList();

      // Filter sponsees based on the 'Name' property
      filteredSponsees = sponsees.where((user) {
        final words = user['Name']?.split(' ') ?? [];
        return words.any((word) =>
            word.isNotEmpty &&
            word.toLowerCase().startsWith(searchText.toLowerCase()));
      }).toList();
    });
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
            String City = value['City'];

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
                City: value['City'],
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
      print("selected category in filteredevents " + selectedCategory);

      return events;
    } else {
      print("else selected category in filteredevents " + selectedCategory);

      return events
          .where((event) => event.EventType == selectedCategory)
          .toList();
    }
  }

  bool doesContainCategory(
      List<String> eventCategories, List<String> selectedCategories) {
    for (String category in eventCategories) {
      if (selectedCategories.contains(category)) {
        return true; // At least one category matches
      }
    }
    return false; // No matching category found
  }

  bool applyFilterCriteria(Event event) {
    bool cityCriteria =
        FselectedCities.isEmpty || FselectedCities.contains(event.City);
    bool categoryCriteria = FselectedCategories.isEmpty ||
        event.Category.any((cat) => FselectedCategories.contains(cat));
    bool attendeesCriteria = event.NumberOfAttendees != null &&
            event.NumberOfAttendees.isNotEmpty &&
            int.tryParse(event.NumberOfAttendees) != null
        ? (int.tryParse(event.NumberOfAttendees)! >= FminAttendees &&
            int.tryParse(event.NumberOfAttendees)! <= FmaxAttendees)
        : false;

    return cityCriteria && categoryCriteria && attendeesCriteria;
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
    _searchEventsByName(originalSearchText);

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
                    child: Row(
                      children: [
                        IconButton(
                            icon: Icon(Icons.arrow_back,
                                color: Colors.white, size: 40),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Stack(
                                    children: [
                                      SponsorHomePage(),
                                      SponsorBottomNavBar()
                                    ],
                                  ), // Replace with your Recent Events page widget
                                ),
                              );
                            }),
                        SizedBox(
                          width: 120,
                        ),
                        Container(
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
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.search, color: Colors.grey),
                                onPressed: () {
                                  // When the search button is pressed, filter events by event name
                                  final eventName = searchController.text;
                                  _searchEventsByName(eventName);
                                  originalSearchText = eventName;

                                  // You can now display filteredEvents in your UI
                                  setState(() {});
                                },
                              ),
                              Expanded(
                                child: TextField(
                                  controller: searchController,
                                  style: TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: 'Search for an event',
                                    hintStyle: TextStyle(color: Colors.grey),
                                    border: InputBorder.none,
                                  ),
                                  onChanged: (text) {
                                    filterUsers(text);
                                  },
                                  onEditingComplete: () {
                                    String trimmedText =
                                        searchController.text.trim();
                                    searchController.text = trimmedText;
                                    filterUsers(trimmedText);
                                  },
                                  onSubmitted: (value) {
                                    // Handle the search when the user presses Enter on the keyboard
                                    _searchEventsByName(value);
                                    originalSearchText = value;

                                    // You can now display filteredEvents in your UI
                                    setState(() {});
                                  },
                                ),
                              ),
                              if (searchController.text.isNotEmpty)
                                IconButton(
                                  icon: Icon(Icons.cancel, color: Colors.grey),
                                  onPressed: () {
                                    searchController.clear();
                                    setState(() {});
                                  },
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
            SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Search results for user \"${originalSearchText}\" ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                          color: Color.fromARGB(255, 91, 79, 158),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: screenHeight - 1000,
                    child: Scrollbar(
                      child: ListView(
                        children: [
                          _buildUserList(context, filteredSponsors,
                              filteredSponsees, searchController.text),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Stack(
              children: [
                Container(
                  height: 100,
                  color: const Color.fromARGB(255, 255, 255, 255),
                ),
                Column(
                  children: [
                    const SizedBox(height: 50),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 16),
                          child: Text(
                            "Search results for event \"${originalSearchText}\" ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                              color: Color.fromARGB(255, 91, 79, 158),
                            ),
                          ),
                        ),
                        Positioned(
                          top: kToolbarHeight +
                              40, // Adjust the top position as needed
                          right: 16, // Adjust the right position as needed
                          child: IconButton(
                            icon: Icon(
                              Icons.filter_list,
                              color: (FminAttendees != 0 ||
                                      FmaxAttendees != 200000 ||
                                      FselectedCategories.isNotEmpty ||
                                      FselectedCities.isNotEmpty)
                                  ? Color.fromARGB(255, 91, 79, 158)
                                  : Colors.grey,
                            ),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return FilterDialog(
                                      onFilterApplied: (minAttendees,
                                          maxAttendees,
                                          selectedCategories,
                                          selectedCities) {
                                        setState(() {
                                          FminAttendees = minAttendees;
                                          FmaxAttendees = maxAttendees;
                                          FselectedCategories =
                                              selectedCategories;
                                          FselectedCities = selectedCities;
                                        });
                                      },
                                    );
                                  });
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
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: eventTypesList.length,
                itemBuilder: (context, index) {
                  return _buildCategoryText(index);
                },
              ),
            ),
            SizedBox(height: 3),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal, // Scroll horizontally
                  child: Row(
                    children: [
                      if (FminAttendees != 0 ||
                          FmaxAttendees != 200000 ||
                          (FselectedCategories != null &&
                              FselectedCategories.isNotEmpty) ||
                          (FselectedCities != null &&
                              FselectedCities.isNotEmpty))
                        Text(
                          'Filtered By:',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Color.fromARGB(255, 91, 79, 158),
                          ),
                        ),
                      SizedBox(width: 10),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: <Widget>[
                          if (FminAttendees != 0)
                            Chip(
                              label: Text(
                                'Min Attendees: $FminAttendees',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 91, 79, 158),
                                ),
                              ),
                            ),
                          if (FmaxAttendees != 200000)
                            Chip(
                              label: Text(
                                'Max Attendees: $FmaxAttendees',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 91, 79, 158),
                                ),
                              ),
                            ),
                          if (FselectedCategories != null &&
                              FselectedCategories.isNotEmpty)
                            Chip(
                              label: Text(
                                  'Categories: ${FselectedCategories.join(', ')}'),
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 91, 79, 158),
                              ),
                            ),
                          if (FselectedCities != null &&
                              FselectedCities.isNotEmpty)
                            Chip(
                              label:
                                  Text('Cities: ${FselectedCities.join(', ')}'),
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 91, 79, 158),
                              ),
                            ),
                        ],
                      ),
                      if (FminAttendees != 0 ||
                          FmaxAttendees != 200000 ||
                          (FselectedCategories != null &&
                              FselectedCategories.isNotEmpty) ||
                          (FselectedCities != null &&
                              FselectedCities.isNotEmpty))
                        TextButton(
                          onPressed: () {
                            setState(() {
                              FminAttendees = 0;
                              FmaxAttendees = 200000;
                              FselectedCategories = [];
                              FselectedCities = [];
                            });

                            FilterDialog filterDialog = FilterDialog(
                              onFilterApplied: (
                                int minAttendees,
                                int maxAttendees,
                                List<String> selectedCategories,
                                List<String> selectedCities,
                              ) {},
                            );
                            //     filterDialog.clearFilterValues();
                          },
                          child: Row(
                            children: [
                              Icon(Icons.close), // Trash icon
                              SizedBox(
                                  width:
                                      8), // Add some space between the icon and text
                              //  Text('Clear Filter'),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                if (searchedEvents.isNotEmpty && originalSearchText.isNotEmpty)
                  SizedBox(
                    height: screenHeight - 580,
                    child: Scrollbar(
                      // Set this to true to always show the scrollbar
                      child: GridView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12.0, 0),
                        shrinkWrap:
                            true, // Add this to allow GridView to scroll inside SingleChildScrollView
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.715,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        // itemCount: getFilteredEvents().length,
                        // itemBuilder: (context, index) {
                        //   Event event = getFilteredEvents()[index];
                        itemCount: searchedEvents.isNotEmpty
                            ? searchedEvents.length
                            : getFilteredEvents().length,
                        itemBuilder: (context, index) {
                          Event event = searchedEvents.isNotEmpty
                              ? searchedEvents[index]
                              : getFilteredEvents()[index];
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
                                      NumberOfAttendees:
                                          event.NumberOfAttendees,
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
                                        borderRadius:
                                            const BorderRadius.vertical(
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            event.EventName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                              color:
                                                  Color.fromARGB(255, 0, 0, 0),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              GestureDetector(
                                                child: CircleAvatar(
                                                  radius: 25,
                                                  backgroundImage: NetworkImage(
                                                      event.sponseeImage),
                                                  backgroundColor:
                                                      Colors.transparent,
                                                ),
                                                onTap: () {
                                                  Navigator.of(context)
                                                      .push(MaterialPageRoute(
                                                    builder: (context) =>
                                                        ViewOthersProfile(
                                                            'Sponsees',
                                                            event.sponseeId),
                                                  ));
                                                },
                                              ),

                                              SizedBox(width: 15),
                                              // Add some space between the CircleAvatar and Text
                                              GestureDetector(
                                                child: Expanded(
                                                  child: Text(
                                                    event.sponseeName,
                                                    style: const TextStyle(
                                                      fontSize: 22,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ),
                                                onTap: () {
                                                  Navigator.of(context)
                                                      .push(MaterialPageRoute(
                                                    builder: (context) =>
                                                        ViewOthersProfile(
                                                            'Sponsees',
                                                            event.sponseeId),
                                                  ));
                                                },
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),

                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.calendar_today,
                                                size: 18,
                                                color: Color.fromARGB(
                                                    255, 91, 79, 158),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                "${event.startDate} - ${event.endDate}",
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  color: Color.fromARGB(
                                                      255, 0, 0, 0),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              if (event.NumberOfAttendees !=
                                                      null &&
                                                  event.NumberOfAttendees
                                                      .isNotEmpty)
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
                                                    color: Color.fromARGB(
                                                        255, 0, 0, 0),
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
                                            height: 105,
                                            child: Wrap(
                                              spacing: 4,
                                              children: event.Category.map(
                                                  (category) {
                                                return Chip(
                                                  label: Text(category),
                                                  backgroundColor:
                                                      const Color.fromARGB(
                                                          255, 255, 255, 255),
                                                  shadowColor:
                                                      const Color.fromARGB(
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
                                              height: 8), // Add some space
                                          const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
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
                                                size:
                                                    16, // Adjust the size as needed
                                                color: Color.fromARGB(
                                                    255, 91, 79, 158),
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
                  ),
                if (searchedEvents.isEmpty ||
                    originalSearchText.isEmpty ||
                    (filteredSponsees.isEmpty && filteredSponsors.isEmpty))
                  Center(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 150,
                        ),
                        Text(
                          "No results match your search",
                          style: TextStyle(
                            fontSize: 24,
                            color: Color.fromARGB(255, 189, 189, 189),
                          ),
                        ),
                        TextButton(
                          child: Text("Go Back",
                              style: TextStyle(
                                  fontSize: 23,
                                  decoration: TextDecoration.underline)),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Stack(
                                  children: [
                                    ResultPage(
                                        searchText: searchController.text),
                                    SponsorBottomNavBar()
                                  ],
                                ), // Replace with your Recent Events page widget
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryText(int index) {
    print(index);
    print("Building category: " + eventTypesList[index]);
    print("Selected Category: " + selectedCategory);
    String category = eventTypesList[index];
    bool isSelected = selectedCategory == category;
    print("isSelected: ${isSelected}");

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = category;
          getFilteredEvents();
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: 15), // Adjust the padding as needed
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
                    color:
                        const Color.fromARGB(255, 91, 79, 158), // Button color
                  )
                : const SizedBox(height: 2),
          ],
        ),
      ),
    );
  }
}

Widget _buildUserList(
  BuildContext context,
  List<Map<String, dynamic>> sponsors,
  List<Map<String, dynamic>> sponsees,
  String searchQuery,
) {
  if (sponsors.isEmpty && sponsees.isEmpty) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'No users that matched $searchQuery',
          style: TextStyle(
            fontSize: 24,
            color: Color.fromARGB(255, 189, 189, 189),
          ),
        ),
        /*  TextButton(
          child: Text(
            "Go Back",
            style: TextStyle(
              fontSize: 23,
              decoration: TextDecoration.underline,
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ), */
      ],
    );
  }

  return Column(
    children: [
      _buildUserCategory(context, 'Sponsors', sponsors, searchQuery),
      _buildUserCategory(context, 'Sponsees', sponsees, searchQuery),
    ],
  );
}

Widget _buildUserCategory(BuildContext context, String category,
    List<Map<String, dynamic>> users, String text) {
  if (users == null || users.isEmpty) {
    return SizedBox.shrink();
  }

  if (text.isNotEmpty) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /* Text(
              category,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w500,
                color: Color.fromARGB(255, 51, 45, 81),
              ),
            ),*/
          ListView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: users.map((user) {
              String id = user['ID'] ?? 'No ID available';
              String name = user['Name'] ?? 'No name available';
              String pic = user['Picture'] ?? '';
              String bio = user['Bio'] ?? 'no bio available';
              String type = user['Type'] ?? '';

              return Card(
                color: Color.fromARGB(255, 255, 255, 255),
                child: ListTile(
                  title: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(pic),
                        backgroundColor: Colors.transparent,
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              color: Color.fromARGB(255, 51, 45, 81),
                              fontSize: 22,
                            ),
                          ),
                          SizedBox(
                              height: 4), // Add some space between name and bio
                          Text(
                            type,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 51, 45, 81),
                              fontSize: 17,
                            ),
                          ),
                          SizedBox(
                              height: 4), // Add some space between name and bio
                          Text(
                            bio.length > 65
                                ? '${bio.substring(0, 65)}...'
                                : bio,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 51, 45, 81),
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.more_vert),
                    color: Color.fromARGB(255, 91, 79, 158),
                    onPressed: () {
                      String userType =
                          (type == 'Sponsee') ? 'Sponsees' : 'Sponsors';

                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ViewOthersProfile(userType, id),
                      ));
                    },
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Return a default widget if the search input is empty
  return Text(
    '',
    style: TextStyle(
      fontSize: 16,
      color: Colors.grey,
    ),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MaterialApp());
}

class FilterDialog extends StatefulWidget {
  final Function(
    int minAttendees,
    int maxAttendees,
    List<String> selectedCategories,
    List<String> selectedCities,
  ) onFilterApplied;

  FilterDialog({required this.onFilterApplied});

  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  int _minValue = 0;
  int _maxValue = 200000;
  bool _locationSelected = false;
  String _selectedCity = '';
  List<String> _categories = [];
  List<String> _cities = [];
  List<String> _selectedCategories = [];
  List<String> _selectedCities = [];
  List<bool> _checkboxValues = [];
  List<bool> _cityCheckboxValues = [];
  TextEditingController searchController = TextEditingController();
  String? selectedAddressDescription;

  final places = GoogleMapsPlaces(
    apiKey:
        'AIzaSyD6Qb46BjUA0NQlicbMO3uznD495RLGyuU', // Replace with your Google Maps API key
  );
  Prediction? selectedPrediction;

  void initState() {
    super.initState();
    initCategories();
    initCities();
    loadFilterValues();
  }

  Future<void> initCategories() async {
    final databaseReference = FirebaseDatabase.instance.reference();
    DatabaseReference categoriesRef = databaseReference.child('Categories');

    categoriesRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> categoriesMap =
            event.snapshot.value as Map<dynamic, dynamic>;
        List<String> categories =
            categoriesMap.values.map((value) => value as String).toList();

        setState(() {
          _categories = categories;
          _checkboxValues = List.generate(_categories.length, (_) => false);
        });
      }
    });
  }

  Future<void> initCities() async {
    final databaseReference = FirebaseDatabase.instance.reference();
    DatabaseReference citiesRef = databaseReference.child('Cities');

    citiesRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> citiesMap =
            event.snapshot.value as Map<dynamic, dynamic>;
        List<String> cities =
            citiesMap.values.map((value) => value as String).toList();

        setState(() {
          // Check for duplicates and add new cities
          for (var city in cities) {
            if (!_cities.contains(city)) {
              _cities.add(city);
              _cityCheckboxValues.add(false);
            }
          }
        });
      }
    });
  }

  Future<void> loadFilterValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _minValue = prefs.getInt('minValue') ?? 0;
      _maxValue = prefs.getInt('maxValue') ?? 200000;
      _locationSelected = prefs.getBool('locationSelected') ?? false;
      _selectedCity = prefs.getString('selectedCity') ?? '';
      _selectedCategories = prefs.getStringList('selectedCategories') ?? [];
      _selectedCities = prefs.getStringList('selectedCities') ?? [];

      _selectedCategories.forEach((category) {
        int index = _categories.indexOf(category);
        if (index >= 0) {
          _checkboxValues[index] = true;
        }
      });

      _selectedCities.forEach((city) {
        int index = _cities.indexOf(city);
        if (index >= 0) {
          _cityCheckboxValues[index] = true;
        }
      });
    });
  }

  Future<void> saveFilterValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('minValue', _minValue);
    prefs.setInt('maxValue', _maxValue);
    prefs.setBool('locationSelected', _locationSelected);
    prefs.setString('selectedCity', _selectedCity);
    prefs.setStringList('selectedCategories', _selectedCategories);
    prefs.setStringList('selectedCities', _selectedCities);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: Text('Filter Events'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Number of Attendees (Min and Max)'),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Min'),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(),
                      controller:
                          TextEditingController(text: _minValue.toString()),
                      onChanged: (value) {
                        try {
                          int min = int.parse(value);
                          setState(() {
                            _minValue = min;
                          });
                        } catch (e) {
                          print('Error parsing Min: $e');
                        }
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Max'),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(),
                      controller:
                          TextEditingController(text: _maxValue.toString()),
                      onChanged: (value) {
                        try {
                          int max = int.parse(value);
                          setState(() {
                            _maxValue = max;
                          });
                        } catch (e) {
                          print('Error parsing Max: $e');
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          RangeSlider(
            values: RangeValues(_minValue.toDouble(), _maxValue.toDouble()),
            min: 0,
            max: 200000,
            onChanged: (RangeValues values) {
              try {
                setState(() {
                  _minValue = values.start.toInt();
                  _maxValue = values.end.toInt();
                });
              } catch (e) {
                print('Error handling RangeSlider values: $e');
              }
            },
          ),
          SizedBox(height: 16),
          Text('Select Categories'),
          Column(
            children: _categories.asMap().entries.map((entry) {
              final index = entry.key;
              final category = entry.value;

              return CheckboxListTile(
                title: Text(category),
                value: _selectedCategories.contains(category),
                onChanged: (bool? value) {
                  setState(() {
                    _checkboxValues[index] = value ?? false;

                    if (value == true) {
                      if (!_selectedCategories.contains(category)) {
                        _selectedCategories.add(category);
                      }
                    } else {
                      _selectedCategories.remove(category);
                    }
                    saveFilterValues();
                  });
                },
              );
            }).toList(),
          ),
          SizedBox(height: 16),
          Text('Select Cities'),
          Column(
            children: _cities.asMap().entries.map((entry) {
              final index = entry.key;
              final city = entry.value;

              return CheckboxListTile(
                title: Text(city),
                value: _selectedCities.contains(city),
                onChanged: (bool? value) {
                  setState(() {
                    _cityCheckboxValues[index] = value ?? false;

                    if (value == true) {
                      if (!_selectedCities.contains(city)) {
                        _selectedCities.add(city);
                      }
                    } else {
                      _selectedCities.remove(city);
                    }
                    saveFilterValues();
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.clear();
            // Reset filter values in the current widget's state
            setState(() {
              _minValue = 0;
              _maxValue = 200000;
              _selectedCategories = [];
              _selectedCities = [];
            });
            widget.onFilterApplied(
              _minValue,
              _maxValue,
              _selectedCategories,
              _selectedCities, // Added selected cities
            );
            Navigator.of(context).pop();
          },
          child: Text('Clear'),
        ),
        TextButton(
          onPressed: () {
            try {
              // Save filter values before applying the filter
              saveFilterValues();
              widget.onFilterApplied(
                _minValue,
                _maxValue,
                _selectedCategories,
                _selectedCities, // Added selected cities
              );
              Navigator.of(context).pop();
            } catch (e) {
              print('Error applying filter: $e');
            }
          },
          child: Text('Apply'),
        ),
      ],
    );
  }
}
