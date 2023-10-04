import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:sponsite/main.dart';
import 'dart:typed_data';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:geocoding/geocoding.dart' as geocoding;

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

//some widgets

Widget _titleContainer(String myTitle) {
  return Text(
    myTitle,
    style: const TextStyle(
      color: Colors.black,
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
    ),
  );
}

//-----chip widget------------------------------------
class FilterChipWidget extends StatefulWidget {
  final String chipName;
  final Function(String) onChipCreated;
  final Function(String, bool) onChipSelected;

  const FilterChipWidget({
    super.key,
    required this.chipName,
    required this.onChipCreated,
    required this.onChipSelected,
  });

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
        style: const TextStyle(fontSize: 25),
      ),
      labelStyle: const TextStyle(
        color: Color(0xff6200ee),
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
          title: const Text(
            'Warning',
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
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      const Color.fromARGB(255, 51, 45, 81)),
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
              child: const Text('OK'),
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
          title: const Text('Create new category'),
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
//------------------------------------------------------------------------------

//---------radio button widget -------------------------------------------------

class CustomRadioButton extends StatelessWidget {
  final String value;
  final String? groupValue;
  final Function(String?) onChanged;
  final double width; // New property for width
  final double height; // New property for height

  const CustomRadioButton({
    super.key,
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

//-----------------------------------------------------------------------------

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
  //--------- map definitions ------------------------------------------------
  GoogleMapController? mapController;
  LatLng? selectedLocation;
  TextEditingController searchController = TextEditingController();
  Prediction? selectedPrediction;
  String? selectedAddressDescription;
  Set<Marker> markers = {};
  bool showMap = false;

  GoogleMapsPlaces _places = GoogleMapsPlaces(
    apiKey:
        'AIzaSyD6Qb46BjUA0NQlicbMO3uznD495RLGyuU', // Replace with your API key
  );

  void _handlePredictionTap(Prediction prediction) async {
    final details = await _places.getDetailsByPlaceId(prediction.placeId!);
    if (details.isOkay) {
      setState(() {
        selectedLocation = LatLng(
          details.result.geometry!.location.lat,
          details.result.geometry!.location.lng,
        );
        selectedPrediction = prediction;
      });
      _updateMarkers();
      _reverseGeocodeLocation(selectedLocation!);
    }
  }

//------------------------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    check();
    fetchEventTypesFromDatabase();
    _imageController.text =
        'No image selected'; // Initialize the controller text
  }

  bool areRequiredFieldsFilled() {
    return EnameController.text.isNotEmpty &&
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
        if (_imageFile != null) {
          imageUploadResult = await _uploadImage(_imageFile!);
        } else {
          imageUploadResult = '';
        }

        dbref.child('sponseeEvents').push().set({
          'SponseeID': sponseeID,
          'EventType': type,
          'EventName': eventName,
          'Location': location,
          'startDate': startDate,
          'endDate': endDate,
          'startTime': startTime,
          'endTime': endTime,
          'NumberOfAttendees': numofAt,
          'Category': categ,
          'Benefits': benefits,
          'img': imageUploadResult,
          'Notes': notes,
          'TimeStamp': timestamp,
        });

        ///_showSuccessSnackbar(context);
        main();

        //runApp(const SponseeHome());
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

  ///---date and time methods-----------------------------------------------------
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
          if (selectedStartDate != null && selectedStartTime != null) {
            _startDatetimeController.text =
                '${selectedStartDate!.toLocal().toString().substring(0, 10)} , ${selectedStartTime!.format(context)}';
          }
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
              .add(Duration(
                  hours: selectedStartTime!.hour,
                  minutes: selectedStartTime!.minute));
          DateTime endDateTime = pickedDate.add(
              Duration(hours: pickedTime.hour, minutes: pickedTime.minute));

          if (endDateTime.isBefore(startDateTime)) {
            before = true;
          }
        }

        setState(() {
          selectedEndDate = pickedDate;
          selectedEndTime = pickedTime;
          if (selectedEndDate != null && selectedEndTime != null) {
            _endDatetimeController.text =
                '${selectedEndDate!.toLocal().toString().substring(0, 10)} , ${selectedEndTime!.format(context)}';
          }
        });
      }
    }
  }
//------------------------------------------------------------------------------

  int _activeStepIndex = 0;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController EnameController = TextEditingController();
  //final TextEditingController LocationController = TextEditingController();
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

//---------image methods--------------------------------------------------------

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
//------------------------------------------------------------------------------

//----------------fetchinf from db---------------------------------------------
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
          return const CircularProgressIndicator();
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
          return const Text('No categories available.');
        }
      },
    );
  }
//------------------------------------------------------------------------------

//--------------confirmation messages-------------------------------------------
  void _showpostcancel() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Cancel Event Post",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
          ),
          content: const Text(
            "Are you sure you want to cancel this event?",
          ),
          backgroundColor: Colors.white,
          elevation: 0, // Remove the shadow
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
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
                //runApp(const SponseeHome());
                Navigator.of(context).pop();
                main();
              },
            ),
          ],
        );
      },
    );
  }

  void _showpostconfirm() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Post Event",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
          ),
          content: const Text(
            "Are you sure you want to post this event?",
          ),
          backgroundColor: Colors.white,
          elevation: 0, // Remove the shadow
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
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
                String location = selectedLocation
                    .toString()
                    .replaceAll('LatLng(', '')
                    .replaceAll(')', '');
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
                _postNewEvent(type, ename, location, startDate, endDate,
                    startTime, endTime, numOfAt, categ, benefits, notes);
                Navigator.of(context).pop();
                _showSuccessSnackbar(context);

                //_showSuccessSnackbar(context);
              },
            ),
          ],
        );
      },
    );
  }
//------------------------------------------------------------------------------

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
                ? const Color.fromARGB(255, 51, 45, 84)
                : Colors.black,
          ),
          color: (groupValue == value)
              ? const Color.fromARGB(255, 51, 45, 84)
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
                const SizedBox(width: 8.0), // Add space between buttons
                Center(
                    child: SizedBox(
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
        const SizedBox(height: 25),
        Row(
          mainAxisAlignment:
              MainAxisAlignment.center, // Center the children horizontally

          children: eventTypesList.sublist(4, 7).map((eventType) {
            return Row(
              children: [
                const SizedBox(width: 8.0), // Add space between buttons
                Center(
                    child: SizedBox(
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

  Widget buildChooseLocationButton() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                showMap = true;
                print('pressed - about to go to buildmap');
                //buildMap();
              });
            },
            child: Text(selectedAddressDescription != null
                ? 'Change Location'
                : 'Choose Location'),
          ),
          if (selectedLocation != null)
            //  if (selectedAddressDescription!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Address: ${selectedAddressDescription}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
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
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "About your event",
                    style: TextStyle(fontSize: 40),
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                const Row(
                    mainAxisAlignment: MainAxisAlignment
                        .center, // Center the children horizontally
                    children: [
                      Text("Event Type *", style: TextStyle(fontSize: 18)),
                      SizedBox(
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
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: EnameController,
                    maxLength: 20,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
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
                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.center, // Align children to the start
                  children: [
                    Text(
                      "Event Location",
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 10.0),
                    if (selectedLocation != null)
                      Row(
                        children: [
                          if (selectedAddressDescription != null)
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.place, // Replace with the desired icon
                                color: Color.fromARGB(255, 51, 45,
                                    81), // Customize the icon color
                                size: 24.0, // Customize the icon size
                              ),
                            ),
                          if (selectedAddressDescription != null)
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  selectedAddressDescription!,
                                  style: TextStyle(
                                    fontSize: 16.0,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: buildMap(),
                    ),
                  ],
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
                      autovalidateMode: AutovalidateMode.onUserInteraction,
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
                      autovalidateMode: AutovalidateMode.onUserInteraction,
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
                    maxLength: 6,
                    controller: numofAttendeesController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Number of attendees *',
                      prefixIcon:
                          Icon(Icons.people, size: 24, color: Colors.black),
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
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
                // const SizedBox(
                //   height: 10,
                // ),
                // const SizedBox(height: 25.0),
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
                                icon: Icon(Icons.image_outlined),
                                onPressed: _selectedImageBytes != null
                                    ? _pickImage
                                    : _pickImage,
                                label: Text(getButtonLabel()),
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all<Color>(
                                        const Color.fromARGB(255, 51, 45, 81)),
                                    //Color.fromARGB(255, 207, 186, 224),), // Background color
                                    textStyle:
                                        MaterialStateProperty.all<TextStyle>(
                                            const TextStyle(
                                                fontSize: 16)), // Text style
                                    padding: MaterialStateProperty.all<
                                            EdgeInsetsGeometry>(
                                        const EdgeInsets.all(16)), // Padding
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
                if (showRequiredValidationMessage)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
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
              const Padding(
                padding: EdgeInsets.all(8.0),
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
              const Text("Selected Categories:",
                  style: TextStyle(fontSize: 20)),
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
                    border: const OutlineInputBorder(
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
                const Padding(
                  padding: EdgeInsets.all(8.0),
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
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Sponsor Benefits",
                    style: TextStyle(fontSize: 40),
                  ),
                ),
                TextFormField(
                  controller: benefitsController,
                  maxLength: 200,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Benefits to the sponsor *',
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
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
                  maxLength: 200,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Additional Notes',
                      contentPadding: EdgeInsets.fromLTRB(15, 20, 20, 20)),
                ),
                const SizedBox(
                  height: 26,
                ),
                if (showRequiredValidationMessage)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
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
      const SnackBar(
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
          deleteIcon: const Icon(
              Icons.cancel), // Add a delete (cancel) icon for each chip
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
          backgroundColor: const Color.fromARGB(255, 51, 45, 81),
        ),
        body:
            // Column(children: [
            //   Expanded(
            //     child: showMap ? buildMap() : buildChooseLocationButton(),
            //   ),
            Form(
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
                                      const Color.fromARGB(255, 51, 45, 81)),
                                  //Color.fromARGB(255, 207, 186, 224),), // Background color
                                  textStyle: MaterialStateProperty.all<TextStyle>(
                                      const TextStyle(
                                          fontSize: 16)), // Text style
                                  padding: MaterialStateProperty.all<
                                          EdgeInsetsGeometry>(
                                      const EdgeInsets.all(16)), // Padding
                                  elevation: MaterialStateProperty.all<double>(
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
                                      const Color.fromARGB(255, 51, 45, 81)),
                                  //Color.fromARGB(255, 207, 186, 224),), // Background color
                                  textStyle: MaterialStateProperty.all<TextStyle>(
                                      const TextStyle(
                                          fontSize: 16)), // Text style
                                  padding: MaterialStateProperty.all<
                                          EdgeInsetsGeometry>(
                                      const EdgeInsets.all(16)), // Padding
                                  elevation: MaterialStateProperty.all<double>(
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
                                  minimumSize: MaterialStateProperty.all<Size>(
                                      const Size(200, 50))),
                              child: const Text(
                                'CANCEL',
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
                                      const Color.fromARGB(255, 51, 45, 81)),
                                  //Color.fromARGB(255, 207, 186, 224),), // Background color
                                  textStyle: MaterialStateProperty.all<TextStyle>(
                                      const TextStyle(
                                          fontSize: 16)), // Text style
                                  padding: MaterialStateProperty.all<
                                          EdgeInsetsGeometry>(
                                      const EdgeInsets.all(16)), // Padding
                                  elevation: MaterialStateProperty.all<double>(
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
                                  minimumSize: MaterialStateProperty.all<Size>(
                                      const Size(200, 50))),
                              //),
                              child: const Text(
                                'NEXT',
                              ),
                            )
                          else if (_activeStepIndex == stepList().length - 1)
                            ElevatedButton(
                                onPressed: () {
                                  if (benefitsController.text.isEmpty) {
                                    setState(() {
                                      showRequiredValidationMessage = true;
                                    });
                                  } else {
                                    _showpostconfirm();
                                  }
                                },
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all<Color>(
                                        const Color.fromARGB(255, 51, 45, 81)),
                                    //Color.fromARGB(255, 207, 186, 224),), // Background color
                                    textStyle: MaterialStateProperty.all<TextStyle>(
                                        const TextStyle(
                                            fontSize: 16)), // Text style
                                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                                        const EdgeInsets.all(16)), // Padding
                                    elevation: MaterialStateProperty.all<double>(
                                        1), // Elevation
                                    shape: MaterialStateProperty.all<
                                        OutlinedBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            30), // Border radius
                                        side: const BorderSide(
                                            color: Color.fromARGB(255, 255, 255,
                                                255)), // Border color
                                      ),
                                    ),
                                    minimumSize: MaterialStateProperty.all<Size>(
                                        const Size(200, 50))),
                                child: const Text("Post Event", style: TextStyle(fontSize: 20, color: Colors.white))),
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
                ))
        // ])
        );
  }

  bool isMapExpanded = false;

  Widget buildMap() {
    print("here!!");
    return Stack(
      children: [
        // isMapExpanded
        //     ? Container(
        //         height: MediaQuery.of(context).size.height, // Use full height
        //         child: GoogleMap(
        //           onMapCreated: (controller) {
        //             setState(() {
        //               mapController = controller;
        //             });
        //           },
        //           initialCameraPosition: CameraPosition(
        //             target: LatLng(24.7136, 46.6753), // Initial map location
        //             zoom: 12.0, // Initial zoom level
        //           ),
        //           markers: markers,
        //           onTap: _handleMapTap,
        //         ),
        //       )
        //     :
        Container(
          height: 500,
          child: GoogleMap(
            onMapCreated: (controller) {
              setState(() {
                mapController = controller;
              });
            },
            initialCameraPosition: CameraPosition(
              target: LatLng(24.7136, 46.6753), // Initial map location
              zoom: 12.0, // Initial zoom level
            ),
            markers: markers,
            onTap: _handleMapTap,
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for a place...',
                  ),
                  onChanged: (value) {
                    // Clear previous selection
                    setState(() {
                      selectedPrediction = null;
                      selectedLocation = null;
                      selectedAddressDescription = null;
                    });
                    _performSearch(value);
                  },
                ),
                if (selectedPrediction != null)
                  ListTile(
                    title: Text(selectedPrediction?.description ??
                        'No description available'),
                    onTap: () {
                      // Handle selection of a prediction
                      _handlePredictionTap(selectedPrediction!);
                    },
                  ),
              ],
            ),
          ),
        ),

        // ElevatedButton(
        //   onPressed: () async {
        //     final addressDescription = await navigateToConfirmation();
        //     if (addressDescription != null) {
        //       setState(() {
        //         showMap = false;
        //         // selectedLocation = null;
        //         selectedPrediction = null;
        //         selectedAddressDescription = addressDescription;
        //       });
        //     }
        //   },
        //   child: Text('Confirm'),
        // ),

        // Positioned(
        //   top: 16.0,
        //   right: 16.0,
        //   child: IconButton(
        //     icon:
        //         Icon(isMapExpanded ? Icons.fullscreen_exit : Icons.fullscreen),
        //     onPressed: () {
        //       setState(() {
        //         isMapExpanded = !isMapExpanded;
        //         if (isMapExpanded) {
        //           _showMapFullScreen(context);
        //         } else {
        //           Navigator.of(context).pop(); // Close the full-screen map
        //         }
        //       });
        //     },
        //   ),
        // ),
      ],
    );
  }

  // void _showMapFullScreen(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true, // Ensure it covers the full screen
  //     builder: (BuildContext context) {
  //       return GestureDetector(
  //         behavior: HitTestBehavior.opaque, // Handle gestures outside the map
  //         onTap: () {
  //           // Close the full-screen map when tapping outside
  //           Navigator.of(context).pop();
  //         },
  //         child: Stack(
  //           children: [
  //             Container(
  //               height: MediaQuery.of(context).size.height,
  //               child: GoogleMap(
  //                 onMapCreated: (controller) {
  //                   setState(() {
  //                     mapController = controller;
  //                   });
  //                 },
  //                 initialCameraPosition: CameraPosition(
  //                   target: LatLng(24.7136, 46.6753), // Initial map location
  //                   zoom: 12.0, // Initial zoom level
  //                 ),
  //                 markers: markers,
  //                 onTap: _handleMapTap,
  //               ),
  //             ),
  //             Positioned(
  //               top: 0,
  //               left: 0,
  //               right: 0,
  //               child: Container(
  //                 color: Colors.white,
  //                 padding: EdgeInsets.symmetric(horizontal: 16.0),
  //                 child: Column(
  //                   children: [
  //                     TextField(
  //                       controller: searchController,
  //                       decoration: InputDecoration(
  //                         hintText: 'Search for a place...',
  //                       ),
  //                       onChanged: (value) {
  //                         // Clear previous selection
  //                         setState(() {
  //                           selectedPrediction = null;
  //                           selectedLocation = null;
  //                           selectedAddressDescription = null;
  //                         });
  //                         _performSearch(value);
  //                       },
  //                     ),
  //                     if (selectedPrediction != null)
  //                       ListTile(
  //                         title: Text(selectedPrediction?.description ??
  //                             'No description available'),
  //                         onTap: () {
  //                           // Handle selection of a prediction
  //                           _handlePredictionTap(selectedPrediction!);
  //                         },
  //                       ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //             if (selectedLocation != null)
  //               Positioned(
  //                 bottom: 16.0,
  //                 left: 16.0,
  //                 right: 16.0,
  //                 child: Container(
  //                   color: Colors.white, // Background color set to white
  //                   padding: EdgeInsets.all(16.0),
  //                   child: Column(
  //                     children: [
  //                       if (selectedAddressDescription != null)
  //                         Container(
  //                           color:
  //                               Colors.white, // Background color set to white
  //                           padding: EdgeInsets.all(8.0),
  //                           child: Text(
  //                             'Selected Address:',
  //                             style: TextStyle(
  //                               fontWeight: FontWeight.bold,
  //                             ),
  //                           ),
  //                         ),
  //                       if (selectedAddressDescription != null)
  //                         Container(
  //                           color:
  //                               Colors.white, // Background color set to white
  //                           padding: EdgeInsets.all(8.0),
  //                           child: Text(
  //                             selectedAddressDescription!,
  //                             style: TextStyle(
  //                               fontSize: 16.0,
  //                             ),
  //                           ),
  //                         ),
  //                       ElevatedButton(
  //                         onPressed: () async {
  //                           final addressDescription =
  //                               await navigateToConfirmation();
  //                           if (addressDescription != null) {
  //                             setState(() {
  //                               showMap = false;
  //                               // selectedLocation = null;
  //                               selectedPrediction = null;
  //                               selectedAddressDescription = addressDescription;
  //                             });
  //                           }
  //                         },
  //                         child: Text('Confirm'),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             Positioned(
  //               top: 16.0,
  //               right: 16.0,
  //               child: IconButton(
  //                 icon: Icon(
  //                     isMapExpanded ? Icons.fullscreen_exit : Icons.fullscreen),
  //                 onPressed: () {
  //                   setState(() {
  //                     isMapExpanded = !isMapExpanded;
  //                     if (isMapExpanded) {
  //                       _showMapFullScreen(context);
  //                     } else {
  //                       Navigator.of(context)
  //                           .pop(); // Close the full-screen map
  //                     }
  //                   });
  //                 },
  //               ),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  // Future<String?> navigateToConfirmation() async {
  //   if (selectedAddressDescription != null) {
  //     return selectedAddressDescription;
  //   } else {
  //     final result = await Navigator.push(
  //       context,
  //       MaterialPageRoute(builder: (context) => MyApp()),
  //     );
  //     return result as String?;
  //   }
  // }

  void _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        selectedPrediction = null;
        selectedLocation = null;
        selectedAddressDescription = null;
      });
      return;
    }

    try {
      final response = await _places.autocomplete(
        query,
        strictbounds: false,
        location: Location(lat: 24.7136, lng: 46.6753),
        radius: 100000,
      );
      if (response.isOkay && response.predictions.isNotEmpty) {
        final place = response.predictions.first;
        final details = await _places.getDetailsByPlaceId(place.placeId!);
        if (details.isOkay) {
          setState(() {
            selectedLocation = LatLng(
              details.result.geometry!.location.lat,
              details.result.geometry!.location.lng,
            );
            selectedPrediction = place;
          });
          _updateMarkers();
          _reverseGeocodeLocation(selectedLocation!);
        }
      }
    } catch (e) {
      setState(() {
        selectedPrediction = null;
        selectedLocation = null;
        selectedAddressDescription = null;
      });
    }
  }

  void _handleMapTap(LatLng tappedLocation) {
    setState(() {
      selectedLocation = tappedLocation;
      selectedPrediction = null;
      selectedAddressDescription = null;
    });

    _updateMarkers();
    _reverseGeocodeLocation(tappedLocation);
  }

  void _updateMarkers() {
    if (selectedLocation != null) {
      final newMarker = Marker(
        markerId: MarkerId('selectedLocation'),
        position: selectedLocation!,
      );
      setState(() {
        markers = {newMarker};
      });
    } else {
      setState(() {
        markers = {};
      });
    }
  }

  void _reverseGeocodeLocation(LatLng location) async {
    final placemarks = await geocoding.placemarkFromCoordinates(
      location.latitude,
      location.longitude,
    );
    if (placemarks.isNotEmpty) {
      final placemark = placemarks.first;
      final addressDescription =
          '${placemark.street}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}';
      setState(() {
        selectedAddressDescription = addressDescription;
        print("printing ${selectedAddressDescription} --- ");
        print(selectedLocation);
      });

      // Move the camera to the selected location
      _moveCamera(location);
    }
  }

  void _moveCamera(LatLng location) {
    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
          location, 15.0), // You can adjust the zoom level as needed
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
// import 'package:sponsite/main.dart';
// import 'dart:typed_data';

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

// Widget _titleContainer(String myTitle) {
//   return Text(
//     myTitle,
//     style: const TextStyle(
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

//   const FilterChipWidget({
//     super.key,
//     required this.chipName,
//     required this.onChipCreated,
//     required this.onChipSelected,
//   });

//   @override
//   _FilterChipWidgetState createState() => _FilterChipWidgetState();
// }

// class _FilterChipWidgetState extends State<FilterChipWidget> {
//   var _isSelected = false;
//   List<String> customCategories = [];

//   @override
//   Widget build(BuildContext context) {
//     return FilterChip(
//       label: Text(
//         widget.chipName,
//         style: const TextStyle(fontSize: 25),
//       ),
//       labelStyle: const TextStyle(
//         color: Color(0xff6200ee),
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

//   Future<void> _showAlertDialog(String message) async {
//     return showDialog<void>(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text(
//             'Warning',
//             style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
//           ),
//           backgroundColor: const Color.fromARGB(255, 51, 45, 81),
//           elevation: 0, // Remove the shadow
//           shape: const RoundedRectangleBorder(
//             borderRadius: BorderRadius.only(
//               bottomLeft: Radius.circular(20),
//               bottomRight: Radius.circular(20),
//             ),
//           ),
//           content: SingleChildScrollView(
//             child: ListBody(
//               children: <Widget>[
//                 Text(message),
//               ],
//             ),
//           ),
//           actions: <Widget>[
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               style: ButtonStyle(
//                   backgroundColor: MaterialStateProperty.all<Color>(
//                       const Color.fromARGB(255, 51, 45, 81)),
//                   //Color.fromARGB(255, 207, 186, 224),), // Background color
//                   textStyle: MaterialStateProperty.all<TextStyle>(
//                       const TextStyle(fontSize: 16)), // Text style
//                   padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
//                       const EdgeInsets.all(16)), // Padding
//                   elevation: MaterialStateProperty.all<double>(1), // Elevation
//                   shape: MaterialStateProperty.all<OutlinedBorder>(
//                     RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(30), // Border radius
//                       side: const BorderSide(
//                           color: Color.fromARGB(
//                               255, 255, 255, 255)), // Border color
//                     ),
//                   ),
//                   minimumSize:
//                       MaterialStateProperty.all<Size>(const Size(200, 50))),
//               child: const Text('OK'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showTextInputDialog() async {
//     return showDialog<void>(
//       context: context,
//       builder: (BuildContext context) {
//         String newChipName = "";
//         return AlertDialog(
//           title: const Text('Create new category'),
//           content: TextField(
//             onChanged: (text) {
//               newChipName = text;
//             },
//             decoration: const InputDecoration(labelText: "Enter Category"),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close the dialog
//               },
//               child: const Text(
//                 'Cancel',
//                 style: TextStyle(color: Color.fromARGB(255, 51, 45, 81)),
//               ),
//             ),
//             TextButton(
//                 child: const Text("Create Category",
//                     style: TextStyle(color: Color.fromARGB(255, 51, 45, 81))),
//                 onPressed: () {
//                   if (newChipName.isNotEmpty) {
//                     if (!selectedChips.contains(newChipName) &&
//                         !customCategories.contains(newChipName)) {
//                       Navigator.of(context).pop();
//                       widget.onChipCreated(newChipName);
//                       customCategories.add(newChipName);
//                     } else {
//                       _showAlertDialog("Category already exists.");
//                     }
//                   }
//                 }),
//           ],
//         );
//       },
//     );
//   }
// }

// class CustomRadioButton extends StatelessWidget {
//   final String value;
//   final String? groupValue;
//   final Function(String?) onChanged;
//   final double width; // New property for width
//   final double height; // New property for height

//   const CustomRadioButton({
//     super.key,
//     required this.value,
//     required this.groupValue,
//     required this.onChanged,
//     this.width = 100.0, // Default width
//     this.height = 40.0, // Default height
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         onChanged(value);
//       },
//       child: Container(
//         width: width, // Set width
//         height: height, // Set height
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(height / 2), // Make it round
//           border: Border.all(
//             color: (groupValue == value) ? Colors.green : Colors.black,
//           ),
//           color: (groupValue == value) ? Colors.green : Colors.white,
//         ),
//         child: Center(
//           child: Text(
//             value,
//             style: TextStyle(
//               color: (groupValue == value) ? Colors.white : Colors.black,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({Key? key}) : super(key: key);

//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// DateTime? selectedStartDate;
// DateTime? selectedEndDate;
// TimeOfDay? selectedStartTime;
// TimeOfDay? selectedEndTime;
// List<String> eventTypesList = [];
// String? selectedEventType;
// List<String> selectedChips = [];

// class _MyHomePageState extends State<MyHomePage> {
//   File? _imageFile;
//   List<String> eventTypesList = [];

//   @override
//   void initState() {
//     super.initState();
//     check();
//     fetchEventTypesFromDatabase();
//     _imageController.text =
//         'No image selected'; // Initialize the controller text
//   }

//   bool areRequiredFieldsFilled() {
//     return EnameController.text.isNotEmpty &&
//         selectedStartDate != null &&
//         selectedEndDate != null &&
//         selectedStartTime != null &&
//         selectedEndTime != null &&
//         numofAttendeesController.text.isNotEmpty &&
//         selectedChips.isNotEmpty &&
//         benefitsController.text.isNotEmpty;
//   }

//   Future<void> fetchEventTypesFromDatabase() async {
//     final eventTypes = await fetchEventTypes();

//     setState(() {
//       eventTypesList = eventTypes;
//     });
//   }

//   final String timestamp = DateTime.now().toString();

//   void _postNewEvent(
//     String type,
//     String eventName,
//     String location,
//     String startDate,
//     String endDate,
//     String startTime,
//     String endTime,
//     String numofAt,
//     List<String> categ,
//     String benefits,
//     String notes,
//   ) async {
//     final isValid = _formKey.currentState!.validate();
//     if (isValid) {
//       try {
//         final String imageUploadResult;
//         if (_imageFile != null) {
//           imageUploadResult = await _uploadImage(_imageFile!);
//         } else {
//           imageUploadResult = '';
//         }

//         dbref.child('sponseeEvents').push().set({
//           'SponseeID': sponseeID,
//           'EventType': type,
//           'EventName': eventName,
//           'Location': location,
//           'startDate': startDate,
//           'endDate': endDate,
//           'startTime': startTime,
//           'endTime': endTime,
//           'NumberOfAttendees': numofAt,
//           'Category': categ,
//           'Benefits': benefits,
//           'img': imageUploadResult,
//           'Notes': notes,
//           'TimeStamp': timestamp,
//         });

//         ///_showSuccessSnackbar(context);
//         main();

//         //runApp(const SponseeHome());
//         print('sent to database!');
//         print(type);
//         print(eventName);
//         print(location);
//         print(startDate);
//         print(endDate);
//         print(startTime);
//         print(endTime);
//         print(numofAt);
//         print(categ);
//         print(benefits);
//         print(notes);
//         print(sponseeID);
//         print(timestamp);
//       } catch (e) {
//         print('Error sending data to DB: $e');
//       }
//     }
//   }

//   Future<void> _selectStartDateAndTime(BuildContext context) async {
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
//           selectedStartDate = pickedDate;
//           selectedStartTime = pickedTime;
//           if (selectedStartDate != null && selectedStartTime != null) {
//             _startDatetimeController.text =
//                 '${selectedStartDate!.toLocal().toString().substring(0, 10)} , ${selectedStartTime!.format(context)}';
//           }
//         });
//       }
//     }
//   }

//   bool before = false;

//   Future<void> _selectEndDateAndTime(BuildContext context) async {
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
//         if (selectedStartDate != null) {
//           DateTime startDateTime = DateTime.parse(selectedStartDate.toString())
//               .add(Duration(
//                   hours: selectedStartTime!.hour,
//                   minutes: selectedStartTime!.minute));
//           DateTime endDateTime = pickedDate.add(
//               Duration(hours: pickedTime.hour, minutes: pickedTime.minute));

//           if (endDateTime.isBefore(startDateTime)) {
//             before = true;
//           }
//         }

//         setState(() {
//           selectedEndDate = pickedDate;
//           selectedEndTime = pickedTime;
//           if (selectedEndDate != null && selectedEndTime != null) {
//             _endDatetimeController.text =
//                 '${selectedEndDate!.toLocal().toString().substring(0, 10)} , ${selectedEndTime!.format(context)}';
//           }
//         });
//       }
//     }
//   }

//   int _activeStepIndex = 0;
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   final TextEditingController EnameController = TextEditingController();
//   final TextEditingController LocationController = TextEditingController();
//   final TextEditingController numofAttendeesController =
//       TextEditingController();

//   final TextEditingController benefitsController = TextEditingController();
//   final TextEditingController notesController = TextEditingController();
//   final TextEditingController _imageController =
//       TextEditingController(text: 'No image selected');
//   final TextEditingController _startDatetimeController =
//       TextEditingController(text: 'No start Date & Time selected');
//   final TextEditingController _endDatetimeController =
//       TextEditingController(text: 'No end Date & Time selected');
//   TextEditingController textEditingController = TextEditingController();

//   final DatabaseReference dbref = FirebaseDatabase.instance.reference();

//   String _selectedEventType = '';
//   bool showCategoryValidationMessage = false;
//   bool showRequiredValidationMessage = false;

//   Future<void> _removeImage() async {
//     setState(() {
//       _imageFile = null;
//       _selectedImageBytes = null;

//       print('image deleted');
//     });
//   }

//   String? _selectedImagePath;
//   Uint8List? _selectedImageBytes;

//   Future<void> _pickImage() async {
//     final imagePicker = ImagePicker();
//     final PickedFile? pickedFile =
//         await imagePicker.getImage(source: ImageSource.gallery);

//     if (pickedFile != null) {
//       final File imageFile = File(pickedFile.path);
//       _selectedImageBytes = await convertImageToBytes(imageFile);
//       setState(() {
//         _imageFile = File(pickedFile.path);
//         _selectedImagePath = pickedFile.path;
//         _imageController.text = _selectedImagePath ?? '';
//         print('image picked');
//       });
//     }
//   }

//   Future<String> _uploadImage(File imageFile) async {
//     try {
//       final firebase_storage.Reference storageReference = firebase_storage
//           .FirebaseStorage.instance
//           .ref()
//           .child('event_images')
//           .child(
//               '${DateTime.now().millisecondsSinceEpoch}.${imageFile.path.split('.').last}');

//       final uploadTask = storageReference.putFile(imageFile);

//       final firebase_storage.TaskSnapshot storageTaskSnapshot =
//           await uploadTask.whenComplete(() => null);

//       final String imageURL = await storageTaskSnapshot.ref.getDownloadURL();
//       print('image uploaded');
//       return imageURL;
//     } catch (e) {
//       print('Error uploading image: $e');
//       return '';
//     }
//   }

//   Future<Uint8List?> convertImageToBytes(File? imageFile) async {
//     Uint8List? bytes;
//     if (imageFile != null) {
//       // Read the file as bytes
//       List<int> imageBytes = await imageFile.readAsBytes();
//       // Convert the list of ints to Uint8List
//       bytes = Uint8List.fromList(imageBytes);
//     }
//     return bytes;
//   }

//   String getButtonLabel() {
//     return _selectedImageBytes != null ? 'Change Image' : 'Upload Image';
//   }

//   Future<List<String>> _fetchCategories() async {
//     final categories = <String>[];

//     try {
//       final DatabaseEvent dataSnapshot = await FirebaseDatabase.instance
//           .reference()
//           .child('Categories')
//           .once();

//       if (dataSnapshot.snapshot.value != null) {
//         final categoryData =
//             dataSnapshot.snapshot.value as Map<dynamic, dynamic>;
//         categoryData.forEach((key, value) {
//           categories.add(value.toString());
//         });
//       }
//     } catch (e) {
//       print('Error fetching categories: $e');
//     }

//     return categories;
//   }

//   Future<List<String>> fetchEventTypes() async {
//     final eventTypes = <String>[];

//     try {
//       final DatabaseEvent dataSnapshot =
//           await FirebaseDatabase.instance.reference().child('EventType').once();

//       if (dataSnapshot.snapshot.value != null) {
//         final Map<dynamic, dynamic> eventTypesMap =
//             dataSnapshot.snapshot.value as Map<dynamic, dynamic>;

//         eventTypesMap.forEach((key, value) {
//           eventTypes.add(value.toString());
//         });
//       }
//     } catch (e) {
//       print('Error fetching event types: $e');
//     }

//     return eventTypes;
//   }

//   Widget _buildCategoryChips() {
//     return FutureBuilder<List<String>>(
//       future: _fetchCategories(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const CircularProgressIndicator();
//         } else if (snapshot.hasError) {
//           return Text('Error: ${snapshot.error}');
//         } else if (snapshot.hasData) {
//           final categories = snapshot.data!;
//           categories.add("Other");
//           return Wrap(
//             spacing: 5.0,
//             runSpacing: 3.0,
//             children: categories.map((category) {
//               final isSelected = selectedChips.contains(category);

//               return FilterChipWidget(
//                 chipName: category,
//                 onChipCreated: _handleChipCreation,
//                 onChipSelected: (chipName, selected) {
//                   _handleChipSelection(chipName, selected);
//                 },
//               );
//             }).toList(),
//           );
//         } else {
//           return const Text('No categories available.');
//         }
//       },
//     );
//   }

//   void _showpostcancel() {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text(
//             "Cancel Event Post",
//             style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
//           ),
//           content: const Text(
//             "Are you sure you want to cancel this event?",
//           ),
//           backgroundColor: Colors.white,
//           elevation: 0, // Remove the shadow
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.all(Radius.circular(20)),
//           ),

//           actions: [
//             TextButton(
//               child: const Text("No",
//                   style: TextStyle(color: Color.fromARGB(255, 51, 45, 81))),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//             TextButton(
//               child: const Text("Yes",
//                   style: TextStyle(color: Color.fromARGB(255, 51, 45, 81))),
//               onPressed: () {
//                 //runApp(const SponseeHome());
//                 Navigator.of(context).pop();
//                 main();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

// //HERE
//   void _showpostconfirm() {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text(
//             "Post Event",
//             style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
//           ),
//           content: const Text(
//             "Are you sure you want to post this event?",
//           ),
//           backgroundColor: Colors.white,
//           elevation: 0, // Remove the shadow
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.all(Radius.circular(20)),
//           ),

//           actions: [
//             TextButton(
//               child: const Text("Cancel",
//                   style: TextStyle(color: Color.fromARGB(255, 51, 45, 81))),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//             TextButton(
//               child: const Text("Post",
//                   style: TextStyle(color: Color.fromARGB(255, 51, 45, 81))),
//               onPressed: () {
//                 String type = _selectedEventType;
//                 String ename = EnameController.text;
//                 String location = LocationController.text;
//                 String startDate =
//                     selectedStartDate!.toLocal().toString().substring(0, 10);
//                 String startTime = selectedStartTime!.format(context);
//                 String endDate =
//                     selectedEndDate!.toLocal().toString().substring(0, 10);
//                 String endTime = selectedEndTime!.format(context);
//                 String numOfAt = numofAttendeesController.text;
//                 List<String> categ = selectedChips;
//                 String benefits = benefitsController.text;
//                 String notes = notesController.text;
//                 _postNewEvent(type, ename, location, startDate, endDate,
//                     startTime, endTime, numOfAt, categ, benefits, notes);
//                 Navigator.of(context).pop();
//                 _showSuccessSnackbar(context);

//                 //_showSuccessSnackbar(context);
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Widget CustomRadioButton({
//     required String value,
//     required String? groupValue,
//     void Function(String?)? onChanged,
//   }) {
//     return GestureDetector(
//       onTap: () {
//         onChanged?.call(value);
//       },
//       child: Container(
//         width: 150.0, // Custom width
//         height: 60.0, // Custom height
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(
//             color: (groupValue == value)
//                 ? const Color.fromARGB(255, 51, 45, 84)
//                 : Colors.black,
//           ),
//           color: (groupValue == value)
//               ? const Color.fromARGB(255, 51, 45, 84)
//               : Colors.white,
//         ),
//         child: Center(
//           child: Text(
//             value,
//             style: TextStyle(
//               fontSize: 16,
//               color: (groupValue == value) ? Colors.white : Colors.black,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildEventTypesRadioList() {
//     return Column(
//       children: [
//         Row(
//           mainAxisAlignment:
//               MainAxisAlignment.center, // Center the children horizontally

//           children: eventTypesList.sublist(0, 4).map((eventType) {
//             return Row(
//               children: [
//                 const SizedBox(width: 8.0), // Add space between buttons
//                 Center(
//                     child: SizedBox(
//                         width: 150.0, // Custom width
//                         height: 60.0, // Custom height
//                         child: CustomRadioButton(
//                           value: eventType,
//                           groupValue: _selectedEventType,
//                           onChanged: (value) {
//                             setState(() {
//                               _selectedEventType = value as String;
//                             });
//                           },
//                         )))
//               ],
//             );
//           }).toList(),
//         ),
//         const SizedBox(height: 25),
//         Row(
//           mainAxisAlignment:
//               MainAxisAlignment.center, // Center the children horizontally

//           children: eventTypesList.sublist(4, 7).map((eventType) {
//             return Row(
//               children: [
//                 const SizedBox(width: 8.0), // Add space between buttons
//                 Center(
//                     child: SizedBox(
//                   width: 120.0, // Custom width
//                   height: 60.0, // Custom height
//                   child: CustomRadioButton(
//                     value: eventType,
//                     groupValue: _selectedEventType,
//                     onChanged: (value) {
//                       setState(() {
//                         _selectedEventType = value as String;
//                       });
//                     },
//                   ),
//                 ))
//               ],
//             );
//           }).toList(),
//         ),
//       ],
//     );
//   }

//   List<Step> stepList() => [
//         Step(
//           state: _activeStepIndex <= 0 ? StepState.indexed : StepState.complete,
//           isActive: _activeStepIndex >= 0,
//           title: const Text('Event Details',
//               style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.normal)),
//           content: Container(
//             child: Column(
//               children: [
//                 const Padding(
//                   padding: EdgeInsets.all(8.0),
//                   child: Text(
//                     "About your event",
//                     style: TextStyle(fontSize: 40),
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 50,
//                 ),
//                 const Row(
//                     mainAxisAlignment: MainAxisAlignment
//                         .center, // Center the children horizontally
//                     children: [
//                       Text("Event Type *", style: TextStyle(fontSize: 18)),
//                       SizedBox(
//                         height: 8,
//                       ),
//                     ]),
//                 Column(
//                   children: <Widget>[
//                     const SizedBox(height: 10),
//                     if (eventTypesList.isEmpty)
//                       const CircularProgressIndicator()
//                     else
//                       _buildEventTypesRadioList(),
//                   ],
//                 ),
//                 const SizedBox(
//                   height: 25.0,
//                 ),
//                 SizedBox(
//                   width: MediaQuery.of(context).size.width * 0.6,
//                   child: TextFormField(
//                     autovalidateMode: AutovalidateMode.onUserInteraction,
//                     controller: EnameController,
//                     maxLength: 20,
//                     decoration: const InputDecoration(
//                       border: OutlineInputBorder(),
//                       labelText: 'Event Name *',
//                       prefixIcon: Icon(Icons.text_fields,
//                           size: 24, color: Colors.black),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Event name is required';
//                       }
//                       print("event name not null");
//                       return null;
//                     },
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 25.0,
//                 ),
//                 SizedBox(
//                   width: MediaQuery.of(context).size.width * 0.6,
//                   child: TextFormField(
//                     controller: LocationController,
//                     decoration: const InputDecoration(
//                       border: OutlineInputBorder(),
//                       labelText: 'Event Address',
//                       prefixIcon: Icon(Icons.location_pin,
//                           size: 24, color: Colors.black),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 25.0,
//                 ),
//                 SizedBox(
//                     width: MediaQuery.of(context).size.width * 0.6,
//                     child: TextFormField(
//                       controller: _startDatetimeController,
//                       readOnly: true,
//                       decoration: const InputDecoration(
//                         labelText: 'Select start Date and Time *',
//                         border: OutlineInputBorder(),
//                         prefixIcon: Icon(
//                           Icons.calendar_month,
//                           size: 24,
//                           color: Colors.black,
//                         ),
//                       ),
//                       autovalidateMode: AutovalidateMode.onUserInteraction,
//                       onTap: () {
//                         _selectStartDateAndTime(context);
//                       },
//                     )),
//                 const SizedBox(height: 25.0),
//                 SizedBox(
//                     width: MediaQuery.of(context).size.width * 0.6,
//                     child: TextFormField(
//                       controller: _endDatetimeController,
//                       readOnly: true,
//                       decoration: const InputDecoration(
//                         labelText: 'Select end Date and Time *',
//                         border: OutlineInputBorder(),
//                         prefixIcon: Icon(
//                           Icons.calendar_month,
//                           size: 24,
//                           color: Colors.black,
//                         ),
//                       ),
//                       onTap: () {
//                         _selectEndDateAndTime(context);
//                       },
//                       autovalidateMode: AutovalidateMode.onUserInteraction,
//                       validator: (Value) {
//                         if (before == true) {
//                           return 'The End Date Can Not Be Before The Start Date';
//                         }
//                         return null;
//                       },
//                     )),
//                 const SizedBox(height: 25.0),
//                 SizedBox(
//                   width: MediaQuery.of(context).size.width * 0.6,
//                   child: TextFormField(
//                     controller: numofAttendeesController,
//                     decoration: const InputDecoration(
//                       border: OutlineInputBorder(),
//                       labelText: 'Number of attendees *',
//                       prefixIcon:
//                           Icon(Icons.people, size: 24, color: Colors.black),
//                     ),
//                     autovalidateMode: AutovalidateMode.onUserInteraction,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Number of attendees is required';
//                       }
//                       final isNumeric = int.tryParse(value);
//                       if (isNumeric == null) {
//                         return 'Please enter a valid number';
//                       }
//                       return null;
//                     },
//                     keyboardType: TextInputType.number,
//                     inputFormatters: <TextInputFormatter>[
//                       FilteringTextInputFormatter.digitsOnly,
//                     ],
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 8,
//                 ),
//                 const SizedBox(height: 25.0),
//                 SizedBox(
//                   width: MediaQuery.of(context).size.width * 0.6,
//                   child: Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         if (_selectedImageBytes != null)
//                           Image.memory(
//                             _selectedImageBytes!,
//                             width: 400,
//                             height: 500,
//                           )
//                         else
//                           Container(), // Placeholder if no image is selected
//                         SizedBox(height: 20),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: <Widget>[
//                             ElevatedButton(
//                                 onPressed: _selectedImageBytes != null
//                                     ? _pickImage
//                                     : _pickImage,
//                                 child: Text(getButtonLabel()),
//                                 style: ButtonStyle(
//                                     backgroundColor: MaterialStateProperty.all<Color>(
//                                         const Color.fromARGB(255, 51, 45, 81)),
//                                     //Color.fromARGB(255, 207, 186, 224),), // Background color
//                                     textStyle:
//                                         MaterialStateProperty.all<TextStyle>(
//                                             const TextStyle(
//                                                 fontSize: 16)), // Text style
//                                     padding: MaterialStateProperty.all<
//                                             EdgeInsetsGeometry>(
//                                         const EdgeInsets.all(16)), // Padding
//                                     elevation:
//                                         MaterialStateProperty.all<double>(
//                                             1), // Elevation
//                                     shape:
//                                         MaterialStateProperty.all<OutlinedBorder>(
//                                       RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(
//                                             30), // Border radius
//                                         side: const BorderSide(
//                                             color: Color.fromARGB(255, 255, 255,
//                                                 255)), // Border color
//                                       ),
//                                     ),
//                                     minimumSize: MaterialStateProperty.all<Size>(const Size(200, 50))) // Dynamically set the button labelText('Upload Image'),
//                                 ),
//                             SizedBox(height: 10),
//                             if (_selectedImageBytes != null)
//                               TextButton.icon(
//                                 icon: Icon(Icons.delete_forever_outlined),
//                                 onPressed: _removeImage,
//                                 label: Text(''),
//                                 //child: Text('Remove Image'),
//                               ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 if (showRequiredValidationMessage)
//                   const Padding(
//                     padding: EdgeInsets.all(8.0),
//                     child: Text(
//                       'Please fill all the required fields',
//                       style: TextStyle(color: Colors.red),
//                     ),
//                   ),
//                 const SizedBox(
//                   height: 50,
//                 ),
//               ],
//             ),
//           ),
//         ),
//         Step(
//           state: _activeStepIndex <= 1 ? StepState.indexed : StepState.complete,
//           isActive: _activeStepIndex >= 1,
//           title: const Text(
//             'Sponsorship Category',
//             style: TextStyle(fontSize: 25, fontWeight: FontWeight.normal),
//           ),
//           content: Column(
//             children: [
//               const Padding(
//                 padding: EdgeInsets.all(8.0),
//                 child: Text(
//                   "What do you need from sponsors?",
//                   style: TextStyle(fontSize: 40),
//                 ),
//               ),
//               const SizedBox(
//                 height: 50,
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(left: 8.0),
//                 child: Align(
//                   alignment: Alignment.centerLeft,
//                   child: Container(
//                     child: _buildCategoryChips(),
//                   ),
//                 ),
//               ),
//               const SizedBox(
//                 height: 50,
//               ),
//               const Text("Selected Categories:",
//                   style: TextStyle(fontSize: 20)),
//               const SizedBox(
//                 height: 30,
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: TextField(
//                   controller: textEditingController,
//                   readOnly: true, // Set the TextField to read-only
//                   decoration: InputDecoration(
//                     //hintText: "Selected Chips",
//                     border: const OutlineInputBorder(
//                       borderRadius: BorderRadius.all(Radius.circular(10.0)),
//                       borderSide: BorderSide(color: Colors.grey),
//                     ),
//                     prefix:
//                         _buildSelectedChipsWidget(), // Display selected chips inside the TextField
//                   ),
//                 ),
//               ),
//               const SizedBox(
//                 height: 50,
//               ),
//               if (showCategoryValidationMessage)
//                 const Padding(
//                   padding: EdgeInsets.all(8.0),
//                   child: Text(
//                     'Please select at least one category',
//                     style: TextStyle(color: Colors.red),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//         Step(
//           state: _activeStepIndex <= 0 ? StepState.indexed : StepState.complete,
//           isActive: _activeStepIndex >= 2,
//           title: const Text(
//             'Benefits',
//             style: TextStyle(fontSize: 25, fontWeight: FontWeight.normal),
//           ),
//           content: Container(
//             child: Column(
//               children: [
//                 const Padding(
//                   padding: EdgeInsets.all(8.0),
//                   child: Text(
//                     "Sponsor Benefits",
//                     style: TextStyle(fontSize: 40),
//                   ),
//                 ),
//                 TextFormField(
//                   controller: benefitsController,
//                   maxLength: 200,
//                   decoration: const InputDecoration(
//                     border: OutlineInputBorder(),
//                     labelText: 'Benefits to the sponsor *',
//                   ),
//                   autovalidateMode: AutovalidateMode.onUserInteraction,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Benefits to the sponsor is required';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(
//                   height: 26,
//                 ),
//                 TextFormField(
//                   controller: notesController,
//                   maxLength: 200,
//                   decoration: const InputDecoration(
//                       border: OutlineInputBorder(),
//                       labelText: 'Additional Notes',
//                       contentPadding: EdgeInsets.fromLTRB(15, 20, 20, 20)),
//                 ),
//                 const SizedBox(
//                   height: 26,
//                 ),
//                 // ElevatedButton(
//                 //     onPressed: () {
//                 //       if (benefitsController.text.isEmpty) {
//                 //         setState(() {
//                 //           showRequiredValidationMessage = true;
//                 //         });
//                 //       } else {
//                 //         _showpostconfirm();
//                 //       }
//                 //     },
//                 //     style: ButtonStyle(
//                 //         backgroundColor: MaterialStateProperty.all<Color>(
//                 //             const Color.fromARGB(255, 51, 45, 81)),
//                 //         //Color.fromARGB(255, 207, 186, 224),), // Background color
//                 //         textStyle: MaterialStateProperty.all<TextStyle>(
//                 //             const TextStyle(fontSize: 16)), // Text style
//                 //         padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
//                 //             const EdgeInsets.all(16)), // Padding
//                 //         elevation:
//                 //             MaterialStateProperty.all<double>(1), // Elevation
//                 //         shape: MaterialStateProperty.all<OutlinedBorder>(
//                 //           RoundedRectangleBorder(
//                 //             borderRadius:
//                 //                 BorderRadius.circular(30), // Border radius
//                 //             side: const BorderSide(
//                 //                 color: Color.fromARGB(
//                 //                     255, 255, 255, 255)), // Border color
//                 //           ),
//                 //         ),
//                 //         minimumSize: MaterialStateProperty.all<Size>(
//                 //             const Size(200, 50))),
//                 //     child: const Text("Post Event",
//                 //         style: TextStyle(fontSize: 20, color: Colors.white))),
//                 if (showRequiredValidationMessage)
//                   const Padding(
//                     padding: EdgeInsets.all(8.0),
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

//   List<String> selectedChips = [];

//   void _showSuccessSnackbar(BuildContext context) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text(
//           'Your event is posted to sponsors!',
//           style: TextStyle(
//             color: Colors.white,
//           ),
//         ),
//         backgroundColor: Colors.green, // Set the background color
//       ),
//     );
//   }

//   Widget _buildSelectedChipsWidget() {
//     if (selectedChips.isEmpty) {
//       return Container(); // Return an empty container if no chips are selected.
//     }

//     return Wrap(
//       spacing: 5.0,
//       runSpacing: 3.0,
//       children: selectedChips.map((chipName) {
//         return Chip(
//           label: Text(chipName), // Empty label for the chip
//           deleteIcon: const Icon(
//               Icons.cancel), // Add a delete (cancel) icon for each chip
//           onDeleted: () {
//             _handleChipRemoval(chipName);
//           },
//         );
//       }).toList(),
//     );
//   }

//   void _updateTextFieldText() {
//     // Generate a visual representation for selected chips, for example, using icons
//     String visualRepresentation = selectedChips.map((chipName) {
//       return ' '; // You can use any symbol or icon here
//     }).join(' '); // Use a space or any separator you prefer

//     textEditingController.text =
//         visualRepresentation; // Set the visual representation as the text
//   }

//   void _handleChipRemoval(String chipName) {
//     setState(() {
//       selectedChips.remove(chipName);
//       _updateTextFieldText();
//     });
//   }

//   void _handleChipCreation(String newChipName) {
//     setState(() {
//       if (newChipName.isNotEmpty) {
//         selectedChips.add(newChipName);
//         showCategoryValidationMessage = false;
//         _updateTextFieldText();
//       }
//     });
//   }

//   void _handleChipSelection(String chipName, bool isSelected) {
//     setState(() {
//       if (isSelected && !selectedChips.contains(chipName)) {
//         selectedChips.add(chipName);
//       } else if (!isSelected && selectedChips.contains(chipName)) {
//         selectedChips.remove(chipName);
//       }
//       _updateTextFieldText();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: const Text('New Event'),
//           backgroundColor: const Color.fromARGB(255, 51, 45, 81),
//         ),
//         body: Form(
//             key: _formKey,
//             // child: IgnorePointer(
//             //   ignoring: true, // Make the steps unclickable
//             child: GestureDetector(
//               onTap: () {},
//               child: Stepper(
//                 controlsBuilder: (context, onStepContinue) {
//                   return Row(
//                     children: <Widget>[
//                       if (_activeStepIndex != 0)
//                         ElevatedButton(
//                           onPressed: () {
//                             if (_activeStepIndex == 0) {
//                               return;
//                             }
//                             setState(() {
//                               _activeStepIndex -= 1;
//                             });
//                           },
//                           style: ButtonStyle(
//                               backgroundColor: MaterialStateProperty.all<Color>(
//                                   const Color.fromARGB(255, 51, 45, 81)),
//                               //Color.fromARGB(255, 207, 186, 224),), // Background color
//                               textStyle: MaterialStateProperty.all<TextStyle>(
//                                   const TextStyle(fontSize: 16)), // Text style
//                               padding:
//                                   MaterialStateProperty.all<EdgeInsetsGeometry>(
//                                       const EdgeInsets.all(16)), // Padding
//                               elevation: MaterialStateProperty.all<double>(
//                                   1), // Elevation
//                               shape: MaterialStateProperty.all<OutlinedBorder>(
//                                 RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(
//                                       30), // Border radius
//                                   side: const BorderSide(
//                                       color: Color.fromARGB(
//                                           255, 255, 255, 255)), // Border color
//                                 ),
//                               ),
//                               minimumSize: MaterialStateProperty.all<Size>(
//                                   const Size(200, 50))),
//                           child: const Text(
//                             'BACK',
//                           ),
//                         )
//                       else if (_activeStepIndex == 0)
//                         ElevatedButton(
//                           onPressed: () {
//                             _showpostcancel();
//                           },
//                           style: ButtonStyle(
//                               backgroundColor: MaterialStateProperty.all<Color>(
//                                   const Color.fromARGB(255, 51, 45, 81)),
//                               //Color.fromARGB(255, 207, 186, 224),), // Background color
//                               textStyle: MaterialStateProperty.all<TextStyle>(
//                                   const TextStyle(fontSize: 16)), // Text style
//                               padding:
//                                   MaterialStateProperty.all<EdgeInsetsGeometry>(
//                                       const EdgeInsets.all(16)), // Padding
//                               elevation: MaterialStateProperty.all<double>(
//                                   1), // Elevation
//                               shape: MaterialStateProperty.all<OutlinedBorder>(
//                                 RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(
//                                       30), // Border radius
//                                   side: const BorderSide(
//                                       color: Color.fromARGB(
//                                           255, 255, 255, 255)), // Border color
//                                 ),
//                               ),
//                               minimumSize: MaterialStateProperty.all<Size>(
//                                   const Size(200, 50))),
//                           child: const Text(
//                             'CANCEL',
//                           ),
//                         ),
//                       const SizedBox(
//                         width: 350,
//                       ),
//                       if (_activeStepIndex != (stepList().length - 1))
//                         ElevatedButton(
//                           onPressed: () => {
//                             if (_activeStepIndex == 0)
//                               {
//                                 // Check if required fields are empty
//                                 if (_selectedEventType.isEmpty ||
//                                     EnameController.text.isEmpty ||
//                                     _startDatetimeController.text ==
//                                         'No start Date & Time selected' ||
//                                     _endDatetimeController.text ==
//                                         'No end Date & Time selected' ||
//                                     numofAttendeesController.text.isEmpty)
//                                   {
//                                     setState(() {
//                                       showRequiredValidationMessage = true;
//                                     })
//                                   }
//                                 else
//                                   {
//                                     setState(() {
//                                       _activeStepIndex += 1;
//                                       showRequiredValidationMessage = false;
//                                     })
//                                   }
//                               }
//                             else if (_activeStepIndex == 1)
//                               {
//                                 if (selectedChips.isEmpty)
//                                   {
//                                     setState(() {
//                                       showCategoryValidationMessage = true;
//                                     })
//                                   }
//                                 else
//                                   {
//                                     setState(() {
//                                       _activeStepIndex += 1;
//                                       showCategoryValidationMessage = false;
//                                     })
//                                   }
//                               }
//                             else
//                               {
//                                 // No additional validation for the last step, simply increment
//                                 setState(() {
//                                   _activeStepIndex += 1;
//                                 })
//                               }
//                           },
//                           style: ButtonStyle(
//                               backgroundColor: MaterialStateProperty.all<Color>(
//                                   const Color.fromARGB(255, 51, 45, 81)),
//                               //Color.fromARGB(255, 207, 186, 224),), // Background color
//                               textStyle: MaterialStateProperty.all<TextStyle>(
//                                   const TextStyle(fontSize: 16)), // Text style
//                               padding:
//                                   MaterialStateProperty.all<EdgeInsetsGeometry>(
//                                       const EdgeInsets.all(16)), // Padding
//                               elevation: MaterialStateProperty.all<double>(
//                                   1), // Elevation
//                               shape: MaterialStateProperty.all<OutlinedBorder>(
//                                 RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(
//                                       30), // Border radius
//                                   side: const BorderSide(
//                                       color: Color.fromARGB(
//                                           255, 255, 255, 255)), // Border color
//                                 ),
//                               ),
//                               minimumSize: MaterialStateProperty.all<Size>(
//                                   const Size(200, 50))),
//                           //),
//                           child: const Text(
//                             'NEXT',
//                           ),
//                         )
//                       else if (_activeStepIndex == stepList().length - 1)
//                         ElevatedButton(
//                             onPressed: () {
//                               if (benefitsController.text.isEmpty) {
//                                 setState(() {
//                                   showRequiredValidationMessage = true;
//                                 });
//                               } else {
//                                 _showpostconfirm();
//                               }
//                             },
//                             style: ButtonStyle(
//                                 backgroundColor: MaterialStateProperty.all<Color>(
//                                     const Color.fromARGB(255, 51, 45, 81)),
//                                 //Color.fromARGB(255, 207, 186, 224),), // Background color
//                                 textStyle: MaterialStateProperty.all<TextStyle>(
//                                     const TextStyle(
//                                         fontSize: 16)), // Text style
//                                 padding:
//                                     MaterialStateProperty.all<EdgeInsetsGeometry>(
//                                         const EdgeInsets.all(16)), // Padding
//                                 elevation: MaterialStateProperty.all<double>(
//                                     1), // Elevation
//                                 shape:
//                                     MaterialStateProperty.all<OutlinedBorder>(
//                                   RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(
//                                         30), // Border radius
//                                     side: const BorderSide(
//                                         color: Color.fromARGB(255, 255, 255,
//                                             255)), // Border color
//                                   ),
//                                 ),
//                                 minimumSize: MaterialStateProperty.all<Size>(
//                                     const Size(200, 50))),
//                             child: const Text("Post Event",
//                                 style: TextStyle(fontSize: 20, color: Colors.white))),
//                     ],
//                   );
//                 },
//                 type: StepperType.horizontal,
//                 currentStep: _activeStepIndex,
//                 steps: stepList(),
//                 onStepTapped: null, //(int index) {
//                 //setState(() {
//                 //   _activeStepIndex = index;
//                 // });
//                 // },
//               ),
//             )));
//   }
// }
