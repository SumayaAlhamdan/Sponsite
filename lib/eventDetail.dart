import 'package:flutter/material.dart';
//import 'package:sponsite/Detail.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:geocoding/geocoding.dart';
import 'package:sponsite/screens/Rating.dart';
import 'package:sponsite/widgets/customAppBarwithNav.dart';   
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';



class eventDetail extends StatefulWidget {
  const eventDetail(
      {
        Key? key,
      required this.DetailKey,
      required this.img,
      required this.location,
      required this.fullDesc,
      required this.startDate,
      required this.endDate,
      required this.Type,
      required this.Category,
      required this.startTime,
      required this.endTime,
      required this.notes,
      this.benefits,
      required this.isPast,
      required this.EVENTid,
      required this.NumberOfAttendees})
      : super(key: key);
      final String EVENTid ; 
  final String img;
  final String location;
  final String startDate;
  final String endDate;
  final String DetailKey;
  final String fullDesc;
  final String Type;
  final String Category;
  final String startTime;
  final String endTime;
  final String notes;
  final String? benefits;
  final bool isPast; 
  final String NumberOfAttendees;

  @override
  State<eventDetail> createState() => _Start();
}

class _Start extends State<eventDetail> {
  double screenWidth = 0;
  double screenHeight = 0;


  //bool isCurrentTabSelected = true;  Indicates whether "Current Events" tab is selected

  @override
  Widget build(BuildContext context) {
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
      print("here!!");
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

    return Scaffold(
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
    
      ElevatedButton.icon(
        onPressed: () {
        Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Rating(
                           EVENTid: widget.EVENTid,
                            EventName: widget.DetailKey,
                            
                           
                          
                          ),
                        ),
                        
                      );
                    
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
          primary: const Color.fromARGB( 255,91,79,158),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          padding: EdgeInsets.all(15), // Adjust padding as needed
        ),
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
                          const Divider(height: 30, thickness: 2),
                          _buildInfoRow(
                              Icons.calendar_today,
                              "${widget.startDate} - ${widget.endDate}",
                              "Date"),
                          _buildInfoRow(Icons.access_time,
                              "${widget.startTime}-${widget.endTime}", "Time"),
                          _buildInfoRow(Icons.people, widget.NumberOfAttendees,
                              "Attendees"),
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
                                          size: 40.0, // Customize the icon size
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
                                width: MediaQuery.of(context).size.width * 0.9,
                                child: buildMap(),
                              ),
                            ),
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
                            children:
                                widget.Category.split(',').map((category) {
                              return Chip(
                                label: Text(category.trim()),
                                backgroundColor:
                                    const Color.fromARGB(255, 255, 255, 255),
                                shadowColor:
                                    const Color.fromARGB(255, 91, 79, 158),
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


}
/*
          child: Column(
            children: [
              Container(
                color: Colors.grey[300], // Gray divider color
                width: screenWidth,
                height: 1,
                margin: const EdgeInsets.symmetric(
                  vertical: 20,
                ),
              ), //the divider
              SizedBox(
                height: 20, // Increase the space between the divider and the content
              ),
              // Tab Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  tabButton(
                    "Current Events",
                    isCurrentTabSelected,
                    onPressed: () {
                      // Handle "Current Events" tab click
                      setState(() {
                        isCurrentTabSelected = true;
                      });
                    },
                  ),
                  SizedBox(width: 40), // Add space between tab buttons
                  tabButton(
                    "Past Events",
                    !isCurrentTabSelected,
                    onPressed: () {
                      // Handle "Past Events" tab click
                      setState(() {
                        isCurrentTabSelected = false;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(
                height: 20, // Increase the space between the tabs and the content
              ),
              // Red Container (Event)
              item(
                "Vegetables.jpg",
                "CPC Competition",
                "Vegetables are parts of plants that are consumed by humans or other animals as food.",
                "Vegetables are parts of plants that are consumed by humans or other animals as food. The original meaning is still commonly used and is applied to plants collectively to refer to all edible plant matter, including the flowers, fruits, stems, leaves, roots, and seeds. An alternative definition of the term is applied somewhat arbitrarily, often by culinary and cultural tradition. It may exclude foods derived from some plants that are fruits, flowers, nuts, and cereal grains, but include savory fruits such as tomatoes and courgettes, flowers such as broccoli, and seeds such as pulses.",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget tabButton(String text, bool isSelected, {required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(isSelected ? Color.fromARGB(255, 106, 33, 134) : const Color.fromARGB(255, 255, 255, 255)),
        padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 40, vertical: 16)), // Adjust button size here
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          color: isSelected ? Colors.white : Color.fromARGB(225, 106, 33, 134),
          fontSize: 18, // Adjust font size here
        ),
      ),
    );
  }

  Widget item(String asset, String title, String desc, String fullDesc) {
    return GestureDetector(
     // onTap: () {
      //  Navigator.of(context).push(
        //  MaterialPageRoute(
         //   builder: (context) => DetailScreen(
            //  asset: asset,
            //  tag: title,
           //   fullDesc: fullDesc,
         //   ),
       //   ),
      //  );
     // },
      child: Container(
        height: screenWidth / 5,
        width: screenWidth,
        decoration: BoxDecoration(
          color: Color.fromRGBO(255, 255, 255, 1),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Color(0x0C000000),
              spreadRadius: 0,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        margin: EdgeInsets.only(
          bottom: screenWidth / 20,
        ),
        child: Row(
          children: [
            Hero(
              tag: title,
              child: Container(
                width: screenWidth / 2.8,
                height: screenWidth / 2.8,
                margin: EdgeInsets.only(
                  right: screenWidth / 20,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    "images/$asset",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Color.fromARGB(255, 106, 33, 134),
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        desc,
                        style: const TextStyle(
                          fontWeight: FontWeight.w300,
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ), //each event
    );
  }
} */