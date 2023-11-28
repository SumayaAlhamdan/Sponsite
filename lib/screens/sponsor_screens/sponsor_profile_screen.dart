import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:sponsite/screens/calendar.dart';
import 'package:sponsite/screens/sponsor_screens/sponsor_edit_profile.dart';
import 'package:url_launcher/url_launcher.dart';

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
  List<Event> events = [];
  List<Offer> offers = [];
  final DatabaseReference dbEvents =
      FirebaseDatabase.instance.reference().child('sponseeEvents');
  final DatabaseReference dbOffers =
      FirebaseDatabase.instance.reference().child('offers');
  void check() {
    if (user != null) {
      sponsorID = user?.uid;
      print('Sponsor ID: $sponsorID');
    } else {
      print('User is not logged in.');
    }
  }

  


  void deleteUserAccount() async {
    check();
    final user = await FirebaseAuth.instance.currentUser;
    var cred = null;

    DateTime parseEventDateAndTime(String date, String time) {
      final dateTimeString = '$date $time';
      final format = DateFormat('yyyy-MM-dd hh:mm');
      return format.parse(dateTimeString);
    }

    final now = DateTime.now();
    final filteredEvents = events.where((event) {
      final eventDateTime =
          parseEventDateAndTime(event.endDate, event.startTime);
      return eventDateTime.isAfter(now);
    }).toList();

    final filteredEventsWithOffers = filteredEvents.where((event) {
      return offers.any((offer) => offer.EventId == event.EventId);
    }).toList();
    print(filteredEventsWithOffers.length);
    filteredEventsWithOffers.forEach((event) {
      print('Event ID: ${event.EventId}');
      print('Event Name: ${event.EventName}');
      // Add more properties as needed
      print('-----------------------');
    });
    if (filteredEventsWithOffers.isNotEmpty) {
      print(filteredEventsWithOffers);
      print("1111111111111111");
      
      Navigator.pop(context);
      _showCantDeleteDialog(context);
      return;
    }
   // _deleteAllUserPosts();
    print("77777777777");
    //    bool _isEventAssociatedWithSponsor(String eventId, String? sponsorID) {
    //   // Check if there is an offer with the specified EventId and sponsorId
    //   return offers.any(
    //       (offer) => offer.EventId == eventId && offer.sponsorId == sponsorID);
    // }
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
        DatabaseReference del =
            FirebaseDatabase.instance.ref().child('Sponsors').child(sponsorID!);
        del.update({
          'Picture':
              'https://firebasestorage.googleapis.com/v0/b/sponsite-6a696.appspot.com/o/user_images%2FCrHfFHgX0DNzwmVmwXzteQNuGRr1%2FCrHfFHgX0DNzwmVmwXzteQNuGRr1.jpg?alt=media&token=4e08e9f5-d526-4d2c-817b-11f9208e9b52',
          'Bio': 'This user deleted their account',
          'Social Media': null,
          'Deleted':true,
        });
        _deleteAllUserPosts();
        // del.remove();
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
    await dbOffers.once().then((offer) {
      if (offer.snapshot.value != null) {
        setState(() {
          offers.clear();
          Map<dynamic, dynamic> offersData =
              offer.snapshot.value as Map<dynamic, dynamic>;
          offersData.forEach((key, value) {
            var categoryList = (value['Category'] as List<dynamic>)
                .map((category) => category.toString())
                .toList();
            if (value['sponsorId'] == sponsorID) {
              offers.add(Offer(
                EventId: value['EventId'] as String? ?? '',
                sponsorId: value['sponsorId'] as String,
                sponseeId: value['sponseeId'] as String,
                notes: value['notes'] as String? ?? '',
                Category: categoryList,
                status: value['Status'] as String? ?? '',
              ));
            }
          });
        });
      }
    });

    setState(() {
      final DatabaseReference database = FirebaseDatabase.instance.ref();
      dbEvents.onValue.listen((event) {
        if (event.snapshot.value != null) {
          setState(() {
            events.clear();
            Map<dynamic, dynamic> eventData =
                event.snapshot.value as Map<dynamic, dynamic>;

            eventData.forEach((key, value) {
              // Check if value['Category'] is a listي
              List<String> categoryList = [];
              if (value['Category'] is List<dynamic>) {
                categoryList = (value['Category'] as List<dynamic>)
                    .map((category) => category.toString())
                    .toList();
              }
              String timestampString = value['TimeStamp'] as String;
              String eventStartDatestring = value['startDate'];
              String eventEndtDatestring = value['endDate'];
              DateTime? eventStartDate =
                  DateTime.tryParse(eventStartDatestring);
              DateTime? eventEndDate = DateTime.tryParse(eventEndtDatestring);

              // Simulate the current time (for testing purposes)
              DateTime currentTime = DateTime.now();

              events.add(Event(
                EventId: key,
                EventName: value['EventName'] as String? ?? '',
                sponseeId: value['SponseeID'] as String? ?? '',
                EventType: value['EventType'] as String? ?? '',
                location: value['Location'] as String? ?? '',
                imgURL: value['img'] as String? ?? "",
                startDate: value['startDate'] as String? ?? '',
                endDate: value['endDate'] as String? ?? '',
                startTime: value['startTime'] as String? ?? ' ',
                endTime: value['endTime'] as String? ?? ' ',
                Category: categoryList,
                description: value['description'] as String? ?? ' ',
                notes:
                    value['Notes'] as String? ?? 'There are no notes available',
                benefits: value['Benefits'] as String?,
                NumberOfAttendees: value['NumberOfAttendees'] as String? ?? '',
                timeStamp: timestampString,
                sponseeImage: '',
                sponseeName: '', // Store the timestamp
              ));
            });
          });
        }
        // Sort events based on the timeStamp (descending order)
        events.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));
      });
    });
  }

  Future<void> _showCantDeleteDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Cannot Delete Account',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
          ),
          content: const Text(
            'You cannot delete your account because you have ongoing events                       ',
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
                'Ok',
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
          ],
        );
      },
    );
  }

  String rating = '0';
  void getRateFromDB() {
    final DatabaseReference database = FirebaseDatabase.instance.ref();
    database.child('Sponsors').onValue.listen((rate) {
      if (rate.snapshot.value != null) {
        Map<dynamic, dynamic> rateData =
            rate.snapshot.value as Map<dynamic, dynamic>;
        rateData.forEach((key, value) {
          if (key == sponsorID) {
            if (value['Rate'] != null) {
              rating = value['Rate'].toString();
            }
          }
        });
      }
    });
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Password',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
          ),
          content: _buildChangePasswordForm(), // Call your function here
          backgroundColor: Colors.white,
          elevation: 0, // Remove the shadow
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
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
                  wrongpass = false;
                  // Implement your password change logic here
                  if (!_formKeyPass.currentState!.validate()) {
                    print('here');
                    return;
                  }

                  deleteUserAccount();
                })
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
    getRateFromDB();
  }
void _deleteAllUserPosts() {
  DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('posts');
    dbRef.onValue.listen((post) {
      if (post.snapshot.value != null) {
       
          posts.clear();
          Map<dynamic, dynamic> postData =
              post.snapshot.value as Map<dynamic, dynamic>;

      // Iterate through all posts
      postData.forEach((key, value) {
        if (value['userId'] == sponsorID) {
          // Use key as POSTid for the current post
          String postID = key;

          // Delete the post
          dbRef.child(postID).remove();
        }
      });
    }
  });
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
                id: POSTid,
                text: value['notes'] as String? ?? '',
                imageUrl: value['img'] as String? ?? '',
                profilePicUrl: profilePicUrl,
                eventname: value['EventName'] as String? ?? '',
                profileName: profileName,
                timestamp: value['TimeStamp'] as String? ?? '',
                // Add other properties as needed
              ));
            }
          });
          // Optionally, you can sort posts based on a timestamp or other criteria
          posts.sort((a, b) => b.timestamp.compareTo(a.timestamp));

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
     return Theme(
      // Apply your theme settings within the Theme widget
      data: ThemeData(
        // Set your desired font family or other theme configurations
        fontFamily: 'Urbanist',
        textTheme: TextTheme(
      displayLarge: const TextStyle(
        fontSize: 72,
        fontWeight: FontWeight.bold,
      ),
        // Add other theme configurations here as needed
      ),
      ),
    child: Scaffold(
      backgroundColor: Colors.white,
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
              child: SingleChildScrollView(
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
                                      fontWeight: FontWeight.bold,
                                      fontSize: 40),
                            ),
                            Icon(
                              Icons.star,
                              color: Colors.yellow,
                              size: 30,
                            ),
                            Text(
                              rating,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontSize: 20),
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
                                  id: post.id,
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
                            Text('You don\'t have any posts yet', style: TextStyle(fontSize:18)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    )
    );
  }
}
class ImagePopupScreen extends StatelessWidget {
  final String imageUrl;

  ImagePopupScreen({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
     return Theme(
      // Apply your theme settings within the Theme widget
      data: ThemeData(
        // Set your desired font family or other theme configurations
        fontFamily: 'Urbanist',
        textTheme: TextTheme(
      displayLarge: const TextStyle(
        fontSize: 72,
        fontWeight: FontWeight.bold,
      ),
        // Add other theme configurations here as needed
      ),
      ),
    child: Scaffold(
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
    )
    );
  }
}

class Post {
  final String? id;
  final String text;
  final String? imageUrl;
  final String profilePicUrl;
  final String profileName;
  final String eventname;
  final String timestamp;

  Post({
    required this.id,
    required this.text,
    this.imageUrl,
    required this.profilePicUrl,
    required this.profileName,
    required this.eventname,
    required this.timestamp,
  });
}

class PostContainer extends StatelessWidget {
  final String? id;
  final String text;
  final String? imageUrl;
  final String profilePicUrl;
  final String profileName;
  final String eventname;

  PostContainer({
    required this.id,
    required this.text,
    this.imageUrl,
    required this.profilePicUrl,
    required this.profileName,
    required this.eventname,
  });
  Future<void> _showDeletePostConfirmation(BuildContext context) async {
    DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('posts');
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Delete Post Confirmation'),
          content: const Text(
            'Are you sure you want to delete this post?                                   ',
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
                print("post id is $id");
                dbRef.child(id!).remove().then((_) {
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
                              'Post deleted successfully!',
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
                });
              },
              child: const Text('Delete',
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
        return Theme(
      // Apply your theme settings within the Theme widget
      data: ThemeData(
        // Set your desired font family or other theme configurations
        fontFamily: 'Urbanist',
        textTheme: TextTheme(
      displayLarge: const TextStyle(
        fontSize: 72,
        fontWeight: FontWeight.bold,
      ),
        // Add other theme configurations here as needed
      ),
      ),
    child: Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Stack(
        children: [
          Column(
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, fontFamily: 'Urbanist',),
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
                        builder: (context) =>
                            ImagePopupScreen(imageUrl: imageUrl!),
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
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                _showDeletePostConfirmation(context);
                // Implement your delete logic here
                // For example, you can show a confirmation dialog
                // and then delete the post if the user confirms.
              },
            ),
          ),
        ],
      ),
    )
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

class Event {
  final String EventId;
  final String EventName;
  final String sponseeId;
  final String EventType;
  final String location;
  final String description;
  final String imgURL;
  final String startDate;
  final String endDate;
  final String startTime;
  final String endTime;
  final String notes;
  final String? benefits;
  final String NumberOfAttendees;
  final List<String> Category;
  final String timeStamp;
  String sponseeName;
  String sponseeImage;

  Event({
    required this.EventId,
    required this.EventName,
    required this.EventType,
    required this.sponseeId,
    required this.location,
    required this.description,
    required this.imgURL,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.Category,
    required this.NumberOfAttendees,
    required this.notes,
    required this.timeStamp,
    this.benefits,
    required this.sponseeName,
    required this.sponseeImage,
  });
}

class Offer {
  final String EventId;
  final String sponseeId;
  final String sponsorId;
  final List<String> Category;
  final String notes;
  final String status;

  Offer({
    required this.EventId,
    required this.sponseeId,
    required this.sponsorId,
    required this.Category,
    required this.notes,
    required this.status,
  });
}
