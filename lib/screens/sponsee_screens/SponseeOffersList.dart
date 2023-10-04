import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

final DatabaseReference dbref = FirebaseDatabase.instance.reference();

class Offer {
  String eventId;
  String sponseeId;
  List<String> categories;
  String notes;
  String sponsorId;
  String sponsorName;
  String sponsorImage;
  String timeStamp;
  String status; // New field to track the offer status

  Offer({
    required this.eventId,
    required this.sponseeId,
    required this.categories,
    required this.notes,
    required this.sponsorId,
    required this.sponsorName,
    required this.sponsorImage,
    required this.timeStamp,
    this.status = 'Pending', // Default status is 'Pending'
  });

  int get timeStampAsInt => int.tryParse(timeStamp) ?? 0;
}

class SponseeOffersList extends StatefulWidget {
  SponseeOffersList({
    required this.EVENTid,
    Key? key,
    required this.EventName,
  }) : super(key: key);

  final String? EVENTid;
  final String? EventName;

  @override
  _SponseeOffersListState createState() => _SponseeOffersListState();
}

class _SponseeOffersListState extends State<SponseeOffersList> {
  List<Offer> offers = [];
  List<Offer> acceptedOffers = [];
  bool showActions = true; //buttons 

  @override
  void initState() {
    super.initState();
    _loadOffersFromFirebase();
    _loadAcceptedOffersFromStorage();
  }

  void _loadOffersFromFirebase() async {
    final DatabaseReference database = FirebaseDatabase.instance.ref();
    offers.clear();

    List<Offer> loadedOffers = [];
    Map<String, String> sponsorNames = {};
    Map<String, String> sponsorImages = {};

    // Clear acceptedOffers when loading new offers
    acceptedOffers.clear();

    database.child('offers').onValue.listen((offer) {
      if (offer.snapshot.value != null) {
     //   print("Firebase offers data: ${offer.snapshot.value}");

        Map<dynamic, dynamic> offerData =
            offer.snapshot.value as Map<dynamic, dynamic>;

        offerData.forEach((key, value) {
          List<String> categoryList = [];
          if (value['Category'] is List<dynamic>) {
            categoryList = (value['Category'] as List<dynamic>)
                .map((category) => category.toString())
                .toList();
          }
         // print('Check EventId: ${value['EventId']}');
          //print("Widget EVENTid: ${widget.EVENTid}");

          if (value['EventId'] == widget.EVENTid) {
            String timestampString = value['TimeStamp'] as String? ?? '';

            loadedOffers.add(Offer(
              eventId: key,
              sponseeId: value['sponseeId'] as String? ?? '',
              categories: categoryList,
              notes:
                  value['notes'] as String? ?? 'There are no notes available',
              sponsorId: value['sponsorId'] as String? ?? '',
              sponsorName: 'krkr',
              sponsorImage: '',
              timeStamp: timestampString,
              status: value['Status'] as String? ?? 'Pending', // Read status from the database
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

  void _loadAcceptedOffersFromStorage() async {
    
    final prefs = await SharedPreferences.getInstance();
    final acceptedOfferIds = prefs.getStringList('acceptedOffers') ?? [];

    setState(() {
    
      acceptedOffers = offers
          .where((offer) =>
              acceptedOfferIds.contains(offer.eventId) &&
              offer.status == 'Accepted')
          .toList();
    });
    print(acceptedOffers);
  }

  String formatTimeAgo(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);

    final day = DateFormat.d().format(date);
    final month = DateFormat.MMM().format(date);
    final year = DateFormat.y().format(date);
    final hour = DateFormat.jm().format(date);

    final formattedTime = 'Posted: $day - $month - $year at $hour';

    return formattedTime;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '${widget.EventName} Event Offers',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
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
    final currentOffers = offers.where((offer) => offer.status == 'Pending').toList();
    return SingleChildScrollView(
      child: Column(
        children: currentOffers.map((offer) {
          return _buildOfferCard(offer);
        }).toList(),
      ),
    );
  }

  Widget _buildSponsorsPage() {
    final acceptedOffers = offers.where((offer) => offer.status == 'Accepted').toList();
    return SingleChildScrollView(
      child: Column(
        children: [
         for (Offer offer in acceptedOffers) _buildOfferCard(offer),
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

    return Container(
      child: Card(
        margin: EdgeInsets.all(10),
        elevation: 5,
        color: Color.fromARGB(255, 255, 255, 255),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: ExpansionTile(
          tilePadding: EdgeInsets.all(0),
          expandedAlignment: Alignment.topLeft,
          childrenPadding: EdgeInsets.all(22),
          trailing: SizedBox.shrink(),
          title: Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 51, 45, 81).withOpacity(0.7),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(0),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Posted: ${formatTimeAgo(timestamp)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 35),
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
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sponsor',
                        style: TextStyle(
                          fontSize: 25,
                        ),
                      ),
                      Text(
                        offer.sponsorName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 36,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),
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
                const SizedBox(height: 16),
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
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (showActions)
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              _showConfirmationDialog("Accept", offer);
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.green,
                              minimumSize: Size(120, 50),
                              padding: EdgeInsets.symmetric(horizontal: 10),
                            ),
                            child: Text(
                              'Accept',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          SizedBox(width: 5),
                          ElevatedButton(
                            onPressed: () {
                              _showConfirmationDialog("Reject", offer);
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.red,
                              minimumSize: Size(120, 50),
                              padding: EdgeInsets.symmetric(horizontal: 10),
                            ),
                            child: Text(
                              'Reject',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
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
                Navigator.of(context).pop(); // Close the dialog

                if (action == "Accept") {
                  // Mark the offer as accepted
                  offer.status = 'Accepted';

                  // Save accepted offers to storage
                  _saveAcceptedOffersToStorage();

                  setState(() {
                    acceptedOffers.add(offer);
                  });

                  // Push the accepted status to the database
                  dbref.child('offers').child(offer.eventId).update({'Status': "Accepted"});
                } else {
                  // Push the rejected status to the database
                  dbref.child('offers').child(offer.eventId).update({'Status': "Rejected"});
                }

                setState(() {
                  showActions = false; // Hide actions after rejecting
                });
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _saveAcceptedOffersToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final acceptedOfferIds = acceptedOffers.map((offer) => offer.eventId).toList();
    prefs.setStringList('acceptedOffers', acceptedOfferIds);
  }

  void _navigateToSponsorsTab() {
    DefaultTabController.of(context)?.animateTo(1);
  }
}

void main() {
  runApp(MaterialApp(
    home: SponseeOffersList(
      EVENTid: "your_event_id_here",
      EventName: "Your Event Name",
    ),
  ));
}
