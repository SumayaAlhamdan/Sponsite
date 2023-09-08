import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path/path.dart';
import '../FirebaseApi.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen> {
  bool _obscured = true;
  var _isLogin = false;
  var _isAuthenticating = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _fileController =
      TextEditingController(text: 'No file selected');
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final DatabaseReference dbref = FirebaseDatabase.instance.reference();
  final _firebase = FirebaseAuth.instance;
  var type;

  bool sponseeSelected = false;
  bool sponsorSelected = false;
  bool _didChoose = false;
  var fileName = 'No File Selected';
  MaterialColor _sponseeBorder=Colors.grey;
  MaterialColor _sponsorBorder=Colors.grey;
  String? errorMessage;

  UploadTask? task;
  File? file;

  void _toggleObscured() {
    setState(() {
      _obscured = !_obscured;
    });
  }

  void sendDatatoDB(BuildContext context, String name, String email,
      String password, String fileName) async {
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

      if (_isLogin) {
        final userCredentials = await _firebase.signInWithEmailAndPassword(
            email: email, password: password);
      } else {
        final userCredentials = await _firebase.createUserWithEmailAndPassword(
            email: email, password: password);
        //connect the enterd user to its info

        final userId = userCredentials.user!.uid;

// Connect the entered user to its info with the user's ID
        dbref.child(type).child(userId).set({
          'Name': name,
          'Email': email,
          'Password': password,
          'authentication document': fileName, // Remove the extra colon
        });
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        setState(() {
          _isAuthenticating = false;
          errorMessage = 'The password provided is too weak';
        });
      } else if (e.code == 'email-already-in-use') {
        setState(() {
          _isAuthenticating = false;
          errorMessage = 'Email already in use';
        });
      } else if (e.code == 'user-not-found' || e.code == 'wrong-password') {
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
                            if (!_isLogin)
                              const Text(
                                'Welcome,',
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            SizedBox(height: screenHeight * .01),
                            if (!_isLogin)
                              Text(
                                'Choose account type',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black.withOpacity(.6),
                                ),
                              ),
                            const SizedBox(
                              height: 20,
                            ),
                            if (!_isLogin)
                              Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Card(
                                      elevation: 1,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        side:  BorderSide(
                                          color: _sponsorBorder,
                                          // Colors.grey,
                                          width: 4,
                                        ),
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            _didChoose = true;
                                            sponseeSelected = false;
                                            sponsorSelected = true;
                                            _sponsorBorder= Colors.deepPurple;
                                            _sponseeBorder=Colors.grey;
                                            type = 'Sponsors';
                                          });
                                        },
                                        child: Stack(
                                          children: [
                                            Container(
                                              width: 180,
                                              height: 215,
                                              padding: const EdgeInsets.all(8),
                                              child: Image.asset(
                                                "assets/6-removebg-preview.png",
                                                fit: BoxFit.scaleDown,
                                                height: 1,
                                                width: 1,
                                              ),
                                            ),
                                            // if (sponsorSelected)
                                            //   const Positioned(
                                            //     bottom: 1,
                                            //     right: 4,
                                            //     child: Icon(
                                            //       Icons.check_circle_rounded,
                                            //       color: Color.fromARGB(
                                            //           255, 135, 181, 103),
                                            //       size: 40,
                                            //     ),
                                            //   ),
                                            const Positioned(
                                                bottom: -5,
                                                right: 0,
                                                left: 56,
                                                child: Text(
                                                  'Sponsor',
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w300),
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
                                        side:  BorderSide(
                                          color: _sponseeBorder,
                                          //Colors.grey,
                                          width: 4,
                                        ),
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            _didChoose = true;
                                            sponseeSelected = true;
                                            sponsorSelected = false;
                                            _sponseeBorder= Colors.deepPurple;
                                            _sponsorBorder=Colors.grey;
                                            type = 'Sponsees';
                                          });
                                        },
                                        child: Stack(
                                          children: [
                                            Container(
                                              width: 180,
                                              height: 215,
                                              padding: const EdgeInsets.all(8),
                                              child: Image.asset(
                                                "assets/5-removebg-preview.png",
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            // if (sponseeSelected)
                                            //   const Positioned(
                                            //     bottom: 1,
                                            //     right: 4,
                                            //     child: Icon(
                                            //       Icons.circle_rounded,
                                            //       color: Color.fromARGB(
                                            //           255, 135, 181, 103),
                                            //       size: 40,
                                            //     ),
                                            //   ),
                                            const Positioned(
                                                bottom: -5,
                                                right: 0,
                                                left: 56,
                                                child: Text(
                                                  'Sponsee',
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w300),
                                                ))
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 30),
                            if (!_isLogin)
                              SizedBox(
                                width: MediaQuery.of(context).size.width *
                                    0.7, // Set the desired width
                                child: TextFormField(
                                  controller: _nameController,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Name',
                                    prefixIcon: Icon(Icons.person, size: 24),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return "Please enter name";
                                    }
                                    return null;
                                  },
                                ),
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
                                  }
                                },
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            if (!_isLogin)
                              SizedBox(
                                width: MediaQuery.of(context).size.width *
                                    0.7, // Set the desired width
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    border: const OutlineInputBorder(),
                                    labelText: 'Authentication document',
                                    prefixIcon: Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(0, 0, 4, 0),
                                      child: GestureDetector(
                                        onTap: selectFile,
                                        child: ElevatedButton(
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(
                                              const Color.fromARGB(
                                                  255, 87, 11, 117),
                                            ), // Background color
                                            textStyle: MaterialStateProperty
                                                .all<TextStyle>(
                                              const TextStyle(fontSize: 13),
                                            ), // Text style
                                            padding: MaterialStateProperty.all<
                                                EdgeInsetsGeometry>(
                                              const EdgeInsets.symmetric(
                                                  vertical: 2,
                                                  horizontal: 4), // Padding
                                            ), // Padding
                                            elevation: MaterialStateProperty
                                                .all<double>(1), // Elevation
                                            shape: MaterialStateProperty.all<
                                                OutlinedBorder>(
                                              RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        7), // Border radius
                                                side: const BorderSide(
                                                  color: Color.fromARGB(
                                                      255, 255, 255, 255),
                                                ), // Border color
                                              ),
                                            ),
                                            minimumSize:
                                                MaterialStateProperty.all<Size>(
                                                    const Size(10, 10)),
                                          ),
                                          onPressed: () {
                                            // selectFile;
                                          },
                                          child: const Text(
                                            'Attatch File',
                                            style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 255, 255, 255)),
                                          ),
                                          // const Icon(
                                          //   Icons.attach_file,
                                          //   size: 24,
                                          // ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  controller:
                                      _fileController, // Link the controller
                                  readOnly: true,
                                  validator: (value) {
                                    if (value == 'No file selected') {
                                      print("hello1");
                                      return "Please select authentication document";
                                    }
                                    return null;
                                  },
                                ),
                              ),

                            const SizedBox(height: 10.0),
                            // Row(
                            //   children: [
                            //     if (!_isLogin)
                            //       ElevatedButton.icon(
                            //         onPressed: selectFile,
                            //         icon: const Icon(Icons.attach_file),
                            //         label: const Text(
                            //             'Attach authentication document'),
                            //       ),
                            //     const SizedBox(
                            //       width: 40,
                            //     ),
                            //     if (!_isLogin)
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
                                            const Color.fromARGB(
                                                255, 87, 11, 117)), // Background color
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
                                  String name = _nameController.text;
                                  String email = _emailController.text;
                                  String password = _passwordController.text;

                                  print('Name: $name');
                                  print('Email: $email');
                                  print('Password: $password');
                                  print('authentication document: $fileName');
                                  if (errorMessage != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(errorMessage!),
                                      ),
                                    );
                                    return; // Return or perform any other necessary action
                                  }
                                  if (!_isLogin) {
                                    // if (fileName == 'No File Selected') {
                                    // setState(() {
                                    //   errorMessage =
                                    //       'Please attach authentication document';
                                    // });
                                    // ScaffoldMessenger.of(context)
                                    //     .showSnackBar(fileSnackBar);
                                    // return;
                                    // }
                                    //else
                                    if (!_didChoose) {
                                      setState(() {
                                        errorMessage =
                                            'Please choose user type';
                                      });
                                      return;
                                    }
                                    uploadFile();
                                  }

                                  sendDatatoDB(
                                      context, name, email, password, fileName);
                                },
                                child: Text(
                                  _isLogin ? 'Sign In' : 'Sign Up',
                                  style: const TextStyle(
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
                                  Text(_isLogin
                                      ? "Dont have an account?"
                                      : 'I already have an account'),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _isLogin = !_isLogin;
                                      });
                                    },
                                    child: Text(
                                      _isLogin ? 'Sign Up' : 'Sign In',
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
