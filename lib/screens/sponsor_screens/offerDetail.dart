import 'package:flutter/material.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:sponsite/screens/sponsor_screens/ViewOffersSponsor.dart';
class offertDetail extends StatefulWidget {
const offertDetail({Key? key, required this.DetailKey, required this.img, required this.location, required this.fullDesc, required this.startDate,required this.endDate, required this.Type , required this.eventCategory , required this.startTime , required this.endTime ,required this.eventNotes , this.benefits , required this.NumberOfAttendees, required this.EventId, required this.Category, required this.notes }) : super(key: key);
 final String img;
 final String location ;
 final String startDate;
  final String endDate;
  final String DetailKey;
  final String fullDesc ;
  final String Type ;
  final String eventCategory ;
  final String startTime ;
    final String endTime ;
  final String eventNotes ; 
  final String? benefits ;
  final String NumberOfAttendees ;
  final String EventId;
  final String Category;
  final String notes;

  @override
  State<offertDetail> createState() => _Start();
}
class _Start extends State<offertDetail> {
  double screenWidth = 0;
  double screenHeight = 0;
  //bool isCurrentTabSelected = true;  Indicates whether "Current Events" tab is selected
bool isExpanded = false; 
  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
  title: const Text(
    'Event Details',
    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
  ),
  backgroundColor: const Color.fromARGB(255, 51, 45, 81),
  elevation: 0, // Remove the shadow
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.only(
      bottomLeft: Radius.circular(20),
      bottomRight: Radius.circular(20),
    ),
  ),
  leading: IconButton(
    icon: const Icon(Icons.arrow_back, color: Colors.white),
    onPressed: () {
         Navigator.of(context).pop();
    },
  ),
),


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
                     widget.img.isNotEmpty?widget.img: 'https://media.istockphoto.com/id/1369748264/vector/abstract-white-background-geometric-texture.jpg?s=612x612&w=0&k=20&c=wFsN0D9Ifrw1-U8284OdjN25JJwvV9iKi9DdzVyMHEk=',
               fit: BoxFit.cover,
                  ),
                ),
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
                          Text(
                            widget.DetailKey,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 32,
                              color: Colors.black87,
                            ),
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
                          _buildInfoRow(Icons.location_on, widget.location, "Location"),
                          _buildInfoRow(Icons.calendar_today, "${widget.startDate} - ${widget.endDate}", "Date"),
                          _buildInfoRow(Icons.access_time,  "${widget.startTime}-${widget.endTime}", "Time"),
                          _buildInfoRow(Icons.person, widget.NumberOfAttendees, "Attendees"),
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
                            children: widget.eventCategory.split(',').map((category) {
                              return Chip(
                                label: Text(category.trim()),
                                backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                                shadowColor: const Color.fromARGB(255,91,79,158),
                                elevation: 3,
                                labelStyle: const TextStyle(
                                  color: Color.fromARGB(255,91,79,158),
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
                          const SizedBox(height: 20),
                          Container(
                  decoration: BoxDecoration(
                    border: Border.all(width: 1), // Add a border
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: EdgeInsets.all(0),
              child: ExpansionTileCard(
              borderRadius: const BorderRadius.all(Radius.circular(10.0)),
              baseColor: Color.fromARGB(255, 255, 255, 255),
              expandedColor:  Color.fromARGB(255, 157, 151, 190),
            title:Text(
            "Offer Details",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            ),
        children: <Widget>[
        Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            color: Color.fromARGB(255, 157, 151, 190),
          ),
          padding: EdgeInsets.all(12.0),
          alignment: Alignment.bottomLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                children: widget.Category.split(',').map((category) {
                  return Chip(
                    label: Text(category.trim()),
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    shadowColor: const Color.fromARGB(255, 91, 79, 158),
                    elevation: 3,
                    labelStyle: const TextStyle(
                      color: Color.fromARGB(255, 91, 79, 158),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(width: 20),
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
              const SizedBox(width: 10),
            ],
          ),
        ),],
),
                      )],
      )),
)

                        
                ),
                      
                      )
        )
        )
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

