import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'dart:io';

class resetPassword extends StatefulWidget {
  const resetPassword({super.key});

  @override
  State<resetPassword> createState() {
    return _resetPasswordState();
  }
}

class _resetPasswordState extends State<resetPassword> {
  var _isAuthenticating = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKey2 = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final DatabaseReference dbref = FirebaseDatabase.instance.reference();
  final _firebase = FirebaseAuth.instance;
  bool _obscured = true;
  bool wrongEmailOrPass = false;
  bool invalidEmail = false;
  bool errorReset = false;

  UploadTask? task;
  File? file;

  void _toggleObscured() {
    setState(() {
      _obscured = !_obscured;
    });
  }

  void sendDatatoDB(BuildContext context, String email) async {
    final isValid = _formKey.currentState!.validate();
   
    print('jjj');
    if (!isValid) {
      print('jjj999');
      return;
    }
    _formKey.currentState!.save();

    try {
      setState(() {
        _isAuthenticating = true;
      });

      try {
        final methods = await FirebaseAuth.instance
            .fetchSignInMethodsForEmail(email);
        if (methods.isEmpty) {
          // Email is not registered
          setState(() {
            errorReset = true;
            _isAuthenticating = false;
          });
          return;
        }

        // Email is registered, and you can get the sign-in methods used
        await FirebaseAuth.instance.sendPasswordResetEmail(
          email: email,
        );

        Navigator.of(context).pop();
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
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Color.fromARGB(255, 91, 79, 158),
                              size: 48,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Password reset link sent successfully!',
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
      } catch (e) {
        setState(() {
          errorReset = true;
          _isAuthenticating = false;
        });
        return;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        setState(() {
          _isAuthenticating = false;
          wrongEmailOrPass = true;
          return;
        });
      } else if (e.code == 'invalid-email') {
        setState(() {
          _isAuthenticating = false;
          invalidEmail = true;
          return;
        });
      }
    } catch (e) {
      setState(() {
        _isAuthenticating = false;
        return;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        // appBar: AppBar(
        //   title: const Text('Sponsite'),
        // ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                    margin: const EdgeInsets.all(20),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            // mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              const SizedBox(
                                height: 50,
                              ),
                              SizedBox(height: screenHeight * .03),
                              const Text(
                                'Forgot your password?',
                                style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 51, 45, 81)),
                              ),
                              SizedBox(height: screenHeight * .0),
                              Text(
                                'please enter your registered email \n to recive reset link',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black.withOpacity(.6),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(
                                height: 70,
                              ),
                              const SizedBox(height: 10.0),
                              Row(
                                children: [
                                  SizedBox(width: 110,),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.6, // Set the desired width
                                    child: TextFormField(
                                      controller: _emailController,
                                      autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: 'Email Address',
                                        prefixIcon:
                                            Icon(Icons.email_rounded, size: 24),
                                      ),
                                      keyboardType: TextInputType.emailAddress,
                                      autocorrect: false,
                                      textCapitalization: TextCapitalization.none,
                                      validator: (value) {
                                      if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
                                                .hasMatch(value!) ||
                                            value.isEmpty) {
                                          return 'Please enter a valid email address';
                                        } else if (errorReset) {
                                          return 'Please enter a registered email';
                                        }else if (wrongEmailOrPass) {
                                          return 'Please enter a valid email';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                    SizedBox(width: 30,),
                                ],
                              ),
                              const SizedBox(height: 60.0),
                              

                              // if (errorReset)
                              //   Text(
                              //     'Please enter a registered email',
                              //     style: TextStyle(
                              //         fontStyle: FontStyle.normal,
                              //         fontSize: 13,
                              //         color: Colors.red[700],
                              //         height: 0.5),
                              //   ),
                              const SizedBox(height: 25),
                              if (_isAuthenticating)
                                const CircularProgressIndicator(),
                              if (!_isAuthenticating)
                                ElevatedButton(
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              const Color.fromARGB(
                                                  255, 51, 45, 81)),
                                      //Color.fromARGB(255, 207, 186, 224),), // Background color
                                      textStyle:
                                          MaterialStateProperty.all<TextStyle>(
                                              const TextStyle(
                                                  fontSize: 16)), // Text style
                                      padding: MaterialStateProperty.all<
                                              EdgeInsetsGeometry>(
                                          const EdgeInsets.all(16)), // Padding
                                      elevation: MaterialStateProperty.all<double>(
                                          1), // Elevation
                                      shape: MaterialStateProperty.all<OutlinedBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              30), // Border radius
                                          side: const BorderSide(
                                              color: Color.fromARGB(255, 255,
                                                  255, 255)), // Border color
                                        ),
                                      ),
                                      minimumSize: MaterialStateProperty.all<Size>(const Size(200, 50))),
                                  onPressed: () async {
                                    setState(() {
                                      errorReset=false;
                                      wrongEmailOrPass=false;
                                    });
                                    sendDatatoDB(context, _emailController.text.trim());
                                  },
                                  child: const Text(
                                    'Reset',
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
                                        fontSize: 20),
                                  ),
                                ),
                              const SizedBox(
                                height: 30,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Future<void> _showResetPasswordDialog(BuildContext context) async {
  //   showDialog<void>(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Reset Password'),
  //         content: SingleChildScrollView(
  //           child: Form(
  //             key: _formKey2,
  //             child: SizedBox(
  //               width: MediaQuery.of(context).size.width *
  //                   0.6, // Set the desired width
  //               child: Column(
  //                 children: [
  //                   TextFormField(
  //                     controller: _emailController,
  //                     autovalidateMode: AutovalidateMode.onUserInteraction,
  //                     decoration: const InputDecoration(
  //                       border: OutlineInputBorder(),
  //                       labelText: 'Email Address',
  //                       prefixIcon: Icon(Icons.email_rounded, size: 24),
  //                     ),
  //                     keyboardType: TextInputType.emailAddress,
  //                     autocorrect: false,
  //                     textCapitalization: TextCapitalization.none,
  //                     validator: (value) {
  //                       if (value == null || value.trim().isEmpty) {
  //                         return "Please enter email address";
  //                       } else if (invalidEmail) {
  //                         return 'Please enter a valid email';
  //                       }

  //                       return null;
  //                     },
  //                   ),
  //                   SizedBox(
  //                     height: 20,
  //                   ),
  //                   if (errorReset)
  //                     Text(
  //                       'Invalid email',
  //                       style: TextStyle(
  //                         fontStyle: FontStyle.normal,
  //                         fontSize: 13,
  //                         color: Colors.red[700],
  //                         height: 0.5,
  //                       ),
  //                     ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             onPressed: () {
  //               setState(() {
  //                 errorReset = false;
  //               });
  //               Navigator.of(context).pop(); // Close the dialog
  //             },
  //             child: const Text(
  //               'Cancel',
  //               style: TextStyle(
  //                 color: Color.fromARGB(255, 51, 45, 81),
  //                 fontSize: 20,
  //               ),
  //             ),
  //           ),
  //           TextButton(
  //             onPressed: () async {
  //               if (_formKey.currentState!.validate()) {
  //                 // Sign out the user
  //                 try {
  //                   final methods = await FirebaseAuth.instance
  //                       .fetchSignInMethodsForEmail(
  //                           _emailController.text.trim());
  //                   if (methods.isEmpty) {
  //                     // Email is not registered
  //                     setState(() {
  //                       errorReset = true;
  //                     });
  //                     return;
  //                   }

  //                   // Email is registered, and you can get the sign-in methods used
  //                   await FirebaseAuth.instance.sendPasswordResetEmail(
  //                     email: _emailController.text.trim(),
  //                   );

  //                   Navigator.of(context).pop();
  //                 } catch (e) {
  //                   setState(() {
  //                     errorReset = true;
  //                   });
  //                   return;
  //                 }
  //               }
  //             },
  //             child: const Text(
  //               'Send Email',
  //               style: TextStyle(
  //                 color: Color.fromARGB(255, 51, 45, 81),
  //                 fontSize: 20,
  //               ),
  //             ),
  //           ),
  //         ],
  //       );
  //     },
  //   ).then((_) {
  //     // Reset error flag when the dialog is dismissed
  //     setState(() {
  //       errorReset = false;
  //     });
  //   });
  // }
}
