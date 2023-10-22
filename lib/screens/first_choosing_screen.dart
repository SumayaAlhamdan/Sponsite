import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sponsite/screens/signUp_screen.dart';

class FirstChoosing extends StatefulWidget {
  const FirstChoosing({super.key});

  @override
  State<FirstChoosing> createState() {
    return _FirstChoosingState();
  }
}

class _FirstChoosingState extends State<FirstChoosing> {
  final DatabaseReference dbref = FirebaseDatabase.instance.reference();

  var type = "";

  bool sponseeSelected = false;
  bool sponsorSelected = false;

  final MaterialColor _sponseeBorder = Colors.grey;
  final MaterialColor _sponsorBorder = Colors.grey;

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      decoration: const BoxDecoration(
        // image: DecorationImage(image:AssetImage('assets/5.png'),
        // fit: BoxFit.cover),

        gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Color.fromARGB(255, 91, 79, 158),
              Color.fromARGB(255, 51, 45, 81),
            ]),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          // title: const Text('Sponsite'),
          backgroundColor: Colors.transparent,
          iconTheme:const IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const SizedBox(
                          height: 50,
                        ),
                        SizedBox(height: screenHeight * .1),
                        const Text(
                          'Welcome,',
                          style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 51, 45, 81)),
                        ),
                        SizedBox(height: screenHeight * .02),
                        Text(
                          'Choose account type to continue',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black.withOpacity(.6),
                          ),
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Card(
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  side: BorderSide(
                                    color: _sponsorBorder,
                                    // Colors.grey,
                                    width: 1,
                                  ),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      sponseeSelected = false;
                                      sponsorSelected = true;
                                      // _sponsorBorder = Colors.deepPurple;
                                      // _sponseeBorder = Colors.grey;
                                      type = 'Sponsor';
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => SignUp(type),
                                        ),
                                      );
                                    });
                                  },
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: 190,
                                        height: 240,
                                        padding: const EdgeInsets.all(8),
                                        child: Image.asset(
                                          "assets/Spo_site__2_-removebg-preview.png",
                                          fit: BoxFit.scaleDown,
                                          height: 1,
                                          width: 1,
                                        ),
                                      ),
                                      if (sponsorSelected)
                                        const Positioned(
                                          bottom: 1,
                                          right: 4,
                                          child: Icon(
                                            Icons.check_circle_rounded,
                                            color: Color.fromARGB(
                                                255, 135, 181, 103),
                                            size: 40,
                                          ),
                                        ),
                                      const Positioned(
                                          bottom: -5,
                                          right: 0,
                                          left: 56,
                                          child: Text(
                                            'Sponsor',
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w500,
                                                color: Color.fromARGB(
                                                    255, 51, 45, 81)),
                                          ))
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 45.0),
                              Card(
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  side: BorderSide(
                                    color: _sponseeBorder,
                                    //Colors.grey,
                                    width: 1,
                                  ),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      sponseeSelected = true;
                                      sponsorSelected = false;
                                      // _sponseeBorder = Colors.deepPurple;
                                      // _sponsorBorder = Colors.grey;
                                      type = 'Sponsee';
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => SignUp(type),
                                        ),
                                      );
                                    });
                                  },
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: 190,
                                        height: 240,
                                        padding: const EdgeInsets.all(8),
                                        child: Image.asset(
                                          "assets/sponsee-4.png",
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      if (sponseeSelected)
                                        const Positioned(
                                          bottom: 1,
                                          right: 4,
                                          child: Icon(
                                            Icons.check_circle_rounded,
                                            color: Color.fromARGB(
                                                255, 135, 181, 103),
                                            size: 40,
                                          ),
                                        ),
                                      const Positioned(
                                          bottom: -5,
                                          right: 0,
                                          left: 56,
                                          child: Text(
                                            'Sponsee',
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w500,
                                                color: Color.fromARGB(
                                                    255, 51, 45, 81)),
                                          ))
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 200),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.center,
                        //   children: [
                        //     const Text(
                        //       'I already have an account',
                        //       style: TextStyle(fontSize: 17),
                        //     ),
                        //     TextButton(
                        //       onPressed: () {
                        //         Navigator.of(context).push(
                        //           MaterialPageRoute(
                        //             builder: (context) => const SignIn(),
                        //           ),
                        //         );
                        //       },
                        //       child: const Text(
                        //         'Sign In',
                        //         style: TextStyle(
                        //             fontSize: 20,
                        //             color: Color.fromARGB(255, 87, 11, 117)),
                        //       ),
                        //     )
                        //   ],
                        // )
                      ],
                    ),
                  ),
                ),
              )
            ]),
          ),
        ),
      ),
    );
  }
}
