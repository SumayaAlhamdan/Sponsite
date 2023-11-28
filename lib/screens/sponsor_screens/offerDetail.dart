import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sponsite/screens/view_others_profile.dart';
import 'package:sponsite/widgets/customAppBarwithNav.dart';



class offertDetail extends StatefulWidget {
  offertDetail({
    Key? key,
    required this.DetailKey,
    required this.img,
    required this.location,
    required this.sponseeName,
    required this.sponseeId,
    required this.sponseeImage,
    required this.fullDesc,
    required this.startDate,
    required this.endDate,
    required this.Type,
    required this.eventCategory,
    required this.startTime,
    required this.endTime,
    required this.eventNotes,
    this.benefits,
    required this.NumberOfAttendees,
    required this.EventId,
    required this.Category,
    required this.notes,
    required this.status,
    required this.isPast,
    this.rating,
    this.sponsorId,
  }) : super(key: key ); // Use myKey if key is not provided

  final String img;
  final String location;
  String sponseeName;
  String sponseeId;
  String sponseeImage;
  final String startDate;
  final String endDate;
  final String DetailKey;
  final String fullDesc;
  final String Type;
  final String eventCategory;
  final String startTime;
  final String endTime;
  final String eventNotes;
  final String? benefits;
  final String NumberOfAttendees;
  final String EventId;
  final String Category;
  final String notes;
  final String status;
  final bool isPast;
  double? rating;
  String? sponsorId ; 

  @override
  State<offertDetail> createState() => _Start();
}

class _Start extends State<offertDetail> {
  double screenWidth = 0;
  double screenHeight = 0;
  //bool isCurrentTabSelected = true;  Indicates whether "Current Events" tab is selected
  bool isExpanded = false;


@override
void initState() {
  super.initState();

setTimePhrase();
  fetchOfferRating(widget.sponseeId, widget.EventId, widget.sponsorId).then((double? rating) {
    if (rating != null) {
      setState(() {
        widget.rating = rating;
      });
    }
  });
}
String st = "";
  String et = "";
  String stP = "";
  String etP = "";

void setTimePhrase() {
  // Splitting the time by the ':' separator
  List<String> startSplit = widget.startTime.split(':');
  List<String> endSplit = widget.endTime.split(':');
  // Extracting hours part as an integer
  int? sHour = int.tryParse(startSplit[0]);
    int? sMin = int.tryParse(startSplit[1]);

  int? eHour = int.tryParse(endSplit[0]);
    int? eMin = int.tryParse(endSplit[1]);


  // Checking if the parsed hour is not null and within the valid range
  if (sHour != null && sHour >= 0 && sHour <= 23) {
    stP = sHour < 12 ? "AM" : "PM";
  } else {
    // Handling the case when the hour is invalid
    stP = "Invalid start time";
  }

 if (eHour != null && eHour >= 0 && eHour <= 23) {
    etP = eHour < 12 ? "AM" : "PM";
  } else {
    // Handling the case when the hour is invalid
    etP = "Invalid start time";
  }

  if(sHour != null && stP=="PM"){
    sHour=sHour-12;
    st="${sHour}:${sMin}";
  }
  else{
   st=widget.startTime;

  }

  if(eHour != null && etP=="PM"){
    eHour=eHour-12;
    et="${eHour}:${eMin}";
  }
  else{
      et=widget.endTime;
  }

  print(st);
  print(et);
}


Future<double?> fetchOfferRating(String sponseeID, String eventId, String? sponsorID) async {
  try {
    final DatabaseReference database = FirebaseDatabase.instance.ref();
    final DatabaseEvent event = await database
        .child('offers')
        .orderByChild('EventId')
        .equalTo(eventId)
        .once();

    final DataSnapshot snapshot = event.snapshot;

    if (snapshot.value != null) {
      final Map<dynamic, dynamic> offers =
          snapshot.value as Map<dynamic, dynamic>;

      for (final entry in offers.entries) {
        final Map<dynamic, dynamic> offer = entry.value as Map<dynamic, dynamic>;

        if (offer['sponseeId'] == sponseeID && offer['sponsorId' == sponsorID ]) {
          // Check if the offer has a rating
          if (offer.containsKey('sponseeRating')) {
            return (offer['sponseeRating'] as num).toDouble();
          } else {
            // Offer doesn't have a rating
            return null;
          }
        }
      }
    }

    // No matching offer found
    return null;
  } catch (error) {
    print('Error fetching offer rating: $error');
    return null;
  }
}


  @override
  Widget build(BuildContext context) {
    if (widget.status == 'Accepted') {
      statusColor = Colors.green;
    } else if (widget.status == 'Rejected') {
      statusColor = Colors.red;
    }
    GoogleMapController? mapController;

    double latitude = 0;
    double longitude = 0;
    LatLng loc = LatLng(latitude, longitude);

    void getloc() {
      List<String> parts = widget.location.split(',');
      latitude = double.parse(parts[0]);
      longitude = double.parse(parts[1]);
      loc = LatLng(latitude, longitude);
    }

    if (widget.location != "null") getloc();

    Widget buildMap() {
      return Stack(
        children: [
          Container(
            height: 350,
            child: GoogleMap(
              onMapCreated: (controller) {
                // setState(() {
                mapController = controller;
                // });
              },
              initialCameraPosition: CameraPosition(
                target: loc, // Initial map location
                zoom: 15.0,
                // Initial zoom level
              ),
              markers: {
                Marker(
                  markerId: MarkerId(
                      "EventLoc"), // A unique identifier for the marker
                  position:
                      loc, // Coordinates where the marker should be placed
                  infoWindow: InfoWindow(
                      title: "Event Location"), // Optional info window
                ),
              },
            ),
          ),
        ],
      );
    }

    Future<String> getAddressFromCoordinates(
        double latitude, double longitude) async {
      try {
        List<Placemark> placemarks =
            await placemarkFromCoordinates(latitude, longitude);

        if (placemarks.isNotEmpty) {
          Placemark placemark = placemarks[0];
          String address =
              '${placemark.street}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}';
          ; // You can access various fields like street, city, country, etc.
          return address;
        } else {
          return "Address not found";
        }
      } catch (e) {
        print("Error retrieving address: $e");
        return "Error retrieving address";
      }
    }

    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
 return Theme(
      // Apply your theme settings within the Theme widget
      data: ThemeData(
        // Set your desired font family or other theme configurations
        fontFamily: 'Urbanist',
        useMaterial3: true,
        textTheme: TextTheme(
      displayLarge: const TextStyle(
        fontSize: 72,
        fontWeight: FontWeight.bold,
      ),
        // Add other theme configurations here as needed
      ),
      ),
    child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.topLeft,
              children: [
                Hero(
                  tag: widget.DetailKey,
                  child: SizedBox(
                    height: screenHeight / 2.2,
                    width: screenWidth,
                    child: Image.network(
                      widget.img.isNotEmpty
                          ? widget.img
                          : 'https://media.istockphoto.com/id/1369748264/vector/abstract-white-background-geometric-texture.jpg?s=612x612&w=0&k=20&c=wFsN0D9Ifrw1-U8284OdjN25JJwvV9iKi9DdzVyMHEk=',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                CustomAppBar(
                  title: 'Event Details',
                ),
                
              ],
            ),
            Expanded(

                // Use Expanded to fill available space
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
Row(
  children: [
    Expanded(
      child: Text(
        widget.DetailKey,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 32,
          color: Colors.black87,
        ),
      ),
    ),
    if (widget.isPast)
      widget.rating == null
          ? ElevatedButton.icon(
              onPressed: () {
                _rateSponsorships(context);
              },
              icon: Icon(
                Icons.star,
                color: Colors.white,
              ),
              label: Text(
                "Rate Sponsorship",
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                primary: const Color.fromARGB(255, 91, 79, 158),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: EdgeInsets.all(15), // Adjust padding as needed
              ),
            )
          : Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Row(
      children: [
        
        Text(
          'Rated with: ',
          style: TextStyle(
            fontSize: 23,
            color: Colors.black,
          ),
        ),
        Icon(
          Icons.star,
          color: Colors.yellow,
          size: 30,
        ),
        SizedBox(width: 5),
       
        Text(
          widget.rating.toString(),
          style: TextStyle(
            fontSize: 23,
            color: Colors.black,
          ),
        ),
          Padding(padding: EdgeInsets.only(right: 10)),
      ],
    ),
  ],
),

  ],
),




                                const SizedBox(height: 10),
                                Text(
                                  widget.Type,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    color: Colors.black87,
                                  ),
                                ),
                                Row(
                                  children: [
                                    GestureDetector(
                                      child: CircleAvatar(
                                        radius: 25,
                                        backgroundImage:
                                            NetworkImage(widget.sponseeImage),
                                        backgroundColor: Colors.transparent,
                                      ),
                                      onTap: () {
                                        Navigator.of(context)
                                            .push(MaterialPageRoute(
                                          builder: (context) =>
                                              ViewOthersProfile(
                                                  'Sponsees', widget.sponseeId),
                                        ));
                                      },
                                      
                                    ),

                                    SizedBox(width: 10),
                                    // Add some space between the CircleAvatar and Text
                                    GestureDetector(
                                      child: Expanded(
                                        child: Text(
                                          widget.sponseeName,
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
                                                  'Sponsees', widget.sponseeId),
                                        ));
                                      },
                                    ),
                                  ],
                                ),
                                const Divider(height: 30, thickness: 2),
                                Container(
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(width: 1.5), // Add a border
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  padding: EdgeInsets.all(0),
                                  child: ExpansionTileCard(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10.0)),
                                    baseColor:
                                        Color.fromARGB(255, 255, 255, 255),
                                    
                                    title: Center( child: Text(
                                      "Event Details",
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                  
                                      ),  
                                    ),  
                                    ),
                                    children: <Widget>[
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(10.0)), 
                                        ),
                                        padding: EdgeInsets.all(12.0),
                                        alignment: Alignment.bottomLeft,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                _buildInfoRow(
                                    Icons.calendar_today,
                                    "${widget.startDate} - ${widget.endDate}",
                                    "Date"),
                              _buildInfoRow(Icons.access_time,
                              "${st} ${stP} - ${et} ${etP}", "Time"),
                                _buildInfoRow(Icons.person,
                                    widget.NumberOfAttendees, "Attendees"),
                                if (widget.location != "null")
                                  FutureBuilder<String>(
                                    future: getAddressFromCoordinates(
                                        latitude, longitude),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return CircularProgressIndicator();
                                      } else if (snapshot.hasError) {
                                        return Text("Error: ${snapshot.error}");
                                      } else if (!snapshot.hasData) {
                                        return Text("Address not found");
                                      } else {
                                        return Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(8.0),
                                              child: Icon(
                                                Icons
                                                    .location_on, // Replace with the desired icon
                                                color: const Color.fromARGB(
                                                    255,
                                                    91,
                                                    79,
                                                    158), // Customize the icon color
                                                size:
                                                    40.0, // Customize the icon size
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text(
                                                  snapshot.data ?? "",
                                                  style: TextStyle(
                                                    fontSize: 22.0,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      }
                                    },
                                  ),
                                if (widget.location != "null")
                                  Center(
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.9,
                                      child: buildMap(),
                                    ),
                                  ),
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
                                  spacing: 8,
                                  children: widget.eventCategory
                                      .split(',')
                                      .map((category) {
                                    return Chip(
                                      label: Text(category.trim()),
                                      backgroundColor: const Color.fromARGB(
                                          255, 255, 255, 255),
                                      shadowColor: const Color.fromARGB(
                                          255, 91, 79, 158),
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
                                  widget.benefits ?? "No benefits available",
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
                                  (widget.eventNotes.isNotEmpty)
                                      ? widget.eventNotes
                                      : "There are no notes available",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.black87,
                                  ),
                                ),
                                ],
                                ),
                                ),  
                                ],
                                ),
                                ),

                                const SizedBox(height: 20),
                                Container(
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(width: 1.5), // Add a border
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  padding: EdgeInsets.all(0),
                                  child: ExpansionTileCard(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10.0)),
                                    baseColor:
                                        Color.fromARGB(255, 255, 255, 255),
                                    
                                    title: Center( child: Text(
                                      "Offer Details",
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                  
                                      ),
                                    ),  
                                    ),
                                    children: <Widget>[
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(10.0)), 
                                        ),
                                        padding: EdgeInsets.all(12.0),
                                        alignment: Alignment.bottomLeft,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                            const Text(
                                              "Categories",
                                              style: TextStyle(
                                                fontSize: 25,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(width: 20),
                                            Wrap(
                                              spacing: 8,
                                              children:
                                                  widget.Category.split(',')
                                                      .map((category) {
                                                return Chip(
                                                  label: Text(category.trim()),
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
                                              ],
                                              ),
                                            const SizedBox(height: 20),
                                            Row(
                                              children:[
                                            const Text(
                                              "Notes",
                                              style: TextStyle(
                                                fontSize: 25,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(width: 20),
                                            Text(
                                              (widget.notes.isNotEmpty)
                                                  ? widget.notes
                                                  : "There are no notes available",
                                              style: const TextStyle(
                                                fontSize: 20,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            ],
                                            ),
                                            const SizedBox(height: 23),
                                            Row(
                                              children: [
                                            const Text(
                                              "Offer Status",
                                              style: TextStyle(
                                                fontSize: 25,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(width: 23),
                                            Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color:
                                                      statusColor, // Set the border color
                                                  width:
                                                      1.0, // Set the border width
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                color: statusColor,
                                                //   20.0), // Set border radius if needed
                                              ),
                                              padding: EdgeInsets.all(5.0),
                                              child: Text(
                                                widget
                                                    .status, // Display the status text here (e.g., "Pending", "Accepted", "Rejected")
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white,
                                                  //backgroundColor: statusColor),
                                                ),
                                              ),
                                            ),
                                              ],
                                            ),  
                                            const SizedBox(width: 10),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            )))))))
          ],
        ))
 );
  }

  Color statusColor = const Color.fromARGB(
      255, 91, 79, 158); // Default status color is gray for pending

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
              if (text != null && text.isNotEmpty)
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              if (text != null && text.isNotEmpty)
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

  void _rateSponsorships(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      double rating = 0; // Initial rating
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          width: 600, // Set the desired width
          height: 300, // Set the desired height
          child: SingleChildScrollView(
            child: Column(
              
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 48,
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
                        padding: EdgeInsets.all(12),
                        child: Text(
                          'Rate Sponsorship',
                          style: TextStyle(
                            fontSize: 20,
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
                  
                  height: 250, // Adjusted height
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Padding(
                    
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        
                        const Text(
                          'Rate this Sponsorship',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 10),
                   Center(
  child: RatingBar.builder(
    initialRating: rating,
    minRating: 1,
    direction: Axis.horizontal,
    allowHalfRating: true,
    itemCount: 5,
    itemSize: 40, // Adjust the size to your preference
    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
    itemBuilder: (context, _) => Icon(
      Icons.star,
       color: Colors.amber
    ),
    onRatingUpdate: (newRating) {
      rating = newRating;
      // Handle the rating update
    },
  ),
),
const SizedBox(height: 20),

                        Center(
                          
                          child: ElevatedButton(
                            onPressed: () {
                              // Handle submission of the rating
                              Navigator.of(context).pop();
                              _submitRating(widget.sponseeId,widget.EventId, rating) ; 
                              calculateRating(widget.sponseeId) ; 
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor:
                                  const Color.fromARGB(255, 51, 45, 81),
                              elevation: 20,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              'Rate',
                              style: TextStyle(
                                fontSize: 22,
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
        ),
      );
    },
  );
}

Future<void> _submitRating(String sponseeID, String eventId, double rate) async {
  try {
    final DatabaseReference database = FirebaseDatabase.instance.ref();

    // Construct the path to the specific offer
    final DatabaseReference offerRef = database.child('offers');

    // Use orderByChild and equalTo to filter offers based on EventId and sponseeId
    final DatabaseEvent event = await offerRef
        .orderByChild('EventId')
        .equalTo(eventId)
        .once();

    final DataSnapshot snapshot = event.snapshot;

    // Check if there is a matching offer
    if (snapshot.value != null) {
      final Map<dynamic, dynamic> offers = snapshot.value as Map<dynamic, dynamic>;

      // Iterate through the offers
      for (final entry in offers.entries) {
        final String key = entry.key as String;
        final Map<dynamic, dynamic> offer = entry.value as Map<dynamic, dynamic>;

        if (offer['sponseeId'] == sponseeID) {
          // Update the rating in the specific offer
          await offerRef.child(key).child('sponseeRating').set(rate);
          // Perform any additional actions or UI updates as needed
          setState(() {
            widget.rating = rate ; 
          });
  
            
                   break; // Exit the loop after updating the rating
        }
      }
    } else {
      print('No matching offer found.');
    }
  } catch (error) {
    print('Error submitting rating: $error');
    // Handle errors accordingly
  }
}

double ratingSum = 0 ; 
int count = 0 ; 
double calculateRating(String sponseeID) {
  final DatabaseReference database = FirebaseDatabase.instance.ref();

  database.child('offers').onValue.listen((rates) {
    if (rates.snapshot.value != null) {
      Map<dynamic, dynamic> offerData =
          rates.snapshot.value as Map<dynamic, dynamic>;
      offerData.forEach((key, value) {
        if (value['sponseeId'] == sponseeID) {
          if (value['sponseeRating'] != null) {
            ratingSum += value['sponseeRating'];
            count++;
          }
        }
      });

      // Update the 'Rate' value under the specified sponsorID in 'Sponsors'
      final DatabaseReference databaseSponsor = FirebaseDatabase.instance.ref();
      final DatabaseReference sponseeRef =
          databaseSponsor.child('Sponsees').child(sponseeID);
      sponseeRef.child('Rate').set((ratingSum/count).toStringAsFixed(1)) ;
    }
  });

  // Return 0 if the 'offers' data is null to avoid division by zero
  return ratingSum / count;
}


}