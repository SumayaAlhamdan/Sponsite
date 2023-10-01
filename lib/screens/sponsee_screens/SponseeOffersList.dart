import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:sponsite/local_notifications.dart';

class Offer {
  String eventId;
  String sponseeId;
  List<String> categories;
  String notes;
  String sponsorId;
  String sponsorName;
  String sponsorImage;
  String timeStamp;

  Offer({
    required this.eventId,
    required this.sponseeId,
    required this.categories,
    required this.notes,
    required this.sponsorId,
    required this.sponsorName,
    required this.sponsorImage,
    required this.timeStamp,
  });
    int get timeStampAsInt => int.tryParse(timeStamp) ?? 0;
}

class SponseeOffersList extends StatefulWidget {
  SponseeOffersList({required this.EVENTid, Key? key, required this.EventName})
      : super(key: key);

  final String? EVENTid;
  final String? EventName;

  @override
  _SponseeOffersListState createState() => _SponseeOffersListState();
}

class _SponseeOffersListState extends State<SponseeOffersList> {
  List<Offer> offers = [];

  void initState() {
    super.initState();
    _loadOffersFromFirebase();
  }

  void _loadOffersFromFirebase() async {
    final DatabaseReference database = FirebaseDatabase.instance.ref();
    offers.clear();

    // Declare variables to store offers, sponsor names, and timestamps
    List<Offer> loadedOffers = [];
    Map<String, String> sponsorNames = {};
    Map<String, String> sponsorImages = {};
    Map<String, int> offerTimestamps = {};

    // Retrieve offers
    database.child('offers').onValue.listen((offer) {
      if (offer.snapshot.value != null) {
         NotificationService()
              .showNotification(title: 'You got a new message', body: 'It works!');
        print(offer.snapshot.value) ; 
        Map<dynamic, dynamic> offerData =
            offer.snapshot.value as Map<dynamic, dynamic>;

        offerData.forEach((key, value) {
          List<String> categoryList = [];
          if (value['Category'] is List<dynamic>) {
            categoryList = (value['Category'] as List<dynamic>)
                .map((category) => category.toString())
                .toList();
          }
          if (value['EventId'] == widget.EVENTid) {
          String timestampString = value['TimeStamp'] as String? ?? '';


        loadedOffers.add(Offer(
  eventId: key,
  sponseeId: value['sponseeId'] as String? ?? '',
  categories: categoryList,
  notes: value['notes'] as String? ?? 'There are no notes available',
  sponsorId: value['sponsorId'] as String? ?? '',
  sponsorName: 'krkr',
  sponsorImage: '',
  timeStamp: timestampString, // Use the correct timestamp field name
));






          }
        });

        // Retrieve sponsor names
        database.child('Sponsors').onValue.listen((spons) {
          if (spons.snapshot.value != null) {
            Map<dynamic, dynamic> sponsorData =
                spons.snapshot.value as Map<dynamic, dynamic>;

            sponsorData.forEach((key, value) {
              sponsorNames[key] = value['Name'] as String? ?? '';
              sponsorImages[key] = value['Picture'] as String? ?? '';
            });

            // Update the 'sponsorName' and 'sponsorImage' properties for each offer
            for (var offer in loadedOffers) {
              offer.sponsorName = sponsorNames[offer.sponsorId] ?? '';
              offer.sponsorImage = sponsorImages[offer.sponsorId] ?? '';
            }

            // Update the state with the loaded offers
            setState(() {
              offers = loadedOffers;
            });
          }
        });
      }
    });
  }

  String formatTimeAgo(int timestamp) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final difference = now - timestamp;

    if (difference < Duration.minutesPerHour) {
      final minutes = difference ~/ Duration.millisecondsPerMinute;
      return '$minutes min ago';
    } else if (difference < Duration.hoursPerDay) {
      final hours = difference ~/ Duration.millisecondsPerHour;
      return '$hours hrs ago';
    } else if (difference < 7)  { //DAYS PER WEEK
      final days = difference ~/ Duration.millisecondsPerDay;
      return '$days days ago';
    } else {
      final dateFormat = DateFormat('MMM d, y');
      final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
      return dateFormat.format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '${widget.EventName} Event Offers',
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
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Container(
              color: Color.fromARGB(255, 255, 255, 255),
              padding: const EdgeInsets.only(bottom: 20, top: 50),
              child: TabBar(
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
                      'Sponsors',
                      style: TextStyle(fontSize: 22),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildCurrentOffersPage(),
                  _buildSponsorsPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentOffersPage() {
    return SingleChildScrollView(
      child: Column(
        children: offers.map((offer) {
          return _buildOfferCard(offer);
        }).toList(),
      ),
    );
  }

  Widget _buildSponsorsPage() {
    return Center(
      child: Text(
        'Sponsors Page',
        style: TextStyle(fontSize: 24),
      ),
    );
  }

 Widget _buildOfferCard(Offer offer) {
   print("Building offer card for ${offer.eventId}");
  // Parse the timestamp string and convert it to milliseconds since epoch
  final timestamp = DateTime.parse(offer.timeStamp).millisecondsSinceEpoch;

  return Card(
    margin: EdgeInsets.all(10),
    color: Colors.white,
    child: ExpansionTile(
      initiallyExpanded: false,
      title: Row(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              image: DecorationImage(
                image: NetworkImage(offer.sponsorImage),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 10),
          Text(
            'Sponsor: ${offer.sponsorName}',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Categories",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 4,
                children: offer.categories.map((category) {
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
              SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notes:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    offer.notes,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'Posted: ${formatTimeAgo(timestamp)}', // Use the parsed timestamp
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
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
