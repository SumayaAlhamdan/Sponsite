import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sponsite/screens/sponsor_screens/sendOffer.dart';
import 'package:sponsite/screens/view_others_profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(FilterPage());
}

String? sponsorID;

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

class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  _FilterPageState createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  List<Event> events = [];
  String selectedCategory = 'All';
  String? mtoken = " ";
  User? user = FirebaseAuth.instance.currentUser;
  TextEditingController searchController = TextEditingController();
  List<Event> searchedEvents = []; // List to store searched events
  bool isSearched = false;
  int minAttendees = 0;
  int maxAttendees = 200000;
  List<String> selectedCategories = [];
  int FminAttendees = 0;
  int FmaxAttendees = 200000;
  List<String> FselectedCategories = [];
  List<String> FselectedCities = [];
  void _searchEventsByName(String eventName) {
    // Filter events based on event name
    isSearched = true;
    searchedEvents = events
        .where((event) =>
            event.EventName.toLowerCase().contains(eventName.toLowerCase()))
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
      return events;
    } else {
      return events
          .where((event) => event.Category.contains(selectedCategory))
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
 return Theme(
      // Apply your theme settings within the Theme widget
      data: ThemeData(
        // Set your desired font family or other theme configurations
        fontFamily: 'Urbanist',
        textTheme: TextTheme(
      displayLarge: const TextStyle(
        fontSize: 72,
        fontWeight: FontWeight.bold,
      ),
        // Add other theme configurations here as needed
      ),
      ),
    child: Scaffold(
        appBar: AppBar(
          title: Text('Sumaya coding'),
          actions: [
            //FILTER CODE HEREEEE
            IconButton(
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
                        onFilterApplied: (minAttendees, maxAttendees,
                            selectedCategories, selectedCities) {
                          setState(() {
                            FminAttendees = minAttendees;
                            FmaxAttendees = maxAttendees;
                            FselectedCategories = selectedCategories;
                            FselectedCities = selectedCities;
                          });
                        },
                      );
                    });
              },
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // new addition
            if (FminAttendees != 0 ||
                FmaxAttendees != 200000 ||
                (FselectedCategories != null &&
                    FselectedCategories.isNotEmpty) ||
                (FselectedCities != null && FselectedCities.isNotEmpty))
              Text('Filtered By:',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Color.fromARGB(255, 91, 79, 158),
                  )),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: <Widget>[
                if (FminAttendees != 0)
                  Chip(
                      label: Text(
                    'Min Attendees: $FminAttendees',
                    style: TextStyle(color: Color.fromARGB(255, 91, 79, 158)),
                  )),
                if (FmaxAttendees != 200000)
                  Chip(
                    label: Text(
                      'Max Attendees: $FmaxAttendees',
                      style: TextStyle(color: Color.fromARGB(255, 91, 79, 158)),
                    ),
                  ),
                if (FselectedCategories != null &&
                    FselectedCategories.isNotEmpty)
                  Chip(
                    label:
                        Text('Categories: ${FselectedCategories.join(', ')}'),
                    labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(
                            255, 91, 79, 158)), // Add style as needed
                  ),
                if (FselectedCities != null && FselectedCities.isNotEmpty)
                  Chip(
                    label: Text('Cities: ${FselectedCities.join(', ')}'),
                    labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(
                            255, 91, 79, 158)), // Add style as needed
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (isSearched == false || searchedEvents.isNotEmpty)
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isSearched == true && searchedEvents.isEmpty)
                  Center(
                    child: Text(
                      "No results match your search",
                      style: TextStyle(fontSize: 20, color: Colors.grey),
                    ),
                  ),
                if (isSearched == false || searchedEvents.isNotEmpty)
                  SizedBox(
                    height: screenHeight - 580,
                    child: Scrollbar(
                      // Set this to true to always show the scrollbar
                      child: GridView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12.0, 0),
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.715,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: searchedEvents.isNotEmpty
                            ? searchedEvents.length
                            : getFilteredEvents().length,
                        itemBuilder: (context, index) {
                          Event event = searchedEvents.isNotEmpty
                              ? searchedEvents[index]
                              : getFilteredEvents()[index];
                          bool meetsFilterCriteria = applyFilterCriteria(event);
                          print('HERE EVENT CRIRITA');
                          if (meetsFilterCriteria) {
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
                                        ),
                                      ),
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
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
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
                                                },
                                              ).toList(),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 8,
                                          ),
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
                                                size: 16,
                                                color: Color.fromARGB(
                                                    255, 91, 79, 158),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 41.9,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else {}
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ))
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
      title: Text(
        'Filter Events By:',
        style: TextStyle(color: Color.fromARGB(255, 91, 79, 158)),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Number of Attendees (Min and Max):',
            style: TextStyle(
                color: Color.fromARGB(255, 91, 79, 158), fontSize: 20),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Min',
                      style: TextStyle(
                          color: Color.fromARGB(255, 91, 79, 158),
                          fontSize: 15),
                    ),
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
                    Text(
                      'Max',
                      style: TextStyle(
                          color: Color.fromARGB(255, 91, 79, 158),
                          fontSize: 15),
                    ),
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
          Text(
            'Select Categories:',
            style: TextStyle(
                color: Color.fromARGB(255, 91, 79, 158), fontSize: 20),
          ),
          Column(
            children: _categories.asMap().entries.map((entry) {
              final index = entry.key;
              final category = entry.value;

              return CheckboxListTile(
                title: Text(
                  category,
                  style: TextStyle(
                      color: Color.fromARGB(255, 91, 79, 158), fontSize: 15),
                ),
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
                controlAffinity: ListTileControlAffinity
                    .leading, // Set checkboxes to the left
              );
            }).toList(),
          ),
          SizedBox(height: 16),
          Text(
            'Select Cities:',
            style: TextStyle(
                color: Color.fromARGB(255, 91, 79, 158), fontSize: 20),
          ),
          Column(
            children: _cities.asMap().entries.map((entry) {
              final index = entry.key;
              final city = entry.value;

              return CheckboxListTile(
                title: Text(
                  city,
                  style: TextStyle(
                      color: Color.fromARGB(255, 91, 79, 158), fontSize: 15),
                ),
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
                controlAffinity: ListTileControlAffinity
                    .leading, // Set checkboxes to the left
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
          child: Text(
            'Clear',
            style: TextStyle(
                color: Color.fromARGB(255, 91, 79, 158), fontSize: 15),
          ),
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
          child: Text(
            'Apply',
            style: TextStyle(
                color: Color.fromARGB(255, 91, 79, 158), fontSize: 15),
          ),
        ),
      ],
    );
  }
}
