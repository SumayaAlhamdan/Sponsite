import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sponsite/screens/admin_screens/admin_home_screen.dart';
import 'package:sponsite/screens/calendar.dart';
import 'package:sponsite/widgets/user_image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class SponseeEditProfile extends StatefulWidget {
  SponseeEditProfile({Key? key}) : super(key: key);
  State<SponseeEditProfile> createState() => _SponseeEditProfileState();
}

class _SponseeEditProfileState extends State<SponseeEditProfile> {
  User? user = FirebaseAuth.instance.currentUser;
  String? sponseeID;
  // late String name;
  List<SponseeEditProfileInfo> sponseeList = [];
  File? _selectedImage;
  bool _obscured = true;
  var theType;
  var _isAuthenticating = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyPass = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyAdd = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  final TextEditingController _fileController =
      TextEditingController(text: 'No file selected');
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _urlTitleController = TextEditingController();
  final TextEditingController _currentpasswordController =
      TextEditingController();
  final TextEditingController _newpasswordController = TextEditingController();
  final DatabaseReference dbref = FirebaseDatabase.instance.reference();
  final _firebase = FirebaseAuth.instance;
  bool weakPass = false;
  bool emailUsed = false;
  bool invalidEmail = false;
  bool wrongpass = false;
  bool addLink = false;
  String? selectedApp;
  List<String> socialMediaApps = [
    'github',
    'twitter',
    'instagram',
    'facebook',
    'linkedin',
    'website',
    'youtube',
    // Add more apps as needed
  ];
  final Map<String, IconData> socialMediaIcons = {
    'github': FontAwesomeIcons.github,
    'twitter': FontAwesomeIcons.twitter,
    'instagram': FontAwesomeIcons.instagram,
    'facebook': FontAwesomeIcons.facebook,
    'linkedin': FontAwesomeIcons.linkedin,
    'website': FontAwesomeIcons.link,
    'youtube': FontAwesomeIcons.youtube,

    // Add more social media titles and corresponding icons as needed
  };
  void _toggleObscured() {
    setState(() {
      _obscured = !_obscured;
    });
  }

  void check() {
    if (user != null) {
      sponseeID = user?.uid;
      print('Sponsee ID: $sponseeID');
    } else {
      print('User is not logged in.');
    }
  }

  void _loadProfileFromFirebase() async {
    check();
    DatabaseReference dbRef =
        FirebaseDatabase.instance.ref().child('Sponsees').child(sponseeID!);
    // user.updatePassword(newPassword)
    // user.reauthenticateWithCredential(credential)

    // Listen to the changes in the database reference
    dbRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          // Clear the existing data in the list
          sponseeList.clear();

          Map<dynamic, dynamic> sponseeData =
              event.snapshot.value as Map<dynamic, dynamic>;

          // Parse social media accounts into a list of title-link pairs
          List<SocialMediaAccount> socialMediaAccounts = [];
          if (sponseeData.containsKey('Social Media')) {
            Map<dynamic, dynamic> socialMediaData =
                sponseeData['Social Media'] as Map<dynamic, dynamic>;
            socialMediaData.forEach((title, link) {
              socialMediaAccounts.add(SocialMediaAccount(
                title: title as String? ?? '',
                link: link as String? ?? '',
              ));
            });
          }
          // print(socialMediaAccounts[0].link);
          // print(socialMediaAccounts[0].title);
          // print(sponseeData);
          // Create a Sponsee object and add it to the list
          SponseeEditProfileInfo sponsee = SponseeEditProfileInfo(
            name: sponseeData['Name'] as String? ?? '',
            bio: sponseeData['Bio'] as String? ?? '',
            pic: sponseeData['Picture'] as String? ?? '',
            social: socialMediaAccounts,
            email: sponseeData['Email'] as String? ?? '',

            // Add other fields as needed
          );
          _nameController.text = sponsee.name;
          _emailController.text = sponsee.email;
          _bioController.text = sponsee.bio;
          print(socialMediaApps);
          for (var account in socialMediaAccounts) {
            socialMediaApps.remove(account.title.toLowerCase());
          }
          print(socialMediaApps);
          // _emailController.text=sponsee.
          sponseeList.add(sponsee);
          // print(sponseeList);
          // print(sponseeList.first.social.first.link);
        });
      }
    });
  }

  void save() async {
    print('here1');
    if (!_formKey.currentState!.validate()) {
      print('here');
      return;
    }
    print('here2');
    _formKey.currentState!.save();

    if (_selectedImage != null) {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('user_images')
          .child(sponseeID!)
          .child('$sponseeID.jpg');

      await storageRef.putFile(_selectedImage!);
      final imageUrl = await storageRef.getDownloadURL();
      DatabaseReference dbRef =
          FirebaseDatabase.instance.ref().child('Sponsees').child(sponseeID!);
      dbRef.update({'Picture': imageUrl});
    }
    DatabaseReference dbRef =
        FirebaseDatabase.instance.ref().child('Sponsees').child(sponseeID!);
    dbRef.update({
      'Name': _nameController.text.trim(),
      'Bio': _bioController.text.trim()
    });
    _loadProfileFromFirebase();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void initState() {
    super.initState();
    check();
    _loadProfileFromFirebase();
  }

  Future<void> _showSignOutConfirmationDialog(BuildContext context,item) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Delete Link Confirmation',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
          ),
          content: const Text(
            'Are you sure you want to delete this social media link?                                   ',
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
                child: const Text("Delete",
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
                  DatabaseReference dbRef = FirebaseDatabase.instance
                            .ref()
                            .child('Sponsees')
                            .child(sponseeID!)
                            .child('Social Media')
                            .child(item.title);
                        await dbRef.remove();
                        //check here

                        //  Navigator.pop(context);
                        //  SponseeEditProfile();
                        // setState(() {
                        //   sponseeList.first.social.remove(item);
                        // });
                        socialMediaApps.add(item.title);
                        _loadProfileFromFirebase();
                        Navigator.pop(context);
                })
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 51, 45, 81),
          title: Text(
            'Edit Profile',
            style: TextStyle(color: Colors.white, fontSize: 25),
          ),
          centerTitle: true,
          leading: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white, fontSize: 15),
              )),
          leadingWidth: 100,
          actions: [
            TextButton(
                onPressed: () => save(),
                child: Text(
                  ' Save ',
                  style: TextStyle(color: Colors.white, fontSize: 15),
                )),
            SizedBox(
              width: 10,
            ),
          ],
        ),
        body: Column(
          // mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
                flex: 2,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 50),
                      decoration: const BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Color.fromARGB(255, 91, 79, 158),
                                Color.fromARGB(255, 51, 45, 81),
                              ]),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(50),
                            bottomRight: Radius.circular(50),
                          )),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(
                        width: 200,
                        height: 200,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Center(
                              child: UserImagePicker(
                                sponseeList.first.pic,
                                onPickImage: (pickedImage) {
                                  _selectedImage = pickedImage;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                )),
            Expanded(
              flex: 5,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Column(children: [
                      Form(
                          key: _formKey,
                          child: Column(
                              mainAxisSize: MainAxisSize.min,
                              // mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  sponseeList.first.email,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
                                ),
                                //if (sponseeList.isNotEmpty)
                                SizedBox(
                                  height: 10,
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      0.6, // Set the desired width
                                  child: TextFormField(
                                    // initialValue: sponseeList.,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    controller: _nameController,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Name',
                                      prefixIcon: Icon(Icons.person, size: 24),
                                    ),
                                    // inputFormatters: [
                                    //   FilteringTextInputFormatter(
                                    //       RegExp(r'^[A-Za-z0-9\s]+$'),
                                    //       allow: true)
                                    // ],
                                    validator: (value) {
                                      if (RegExp(r'[!@#$%^&*(),.?":{}|<>]')
                                              .hasMatch(value!) ||
                                          value.isEmpty) {
                                        return "Please enter a valid name with no special characters";
                                      }
                                      if (value.length > 30) {
                                        return 'Name should not exceed 30 characters';
                                      }
                                      return null;
                                    },
                                  ),
                                ),

                                const SizedBox(height: 25.0),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      0.6, // Set the desired width
                                  child: TextFormField(
                                    // initialValue: sponseeList.,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    controller: _bioController,
                                    // expands: true,
                                    maxLines: null,
                                    minLines: null,
                                    maxLength: 160,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Bio',
                                      prefixIcon:
                                          Icon(Icons.account_box, size: 24),
                                    ),
                                    // inputFormatters: [
                                    //   FilteringTextInputFormatter(
                                    //       RegExp(r'^[A-Za-z0-9\s]+$'),
                                    //       allow: true)
                                    // ],
                                    validator: (value) {
                                      // if (RegExp(r'[!@#$%^&*(),.?":{}|<>]')
                                      //         .hasMatch(value!) ||
                                      //     value.isEmpty) {
                                      //   return "Special characters are not allowed";
                                      // }
                                      // if (value.length > 30) {
                                      //   return 'Name should not exceed 30 characters';
                                      // }
                                      return null;
                                    },
                                  ),
                                ),

                                const SizedBox(height: 25.0),
                                Divider(
                                  indent: 100,
                                  endIndent: 100,
                                ),
                                const SizedBox(height: 25.0),
                                buildProfileCol(context),
                                const SizedBox(height: 25.0),
                                if (sponseeList.first.social.length != 4)
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(
                                          255, 91, 79, 158),
                                      elevation: 5,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    onPressed: () {
                                      _showSocialsDialog();
                                    },
                                    child: const Text(
                                      "Add Social Media Link",
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 25.0),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromARGB(255, 91, 79, 158),
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  onPressed: () {
                                    _showChangePasswordDialog(context);
                                  },
                                  child: const Text(
                                    "    Change Password    ",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ]))
                    ])),
              ),
            )
          ],
        ));
  }

  void _showSocialsDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Social Media Link'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Form(
                key: _formKeyAdd,
                child: Column(children: [
                  SizedBox(
                    height: 60,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: _linkController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'URL',
                        prefixIcon: Icon(Icons.link, size: 24),
                      ),
                      validator: (value) {
                        if (!RegExp(r'^(https?|ftp)://[^\s/$.?#].[^\s]*$')
                                .hasMatch(value!) ||
                            value.isEmpty) {
                          return "Please enter a valid URL";
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 25.0),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.58,
                      child: DropdownButton<String>(
                        hint: Text('Select Platform'),
                        value: selectedApp,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedApp = newValue!;
                            Navigator.pop(context);
                            _showSocialsDialog();
                          });
                        },
                        items: socialMediaApps
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ]))
          ]),
          actions: [
            TextButton(
              onPressed: () {
                 _linkController.clear();
                  selectedApp = null;
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color.fromARGB(255, 51, 45, 81)),
              ),
            ),
            TextButton(
              child: const Text("Add",
                  style: TextStyle(color: Color.fromARGB(255, 51, 45, 81))),
              onPressed: () async {
                // Implement your password change logic here
                if (_formKeyAdd.currentState!.validate()) {
                  await dbref
                      .child("Sponsees")
                      .child(sponseeID!)
                      .child('Social Media')
                      .update({selectedApp!: _linkController.text});
                  //socialMediaApps.remove(selectedApp);
                  _linkController.clear();
                  selectedApp = null;
                  // initState();
                  Navigator.pop(context);
                  _loadProfileFromFirebase();
                }

                // selectedApp = 'Select Platform';
              },
            ),
          ],
        );
      },
    );
  }

  Widget buildProfileCol(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        // height: 100,
        // color: Colors.amber,
        // constraints: BoxConstraints(maxWidth: sponseeList.first.social.length * 250),
        children: [
          Column(
            children: sponseeList.first.social.map((item) {
              return Container(
                margin: EdgeInsets.only(
                    bottom: 10), // Adjust the bottom margin as needed
                child: Row(
                  children: [
                    _singleItem(context, item),
                    SizedBox(width: 50),
                    Container(
                      // color: Colors.amber,
                      width: 100,
                      height: 30,
                      child: Text(
                        item.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                      ),
                    ),
                    SizedBox(width: 150),
                    GestureDetector(
                      child: Icon(Icons.delete),
                      onTap: () async {
                       _showSignOutConfirmationDialog(context,item);
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
          )
        ]);
  }

  Widget _singleItem(BuildContext context, SocialMediaAccount item) =>
      CircleAvatar(
          radius: 30,
          child: Material(
            shape: const CircleBorder(),
            clipBehavior: Clip.hardEdge,
            color: Color.fromARGB(255, 244, 244, 244),
            child: InkWell(
              onTap: () {
                _launchUrl(item.link);
              },
              child: Center(
                child: Icon(
                  socialMediaIcons[item.title],
                  size: 40,
                  color: Color.fromARGB(255, 91, 79, 158),
                ),
              ),
            ),
          ));

  Future<void> _launchUrl(String url) async {
    final Uri _url = Uri.parse(url);

    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  void _changePassword(String currentPassword, String newPassword) async {
    final user = await FirebaseAuth.instance.currentUser;
    final cred = EmailAuthProvider.credential(
        email: sponseeList.first.email, password: currentPassword);

    user!.reauthenticateWithCredential(cred).then((value) {
      user.updatePassword(newPassword).then((_) {
        //Success, do something
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) {
            Future.delayed(const Duration(seconds: 3), () {
              Navigator.of(context).pop(true);
            });
            return Theme(
              data: Theme.of(context)
                  .copyWith(dialogBackgroundColor: Colors.white),
              child: AlertDialog(
                backgroundColor: Colors.white,
                shape: BeveledRectangleBorder(
                    borderRadius: BorderRadius.circular(2)),
                content: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Color.fromARGB(255, 91, 79, 158),
                      size: 48,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Password changed successfully!',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }).catchError((error) {
        //Error, show something
        setState(() {
          weakPass = true;
        });
        return;
      });
    }).catchError((err) {
      setState(() {
        wrongpass = true;
      });
      return;
    });
  }

  Widget _buildChangePasswordForm() {
    return Column(
      mainAxisSize:
          MainAxisSize.min, // Use MainAxisSize.min to make it fit in a dialog
      children: [
        SizedBox(
          height: 60,
        ),
        Form(
            key: _formKeyPass,
            child: Column(children: [
              SizedBox(
                width: MediaQuery.of(context).size.width *
                    0.6, // Set the desired width
                child: TextFormField(
                  controller: _currentpasswordController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Current Password',
                    prefixIcon: const Icon(Icons.lock_rounded, size: 24),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
                      child: GestureDetector(
                        onTap: _toggleObscured,
                        child: Icon(
                          _obscured
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  obscureText: _obscured,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter password';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width *
                    0.6, // Set the desired width
                child: TextFormField(
                  controller: _newpasswordController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'New Password',
                    prefixIcon: const Icon(Icons.lock_rounded, size: 24),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
                      child: GestureDetector(
                        onTap: _toggleObscured,
                        child: Icon(
                          _obscured
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  obscureText: _obscured,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'[\s]')),
                    LengthLimitingTextInputFormatter(15),
                  ],
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your password';
                    }
                    value = value.trim();
                    if (value.length < 6 || value.length > 15) {
                      return 'Password must between 6 and 15 characters';
                    }
                    if (weakPass) {
                      return 'The password provided is too weak';
                    }

                    return null;
                  },
                ),
              ),
            ]))
      ],
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Password'),
          content: _buildChangePasswordForm(), // Call your function here
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Color.fromARGB(255, 51, 45, 81)),
              ),
            ),
            TextButton(
              onPressed: () {
                // Implement your password change logic here
                _changePassword(
                  _currentpasswordController.text.trim(),
                  _newpasswordController.text.trim(),
                );
                Navigator.of(context).pop();
              },
              child: Text('Save',
                  style: TextStyle(color: Color.fromARGB(255, 51, 45, 81))),
            ),
          ],
        );
      },
    );
  }

//not used
  // void _showSocialsDialog(BuildContext context) {
  //   showDialog<void>(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('Add Link'),
  //         content: buildSheet3(context), // Call your function here
  //         actions: <Widget>[
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: Text('Cancel'),
  //           ),
  //           TextButton(
  //             onPressed: () async {
  //               // Implement your password change logic here
  //               await dbref
  //                   .child("Sponsees")
  //                   .child(sponseeID!)
  //                   .child('Social Media')
  //                   .update({selectedApp!: _linkController.text});
  //               //socialMediaApps.remove(selectedApp);
  //               _linkController.clear();
  //               Navigator.pop(context);
  //               // selectedApp = 'Select Platform';
  //             },
  //             child: Text('Save'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // void _showAddLinkDialog(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('Add Link'),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             SizedBox(
  //               height: 60,
  //             ),
  //             SizedBox(
  //               width: MediaQuery.of(context).size.width * 0.6,
  //               child: TextFormField(
  //                 autovalidateMode: AutovalidateMode.onUserInteraction,
  //                 controller: _linkController,
  //                 decoration: InputDecoration(
  //                   border: OutlineInputBorder(),
  //                   labelText: 'URL',
  //                   prefixIcon: Icon(Icons.link, size: 24),
  //                 ),
  //                 validator: (value) {
  //                   if (!RegExp(r'^(https?|ftp)://[^\s/$.?#].[^\s]*$')
  //                           .hasMatch(value!) ||
  //                       value.isEmpty) {
  //                     return "Please enter a valid URL";
  //                   }
  //                   return null;
  //                 },
  //               ),
  //             ),
  //             const SizedBox(height: 25.0),
  //             Container(
  //               padding: const EdgeInsets.all(8.0),
  //               decoration: BoxDecoration(
  //                 border: Border.all(color: Colors.grey),
  //                 borderRadius: BorderRadius.circular(8.0),
  //               ),
  //               child: SizedBox(
  //                 width: MediaQuery.of(context).size.width * 0.58,
  //                 child: DropdownButton<String>(
  //                   value: selectedApp,
  //                   onChanged: (String? newValue) {
  //                     setState(() {
  //                       selectedApp = newValue!;
  //                     });
  //                   },
  //                   items: socialMediaApps
  //                       .map<DropdownMenuItem<String>>((String value) {
  //                     return DropdownMenuItem<String>(
  //                       value: value,
  //                       child: Text(value),
  //                     );
  //                   }).toList(),
  //                 ),
  //               ),
  //             ),
  //             ElevatedButton(
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: const Color.fromARGB(255, 91, 79, 158),
  //                 elevation: 5,
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(30),
  //                 ),
  //               ),
  //               onPressed: () {
  //                 // Handle add link logic here
  //                 // You can access _linkController.text and selectedApp
  //                 // for the URL and social media app selected
  //                 // After handling the logic, you can close the dialog.
  //                 Navigator.of(context).pop();
  //               },
  //               child: const Text(
  //                 "Add Link",
  //                 style: TextStyle(
  //                   fontSize: 18,
  //                   color: Colors.white,
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

// Call _showAddLinkDialog when you want to show the dialog.

  Widget buildSheet2(context) {
    return Column(mainAxisSize: MainAxisSize.max, children: [
      AppBar(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        title: Text('Change password'),
        centerTitle: true,
        leading: TextButton(
            onPressed: () => Navigator.pop(context), child: Text('Cancel')),
        leadingWidth: 100,
        actions: [
          TextButton(
              onPressed: () => _changePassword(
                  _currentpasswordController.text.trim(),
                  _newpasswordController.text.trim()),
              child: Text(' Save ')),
          SizedBox(
            width: 10,
          ),
        ],
      ),
      SizedBox(
        height: 60,
      ),
      SizedBox(
        width: MediaQuery.of(context).size.width * 0.6, // Set the desired width
        child: TextFormField(
          controller: _currentpasswordController,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: 'Current Password',
            prefixIcon: const Icon(Icons.lock_rounded, size: 24),
            suffixIcon: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
              child: GestureDetector(
                onTap: _toggleObscured,
                child: Icon(
                  _obscured
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  size: 24,
                ),
              ),
            ),
          ),
          obscureText: _obscured,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter password';
            }
            return null;
          },
        ),
      ),
      SizedBox(
        height: 20,
      ),
      SizedBox(
        width: MediaQuery.of(context).size.width * 0.6, // Set the desired width
        child: TextFormField(
          controller: _newpasswordController,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: 'New Password',
            prefixIcon: const Icon(Icons.lock_rounded, size: 24),
            suffixIcon: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
              child: GestureDetector(
                onTap: _toggleObscured,
                child: Icon(
                  _obscured
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  size: 24,
                ),
              ),
            ),
          ),
          obscureText: _obscured,
          inputFormatters: [
            FilteringTextInputFormatter.deny(RegExp(r'[\s]')),
            LengthLimitingTextInputFormatter(15),
          ],
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please enter your password';
            }
            value = value.trim();
            if (value.length < 6 || value.length > 15) {
              return 'Password must between 6 and 15 characters';
            }
            if (weakPass) {
              return 'The password provided is too weak';
            }

            return null;
          },
        ),
      ),
    ]);
  }

  Widget buildSheet3(context) {
    return Column(mainAxisSize: MainAxisSize.max, children: [
      // AppBar(
      //   shape: const RoundedRectangleBorder(
      //       borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      //   title: Text('Social Media Accounts'),
      //   centerTitle: true,
      //   leading: TextButton(
      //       onPressed: () {
      //         Navigator.pop(context);
      //         selectedApp = 'Select Platform';
      //       },
      //       child: Text('Cancel')),
      //   leadingWidth: 100,
      //   actions: [
      //     TextButton(onPressed: () => (), child: Text(' Save ')),
      //     SizedBox(
      //       width: 10,
      //     ),
      //   ],
      // ),
      SizedBox(
        height: 60,
      ),

      // Text(
      //   'Add Link                                ',
      //   style: Theme.of(context)
      //       .textTheme
      //       .titleLarge
      //       ?.copyWith(fontWeight: FontWeight.bold, fontSize: 20),
      // ),
      SizedBox(
        width: MediaQuery.of(context).size.width * 0.6, // Set the desired width
        child: TextFormField(
          // initialValue: sponseeList.,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          controller: _linkController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'URL',
            prefixIcon: Icon(Icons.link, size: 24),
          ),
          // inputFormatters: [
          //   FilteringTextInputFormatter(
          //       RegExp(r'^[A-Za-z0-9\s]+$'),
          //       allow: true)
          // ],
          validator: (value) {
            if (!RegExp(r'^(https?|ftp)://[^\s/$.?#].[^\s]*$')
                    .hasMatch(value!) ||
                value.isEmpty) {
              return "Please enter a valid URL";
            }
            // if (value.length > 30) {
            //   return 'Name should not exceed 30 characters';
            // }
            return null;
          },
        ),
      ),
      const SizedBox(height: 25.0),
      // Dropdown for selecting the social media app
      Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8.0)),
        child: SizedBox(
          width:
              MediaQuery.of(context).size.width * 0.58, // Set the desired width
          child: DropdownButton<String>(
            value: selectedApp,
            onChanged: (String? newValue) {
              setState(() {
                // Navigator.pop(context);
                selectedApp = newValue!;

                // showModalBottomSheet(context: context, builder: buildSheet3);
              });
            },
            items:
                socialMediaApps.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
      ),

      // const SizedBox(height: 25.0),
      // ElevatedButton(
      //   style: ElevatedButton.styleFrom(
      //     backgroundColor: const Color.fromARGB(255, 91, 79, 158),
      //     elevation: 5,
      //     shape: RoundedRectangleBorder(
      //       borderRadius: BorderRadius.circular(30),
      //     ),
      //   ),
      //   onPressed: () async {
      //     await dbref
      //         .child("Sponsees")
      //         .child(sponseeID!)
      //         .child('Social Media')
      //         .update({selectedApp!: _linkController.text});
      //     socialMediaApps.remove(selectedApp);
      //     _linkController.clear();
      //     Navigator.pop(context);
      //     selectedApp = 'Select Platform';

      //     showModalBottomSheet(context: context, builder: buildSheet3);
      //   },
      //   child: const Text(
      //     "   Add Link    ",
      //     style: TextStyle(
      //       fontSize: 18,
      //       color: Colors.white,
      //     ),
      //   ),
      // ),
      // Divider(
      //   indent: 100,
      //   endIndent: 100,
      // ),
      // _ProfileInfoCol(sponseeList.first.social, sponseeID)
    ]);
  }

  // Widget buildSheet(context) {
  //   return Column(
  //     mainAxisSize: MainAxisSize.max,
  //     children: [
  //       AppBar(
  //         shape: const RoundedRectangleBorder(
  //             borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
  //         title: Text('Edit profile'),
  //         centerTitle: true,
  //         leading: TextButton(
  //             onPressed: () => Navigator.pop(context), child: Text('Cancel')),
  //         leadingWidth: 100,
  //         actions: [
  //           TextButton(onPressed: () => save(), child: Text(' Save ')),
  //           SizedBox(
  //             width: 10,
  //           ),
  //         ],
  //       ),
  //       SizedBox(
  //         height: 20,
  //       ),
  //       Center(
  //         child: UserImagePicker(
  //           sponseeList.first.pic,
  //           onPickImage: (pickedImage) {
  //             _selectedImage = pickedImage;
  //           },
  //         ),
  //       ),
  //       Form(
  //           key: _formKey,
  //           child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               // mainAxisAlignment: MainAxisAlignment.center,
  //               children: <Widget>[
  //                 SizedBox(
  //                   height: 10,
  //                 ),
  //                 Text(
  //                   sponseeList.first.email,
  //                   style: Theme.of(context)
  //                       .textTheme
  //                       .titleLarge
  //                       ?.copyWith(fontWeight: FontWeight.bold, fontSize: 20),
  //                 ),
  //                 //if (sponseeList.isNotEmpty)
  //                 SizedBox(
  //                   height: 10,
  //                 ),
  //                 SizedBox(
  //                   width: MediaQuery.of(context).size.width *
  //                       0.6, // Set the desired width
  //                   child: TextFormField(
  //                     // initialValue: sponseeList.,
  //                     autovalidateMode: AutovalidateMode.onUserInteraction,
  //                     controller: _nameController,
  //                     decoration: const InputDecoration(
  //                       border: OutlineInputBorder(),
  //                       labelText: 'Name',
  //                       prefixIcon: Icon(Icons.person, size: 24),
  //                     ),
  //                     // inputFormatters: [
  //                     //   FilteringTextInputFormatter(
  //                     //       RegExp(r'^[A-Za-z0-9\s]+$'),
  //                     //       allow: true)
  //                     // ],
  //                     validator: (value) {
  //                       if (RegExp(r'[!@#$%^&*(),.?":{}|<>]')
  //                               .hasMatch(value!) ||
  //                           value.isEmpty) {
  //                         return "Please enter a valid name with no special characters";
  //                       }
  //                       if (value.length > 30) {
  //                         return 'Name should not exceed 30 characters';
  //                       }
  //                       return null;
  //                     },
  //                   ),
  //                 ),
  //                 //const SizedBox(height: 25.0),

  //                 // SizedBox(
  //                 //   width: MediaQuery.of(context).size.width *
  //                 //       0.6, // Set the desired width
  //                 //   child: TextFormField(
  //                 //     autovalidateMode: AutovalidateMode.onUserInteraction,
  //                 //     controller: _emailController,
  //                 //     readOnly: true,
  //                 //     decoration: const InputDecoration(
  //                 //       border: OutlineInputBorder(),
  //                 //       labelText: 'Email Address',
  //                 //       prefixIcon: Icon(Icons.email_rounded, size: 24),
  //                 //     ),
  //                 //     keyboardType: TextInputType.emailAddress,
  //                 //     autocorrect: false,
  //                 //     textCapitalization: TextCapitalization.none,
  //                 //     /* inputFormatters: [
  //                 //                   FilteringTextInputFormatter(
  //                 //                       RegExp(
  //                 //                           r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$'),
  //                 //                       allow: true)
  //                 //                 ],*/
  //                 //     validator: (value) {
  //                 //       if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
  //                 //               .hasMatch(value!) ||
  //                 //           value.isEmpty) {
  //                 //         return 'Please enter a valid email address';
  //                 //       }
  //                 //       if (emailUsed) {
  //                 //         return 'Email already in use';
  //                 //       }
  //                 //       if (invalidEmail) {
  //                 //         return 'Please enter a valid email';
  //                 //       }
  //                 //       return null; // Add this line to handle valid input
  //                 //     },
  //                 //   ),
  //                 // ),
  //                 const SizedBox(height: 25.0),
  //                 SizedBox(
  //                   width: MediaQuery.of(context).size.width *
  //                       0.6, // Set the desired width
  //                   child: TextFormField(
  //                     // initialValue: sponseeList.,
  //                     autovalidateMode: AutovalidateMode.onUserInteraction,
  //                     controller: _bioController,
  //                     // expands: true,
  //                     maxLines: null,
  //                     minLines: null,
  //                     maxLength: 160,
  //                     decoration: const InputDecoration(
  //                       border: OutlineInputBorder(),
  //                       labelText: 'Bio',
  //                       prefixIcon: Icon(Icons.account_box, size: 24),
  //                     ),
  //                     // inputFormatters: [
  //                     //   FilteringTextInputFormatter(
  //                     //       RegExp(r'^[A-Za-z0-9\s]+$'),
  //                     //       allow: true)
  //                     // ],
  //                     validator: (value) {
  //                       // if (RegExp(r'[!@#$%^&*(),.?":{}|<>]')
  //                       //         .hasMatch(value!) ||
  //                       //     value.isEmpty) {
  //                       //   return "Special characters are not allowed";
  //                       // }
  //                       // if (value.length > 30) {
  //                       //   return 'Name should not exceed 30 characters';
  //                       // }
  //                       return null;
  //                     },
  //                   ),
  //                 ),
  //                 // SizedBox(
  //                 //   width: MediaQuery.of(context).size.width *
  //                 //       0.6, // Set the desired width
  //                 //   child: TextFormField(
  //                 //     controller: _passwordController,
  //                 //     readOnly: true,
  //                 //     autovalidateMode: AutovalidateMode.onUserInteraction,
  //                 //     decoration: InputDecoration(
  //                 //       border: const OutlineInputBorder(),
  //                 //       labelText: 'Change Password',
  //                 //       prefixIcon: const Icon(Icons.lock_rounded, size: 24),
  //                 //       suffixIcon: Padding(
  //                 //         padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
  //                 //         child: GestureDetector(
  //                 //           onTap: () {
  //                 //             showModalBottomSheet(
  //                 //                 context: context, builder: buildSheet2);
  //                 //           },
  //                 //           child: const Icon(
  //                 //             Icons.arrow_forward,
  //                 //             // _obscured
  //                 //             //     ? Icons.visibility_off_rounded
  //                 //             //     : Icons.visibility_rounded,
  //                 //             size: 24,
  //                 //           ),
  //                 //         ),
  //                 //       ),
  //                 //     ),
  //                 //     obscureText: _obscured,
  //                 //     inputFormatters: [
  //                 //       FilteringTextInputFormatter.deny(RegExp(r'[\s]')),
  //                 //       LengthLimitingTextInputFormatter(15),
  //                 //     ],
  //                 //     validator: (value) {
  //                 //       if (value!.contains(' ')) {
  //                 //         return 'Please enter a valid password';
  //                 //       }
  //                 //       if (value.isEmpty) {
  //                 //         return 'Please enter your password';
  //                 //       }

  //                 //       if (value.length < 6 || value.length > 15) {
  //                 //         return 'Password must between 6 and 15 characters';
  //                 //       }
  //                 //       if (weakPass) {
  //                 //         return 'The password provided is too weak';
  //                 //       }

  //                 //       return null;
  //                 //     },
  //                 //   ),
  //                 // ),
  //                 //  SizedBox(
  //                 //   width: MediaQuery.of(context).size.width *
  //                 //       0.6, // Set the desired width
  //                 //   child: TextFormField(
  //                 //     // initialValue: sponseeList.,
  //                 //     autovalidateMode: AutovalidateMode.onUserInteraction,
  //                 //     controller: _nameController,
  //                 //     decoration: const InputDecoration(
  //                 //       border: OutlineInputBorder(),
  //                 //       labelText: 'Name',
  //                 //       prefixIcon: Icon(Icons.person, size: 24),
  //                 //     ),
  //                 //     // inputFormatters: [
  //                 //     //   FilteringTextInputFormatter(
  //                 //     //       RegExp(r'^[A-Za-z0-9\s]+$'),
  //                 //     //       allow: true)
  //                 //     // ],
  //                 //     validator: (value) {
  //                 //       if (RegExp(r'[!@#$%^&*(),.?":{}|<>]')
  //                 //               .hasMatch(value!) ||
  //                 //           value.isEmpty) {
  //                 //         return "Please enter a valid name with no special characters";
  //                 //       }
  //                 //       if (value.length > 30) {
  //                 //         return 'Name should not exceed 30 characters';
  //                 //       }
  //                 //       return null;
  //                 //     },
  //                 //   ),
  //                 // ),
  //                 //  SizedBox(
  //                 //   width: MediaQuery.of(context).size.width *
  //                 //       0.6, // Set the desired width
  //                 //   child: TextFormField(
  //                 //     // initialValue: sponseeList.,
  //                 //     autovalidateMode: AutovalidateMode.onUserInteraction,
  //                 //     controller: _nameController,
  //                 //     decoration: const InputDecoration(
  //                 //       border: OutlineInputBorder(),
  //                 //       labelText: 'Name',
  //                 //       prefixIcon: Icon(Icons.person, size: 24),
  //                 //     ),
  //                 //     // inputFormatters: [
  //                 //     //   FilteringTextInputFormatter(
  //                 //     //       RegExp(r'^[A-Za-z0-9\s]+$'),
  //                 //     //       allow: true)
  //                 //     // ],
  //                 //     validator: (value) {
  //                 //       if (RegExp(r'[!@#$%^&*(),.?":{}|<>]')
  //                 //               .hasMatch(value!) ||
  //                 //           value.isEmpty) {
  //                 //         return "Please enter a valid name with no special characters";
  //                 //       }
  //                 //       if (value.length > 30) {
  //                 //         return 'Name should not exceed 30 characters';
  //                 //       }
  //                 //       return null;
  //                 //     },
  //                 //   ),
  //                 // ),
  //                 //  SizedBox(
  //                 //   width: MediaQuery.of(context).size.width *
  //                 //       0.6, // Set the desired width
  //                 //   child: TextFormField(
  //                 //     // initialValue: sponseeList.,
  //                 //     autovalidateMode: AutovalidateMode.onUserInteraction,
  //                 //     controller: _nameController,
  //                 //     decoration: const InputDecoration(
  //                 //       border: OutlineInputBorder(),
  //                 //       labelText: 'Name',
  //                 //       prefixIcon: Icon(Icons.person, size: 24),
  //                 //     ),
  //                 //     // inputFormatters: [
  //                 //     //   FilteringTextInputFormatter(
  //                 //     //       RegExp(r'^[A-Za-z0-9\s]+$'),
  //                 //     //       allow: true)
  //                 //     // ],
  //                 //     validator: (value) {
  //                 //       if (RegExp(r'[!@#$%^&*(),.?":{}|<>]')
  //                 //               .hasMatch(value!) ||
  //                 //           value.isEmpty) {
  //                 //         return "Please enter a valid name with no special characters";
  //                 //       }
  //                 //       if (value.length > 30) {
  //                 //         return 'Name should not exceed 30 characters';
  //                 //       }
  //                 //       return null;
  //                 //     },
  //                 //   ),
  //                 // ),
  //                 const SizedBox(height: 25.0),
  //                 ElevatedButton(
  //                   style: ElevatedButton.styleFrom(
  //                     backgroundColor: const Color.fromARGB(255, 91, 79, 158),
  //                     elevation: 5,
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(30),
  //                     ),
  //                   ),
  //                   onPressed: () {
  //                     showModalBottomSheet(
  //                         context: context, builder: buildSheet2);
  //                   },
  //                   child: const Text(
  //                     "    Change Password    ",
  //                     style: TextStyle(
  //                       fontSize: 18,
  //                       color: Colors.white,
  //                     ),
  //                   ),
  //                 ),

  //                 const SizedBox(height: 25.0),
  //                 ElevatedButton(
  //                   style: ElevatedButton.styleFrom(
  //                     backgroundColor: const Color.fromARGB(255, 91, 79, 158),
  //                     elevation: 5,
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(30),
  //                     ),
  //                   ),
  //                   onPressed: () {
  //                     showModalBottomSheet(
  //                         context: context, builder: buildSheet3);
  //                   },
  //                   child: const Text(
  //                     "Social Media Accounts",
  //                     style: TextStyle(
  //                       fontSize: 18,
  //                       color: Colors.white,
  //                     ),
  //                   ),
  //                 ),
  //               ]))
  //     ],
  //   );
  // }
}

// //class _ProfileInfoCol extends StatefulWidget {
//   _ProfileInfoCol(List<SocialMediaAccount> this.sponseeList.first.social, this.id, {Key? key})
//       : super(key: key);
//   final List<SocialMediaAccount> sponseeList.first.social;
//   final id;
//   State<_ProfileInfoCol> createState() => _ProfileInfoColState(sponseeList.first.social, id);
// }

// //class _ProfileInfoColState extends State<_ProfileInfoCol> {
//   _ProfileInfoColState(this.sponseeList.first.social, this.id) {
//     // id=ID;
//     // sponseeList.first.social=items;
//   }
//   List<SocialMediaAccount> sponseeList.first.social;
//   var id;
//   final Map<String, IconData> socialMediaIcons = {
//     'github': FontAwesomeIcons.github,
//     'twitter': FontAwesomeIcons.twitter,
//     'instagram': FontAwesomeIcons.instagram,
//     'facebook': FontAwesomeIcons.facebook,
//     'linkedin': FontAwesomeIcons.linkedin,
//     'website': FontAwesomeIcons.link,
//     'youtube': FontAwesomeIcons.youtube,

//     // Add more social media titles and corresponding icons as needed
//   };

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         // height: 100,
//         // color: Colors.amber,
//         // constraints: BoxConstraints(maxWidth: sponseeList.first.social.length * 250),
//         children: [
//           Column(
//             children: sponseeList.first.social.map((item) {
//               return Container(
//                 margin: EdgeInsets.only(
//                     bottom: 10), // Adjust the bottom margin as needed
//                 child: Row(
//                   children: [
//                     _singleItem(context, item),
//                     SizedBox(width: 50),
//                     Container(
//                       // color: Colors.amber,
//                       width: 100,
//                       height: 30,
//                       child: Text(
//                         item.title,
//                         style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 20,
//                             ),
//                       ),
//                     ),
//                     SizedBox(width: 150),
//                     GestureDetector(
//                       child: Icon(Icons.delete),
//                       onTap: () async {
//                         DatabaseReference dbRef = FirebaseDatabase.instance
//                             .ref()
//                             .child('Sponsees')
//                             .child(id!)
//                             .child('Social Media')
//                             .child(item.title);
//                         await dbRef.remove();
//                         //check here
//                        Navigator.pop(context);
//                       //  Navigator.pop(context);
//                       //  SponseeEditProfile();
//                         setState(() {
//                           sponseeList.first.social.remove(item);
//                         });

//                       },
//                     ),
//                   ],
//                 ),
//               );
//             }).toList(),
//           )
//         ]);
//   }

//   Widget _singleItem(BuildContext context, SocialMediaAccount item) =>
//       CircleAvatar(
//           radius: 30,
//           child: Material(
//             shape: const CircleBorder(),
//             clipBehavior: Clip.hardEdge,
//             color: Color.fromARGB(255, 244, 244, 244),
//             child: InkWell(
//               onTap: () {
//                 _launchUrl(item.link);
//               },
//               child: Center(
//                 child: Icon(
//                   socialMediaIcons[item.title],
//                   size: 40,
//                   color: Color.fromARGB(255, 91, 79, 158),
//                 ),
//               ),
//             ),
//           ));

//   Future<void> _launchUrl(String url) async {
//     final Uri _url = Uri.parse(url);

//     if (!await launchUrl(_url)) {
//       throw Exception('Could not launch $_url');
//     }
//   }
// }

// //class _ProfileInfoRow extends StatelessWidget {
//   _ProfileInfoRow(List<SocialMediaAccount> this.sponseeList.first.social, {Key? key})
//       : super(key: key);

//   final List<SocialMediaAccount> sponseeList.first.social;

//   final Map<String, IconData> socialMediaIcons = {
//     'github': FontAwesomeIcons.github,
//     'twitter': FontAwesomeIcons.twitter,
//     'instagram': FontAwesomeIcons.instagram,
//     'facebook': FontAwesomeIcons.facebook,
//     'linkedin': FontAwesomeIcons.linkedin,
//     'website': FontAwesomeIcons.link,
//     'youtube': FontAwesomeIcons.youtube,

//     // Add more social media titles and corresponding icons as needed
//   };

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 100,
//       //color: Colors.amber,
//       constraints: BoxConstraints(maxWidth: sponseeList.first.social.length * 80),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: sponseeList.first.social
//             .map((item) => Expanded(
//                     child: Row(
//                   children: [
//                     //if (sponseeList.first.social.indexOf(item) != 0)
//                     Expanded(child: _singleItem(context, item)),
//                   ],
//                 )))
//             .toList(),
//       ),
//     );
//   }

//   Widget _singleItem(BuildContext context, SocialMediaAccount item) =>
//       CircleAvatar(
//           radius: 30,
//           child: Material(
//             shape: const CircleBorder(),
//             clipBehavior: Clip.hardEdge,
//             color: Color.fromARGB(255, 244, 244, 244),
//             child: InkWell(
//               onTap: () {
//                 _launchUrl(item.link);
//               },
//               child: Center(
//                 child: Icon(
//                   socialMediaIcons[item.title],
//                   size: 40,
//                   color: Color.fromARGB(255, 91, 79, 158),
//                 ),
//               ),
//             ),
//           ));

//   Future<void> _launchUrl(String url) async {
//     final Uri _url = Uri.parse(url);

//     if (!await launchUrl(_url)) {
//       throw Exception('Could not launch $_url');
//     }
//   }
// }

class SponseeEditProfileInfo {
  final String name;
  final String bio;
  final String pic;
  final String email;
  List<SocialMediaAccount> social;

  SponseeEditProfileInfo({
    required this.name,
    required this.bio,
    required this.pic,
    required this.email,
    required this.social,
  });
}

class SocialMediaAccount {
  final String title;
  final String link;

  SocialMediaAccount({
    required this.title,
    required this.link,
  });
}
