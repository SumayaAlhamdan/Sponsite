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

  void _showTextInputDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String newChipName = "";

        return AlertDialog(
          title: const Text("Create a New Category"),
          content: TextField(
            onChanged: (text) {
              newChipName = text;
            },
            decoration: const InputDecoration(labelText: "Enter Category"),
          ),
          actions: [
            ElevatedButton(
              child: const Text("Cancel"),
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
            ElevatedButton(
                child: const Text("Create Category"),
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
                },
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
                    minimumSize:
                        MaterialStateProperty.all<Size>(const Size(200, 50)))),
            //)
          ],
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

DateTime? selectedDate;
TimeOfDay? selectedTime;
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
        selectedDate != null &&
        selectedTime != null &&
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

  void _postNewEvent(
    String type,
    String eventName,
    String location,
    String date,
    String time,
    String numofAt,
    List<String> categ,
    String benefits,
    String notes,
  ) async {
    if (benefitsController.text.isEmpty) {
      setState(() {
        showRequiredValidationMessage = true;
      });
    }
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
          'Date': date,
          'Time': time,
          'NumberOfAttendees': numofAt,
          'Category': categ,
          'Benefits': benefits,
          'img': imageUploadResult,
          'Notes': notes,
        });
        print('sent to database!');
        print(type);
        print(eventName);
        print(location);
        print(date);
        print(time);
        print(numofAt);
        print(categ);
        print(benefits);
        print(notes);
        print(sponseeID);
      } catch (e) {
        print('Error sending data to DB: $e');
      }
    }
  }

  Future<void> _selectDateAndTime(BuildContext context) async {
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
          selectedDate = pickedDate;
          selectedTime = pickedTime;
          if (selectedDate != null && selectedTime != null)
            _datetimeController.text =
                '${selectedDate!.toLocal().toString().substring(0, 10)} , ${selectedTime!.format(context)}';
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
  final TextEditingController _datetimeController =
      TextEditingController(text: 'No Date & Time selected');
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

  void _showpostconfirm() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Are you sure you want to post this event?",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
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
            ElevatedButton(
              child: const Text("Cancel"),
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
            ElevatedButton(
                child: const Text("Post"),
                onPressed: () {
                  return;
                },
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
                    minimumSize:
                        MaterialStateProperty.all<Size>(const Size(200, 50)))),
            //)
          ],
        );
      },
    );
  }

  Widget _buildEventTypesRadioList() {
    return Column(
      children: [
        Row(
          children: eventTypesList.sublist(0, 6).map((eventType) {
            return Row(
              children: [
                Radio(
                  value: eventType,
                  groupValue: _selectedEventType,
                  onChanged: (value) {
                    setState(() {
                      _selectedEventType = value as String;
                    });
                  },
                ),
                Text(eventType),
              ],
            );
          }).toList(),
        ),
        SizedBox(width: 16),
        Row(
          children: eventTypesList.sublist(6, 7).map((eventType) {
            return Row(
              children: [
                Radio(
                  value: eventType,
                  groupValue: _selectedEventType,
                  onChanged: (value) {
                    setState(() {
                      _selectedEventType = value as String;
                    });
                  },
                ),
                Text(eventType),
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
                Row(children: [
                  Text("Event Type"),
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
                      controller: _datetimeController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Select Date and Time *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(
                          Icons.calendar_month,
                          size: 24,
                          color: Colors.black,
                        ),
                      ),
                      onTap: () {
                        _selectDateAndTime(context);
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
                          suffixIcon: InkWell(
                            onTap: () {
                              _deleteImage();
                              print('image deleted');
                            },
                            child: Row(children: [
                              Spacer(),
                              Icon(Icons.cancel),
                              SizedBox(width: 8)
                            ]),
                          ),
                        ),
                        onTap: () {
                          _pickImage();
                        })),
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
              // Padding(
              //   padding: const EdgeInsets.all(8.0),
              //   child: TextField(
              //     controller: textEditingController,
              //     readOnly: true, // Set the TextField to read-only
              //     decoration: InputDecoration(
              //       hintText: "Selected Categories",
              //       border: OutlineInputBorder(
              //         borderRadius: BorderRadius.all(Radius.circular(10.0)),
              //         borderSide: BorderSide(color: Colors.grey),
              //       ),
              //     ),
              //   ),
              // ),
              const SizedBox(
                height: 50,
              ),
              // Padding(
              //   padding: const EdgeInsets.all(8.0),
              //   child: Wrap(
              //     spacing: 5.0,
              //     runSpacing: 3.0,
              //     children: selectedChips.map((chipName) {
              //       return Chip(
              //         label: Text(chipName),
              //         onDeleted: () {
              //           setState(() {
              //             selectedChips.remove(chipName);
              //           });
              //           const SizedBox(
              //             height: 50,
              //           );
              //         },
              //       );
              //     }).toList(),
              //   ),
              // ),
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
                      String type = _selectedEventType;
                      String ename = EnameController.text;
                      String location = LocationController.text;
                      String date =
                          selectedDate!.toLocal().toString().substring(0, 10);
                      String time = selectedTime!.format(context);
                      String numOfAt = numofAttendeesController.text;
                      List<String> categ = selectedChips;
                      String benefits = benefitsController.text;
                      String notes = notesController.text;
                      _showpostconfirm();
                      _postNewEvent(type, ename, location, date, time, numOfAt,
                          categ, benefits, notes);
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

  // Widget _buildSelectedChipsWidget() {
  //   List<Widget> chipWidgets = selectedChips.map((chipName) {
  //     return Row(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         Chip(
  //           label: Text(chipName),
  //           onDeleted: () {
  //             _handleChipRemoval(chipName);
  //           },
  //         ),
  //         SizedBox(width: 4.0), // Add spacing between chips and clear buttons
  //       ],
  //     );
  //   }).toList();

  //   return Wrap(
  //     spacing: 5.0,
  //     runSpacing: 3.0,
  //     children: chipWidgets,
  //   );
  //}

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

  // void _updateTextFieldText() {
  //   textEditingController.text =
  //       selectedChips.join(", "); // Comma-separated chip names
  // }

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

  Future<void> _showAlertDialog(String message) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Warning'),
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
                    minimumSize:
                        MaterialStateProperty.all<Size>(const Size(200, 50)))),
          ],
        );
      },
    );
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
                            'BACK',
                          ),
                        )
                      else if (_activeStepIndex == 0)
                        ElevatedButton(
                          onPressed: () {
                            runApp(const SponseeHome());
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
                                    _datetimeController.text ==
                                        'No Date & Time selected' ||
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

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(const MyApp());
// }

// // void main() {
// //   runApp(const MyApp());
// // }
// // void main() async {
// //   WidgetsFlutterBinding.ensureInitialized();
// //   await Firebase.initializeApp();
// //   runApp(const MyApp());
// // }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'New Event',
//       theme: ThemeData(
//         primarySwatch: Colors.deepPurple,
//       ),
//       home: const MyHomePage(),
//     );
//   }
// }

// User? user = FirebaseAuth.instance.currentUser;
// String? sponseeID;
// void check() {
//   if (user != null) {
//     sponseeID = user?.uid;
//     print('Sponsor ID: $sponseeID');
//   } else {
//     print('User is not logged in.');
//   }
// }
// // String getUsername() {
// //   User? user = FirebaseAuth.instance.currentUser;

// //   if (user != null) {
// //     // User is signed in
// //     String email = user.email!;
// //     print(email);
// //     return email;
// //   } else {
// //     // No user is signed in
// //     return '';
// //   }
// // }

// Widget _titleContainer(String myTitle) {
//   return Text(
//     myTitle,
//     style: TextStyle(
//       color: Colors.black,
//       fontSize: 24.0,
//       fontWeight: FontWeight.bold,
//     ),
//   );
// }

// class FilterChipWidget extends StatefulWidget {
//   final String chipName;
//   final Function(String) onChipCreated;
//   final Function(String, bool) onChipSelected;

//   FilterChipWidget({
//     required this.chipName,
//     required this.onChipCreated,
//     required this.onChipSelected, // Add this parameter
//   }) : super();

//   @override
//   _FilterChipWidgetState createState() => _FilterChipWidgetState();
// }

// class _FilterChipWidgetState extends State<FilterChipWidget> {
//   var _isSelected = false;

//   @override
//   Widget build(BuildContext context) {
//     return FilterChip(
//       label: Text(widget.chipName),
//       labelStyle: TextStyle(
//         color: const Color(0xff6200ee),
//         fontSize: 16.0,
//         fontWeight: FontWeight.bold,
//       ),
//       selected: _isSelected,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(30.0),
//       ),
//       backgroundColor: const Color(0xffededed),
//       onSelected: (isSelected) {
//         if (widget.chipName == 'Other' && isSelected) {
//           _showTextInputDialog();
//         } else {
//           setState(() {
//             widget.onChipSelected(widget.chipName, isSelected);
//             _isSelected = isSelected;
//           });
//         }
//       },
//       selectedColor: const Color(0xffeadffd),
//     );
//   }

//   void _showTextInputDialog() {
//     showDialog(
//       context: context,
//       builder: (context) {
//         String newChipName = "";

//         return AlertDialog(
//           title: const Text("Create a New Category"),
//           content: TextField(
//             onChanged: (text) {
//               newChipName = text;
//             },
//             decoration: const InputDecoration(labelText: "Enter Category"),
//           ),
//           actions: [
//             TextButton(
//               child: const Text("Cancel"),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//             TextButton(
//               child: const Text("Create Category"),
//               onPressed: () {
//                 if (newChipName.isNotEmpty) {
//                   widget.onChipCreated(newChipName);
//                   Navigator.of(context).pop();
//                 }
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({Key? key}) : super(key: key);

//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// DateTime? selectedDate;
// TimeOfDay? selectedTime;
//  List<String> eventTypesList = [];
//   String? selectedEventType;

// class _MyHomePageState extends State<MyHomePage> {
//   File? _imageFile; // Store the picked image file
// List<String> eventTypesList = [];

//   void initState() {
//     super.initState();
//     check();
//  fetchEventTypesFromDatabase(); // Call the function to fetch event types
// }

// Future<void> fetchEventTypesFromDatabase() async {
//   final eventTypes = await fetchEventTypes();

//   // Update the event types in the UI
//   setState(() {
//     eventTypesList = eventTypes;
//   });
// }
//   void _postNewEvent(
//       String type,
//       String eventName,
//       String location,
//       String date,
//       String time,
//       String numofAt,
//       List<String> categ,
//       String benefits,
//       String notes) async {
//     if (benefitsController.text.isEmpty) {
//       setState(() {
//         showRequiredValidationMessage = true;
//       });
//     }
//     final isValid = _formKey.currentState!.validate();
//     if (isValid) {
//       try {
//         final String imageUploadResult = await _uploadImage(_imageFile!);
//         dbref.child('sponseeEvents').push().set({
//           'SponseeID': sponseeID,
//           'EventType': type,
//           'EventName': eventName,
//           'Location': location,
//           'Date': date,
//           'Time': time,
//           'NumberOfAttendees': numofAt,
//           'Category': categ,
//           'Benefits': benefits,
//           'img': imageUploadResult,
//           'Notes': notes,
//         });
//         print('sent to database!');
//         print(type);
//         print(eventName);
//         print(location);
//         print(date);
//         print(time);
//         print(numofAt);
//         print(categ);
//         print(benefits);
//         print(notes);
//         print(sponseeID);
//       } catch (e) {
//         print('Error sending data to DB: $e');
//       }
//     }
//   }

//   Future<void> _selectDateAndTime(BuildContext context) async {
//     final pickedDate = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime.now(),
//       lastDate: DateTime(2101),
//     );

//     if (pickedDate != null) {
//       final pickedTime = await showTimePicker(
//         context: context,
//         initialTime: TimeOfDay.now(),
//       );

//       if (pickedTime != null) {
//         setState(() {
//           selectedDate = pickedDate;
//           selectedTime = pickedTime;
//         });
//       }
//     }
//   }

//   int _activeStepIndex = 0;
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   // First step controllers
//   //event type
//   final TextEditingController EnameController = TextEditingController();
//   //dateandtime
//   final TextEditingController LocationController = TextEditingController();
//   final TextEditingController numofAttendeesController =
//       TextEditingController();

//   //Second step
//   //categories

//   // Third step controllers
//   final TextEditingController benefitsController = TextEditingController();
//   final TextEditingController notesController = TextEditingController();

//   final DatabaseReference dbref = FirebaseDatabase.instance.reference();

//   String _selectedEventType= '';
//   List<String> selectedChips = [];
//   bool showCategoryValidationMessage = false;
//   bool showRequiredValidationMessage = false;
//   Future<void> _pickImage() async {
//   final imagePicker = ImagePicker();
//   final PickedFile? pickedFile = await imagePicker.getImage(source: ImageSource.gallery);

//   if (pickedFile != null) {
//     setState(() {
//       _imageFile = File(pickedFile.path); // Correctly create a File object
//     });
//   }
// }
// Future<String> _uploadImage(File imageFile) async {
//   try {
//     final firebase_storage.Reference storageReference =
//         firebase_storage.FirebaseStorage.instance.ref().child('event_images').child(
//             '${DateTime.now().millisecondsSinceEpoch}.${imageFile.path.split('.').last}');

//     final uploadTask = storageReference.putFile(imageFile);

//     final firebase_storage.TaskSnapshot storageTaskSnapshot =
//         await uploadTask.whenComplete(() => null);

//     // Get the URL of the uploaded image
//     final String imageURL = await storageTaskSnapshot.ref.getDownloadURL();

//     return imageURL; // Return the image URL
//   } catch (e) {
//     print('Error uploading image: $e');
//     return ''; // Return an empty string in case of an error
//   }
// }

// Future<List<String>> _fetchCategories() async {
//   final categories = <String>[];

//   try {
//     // Replace 'your_categories_node' with the actual database path where your categories are stored
//     final DatabaseEvent dataSnapshot = await FirebaseDatabase.instance
//         .reference()
//         .child('Categories')
//         .once();

//     if (dataSnapshot.snapshot.value != null) {
//       // Convert the data snapshot into a List<String>
//       final categoryData = dataSnapshot.snapshot.value as Map<dynamic, dynamic>;
//       categoryData.forEach((key, value) {
//         categories.add(value.toString());
//       });
//     }
//   } catch (e) {
//     print('Error fetching categories: $e');
//   }

//   return categories;
// }

// Future<List<String>> fetchEventTypes() async {
//   final eventTypes = <String>[];

//   try {
//     final DatabaseEvent dataSnapshot = await FirebaseDatabase.instance
//         .reference()
//         .child('EventType')
//         .once();

//     if (dataSnapshot.snapshot.value != null) {
//       final Map<dynamic, dynamic> eventTypesMap = dataSnapshot.snapshot.value as Map<dynamic, dynamic>;

//       // Iterate through the map and add event type names to the 'eventTypes' list
//       eventTypesMap.forEach((key, value) {
//         eventTypes.add(value.toString());
//       });
//     }
//   } catch (e) {
//     print('Error fetching event types: $e');
//   }

//   return eventTypes;
// }

// Widget _buildCategoryChips() {
//   return FutureBuilder<List<String>>(
//     future: _fetchCategories(),
//     builder: (context, snapshot) {
//       if (snapshot.connectionState == ConnectionState.waiting) {
//         // Display a loading indicator while fetching categories
//         return CircularProgressIndicator();
//       } else if (snapshot.hasError) {
//         // Handle error if fetching categories fails
//         return Text('Error: ${snapshot.error}');
//       } else if (snapshot.hasData) {
//         // Create FilterChipWidget widgets based on the fetched categories
//         final categories = snapshot.data!;
//         return Wrap(
//           spacing: 5.0,
//           runSpacing: 3.0,
//           children: categories.map((category) {
//             return FilterChipWidget(
//               chipName: category,
//               onChipCreated: _handleChipCreation,
//               onChipSelected: _handleChipSelection,
//             );
//           }).toList(),
//         );
//       } else {
//         // Handle the case when there are no categories
//         return Text('No categories available.');
//       }
//     },
//   );
// }
// Widget _buildEventTypesRadioList() {// Calculate events per column

//   return Column(
//     children: [
//       Row(
//         children: eventTypesList
//             .sublist(0, 6)
//             .map((eventType) {
//               return Row(
//                 children: [
//                   Radio(
//                     value: eventType,
//                     groupValue: _selectedEventType,
//                     onChanged: (value) {
//                       setState(() {
//                         _selectedEventType = value as String;
//                       });
//                     },
//                   ),
//                   Text(eventType),
//                 ],
//               );
//             })
//             .toList(),
//       ),
//       SizedBox(width: 16), // Add some spacing between the columns
//       Row(
//         children: eventTypesList
//             .sublist(6,7)
//             .map((eventType) {
//               return Row(
//                 children: [
//                   Radio(
//                     value: eventType,
//                     groupValue: selectedEventType,
//                     onChanged: (value) {
//                       setState(() {
//                         _selectedEventType = value as String;
//                       });
//                     },
//                   ),
//                   Text(eventType),
//                 ],
//               );
//             })
//             .toList(),
//       ),
//     ],
//   );
// }

//   List<Step> stepList() => [
//         Step(
//           state: _activeStepIndex <= 0 ? StepState.indexed : StepState.complete,
//           isActive: _activeStepIndex >= 0,
//           title: const Text('Event Details'),
//           content: Container(
//             child: Column(
//               children: [
//                 Row(children: [
//                   Text("Event Type"),
//                   const SizedBox(
//                     height: 8,
//                   ),
//                 ]),
//                 Column(
//   children: <Widget>[
//     const SizedBox(height: 10),
//     if (eventTypesList.isEmpty)
//       const CircularProgressIndicator()
//     else
//       _buildEventTypesRadioList(),
//   ],
// ),
//                 const SizedBox(
//                   height: 8,
//                 ),
//                 TextFormField(
//                   controller: EnameController,
//                   decoration: const InputDecoration(
//                     border: OutlineInputBorder(),
//                     labelText: 'Event Name *',
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Event Name is required';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(
//                   height: 8,
//                 ),
//                 TextFormField(
//                   controller: LocationController,
//                   decoration: const InputDecoration(
//                     border: OutlineInputBorder(),
//                     labelText: 'Event Address',
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 8,
//                 ),
//                 ElevatedButton(
//                   onPressed: () => _selectDateAndTime(context),
//                   child: const Text('Select Date and Time *'),
//                 ),
//                 if (selectedDate != null)
//                   Text(
//                     'Event Date: ${selectedDate!.toLocal().toString().substring(0, 10)} ',
//                     style: TextStyle(fontSize: 16),
//                   ),
//                 if (selectedTime != null)
//                   Text(
//                     'Event Time:  ${selectedTime!.format(context)}',
//                     style: TextStyle(fontSize: 16),
//                   ),
//                 TextFormField(
//                   controller: numofAttendeesController,
//                   decoration: const InputDecoration(
//                     border: OutlineInputBorder(),
//                     labelText: 'Number of attendees *',
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Number of attendees is required';
//                     }
//                     // Use a regular expression to check if the input is a number
//                     final isNumeric = int.tryParse(value);
//                     if (isNumeric == null) {
//                       return 'Please enter a valid number';
//                     }
//                     return null;
//                   },
//                   keyboardType:
//                       TextInputType.number, // Set the keyboard type to number
//                   inputFormatters: <TextInputFormatter>[
//                     FilteringTextInputFormatter.digitsOnly, // Allow only digits
//                   ],
//                 ),
//                 const SizedBox(
//                   height: 8,
//                 ),
//                 ElevatedButton(
//   onPressed: () => _pickImage(),
//   child: const Text("Select Image"),
// ),
//                 if (showRequiredValidationMessage) // Show the message conditionally
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Text(
//                       'Please fill all the required fields',
//                       style: TextStyle(color: Colors.red),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ),
//     Step(
//   state: _activeStepIndex <= 1 ? StepState.indexed : StepState.complete,
//   isActive: _activeStepIndex >= 1,
//   title: const Text('Sponsorship Category'),
//   content: Column(
//     children: [
//       Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: _titleContainer("What do you need from sponsors?"),
//       ),
//       Padding(
//         padding: const EdgeInsets.only(left: 8.0),
//         child: Align(
//           alignment: Alignment.centerLeft,
//           child: Container(
//             child: _buildCategoryChips(), // Use the _buildCategoryChips() function here
//           ),
//         ),
//       ),
//       // Display the selected chips
//       Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Wrap(
//           spacing: 5.0,
//           runSpacing: 3.0,
//           children: selectedChips.map((chipName) {
//             return Chip(
//               label: Text(chipName),
//               onDeleted: () {
//                 setState(() {
//                   selectedChips.remove(chipName);
//                 });
//               },
//             );
//           }).toList(),
//         ),
//       ),
//       if (showCategoryValidationMessage) // Show the message conditionally
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Text(
//             'Please select at least one category',
//             style: TextStyle(color: Colors.red),
//           ),
//         ),
//     ],
//   ),
// ),

//         Step(
//           state: StepState.complete,
//           //StepState.indexed : StepState.complete,
//           isActive: _activeStepIndex >= 2,
//           title: const Text('Benefits *'),
//           content: Container(
//             child: Column(
//               children: [
//                 TextFormField(
//                   controller: benefitsController,
//                   decoration: const InputDecoration(
//                     border: OutlineInputBorder(),
//                     labelText: 'Benefits to the sponsor *',
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Benefits to the sponsor is required'; // Validation message
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(
//                   height: 26,
//                 ),
//                 TextFormField(
//                   controller: notesController,
//                   decoration: const InputDecoration(
//                     border: OutlineInputBorder(),
//                     labelText: 'Additional Notes',
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 26,
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     String type = _selectedEventType;
//                     String ename = EnameController.text;
//                     String location = LocationController.text;
//                     String date =
//                         selectedDate!.toLocal().toString().substring(0, 10);
//                     String time = selectedTime!.format(context);
//                     String numOfAt = numofAttendeesController.text;
//                     List<String> categ = selectedChips;
//                     String benefits = benefitsController.text;
//                     String notes = notesController.text;

//                     _postNewEvent(type, ename, location, date, time, numOfAt,
//                         categ, benefits, notes);
//                   },
//                   child: const Text("Post Event"),
//                 ),
//                 if (showRequiredValidationMessage) // Show the message conditionally
//                   const Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Text(
//                       'Please fill all the required fields',
//                       style: TextStyle(color: Colors.red),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ];

//   void _handleChipCreation(String newChipName) {
//     setState(() {
//       if (newChipName.isNotEmpty) {
//         selectedChips.add(newChipName);
//       }
//     });
//   }

//   void _handleChipSelection(String chipName, bool isSelected) {
//     setState(() {
//       if (isSelected) {
//         selectedChips.add(chipName);
//       } else {
//         selectedChips.remove(chipName);
//       }
//     });
//   }

//   Future<void> _showAlertDialog(String message) async {
//     return showDialog<void>(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Warning'),
//           content: SingleChildScrollView(
//             child: ListBody(
//               children: <Widget>[
//                 Text(message),
//               ],
//             ),
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: Text('OK'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: const Text('New Event'),
//         ),
//         body: Form(
//           key: _formKey,
//           child: Stepper(
//             controlsBuilder: (context, onStepContinue) {
//               return Row(
//                 children: <Widget>[
//                   if (_activeStepIndex != 0)
//                     TextButton(
//                       onPressed: () {
//                         if (_activeStepIndex == 0) {
//                           return;
//                         }
//                         setState(() {
//                           _activeStepIndex -= 1;
//                         });
//                       },
//                       child: const Text(
//                         'BACK',
//                         style: TextStyle(color: Colors.deepPurple),
//                       ),
//                     )
//                   else if (_activeStepIndex == 0)
//                     TextButton(
//                       onPressed: () {
//                         return;
//                       },
//                       child: const Text(
//                         'CANCEL POST',
//                         style: TextStyle(color: Colors.deepPurple),
//                       ),
//                     ),
//                   if (_activeStepIndex != (stepList().length - 1))
//                     TextButton(
//                       onPressed: () => {
//                         if (_activeStepIndex == 0)
//                           {
//                             // Check if required fields are empty
//                             if (_selectedEventType == null ||
//                                 EnameController.text.isEmpty ||
//                                 selectedDate == null ||
//                                 selectedTime == null ||
//                                 numofAttendeesController.text.isEmpty)
//                               {
//                                 setState(() {
//                                   showRequiredValidationMessage = true;
//                                 })
//                               }
//                             else
//                               {
//                                 setState(() {
//                                   _activeStepIndex += 1;
//                                   showRequiredValidationMessage = false;
//                                 })
//                               }
//                           }
//                         else if (_activeStepIndex == 1)
//                           {
//                             if (selectedChips.isEmpty)
//                               {
//                                 setState(() {
//                                   showCategoryValidationMessage = true;
//                                 })
//                               }
//                             else
//                               {
//                                 setState(() {
//                                   _activeStepIndex += 1;
//                                   showCategoryValidationMessage = false;
//                                 })
//                               }
//                           }
//                         else
//                           {
//                             // No additional validation for the last step, simply increment
//                             setState(() {
//                               _activeStepIndex += 1;
//                             })
//                           }
//                       },
//                       child: const Text(
//                         'NEXT',
//                         style: TextStyle(color: Colors.deepPurple),
//                       ),
//                     )
//                 ],
//               );
//             },
//             type: StepperType.horizontal,
//             currentStep: _activeStepIndex,
//             steps: stepList(),
//             onStepTapped: (int index) {
//               setState(() {
//                 _activeStepIndex = index;
//               });
//             },
//           ),
//         ));
//   }
// }
