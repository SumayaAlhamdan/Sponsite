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
            'Are you sure you want to sign out?                                   ',
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
            // TextButton(
            //   onPressed: () async {
            //     // Sign out the user
            //     await FirebaseAuth.instance.signOut();
            //     Navigator.of(context).pop();
            //     // Close the dialog
            //   },
            //   child: const Text('Sign Out',
            //       style: TextStyle(
            //           color: Color.fromARGB(255, 51, 45, 81), fontSize: 20)),
            // ),
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
        
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin Panel') ,actions: [
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_horiz,
              color:  Color.fromARGB(255, 51, 45, 81),
              size: 40,
            ),
            onSelected: (value) {
              // Handle menu item selection here
              switch (value) {
                case 'myAccount':
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => AdminPanel(),
                  ));
                  break;
                case 'signOut':
                  _showSignOutConfirmationDialog(context);
                  break;
                // case 'deleteAccount':
                //   // Handle Delete Account selection
                //   // You can add your logic here
                //   break;
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                // const PopupMenuItem<String>(
                //   value: 'myAccount',
                //   child: ListTile(
                //     leading: Icon(
                //       Icons.perm_identity,
                //       size: 30,
                //     ),
                //     title: Text(
                //       'My Account',
                //       style: TextStyle(fontSize: 20),
                //     ),
                //   ),
                // ),
                const PopupMenuItem<String>(
                  value: 'signOut',
                  child: ListTile(
                    leading: Icon(
                      Icons.exit_to_app,
                      size: 30,
                    ),
                    title: Text(
                      'Sign out',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                // PopupMenuItem<String>(
                //   value: 'deleteAccount',
                //   child: ListTile(
                //     leading: Icon(
                //       Icons.delete,
                //       size: 30,
                //     ),
                //     title: Text(
                //       'Delete account',
                //       style: TextStyle(fontSize: 20),
                //     ),
                //   ),
                // ),
              ];
            },
          ),
        ],),
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
  return Card(
    color: Colors.white,
    margin: EdgeInsets.all(16.0),
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.0),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 16.0),
              child: Text(
                'Categories',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0.0, 15.0, 15.0, 15.0),
              width: 180,
              height: 40,
              child: ElevatedButton(
                onPressed: _showTextInputDialog,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                    const Color.fromARGB(255, 51, 45, 81),
                  ),
                ),
                child: Text(
                  'Add New Category',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        if (categories.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('No categories available.', style: TextStyle(color: Colors.black),
            ),
          )
        else
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: categories.entries.map((entry) {
              return Container(
                width: MediaQuery.of(context).size.width / 2 - 24.0,
                child: Card(
                  color: Color.fromARGB(255, 51, 45, 81),
                  child: ListTile(
                    title: Text(entry.value, style: TextStyle(color: Colors.white),
                    ),
                    trailing: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: IconButton(
                        icon: Icon(Icons.edit),
                        color: Colors.white,
                        onPressed: () {
                          _editCategoryDialog(entry.key, entry.value);
                        },
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    ),
  );
}



GlobalKey<FormState> _formKey = GlobalKey<FormState>();
TextEditingController categoryController = TextEditingController();
void _showTextInputDialog() async {
  categoryController.clear();

  List<String> existingCategories = categories.values.toList();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
              backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        title: Text('Add New Category'),
        content: Container(
           // Set the background color of the entire AlertDialog to white
          child: Container(
            width: 400, // Set your desired width here
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: categoryController,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: InputDecoration(
                      labelText: 'Category Name',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Category name cannot be empty';
                      }
                      if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value)) {
                        return 'Category name can only contain letters and spaces.';
                      }
                      if (value.length > 15) {
                        return "Category name is too long, Please use a name with a maximum\n of 15 characters.";
                      }
                      if (value.length < 3) {
                        return "Category name is too short. Please use a name with a minimum\n of 3 characters.";
                      }

                      if (existingCategories.any((category) => category.toLowerCase() == value.toLowerCase())) {
                        return 'Category already exists. Please enter a unique name.';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
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
              if (_formKey.currentState!.validate()) {
                String categoryName = categoryController.text.trim();
                _showConfirmationDialog(context, 'Create', categoryName, "", "");
              }
            },
            child: Text('Add'),
          ),
        ],
      );
    },
  );
}

void _editCategoryDialog(String categoryKey, String categoryName) async {
  TextEditingController categoryController = TextEditingController(text: categoryName);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        title: Text('Edit Category'),
        content: Container(
          child: Container(
            width: 400, // Set your desired width here
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: categoryController,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: InputDecoration(
                      labelText: 'Category Name',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Category name cannot be empty';
                      }
                      if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value)) {
                        return 'Category name can only contain letters and spaces.';
                      }
                      if (value.length < 3) {
                        return "Category name is too short. Please use a name with a minimum\n of 3 characters.";
                      }
                      if (value.length > 15) {
                        return 'Category name is too long, Please use a name with a maximum\n of 15 characters.';
                      }
                      if (value.toLowerCase() == categoryName.toLowerCase()) {
                        return 'No changes made to the category name.';
                      }
                      if (categories.values.any((existingCategory) => existingCategory.toLowerCase() == value.toLowerCase())) {
                        return 'Category already exists. Please enter a unique name.';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
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
              if (_formKey.currentState!.validate()) {
                String newCategoryName = categoryController.text.trim();
                _showConfirmationDialog(context, 'Update', newCategoryName, categoryName, categoryKey);
              }
            },
            child: Text('Save'),
          ),
        ],
      );
    },
  );
}


void _showConfirmationDialog(BuildContext context, String action, String categoryName, String oldCategoryName, String categoryKey) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Confirm $action' +'ing',
       style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        ),
        content: Text(action == "Create"
            ? 'Are you sure you want to create $categoryName?'
            : 'Are you sure you want to change the $oldCategoryName category to $categoryName?'),
        backgroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
        actions: [
       Padding(
  padding: EdgeInsets.only(right: 50.0), // Adjust the left value as needed
  child: TextButton(
    onPressed: () {
      Navigator.of(context).pop();
    },
    child: Text(
      'Cancel',
      style: TextStyle(color: Color.fromARGB(255, 51, 45, 81)),
    ),
  ),
), 

          TextButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                if (action == 'Create') {
                  dbCategories.push().set(categoryName);
                } else if (action == 'Update') {
                  dbCategories.child(categoryKey).set(categoryName);
                }

                Navigator.pop(context);

                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
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
                            action == "Create"
                                ? 'Category created successfully!'
                                : 'Category name changed successfully!',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                );

                Future.delayed(Duration(seconds: 5), () {
                  Navigator.pop(context);
                });
              }
            },
            child: Text('Confirm',
            style: TextStyle(color: Color.fromARGB(255, 242, 241, 241))),
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
                      borderRadius: BorderRadius.circular(10), // Border radius
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