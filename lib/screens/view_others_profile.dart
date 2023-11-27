import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sponsite/widgets/user_image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewOthersProfile extends StatefulWidget {
  ViewOthersProfile(this.type, this.otherID, {Key? key}) : super(key: key);
  final otherID;
  final type;
  State<ViewOthersProfile> createState() =>
      _ViewOthersProfileState(type, otherID);
}

class _ViewOthersProfileState extends State<ViewOthersProfile> {
  var otherID;
  var type;
  _ViewOthersProfileState(t, otherId) {
    otherID = otherId;
    type = t;
  }
  // late String name;
  List<ViewOthersProfileInfo> sponseeList = [];
  File? _selectedImage;

  // void check() {
  //   if (user != null) {
  //     otherID = user?.uid;
  //     print('Sponsee ID: $otherID');
  //   } else {
  //     print('User is not logged in.');
  //   }
  // }

  void _loadProfileFromFirebase() async {
    //  check();
    DatabaseReference dbRef =
        FirebaseDatabase.instance.ref().child(type).child(otherID!);
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
          ViewOthersProfileInfo sponsee = ViewOthersProfileInfo(
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
  late String rating  = '0.0'  ;  
  void _getRateFromDB(){ 
  final DatabaseReference database = FirebaseDatabase.instance.ref();
  database.child(type).onValue.listen((rate) {
    print('Thy type there is : ') ; print(type) ; 
    if (rate.snapshot.value != null) {
                print('line 94 isnt null') ; 
      Map<dynamic, dynamic> rateData =
          rate.snapshot.value as Map<dynamic, dynamic>;
      rateData.forEach((key, value) {
        if (key == otherID) {
          print('They key of spnsee value') ; 
                   print('They  spnsee id') ;
          if (value['Rate'] != null) {
            print('Rate isnt null') ; 
            rating = value['Rate'] ;
          }
       
          }
      }
      ); } }); 
  }

  void initState() {
    super.initState();
    // check();
    _loadProfileFromFirebase();
    _loadPostsFromFirebase();
    _getRateFromDB() ; 
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
            if (value['userId'] == otherID) {
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
        iconTheme: IconThemeData(color: Colors.white),
        // actions: [
        //   PopupMenuButton<String>(
        //     icon: const Icon(
        //       Icons.more_horiz,
        //       color: Color.fromARGB(255, 255, 255, 255),
        //       size: 70,
        //     ),
        //     onSelected: (value) {
        //       // Handle menu item selection here
        //       switch (value) {
        //         case 'myAccount':
        //           Navigator.of(context).push(
        //                                 MaterialPageRoute(
        //                                   builder: (context) => MyAccount(),
        //                                 ));
        //           break;
        //         case 'signOut':
        //           _showSignOutConfirmationDialog(context);
        //           break;
        //         // case 'deleteAccount':
        //         //   // Handle Delete Account selection
        //         //   // You can add your logic here
        //         //   break;
        //       }
        //     },
        //     itemBuilder: (BuildContext context) {
        //       return [
        //         const PopupMenuItem<String>(
        //           value: 'myAccount',
        //           child: ListTile(
        //             leading: Icon(
        //               Icons.perm_identity,
        //               size: 30,
        //             ),
        //             title: Text(
        //               'My Account',
        //               style: TextStyle(fontSize: 20),
        //             ),
        //           ),
        //         ),
        //         const PopupMenuItem<String>(
        //           value: 'signOut',
        //           child: ListTile(
        //             leading: Icon(
        //               Icons.exit_to_app,
        //               size: 30,
        //             ),
        //             title: Text(
        //               'Sign out',
        //               style: TextStyle(fontSize: 20),
        //             ),
        //           ),
        //         ),
        //         // PopupMenuItem<String>(
        //         //   value: 'deleteAccount',
        //         //   child: ListTile(
        //         //     leading: Icon(
        //         //       Icons.delete,
        //         //       size: 30,
        //         //     ),
        //         //     title: Text(
        //         //       'Delete account',
        //         //       style: TextStyle(fontSize: 20),
        //         //     ),
        //         //   ),
        //         // ),
        //       ];
        //     },
        //   ),
        // ],
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
  Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        sponseeList.first.name,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 40,
            ),
      ),
      SizedBox(width: 10), // Adjust the width according to your preference
      Icon(
        Icons.star,
        color: Colors.yellow,
        size: 30,
      ),
      Text(
        rating,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 20,
            ),
      ),
    ],
  ),
                   
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
                        'Posts',
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
                          Text(sponseeList.first.name +
                              ' doesn\'t have any posts yet'),
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
  //         ],
  //       ),
  //       Center(
  //         child: UserImagePicker(
  //           sponseeList.first.pic,
  //           onPickImage: (pickedImage) {
  //             _selectedImage = pickedImage;
  //           },
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // void save() async {
  //   final storageRef = FirebaseStorage.instance
  //       .ref()
  //       .child('user_images')
  //       .child(otherID!)
  //       .child('$otherID.jpg');

  //   await storageRef.putFile(_selectedImage!);
  //   final imageUrl = await storageRef.getDownloadURL();
  //   DatabaseReference dbRef =
  //       FirebaseDatabase.instance.ref().child('Sponsees').child(otherID!);
  //   dbRef.update({'Picture': imageUrl});
  //   _loadProfileFromFirebase();
  //   Navigator.pop(context);
  // }
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

class ViewOthersProfileInfo {
  final String name;
  final String bio;
  final String pic;
  List<SocialMediaAccount> social;

  ViewOthersProfileInfo(
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
