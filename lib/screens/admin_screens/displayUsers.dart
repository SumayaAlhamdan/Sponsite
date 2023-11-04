import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' show BaseRequest, Response;
import 'package:http/io_client.dart' show IOClient, IOStreamedResponse;
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:url_launcher/url_launcher.dart';

class DisplayUsers extends StatefulWidget {
  @override
  _DisplayUsersState createState() => _DisplayUsersState();
}

class _DisplayUsersState extends State<DisplayUsers> {
  User? user = FirebaseAuth.instance.currentUser;
  String adminID = "";
  String email = "";
  final databaseReference = FirebaseDatabase.instance.reference();
  List<Map<String, dynamic>> sponsors = [];
  List<Map<String, dynamic>> sponsees = [];
  List<Map<String, dynamic>> Dsponsors = [];
  List<Map<String, dynamic>> Dsponsees = [];
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> filteredSponsors = [];
  List<Map<String, dynamic>> filteredDSponsors = [];
  List<Map<String, dynamic>> filteredSponsees = [];
  List<Map<String, dynamic>> filteredDSponsees = [];

  @override
  void initState() {
    check();
    super.initState();
    fetchSponsors().listen((sponsorsData) {
      setState(() {
        sponsors = sponsorsData;
        //   print('Sponsors updated:');
        //   print(sponsors);
      });
    });
    fetchDSponsors().listen((sponsorsData) {
      setState(() {
        Dsponsors = sponsorsData;
        print('Sponsors updated:');
        print(Dsponsors);
      });
    });
    fetchSponsees().listen((sponseesData) {
      setState(() {
        sponsees = sponseesData;
        //   print('Sponsees updated:');
        //  print(sponsees);
      });
    });
    fetchDSponsees().listen((sponseesData) {
      setState(() {
        Dsponsees = sponseesData;
        print('Sponsees updated:');
        print(Dsponsees);
      });
    });
    filteredSponsors = sponsors;
    filteredDSponsors = Dsponsors;
    filteredSponsees = sponsees;
    filteredDSponsees = Dsponsees;
    super.initState();
  }

  void filterUsers(String text) {
    setState(() {
      filteredSponsors = sponsors
          .where((user) =>
              user['Name']?.toLowerCase().contains(text.toLowerCase()) == true)
          .toList();
      filteredDSponsors = Dsponsors.where((user) =>
              user['Name']?.toLowerCase().contains(text.toLowerCase()) == true)
          .toList();
      filteredSponsees = sponsees
          .where((user) =>
              user['Name']?.toLowerCase().contains(text.toLowerCase()) == true)
          .toList();
      filteredDSponsees = Dsponsees.where((user) =>
              user['Name']?.toLowerCase().contains(text.toLowerCase()) == true)
          .toList();
    });
  }

  void check() {
    if (user != null) {
      adminID = user!.uid;
      print('Admin ID: $adminID');
      final DatabaseReference database =
          FirebaseDatabase.instance.reference().child('Admins');
      database.child(adminID).once().then((DatabaseEvent event) async {
        DataSnapshot userData = event.snapshot;
        Map<dynamic, dynamic>? userMap =
            userData.value as Map<dynamic, dynamic>?;
        if (userMap != null) {
          email = userMap['Email'];
        }
      });
    } else {
      print('User is not logged in.');
    }
  }

  Stream<List<Map<String, dynamic>>> fetchSponsors() {
    DatabaseReference sponRef = _database.child('Sponsors');

    return sponRef.onValue.map(
      (event) {
        List<Map<String, dynamic>> Sponsors = [];
        DataSnapshot dataSnapshot = event.snapshot;

        try {
          if (dataSnapshot.value != null) {
            Map<dynamic, dynamic>? dataMap = dataSnapshot.value as Map?;

            if (dataMap != null) {
              dataMap.forEach((key, value) async {
                if (value is Map<dynamic, dynamic>) {
                  Map<String, dynamic> data = {
                    'ID': key,
                    'Name': value['Name'] ?? '',
                    'Email': value['Email'] ?? '',
                    'Status': value['Status'] ?? 'Active',
                    'doc': value['authentication document'] ?? '',
                    'Type': 'Sponsor',
                  };

                  Sponsors.add(data);
                }
              });
            }
          }
        } catch (e) {
          print('Error occurred: $e');
        }
        return Sponsors;
      },
    );
  }

  Stream<List<Map<String, dynamic>>> fetchSponsees() {
    DatabaseReference sponRef = _database.child('Sponsees');

    return sponRef.onValue.map(
      (event) {
        List<Map<String, dynamic>> Sponsees = [];
        DataSnapshot dataSnapshot = event.snapshot;

        try {
          if (dataSnapshot.value != null) {
            Map<dynamic, dynamic>? dataMap = dataSnapshot.value as Map?;

            if (dataMap != null) {
              dataMap.forEach((key, value) async {
                if (value is Map<dynamic, dynamic>) {
                  Map<String, dynamic> data = {
                    'ID': key,
                    'Name': value['Name'] ?? '',
                    'Email': value['Email'] ?? '',
                    'Status': value['Status'] ?? 'Active',
                    'doc': value['authentication document'] ?? '',
                    'Type': 'Sponsee',
                  };

                  Sponsees.add(data);
                }
              });
            }
          }
        } catch (e) {
          print('Error occurred: $e');
        }
        return Sponsees;
      },
    );
  }

  Stream<List<Map<String, dynamic>>> fetchDSponsors() {
    DatabaseReference sponRef = _database.child('DeactivatedSponsors');

    return sponRef.onValue.map(
      (event) {
        List<Map<String, dynamic>> Sponsors = [];
        DataSnapshot dataSnapshot = event.snapshot;

        try {
          if (dataSnapshot.value != null) {
            Map<dynamic, dynamic>? dataMap = dataSnapshot.value as Map?;

            if (dataMap != null) {
              dataMap.forEach((key, value) async {
                if (value is Map<dynamic, dynamic>) {
                  Map<String, dynamic> data = {
                    'ID': key,
                    'Name': value['Name'] ?? '',
                    'Email': value['Email'] ?? '',
                    'Status': value['Status'] ?? 'Active',
                    'Type': 'Sponsor',
                    'Picture': value['Picture'],
                    'doc': value['authentication document'],
                  };

                  Sponsors.add(data);
                }
              });
            }
          }
        } catch (e) {
          print('Error occurred: $e');
        }
        return Sponsors;
      },
    );
  }

  Stream<List<Map<String, dynamic>>> fetchDSponsees() {
    DatabaseReference sponRef = _database.child('DeactivatedSponsees');

    return sponRef.onValue.map(
      (event) {
        List<Map<String, dynamic>> Sponsees = [];
        DataSnapshot dataSnapshot = event.snapshot;

        try {
          if (dataSnapshot.value != null) {
            Map<dynamic, dynamic>? dataMap = dataSnapshot.value as Map?;

            if (dataMap != null) {
              dataMap.forEach((key, value) async {
                if (value is Map<dynamic, dynamic>) {
                  Map<String, dynamic> data = {
                    'ID': key,
                    'Name': value['Name'] ?? '',
                    'Email': value['Email'] ?? '',
                    'Status': value['Status'] ?? 'Active',
                    'Type': 'Sponsee',
                    'Picture': value['Picture'],
                    'doc': value['authentication document']
                  };

                  Sponsees.add(data);
                }
              });
            }
          }
        } catch (e) {
          print('Error occurred: $e');
        }
        return Sponsees;
      },
    );
  }

  void ActivateUser(
      String? userId, String? userType, String? userEmail, String? name) {
    print('ACTIVATING');

    if (userId == null || userType == null) {
      print("User ID or User Type is null.");
      return;
    }

    DatabaseReference? destinationRef = FirebaseDatabase.instance.reference();
    DatabaseReference? ref = FirebaseDatabase.instance.reference();

    if (userType == 'Sponsor') {
      destinationRef =
          FirebaseDatabase.instance.reference().child('DeactivatedSponsors');
      ref = FirebaseDatabase.instance.reference().child('Sponsors');
    } else if (userType == 'Sponsee') {
      destinationRef =
          FirebaseDatabase.instance.reference().child('DeactivatedSponsees');
      ref = FirebaseDatabase.instance.reference().child('Sponsees');
    }

    destinationRef.child(userId).once().then((DatabaseEvent event) {
      DataSnapshot userData = event.snapshot;
      Map<dynamic, dynamic>? userMap = userData.value as Map<dynamic, dynamic>?;
      print(userMap);
      if (userMap != null) {
        userMap['Status'] = 'Active'; // Change the user status
        ref?.child(userId).set(userMap).then((_) {
          destinationRef?.child(userId).remove();
          sendEmail(userEmail, name, 'Activated');
        });
      }
    });

    // send email
  }

  void DeactivateUser(
      String? userId, String? userType, String? userEmail, String? name) {
    print('DEACTIVATING');
    if (userId == null || userType == null) {
      print("User ID or User Type is null.");
      return;
    }

    DatabaseReference? destinationRef;
    DatabaseReference? ref;

    if (userType == 'Sponsor') {
      destinationRef =
          FirebaseDatabase.instance.reference().child('DeactivatedSponsors');
      ref = FirebaseDatabase.instance.reference().child('Sponsors');
    } else if (userType == 'Sponsee') {
      destinationRef =
          FirebaseDatabase.instance.reference().child('DeactivatedSponsees');
      ref = FirebaseDatabase.instance.reference().child('Sponsees');
    }

    ref?.child(userId).once().then((DatabaseEvent event) {
      DataSnapshot userData = event.snapshot;
      Map<dynamic, dynamic>? userMap = userData.value as Map<dynamic, dynamic>?;
      print(userMap);
      if (userMap != null) {
        userMap['Status'] = 'Inactive'; // Change the user status
        destinationRef!.child(userId).set(userMap).then((_) {
          ref!.child(userId).remove();
          sendEmail(userEmail, name, 'Deactivated');
        });
      }
    });

    // send email
  }

  Future<void> showActivationDialog(BuildContext context, String? userType,
      String? name, String? userId, String? userEmail) async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            userType == 'Sponsor' ? 'Activate Sponsor' : 'Activate Sponsee',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
          ),
          content: Text('Are you sure you want to activate $name?'),
          backgroundColor: Colors.white,
          elevation: 0, // Remove the shadow
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Color.fromARGB(255, 51, 45, 81)),
              ),
            ),
            ElevatedButton(
              child: Text(
                'Activate',
                style: TextStyle(color: Colors.white),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                textStyle: MaterialStateProperty.all<TextStyle>(
                  const TextStyle(fontSize: 16),
                ),
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                  const EdgeInsets.all(16),
                ),
              ),
              onPressed: () {
                ActivateUser(userId, userType, userEmail, name);
                sendEmail(userEmail, name, 'Activated');
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> showDeactivationDialog(BuildContext context, String? userType,
      String? name, String? userId, String? userEmail) async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            userType == 'Sponsor' ? 'Deactivate Sponsor' : 'Deactivate Sponsee',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
          ),
          content: Text('Are you sure you want to deactivate $name?'),
          backgroundColor: Colors.white,
          elevation: 0, // Remove the shadow
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              child: Text(
                'Deactivate',
                style: TextStyle(color: Colors.white),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                textStyle: MaterialStateProperty.all<TextStyle>(
                  const TextStyle(fontSize: 16),
                ),
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                  const EdgeInsets.all(16),
                ),
              ),
              onPressed: () {
                DeactivateUser(userId, userType, userEmail, name);
                sendEmail(userEmail, name, 'Deactivated');
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> sendEmail(String? userEmail, String? name, String type) async {
    final DatabaseReference database =
        FirebaseDatabase.instance.reference().child('Sponsees');
    database.child(adminID).once().then((DatabaseEvent event) async {
      final smtpServer = gmail(email, "lxcx kkdm quez tcio");
      Message? message;

      if (type == "Activated") {
        message = Message()
          ..from = Address(email)
          ..recipients = [userEmail] //recipent email
          ..subject =
              'Sponsite: Your Account Has Been Activated' //subject of the email
          ..text = '''Dear $name
We are pleased to inform you that your account has been activated.
You can now log in and start enjoying the benefits of Sponsite.

1) Go to login page of Sponsite.
2) Enter your email and password.

If you encounter any issues during the login process or have any questions about using our application, please don't hesitate to reach out to our support team at $email

Thank you for choosing our application. We look forward to serving you, and we hope you find it valuable for your needs.

Best regards,
Sponsite
''';
      } else if (type == "Deactivated") {
        message = Message()
          ..from = Address(email)
          ..recipients = [userEmail] //recipent email
          ..subject =
              'Sponsite: Your Account Has Been Deactivated' //subject of the email
          ..text = '''Dear $name
We regret to inform you that your account has been deactivated. After careful consideration, we have determined that we are unable to grant you access at this time.

We appreciate your interest in our platform and thank you for considering us. If you believe that this decision was made in error or if you have any questions or concerns, please feel free to reach out to our support team at $email. 
They will be happy to assist you with any inquiries you may have.

Thank you for considering our application.

Best regards,
Sponsite
''';
      }
      try {
        final sendReport = await send(message!, smtpServer);
        print('Message sent: ' +
            sendReport.toString()); //print if the email is sent
      } on MailerException catch (e) {
        print('Message not sent. \n' +
            e.toString()); //print if the email is not sent
        // e.toString() will show why the email is not sending
      }
    }).catchError((error) {
      print("Error fetching user data: $error");
      // Handle the error appropriately
    });
  }

  Future<void> ViewOthersProfileAdmin(BuildContext context, String email,
      String name, String status, String type, String file) async {
    await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("User Information", style: TextStyle(fontSize: 25)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    width: 300,
                    height: 60,
                    padding: EdgeInsets.all(10),
                    child: Center(
                      child: Text(
                        "Email:",
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                    decoration: BoxDecoration(
                        color: Color.fromARGB(255, 147, 139, 192),
                        border: Border.all(
                          // Add this line to set borders
                          color: Colors.black45,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(0),
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(0),
                        )),
                  ),
                  Container(
                    width: 300,
                    height: 60,
                    padding: EdgeInsets.all(10),
                    child: Center(
                      child: Text(
                        email,
                        style: TextStyle(
                            fontSize: 20,
                            color: const Color.fromARGB(255, 0, 0, 0)),
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 255, 255, 255),
                      border: Border.all(
                        // Add this line to set borders
                        color: Colors.black45,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(0),
                        topRight: Radius.circular(10),
                        bottomLeft: Radius.circular(0),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                  ),
                ]),
                SizedBox(height: 10),
                Row(children: [
                  Container(
                    width: 300,
                    height: 60,
                    padding: EdgeInsets.all(10),
                    child: Center(
                      child: Text(
                        "Name:",
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                    decoration: BoxDecoration(
                        color: Color.fromARGB(255, 147, 139, 192),
                        border: Border.all(
                          // Add this line to set borders
                          color: Colors.black45,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(0),
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(0),
                        )),
                  ),
                  Container(
                    width: 300,
                    height: 60,
                    padding: EdgeInsets.all(10),
                    child: Center(
                      child: Text(
                        name,
                        style: TextStyle(
                            fontSize: 20,
                            color: const Color.fromARGB(255, 0, 0, 0)),
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 255, 255, 255),
                      border: Border.all(
                        // Add this line to set borders
                        color: Colors.black45,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(0),
                        topRight: Radius.circular(10),
                        bottomLeft: Radius.circular(0),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                  ),
                ]),
                SizedBox(height: 10),
                Row(children: [
                  Container(
                    width: 300,
                    height: 60,
                    padding: EdgeInsets.all(10),
                    child: Center(
                      child: Text(
                        "Type:",
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                    decoration: BoxDecoration(
                        color: Color.fromARGB(255, 147, 139, 192),
                        border: Border.all(
                          // Add this line to set borders
                          color: Colors.black45,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(0),
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(0),
                        )),
                  ),
                  Container(
                    width: 300,
                    height: 60,
                    padding: EdgeInsets.all(10),
                    child: Center(
                      child: Text(
                        type,
                        style: TextStyle(
                            fontSize: 20,
                            color: const Color.fromARGB(255, 0, 0, 0)),
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 255, 255, 255),
                      border: Border.all(
                        // Add this line to set borders
                        color: Colors.black45,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(0),
                        topRight: Radius.circular(10),
                        bottomLeft: Radius.circular(0),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                  ),
                ]),
                SizedBox(height: 10),
                Row(children: [
                  Container(
                    width: 300,
                    height: 60,
                    padding: EdgeInsets.all(10),
                    child: Center(
                      child: Text(
                        "Status:",
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                    decoration: BoxDecoration(
                        color: Color.fromARGB(255, 147, 139, 192),
                        border: Border.all(
                          // Add this line to set borders
                          color: Colors.black45,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(0),
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(0),
                        )),
                  ),
                  Container(
                    width: 300,
                    height: 60,
                    padding: EdgeInsets.all(10),
                    child: Center(
                      child: Text(
                        status,
                        style: TextStyle(
                            fontSize: 20,
                            color: const Color.fromARGB(255, 0, 0, 0)),
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 255, 255, 255),
                      border: Border.all(
                        // Add this line to set borders
                        color: Colors.black45,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(0),
                        topRight: Radius.circular(10),
                        bottomLeft: Radius.circular(0),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                  ),
                ]),
                SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      width: 300,
                      height: 60,
                      padding: EdgeInsets.all(10),
                      child: Center(
                        child: Text(
                          "Authentication document:",
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ),
                      decoration: BoxDecoration(
                          color: Color.fromARGB(255, 147, 139, 192),
                          border: Border.all(
                            // Add this line to set borders
                            color: Colors.black45,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(0),
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(0),
                          )),
                    ),
                    Container(
                      width: 300,
                      height: 60,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 255, 255, 255),
                        border: Border.all(
                          // Add this line to set borders
                          color: Colors.black45,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(0),
                          topRight: Radius.circular(10),
                          bottomLeft: Radius.circular(0),
                          bottomRight: Radius.circular(10),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () async {
                          String? downloadURL = await downloadFile(file);
                          if (downloadURL != null) {
                            launchUrl(Uri.parse(downloadURL));
                          } else {
                            // Handle the case where an error occurred during the download
                          }
                        },
                        child: Center(
                          child: Text(
                            file,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 15, 113, 193),
                              decoration: TextDecoration.underline,
                              decorationColor:
                                  Color.fromARGB(255, 15, 113, 193),
                              decorationThickness: 2.0,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0, // Remove the shadow
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Color.fromARGB(255, 51, 45, 81),
                  fontSize: 20,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<String?> downloadFile(String fileName) async {
    try {
      final Reference storageRef =
          FirebaseStorage.instance.ref().child('files/$fileName');
      final String downloadURL = await storageRef.getDownloadURL();
      print(downloadURL);
      return downloadURL;
    } catch (e) {
      print('Error downloading file: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> tabViewChildren = [];

    if (filteredDSponsees.isNotEmpty ||
        filteredDSponsors.isNotEmpty ||
        filteredSponsees.isNotEmpty ||
        filteredSponsors.isNotEmpty) {
      tabViewChildren.addAll([
        _buildUserList(filteredSponsors, filteredDSponsors),
        _buildUserList(filteredSponsees, filteredDSponsees),
      ]);
    } else {
      tabViewChildren.addAll([
        _buildUserList(sponsors, Dsponsors),
        _buildUserList(sponsees, Dsponsees),
      ]);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('User Management'),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                onChanged: (text) {
                  filterUsers(text);
                },
                decoration: InputDecoration(
                  labelText: 'Search Users',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search,
                      color: Color.fromARGB(255, 51, 45, 81)),
                  labelStyle: TextStyle(color: Color.fromARGB(255, 51, 45, 81)),
                ),
              ),
            ),
            TabBar(
              tabs: [
                Tab(text: 'Sponsors'),
                Tab(text: 'Sponsees'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: tabViewChildren,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserList(
    List<Map<String, dynamic>> activatedUsers,
    List<Map<String, dynamic>> deactivatedUsers,
  ) {
    if (activatedUsers.isEmpty && deactivatedUsers.isEmpty) {
      return Center(child: Text('No users available.'));
    }

    return Column(
      children: [
        _buildUserCategory('Activated Users', activatedUsers),
        _buildUserCategory('Deactivated Users', deactivatedUsers),
      ],
    );
  }

  Widget _buildUserCategory(String category, List<Map<String, dynamic>> users) {
    if (users.isEmpty) {
      return SizedBox.shrink();
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category,
            style: const TextStyle(
              color: Color.fromARGB(255, 51, 45, 81),
              fontSize: 26,
              fontWeight: FontWeight.w500,
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: users.map((user) {
                String id = user['ID'] ?? 'No ID available';
                String name = user['Name'] ?? 'No name available';
                String email = user['Email'] ?? 'No email available';
                String status = user['Status'] ?? 'No status available';
                String type = user['Type'] ?? 'No type available';
                String pic = user['Picture'] ?? '';
                String authdoc =
                    user['doc'] ?? 'No authentication document available';
                Color statusColor =
                    status == 'Active' ? Colors.green : Colors.red;
                bool isUserInactive = status != 'Active';
                bool isUserActive = status == 'Active';

                return Card(
                  color: Color.fromARGB(255, 255, 255, 255),
                  child: ListTile(
                    title: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(pic),
                          backgroundColor: Colors.transparent,
                        ),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                color: Color.fromARGB(255, 51, 45, 81),
                                fontSize: 22,
                              ),
                            ),
                            Text(
                              email,
                              style: const TextStyle(
                                color: Color.fromARGB(255, 51, 45, 81),
                                fontSize: 17,
                              ),
                            ),
                            Text(
                              status,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 17,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: isUserInactive
                              ? () {
                                  showActivationDialog(
                                    context,
                                    type,
                                    name,
                                    id,
                                    email,
                                  );
                                }
                              : null,
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              isUserInactive
                                  ? const Color.fromARGB(255, 129, 192, 131)
                                  : Color.fromARGB(255, 201, 200, 200),
                            ),
                            padding: MaterialStateProperty.all(
                              EdgeInsets.all(8.0),
                            ),
                          ),
                          child: Text(
                            'Activate',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        SizedBox(width: 6.0),
                        ElevatedButton(
                          onPressed: isUserActive
                              ? () {
                                  showDeactivationDialog(
                                    context,
                                    type,
                                    name,
                                    id,
                                    email,
                                  );
                                }
                              : null,
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              isUserActive
                                  ? Color.fromARGB(255, 240, 90, 80)
                                  : Color.fromARGB(255, 201, 200, 200),
                            ),
                            padding: MaterialStateProperty.all(
                              EdgeInsets.all(8.0),
                            ),
                          ),
                          child: Text(
                            'Deactivate',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.arrow_forward),
                          color: Color.fromARGB(255, 91, 79, 158),
                          onPressed: () {
                            ViewOthersProfileAdmin(
                              context,
                              email,
                              name,
                              status,
                              type,
                              authdoc,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class GoogleAPIClient extends IOClient {
  final Map<String, String> _headers;

  GoogleAPIClient(this._headers) : super();

  @override
  Future<IOStreamedResponse> send(BaseRequest request) =>
      super.send(request..headers.addAll(_headers));

  @override
  Future<Response> head(Uri url, {Map<String, String>? headers}) =>
      super.head(url,
          headers: (headers != null ? (headers..addAll(_headers)) : headers));
}
