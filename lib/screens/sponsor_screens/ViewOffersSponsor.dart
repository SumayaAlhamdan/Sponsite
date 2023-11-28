import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sponsite/screens/sponsor_screens/offerDetail.dart';
import 'package:sponsite/screens/view_others_profile.dart';
import 'package:sponsite/widgets/customAppBar.dart'; 
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';

class ViewOffersSponsor extends StatefulWidget {
  const ViewOffersSponsor({Key? key}) : super(key: key);

  @override
  _ViewOffersSponsorState createState() => _ViewOffersSponsorState();
}

class _ViewOffersSponsorState extends State<ViewOffersSponsor> {
  List<Event> events = [];
  List<Offer> offers = [];
 Offer? offer;


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
@override
void dispose() {
  // Cancel timers or stop animations here
  super.dispose();
}


  Widget listItem({required Event event, required Offer offer,required bool isPast}) { 
    Color statusColor = const Color.fromARGB(
        255, 91, 79, 158); // Default status color is gray for pending
    bool isAccepted = offer.status == 'Accepted' ;
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
        SizedBox(height: 8),  
          SizedBox(
            width: double.infinity,
            height: 180,  

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
                  height: 9  ,   
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
                            isPast : isPast,
                            sponsorId: sponsorID,
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
          if(isAccepted && isPast)
          Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 91, 79, 158),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed:() {
                      showDialog(
                        context:context,
                          builder: (BuildContext context){ return newPost(
                            eventID: event.EventId,
                            eventName: event.EventName,
                            userID : sponsorID as String ,
                          
                          );},
                      );
                    },
                    child: Text(
                      'Post About it!',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
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
  DateTime parseEventDateAndTime(String date, String time) {
    final dateTimeString = '$date $time';
    final format = DateFormat('yyyy-MM-dd hh:mm');
    return format.parse(dateTimeString);
  }

  final now = DateTime.now();
  final filteredEvents = events.where((event) {
    final eventDateTime = parseEventDateAndTime(event.endDate, event.startTime);
    return eventDateTime.isAfter(now);
  }).toList();

 final filteredEventsWithOffers = filteredEvents.where((event) {
  return offers.any((offer) => offer.EventId == event.EventId);
}).toList();

  return SafeArea(
    child: Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 50.0),
          ),
          Expanded(
            child: filteredEvents.isEmpty
                ? Center(
                    child: Column(
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
                          'No current events available',
                          style: TextStyle(
                            fontSize: 24,
                            // Adjust the font size as needed
                          ),
                        ),
                      ],
                    ),
                  )
                : Scrollbar(
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.70,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: filteredEventsWithOffers.length,
                      itemBuilder: (BuildContext context, int index) {
                        Event event = filteredEventsWithOffers[index];
                        Offer? offer;

                        for (Offer o in offers) {
                          if (o.EventId == event.EventId) {
                          
                            offer = o;
                            break;
                          }
                        }

                        if (offer != null) {
                          return listItem(event: event, offer: offer, isPast:false);
                        
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
  DateTime parseEventDateAndTime(String date, String time) {
    final dateTimeString = '$date $time';
    final format = DateFormat('yyyy-MM-dd hh:mm');
    return format.parse(dateTimeString);
  }

  final now = DateTime.now();
  final filteredEvents = events.where((event) {
    final eventDateTime = parseEventDateAndTime(event.endDate, event.startTime);
    return eventDateTime.isBefore(now);
  }).toList();

  final filteredEventsWithOffers = filteredEvents.where((event) {
  return offers.any((offer) => offer.EventId == event.EventId);
}).toList();

  if (filteredEvents.isEmpty) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/Time.png',
            width: 282,
            height: 284,
            fit: BoxFit.fitWidth,
          ),
          const SizedBox(height: 20),
          Text(
            'No past events available',
            style: TextStyle(
              fontSize: 24,
              // Adjust the font size as needed
            ),
          ),
        ],
      ),
    );
  }
else { 
  return SafeArea(
  child: Padding(
    padding: const EdgeInsets.only(top: 15),
    child: Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 50.0),
        ),
        Expanded(
          child: Scrollbar(
            child: GridView.builder(
  shrinkWrap: true,
  physics: const BouncingScrollPhysics(),
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    childAspectRatio: 0.70,
    crossAxisSpacing: 8,
    mainAxisSpacing: 8,
  ),
  itemCount: filteredEventsWithOffers.length,
  itemBuilder: (BuildContext context, int index) {
    Event event = filteredEventsWithOffers[index];
    Offer? offer;

    for (Offer o in offers) {
      if (o.EventId == event.EventId) {
        offer = o;
        break;
      }
    }
if (offer != null ) 
    return listItem(event: event, offer: offer, isPast: true);
  },
),
          ),
        ),
      ],
    ),
  ),
);
}
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
                  );
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


class newPost extends StatefulWidget {
final String eventID ;
final String userID ;
final String eventName ;

newPost({
required this.eventID ,
required this.userID ,
required this.eventName , 
});

@override
_newPostState createState() => _newPostState() ;
}
class _newPostState extends State<newPost>{
  File? _imageFile;
   TextEditingController notesController = TextEditingController();
  final DatabaseReference database = FirebaseDatabase.instance.ref();
  final TextEditingController _imageController =
      TextEditingController(text: 'No image selected');
  User? user = FirebaseAuth.instance.currentUser;

  @override
  initState() {
    super.initState();
  }
   @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }
  void _showEmptyFormAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Theme(
            data:
                Theme.of(context).copyWith(dialogBackgroundColor: Colors.white),
            child: AlertDialog(
              title: const Text('Empty Post'),
              // backgroundColor: Colors.white,
              content: const Text(
                'Your post should not be empty',
                style: TextStyle(fontSize: 20),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'OK',
                    style: TextStyle(color: Color.fromARGB(255, 51, 45, 81)),
                  ),
                ),  
              ],
            ));
      },
    );
  }
  //image methods //

  Future<void> _removeImage() async {
    setState(() {
      _imageFile = null;
      _selectedImageBytes = null;

      print('image deleted');
    });
  }

  String? _selectedImagePath;
  Uint8List? _selectedImageBytes;

  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    final PickedFile? pickedFile =
        await imagePicker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final File imageFile = File(pickedFile.path);
      _selectedImageBytes = await convertImageToBytes(imageFile);
      setState(() {
        _imageFile = File(pickedFile.path);
        _selectedImagePath = pickedFile.path;
        _imageController.text = _selectedImagePath ?? '';
        print('image picked');
      });
    }
  }

  Future<String> _uploadImage(File imageFile) async {
    try {
      final firebase_storage.Reference storageReference = firebase_storage
          .FirebaseStorage.instance
          .ref()
          .child('event_images')
          .child(
              '${DateTime.now().millisecondsSinceEpoch}.${imageFile.path.split('.').last}');

      final uploadTask = storageReference.putFile(imageFile);

      final firebase_storage.TaskSnapshot storageTaskSnapshot =
          await uploadTask.whenComplete(() => null);

      final String imageURL = await storageTaskSnapshot.ref.getDownloadURL();
      print('image uploaded');
      return imageURL;
    } catch (e) {
      print('Error uploading image: $e');
      return '';
    }
  }

  Future<Uint8List?> convertImageToBytes(File? imageFile) async {
    Uint8List? bytes;
    if (imageFile != null) {
      // Read the file as bytes
      List<int> imageBytes = await imageFile.readAsBytes();
      // Convert the list of ints to Uint8List
      bytes = Uint8List.fromList(imageBytes);
    }
    return bytes;
  }

  String getButtonLabel() {
    return _selectedImageBytes != null ? 'Change Image' : 'Upload Image';
  }
  
  void _newPost() async {
    DatabaseReference postsRef = database.child('posts');
    if(notesController.text.trim().isEmpty ){
      _showEmptyFormAlert();
    }
    else{
      newPost post = newPost(
eventID: widget.eventID,
userID: widget.userID,
eventName: widget.eventName ,
        );
         DatabaseReference newPostRef = postsRef.push();
         final String imageUploadResult;
        if (_imageFile != null) {
          imageUploadResult = await _uploadImage(_imageFile!);
        } else {
          imageUploadResult = '';
        }
        final String timestamp = DateTime.now().toString();
         await newPostRef.set({
            "EventId": post.eventID,
            "userId": post.userID,
            "EventName": post.eventName,
            "notes": notesController.text ,
            "TimeStamp": timestamp ,
            "img": imageUploadResult ,
          });
          setState(() {
            notesController.clear();  
          }); 
          Navigator.of(context).pop();
          // Show a success message
          showDialog(
            context: context,
            builder: (context) {
              Future.delayed(const Duration(seconds: 3), () {
                Navigator.of(context).pop(true);
              });
              return Theme(
                data: Theme.of(context)
                    .copyWith(dialogBackgroundColor: Colors.white),
                child: AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Color.fromARGB(255, 91, 79, 158),
                        size: 48,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Your Post has been posted successfully!',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
    }
  }
  @override
  Widget build(BuildContext context) {
    print('Event Name: ${widget.eventName}');
  return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
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
                   Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'New post for ${widget.eventName}',
                      style: TextStyle(
                        fontSize: 30,
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
              decoration: const BoxDecoration(
                color: Colors.white, // Changed to white
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Row(
                      children: [
                        Text(
                          'Upload a photo of the event!',
                          style: TextStyle(
                            fontSize: 23,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 5),
                      ],
                    ),
                    SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_selectedImageBytes != null)
                          Image.memory(
                            _selectedImageBytes!,
                            width: 400,
                            height: 500,
                          )
                        else
                          Container(), // Placeholder if no image is selected
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            ElevatedButton.icon(
                                icon: Icon(Icons.image_outlined , color: Colors.white,),
                                onPressed: _selectedImageBytes != null
                                    ? _pickImage
                                    : _pickImage,
                                label: Text(getButtonLabel() , style: TextStyle(color: Colors.white),),
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all<Color>(
                                        const Color.fromARGB(255, 51, 45, 81)),
                                    //Color.fromARGB(255, 207, 186, 224),), // Background color
                                    textStyle:
                                        MaterialStateProperty.all<TextStyle>(
                                            const TextStyle(
                                                fontSize: 16)), // Text style
                                   // padding: MaterialStateProperty.all<
                                     //       EdgeInsetsGeometry>(
                                       // const EdgeInsets.all(16)), // Padding
                                    elevation:
                                        MaterialStateProperty.all<double>(
                                            1), // Elevation
                                    shape:
                                        MaterialStateProperty.all<OutlinedBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            30), // Border radius
                                        side: const BorderSide(
                                            color: Color.fromARGB(255, 255, 255,
                                                255)), // Border color
                                      ),
                                    ),
                                    minimumSize: MaterialStateProperty.all<Size>(const Size(200, 50))) // Dynamically set the button labelText('Upload Image'),
                                ),
                            SizedBox(height: 10),
                            if (_selectedImageBytes != null)
                              TextButton.icon(
                                icon: Icon(Icons.delete_forever_outlined),
                                onPressed: _removeImage,
                                label: Text(''),
                                //child: Text('Remove Image'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                    const SizedBox(height: 17),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: TextFormField(
                          controller: notesController,
                          maxLength: 600,
                          decoration: const InputDecoration(
                            labelText: 'What you would like to share? * ',
                            //border: OutlineInputBorder(),
                          ),
                           autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Field must not left empty';
                      }
                    },
                          style: const TextStyle(fontSize: 20),
                          maxLines: 9,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          _newPost();
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
                          'Post Now',
                          style: TextStyle(
                            fontSize: 20,
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
    );
  } 
}
