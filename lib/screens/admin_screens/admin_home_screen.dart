import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' show BaseRequest, Response;
import 'package:http/io_client.dart' show IOClient, IOStreamedResponse;
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class AdminPanel extends StatefulWidget {
  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final DatabaseReference _usersRef = FirebaseDatabase.instance.reference().child('newUsers');
  final DatabaseReference dbCategories = FirebaseDatabase.instance.reference().child('Categories');
  Map<String, String> categories = {};
  String adminID="";
  User? user = FirebaseAuth.instance.currentUser;

  @override
initState() {
    super.initState();
    check();
    _loadCategoriesFromFirebase();
  }

    void check() {
    if (user != null) {
      adminID = user!.uid;
      print('Admin ID: $adminID');
    } else {
      print('User is not logged in.');
    }
  }


  Future<void> sendEmail(String? userEmail, String? name, String type) async {
              String email = ""; //Your Email;

        final DatabaseReference database = FirebaseDatabase.instance.reference().child('Sponsees');
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

 if (type=="Accepted"){
  message = Message()
    ..from = Address(email)
    ..recipients=[userEmail] //recipent email
    ..subject = 'Sponsite: Your Application Access Request Has Been Approved' //subject of the email
    ..text ='''Dear $name
We are pleased to inform you that your request for access to our application has been approved.
You can now log in and start enjoying the benefits of Sponsite.

1) Go to login page of Sponsite.
2) Enter your email and password.

If you encounter any issues during the login process or have any questions about using our application, please don't hesitate to reach out to our support team at $email

Thank you for choosing our application. We look forward to serving you, and we hope you find it valuable for your needs.

Best regards,
Sponsite
''';
 }
 else if(type=="Rejected"){
    message = Message()
    ..from = Address(email)
    ..recipients=[userEmail] //recipent email
    ..subject = 'Sponsite: Your Application Access Request Has Been Rejecetd' //subject of the email
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
    print('Message sent: ' + sendReport.toString()); //print if the email is sent
  } on MailerException catch (e) {
    print('Message not sent. \n'+ e.toString()); //print if the email is not sent
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
      appBar: AppBar(title: Text('Admin Panel')),
      body: FutureBuilder<DatabaseEvent>(
        future: _usersRef.once(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              DataSnapshot data = snapshot.data!.snapshot;
              if (data.value != null && data.value is Map<dynamic, dynamic>) {
                Map<dynamic, dynamic> usersData = data.value as Map<dynamic, dynamic>;
                List<Widget> userWidgets = [];

                usersData.forEach((key, value) {
                  String? userEmail = value['Email'];
                  String? status = value['Status'];
                  if (userEmail != null) {
                    userWidgets.add(
                      ListTile(
                        title: Text(userEmail!),
                        subtitle: Text(status ?? 'No status available'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                acceptUser(key, value['Type'], value['Email'], value['Name']);
                              },
                              child: Text('Accept'),
                            ),
                            SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () {
                                rejectedUser(key, value['Type'], value['Email'], value['Name']);
                              },
                              child: Text('Reject'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                });

                userWidgets.add(editCategory()); // Add the categories widget here.

                return ListView(
                  children: userWidgets,
                );
              } else {
                return Text('Data is not in the expected format.');
              }
            } else {
              return Text('No data found.');
            }
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }

  void acceptUser(String? userId, String? userType, String? userEmail, String? name) {
    if (userId == null || userType == null) {
      print("User ID or User Type is null.");
      return;
    }

    DatabaseReference newUsersRef = FirebaseDatabase.instance.reference().child('newUsers');
    newUsersRef.child(userId).update({'Status': 'Active'}).then((_) {
      DatabaseReference? destinationRef;
      if (userType == 'Sponsor') {
        destinationRef = FirebaseDatabase.instance.reference().child('Sponsors');
      } else if (userType == 'Sponsee') {
        destinationRef = FirebaseDatabase.instance.reference().child('Sponsees');
      }

      newUsersRef.child(userId).once().then((DatabaseEvent event) {
        DataSnapshot userData = event.snapshot;
        Map<dynamic, dynamic>? userMap = userData.value as Map<dynamic, dynamic>?;
        if (userMap != null) {
          destinationRef?.child(userId).set(userMap).then((_) {
            newUsersRef.child(userId).remove();
             sendEmail(userEmail,name,"Accepted");
          });
        }
      }).catchError((error) {
        print("Error fetching user data: $error");
        // Handle the error appropriately
      });
    });
  }

  void rejectedUser(String userId, String userType, String? userEmail, String? name) {
    if (userId == null || userType == null) {
      print("User ID or User Type is null.");
      return;
    }

    DatabaseReference newUsersRef = FirebaseDatabase.instance.reference().child('newUsers');
    newUsersRef.child(userId).update({'Status': 'Inactive'}).then((_) {
      DatabaseReference? destinationRef;
      if (userType == 'Sponsor') {
        destinationRef = FirebaseDatabase.instance.reference().child('rejectedSponsors');
      } else if (userType == 'Sponsee') {
        destinationRef = FirebaseDatabase.instance.reference().child('rejectedSponsees');
      }

      newUsersRef.child(userId).once().then((DatabaseEvent event) {
        DataSnapshot userData = event.snapshot;
        Map<dynamic, dynamic>? userMap = userData.value as Map<dynamic, dynamic>?;
        if (userMap != null) {
          destinationRef?.child(userId).set(userMap).then((_) {
            newUsersRef.child(userId).remove();
             sendEmail(userEmail,name,"Rejected");
          });
        }
      }).catchError((error) {
        print("Error fetching user data: $error");
        // Handle the error appropriately
      });
    });
  }

  void _loadCategoriesFromFirebase() {
    dbCategories.onValue.listen((category) {
      if (category.snapshot.value != null) {
        setState(() {
          categories.clear();
          Map<dynamic, dynamic> categoriesData = category.snapshot.value as Map<dynamic, dynamic>;

          categoriesData.forEach((key, value) {
            categories[key] = value as String;
          });
        });
      }
    });
  }

Widget editCategory() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 16.0),
        child: Text(
          'Categories',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      Card(
        margin: EdgeInsets.all(16.0),
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Spacer to push the button to the right
                Spacer(),
                ElevatedButton(
                  onPressed: _showTextInputDialog,
                  child: Text('Add New Category'),
                ),
              ],
            ),
            if (categories.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('No categories available.'),
              )
            else
              ListView(
                shrinkWrap: true,
                children: categories.entries.map((entry) {
                  return Card(
                    margin: EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text(entry.value),
                      trailing: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _editCategoryDialog(entry.key, entry.value); // Pass the category key and name for editing
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    ],
  );
}


void _showTextInputDialog() async {
  TextEditingController categoryController = TextEditingController();
  int charCount = 0;
  List<String> existingCategories = categories.values.toList();


  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Add New Category'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: categoryController,
                        onChanged: (value) {
                          setState(() {
                            charCount = value.length;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Category Name',
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        '$charCount/15',
                        style: TextStyle(
                          color: charCount <= 15 ? Colors.grey : Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  String categoryName = categoryController.text.trim();

                  
                  if (existingCategories.contains(categoryName)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Category already exists. Please enter a unique name.'),
                      ),
                    );
                    return;
                  }

                
                  if (categoryName.isNotEmpty &&
                      categoryName.length <= 15 &&
                      RegExp(r'^[a-zA-Z ]+$').hasMatch(categoryName)) {
                    // Add the category to the database at the end of the list
                    dbCategories.push().set(categoryName);
                    Navigator.pop(context); // Close the dialog
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Invalid category name.'),
                      ),
                    );
                  }
                },
                child: Text('Add'),
              ),
            ],
          );
        },
      );
    },
  );
}

void _editCategoryDialog(String categoryKey, String categoryName) async {
  TextEditingController categoryController = TextEditingController(text: categoryName);
  int charCount = categoryName.length; // Set charCount to the length of the existing category name
  List<String> existingCategories = categories.values.toList();

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Edit Category'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: categoryController,
                        onChanged: (value) {
                          setState(() {
                            charCount = value.length;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Category Name',
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        '$charCount/15',
                        style: TextStyle(
                          color: charCount <= 15 ? Colors.grey : Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  String newCategoryName = categoryController.text.trim();

                  if (existingCategories.contains(newCategoryName) && newCategoryName != categoryName) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Category already exists. Please enter a unique name.'),
                      ),
                    );
                    return;
                  }

                  if (newCategoryName.isNotEmpty && newCategoryName.length <= 15 && RegExp(r'^[a-zA-Z ]+$').hasMatch(newCategoryName)) {
                    // Update the category in the database
                    dbCategories.child(categoryKey).set(newCategoryName);
                    Navigator.pop(context); // Close the dialog
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Invalid category name.'),
                      ),
                    );
                  }
                },
                child: Text('Save'),
              ),
            ],
          );
        },
      );
    },
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