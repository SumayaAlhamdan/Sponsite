import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' show BaseRequest, Response;
import 'package:http/io_client.dart' show IOClient, IOStreamedResponse;
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:url_launcher/url_launcher.dart';

class Event {
  final List<String> Category;
  Event({
    required this.Category,
  });
}

class Offer {
  List<String> categories;

  Offer({
    required this.categories,
  });
}

class AdminPanel extends StatefulWidget {
  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final DatabaseReference _usersRef =
      FirebaseDatabase.instance.reference().child('newUsers');
  final DatabaseReference dbCategories =
      FirebaseDatabase.instance.reference().child('Categories');
  Map<String, String> categories = {};
  String adminID = "";
  String email = "";
  User? user = FirebaseAuth.instance.currentUser;

  @override
  initState() {
    super.initState();
    check();
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

  Future<void> showconfirmationDialog(BuildContext context, String? userType,
      String? name, String userId, String? userEmail, String type) async {
    await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            userType == 'Sponsor' ? '$type Sponsor' : '$type Sponsee',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
          ),
          content: Text(
            'Are you sure you want to ${type.toLowerCase()} $name as ${userType?.toLowerCase()}?',
            style: TextStyle(fontSize: 20),
          ),
          backgroundColor: Colors.white,
          elevation: 0, // Remove the shadow
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          actions: <Widget>[
            Row(
              children: [
                SizedBox(
                  width: 30,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Color.fromARGB(255, 51, 45, 81),
                    ),
                  ),
                ),
                SizedBox(
                  width: 200,
                ),
                ElevatedButton(
                    child: Text(type,
                        style: TextStyle(
                            color: Color.fromARGB(255, 242, 241, 241))),
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            const Color.fromARGB(255, 51, 45, 81)),
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
                                BorderRadius.circular(10), // Border radius
                            side: const BorderSide(
                                color: Color.fromARGB(
                                    255, 255, 255, 255)), // Border color
                          ),
                        ),
                        minimumSize: MaterialStateProperty.all<Size>(
                            const Size(200, 50))),
                    onPressed: () async {
                      if (type == "Accept") {
                        acceptUser(userId, userType, userEmail, name);
                        Navigator.of(context).pop();
                      } else if (type == "Reject") {
                        rejectedUser(userId, userType, userEmail, name);
                        Navigator.of(context).pop();
                      }
                    })
              ],
            ),
          ],
        );
      },
    );
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

  Future<void> sendEmail(String? userEmail, String? name, String type) async {
    final DatabaseReference database =
        FirebaseDatabase.instance.reference().child('Admins');
    database.child(adminID).once().then((DatabaseEvent event) async {
      final smtpServer = gmail(email, "lxcx kkdm quez tcio");
      Message? message;

      if (type == "Accepted") {
        message = Message()
          ..from = Address(email)
          ..recipients = [userEmail] //recipent email
          ..subject =
              'Sponsite: Your Application Access Request Has Been Approved' //subject of the email
          ..text = '''Dear $name
We are pleased to inform you that your request for access to our application has been approved.
You can now log in and start enjoying the benefits of Sponsite.

1) Go to login page of Sponsite.
2) Enter your email and password.

If you encounter any issues during the login process or have any questions about using our application, please don't hesitate to reach out to our support team at $email

Thank you for choosing our application. We look forward to serving you, and we hope you find it valuable for your needs.

Best regards,
Sponsite
''';
      } else if (type == "Rejected") {
        message = Message()
          ..from = Address(email)
          ..recipients = [userEmail] //recipent email
          ..subject =
              'Sponsite: Your Application Access Request Has Been Rejecetd' //subject of the email
          ..text = '''Dear $name
We regret to inform you that your request for access to our application has been rejected. After careful consideration, we have determined that we are unable to grant you access at this time.

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

  Future<void> _showSignOutConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Sign Out Confirmation',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
          ),
          content: const Text(
            'Are you sure you want to sign out?',
            //style: TextStyle(fontSize: 20),
          ),
          backgroundColor: Colors.white,
          elevation: 0, // Remove the shadow
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Color.fromARGB(255, 51, 45, 81),
                ),
              ),
            ),
            ElevatedButton(
                child: const Text("Sign Out",
                    style:
                        TextStyle(color: Color.fromARGB(255, 242, 241, 241))),
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        const Color.fromARGB(255, 51, 45, 81)),
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
                            BorderRadius.circular(10), // Border radius
                        side: const BorderSide(
                            color: Color.fromARGB(
                                255, 255, 255, 255)), // Border color
                      ),
                    ),
                    minimumSize:
                        MaterialStateProperty.all<Size>(const Size(200, 50))),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pop();
                })
          ],
        );
      },
    );
  }

  Future<void> _showAccountDialog(BuildContext context, String email) async {
    TextEditingController emailController = TextEditingController(text: email);

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'My account',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
          ),
          content: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Row(
              children: [
                Text(
                  "Email: ",
                  style: const TextStyle(fontSize: 20),
                ),
                Text(
                  email,
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0, // Remove the shadow
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'OK',
                style: TextStyle(
                    color: Color.fromARGB(255, 51, 45, 81), fontSize: 15),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(90), // Set the desired height
          child: Container(
            height: 90,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 51, 45, 81),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
            child: Row(
              children: [
                SizedBox(width: 280),
                Center(
                  child: Text(
                    "Admin Panel",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 35,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(width: 220),
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_horiz,
                    color: Color.fromARGB(255, 255, 255, 255),
                    size: 45,
                  ),
                  onSelected: (value) {
                    // Handle menu item selection here
                    switch (value) {
                      case 'myAccount':
                        _showAccountDialog(context, email);
                        break;
                      case 'signOut':
                        _showSignOutConfirmationDialog(context);
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      const PopupMenuItem<String>(
                        value: 'myAccount',
                        child: ListTile(
                          leading: Icon(
                            Icons.perm_identity,
                            size: 30,
                          ),
                          title: Text(
                            'My Account',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'signOut',
                        child: ListTile(
                          leading: Icon(
                            Icons.exit_to_app,
                            size: 30,
                            color: Color.fromARGB(255, 240, 90, 80),
                          ),
                          title: Text(
                            'Sign out',
                            style: TextStyle(
                                fontSize: 20,
                                color: Color.fromARGB(255, 240, 90, 80)),
                          ),
                        ),
                      ),
                    ];
                  },
                ),
              ],
            ),
          ),
        ), // Hide the back button
        body: FutureBuilder<DatabaseEvent>(
          future: _usersRef.once(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                DataSnapshot data = snapshot.data!.snapshot;
                if (data.value != null && data.value is Map<dynamic, dynamic>) {
                  Map<dynamic, dynamic> usersData =
                      data.value as Map<dynamic, dynamic>;
                  List<Widget> userWidgets = [];
                  userWidgets.add(
                    Text(
                      " New users",
                      style: const TextStyle(
                          color: Color.fromARGB(255, 51, 45, 81),
                          fontSize: 26,
                          fontWeight: FontWeight.w500),
                    ),
                  );
                  usersData.entries.forEach((entry) {
                    String userId = entry.key;
                    Map<dynamic, dynamic> userData = entry.value;

                    String? userEmail = userData['Email'];
                    String status = userData['Status'];
                    String? name = userData['Name'];
                    String type = userData['Type'];
                    String file = userData['authentication document'];
                    if (userEmail != null) {
                      userWidgets.add(
                        Card(
                          color: Colors.white,
                          elevation: 2,
                          margin: const EdgeInsets.all(8),
                          child: ListTile(
                            title: Text(
                              name!,
                              style: const TextStyle(
                                color: Color.fromARGB(255, 51, 45, 81),
                                fontSize: 22,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userEmail,
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 51, 45, 81),
                                    fontSize: 17,
                                  ),
                                ),
                                Text(
                                  type ?? 'No type available',
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 51, 45, 81),
                                    fontSize: 17,
                                  ),
                                )
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(
                                          255, 129, 192, 131),
                                    ),
                                    onPressed: () {
                                      showconfirmationDialog(context, type,
                                          name, userId, userEmail, "Accept");
                                    },
                                    child: Text(
                                      'Accept',
                                      style: TextStyle(color: Colors.white),
                                    )),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Color.fromARGB(255, 240, 90, 80),
                                    ),
                                    onPressed: () {
                                      showconfirmationDialog(context, type,
                                          name, userId, userEmail, "Reject");
                                    },
                                    child: Text(
                                      'Reject',
                                      style: TextStyle(color: Colors.white),
                                    )),
                                IconButton(
                                  icon: Icon(Icons.more_vert),
                                  color: Color.fromARGB(255, 91, 79, 158),
                                  onPressed: () {
                                    ViewOthersProfileAdmin(context, userEmail,
                                        name, status, type, file);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                  });

                  return ListView(
                    children: userWidgets,
                  );
                } else {
                  return Center(child: Text('No new users available.'));
                }
              } else {
                return Center(child: Text('No new users available.'));
              }
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ));
  }

  void acceptUser(
      String? userId, String? userType, String? userEmail, String? name) {
    if (userId == null || userType == null) {
      print("User ID or User Type is null.");
      return;
    }

    DatabaseReference newUsersRef =
        FirebaseDatabase.instance.reference().child('newUsers');
    newUsersRef.child(userId).update({'Status': 'Active'}).then((_) {
      DatabaseReference? destinationRef;
      if (userType == 'Sponsor') {
        destinationRef =
            FirebaseDatabase.instance.reference().child('Sponsors');
      } else if (userType == 'Sponsee') {
        destinationRef =
            FirebaseDatabase.instance.reference().child('Sponsees');
      }

      newUsersRef.child(userId).once().then((DatabaseEvent event) {
        DataSnapshot userData = event.snapshot;
        Map<dynamic, dynamic>? userMap =
            userData.value as Map<dynamic, dynamic>?;
        if (userMap != null) {
          destinationRef?.child(userId).set(userMap).then((_) {
            newUsersRef.child(userId).remove();
            sendEmail(userEmail, name, "Accepted");
            setState(() {});
          });
        }
      }).catchError((error) {
        print("Error fetching user data: $error");
        // Handle the error appropriately
      });
    });
  }

  void rejectedUser(
      String userId, String? userType, String? userEmail, String? name) {
    if (userId == null || userType == null) {
      print("User ID or User Type is null.");
      return;
    }

    DatabaseReference newUsersRef =
        FirebaseDatabase.instance.reference().child('newUsers');
    newUsersRef.child(userId).update({'Status': 'Inactive'}).then((_) {
      DatabaseReference? destinationRef;
      if (userType == 'Sponsor') {
        destinationRef =
            FirebaseDatabase.instance.reference().child('rejectedSponsors');
      } else if (userType == 'Sponsee') {
        destinationRef =
            FirebaseDatabase.instance.reference().child('rejectedSponsees');
      }

      newUsersRef.child(userId).once().then((DatabaseEvent event) {
        DataSnapshot userData = event.snapshot;
        Map<dynamic, dynamic>? userMap =
            userData.value as Map<dynamic, dynamic>?;
        if (userMap != null) {
          destinationRef?.child(userId).set(userMap).then((_) {
            newUsersRef.child(userId).remove();
            sendEmail(userEmail, name, "Rejected");
            setState(() {});
          });
        }
      }).catchError((error) {
        print("Error fetching user data: $error");
        // Handle the error appropriately
      });
    });
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
