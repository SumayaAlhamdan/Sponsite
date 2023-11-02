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
import 'package:sponsite/screens/sponsee_screens/sponsee_edit_profile.dart';
import 'package:sponsite/widgets/user_image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class SponseeProfile extends StatefulWidget {
  SponseeProfile({Key? key}) : super(key: key);
  State<SponseeProfile> createState() => _SponseeProfileState();
}

class _SponseeProfileState extends State<SponseeProfile> {
  User? user = FirebaseAuth.instance.currentUser;
  String? sponseeID;
  // late String name;
  List<SponseeProfileInfo> sponseeList = [];
  File? _selectedImage;
  bool _obscured = true;
  var theType;
  var _isAuthenticating = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
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
  String selectedApp = 'Selecet Platform';
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
          SponseeProfileInfo sponsee = SponseeProfileInfo(
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

          // _emailController.text=sponsee.
          sponseeList.add(sponsee);
          // print(sponseeList);
          // print(sponseeList.first.social.first.link);
        });
      }
    });
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
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 51, 45, 81),
        leading: IconButton(
          icon: Icon(Icons.calendar_month_rounded),
          iconSize: 40,
          color: Colors.white,
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => googleCalendar(),
            ));
          },
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_horiz,
              color: Color.fromARGB(255, 255, 255, 255),
              size: 40,
            ),
            onSelected: (value) {
              // Handle menu item selection here
              switch (value) {
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
        ],
      ),
      body: Column(
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
                      width: 170,
                      height: 170,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (sponseeList.isNotEmpty)
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(sponseeList.first.pic)
                                    // sponseeList.first.pic != ""? NetworkImage(sponseeList.first.pic) :AssetImage("assets/ksuCPCLogo.png")
                                    ),
                              ),
                            ),
                          // Positioned(
                          //   bottom: 0,
                          //   right: 0,
                          //   child: CircleAvatar(
                          //       radius: 25,
                          //       backgroundColor:
                          //           Color.fromARGB(255, 224, 224, 224),
                          //       child: GestureDetector(
                          //         child: const Icon(
                          //           Icons.edit,
                          //           size: 30,
                          //           color: Color.fromARGB(255, 91, 79, 158),
                          //         ),
                          //         onTap: () {
                          //           showModalBottomSheet(
                          //               context: context, builder: buildSheet);
                          //         },
                          //       )),
                          // ),
                        ],
                      ),
                    ),
                  )
                ],
              )),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(0.0),
              child: Column(
                children: [
                  if (sponseeList.isNotEmpty)
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            sponseeList.first.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                    fontWeight: FontWeight.bold, fontSize: 40),
                          ),
                          // SizedBox(width: 10,),
                          // CircleAvatar(
                          //     radius: 25,
                          //     backgroundColor: Color.fromARGB(255, 244, 244, 244),
                          //     child: GestureDetector(
                          //       child: const Icon(
                          //         Icons.edit,
                          //         size: 30,
                          //         color: Color.fromARGB(255, 91, 79, 158),
                          //       ),
                          //       onTap: () {
                          //          Navigator.of(context).push(
                          //                   MaterialPageRoute(
                          //                     builder: (context) =>
                          //                          SponseeEditProfile(),
                          //                   ),
                          //                 );
                          //       },
                          //     )),
                        ],
                      ),
                    ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 91, 79, 158),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => SponseeEditProfile(),
                      ));
                    },
                    child: const Text(
                      "Edit Profile",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // const _ProfileInfoRow(),
                  if (sponseeList.isNotEmpty)
                    SizedBox(
                      width: 600,

                      // Set your desired width here
                      child: Center(
                        child: Card(
                          margin: const EdgeInsets.all(16.0),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              sponseeList.first.bio,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  if (sponseeList.isNotEmpty)
                    _ProfileInfoRow(sponseeList.first.social),
                  const Divider(
                      // indent: 100,
                      // endIndent: 100,
                      ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 20,
                      ),
                      Text(
                        'My Posts',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 30),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
      AppBar(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        title: Text('Social Media Accounts'),
        centerTitle: true,
        leading: TextButton(
            onPressed: () {
              Navigator.pop(context);
              selectedApp = 'Select Platform';
            },
            child: Text('Cancel')),
        leadingWidth: 100,
        actions: [
          TextButton(onPressed: () => (), child: Text(' Save ')),
          SizedBox(
            width: 10,
          ),
        ],
      ),
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
                Navigator.pop(context);
                selectedApp = newValue!;

                showModalBottomSheet(context: context, builder: buildSheet3);
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

      const SizedBox(height: 25.0),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 91, 79, 158),
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: () async {
          await dbref
              .child("Sponsees")
              .child(sponseeID!)
              .child('Social Media')
              .update({selectedApp!: _linkController.text});
          socialMediaApps.remove(selectedApp);
          _linkController.clear();
          Navigator.pop(context);
          selectedApp = 'Select Platform';

          showModalBottomSheet(context: context, builder: buildSheet3);
        },
        child: const Text(
          "   Add Link    ",
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
      Divider(
        indent: 100,
        endIndent: 100,
      ),
      _ProfileInfoCol(sponseeList.first.social, sponseeID)
    ]);
  }

  Widget buildSheet(context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        AppBar(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
          title: Text('Edit profile'),
          centerTitle: true,
          leading: TextButton(
              onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          leadingWidth: 100,
          actions: [
            TextButton(onPressed: () => save(), child: Text(' Save ')),
            SizedBox(
              width: 10,
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        Center(
          child: UserImagePicker(
            sponseeList.first.pic,
            onPickImage: (pickedImage) {
              _selectedImage = pickedImage;
            },
          ),
        ),
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
                        ?.copyWith(fontWeight: FontWeight.bold, fontSize: 20),
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
                      autovalidateMode: AutovalidateMode.onUserInteraction,
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
                  //const SizedBox(height: 25.0),

                  // SizedBox(
                  //   width: MediaQuery.of(context).size.width *
                  //       0.6, // Set the desired width
                  //   child: TextFormField(
                  //     autovalidateMode: AutovalidateMode.onUserInteraction,
                  //     controller: _emailController,
                  //     readOnly: true,
                  //     decoration: const InputDecoration(
                  //       border: OutlineInputBorder(),
                  //       labelText: 'Email Address',
                  //       prefixIcon: Icon(Icons.email_rounded, size: 24),
                  //     ),
                  //     keyboardType: TextInputType.emailAddress,
                  //     autocorrect: false,
                  //     textCapitalization: TextCapitalization.none,
                  //     /* inputFormatters: [
                  //                   FilteringTextInputFormatter(
                  //                       RegExp(
                  //                           r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$'),
                  //                       allow: true)
                  //                 ],*/
                  //     validator: (value) {
                  //       if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
                  //               .hasMatch(value!) ||
                  //           value.isEmpty) {
                  //         return 'Please enter a valid email address';
                  //       }
                  //       if (emailUsed) {
                  //         return 'Email already in use';
                  //       }
                  //       if (invalidEmail) {
                  //         return 'Please enter a valid email';
                  //       }
                  //       return null; // Add this line to handle valid input
                  //     },
                  //   ),
                  // ),
                  const SizedBox(height: 25.0),
                  SizedBox(
                    width: MediaQuery.of(context).size.width *
                        0.6, // Set the desired width
                    child: TextFormField(
                      // initialValue: sponseeList.,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: _bioController,
                      // expands: true,
                      maxLines: null,
                      minLines: null,
                      maxLength: 160,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Bio',
                        prefixIcon: Icon(Icons.account_box, size: 24),
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
                  // SizedBox(
                  //   width: MediaQuery.of(context).size.width *
                  //       0.6, // Set the desired width
                  //   child: TextFormField(
                  //     controller: _passwordController,
                  //     readOnly: true,
                  //     autovalidateMode: AutovalidateMode.onUserInteraction,
                  //     decoration: InputDecoration(
                  //       border: const OutlineInputBorder(),
                  //       labelText: 'Change Password',
                  //       prefixIcon: const Icon(Icons.lock_rounded, size: 24),
                  //       suffixIcon: Padding(
                  //         padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
                  //         child: GestureDetector(
                  //           onTap: () {
                  //             showModalBottomSheet(
                  //                 context: context, builder: buildSheet2);
                  //           },
                  //           child: const Icon(
                  //             Icons.arrow_forward,
                  //             // _obscured
                  //             //     ? Icons.visibility_off_rounded
                  //             //     : Icons.visibility_rounded,
                  //             size: 24,
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //     obscureText: _obscured,
                  //     inputFormatters: [
                  //       FilteringTextInputFormatter.deny(RegExp(r'[\s]')),
                  //       LengthLimitingTextInputFormatter(15),
                  //     ],
                  //     validator: (value) {
                  //       if (value!.contains(' ')) {
                  //         return 'Please enter a valid password';
                  //       }
                  //       if (value.isEmpty) {
                  //         return 'Please enter your password';
                  //       }

                  //       if (value.length < 6 || value.length > 15) {
                  //         return 'Password must between 6 and 15 characters';
                  //       }
                  //       if (weakPass) {
                  //         return 'The password provided is too weak';
                  //       }

                  //       return null;
                  //     },
                  //   ),
                  // ),
                  //  SizedBox(
                  //   width: MediaQuery.of(context).size.width *
                  //       0.6, // Set the desired width
                  //   child: TextFormField(
                  //     // initialValue: sponseeList.,
                  //     autovalidateMode: AutovalidateMode.onUserInteraction,
                  //     controller: _nameController,
                  //     decoration: const InputDecoration(
                  //       border: OutlineInputBorder(),
                  //       labelText: 'Name',
                  //       prefixIcon: Icon(Icons.person, size: 24),
                  //     ),
                  //     // inputFormatters: [
                  //     //   FilteringTextInputFormatter(
                  //     //       RegExp(r'^[A-Za-z0-9\s]+$'),
                  //     //       allow: true)
                  //     // ],
                  //     validator: (value) {
                  //       if (RegExp(r'[!@#$%^&*(),.?":{}|<>]')
                  //               .hasMatch(value!) ||
                  //           value.isEmpty) {
                  //         return "Please enter a valid name with no special characters";
                  //       }
                  //       if (value.length > 30) {
                  //         return 'Name should not exceed 30 characters';
                  //       }
                  //       return null;
                  //     },
                  //   ),
                  // ),
                  //  SizedBox(
                  //   width: MediaQuery.of(context).size.width *
                  //       0.6, // Set the desired width
                  //   child: TextFormField(
                  //     // initialValue: sponseeList.,
                  //     autovalidateMode: AutovalidateMode.onUserInteraction,
                  //     controller: _nameController,
                  //     decoration: const InputDecoration(
                  //       border: OutlineInputBorder(),
                  //       labelText: 'Name',
                  //       prefixIcon: Icon(Icons.person, size: 24),
                  //     ),
                  //     // inputFormatters: [
                  //     //   FilteringTextInputFormatter(
                  //     //       RegExp(r'^[A-Za-z0-9\s]+$'),
                  //     //       allow: true)
                  //     // ],
                  //     validator: (value) {
                  //       if (RegExp(r'[!@#$%^&*(),.?":{}|<>]')
                  //               .hasMatch(value!) ||
                  //           value.isEmpty) {
                  //         return "Please enter a valid name with no special characters";
                  //       }
                  //       if (value.length > 30) {
                  //         return 'Name should not exceed 30 characters';
                  //       }
                  //       return null;
                  //     },
                  //   ),
                  // ),
                  //  SizedBox(
                  //   width: MediaQuery.of(context).size.width *
                  //       0.6, // Set the desired width
                  //   child: TextFormField(
                  //     // initialValue: sponseeList.,
                  //     autovalidateMode: AutovalidateMode.onUserInteraction,
                  //     controller: _nameController,
                  //     decoration: const InputDecoration(
                  //       border: OutlineInputBorder(),
                  //       labelText: 'Name',
                  //       prefixIcon: Icon(Icons.person, size: 24),
                  //     ),
                  //     // inputFormatters: [
                  //     //   FilteringTextInputFormatter(
                  //     //       RegExp(r'^[A-Za-z0-9\s]+$'),
                  //     //       allow: true)
                  //     // ],
                  //     validator: (value) {
                  //       if (RegExp(r'[!@#$%^&*(),.?":{}|<>]')
                  //               .hasMatch(value!) ||
                  //           value.isEmpty) {
                  //         return "Please enter a valid name with no special characters";
                  //       }
                  //       if (value.length > 30) {
                  //         return 'Name should not exceed 30 characters';
                  //       }
                  //       return null;
                  //     },
                  //   ),
                  // ),
                  const SizedBox(height: 25.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 91, 79, 158),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                          context: context, builder: buildSheet2);
                    },
                    child: const Text(
                      "    Change Password    ",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 91, 79, 158),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                          context: context, builder: buildSheet3);
                    },
                    child: const Text(
                      "Social Media Accounts",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ]))
      ],
    );
  }

  void save() async {
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
    _loadProfileFromFirebase();
    Navigator.pop(context);
  }
}

class _ProfileInfoCol extends StatefulWidget {
  _ProfileInfoCol(List<SocialMediaAccount> this._items, this.id, {Key? key})
      : super(key: key);
  final List<SocialMediaAccount> _items;
  final id;
  State<_ProfileInfoCol> createState() => _ProfileInfoColState(_items, id);
}

class _ProfileInfoColState extends State<_ProfileInfoCol> {
  _ProfileInfoColState(this._items, this.id) {
    // id=ID;
    // _items=items;
  }
  List<SocialMediaAccount> _items;
  var id;
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

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        // height: 100,
        // color: Colors.amber,
        // constraints: BoxConstraints(maxWidth: _items.length * 250),
        children: [
          Column(
            // mainAxisAlignment: MainAxisAlignment.end,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: _items
                .map((item) => Row(
                      children: [
                        //if (_items.indexOf(item) != 0)
                        _singleItem(context, item),

                        SizedBox(
                          width: 50,
                        ),
                        Text(
                          item.title,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        SizedBox(
                          width: 150,
                        ),
                        GestureDetector(
                          child: Icon(Icons.delete),
                          onTap: () async {
                            DatabaseReference dbRef = FirebaseDatabase.instance
                                .ref()
                                .child('Sponsees')
                                .child(id!)
                                .child('Social Media')
                                .child(item.title);
                            await dbRef.remove();
                            setState(() {
                              _items.remove(item);
                            });
                          },
                        )
                        // SizedBox(width: 50,)
                      ],
                    ))
                .toList(),
          ),
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
}

class _ProfileInfoRow extends StatelessWidget {
  _ProfileInfoRow(List<SocialMediaAccount> this._items, {Key? key})
      : super(key: key);

  final List<SocialMediaAccount> _items;

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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      //color: Colors.amber,
      constraints: BoxConstraints(maxWidth: _items.length * 80),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _items
            .map((item) => Expanded(
                    child: Row(
                  children: [
                    //if (_items.indexOf(item) != 0)
                    Expanded(child: _singleItem(context, item)),
                  ],
                )))
            .toList(),
      ),
    );
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
}

class SponseeProfileInfo {
  final String name;
  final String bio;
  final String pic;
  final String email;
  List<SocialMediaAccount> social;

  SponseeProfileInfo({
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
