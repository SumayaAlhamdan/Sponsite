import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:sponsite/screens/sponsee_screens/sponsee_home_screen.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(const MyApp());
// }

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'New Event',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const MyHomePage(),
    );
  }
}
//   Widget build(BuildContext context) {
//     // const screenHeight =  MediaQuery.of(context).size.height;
//     //const screenWidth =  MediaQuery.of(context).size.width;

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: Text(
//           'New Event',
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
//         ),
//         backgroundColor: Color.fromARGB(255, 51, 45, 81),
//         elevation: 0, // Remove the shadow
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.only(
//             bottomLeft: Radius.circular(20),
//             bottomRight: Radius.circular(20),
//           ),
//         ),
//       ),
//     );
//   }
// }

User? user = FirebaseAuth.instance.currentUser;
String? sponseeID;

void check() {
  if (user != null) {
    sponseeID = user?.uid;
    print('Sponsor ID: $sponseeID');
  } else {
    print('User is not logged in.');
  }
}

Widget _titleContainer(String myTitle) {
  return Text(
    myTitle,
    style: TextStyle(
      color: Colors.black,
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
    ),
  );
}

class FilterChipWidget extends StatefulWidget {
  final String chipName;
  final Function(String) onChipCreated;
  final Function(String, bool) onChipSelected;

  FilterChipWidget({
    required this.chipName,
    required this.onChipCreated,
    required this.onChipSelected,
  }) : super();

  @override
  _FilterChipWidgetState createState() => _FilterChipWidgetState();
}

class _FilterChipWidgetState extends State<FilterChipWidget> {
  var _isSelected = false;
  List<String> customCategories = [];

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(
        widget.chipName,
        style: TextStyle(fontSize: 25),
      ),
      labelStyle: TextStyle(
        color: const Color(0xff6200ee),
        fontSize: 16.0,
        fontWeight: FontWeight.bold,
      ),
      selected: _isSelected,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      backgroundColor: const Color(0xffededed),
      onSelected: (isSelected) {
        if (widget.chipName == 'Other' && isSelected) {
          _showTextInputDialog();
        } else {
          setState(() {
            widget.onChipSelected(widget.chipName, isSelected);
            _isSelected = isSelected;
          });
        }
      },
      selectedColor: const Color(0xffeadffd),
    );
  }

  Future<void> _showAlertDialog(String message) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Warning',
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
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Color.fromARGB(255, 51, 45, 81)),
                  //Color.fromARGB(255, 207, 186, 224),), // Background color
                  textStyle: MaterialStateProperty.all<TextStyle>(
                      const TextStyle(fontSize: 16)), // Text style
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.all(16)), // Padding
                  elevation: MaterialStateProperty.all<double>(1), // Elevation
                  shape: MaterialStateProperty.all<OutlinedBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // Border radius
                      side: const BorderSide(
                          color: Color.fromARGB(
                              255, 255, 255, 255)), // Border color
                    ),
                  ),
                  minimumSize:
                      MaterialStateProperty.all<Size>(const Size(200, 50))),
            ),
          ],
        );
      },
    );
  }

  void _showTextInputDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        String newChipName = "";
        return AlertDialog(
          title: Text('Create new category'),
          content: TextField(
            onChanged: (text) {
              newChipName = text;
            },
            decoration: const InputDecoration(labelText: "Enter Category"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color.fromARGB(255, 51, 45, 81)),
              ),
            ),
            TextButton(
                child: const Text("Create Category",
                    style: TextStyle(color: Color.fromARGB(255, 51, 45, 81))),
                onPressed: () {
                  if (newChipName.isNotEmpty) {
                    if (!selectedChips.contains(newChipName) &&
                        !customCategories.contains(newChipName)) {
                      Navigator.of(context).pop();
                      widget.onChipCreated(newChipName);
                      customCategories.add(newChipName);
                    } else {
                      _showAlertDialog("Category already exists.");
                    }
                  }
                }),
          ],
        );
      },
    );
  }
}

class CustomRadioButton extends StatelessWidget {
  final String value;
  final String? groupValue;
  final Function(String?) onChanged;
  final double width; // New property for width
  final double height; // New property for height

  CustomRadioButton({
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.width = 100.0, // Default width
    this.height = 40.0, // Default height
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onChanged(value);
      },
      child: Container(
        width: width, // Set width
        height: height, // Set height
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(height / 2), // Make it round
          border: Border.all(
            color: (groupValue == value) ? Colors.green : Colors.black,
          ),
          color: (groupValue == value) ? Colors.green : Colors.white,
        ),
        child: Center(
          child: Text(
            value,
            style: TextStyle(
              color: (groupValue == value) ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

DateTime? selectedStartDate;
DateTime? selectedEndDate;
TimeOfDay? selectedStartTime;
TimeOfDay? selectedEndTime;
List<String> eventTypesList = [];
String? selectedEventType;
List<String> selectedChips = [];

class _MyHomePageState extends State<MyHomePage> {
  File? _imageFile;
  List<String> eventTypesList = [];

  void initState() {
    super.initState();
    check();
    fetchEventTypesFromDatabase();
    _imageController.text =
        'No image selected'; // Initialize the controller text
  }

  bool areRequiredFieldsFilled() {
    return _selectedEventType != null &&
        EnameController.text.isNotEmpty &&
        selectedStartDate != null &&
         selectedEndDate != null && 
         selectedStartTime != null &&
        selectedEndTime != null &&
        numofAttendeesController.text.isNotEmpty &&
        selectedChips.isNotEmpty &&
        benefitsController.text.isNotEmpty;
  }

  Future<void> fetchEventTypesFromDatabase() async {
    final eventTypes = await fetchEventTypes();

    setState(() {
      eventTypesList = eventTypes;
    });
  }

  final String timestamp = DateTime.now().toString();

  void _postNewEvent(
    String type,
    String eventName,
    String location,
    String startDate,
    String endDate,
    String startTime,
    String endTime,
    String numofAt,
    List<String> categ,
    String benefits,
    String notes,
  ) async {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      try {
        final String imageUploadResult;
        if (_imageFile != null)
          imageUploadResult = await _uploadImage(_imageFile!);
        else
          imageUploadResult = '';

        dbref.child('sponseeEvents').push().set({
          'SponseeID': sponseeID,
          'EventType': type,
          'EventName': eventName,
          'Location': location,
          'startDate': startDate,
          'endDate' : endDate, 
          'startTime': startTime,
          'endTime': endTime , 
          'NumberOfAttendees': numofAt,
          'Category': categ,
          'Benefits': benefits,
          'img': imageUploadResult,
          'Notes': notes,
          'TimeStamp': timestamp,
        });
        runApp(const SponseeHome());
        print('sent to database!');
        print(type);
        print(eventName);
        print(location);
        print(startDate);
        print(endDate);
        print(startTime);
        print(endTime);
        print(numofAt);
        print(categ);
        print(benefits);
        print(notes);
        print(sponseeID);
        print(timestamp);
      } catch (e) {
        print('Error sending data to DB: $e');
      }
    }
  }

  Future<void> _selectStartDateAndTime(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          selectedStartDate = pickedDate;
          selectedStartTime = pickedTime;
          if (selectedStartDate != null && selectedStartTime != null)
            _startDatetimeController.text =
                '${selectedStartDate!.toLocal().toString().substring(0, 10)} , ${selectedStartTime!.format(context)}';
        });
      }
    }
  }

bool before = false;

Future<void> _selectEndDateAndTime(BuildContext context) async {
  final pickedDate = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime.now(),
    lastDate: DateTime(2101),
  );

  if (pickedDate != null) {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      if (selectedStartDate != null) {
        DateTime startDateTime = DateTime.parse(selectedStartDate.toString())
            .add(Duration(hours: selectedStartTime!.hour, minutes: selectedStartTime!.minute));
        DateTime endDateTime = pickedDate.add(Duration(hours: pickedTime.hour, minutes: pickedTime.minute));

        if (endDateTime.isBefore(startDateTime)) {
          before = true;
        }
      }

      setState(() {
        selectedEndDate = pickedDate;
        selectedEndTime = pickedTime;
        if (selectedEndDate != null && selectedEndTime != null)
          _endDatetimeController.text =
              '${selectedEndDate!.toLocal().toString().substring(0, 10)} , ${selectedEndTime!.format(context)}';
      });
    }
  }
}



  int _activeStepIndex = 0;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController EnameController = TextEditingController();
  final TextEditingController LocationController = TextEditingController();
  final TextEditingController numofAttendeesController =
      TextEditingController();

  final TextEditingController benefitsController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController _imageController =
      TextEditingController(text: 'No image selected');
  final TextEditingController _startDatetimeController =
      TextEditingController(text: 'No start Date & Time selected');
      final TextEditingController _endDatetimeController =
      TextEditingController(text: 'No end Date & Time selected');
  TextEditingController textEditingController = TextEditingController();

  final DatabaseReference dbref = FirebaseDatabase.instance.reference();

  String _selectedEventType = '';
  bool showCategoryValidationMessage = false;
  bool showRequiredValidationMessage = false;

  Future<void> _deleteImage() async {
    setState(() {
      _imageFile = null;
      _selectedImagePath = null;
      _imageController.text = 'No image selected';
      print('image deleted');
    });
  }

  String? _selectedImagePath;

  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    final PickedFile? pickedFile =
        await imagePicker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
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

  Future<List<String>> _fetchCategories() async {
    final categories = <String>[];

    try {
      final DatabaseEvent dataSnapshot = await FirebaseDatabase.instance
          .reference()
          .child('Categories')
          .once();

      if (dataSnapshot.snapshot.value != null) {
        final categoryData =
            dataSnapshot.snapshot.value as Map<dynamic, dynamic>;
        categoryData.forEach((key, value) {
          categories.add(value.toString());
        });
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }

    return categories;
  }

  Future<List<String>> fetchEventTypes() async {
    final eventTypes = <String>[];

    try {
      final DatabaseEvent dataSnapshot =
          await FirebaseDatabase.instance.reference().child('EventType').once();

      if (dataSnapshot.snapshot.value != null) {
        final Map<dynamic, dynamic> eventTypesMap =
            dataSnapshot.snapshot.value as Map<dynamic, dynamic>;

        eventTypesMap.forEach((key, value) {
          eventTypes.add(value.toString());
        });
      }
    } catch (e) {
      print('Error fetching event types: $e');
    }

    return eventTypes;
  }

  Widget _buildCategoryChips() {
    return FutureBuilder<List<String>>(
      future: _fetchCategories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          final categories = snapshot.data!;
          categories.add("Other");
          return Wrap(
            spacing: 5.0,
            runSpacing: 3.0,
            children: categories.map((category) {
              final isSelected = selectedChips.contains(category);

              return FilterChipWidget(
                chipName: category,
                onChipCreated: _handleChipCreation,
                onChipSelected: (chipName, selected) {
                  _handleChipSelection(chipName, selected);
                },
              );
            }).toList(),
          );
        } else {
          return Text('No categories available.');
        }
      },
    );
  }

  void _showpostcancel() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Post Event",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
          ),
          content: Text(
            "Are you sure you want to cancel this event?",
          ),
          backgroundColor: Colors.white,
          elevation: 0, // Remove the shadow
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),

          actions: [
            TextButton(
              child: const Text("No",
                  style: TextStyle(color: Color.fromARGB(255, 51, 45, 81))),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Yes",
                  style: TextStyle(color: Color.fromARGB(255, 51, 45, 81))),
              onPressed: () {
                runApp(const SponseeHome());
              },
            ),
          ],
        );
      },
    );
  }
//HERE
  void _showpostconfirm() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Post Event",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
          ),
          content: Text(
            "Are you sure you want to post this event?",
          ),
          backgroundColor: Colors.white,
          elevation: 0, // Remove the shadow
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),

          actions: [
            TextButton(
              child: const Text("Cancel",
                  style: TextStyle(color: Color.fromARGB(255, 51, 45, 81))),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Post",
                  style: TextStyle(color: Color.fromARGB(255, 51, 45, 81))),
              onPressed: () {
                String type = _selectedEventType;
                String ename = EnameController.text;
                String location = LocationController.text;
                String startDate =
                    selectedStartDate!.toLocal().toString().substring(0, 10);
                String startTime = selectedStartTime!.format(context);
                 String endDate =
                    selectedEndDate!.toLocal().toString().substring(0, 10);
                String endTime = selectedEndTime!.format(context);
                String numOfAt = numofAttendeesController.text;
                List<String> categ = selectedChips;
                String benefits = benefitsController.text;
                String notes = notesController.text;
                _postNewEvent(type, ename, location, startDate, endDate, startTime,endTime, numOfAt, categ,
                    benefits, notes);
                //_showSuccessSnackbar(context);
              },
            ),
          ],
        );
      },
    );
  }

  Widget CustomRadioButton({
    required String value,
    required String? groupValue,
    void Function(String?)? onChanged,
  }) {
    return GestureDetector(
      onTap: () {
        onChanged?.call(value);
      },
      child: Container(
        width: 150.0, // Custom width
        height: 60.0, // Custom height
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: (groupValue == value)
                ? Color.fromARGB(255, 51, 45, 84)
                : Colors.black,
          ),
          color: (groupValue == value)
              ? Color.fromARGB(255, 51, 45, 84)
              : Colors.white,
        ),
        child: Center(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: (groupValue == value) ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventTypesRadioList() {
    return Column(
      children: [
        Row(
          mainAxisAlignment:
              MainAxisAlignment.center, // Center the children horizontally

          children: eventTypesList.sublist(0, 4).map((eventType) {
            return Row(
              children: [
                SizedBox(width: 8.0), // Add space between buttons
                Center(
                    child: Container(
                        width: 150.0, // Custom width
                        height: 60.0, // Custom height
                        child: CustomRadioButton(
                          value: eventType,
                          groupValue: _selectedEventType,
                          onChanged: (value) {
                            setState(() {
                              _selectedEventType = value as String;
                            });
                          },
                        )))
              ],
            );
          }).toList(),
        ),
        SizedBox(height: 25),
        Row(
          mainAxisAlignment:
              MainAxisAlignment.center, // Center the children horizontally

          children: eventTypesList.sublist(4, 7).map((eventType) {
            return Row(
              children: [
                SizedBox(width: 8.0), // Add space between buttons
                Center(
                    child: Container(
                  width: 120.0, // Custom width
                  height: 60.0, // Custom height
                  child: CustomRadioButton(
                    value: eventType,
                    groupValue: _selectedEventType,
                    onChanged: (value) {
                      setState(() {
                        _selectedEventType = value as String;
                      });
                    },
                  ),
                ))
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  List<Step> stepList() => [
        Step(
          state: _activeStepIndex <= 0 ? StepState.indexed : StepState.complete,
          isActive: _activeStepIndex >= 0,
          title: const Text('Event Details',
              style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.normal)),
          content: Container(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "About your event",
                    style: TextStyle(fontSize: 40),
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment
                        .center, // Center the children horizontally
                    children: [
                      Text("Event Type *", style: TextStyle(fontSize: 18)),
                      const SizedBox(
                        height: 8,
                      ),
                    ]),
                Column(
                  children: <Widget>[
                    const SizedBox(height: 10),
                    if (eventTypesList.isEmpty)
                      const CircularProgressIndicator()
                    else
                      _buildEventTypesRadioList(),
                  ],
                ),
                const SizedBox(
                  height: 25.0,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: TextFormField(
                    controller: EnameController,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: 'Event Name *',
                      prefixIcon: Icon(Icons.text_fields,
                          size: 24, color: Colors.black),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Event name is required';
                      }
                      print("event name not null");
                      return null;
                    },
                  ),
                ),
                const SizedBox(
                  height: 25.0,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: TextFormField(
                    controller: LocationController,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: 'Event Address',
                      prefixIcon: Icon(Icons.location_pin,
                          size: 24, color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 25.0,
                ),
                SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: TextFormField(
                      controller: _startDatetimeController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Select start Date and Time *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(
                          Icons.calendar_month,
                          size: 24,
                          color: Colors.black,
                        ),
                      ),
                      onTap: () {
                        _selectStartDateAndTime(context);
                      },
                      
                    )),
                const SizedBox(height: 25.0),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: TextFormField(
                      controller: _endDatetimeController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Select end Date and Time *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(
                          Icons.calendar_month,
                          size: 24,
                          color: Colors.black,
                        ),
                      ),
                      onTap: () {
                        _selectEndDateAndTime(context); 
                      },
                       validator: (Value) {
                      if (before == true) {
                        return 'The End Date Can Not Be Before The Start Date';
                      }
                      return null;
                    },
                    )),
                    const SizedBox(height: 25.0),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: TextFormField(
                    controller: numofAttendeesController,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: 'Number of attendees *',
                      prefixIcon:
                          Icon(Icons.people, size: 24, color: Colors.black),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Number of attendees is required';
                      }
                      final isNumeric = int.tryParse(value);
                      if (isNumeric == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                const SizedBox(height: 25.0),
                SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: TextFormField(
                        controller: _imageController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Upload Image',
                          border: OutlineInputBorder(),
                          prefixIcon:
                              Icon(Icons.image, size: 24, color: Colors.black),
                          // suffixIcon: InkWell(
                          //   onTap: () {
                          //     _deleteImage();
                          //     print('image deleted');
                          //   },
                          //   child: Row(children: [
                          //     Spacer(),
                          //     Icon(Icons.cancel),
                          //     SizedBox(width: 8)
                          //   ]),
                          // ),
                        ),
                        onTap: () {
                          _pickImage();
                        })),
                if (_imageController.text != "No image selected")
                  TextButton.icon(
                      onPressed: () {
                        _deleteImage();
                      },
                      icon: Icon(Icons.delete_outline_rounded),
                      label: Text(
                        "Remove image",
                      )),
                if (showRequiredValidationMessage)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Please fill all the required fields',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(
                  height: 50,
                ),
              ],
            ),
          ),
        ),
        Step(
          state: _activeStepIndex <= 1 ? StepState.indexed : StepState.complete,
          isActive: _activeStepIndex >= 1,
          title: const Text(
            'Sponsorship Category',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.normal),
          ),
          content: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "What do you need from sponsors?",
                  style: TextStyle(fontSize: 40),
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    child: _buildCategoryChips(),
                  ),
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              Text("Selected Categories:", style: TextStyle(fontSize: 20)),
              const SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: textEditingController,
                  readOnly: true, // Set the TextField to read-only
                  decoration: InputDecoration(
                    //hintText: "Selected Chips",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    prefix:
                        _buildSelectedChipsWidget(), // Display selected chips inside the TextField
                  ),
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              if (showCategoryValidationMessage)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Please select at least one category',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
        Step(
          state: _activeStepIndex <= 0 ? StepState.indexed : StepState.complete,
          isActive: _activeStepIndex >= 2,
          title: const Text(
            'Benefits',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.normal),
          ),
          content: Container(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Sponsor Benefits",
                    style: TextStyle(fontSize: 40),
                  ),
                ),
                TextFormField(
                  controller: benefitsController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Benefits to the sponsor *',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Benefits to the sponsor is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 26,
                ),
                TextFormField(
                  controller: notesController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Additional Notes',
                      contentPadding: EdgeInsets.symmetric(vertical: 20.0)),
                ),
                const SizedBox(
                  height: 26,
                ),
                ElevatedButton(
                    onPressed: () {
                      if (benefitsController.text.isEmpty) {
                        setState(() {
                          showRequiredValidationMessage = true;
                        });
                      }
                      _showpostconfirm();
                    },
                    child: const Text("Post Event",
                        style: TextStyle(fontSize: 20, color: Colors.white)),
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Color.fromARGB(255, 51, 45, 81)),
                        //Color.fromARGB(255, 207, 186, 224),), // Background color
                        textStyle: MaterialStateProperty.all<TextStyle>(
                            const TextStyle(fontSize: 16)), // Text style
                        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                            const EdgeInsets.all(16)), // Padding
                        elevation:
                            MaterialStateProperty.all<double>(1), // Elevation
                        shape: MaterialStateProperty.all<OutlinedBorder>(
                          RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(30), // Border radius
                            side: const BorderSide(
                                color: Color.fromARGB(
                                    255, 255, 255, 255)), // Border color
                          ),
                        ),
                        minimumSize: MaterialStateProperty.all<Size>(
                            const Size(200, 50)))),
                if (showRequiredValidationMessage)
                  const Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Please fill all the required fields',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ];

  List<String> selectedChips = [];

  void _showSuccessSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Your event is posted to sponsors!',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green, // Set the background color
      ),
    );
  }

  Widget _buildSelectedChipsWidget() {
    if (selectedChips.isEmpty) {
      return Container(); // Return an empty container if no chips are selected.
    }

    return Wrap(
      spacing: 5.0,
      runSpacing: 3.0,
      children: selectedChips.map((chipName) {
        return Chip(
          label: Text(chipName), // Empty label for the chip
          deleteIcon:
              Icon(Icons.cancel), // Add a delete (cancel) icon for each chip
          onDeleted: () {
            _handleChipRemoval(chipName);
          },
        );
      }).toList(),
    );
  }

  void _updateTextFieldText() {
    // Generate a visual representation for selected chips, for example, using icons
    String visualRepresentation = selectedChips.map((chipName) {
      return ' '; // You can use any symbol or icon here
    }).join(' '); // Use a space or any separator you prefer

    textEditingController.text =
        visualRepresentation; // Set the visual representation as the text
  }

  void _handleChipRemoval(String chipName) {
    setState(() {
      selectedChips.remove(chipName);
      _updateTextFieldText();
    });
  }

  void _handleChipCreation(String newChipName) {
    setState(() {
      if (newChipName.isNotEmpty) {
        selectedChips.add(newChipName);
        showCategoryValidationMessage = false;
        _updateTextFieldText();
      }
    });
  }

  void _handleChipSelection(String chipName, bool isSelected) {
    setState(() {
      if (isSelected && !selectedChips.contains(chipName)) {
        selectedChips.add(chipName);
      } else if (!isSelected && selectedChips.contains(chipName)) {
        selectedChips.remove(chipName);
      }
      _updateTextFieldText();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('New Event'),
          backgroundColor: Color.fromARGB(255, 51, 45, 81),
        ),
        body: Form(
            key: _formKey,
            // child: IgnorePointer(
            //   ignoring: true, // Make the steps unclickable
            child: GestureDetector(
              onTap: () {},
              child: Stepper(
                controlsBuilder: (context, onStepContinue) {
                  return Row(
                    children: <Widget>[
                      if (_activeStepIndex != 0)
                        ElevatedButton(
                          onPressed: () {
                            if (_activeStepIndex == 0) {
                              return;
                            }
                            setState(() {
                              _activeStepIndex -= 1;
                            });
                          },
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Color.fromARGB(255, 176, 176, 179)),
                              //Color.fromARGB(255, 207, 186, 224),), // Background color
                              textStyle: MaterialStateProperty.all<TextStyle>(
                                  const TextStyle(fontSize: 16)), // Text style
                              padding:
                                  MaterialStateProperty.all<EdgeInsetsGeometry>(
                                      const EdgeInsets.all(16)), // Padding
                              elevation: MaterialStateProperty.all<double>(
                                  1), // Elevation
                              shape: MaterialStateProperty.all<OutlinedBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      30), // Border radius
                                  side: const BorderSide(
                                      color: Color.fromARGB(
                                          255, 255, 255, 255)), // Border color
                                ),
                              ),
                              minimumSize: MaterialStateProperty.all<Size>(
                                  const Size(200, 50))),
                          child: const Text(
                            'BACK',
                          ),
                        )
                      else if (_activeStepIndex == 0)
                        ElevatedButton(
                          onPressed: () {
                            _showpostcancel();
                          },
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Color.fromARGB(255, 51, 45, 81)),
                              //Color.fromARGB(255, 207, 186, 224),), // Background color
                              textStyle: MaterialStateProperty.all<TextStyle>(
                                  const TextStyle(fontSize: 16)), // Text style
                              padding:
                                  MaterialStateProperty.all<EdgeInsetsGeometry>(
                                      const EdgeInsets.all(16)), // Padding
                              elevation: MaterialStateProperty.all<double>(
                                  1), // Elevation
                              shape: MaterialStateProperty.all<OutlinedBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      30), // Border radius
                                  side: const BorderSide(
                                      color: Color.fromARGB(
                                          255, 255, 255, 255)), // Border color
                                ),
                              ),
                              minimumSize: MaterialStateProperty.all<Size>(
                                  const Size(200, 50))),
                          child: const Text(
                            'CANCEL POST',
                          ),
                        ),
                      const SizedBox(
                        width: 350,
                      ),
                      if (_activeStepIndex != (stepList().length - 1))
                        ElevatedButton(
                          onPressed: () => {
                            if (_activeStepIndex == 0)
                              {
                                // Check if required fields are empty
                                if (_selectedEventType.isEmpty ||
                                    EnameController.text.isEmpty ||
                                    _startDatetimeController.text ==
                                        'No start Date & Time selected' ||
                                          _endDatetimeController.text == 
                                            'No end Date & Time selected' ||
                                    numofAttendeesController.text.isEmpty)
                                  {
                                    setState(() {
                                      showRequiredValidationMessage = true;
                                    })
                                  }
                                else
                                  {
                                    setState(() {
                                      _activeStepIndex += 1;
                                      showRequiredValidationMessage = false;
                                    })
                                  }
                              }
                            else if (_activeStepIndex == 1)
                              {
                                if (selectedChips.isEmpty)
                                  {
                                    setState(() {
                                      showCategoryValidationMessage = true;
                                    })
                                  }
                                else
                                  {
                                    setState(() {
                                      _activeStepIndex += 1;
                                      showCategoryValidationMessage = false;
                                    })
                                  }
                              }
                            else
                              {
                                // No additional validation for the last step, simply increment
                                setState(() {
                                  _activeStepIndex += 1;
                                })
                              }
                          },
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Color.fromARGB(255, 51, 45, 81)),
                              //Color.fromARGB(255, 207, 186, 224),), // Background color
                              textStyle: MaterialStateProperty.all<TextStyle>(
                                  const TextStyle(fontSize: 16)), // Text style
                              padding:
                                  MaterialStateProperty.all<EdgeInsetsGeometry>(
                                      const EdgeInsets.all(16)), // Padding
                              elevation: MaterialStateProperty.all<double>(
                                  1), // Elevation
                              shape: MaterialStateProperty.all<OutlinedBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      30), // Border radius
                                  side: const BorderSide(
                                      color: Color.fromARGB(
                                          255, 255, 255, 255)), // Border color
                                ),
                              ),
                              minimumSize: MaterialStateProperty.all<Size>(
                                  const Size(200, 50))),
                          //),
                          child: const Text(
                            'NEXT',
                          ),
                        )
                    ],
                  );
                },
                type: StepperType.horizontal,
                currentStep: _activeStepIndex,
                steps: stepList(),
                onStepTapped: null, //(int index) {
                //setState(() {
                //   _activeStepIndex = index;
                // });
                // },
              ),
            )));
  }

  
}
