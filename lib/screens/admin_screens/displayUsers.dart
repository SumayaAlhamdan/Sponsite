import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:mailer/smtp_server/gmail.dart';

class DisplayUsers extends StatefulWidget {
  @override
  _DisplayUsersState createState() => _DisplayUsersState();
}

class _DisplayUsersState extends State<DisplayUsers> {
  User? user = FirebaseAuth.instance.currentUser;
  String adminID = '';
  final databaseReference = FirebaseDatabase.instance.reference();
  List<Map<String, dynamic>> sponsors = [];
  List<Map<String, dynamic>> sponsees = [];
  List<Map<String, dynamic>> Dsponsors = [];
  List<Map<String, dynamic>> Dsponsees = [];
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    if (user != null) {
      adminID = user!.uid;
      print('Admin ID: $adminID');
    } else {
      print('User is not logged in.');
    }
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
              userType == 'Sponsor' ? 'Activate Sponsor' : 'Activate Sponsee'),
          content: Text('Are you sure you want to activate $name?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Activate'),
              onPressed: () {
                ActivateUser(userId, userType, userEmail, name);
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
          title: Text(userType == 'Sponsor'
              ? 'Deactivate Sponsor'
              : 'Deactivate Sponsee'),
          content: Text('Are you sure you want to deactivate $name?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Deactivate'),
              onPressed: () {
                DeactivateUser(userId, userType, userEmail, name);
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> sendEmail(String? userEmail, String? name, String type) async {
    String email = ""; //Your Email;

    final DatabaseReference database =
        FirebaseDatabase.instance.reference().child('Sponsees');
    database.child(adminID).once().then((DatabaseEvent event) async {
      DataSnapshot userData = event.snapshot;
      Map<dynamic, dynamic>? userMap = userData.value as Map<dynamic, dynamic>?;
      if (userMap != null) {
        email = userMap['Email'];
        print(email);
        print(userEmail);
      }

      final smtpServer = gmail(email, "gifp fhas owwl bdtb");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Management'),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              tabs: [
                Tab(text: 'Sponsors'),
                Tab(text: 'Sponsees'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildUserList(sponsors, Dsponsors),
                  _buildUserList(sponsees, Dsponsees),
                ],
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category,
          style: TextStyle(
            color: Color.fromARGB(255, 51, 45, 81),
            fontSize: 25,
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: ScrollPhysics(),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            String id = user['ID'] ?? 'No ID available';
            String name = user['Name'] ?? 'No name available';
            String email = user['Email'] ?? 'No email available';
            String status = user['Status'] ?? 'No status available';
            String type = user['Type'] ?? 'No type available';
            String pic = user['Picture'] ?? '';
            Color statusColor = status == 'Active' ? Colors.green : Colors.red;
            bool isUserInactive = status != 'Active';
            bool isUserActive = status == 'Active';
            return Card(
              color: Color.fromARGB(255, 255, 255, 255),
              child: ListTile(
                title: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage:
                          NetworkImage(pic), // Set the image as backgroundImage
                      backgroundColor: Colors.transparent,
                    ),
                    SizedBox(
                        width:
                            10), // Add space between the picture and the name
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
                                  context, type, name, id, email);
                            }
                          : null, // Disable if the user is already active
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          isUserInactive ? const Color.fromARGB(255, 129, 192, 131) : Color.fromARGB(255, 201, 200, 200),
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
                    SizedBox(width: 6.0), // Add space between buttons
                    ElevatedButton(
                      onPressed:
                          isUserActive // Enable deactivation button if the user is active
                              ? () {
                                  showDeactivationDialog(
                                      context, type, name, id, email);
                                }
                              : null, // Disable if the user is already inactive
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          isUserActive ? Color.fromARGB(255, 240, 90, 80) : Color.fromARGB(255, 201, 200, 200),
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
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

