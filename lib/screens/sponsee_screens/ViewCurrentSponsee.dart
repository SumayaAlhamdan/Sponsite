import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sponsite/screens/eventDetail.dart';
import 'package:sponsite/screens/sponsee_screens/SponseeOffersList.dart';
import 'package:sponsite/widgets/customAppBar.dart';  

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

  void check() {
    if (user != null) {
      sponseeID = user?.uid;
      print('Sponsee ID: $sponseeID');
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

            if (value['SponseeID'] == sponseeID) {
              // Use key as EVENTid for the current event
              String EVENTid = key;
              //  print("The key value is " + key);
              //print("the var value is : ");
              //print(EVENTid);

              String timestampString = value['TimeStamp'] as String;

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
                notes:
                    value['Notes'] as String? ?? 'There are no notes available',
                benefits: value['Benefits'] as String? ?? '',
                NumberOfAttendees: value['NumberOfAttendees'] as String? ?? '',
                Category: categoryList,
                EVENTid: EVENTid,
                timeStamp: timestampString,
                // Assign the EVENTid to the Event object
              ));
            }
          });
          events.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));
        });
      }
    });
  }

  Widget listItem({required Event event, required bool isPast} ) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color.fromARGB(255, 255, 255, 255),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            height: 140,
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
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.EventName,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
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
                          child: Text(
                            event.NumberOfAttendees,
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
                SizedBox(   
                  height: 60,  
                child: Wrap(
                  spacing: 8,
                  children: event.Category.map((category) {
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
                ),    
                const SizedBox(
                  height: 20,   
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: GestureDetector(
                    onTap: () {
                      final categoriesString = event.Category.join(', ');
                     print("The event ID from class view current") ;  print(event.EVENTid) ; 
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
                            isPast : isPast,
                            EVENTid: event.EVENTid,
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
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                            color: Color.fromARGB(255, 91, 79, 158),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: Color.fromARGB(255, 91, 79, 158),
                        ),
                      ],
                    ),
                  ),
                ),
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
                    onPressed: isPast? () {
                      showDialog(
                        context:context,
                          builder: (BuildContext context){ return newPost(
                            eventID: event.EVENTid,
                            eventName: event.EventName,
                            userID : sponseeID as String ,
                          
                          );},
                      );
                    } : () {
                      print("This id from deema's class : ");
                      print(event.EVENTid);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SponseeOffersList(
                            EVENTid: event.EVENTid,
                            EventName: event.EventName,
                            startDate : event.startDate,
                            startTime : event.startTime,
                          
                          ),
                        ),
                        
                      );
                    
                    },
                    child: Text(
                      isPast? 'Post About it!' : 'View Offers',
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
    return DefaultTabController(
      length: 2, // Number of tabs (Current and Past)
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: const PreferredSize(
        preferredSize: Size.fromHeight(105), // Adjust the height as needed
        child: CustomAppBar(  
          title: 'My Events',
        ),
      ),
        body: Column(
          children: [ 
            Container(
              color: Color.fromARGB(255, 255, 255, 255),
              padding: const EdgeInsets.only( top: 50),
              child: TabBar(
                // Move the TabBar to the appBar's bottom property
                indicatorColor: Color.fromARGB(255, 51, 45, 81),
                tabs: const [
                  Tab(
                    child: Text(
                      'Current Events',
                      style: TextStyle(fontSize: 22),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Past Events',
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
    )      
      );  
  }

  Widget _buildCurrentEventsPage() {
  DateTime parseEventDateAndTime(String date, String time) {
  final dateTimeString = '$date $time';
  final format = DateFormat('yyyy-MM-dd hh:mm');
  print(format.parse(dateTimeString));
  return format.parse(dateTimeString);
}


  final now = DateTime.now();
  print(now);
final filteredEvents = events.where((event) {
  final eventDateTime = parseEventDateAndTime(event.endDate, event.startTime);
  return eventDateTime.isAfter(now);
}).toList();
if(filteredEvents.isNotEmpty){
  return Padding(
    padding: const EdgeInsets.only(top: 1),
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
                childAspectRatio: 0.9,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: filteredEvents.length,
              itemBuilder: (BuildContext context, int index) {
                Event event = filteredEvents[index];
                return listItem(event: event , isPast: false);
              },
            ),
          ),
        ),
      ],
    ),
  );
}else {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 282,
          height: 284,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/Add Files (1).png'),
              fit: BoxFit.fitWidth,
            ),
          ),
        ),
        SizedBox(height: 20), // Adjust the spacing as needed
        Text(
          'There are no current events yet',
          style: TextStyle(
            fontSize: 24, // Adjust the font size as needed
          ),
        ),
      ],
    );
  }}

Widget _buildPastEventsPage() {
  DateTime parseEventDateAndTime(String date, String time) {
  final dateTimeString = '$date $time';
  final format = DateFormat('yyyy-MM-dd hh:mm');
  print(format.parse(dateTimeString));
  return format.parse(dateTimeString);
}

  final now = DateTime.now();
final filteredEvents = events.where((event) {
  final eventDateTime = parseEventDateAndTime(event.endDate, event.startTime);
  return eventDateTime.isBefore(now);
}).toList();
filteredEvents.sort((a, b) => parseEventDateAndTime(b.startDate, b.startTime).compareTo(parseEventDateAndTime(a.startDate, a.startTime)));

  if (filteredEvents.isNotEmpty) {
    return Padding(
      padding: const EdgeInsets.only(top: 1),
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
                  childAspectRatio: 0.9,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: filteredEvents.length,
                itemBuilder: (BuildContext context, int index) {
                  Event event = filteredEvents[index];
                  return listItem(event: event , isPast: true);
                },
              ),
            ),
          ),
        ],
      )
    );
  } else {
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
          'There Are No Past Events Yet',
          style: TextStyle(
            fontSize: 24, // Adjust the font size as needed
          ),
        ),
      ],
    );
  }
}}

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
  final String EVENTid;
  final String timeStamp;

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
    required this.EVENTid,
    required this.timeStamp,
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