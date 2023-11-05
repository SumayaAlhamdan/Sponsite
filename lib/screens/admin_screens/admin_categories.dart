import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

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

// Define the AdminCategories class
class AdminCategories extends StatefulWidget {
  @override
  _AdminCategoriesState createState() => _AdminCategoriesState();
}

// Define the state class
class _AdminCategoriesState extends State<AdminCategories> {
  // Define state variables and methods specific to this screen

final DatabaseReference dbCategories =
      FirebaseDatabase.instance.reference().child('Categories');
        Map<String, String> categories = {};
         @override
  initState() {
    super.initState();
    _loadCategoriesFromFirebase();
  }

void _loadCategoriesFromFirebase() {
    dbCategories.onValue.listen((category) {
      if (category.snapshot.value != null) {
        setState(() {
          categories.clear();
          Map<dynamic, dynamic> categoriesData =
              category.snapshot.value as Map<dynamic, dynamic>;

          categoriesData.forEach((key, value) {
            categories[key] = value as String;
          });
        });
      }
    });
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: PreferredSize(
      preferredSize: const Size.fromHeight(95),
      child: Container(
        height: 95,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 51, 45, 81),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
        child: Row(
          children: [
            SizedBox(width: 280), // You can adjust this width as needed
            Center(
              child: Text(
                "Categories",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 30,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(width: 260), // You can adjust this width as needed
          ],
        ),
      ),
    ),
    body: editCategory(), // Call the editCategory widget to display it
  );
}


Widget editCategory() {
  return Container(
    margin: EdgeInsets.fromLTRB(16.0, 32.0, 16.0, 16.0), // Increased top margin
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            
            Container(
              margin: EdgeInsets.only(right: 15.0),
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
        SizedBox(height: 16.0), // Add space between the button and category items
        if (categories.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'No categories available.',
              style: TextStyle(color: Colors.black),
            ),
          )
        else
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: categories.entries.map((entry) {
              return Container(
                width: MediaQuery.of(context).size.width / 2 - 24.0,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 51, 45, 81),
                  borderRadius: BorderRadius.circular(12.0), // Added radius
                ),
                child: ListTile(
                  tileColor: Color.fromARGB(255, 51, 45, 81),
                  title: Text(
                    entry.value,
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: Container(
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 51, 45, 81),
                      borderRadius: BorderRadius.circular(12.0), // Added radius
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          color: Colors.white,
                          onPressed: () {
                            _editCategoryDialog(entry.key, entry.value);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          color: Colors.white,
                          onPressed: () {
                            _showDeleteConfirmationDialog(entry.value, entry.key);
                          },
                        ),
                      ],
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

                        if (existingCategories.any((category) =>
                            category.toLowerCase() == value.toLowerCase())) {
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
                  _showConfirmationDialog(
                      context, 'Create', categoryName, "", "");
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
    TextEditingController categoryController =
        TextEditingController(text: categoryName);

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
                        if (categories.values.any((existingCategory) =>
                            existingCategory.toLowerCase() ==
                            value.toLowerCase())) {
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
                  _showConfirmationDialog(context, 'Update', newCategoryName,
                      categoryName, categoryKey);
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }


void _showConfirmationDialog(BuildContext context, String action,
    String categoryName, String oldCategoryName, String categoryKey) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          'Confirm $action' + 'ing',
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
            padding: EdgeInsets.only(
                right: 50.0), // Adjust the left value as needed
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
                  await _updateCategoryNameInEvents(oldCategoryName, categoryName);
                }
                Navigator.of(context).pop(); // Close the confirmation dialog
                Navigator.of(context).pop(); // Close the text dialog
                showDialog(
                    context: context,
                    builder: (context) {
                      Future.delayed(const Duration(seconds: 3), () {
                Navigator.of(context).pop(true);
              });
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
                    });
                // Future.delayed(Duration(seconds: 2), () {
                //   Navigator.of(context).pop(); // Close the success dialog
                // });
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


Future<void> _updateCategoryNameInEvents(String oldCategoryName, String newCategoryName) async {
  final DatabaseReference database = FirebaseDatabase.instance.ref();

  database.child('sponseeEvents').onValue.listen((event) {
    if (event.snapshot.value != null) {
      Map<dynamic, dynamic> eventData = event.snapshot.value as Map<dynamic, dynamic>;

      eventData.forEach((key, value) {
        if (value['Category'] is List<dynamic>) {
          List<String> categoryList = (value['Category'] as List<dynamic>)
              .map((category) => category.toString())
              .toList();

          if (categoryList.contains(oldCategoryName)) {
            categoryList = categoryList.map((category) {
              if (category == oldCategoryName) {
                return newCategoryName;
              }
              return category;
            }).toList();

            database.child('sponseeEvents').child(key).child('Category').set(categoryList);
          }
        }
      });
    }
  });

  database.child('offers').onValue.listen((offer) {
    if (offer.snapshot.value != null) {
      Map<dynamic, dynamic> offerData = offer.snapshot.value as Map<dynamic, dynamic>;

      offerData.forEach((key, value) {
        if (value['Category'] is List<dynamic>) {
          List<String> categoryList = (value['Category'] as List<dynamic>)
              .map((category) => category.toString())
              .toList();

          if (categoryList.contains(oldCategoryName)) {
            categoryList = categoryList.map((category) {
              if (category == oldCategoryName) {
                return newCategoryName;
              }
              return category;
            }).toList();

            database.child('offers').child(key).child('Category').set(categoryList);
          }
        }
      });
    }
  });
}


void _showDeleteConfirmationDialog(String categoryName, String categoryKey) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          'Confirm Deletion',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        ),
        content: Text('Are you sure you want to delete $categoryName category?'),
        backgroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(
              right: 50.0, // Adjust the left value as needed
            ),
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: const Color.fromARGB(255, 51, 45, 81)),
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              // Perform the delete action from the database
              dbCategories.child(categoryKey).remove().then((_) {
                // Handle successful deletion
                Navigator.of(context).pop(); // Close the confirmation dialog
                showDialog(
                  context: context,
                  builder: (context) {
              Future.delayed(const Duration(seconds: 3), () {
                Navigator.of(context).pop(true);
              });
                    return AlertDialog(
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: const Color.fromARGB(255, 91, 79, 158),
                            size: 48,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Category deleted successfully!',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
                // Future.delayed(Duration(seconds: 2), () {
                //   Navigator.of(context).pop(); // Close the success dialog
                // });
              }).catchError((error) {
                // Handle any errors that occurred during the deletion process.
                print("Error deleting category: $error");
                // Optionally, you can show an error message to the user here.
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 51, 45, 81), // Purple background
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 80, vertical: 18),
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      );
    },
  );
}



}
