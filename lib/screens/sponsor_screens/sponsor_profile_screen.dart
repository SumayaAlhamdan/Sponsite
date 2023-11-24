import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:googleapis/serviceusage/v1.dart';
import 'package:sponsite/screens/sponsor_screens/sponsor_edit_profile.dart';
import 'package:sponsite/widgets/user_image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sponsite/screens/calendar.dart';

class SponsorProfile extends StatefulWidget {
  SponsorProfile({Key? key}) : super(key: key);
  State<SponsorProfile> createState() => _SponsorProfileState();
}

class _SponsorProfileState extends State<SponsorProfile> {
  User? user = FirebaseAuth.instance.currentUser;
  String? sponsorID;
  // late String name;
  List<SponsorProfileInfo> sponsorList = [];
  File? _selectedImage;
  final GlobalKey<FormState> _formKeyPass = GlobalKey<FormState>();
  final TextEditingController _currentpasswordController =
      TextEditingController();
  bool wrongpass = false;

  void check() {
    if (user != null) {
      sponsorID = user?.uid;
      print('Sponsor ID: $sponsorID');
    } else {
      print('User is not logged in.');
    }
  }

  void deleteUserAccount() async {
    final user = await FirebaseAuth.instance.currentUser;
    var cred = null;

    if (user != null) {
      final email = user.email; // This will give you the user's email
      cred = EmailAuthProvider.credential(
        email: email!,
        password: _currentpasswordController.text,
      );
    }

    user!.reauthenticateWithCredential(cred).then((value) {
      user.delete().then((_) {
        //Success, do something
        Navigator.pop(context);
        _currentpasswordController.clear();
        wrongpass = false;
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
                      'Account deleted successfully!',
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
        // setState(() {
        //    isChangeing = false;
        //   weakPass = true;
        //   Navigator.of(context).pop();
        //   _showChangePasswordDialog(context);
        // });
        return;
      });
    }).catchError((err) {
      setState(() {
        // isChangeing = false;
        wrongpass = true;
        Navigator.of(context).pop();
        _showChangePasswordDialog(context);
      });
      return;
    });
  }
  // Future<void> deleteUserAccount() async {
  //   try {
  //     var cred=null;
  //     final user = await FirebaseAuth.instance.currentUser;
  //     if (user != null) {
  //       final email = user.email; // This will give you the user's email
  //        cred = EmailAuthProvider.credential(
  //         email: email!,
  //         password: _currentpasswordController.text,
  //       );
  //     }
  //     user!.reauthenticateWithCredential(cred);
  //     await FirebaseAuth.instance.currentUser!.delete();
  //   } on FirebaseAuthException catch (e) {
  //     if (e.code == "requires-recent-login") {
  //       print("errooooooooooor");
  //     } else {
  //       // Handle other Firebase exceptions
  //     }
  //   } catch (e) {
  //     // Handle general exception
  //   }
  // }

  void _loadProfileFromFirebase() async {
    check();
    DatabaseReference dbRef =
        FirebaseDatabase.instance.ref().child('Sponsors').child(sponsorID!);

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
          SponsorProfileInfo sponsor = SponsorProfileInfo(
              name: sponsorData['Name'] as String? ?? '',
              bio: sponsorData['Bio'] as String? ?? '',
              pic: sponsorData['Picture'] as String? ?? '',
              social: socialMediaAccounts

              // Add other fields as needed
              );

          sponsorList.add(sponsor);
          profilePicUrl = sponsor.pic;
          profileName = sponsor.name;
          // print(sponsorList);
          // print(sponsorList.first.social.first.link);
        });
      }
    });
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Password'),
          content: _buildChangePasswordForm(), // Call your function here
          actions: <Widget>[
            TextButton(
              onPressed: () {
                _currentpasswordController.clear();

                wrongpass = false;
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Color.fromARGB(255, 51, 45, 81)),
              ),
            ),
            TextButton(
              onPressed: () {
                wrongpass = false;
                // Implement your password change logic here
                if (!_formKeyPass.currentState!.validate()) {
                  print('here');
                  return;
                }

                deleteUserAccount();

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

  Widget _buildChangePasswordForm() {
    return Column(
      mainAxisSize:
          MainAxisSize.min, // Use MainAxisSize.min to make it fit in a dialog
      children: [
        SizedBox(
          height: 20,
        ),
        Form(
            key: _formKeyPass,
            child: Column(children: [
              Text(
                "Enter your current password to delete account",
              ),
              SizedBox(
                height: 20,
              ),
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
            ]))
      ],
    );
  }

  void initState() {
    super.initState();
    check();
    _loadProfileFromFirebase();
    _loadPostsFromFirebase();
  }

  List<Post> posts = [];
  String profilePicUrl = '';
  String profileName = '';
  void _loadPostsFromFirebase() {
    DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('posts');
    dbRef.onValue.listen((post) {
      if (post.snapshot.value != null) {
        setState(() {
          posts.clear();
          Map<dynamic, dynamic> postData =
              post.snapshot.value as Map<dynamic, dynamic>;
          postData.forEach((key, value) {
            if (value['userId'] == sponsorID) {
              // Use key as POSTid for the current post
              String POSTid = key;

              posts.add(Post(
                text: value['notes'] as String? ?? '',
                imageUrl: value['img'] as String? ?? '',
                profilePicUrl: profilePicUrl,
                eventname: value['EventName'] as String? ?? '',
                profileName: profileName,
                // Add other properties as needed
              ));
            }
          });
          // Optionally, you can sort posts based on a timestamp or other criteria
          // posts.sort((a, b) => b.timestamp.compareTo(a.timestamp));

          if (posts.isNotEmpty) {
            print("I have posts");
            for (int i = 0; i < posts.length; i++) print(posts[i].text);
          } else {
            print("Posts is empty");
          }
        });
      }
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

  Future<void> _showDeleteAccountConfirmationDialog(
      BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Delete Account Confirmation',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
          ),
          content: const Text(
            'Are you sure you want to delete your account ?                                   ',
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
                  Navigator.of(context).pop();
                  _showChangePasswordDialog(context);
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
                case 'deleteAccount':
                  _showDeleteAccountConfirmationDialog(context);
                  break;
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
                const PopupMenuItem<String>(
                  value: 'deleteAccount',
                  child: ListTile(
                    leading: Icon(
                      Icons.delete,
                      size: 30,
                      color: Colors.red, // Set the color to red
                    ),
                    title: Text(
                      'Delete Account',
                      style: TextStyle(fontSize: 20, color: Colors.red),
                    ),
                  ),
                ),
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
                          if (sponsorList.isNotEmpty)
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(sponsorList.first.pic)
                                    // sponsorList.first.pic != ""? NetworkImage(sponsorList.first.pic) :AssetImage("assets/ksuCPCLogo.png")
                                    ),
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
            child: Padding(
              padding: const EdgeInsets.all(0.0),
              child: Column(
                children: [
                  if (sponsorList.isNotEmpty)
                    Center(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                          Text(
                            sponsorList.first.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                    fontWeight: FontWeight.bold, fontSize: 40),
                          ),
                        ])),
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
                        builder: (context) => sponsorEditProfile(),
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
                  if (sponsorList.isNotEmpty)
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
                              sponsorList.first.bio,
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

                  if (sponsorList.isNotEmpty)
                    _ProfileInfoRow(sponsorList.first.social),
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
                  ),
                  if (posts.isNotEmpty)
                    Container(
                      height: MediaQuery.of(context).size.height *
                          0.3, // Adjust the height as needed
                      child: ListView(
                        children: posts.map((post) {
                          return Column(
                            children: [
                              PostContainer(
                                text: post.text,
                                imageUrl: post.imageUrl,
                                profilePicUrl: post.profilePicUrl,
                                profileName: post.profileName,
                                eventname: post.eventname,
                              ),
                              const SizedBox(height: 16.0),
                            ],
                          );
                        }).toList(),
                      ),
                    )
                  else
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/Write Content.png', // Specify the asset path
                            width: 200, // Specify the width of the image
                            height: 200, // Specify the height of the image
                          ),
                          Text('You don\'t have any posts yet'),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ImagePopupScreen extends StatelessWidget {
  final String imageUrl;

  ImagePopupScreen({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Add an 'X' button to close the popup
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Image.network(
          imageUrl,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class Post {
  final String text;
  final String? imageUrl;
  final String profilePicUrl;
  final String profileName;
  final String eventname;

  Post({
    required this.text,
    this.imageUrl,
    required this.profilePicUrl,
    required this.profileName,
    required this.eventname,
  });
}

class PostContainer extends StatelessWidget {
  final String text;
  final String? imageUrl;
  final String profilePicUrl;
  final String profileName;
  final String eventname;

  PostContainer({
    required this.text,
    this.imageUrl,
    required this.profilePicUrl,
    required this.profileName,
    required this.eventname,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage(profilePicUrl),
              ),
              SizedBox(width: 8.0),
              Text(
                profileName ?? '',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              SizedBox(width: 16.0),
              CircleAvatar(
                radius: 15,
                backgroundImage: AssetImage('assets/sponsite_white.jpg'),
              ),
              SizedBox(width: 8.0),
              Text(
                eventname ?? '',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ],
          ),
          SizedBox(height: 8.0),
          Text(
            text,
            style: const TextStyle(fontSize: 23.0),
          ),
          SizedBox(height: 8.0),
          if (imageUrl != '')
            InkWell(
              onTap: () {
                // When the image is tapped, show the popup
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ImagePopupScreen(imageUrl: imageUrl!),
                  ),
                );
              },
              child: Image.network(
                imageUrl!,
                height: 300.0,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
        ],
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  _ProfileInfoRow(List<SocialMediaAccount> this._items, {Key? key})
      : super(key: key);

  final List<SocialMediaAccount> _items;
  // final List<ProfileInfoItem> _items = const [
  //   ProfileInfoItem("Posts", FontAwesomeIcons.github),
  //   // ProfileInfoItem("Followers", 120),
  //   // ProfileInfoItem("Following", 200),
  // ];

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
                child: Icon(socialMediaIcons[item.title],
                    size: 40, color: Color.fromARGB(255, 91, 79, 158)),
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

class SponsorProfileInfo {
  final String name;
  final String bio;
  final String pic;
  List<SocialMediaAccount> social;

  SponsorProfileInfo(
      {required this.name,
      required this.bio,
      required this.pic,
      required this.social});
}

class SocialMediaAccount {
  final String title;
  final String link;

  SocialMediaAccount({
    required this.title,
    required this.link,
  });
}
