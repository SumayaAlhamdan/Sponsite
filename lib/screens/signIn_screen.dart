import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sponsite/screens/first_choosing_screen.dart';

import 'dart:io';

import 'package:sponsite/screens/signUp_screen.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() {
    return _SignInState();
  }
}

class _SignInState extends State<SignIn> {
  bool _obscured = true;
  var _isLogin = false;
  var _isAuthenticating = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final DatabaseReference dbref = FirebaseDatabase.instance.reference();
  final _firebase = FirebaseAuth.instance;
  var type;

  String? errorMessage;

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
      setState(() {
        errorMessage = "Please make sure to fill all fields correctly";
      });

      return;
    }
    _formKey.currentState!.save();

    try {
      setState(() {
        _isAuthenticating = true;
      });

      final userCredentials = await _firebase.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        setState(() {
          _isAuthenticating = false;
          errorMessage = 'Wrong email or password';
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        _isAuthenticating = false;
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sponsite'),
      ),
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
                        // autovalidateMode: AutovalidateMode.always,
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
                                color: Color.fromARGB(255,51,45,81)
                              ),
                            ),
                            SizedBox(height: screenHeight * .01),
                            Text(
                              'Log in to continue',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black.withOpacity(.6),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            const SizedBox(height: 10.0),
                            SizedBox(
                              width: MediaQuery.of(context).size.width *
                                  0.7, // Set the desired width
                              child: TextFormField(
                                controller: _emailController,
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
                                  if (value == null ||
                                      value.trim().isEmpty ||
                                      !value.contains("@")) {
                                    return "Please enter a valid email address";
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            const SizedBox(height: 30.0),
                            SizedBox(
                              width: MediaQuery.of(context).size.width *
                                  0.7, // Set the desired width
                              child: TextFormField(
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  border: const OutlineInputBorder(),
                                  labelText: 'Password',
                                  prefixIcon:
                                      const Icon(Icons.lock_rounded, size: 24),
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
                                  if (value == null ||
                                      value.trim().length < 6) {
                                    return "Password must be at least 6 characters long";
                                  } else if (value.length > 15) {
                                    return "Password should not be greater than 15 characters";
                                  } else {
                                    return null;
                                  }//Color.fromARGB(235, 160, 122, 192)
                                },
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            const SizedBox(height: 100.0),
                            if (_isAuthenticating)
                              const CircularProgressIndicator(),
                            if (!_isAuthenticating)
                              ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                           Color.fromARGB(255,51,45,81)),
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
                                            color: Color.fromARGB(255, 255, 255,
                                                255)), // Border color
                                      ),
                                    ),
                                    minimumSize: MaterialStateProperty.all<Size>(const Size(200, 50))),
                                onPressed: () {
                                  String email = _emailController.text;
                                  String password = _passwordController.text;

                                  print('Email: $email');
                                  print('Password: $password');

                                  if (errorMessage != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(errorMessage!),
                                        backgroundColor: const Color.fromARGB(
                                            255, 87, 11, 117),
                                        behavior: SnackBarBehavior.floating,
                                        margin: EdgeInsets.all(50),
                                        elevation: 30,
                                      ),
                                    );
                                    return; // Return or perform any other necessary action
                                  }
                                  
                                    sendDatatoDB(context, email, password);
                                  
                                },
                                child: const Text(
                                  'Sign In',
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 255, 255, 255),
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
                                  const Text("Dont have an account?"),
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
                                      style: const TextStyle(fontSize: 17),
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
    );
  }
}
