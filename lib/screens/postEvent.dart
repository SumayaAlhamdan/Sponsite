import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

// void main() {
//   runApp(const MyApp());
// }
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
// String getUsername() {
//   User? user = FirebaseAuth.instance.currentUser;

//   if (user != null) {
//     // User is signed in
//     String email = user.email!;
//     print(email);
//     return email;
//   } else {
//     // No user is signed in
//     return '';
//   }
// }

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
    required this.onChipSelected, // Add this parameter
  }) : super();

  @override
  _FilterChipWidgetState createState() => _FilterChipWidgetState();
}

class _FilterChipWidgetState extends State<FilterChipWidget> {
  var _isSelected = false;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(widget.chipName),
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
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Create Category"),
              onPressed: () {
                if (newChipName.isNotEmpty) {
                  widget.onChipCreated(newChipName);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}

enum EventTypeEnum {
  Social,
  Business,
  Sports,
  Entertainment,
  Educational,
  Charity,
  Technology
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

DateTime? selectedDate;
TimeOfDay? selectedTime;

class _MyHomePageState extends State<MyHomePage> {
  void initState() {
    super.initState();
    check();
  }

  void _postNewEvent(
      String type,
      String eventName,
      String location,
      String date,
      String time,
      String numofAt,
      String categ,
      String benefits,
      String notes) async {
    if (benefitsController.text.isEmpty) {
      setState(() {
        showRequiredValidationMessage = true;
      });
    }
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      try {
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
        });
      }
    }
  }

  int _activeStepIndex = 0;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // First step controllers
  //event type
  final TextEditingController EnameController = TextEditingController();
  //dateandtime
  final TextEditingController LocationController = TextEditingController();
  final TextEditingController numofAttendeesController =
      TextEditingController();

  //Second step
  //categories

  // Third step controllers
  final TextEditingController benefitsController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  final DatabaseReference dbref = FirebaseDatabase.instance.reference();

  EventTypeEnum? _eventTypeEnum;
  List<String> selectedChips = [];
  bool showCategoryValidationMessage = false;
  bool showRequiredValidationMessage = false;

  List<Step> stepList() => [
        Step(
          state: _activeStepIndex <= 0 ? StepState.indexed : StepState.complete,
          isActive: _activeStepIndex >= 0,
          title: const Text('Event Details'),
          content: Container(
            child: Column(
              children: [
                Row(children: [
                  Text("Event Type"),
                  const SizedBox(
                    height: 8,
                  ),
                ]),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile(
                        contentPadding: EdgeInsets.all(0.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                        value: EventTypeEnum.Social,
                        groupValue: _eventTypeEnum,
                        tileColor: Colors.deepPurple.shade50,
                        title: Text('Social'),
                        onChanged: (val) {
                          setState(() {
                            _eventTypeEnum = val;
                            showRequiredValidationMessage = false;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 5.0),
                    Expanded(
                      child: RadioListTile(
                        contentPadding: EdgeInsets.all(0.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                        value: EventTypeEnum.Business,
                        title: Text('Business'),
                        groupValue: _eventTypeEnum,
                        tileColor: Colors.deepPurple.shade50,
                        onChanged: (val) {
                          setState(() {
                            _eventTypeEnum = val;
                            showRequiredValidationMessage = false;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 5.0),
                    Expanded(
                      child: RadioListTile(
                        contentPadding: EdgeInsets.all(0.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                        value: EventTypeEnum.Sports,
                        title: Text('Sports'),
                        groupValue: _eventTypeEnum,
                        tileColor: Colors.deepPurple.shade50,
                        onChanged: (val) {
                          setState(() {
                            _eventTypeEnum = val;
                            showRequiredValidationMessage = false;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 5.0),
                    Expanded(
                      child: RadioListTile(
                        contentPadding: EdgeInsets.all(0.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                        value: EventTypeEnum.Entertainment,
                        groupValue: _eventTypeEnum,
                        tileColor: Colors.deepPurple.shade50,
                        title: Text('Entertainment'),
                        onChanged: (val) {
                          setState(() {
                            _eventTypeEnum = val;
                            showRequiredValidationMessage = false;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 5.0),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile(
                        contentPadding: EdgeInsets.all(0.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                        value: EventTypeEnum.Educational,
                        title: Text('Educational'),
                        groupValue: _eventTypeEnum,
                        tileColor: Colors.deepPurple.shade50,
                        onChanged: (val) {
                          setState(() {
                            _eventTypeEnum = val;
                            showRequiredValidationMessage = false;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 5.0),
                    Expanded(
                      child: RadioListTile(
                        contentPadding: EdgeInsets.all(0.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                        value: EventTypeEnum.Charity,
                        title: Text('Charity'),
                        groupValue: _eventTypeEnum,
                        tileColor: Colors.deepPurple.shade50,
                        onChanged: (val) {
                          setState(() {
                            _eventTypeEnum = val;
                            showRequiredValidationMessage = false;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 5.0),
                    Expanded(
                      child: RadioListTile(
                        contentPadding: EdgeInsets.all(0.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                        value: EventTypeEnum.Technology,
                        title: Text('Technology'),
                        groupValue: _eventTypeEnum,
                        tileColor: Colors.deepPurple.shade50,
                        onChanged: (val) {
                          setState(() {
                            _eventTypeEnum = val;
                            showRequiredValidationMessage = false;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                TextFormField(
                  controller: EnameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Event Name *',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Event Name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 8,
                ),
                TextFormField(
                  controller: LocationController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Event Address',
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                ElevatedButton(
                  onPressed: () => _selectDateAndTime(context),
                  child: const Text('Select Date and Time *'),
                ),
                if (selectedDate != null)
                  Text(
                    'Event Date: ${selectedDate!.toLocal().toString().substring(0, 10)} ',
                    style: TextStyle(fontSize: 16),
                  ),
                if (selectedTime != null)
                  Text(
                    'Event Time:  ${selectedTime!.format(context)}',
                    style: TextStyle(fontSize: 16),
                  ),
                TextFormField(
                  controller: numofAttendeesController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Number of attendees *',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Number of attendees is required';
                    }
                    // Use a regular expression to check if the input is a number
                    final isNumeric = int.tryParse(value);
                    if (isNumeric == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                  keyboardType:
                      TextInputType.number, // Set the keyboard type to number
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly, // Allow only digits
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                if (showRequiredValidationMessage) // Show the message conditionally
                  Padding(
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
        Step(
          state: _activeStepIndex <= 1 ? StepState.indexed : StepState.complete,
          isActive: _activeStepIndex >= 1,
          title: const Text('Sponsorship Category'),
          content: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: _titleContainer("What do you need from sponsors?"),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    child: Wrap(
                      spacing: 5.0,
                      runSpacing: 3.0,
                      children: <Widget>[
                        FilterChipWidget(
                          chipName: 'Food',
                          onChipCreated: _handleChipCreation,
                          onChipSelected: _handleChipSelection,
                        ),
                        FilterChipWidget(
                          chipName: 'Coffee/Beverages',
                          onChipCreated: _handleChipCreation,
                          onChipSelected: _handleChipSelection,
                        ),
                        FilterChipWidget(
                          chipName: 'Financial',
                          onChipCreated: _handleChipCreation,
                          onChipSelected: _handleChipSelection,
                        ),
                        FilterChipWidget(
                          chipName: 'Prizes',
                          onChipCreated: _handleChipCreation,
                          onChipSelected: _handleChipSelection,
                        ),
                        FilterChipWidget(
                          chipName: 'Venue',
                          onChipCreated: _handleChipCreation,
                          onChipSelected: _handleChipSelection,
                        ),
                        FilterChipWidget(
                          chipName: 'Other',
                          onChipCreated: _handleChipCreation,
                          onChipSelected: _handleChipSelection,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Display the selected chips
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Wrap(
                  spacing: 5.0,
                  runSpacing: 3.0,
                  children: selectedChips.map((chipName) {
                    return Chip(
                      label: Text(chipName),
                      onDeleted: () {
                        setState(() {
                          selectedChips.remove(chipName);
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              if (showCategoryValidationMessage) // Show the message conditionally
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
          state: StepState.complete,
          //StepState.indexed : StepState.complete,
          isActive: _activeStepIndex >= 2,
          title: const Text('Benefits *'),
          content: Container(
            child: Column(
              children: [
                TextFormField(
                  controller: benefitsController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Benefits to the sponsor *',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Benefits to the sponsor is required'; // Validation message
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
                  ),
                ),
                const SizedBox(
                  height: 26,
                ),
                ElevatedButton(
                  onPressed: () {
                    String type = _eventTypeEnum
                        .toString()
                        .substring(_eventTypeEnum.toString().indexOf('.') + 1);
                    String ename = EnameController.text;
                    String location = LocationController.text;
                    String date =
                        selectedDate!.toLocal().toString().substring(0, 10);
                    String time = selectedTime!.format(context);
                    String numOfAt = numofAttendeesController.text;
                    String categ = selectedChips.toString();
                    String benefits = benefitsController.text;
                    String notes = notesController.text;

                    _postNewEvent(type, ename, location, date, time, numOfAt,
                        categ, benefits, notes);
                  },
                  child: const Text("Post Event"),
                ),
                if (showRequiredValidationMessage) // Show the message conditionally
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

  void _handleChipCreation(String newChipName) {
    setState(() {
      if (newChipName.isNotEmpty) {
        selectedChips.add(newChipName);
      }
    });
  }

  void _handleChipSelection(String chipName, bool isSelected) {
    setState(() {
      if (isSelected) {
        selectedChips.add(chipName);
      } else {
        selectedChips.remove(chipName);
      }
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
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
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
        ),
        body: Form(
          key: _formKey,
          child: Stepper(
            controlsBuilder: (context, onStepContinue) {
              return Row(
                children: <Widget>[
                  if (_activeStepIndex != 0)
                    TextButton(
                      onPressed: () {
                        if (_activeStepIndex == 0) {
                          return;
                        }
                        setState(() {
                          _activeStepIndex -= 1;
                        });
                      },
                      child: const Text(
                        'BACK',
                        style: TextStyle(color: Colors.deepPurple),
                      ),
                    )
                  else if (_activeStepIndex == 0)
                    TextButton(
                      onPressed: () {
                        return;
                      },
                      child: const Text(
                        'CANCEL POST',
                        style: TextStyle(color: Colors.deepPurple),
                      ),
                    ),
                  if (_activeStepIndex != (stepList().length - 1))
                    TextButton(
                      onPressed: () => {
                        if (_activeStepIndex == 0)
                          {
                            // Check if required fields are empty
                            if (_eventTypeEnum == null ||
                                EnameController.text.isEmpty ||
                                selectedDate == null ||
                                selectedTime == null ||
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
                      child: const Text(
                        'NEXT',
                        style: TextStyle(color: Colors.deepPurple),
                      ),
                    )
                ],
              );
            },
            type: StepperType.horizontal,
            currentStep: _activeStepIndex,
            steps: stepList(),
            onStepTapped: (int index) {
              setState(() {
                _activeStepIndex = index;
              });
            },
          ),
        ));
  }
}
