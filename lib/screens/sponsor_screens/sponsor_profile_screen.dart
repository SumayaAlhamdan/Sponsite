import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sponsite/widgets/drawer.dart';
import 'package:sponsite/widgets/sponsor_botton_navbar.dart';

class SponsorProfile extends StatelessWidget {
  const SponsorProfile({Key? key}) : super(key: key);

  Future<void> _showSignOutConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sign Out Confirmation'),
          content: Text('Are you sure you want to sign out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel',style: TextStyle(color:Color.fromARGB(255,51,45,81) ),),
            ),
            TextButton(
              onPressed: () async {
                // Sign out the user
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pop(); // Close the dialog
              },
              child:const  Text('Sign Out',style: TextStyle(color:Color.fromARGB(255,51,45,81) )),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //bottomNavigationBar: const SponsorBottomNavBar(),
      // endDrawer: const SideDrawer(),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255,51,45,81),
        actions: [
          // Builder(
          //   builder: (BuildContext context) {
          //     return IconButton(
          //       icon: const Icon(
          //         Icons.more_horiz,
          //         color: Color.fromARGB(255, 0, 0, 0),
          //         size: 60, // Changing Drawer Icon Size
          //       ),
          //       onPressed: () {
          //         Scaffold.of(context).openEndDrawer();
          //       },
          //       // tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
          //     );
          //   },
          // ),
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
                PopupMenuItem<String>(
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
                PopupMenuItem<String>(
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
        //leading:
      ),
      // appBar: AppBar(
      //   title: Text(''),
      //   backgroundColor: Color.fromARGB(255, 184, 163, 201) ,
      // ),

      body: Column(
        children: [
          const Expanded(flex: 2, child: _TopPortion()),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(0.0),
              child: Column(
                children: [
                  Text(
                    "Ksu CPC",
                    style: Theme.of(context)
                        .textTheme
                        .headline6
                        ?.copyWith(fontWeight: FontWeight.bold, fontSize: 40),
                  ),
                  // const _ProfileInfoRow(),
                  Container(
                    width: 600, // Set your desired width here
                    child: Card(
                      margin: const EdgeInsets.all(16.0),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          "Our event is designed to bring together the brightest minds in KSU to compete in solving challenging programming problems.",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      //  const _ProfileInfoRow(),
                      Container(
                        padding: const EdgeInsets.all(
                            16.0), // Adjust the padding to control the size
                        child: FloatingActionButton.extended(
                          backgroundColor:
                           Color.fromARGB(255,51,45,81),
                          //Color.fromARGB(255, 184, 163, 201),
                          onPressed: () {},
                          heroTag: 'Edit Profile',
                          elevation: 0,
                          label: Text(
                            "Edit Profile",
                            style: TextStyle(fontSize: 20, color: const Color.fromARGB(255, 255, 255, 255)),
                          ),
                          // icon: Icon(Icons.person),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                30.0), // Adjust the border radius as needed
                          ),
                        ),
                      )

                      // FloatingActionButton.extended(
                      //   onPressed: () {},
                      //   heroTag: 'mesage',
                      //   elevation: 0,
                      //   backgroundColor: Color.fromARGB(255, 178, 134, 195),
                      //   label: const Text("Message"),
                      //   icon: const Icon(Icons.message_rounded),
                      // ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({Key? key}) : super(key: key);

  final List<ProfileInfoItem> _items = const [
    ProfileInfoItem("Posts", 10),
    // ProfileInfoItem("Followers", 120),
    // ProfileInfoItem("Following", 200),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      constraints: const BoxConstraints(maxWidth: 100),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _items
            .map((item) => Expanded(
                    child: Row(
                  children: [
                    if (_items.indexOf(item) != 0) const VerticalDivider(),
                    Expanded(child: _singleItem(context, item)),
                  ],
                )))
            .toList(),
      ),
    );
  }

  Widget _singleItem(BuildContext context, ProfileInfoItem item) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              item.value.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          Text(
            item.title,
            style: Theme.of(context).textTheme.caption,
          )
        ],
      );
}

class ProfileInfoItem {
  final String title;
  final int value;
  const ProfileInfoItem(this.title, this.value);
}

class _TopPortion extends StatelessWidget {
  const _TopPortion({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
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
                    Color.fromARGB(255,51,45,81),
                  ]),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              )),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: 150,
            height: 150,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage("assets/ksuCPCLogo.png")),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    child: Container(
                      margin: const EdgeInsets.all(8.0),
                      decoration: const BoxDecoration(
                          color: Colors.green, shape: BoxShape.circle),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
