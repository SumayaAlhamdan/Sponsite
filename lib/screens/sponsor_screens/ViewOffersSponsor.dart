import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sponsite/screens/sponsor_screens/offerDetail.dart';
import 'package:sponsite/widgets/customAppBar.dart';
import 'package:sponsite/screens/view_others_profile.dart'; 

class ViewOffersSponsor extends StatefulWidget {
  const ViewOffersSponsor({Key? key}) : super(key: key);

  @override
  _ViewOffersSponsorState createState() => _ViewOffersSponsorState();
}

class _ViewOffersSponsorState extends State<ViewOffersSponsor> {
  List<Event> events = [];
  List<Offer> offers = [];

  int selectedTabIndex = 0;
  final DatabaseReference dbEvents =
      FirebaseDatabase.instance.reference().child('sponseeEvents');
  final DatabaseReference dbOffers =
      FirebaseDatabase.instance.reference().child('offers');
  User? user = FirebaseAuth.instance.currentUser;
  String? sponsorID;

  void check() {
    if (user != null) {
      sponsorID = user?.uid;
      print('sponsor ID: $sponsorID');
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

  Widget listItem({required Event event, required Offer offer}) { 
    Color statusColor = const Color.fromARGB(
        255, 91, 79, 158); // Default status color is gray for pending

    if (offer.status == 'Accepted') {
      statusColor = Colors.green;
    } else if (offer.status == 'Rejected') {
      statusColor = Colors.red;
    }

    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      height: screenHeight * 0.8,  
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
            
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: statusColor, // Set the border color
                width: 1.0, // Set the border width
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: EdgeInsets.all(5.0),
            child: Text(
              offer.status, // Display the status text here (e.g., "Pending", "Accepted", "Rejected")
              style: TextStyle(
                fontSize: 16,
                color: statusColor,
              ),
            ),  
            
        ),  
          SizedBox(
            width: double.infinity,
            height: 180,  
// Adjust the height as needed
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
                Row(
                children: [
                  Text(
                  event.EventName,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),     
                SizedBox(width: 80),  
                //      Container(
                //   decoration: BoxDecoration(
                //       border: Border.all(
                //         color: statusColor, // Set the border color
                //         width: 1.0, // Set the border width
                //       ),
                //       borderRadius: BorderRadius.circular(20)
                //       //   20.0), // Set border radius if needed
                //       ),
                //   padding: EdgeInsets.all(5.0),
                //   child: Text(  
                //     offer
                //         .status, // Display the status text here (e.g., "Pending", "Accepted", "Rejected")
                //     style: TextStyle(
                //       fontSize: 16,
                //       color: statusColor,
                //       //backgroundColor: statusColor),
                //     ),
                //   ),
                // ),  
                ],
                ),        
                 Row(
                            children: [
                              GestureDetector(
                                child: CircleAvatar(
                                  radius: 25,
                                  backgroundImage: NetworkImage(event.sponseeImage),
                                  backgroundColor: Colors.transparent,
                                ),
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => ViewOthersProfile(
                                        'Sponsees', event.sponseeId),
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
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => ViewOthersProfile(
                                        'Sponsees', event.sponseeId),
                                  ));
                                },
                              ),
                            ],
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
                        if (event.NumberOfAttendees != null &&
                            event.NumberOfAttendees.isNotEmpty)
                          const Icon(
                            Icons.people,
                            size: 24,
                            color: Color.fromARGB(255, 91, 79, 158),
                          ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(event.NumberOfAttendees,
                              style: const TextStyle(fontSize: 18),
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                SizedBox( 
                  height: 60,   
                  child: Wrap(
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
                ),
                const SizedBox(
                  height: 35  ,   
                ),  
                Align(    
                  alignment: Alignment.bottomRight,
                  child: GestureDetector(
                    onTap: () {
                      final eventCategoriesString = event.Category.join(', ');
                      final offerCategoriesString = offer.Category.join(', ');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => offertDetail(
                            DetailKey: event.EventName,
                            sponseeId: event.sponseeId,
                            location: event.location,
                            fullDesc: event.description,
                            img: event.imgURL,
                            startDate: event.startDate,
                            endDate: event.endDate,
                            Type: event.EventType,
                            eventCategory: eventCategoriesString,
                            startTime: event.startTime,
                            endTime: event.endTime,
                            eventNotes: event.notes,
                            benefits: event.benefits,
                            NumberOfAttendees: event.NumberOfAttendees,
                            EventId: offer.EventId,
                            Category: offerCategoriesString,
                            notes: offer.notes,
                            status: offer.status,
                            sponseeImage: event.sponseeImage,
                            sponseeName: event.sponseeName,
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
  }

  @override
  Widget build(BuildContext context) {
    return 
  DefaultTabController(
      length: 2,    
    child: Scaffold(
      // bottomNavigationBar: const SponseeBottomNavBar(),
      //BottomNavBar(),
      backgroundColor: Colors.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(105), // Adjust the height as needed
        child: CustomAppBar(  
          title: 'My Offers',
        ),
      ),
      body: Column(
          children: [
            Container(
              color: Color.fromARGB(255, 255, 255, 255),
              padding: const EdgeInsets.only(top: 50),
              child: TabBar(  
                // Move the TabBar to the appBar's bottom property
                indicatorColor: Color.fromARGB(255, 51, 45, 81),
                tabs: const [
                  Tab(  
                    child: Text(
                      'Current Offers',
                      style: TextStyle(fontSize: 22),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Past Offers',
                      style: TextStyle(fontSize: 22),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildCurrentEventsPage(),
                  _buildPastEventsPage(),
                ],
              ),
            ),
            ],
    ),
    ),    
    );  
  }
Widget _buildCurrentEventsPage() {
  return SafeArea(
    child: Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Column(
        children: [ 
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 50.0),
          ),  
          Expanded(
            child: offers.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/Add Files (1).png',
                        width: 282,
                        height: 284,  
                        fit: BoxFit.fitWidth,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'No offers available',
                        style: TextStyle( 
                          fontSize: 24,
                          // Adjust the font size as needed
                        ),
                      ),
                    ],
                  )
                : Scrollbar(
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.70,      
                        crossAxisSpacing: 8,        
                        mainAxisSpacing: 8,
                      ),
                      itemCount: events.length,
                      itemBuilder: (BuildContext context, int index) {
                        Event event = events[index];
                        Offer? offer;

                        for (Offer o in offers) {
                          if (o.EventId == event.EventId) {
                            offer = o;  
                            break;
                          }
                        }

                        if (offer != null) {
                          return listItem(event: event, offer: offer);
                        } else {
                          // Return a default widget when offer is null
                          return Container(
                            width: 282,
                            height: 284,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/Time.png'),
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildPastEventsPage() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 282,
            height: 284,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/Time.png'),
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
          SizedBox(height: 20), // Adjust the spacing as needed
          Text(
            'There are no past events yet',
            style: TextStyle(
              fontSize: 24, // Adjust the font size as needed
            ),
          ),
        ],
      );
  } 


  void _loadEventsFromFirebase() {
    check();
  Map<String, String> sponseeNames = {};
    Map<String, String> sponseeImages = {};
    dbOffers.onValue.listen((offer) {
      if (offer.snapshot.value != null) {
        setState(() {
          offers.clear();
          Map<dynamic, dynamic> offersData =
              offer.snapshot.value as Map<dynamic, dynamic>;
          offersData.forEach((key, value) {
            var categoryList = (value['Category'] as List<dynamic>)
                .map((category) => category.toString())
                .toList();
            if (value['sponsorId'] == sponsorID) {
              offers.add(Offer(
                EventId: value['EventId'] as String? ?? '',
                sponsorId: value['sponsorId'] as String,
                sponseeId: value['sponseeId'] as String,
                notes: value['notes'] as String? ?? '',
                Category: categoryList,
                status: value['Status'] as String? ?? '',
              ));
            }

            final DatabaseReference database = FirebaseDatabase.instance.ref();
            database.child('sponseeEvents').onValue.listen((event) {
              if (event.snapshot.value != null) {
                setState(() {
                  events.clear();
                  Map<dynamic, dynamic> eventData =
                      event.snapshot.value as Map<dynamic, dynamic>;

                  eventData.forEach((key, value) {
                    // Check if value['Category'] is a listي
                    List<String> categoryList = [];
                    if (value['Category'] is List<dynamic>) {
                      categoryList = (value['Category'] as List<dynamic>)
                          .map((category) => category.toString())
                          .toList();
                    }
                    String timestampString = value['TimeStamp'] as String;
                    String eventStartDatestring = value['startDate'];
                    String eventEndtDatestring = value['endDate'];
                    DateTime? eventStartDate =
                        DateTime.tryParse(eventStartDatestring);
                    DateTime? eventEndDate =
                        DateTime.tryParse(eventEndtDatestring);

                    // Simulate the current time (for testing purposes)
                    DateTime currentTime = DateTime.now();

                    if (eventStartDate!.isAfter(currentTime) &&
                        _isEventAssociatedWithSponsor(key, sponsorID)) {
                      events.add(Event(
                        EventId: key,
                        EventName: value['EventName'] as String? ?? '',
                        sponseeId: value['SponseeID'] as String? ?? '', 
                        EventType: value['EventType'] as String? ?? '',
                        location: value['Location'] as String? ?? '',
                        imgURL: value['img'] as String? ?? "",
                        startDate: value['startDate'] as String? ?? '',
                        endDate: value['endDate'] as String? ?? '',
                        startTime: value['startTime'] as String? ?? ' ',
                        endTime: value['endTime'] as String? ?? ' ',
                        Category: categoryList,
                        description: value['description'] as String? ?? ' ',
                        notes: value['Notes'] as String? ??
                            'There are no notes available',
                        benefits: value['Benefits'] as String?,
                        NumberOfAttendees:
                            value['NumberOfAttendees'] as String? ?? '',
                        timeStamp: timestampString, 
                                  sponseeImage: '',
                              sponseeName: '',// Store the timestamp
                      ));
                    }
                  });
                });
              }
              // Sort events based on the timeStamp (descending order)
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
          }); 
        });
      }
    });
  }

  bool _isEventAssociatedWithSponsor(String eventId, String? sponsorID) {
    // Check if there is an offer with the specified EventId and sponsorId
    return offers.any(
        (offer) => offer.EventId == eventId && offer.sponsorId == sponsorID);
  }
}

class Event {
  final String EventId;
  final String EventName;
  final String sponseeId;
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
  final String timeStamp;
   String sponseeName;
   String sponseeImage;

  Event({
    required this.EventId,
    required this.EventName,
    required this.EventType,
    required this.sponseeId,
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
    required this.timeStamp,
    this.benefits,
     required this.sponseeName,
     required this.sponseeImage,
  });
}

class Offer {
  final String EventId;
  final String sponseeId;
  final String sponsorId;
  final List<String> Category;
  final String notes;
  final String status;

  Offer({
    required this.EventId,
    required this.sponseeId,
    required this.sponsorId,
    required this.Category,
    required this.notes,
    required this.status,
  });
}
