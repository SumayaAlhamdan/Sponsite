import 'package:flutter/material.dart';
//import 'package:sponsite/Detail.dart';

class eventDetail extends StatefulWidget {
  const eventDetail({Key? key, required this.DetailKey, required this.img, required this.location, required this.fullDesc, required this.date, required this.Type , required this.Category , required this.time , required this.notes , this.benefits , required this.NumberOfAttendees}) : super(key: key);
 final String img;
 final String location ;
 final String date;
  final String DetailKey;
  final String fullDesc ;
  final String Type ;
  final String Category ;
  final String time ;
  final String notes ; 
  final String? benefits ;
  final String NumberOfAttendees ;

  @override
  State<eventDetail> createState() => _Start();
}
class _Start extends State<eventDetail> {
  double screenWidth = 0;
  double screenHeight = 0;
  //bool isCurrentTabSelected = true;  Indicates whether "Current Events" tab is selected

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
  title: Text(
    'Event Details',
    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
  ),
  backgroundColor: Color.fromARGB(255, 51, 45, 81),
  elevation: 0, // Remove the shadow
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
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20),
                        Text(
                          widget.DetailKey,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          widget.Type,
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.black87,
                          ),
                        ),
                        Divider(height: 30, thickness: 2),
                        _buildInfoRow(Icons.location_on, widget.location, "Location"),
                        _buildInfoRow(Icons.calendar_today, widget.date, "Date"),
                        _buildInfoRow(Icons.access_time, widget.time, "Time"),
                        _buildInfoRow(Icons.person, "${widget.NumberOfAttendees}", "Attendees"),
                        Text(
                          "Categories",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          children: widget.Category.split(',').map((category) {
                            return Chip(
                              label: Text(category.trim()),
                              backgroundColor: Color.fromARGB(255, 255, 255, 255),
                              shadowColor: Color.fromARGB(255,91,79,158),
                              elevation: 3,
                              labelStyle: TextStyle(
                                color: Color.fromARGB(255,91,79,158),
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 20),
                        Text(
                          "Benefits",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          widget.benefits ?? "No benefits available",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          "Notes",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                           (widget.notes != null && widget.notes.isNotEmpty)
                              ? widget.notes
                              : "There are no notes available",
                          style: TextStyle(
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
            color: Color.fromARGB(255, 91, 79, 158),
          ),
          SizedBox(width: 10), // Adjust the spacing as needed
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              Text(
                text,
                style: TextStyle(
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