import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
              social: socialMediaAccounts

              // Add other fields as needed
              );

          sponseeList.add(sponsee);
          // print(sponseeList);
          // print(sponseeList.first.social.first.link);
        });
      }
    });
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
          title: const Text('Sign Out Confirmation'),
          content: const Text(
            'Are you sure you want to sign out?                                   ',
            style: TextStyle(fontSize: 20),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                    color: Color.fromARGB(255, 51, 45, 81), fontSize: 20),
              ),
            ),
            TextButton(
              onPressed: () async {
                // Sign out the user
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pop();
                // Close the dialog
              },
              child: const Text('Sign Out',
                  style: TextStyle(
                      color: Color.fromARGB(255, 51, 45, 81), fontSize: 20)),
            ),
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
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_horiz,
              color: Color.fromARGB(255, 255, 255, 255),
              size: 70,
            ),
            onSelected: (value) {
              // Handle menu item selection here
              switch (value) {
                case 'myAccount':
                  // Handle My Account selection
                  // You can add your logic here
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
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                                radius: 25,
                                backgroundColor:
                                    Color.fromARGB(255, 224, 224, 224),
                                child: GestureDetector(
                                  child: const Icon(
                                    Icons.edit,
                                    size: 30,
                                    color: Color.fromARGB(255, 91, 79, 158),
                                  ),
                                  onTap: () {
                                    showModalBottomSheet(
                                        context: context, builder: buildSheet);
                                  },
                                )),
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
                  if (sponseeList.isNotEmpty)
                    Text(
                      sponseeList.first.name,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold, fontSize: 40),
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
                  const Divider(
                    indent: 100,
                    endIndent: 100,
                  ),
                  if (sponseeList.isNotEmpty)
                    _ProfileInfoRow(sponseeList.first.social),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
          ],
        ),
        Center(
          child: UserImagePicker(
            sponseeList.first.pic,
            onPickImage: (pickedImage) {
              _selectedImage = pickedImage;
            },
          ),
        ),
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

class _ProfileInfoRow extends StatelessWidget {
  _ProfileInfoRow(List<SocialMediaAccount> this._items, {Key? key})
      : super(key: key);
 
  final List<SocialMediaAccount> _items;
   
  // void max(){
  //   print("kkkkkkkkkkk");
  //   if(_items.length == 1){
  //     num=10;
      
  //   }
  //   else if(_items.length == 2){
  //     num=100;
  //   }
  //   else if(_items.length == 3){
  //     num=200;
  //   }
  //   else if(_items.length == 4){
  //     num=350;
  //   }
  // }
  // final List<ProfileInfoItem> _items = const [
  //   ProfileInfoItem("Posts", FontAwesomeIcons.github),
  //   // ProfileInfoItem("Followers", 120),
  //   // ProfileInfoItem("Following", 200),
  // ];

  // void initState() {
  //   max();
  //   print(num);
  // }
  

  final Map<String, IconData> socialMediaIcons = {
    'github': FontAwesomeIcons.github,
    'twitter': FontAwesomeIcons.twitter,
    'instagram': FontAwesomeIcons.instagram,
    'facebook': FontAwesomeIcons.facebook,
    'linkedin': FontAwesomeIcons.linkedin,
    'website': FontAwesomeIcons.paperclip,
    // Add more social media titles and corresponding icons as needed
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      //color: Colors.amber,
      constraints:  BoxConstraints(maxWidth: _items.length * 80),
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
            color:Color.fromARGB(255, 244, 244, 244),
            child: InkWell(
              onTap: () {
                _launchUrl(item.link);
              },
              child: Center(
                child: Icon(socialMediaIcons[item.title], size: 40,  color: Color.fromARGB(255, 91, 79, 158),),
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
  List<SocialMediaAccount> social;

  SponseeProfileInfo(
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
