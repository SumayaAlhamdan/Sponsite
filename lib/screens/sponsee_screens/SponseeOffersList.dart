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
  List<Offer> acceptedOffers = [];
  bool accepted = false;
  bool showActions = true;

  void initState() {
    super.initState();
    _loadOffersFromFirebase();
  }

  void _loadOffersFromFirebase() async {
    final DatabaseReference database = FirebaseDatabase.instance.ref();
    offers.clear();

    List<Offer> loadedOffers = [];
    Map<String, String> sponsorNames = {};
    Map<String, String> sponsorImages = {};

    database.child('offers').onValue.listen((offer) {
      if (offer.snapshot.value != null) {
        NotificationService()
            .showNotification(title: 'You got a new message', body: 'It works!');
        print(offer.snapshot.value);
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
              timeStamp: timestampString,
            ));
          }
        });

        database.child('Sponsors').onValue.listen((spons) {
          if (spons.snapshot.value != null) {
            Map<dynamic, dynamic> sponsorData =
                spons.snapshot.value as Map<dynamic, dynamic>;

            sponsorData.forEach((key, value) {
              sponsorNames[key] = value['Name'] as String? ?? '';
              sponsorImages[key] = value['Picture'] as String? ?? '';
            });

            for (var offer in loadedOffers) {
              offer.sponsorName = sponsorNames[offer.sponsorId] ?? '';
              offer.sponsorImage = sponsorImages[offer.sponsorId] ?? '';
            }

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
    } else if (difference < 7) {
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
    return SingleChildScrollView(
      child: Column(
        children: [
          for (Offer offer in acceptedOffers)
            _buildOfferCard(offer),
          Center(
            child: Text(
              'Sponsors Page',
              style: TextStyle(fontSize: 24),
            ),
          ),
        ],
      ),
    );
  }

 Widget _buildOfferCard(Offer offer) {
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Categories",
              style: TextStyle(
                fontSize: 22,
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
                  backgroundColor: Color.fromARGB(255, 91, 79, 158),
                  shadowColor: Colors.white,
                  elevation: 3,
                  labelStyle: TextStyle(
                    color: Colors.white,
                  ),
                );
              }).toList(),
            ),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notes:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      offer.notes,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                Spacer(), // Add space to push buttons to the right
                if (showActions) // Only show actions if showActions is true
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _showConfirmationDialog("Accept", offer);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.green,
                          minimumSize: Size(120, 50), // Adjust button size
                          padding: EdgeInsets.symmetric(horizontal: 10), // Adjust padding
                        ),
                        child: Text(
                          'Accept',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                      SizedBox(width: 5), // Add space of width 5
                      ElevatedButton(
                        onPressed: () {
                          _showConfirmationDialog("Reject", offer);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.red,
                          minimumSize: Size(120, 50), // Adjust button size
                          padding: EdgeInsets.symmetric(horizontal: 10), // Adjust padding
                        ),
                        child: Text(
                          'Reject',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Posted: ${formatTimeAgo(timestamp)}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}




  void _showConfirmationDialog(String action, Offer offer) {
  showDialog(
    context: context,
    builder: (context) {
      final uniqueKey = GlobalKey();
      return AlertDialog(
        key: uniqueKey,
        title: Text('Confirm $action'),
        content: Text('Are you sure you want to $action this offer?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                showActions = false; // Hide actions after rejecting
              });
              if (action == "Accept") {
                acceptedOffers.add(offer);
                offers.remove(offer);
              } else {
                offers.remove(offer);
              }
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('Confirm'),
          ),
        ],
      );
    },
  );
}





  void _navigateToSponsorsTab() {
    DefaultTabController.of(context)?.animateTo(1);
  }
}
