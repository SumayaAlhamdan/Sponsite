import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sponsite/reset_passwords.dart';
import 'package:sponsite/screens/first_choosing_screen.dart';
import 'dart:io';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() {
    return _SignInState();
  }
}

class _SignInState extends State<SignIn> {
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
  

  UploadTask? task;
  File? file;

  void _toggleObscured() {
    setState(() {
      _obscured = !_obscured;
    });
  }

  void sendDatatoDB(BuildContext context, String email, String password) async {
    final isValid = _formKey.currentState!.validate();

    if (!isValid) {
      return;
    }
    _formKey.currentState!.save();

    try {
      setState(() {
        _isAuthenticating = true;
      });

      final userCredentials = await _firebase.signInWithEmailAndPassword(
          email: email, password: password);
           // Check if the user's token is stored
    final currentUser = FirebaseAuth.instance.currentUser;
    await _storeUserToken(currentUser?.uid);

    //if (userToken == null) {
      // The user's token is not stored yet, handle this case by retrieving and storing the token
    // await _storeUserToken(currentUser?.uid);
   // }


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
   Future<void> _storeUserToken(String? userId) async {
  if (userId != null) {
    final newToken = await obtainNewTokenUsingFCM(userId);
    await saveTokenToDatabase(userId, newToken as String);
    //final token = await _retrieveUserToken(userId);
    /*
    if (token != null) {
      // The token is available, proceed with storing it in your database
      await saveTokenToDatabase(userId, token);
    } else {
      final newToken = await obtainNewTokenUsingFCM(userId);
      if (newToken != null) {
        await saveTokenToDatabase(userId, newToken);
      } else {
        print("User's token is not available yet. Handle this case as needed.");
      }
    }*/
  }
}

Future<String?> _retrieveUserToken(String? userId) async {
  if (userId != null) {
    final dataSnapshot = await dbref.child('userTokens').child(userId).once();
    
    if (dataSnapshot.snapshot.value != null) {
      final Map<String, dynamic> data = dataSnapshot.snapshot.value as Map<String, dynamic>;

      if (data != null && data['token'] != null) {
        return data['token'].toString();
      }
    }
  }
  return null;
}



Future<void> saveTokenToDatabase(String userId, String token) async {
  await dbref.child('userTokens').child(userId).set({
    'token': token,
  });
}
Future<String?> obtainNewTokenUsingFCM(String userId) async {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  try {
    // Request a new FCM token
    String? newToken = await _firebaseMessaging.getToken();

    if (newToken != null) {
      return newToken;
    } else {
       print("Error obtaining FCM token");
      return null; // Unable to obtain a new token
    }
  } catch (e) {
    print("Error obtaining FCM token: $e");
    return null; // Handle any errors that occur while obtaining the token
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
                              SizedBox(height: screenHeight * .01),
                              const Text(
                                'Welcome,',
                                style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 51, 45, 81)),
                              ),
                              SizedBox(height: screenHeight * .01),
                              Text(
                                'Sign in to continue',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black.withOpacity(.6),
                                ),
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              const SizedBox(height: 10.0),
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
                                    if (value == null || value.trim().isEmpty) {
                                      return "Please enter email address";
                                    } else if (invalidEmail) {
                                      return 'Please enter a valid email';
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
                                  controller: _passwordController,
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  decoration: InputDecoration(
                                    border: const OutlineInputBorder(),
                                    labelText: 'Password',
                                    prefixIcon: const Icon(Icons.lock_rounded,
                                        size: 24),
                                    suffixIcon: Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(0, 0, 4, 0),
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
                              const SizedBox(height: 20.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  GestureDetector(
                                    child: const Text(
                                      'Forgot password?',
                                      style: TextStyle(
                                          decoration: TextDecoration.underline,
                                          color:
                                              Color.fromARGB(255, 91, 79, 158),
                                          fontSize: 17),
                                    ),
                                    onTap: () {
                                        Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => resetPassword(),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 115.0),
                                ],
                              ),
                              const SizedBox(height: 10.0),
                              const SizedBox(height: 8),
                              if (wrongEmailOrPass)
                                Text(
                                  'Wrong email or password',
                                  style: TextStyle(
                                      fontStyle: FontStyle.normal,
                                      fontSize: 13,
                                      color: Colors.red[700],
                                      height: 0.5),
                                ),
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
                                    String email = _emailController.text.trim();
                                    String password =
                                        _passwordController.text.trim();
                                    setState(() {
                                      wrongEmailOrPass=false;
                                      invalidEmail=false;
                                    });
                                    sendDatatoDB(context, email, password);
                                  },
                                  child: const Text(
                                    'Sign In',
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
                                        fontSize: 20),
                                  ),
                                ),
                              const SizedBox(
                                height: 30,
                              ),
                              if (!_isAuthenticating)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text("Don't have an account?"),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const FirstChoosing(),
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        'Sign Up',
                                        style: TextStyle(
                                            fontSize: 17,
                                            color: Color.fromARGB(
                                                255, 91, 79, 158),
                                            decoration:
                                                TextDecoration.underline),
                                      ),
                                    )
                                  ],
                                )
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

  
}
