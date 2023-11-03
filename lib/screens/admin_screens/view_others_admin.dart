import 'dart:async';
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewOthersProfileAdmin extends StatefulWidget {
  ViewOthersProfileAdmin(this.type,this.otherID,{Key? key}) : super(key: key);
  final otherID;
  final type;
  @override
  State<ViewOthersProfileAdmin> createState() => _ViewOthersProfileAdminState(type,otherID);
}

class _ViewOthersProfileAdminState extends State<ViewOthersProfileAdmin> {
  var otherID;
  var type;
  _ViewOthersProfileAdminState(t,otherId){
    otherID=otherId;
    type=t;
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
              email: sponseeData['Email'] as String? ?? '',
              name: sponseeData['Name'] as String? ?? '',
              type: sponseeData['Type'] as String? ?? '',
              doc: sponseeData['authentication document'] as String? ?? '',

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
   // check();
    _loadProfileFromFirebase();
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 51, 45, 81),
        iconTheme: IconThemeData(color: Colors.white),
        
      ),
      body: Column(
        children: [
          Expanded(
              flex: 2,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                         margin: const EdgeInsets.only(bottom: 500),
                    // height: 200,
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
                      width: 400,
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
                              
                              sponseeList.first.email,
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
                ],
                ),
              ),
                ],
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

class ViewOthersProfileInfo {
  final String email;
  final String name;
  final String type;
  final String doc;

  ViewOthersProfileInfo(
      {required this.email,
      required this.name,
      required this.type,
      required this.doc});
}

class SocialMediaAccount {
  final String title;
  final String link;

  SocialMediaAccount({
    required this.title,
    required this.link,
  });
}

