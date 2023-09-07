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
  final TextEditingController _fileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final DatabaseReference dbref = FirebaseDatabase.instance.reference();
  final _firebase = FirebaseAuth.instance;
  var type;

  String? nameErrorMessage;
  String? emailErrorMessage;
  String? passwordErrorMessage;

  UploadTask? task;
  File? file;
  // var fileName;

  final fileSnackBar = const SnackBar(
    content: Text('Please attach authentication document'),
  );

  void _toggleObscured() {
    setState(() {
      _obscured = !_obscured;
    });
  }

  String? _validateName(String? value) {
    if (_isLogin) return null; // No need to validate name during login
    if (value == null || value.trim().isEmpty) {
      setState(() {
        nameErrorMessage = 'Please enter your name nowwwww';
      });
      return nameErrorMessage;
    }

    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!value.contains('@')) {
      return 'Enter a valid email address';
    }
    if (value == 'email-already-in-use') {
      setState(() {
        nameErrorMessage = 'email already usedddd';
      });
      return nameErrorMessage;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  void sendDatatoDB(BuildContext context, String name, String email,
      String password, String fileName) async {
    setState(() {
      nameErrorMessage = null;
      emailErrorMessage = null;
      passwordErrorMessage = null;
    });
    final isValid = _formKey.currentState!.validate();

    // if (!isValid) {
    //   ScaffoldMessenger.of(context as BuildContext).showSnackBar(
    //     const SnackBar(
    //       content: Text("Please make sure to fill all fields correctly"),
    //     ),
    //   );
    // }
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
        print('The password provided is too weak.');
        setState(() {
          _isAuthenticating = false;
        });
      } else if (e.code == 'email-already-in-use') {
        _validateEmail(e.code);
        setState(() {
          _isAuthenticating = false;
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        _isAuthenticating = false;
      });
    }
    // } on FirebaseAuthException catch (error) {
    //   print("error 111111111111111111");
    //   print(error.code);
    //   if (error.code == 'email-already-in-use') {
    //     _validateEmail(error.code);
    //   }
    //   // ScaffoldMessenger.of(context as BuildContext).clearSnackBars();
    //   // ScaffoldMessenger.of(context as BuildContext).showSnackBar(
    //   //   SnackBar(
    //   //     content: Text(error.message ?? 'Authentication failed.'),
    //   //   ),
    //   // );
    //   setState(() {
    //     _isAuthenticating = false;
    //   });
    // }

    //show error message
  }

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    if (result == null) return;
    final path = result.files.single.path!;

    setState(() => file = File(path));
    // fileName = file != null ? basename(file!.path) : 'No File Selected';
    // _fileController.text = fileName;
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
    final fileName = file != null ? basename(file!.path) : 'No File Selected';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sponsee Registration'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (!_isLogin)
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            type = 'Sponsors';
                          });
                        },
                        child: const Text("I'm a Sponsor"),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            type = 'Sponsees';
                          });
                        },
                        child: const Text("I'm a Sponsee"),
                      )
                    ],
                  ),
                if (!_isLogin)
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Name',
                    ),

                    validator: _validateName,

                    // (value) {
                    //   if (value == null || value.trim().isEmpty) {
                    //     return "Please enter name";
                    //   }
                    //   return null;
                    // },
                  ),
                if (nameErrorMessage != null)
                  Text(
                    nameErrorMessage!, // Display the custom error message
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12.0,
                    ),
                  ),
                const SizedBox(height: 16.0),
                TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Email Address'),
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    textCapitalization: TextCapitalization.none,
                    validator: _validateEmail
                    //  (value) {
                    //   if (value == null ||
                    //       value.trim().isEmpty ||
                    //       !value.contains("@")) {
                    //     return "Please enter a valid email address";
                    //   }
                    //   return null;
                    // },
                    ),
                  if (emailErrorMessage != null)
                  Text(
                    emailErrorMessage!, // Display the custom error message
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12.0,
                    ),
                  ),
                const SizedBox(height: 16.0),
                TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: 'Password',
                      // prefixIcon: Icon(Icons.lock_rounded, size: 24),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
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
                    validator: _validatePassword
                    //  (value) {
                    //   if (value == null || value.trim().length < 6) {
                    //     return "Password must be at least 6 characters long";
                    //   }
                    //   return null;
                    // },
                    ),
                  if (passwordErrorMessage != null)
                  Text(
                    passwordErrorMessage!, // Display the custom error message
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12.0,
                    ),
                  ),
                const SizedBox(height: 16.0),
                // TextFormField(
                //   decoration: InputDecoration(
                //     border: OutlineInputBorder(),
                //     labelText: 'Authentication document',
                //     suffixIcon: Padding(
                //       padding: EdgeInsets.fromLTRB(0, 0, 4, 0),
                //       child: GestureDetector(
                //         onTap: selectFile,
                //         child: const Icon(
                //           Icons.attach_file,
                //           size: 24,
                //         ),
                //       ),
                //     ),
                //   ),
                //   //initialValue:fileName,
                //   controller: _fileController,

                //   readOnly: true,
                //   validator: (value) {
                //     if (value == null) {
                //       print("hello1");
                //       return "Please select authentication document";
                //     }
                //     return null;
                //   },
                // ),
                const SizedBox(
                  height: 12,
                ),
                const SizedBox(height: 20.0),
                Row(
                  children: [
                    if (!_isLogin)
                      ElevatedButton.icon(
                        onPressed: selectFile,
                        icon: const Icon(Icons.attach_file),
                        label: const Text('Attach authentication document'),
                      ),
                    const SizedBox(
                      width: 40,
                    ),
                    if (!_isLogin)
                      Container(
                        color: const Color.fromARGB(116, 159, 172, 178),
                        child: Text(
                          fileName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
                // const SizedBox(height: 8),

                const SizedBox(height: 48),
                /* ElevatedButton(
                  onPressed: uploadFile,
                  child: Text('Upload authentication document'),
                ),
                SizedBox(height: 20), */
                if (_isAuthenticating) const CircularProgressIndicator(),
                if (!_isAuthenticating)
                  ElevatedButton(
                    onPressed: () {
                      String name = _nameController.text;
                      String email = _emailController.text;
                      String password = _passwordController.text;

                      print('Name: $name');
                      print('Email: $email');
                      print('Password: $password');
                      print('authentication document: $fileName');

                      if (!_isLogin) {
                        if (fileName == 'No File Selected') {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(fileSnackBar);
                          return;
                        }
                        uploadFile();
                      }

                      sendDatatoDB(context, name, email, password, fileName);
                    },
                    child: Text(_isLogin ? 'Sign In' : 'Sign Up'),
                  ),
                if (!_isAuthenticating)
                  Row(
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
                        child: Text(_isLogin ? 'Sign Up' : 'Sign In'),
                      )
                    ],
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
