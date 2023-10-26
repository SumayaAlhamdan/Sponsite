import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class AdminPanel extends StatefulWidget {
  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final DatabaseReference _usersRef = FirebaseDatabase.instance.reference().child('newUsers');
  final DatabaseReference dbCategories = FirebaseDatabase.instance.reference().child('Categories');
  Map<String, String> categories = {};
  

  @override
  void initState() {
    super.initState();
    _loadCategoriesFromFirebase();
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
                  String? email = value['Email'];
                  String? status = value['Status'];
                  if (email != null) {
                    userWidgets.add(
                      ListTile(
                        title: Text(email),
                        subtitle: Text(status ?? 'No status available'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                acceptUser(key, value['Type']);
                              },
                              child: Text('Accept'),
                            ),
                            SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () {
                                rejectedUser(key, value['Type']);
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

  void acceptUser(String? userId, String? userType) {
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
          });
        }
      }).catchError((error) {
        print("Error fetching user data: $error");
        // Handle the error appropriately
      });
    });
  }

  void rejectedUser(String userId, String userType) {
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