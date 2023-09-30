import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:sponsite/eventDetail.dart';
import 'package:sponsite/screens/sponsee_screens/SponseeOffersList.dart';
import 'package:sponsite/widgets/customAppBar.dart'; // Import the correct CustomAppBar widget
import 'package:sponsite/widgets/user_type_selector.dart';


class ViewCurrentSponsee extends StatefulWidget {
  const ViewCurrentSponsee({Key? key}) : super(key: key);

  @override
  _ViewCurrentSponseeState createState() => _ViewCurrentSponseeState();
}

class _ViewCurrentSponseeState extends State<ViewCurrentSponsee> {
  List<Event> events = [];
  int selectedTabIndex = 0;
  final DatabaseReference dbRef =
      FirebaseDatabase.instance.ref().child('sponseeEvents');
  User? user = FirebaseAuth.instance.currentUser;
  String? sponseeID;
  String? EVENTid; // Declare EVENTid at the class level

  void check() {
    if (user != null) {
      sponseeID = user?.uid;
      print('Sponsee ID: $sponseeID');
    } else {
      print('User is not logged in.');
    }
  }
//Here is the code for the Reading ??? 

  @override
  void initState() {
    super.initState();
    check();
    _loadEventsFromFirebase();
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
              EVENTid = key;
              events.add(Event(
                EventName: value['EventName'] as String? ?? '',
                EventType: value['EventType'] as String? ?? '',
                location: value['Location'] as String? ?? '',
                description: value['Description'] as String? ?? '',
                imgURL: value['img'] as String? ??
                    'https://png.pngtree.com/templates/sm/20180611/sm_5b1edb6d03c39.jpg',
                startDate: value['startDate'] as String? ?? '',
                endDate: value['endDate'] as String? ?? '',
                startTime: value['startTime'] as String? ?? '',
                endTime: value['endTime'] as String? ?? '',
                notes: value['Notes'] as String? ?? 'There are no notes available',
                benefits: value['Benefits'] as String? ?? '',
                NumberOfAttendees: value['NumberOfAttendees'] as String? ?? '',
                Category: categoryList,
              ));
            }
          });
        });
      }
    });
  }

  Widget listItem({required Event event}) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color.fromARGB(255, 255, 255, 255),
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
          SizedBox(
            width: double.infinity,
            height: 140, // Adjust the height as needed
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
                  style:
                      const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 5,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 24,
                          color: Color.fromARGB(255, 91, 79, 158),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          "${event.startDate} - ${event.endDate}",
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        if (event.location != null &&
                            event.location.isNotEmpty)
                          const Icon(
                            Icons.location_on,
                            size: 24,
                            color: Color.fromARGB(255, 91, 79, 158),
                          ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            event.location,
                            style: const TextStyle(fontSize: 18),
                            overflow: TextOverflow.ellipsis,
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
                      backgroundColor:
                          const Color.fromARGB(255, 255, 255, 255),
                      shadowColor: const Color.fromARGB(255, 91, 79, 158),
                      elevation: 3,
                      labelStyle: const TextStyle(
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
                            startDate: event.startDate,
                            endDate: event.endDate,
                            Type: event.EventType,
                            Category: categoriesString,
                            startTime: event.startTime,
                            endTime: event.endTime,
                            notes: event.notes,
                            benefits: event.benefits,
                            NumberOfAttendees: event.NumberOfAttendees,
                          ),
                        ),
                      );
                    },
                    child: const Row(
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
                Align(
                  alignment: Alignment.center, // Align the button to the center horizontally
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 91, 79, 158),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      // Navigate to the SponseeOffersListPage class when the button is pressed
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SponseeOffersList(EVENTid : EVENTid, EventName : event.EventName) , 
                        ),
                      );
                      // Handle button press here
                    },
                    child: Text(
                      'View Offers',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                      ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            'My Events',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          backgroundColor: Color.fromARGB(255, 51, 45, 81),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
        ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 15),
          child: Column(
            children: [
              const SizedBox(
                height: 100,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 50.0),
              ),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                child: Scrollbar(
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
        padding: const EdgeInsets.only(top: 170),
        child: SizedBox(
          width: 250,
          height: 50,
          child: SingleChoice(
            initialSelection: selectedTabIndex == 0 ? eventType.current : eventType.past,
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
}

class Event {
  final String EventName;
  final String EventType;
  final String location;
  final String description;
  final String imgURL;
  final String startDate;
  final String endDate;
  final String startTime;
  final String endTime;
  final String notes;
  final String? benefits;
  final String NumberOfAttendees;
  final List<String> Category;

  Event({
    required this.EventName,
    required this.EventType,
    required this.location,
    required this.description,
    required this.imgURL,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.Category,
    required this.NumberOfAttendees,
    required this.notes,
    this.benefits,
  });
}
