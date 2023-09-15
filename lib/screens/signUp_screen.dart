import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sponsite/screens/signIn_screen.dart';
import '../FirebaseApi.dart';

class SignUp extends StatefulWidget {
  const SignUp(this.type, {super.key});
  final type;
  @override
  State<SignUp> createState() {
    return _SignUpState(type);
  }
}

class _SignUpState extends State<SignUp> {
  _SignUpState(type) {
    theType = type;
    print(theType);
  }
  bool _obscured = true;
  var theType;
  var _isAuthenticating = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _fileController =
      TextEditingController(text: 'No file selected');
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final DatabaseReference dbref = FirebaseDatabase.instance.reference();
  final _firebase = FirebaseAuth.instance;

  var fileName = 'No File Selected';

  String? errorMessage;

  UploadTask? task;
  File? file;

  void _displayError(context, String errMsg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errMsg),
        backgroundColor: Color.fromARGB(255, 91, 79, 158),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(50),
        elevation: 30,
      ),
    );
  }

  void _toggleObscured() {
    setState(() {
      _obscured = !_obscured;
    });
  }

  void sendDatatoDB(String name, String email, String password, String fileName,
      context) async {
    final isValid = _formKey.currentState!.validate();

    if (!isValid) {
      setState(() {
        _displayError(context, "Please make sure to fill all fields correctly");
      });

      return;
    }
    _formKey.currentState!.save();

    try {
      setState(() {
        _isAuthenticating = true;
      });

      final userCredentials = await _firebase.createUserWithEmailAndPassword(
          email: email, password: password);
      //connect the enterd user to its info

      final userId = userCredentials.user!.uid;

// Connect the entered user to its info with the user's ID
      dbref.child(theType).child(userId).set({
        'Name': name,
        'Email': email,
        'Password': password,
        'authentication document': fileName, // Remove the extra colon
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        setState(() {
          _isAuthenticating = false;
          _displayError(context, 'The password provided is too weak');

          return;
        });
      } else if (e.code == 'email-already-in-use') {
        setState(() {
          _isAuthenticating = false;

          _displayError(context, 'Email already in use');

          return;
        });
      }else if (e.code == 'invalid-email') {
        setState(() {
          _isAuthenticating = false;
          print(e);
          _displayError(context, 'Please enter a valid email');

          return;
        });
      } else {
        print(e);
        setState(() {
          _isAuthenticating = false;
          _displayError(context, "Error occured");

          return;
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        _isAuthenticating = false;

        _displayError(context, 'Error occured');

        return;
      });
    }
  }

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    if (result == null) return;
    final path = result.files.single.path!;

    setState(() {
      file = File(path);
      fileName = file != null ? basename(file!.path) : 'No File Selected';
      _fileController.text = fileName;
    });
  }

  Future uploadFile() async {
    if (file == null) return;
    final fileName = basename(file!.path);
    final destination = 'files/$fileName';

    task = FirebaseApi.uploadFile(destination, file!);
    setState(() {});

    if (task == null) return;

    final snapshot = await task!.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();

    print('Download-Link: $urlDownload');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // var fileName = file != null ? basename(file!.path) : 'No File Selected';
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
                          autovalidateMode: AutovalidateMode.always,
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            // mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              const SizedBox(
                                height: 50,
                              ),
                              SizedBox(height: screenHeight * .01),

                              // const Text(
                              //   'Welcome,',
                              //   style: TextStyle(
                              //     fontSize: 40,
                              //     fontWeight: FontWeight.bold,
                              //   ),
                              // ),
                              Container(
                                  height: 200,
                                  width: 300,
                                  child: Image.asset(
                                      'assets/Spo_site__1_-removebg-preview.png')),
                              SizedBox(height: screenHeight * .03),

                              Text(
                                'Sign up to continue',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black.withOpacity(.6),
                                ),
                              ),
                              const SizedBox(
                                height: 30,
                              ),

                              SizedBox(
                                width: MediaQuery.of(context).size.width *
                                    0.6, // Set the desired width
                                child: TextFormField(
                                  controller: _nameController,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Name',
                                    prefixIcon: Icon(Icons.person, size: 24),
                                  ),
                                  validator: (value) {
                                    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]')
                                            .hasMatch(value!) ||
                                        value.isEmpty) {
                                      return "Please enter a valid name";
                                    }
                                    if (value.length > 50) {
                                      return 'Name should be shorter than 50 characters';
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
                                    if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
                                            .hasMatch(value!) ||
                                        value.isEmpty) {
                                      return 'Please enter a valid email address';
                                    }
                                    return null; // Add this line to handle valid input
                                  },
                                ),
                              ),
                              const SizedBox(height: 25.0),
                              SizedBox(
                                width: MediaQuery.of(context).size.width *
                                    0.6, // Set the desired width
                                child: TextFormField(
                                  controller: _passwordController,
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
                                    if (value!.contains(' ')) {
                                      return 'Please enter a valid password';
                                    }
                                    if (value.isEmpty) {
                                      return 'Please enter your password';
                                    }

                                    if (value.length < 6 || value.length > 15) {
                                      return 'Password must between 6 and 15 characters';
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
                                  controller: _fileController,
                                  readOnly: true, // Link the controller
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Authentication document',
                                    prefixIcon:
                                        Icon(Icons.attach_file_sharp, size: 24),
                                    // suffixIcon: Padding(
                                    //   padding:
                                    // const EdgeInsets.fromLTRB(0, 0, 4, 0),
                                    // child: ElevatedButton.icon(
                                    //   style: ButtonStyle(
                                    //     // overlayColor: MaterialStateProperty.all(Colors.red),
                                    //     backgroundColor:
                                    //         MaterialStateProperty.all<Color>(
                                    //       const Color.fromARGB(
                                    //           255, 87, 11, 117),
                                    //     ), // Background color
                                    //     textStyle: MaterialStateProperty.all<
                                    //         TextStyle>(
                                    //       const TextStyle(fontSize: 0),
                                    //     ), // Text style
                                    //     padding: MaterialStateProperty.all<
                                    //         EdgeInsetsGeometry>(
                                    //       const EdgeInsets.symmetric(
                                    //           vertical: 8,
                                    //           horizontal: 10), // Padding
                                    //     ), // Padding
                                    //     elevation:
                                    //         MaterialStateProperty.all<double>(
                                    //             1), // Elevation
                                    //     shape: MaterialStateProperty.all<
                                    //         OutlinedBorder>(
                                    //       RoundedRectangleBorder(
                                    //         borderRadius: BorderRadius.circular(
                                    //             30), // Border radius
                                    //         side: const BorderSide(
                                    //           color: Color.fromARGB(
                                    //               255, 255, 255, 255),
                                    //         ), // Border color
                                    //       ),
                                    //     ),
                                    //     minimumSize:
                                    //         MaterialStateProperty.all<Size>(
                                    //             const Size(3, 3)),
                                    //   ),
                                    //   onPressed: () {
                                    //     selectFile();
                                    //   },
                                    //   icon: const Icon(
                                    //     Icons.attach_file,
                                    //     color:
                                    //         Color.fromARGB(255, 255, 255, 255),
                                    //   ),
                                    //   label: const Text(
                                    //     '',
                                    //     style: TextStyle(
                                    //         color: Color.fromARGB(
                                    //             255, 255, 255, 255)),
                                    //   ),
                                    //   // child: const Text(
                                    //   //     'Attatch File',
                                    //   //     style: TextStyle(
                                    //   //         color: Color.fromARGB(
                                    //   //             255, 255, 255, 255)),
                                    //   //   ),
                                    //   // const Icon(
                                    //   //   Icons.attach_file,
                                    //   //   size: 24,
                                    //   // ),
                                    // ),
                                  ),
                                  onTap: () {
                                    selectFile();
                                  },

                                  validator: (value) {
                                    if (value == 'No file selected') {
                                      return "Please select authentication document";
                                    }
                                    return null;
                                  },
                                ),
                              ),

                              const SizedBox(height: 25.0),
                              // Row(
                              //   children: [
                              //
                              //       ElevatedButton.icon(
                              //         onPressed: selectFile,
                              //         icon: const Icon(Icons.attach_file),
                              //         label: const Text(
                              //             'Attach authentication document'),
                              //       ),
                              //     const SizedBox(
                              //       width: 40,
                              //     ),
                              //
                              //       Container(
                              //         color: const Color.fromARGB(
                              //             116, 159, 172, 178),
                              //         child: Text(
                              //           fileName,
                              //           style: const TextStyle(
                              //             fontSize: 18,
                              //             fontWeight: FontWeight.w500,
                              //           ),
                              //         ),
                              //       ),
                              //   ],
                              // ),
                              const SizedBox(height: 8),

                              // Center(
                              //   child: Text(
                              //     errorMessage!, // Display the custom error message
                              //     style: const TextStyle(
                              //       color: Color.fromARGB(255, 97, 9, 3),
                              //       fontSize: 20,
                              //     ),
                              //   ),
                              // ),
                              const SizedBox(height: 10),

                              if (_isAuthenticating)
                                const CircularProgressIndicator(),
                              if (!_isAuthenticating)
                                ElevatedButton(
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                          Color.fromARGB(255, 51, 45, 81),
                                        ), // Background color
                                        textStyle: MaterialStateProperty.all<TextStyle>(
                                            const TextStyle(
                                                fontSize: 16)), // Text style
                                        padding:
                                            MaterialStateProperty.all<EdgeInsetsGeometry>(
                                                const EdgeInsets.all(
                                                    16)), // Padding
                                        elevation:
                                            MaterialStateProperty.all<double>(
                                                1), // Elevation
                                        shape: MaterialStateProperty.all<
                                            OutlinedBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                30), // Border radius
                                            // Border color
                                          ),
                                        ),
                                        minimumSize:
                                            MaterialStateProperty.all<Size>(
                                                const Size(200, 50))),
                                    onPressed: () {
                                      String name = _nameController.text;
                                      String email = _emailController.text;
                                      String password =
                                          _passwordController.text;

                                      print('Name: $name');
                                      print('Email: $email');
                                      print('Password: $password');
                                      print(
                                          'authentication document: $fileName');

                                      // if (errorMessage != null) {
                                      //   ScaffoldMessenger.of(context)
                                      //       .showSnackBar(
                                      //     SnackBar(
                                      //       content: Text(errorMessage!),
                                      //       backgroundColor: Color.fromARGB(
                                      //           255, 91, 79, 158),
                                      //       behavior: SnackBarBehavior.floating,
                                      //       margin: EdgeInsets.all(50),
                                      //       elevation: 30,
                                      //     ),
                                      //   );
                                      //   return;
                                      //   // Return or perform any other necessary action
                                      // }

                                      uploadFile();

                                      sendDatatoDB(name, email, password,
                                          fileName, context);

                                      /*   Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const SignIn()),
                                      ); */
                                      // if (errorMessage != null) {
                                      //   ScaffoldMessenger.of(context).showSnackBar(
                                      //     SnackBar(
                                      //       content: Text(errorMessage!),
                                      //       backgroundColor: const Color.fromARGB(
                                      //           255, 87, 11, 117),
                                      //       behavior: SnackBarBehavior.floating,
                                      //       margin: EdgeInsets.all(50),
                                      //       elevation: 30,
                                      //     ),
                                      //   );
                                      //   return; // Return or perform any other necessary action
                                      // }
                                    },
                                    child: const Text(
                                      'Sign Up',
                                      style: TextStyle(
                                          color: Color.fromARGB(
                                              255, 255, 255, 255),
                                          fontSize: 20),
                                    )),
                              const SizedBox(
                                height: 30,
                              ),
                              if (!_isAuthenticating)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('I already have an account'),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const SignIn(),
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        'Sign In',
                                        style: TextStyle(
                                          fontSize: 17,
                                          color:
                                              Color.fromARGB(255, 91, 79, 158),
                                        ),
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
