import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sponsite/widgets/user_image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class sponsorEditProfile extends StatefulWidget {
  sponsorEditProfile({Key? key}) : super(key: key);
  State<sponsorEditProfile> createState() => _sponsorEditProfileState();
}

class _sponsorEditProfileState extends State<sponsorEditProfile> {
  User? user = FirebaseAuth.instance.currentUser;
  String? sponsorID;
  // late String name;
  List<sponsorEditProfileInfo> sponsorList = [];
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
  final TextEditingController _currentpasswordController2 =
      TextEditingController();
  final TextEditingController _newpasswordController = TextEditingController();
  final DatabaseReference dbref = FirebaseDatabase.instance.reference();
  final _firebase = FirebaseAuth.instance;
  bool weakPass = false;
  bool emailUsed = false;
  bool invalidEmail = false;
  bool wrongpass = false;
  bool addLink = false;
  bool notMatch = false;
  bool isChangeing = false;
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
      Navigator.pop(context);
      _showChangePasswordDialog(context);
    });
  }

  void check() {
    if (user != null) {
      sponsorID = user?.uid;
      print('sponsor ID: $sponsorID');
    } else {
      print('User is not logged in.');
    }
  }
  void _loadProfileFromFirebase() async {
    check();
    DatabaseReference dbRef =
        FirebaseDatabase.instance.ref().child('Sponsors').child(sponsorID!);
    // user.updatePassword(newPassword)
    // user.reauthenticateWithCredential(credential)

    // Listen to the changes in the database reference
    dbRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          // Clear the existing data in the list
          sponsorList.clear();

          Map<dynamic, dynamic> sponsorData =
              event.snapshot.value as Map<dynamic, dynamic>;

          // Parse social media accounts into a list of title-link pairs
          List<SocialMediaAccount> socialMediaAccounts = [];
          if (sponsorData.containsKey('Social Media')) {
            Map<dynamic, dynamic> socialMediaData =
                sponsorData['Social Media'] as Map<dynamic, dynamic>;
            socialMediaData.forEach((title, link) {
              socialMediaAccounts.add(SocialMediaAccount(
                title: title as String? ?? '',
                link: link as String? ?? '',
              ));
            });
          }
          // print(socialMediaAccounts[0].link);
          // print(socialMediaAccounts[0].title);
          // print(sponsorData);
          // Create a sponsor object and add it to the list
          sponsorEditProfileInfo sponsor = sponsorEditProfileInfo(
            name: sponsorData['Name'] as String? ?? '',
            bio: sponsorData['Bio'] as String? ?? '',
            pic: sponsorData['Picture'] as String? ?? '',
            social: socialMediaAccounts,
            email: sponsorData['Email'] as String? ?? '',

            // Add other fields as needed
          );
          _nameController.text = sponsor.name;
          _emailController.text = sponsor.email;
          _bioController.text = sponsor.bio;
          print(socialMediaApps);
          for (var account in socialMediaAccounts) {
            socialMediaApps.remove(account.title.toLowerCase());
          }
          socialMediaAccounts.sort((a, b) => a.title.compareTo(b.title));
          print(socialMediaApps);
          // _emailController.text=sponsor.
          sponsorList.add(sponsor);
          // print(sponsorList);
          // print(sponsorList.first.social.first.link);
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
          .child(sponsorID!)
          .child('$sponsorID.jpg');

      await storageRef.putFile(_selectedImage!);
      final imageUrl = await storageRef.getDownloadURL();
      DatabaseReference dbRef =
          FirebaseDatabase.instance.ref().child('Sponsors').child(sponsorID!);
      dbRef.update({'Picture': imageUrl});
    }
    DatabaseReference dbRef =
        FirebaseDatabase.instance.ref().child('Sponsors').child(sponsorID!);
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

  Future<void> _showSignOutConfirmationDialog(
      BuildContext context, item) async {
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
                      .child('Sponsors')
                      .child(sponsorID!)
                      .child('Social Media')
                      .child(item.title);
                  await dbRef.remove();
                  //check here

                  //  Navigator.pop(context);
                  //  sponsorEditProfile();
                  // setState(() {
                  //   sponsorList.first.social.remove(item);
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
   return Theme(
      // Apply your theme settings within the Theme widget
      data: ThemeData(useMaterial3: true,
  primaryColor: Color.fromARGB(255, 91, 79, 158),
  fontFamily: 'Urbanist',
//   inputDecorationTheme: InputDecorationTheme(
//     focusedBorder: OutlineInputBorder(
//       borderSide: BorderSide(color: Color.fromARGB(255, 91, 79, 158),
// ), // Set border color when focused
//     ),
//     labelStyle: TextStyle(
//       color: Colors.black, // Set default label color
//     ),
//     prefixIconColor: Colors.black, // Set default icon color
//     ),

//     iconTheme:  IconThemeData(color: Color.fromARGB(255, 91, 79, 158 )

//     ),
  
//   scaffoldBackgroundColor: Colors.white,
  // other theme properties...
),
   
    child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 51, 45, 81),
          title: Text(
            'Edit Profile',
            style: TextStyle(color: Colors.white, fontSize: 25),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          // leading: TextButton(
          //     onPressed: () => Navigator.pop(context),
          //     child: const Text(
          //       'Cancel',
          //       style: TextStyle(color: Colors.white, fontSize: 20),
          //     )),
          // leadingWidth: 110,
          // actions: [
          //   TextButton(
          //       onPressed: () => save(),
          //       child: Text(
          //         ' Save ',
          //         style: TextStyle(color: Colors.white, fontSize: 20),
          //       )),
          //   SizedBox(
          //     width: 10,
          //   ),
          // ],
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
                     if (sponsorList.isNotEmpty)
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
                                sponsorList.first.pic,
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
                if (sponsorList.isNotEmpty) 
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
                              if (sponsorList.isNotEmpty)
                                Text(
                                  sponsorList.first.email,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
                                ),
                                //if (sponsorList.isNotEmpty)
                                SizedBox(
                                  height: 10,
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      0.6, // Set the desired width
                                  child: TextFormField(
                                    // initialValue: sponsorList.,
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
                                          value.isEmpty  || value.trim().isEmpty) {
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
                                    // initialValue: sponsorList.,
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

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    
                                                  
                                                  ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      const Color.fromARGB(
                                                          255, 91, 79, 158),
                                                  elevation: 5,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  save();
                                                },
                                                child: const Text(
                                                    "               Save               ",
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                  ],
                                ),


                                // const SizedBox(height: 25.0),
                                Divider(
                                  indent: 100,
                                  endIndent: 100,
                                ),
                                const SizedBox(height: 25.0),
                                Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.6, // Set the desired width
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color:
                                              Color.fromARGB(255, 75, 71, 81)),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(
                                              'Social Media Accounts', // Title text
                                              style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 75, 71, 81),
                                                // Customize the color
                                                fontSize:
                                                    16, // Customize the font size
                                              ),
                                            ),
                                          ),
                                          buildProfileCol(context),
                                           if (sponsorList.isNotEmpty)
                                          if (sponsorList.first.social.length !=
                                              4)
                                            Center(
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      const Color.fromARGB(
                                                          255, 91, 79, 158),
                                                  elevation: 5,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  _showSocialsDialog();
                                                },
                                                child: const Text(
                                                  "            Add Link            ",
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                             if (sponsorList.isNotEmpty)
                                          if (sponsorList.first.social.length ==
                                              4)
                                            Center(
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Color.fromARGB(
                                                          255, 75, 71, 81),
                                                  elevation: 5,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                  ),
                                                ),
                                                onPressed: null,
                                                child: const Text(
                                                  "            Add Link            ",
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ])),
                                const SizedBox(height: 25.0),

                                const SizedBox(height: 25.0),
                                Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.6, // Set the desired width
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color:
                                              Color.fromARGB(255, 75, 71, 81)),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(
                                              'Password', // Title text
                                              style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 75, 71, 81),
                                                // Customize the color
                                                fontSize:
                                                    16, // Customize the font size
                                              ),
                                            ),
                                          ),
                                          Center(
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    const Color.fromARGB(
                                                        255, 91, 79, 158),
                                                elevation: 5,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                ),
                                              ),
                                              onPressed: () {
                                                _showChangePasswordDialog(
                                                    context);
                                              },
                                              child: const Text(
                                                "    Change Password    ",
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ])),
                              ]))
                    ])),
              ),
            )
          ],
        ))
     );
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
                      .child("Sponsors")
                      .child(sponsorID!)
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
        // constraints: BoxConstraints(maxWidth: sponsorList.first.social.length * 250),
        children: [
          Column(
            children: sponsorList.first.social.map((item) {
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
                        _showSignOutConfirmationDialog(context, item);
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
        email: sponsorList.first.email, password: currentPassword);

    user!.reauthenticateWithCredential(cred).then((value) {
      setState(() {
        isChangeing = true;
      });
      user.updatePassword(newPassword).then((_) {
        //Success, do something
        Navigator.pop(context);
        _currentpasswordController.clear();
        _newpasswordController.clear();
        _currentpasswordController2.clear();
        weakPass = false;
        wrongpass = false;
        showDialog(
          context: context,
          builder: (context) {
            Future.delayed(const Duration(seconds: 3), () {
              Navigator.of(context).pop(true);
              setState(() {
                isChangeing = false;
              });
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
           isChangeing = false;
          weakPass = true;
          Navigator.of(context).pop();
          _showChangePasswordDialog(context);

        });
        return;
      });
    }).catchError((err) {
      setState(() {
         isChangeing = false;
        wrongpass = true;
        Navigator.of(context).pop();
        _showChangePasswordDialog(context);
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
                    // suffixIcon: Padding(
                    //   padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
                    //   child: GestureDetector(
                    //     onTap: _toggleObscured,
                    //     child: Icon(
                    //       _obscured
                    //           ? Icons.visibility_off_rounded
                    //           : Icons.visibility_rounded,
                    //       size: 24,
                    //     ),
                    //   ),
                    // ),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter password';
                    }
                    if (value.length < 6 || value.length > 15 || wrongpass) {
                      return 'Please enter your correct password';
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
                    // suffixIcon: Padding(
                    //   padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
                    //   child: GestureDetector(
                    //     onTap: _toggleObscured,
                    //     child: Icon(
                    //       _obscured
                    //           ? Icons.visibility_off_rounded
                    //           : Icons.visibility_rounded,
                    //       size: 24,
                    //     ),
                    //   ),
                    // ),
                  ),
                  obscureText: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'[\s]')),
                    LengthLimitingTextInputFormatter(15),
                  ],
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your new password';
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
              SizedBox(
                height: 20,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width *
                    0.6, // Set the desired width
                child: TextFormField(
                  controller: _currentpasswordController2,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Confirm New Password',
                    prefixIcon: const Icon(Icons.lock_rounded, size: 24),
                    // suffixIcon: Padding(
                    //   padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
                    //   child: GestureDetector(
                    //     onTap: _toggleObscured,
                    //     child: Icon(
                    //       _obscured
                    //           ? Icons.visibility_off_rounded
                    //           : Icons.visibility_rounded,
                    //       size: 24,
                    //     ),
                    //   ),
                    // ),
                  ),
                  obscureText: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'[\s]')),
                    LengthLimitingTextInputFormatter(15),
                  ],
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your new password';
                    }
                    value = value.trim();
                    if (value.length < 6 || value.length > 15) {
                      return 'Password must between 6 and 15 characters';
                    }
                    if (value != _newpasswordController.text) {
                      return 'Passwords do not match';
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
            if(!isChangeing)
            TextButton(
              onPressed: () {
                _currentpasswordController.clear();
                _newpasswordController.clear();
                _currentpasswordController2.clear();
                weakPass = false;
                wrongpass = false;
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Color.fromARGB(255, 51, 45, 81)),
              ),
            ),
             if(!isChangeing)
            TextButton(
              onPressed: () {
                weakPass = false;
                wrongpass = false;
                // Implement your password change logic here
                if (!_formKeyPass.currentState!.validate()) {
                  print('here');
                  return;
                }

                _changePassword(
                  _currentpasswordController.text.trim(),
                  _newpasswordController.text.trim(),
                );

                // Navigator.of(context).pop();
              },
              child: Text('Save',
                  style: TextStyle(color: Color.fromARGB(255, 51, 45, 81))),
            ),
          ],
        );
      },
    );
  }
}

class sponsorEditProfileInfo {
  final String name;
  final String bio;
  final String pic;
  final String email;
  List<SocialMediaAccount> social;

  sponsorEditProfileInfo({
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
