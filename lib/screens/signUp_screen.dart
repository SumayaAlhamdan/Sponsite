import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';

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
  bool weakPass = false;
  bool emailUsed = false;
  bool invalidEmail = false;
  bool bigFile = false;
  bool emailWait = false;
  bool emailRejected = false;
    bool emailDeactivated = false;
  var fileName = 'No File Selected';



  UploadTask? task;
  File? file;

 

  void _toggleObscured() {
    setState(() {
      _obscured = !_obscured;
    });
  }
  void showAlertDialog(BuildContext context) async{
      showDialog(
      context: context,
      builder: (BuildContext context) {
        return Theme(
            data:
                Theme.of(context).copyWith(dialogBackgroundColor: Colors.white),
            child: AlertDialog(
              title: const Text('Your request has been sent', style: TextStyle(fontSize: 30),),
              // backgroundColor: Colors.white,
              content: const Text(
                'Please wait for an approval/rejected email from our\nsupport team.',
                style: TextStyle(fontSize: 20),
              ),
              actions: [
                TextButton(
                  onPressed: ()  {
            Navigator.of(context).pop();
                  },
                  child: Text(
                    'OK',
                    style: TextStyle(color: Color.fromARGB(255, 51, 45, 81),fontSize: 18),
                  ),
                ),  
              ],
            ));
      },
    );
  }

  void sendDatatoDB(String name, String email, String password, String fileName,
      context) async {
    final isValid = _formKey.currentState!.validate();
   var keySponsee;
    var keySponsor;
    if (!isValid) {
      return;
    }
    _formKey.currentState!.save();

    try {
       setState(() {
        _isAuthenticating = true;
      });
  
      DatabaseEvent? emailSnapshot = await dbref.child("newUsers")
        .orderByChild('Email')
        .equalTo(email)
        .once();

       final RejectedSponsors= await dbref.child("rejectedSponsors")
        .orderByChild('Email')
        .equalTo(email)
        .once();


         final RejectedSponsees = await dbref.child("rejectedSponsees")
        .orderByChild('Email')
        .equalTo(email)
        .once();

   final deactivatedSponsors= await dbref.child("DeactivatedSponsors")
        .orderByChild('Email')
        .equalTo(email)
        .once();


         final deactivatedSponsees = await dbref.child("DeactivatedSponsees")
        .orderByChild('Email')
        .equalTo(email)
        .once();

      if (emailSnapshot.snapshot.value != null && ((theType=="Sponsor" && RejectedSponsors.snapshot.value == null) || (theType=="Sponsee" && RejectedSponsees.snapshot.value == null)) && ((theType=="Sponsor" && deactivatedSponsors.snapshot.value == null) || (theType=="Sponsee" && deactivatedSponsees.snapshot.value == null) )) {
        // The email already exists in the "new users" list
        setState(() {
          _isAuthenticating = false;
          emailWait = true;
          emailRejected = false;
           emailDeactivated = false;
        });
        return;
      }
        else if ((RejectedSponsors.snapshot.value != null && theType=="Sponsor")|| (RejectedSponsees.snapshot.value != null && theType=="Sponsee")) {
        // The email already exists in the "new users" list
        setState(() {
          _isAuthenticating = false;
          emailRejected = true;
          emailWait = false;
          emailDeactivated = false;
        });
        return;
      }
        else if ((deactivatedSponsors.snapshot.value != null && theType=="Sponsor")|| (deactivatedSponsees.snapshot.value != null && theType=="Sponsee")) {
        // The email already exists in the "new users" list
        setState(() {
          _isAuthenticating = false;
          emailDeactivated = true;
           emailWait = false;
           emailRejected = false;
        });
        return;
      }
      else if ((RejectedSponsees.snapshot.value != null && theType=="Sponsor")) {

        // The email already exists in the "new users" list
        final userId = keySponsee;
        print(userId);
        await dbref.child("newUsers").child(userId!).set({
        'Name': name,
        'Email': email,
        'Social Media':null,
        'Picture':'https://firebasestorage.googleapis.com/v0/b/sponsite-6a696.appspot.com/o/user_images%2FCrHfFHgX0DNzwmVmwXzteQNuGRr1%2FCrHfFHgX0DNzwmVmwXzteQNuGRr1.jpg?alt=media&token=4e08e9f5-d526-4d2c-817b-11f9208e9b52',
        'authentication document': fileName,
        'Status': 'Inactive',
        'Type': theType,
         // Remove the extra colon
      });
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).popUntil((route) => route.isFirst);
       showAlertDialog(context);

   }
       else if ((RejectedSponsors.snapshot.value != null && theType=="Sponsee")) {
    
        final Map<dynamic, dynamic> eventData = RejectedSponsors.snapshot.value as Map<dynamic, dynamic>;
          for (var key in eventData.keys) {
            if (eventData[key]['Email'] == email) {
              keySponsor = key;
            }
          }
        final userId = keySponsor;
        await dbref.child("newUsers").child(userId!).set({
        'Name': name,
        'Email': email,
        'Social Media':null,
        'Picture':'https://firebasestorage.googleapis.com/v0/b/sponsite-6a696.appspot.com/o/user_images%2FCrHfFHgX0DNzwmVmwXzteQNuGRr1%2FCrHfFHgX0DNzwmVmwXzteQNuGRr1.jpg?alt=media&token=4e08e9f5-d526-4d2c-817b-11f9208e9b52',
        'authentication document': fileName,
        'Status': 'Inactive',
        'Type': theType,
        'Rate': '0',
         // Remove the extra colon
      });

        await FirebaseAuth.instance.signOut();
      Navigator.of(context).popUntil((route) => route.isFirst);
       showAlertDialog(context);

   }
    else if ((deactivatedSponsors.snapshot.value != null && theType=="Sponsee")) {
    
        final Map<dynamic, dynamic> eventData = RejectedSponsors.snapshot.value as Map<dynamic, dynamic>;
          for (var key in eventData.keys) {
            if (eventData[key]['Email'] == email) {
              keySponsor = key;
            }
          }
        final userId = keySponsor;
        await dbref.child("newUsers").child(userId!).set({
        'Name': name,
        'Email': email,
        'Social Media':null,
        'Picture':'https://firebasestorage.googleapis.com/v0/b/sponsite-6a696.appspot.com/o/user_images%2FCrHfFHgX0DNzwmVmwXzteQNuGRr1%2FCrHfFHgX0DNzwmVmwXzteQNuGRr1.jpg?alt=media&token=4e08e9f5-d526-4d2c-817b-11f9208e9b52',
        'authentication document': fileName,
        'Status': 'Inactive',
        'Type': theType,
        'Rate':'0'
         // Remove the extra colon
      });

        await FirebaseAuth.instance.signOut();
      Navigator.of(context).popUntil((route) => route.isFirst);
       showAlertDialog(context);

   }
   else if ((deactivatedSponsees.snapshot.value != null && theType=="Sponsor")) {
    
        final Map<dynamic, dynamic> eventData = RejectedSponsors.snapshot.value as Map<dynamic, dynamic>;
          for (var key in eventData.keys) {
            if (eventData[key]['Email'] == email) {
              keySponsor = key;
            }
          }
        final userId = keySponsor;
        await dbref.child("newUsers").child(userId!).set({
        'Name': name,
        'Email': email,
        'Social Media':null,
        'Picture':'https://firebasestorage.googleapis.com/v0/b/sponsite-6a696.appspot.com/o/user_images%2FCrHfFHgX0DNzwmVmwXzteQNuGRr1%2FCrHfFHgX0DNzwmVmwXzteQNuGRr1.jpg?alt=media&token=4e08e9f5-d526-4d2c-817b-11f9208e9b52',
        'authentication document': fileName,
        'Status': 'Inactive',
        'Type': theType,
        'Rate':'0',
         // Remove the extra colon
      });

        await FirebaseAuth.instance.signOut();
      Navigator.of(context).popUntil((route) => route.isFirst);
       showAlertDialog(context);

   }
      else{
      final userCredentials = await _firebase.createUserWithEmailAndPassword(
          email: email, password: password);
      //connect the enterd user to its info

      final userId = userCredentials.user!.uid;

// Connect the entered user to its info with the user's ID
    await dbref.child("newUsers").child(userId).set({
        'Name': name,
        'Email': email,
        'Social Media':null,
        'Picture':'https://firebasestorage.googleapis.com/v0/b/sponsite-6a696.appspot.com/o/user_images%2FCrHfFHgX0DNzwmVmwXzteQNuGRr1%2FCrHfFHgX0DNzwmVmwXzteQNuGRr1.jpg?alt=media&token=4e08e9f5-d526-4d2c-817b-11f9208e9b52',
        'authentication document': fileName,
        'Status': 'Inactive',
        'Type': theType,
        'Rate':'0',
      });
       await FirebaseAuth.instance.signOut();
       Navigator.of(context).popUntil((route) => route.isFirst);
      showAlertDialog(context);

    }}on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        setState(() {
          _isAuthenticating = false;
          weakPass = true;
          return;
        });
      } else if (e.code == 'email-already-in-use') {
        setState(() {
          _isAuthenticating = false;
          emailUsed = true;
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

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    if (result == null) return;
    final path = result.files.single.path!;
    final fileSize = File(path).lengthSync();

    const fileSizeLimit = 1 * 1024 * 1024;

    if (fileSize > fileSizeLimit) {
      setState(() {
        bigFile=true;

      });
      return;
    }

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
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            // mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              const SizedBox(
                                height: 50,
                              ),
                              SizedBox(height: screenHeight * .01),
                              SizedBox(
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
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  controller: _nameController,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Name',
                                    prefixIcon: Icon(Icons.person, size: 24),
                                  ),
                                  // inputFormatters: [
                                  //   FilteringTextInputFormatter(
                                  //       RegExp(r'^[A-Za-z0-9\s]+$'),
                                  //       allow: true)
                                  // ],
                                  validator: (value) {
                                    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]')
                                            .hasMatch(value!) ||
                                        value.isEmpty) {
                                      return "Please enter a valid name with no special characters";
                                    }
                                    if (value.length > 30) {
                                      return 'Name should not exceed 30 characters';
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
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
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
                                  /* inputFormatters: [
                                    FilteringTextInputFormatter(
                                        RegExp(
                                            r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$'),
                                        allow: true)
                                  ],*/
                                  validator: (value) {
                                    if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
                                            .hasMatch(value!) ||
                                        value.isEmpty) {
                                      return 'Please enter a valid email address';
                                    }
                                    if (emailUsed) {
                                      return 'Email already in use';
                                    }
                                    if (invalidEmail) {
                                      return 'Please enter a valid email';
                                    }

                                       if (emailWait) {
                                      return 'You have sign up already, wait for approval/rejection email';
                                    }
                                       if (emailRejected) {
                                      return 'Your email has been rejected, contact @sponsiteApp@Gmail.com for help';
                                    }
                                 if (emailDeactivated) {
                                      return 'Your email has been deactivated, contact @sponsiteApp@Gmail.com for help';
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
                                  inputFormatters: [
                                    FilteringTextInputFormatter.deny(
                                        RegExp(r'[\s]')),
                                    LengthLimitingTextInputFormatter(15),
                                  ],
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
                                    if (weakPass) {
                                      return 'The password provided is too weak';
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
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  readOnly: true, // Link the controller
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Authentication document',
                                    prefixIcon:
                                        Icon(Icons.attach_file_sharp, size: 24),
                                  ),
                                  onTap: () {
                                    selectFile();
                                  },

                                  validator: (value) {
                                    if (value == 'No file selected') {
                                      return "Please select authentication document";
                                    }
                                    if(bigFile){
                                      return "The selected file exceeds the size limit (1MB).";
                                    }

                                    return null;
                                  },
                                ),
                              ),
                             
                              const SizedBox(height: 25.0),
                              const SizedBox(height: 8),
                              const SizedBox(height: 10),
                              if (_isAuthenticating)
                                const CircularProgressIndicator(),
                              if (!_isAuthenticating)
                                ElevatedButton(
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                          const Color.fromARGB(255, 51, 45, 81),
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
                                      //autovalidateMode: AutovalidateMode.always;
                                      String name = _nameController.text;
                                      String email = _emailController.text.trim();
                                      String password =
                                          _passwordController.text.trim();

                                      print('Name: $name');
                                      print('Email: $email');
                                      print('Password: $password');
                                      print(
                                          'authentication document: $fileName');

                                      uploadFile();
                                      setState(() {
                                        weakPass=false;
                                        invalidEmail=false;
                                        emailUsed=false;
                                        emailWait=false;
                                      });
                                      sendDatatoDB(name, email, password,
                                          fileName, context);
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
                                        Navigator.of(context)
                                            .popUntil((route) => route.isFirst);
                                      },
                                      child: const Text(
                                        'Sign In',
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

