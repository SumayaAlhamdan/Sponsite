import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  UserImagePicker(
    this.profilePic, {
    super.key,
    required this.onPickImage,
  });

  final void Function(File pickedImage) onPickImage;
  String profilePic;
  @override
  State<UserImagePicker> createState() {
    return _UserImagePickerState(profilePic);
  }
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _pickedImageFile;
  var pickedImage;
  String? pic;
  _UserImagePickerState(picture) {
    pic = picture;
  }
  void _pickImage() async {
    pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 150,
    );

    if (pickedImage == null) {
      return;
    }

    setState(() {
      _pickedImageFile = File(pickedImage.path);
    });

    widget.onPickImage(_pickedImageFile!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 70,
              backgroundColor: Colors.grey,
              foregroundImage: _pickedImageFile != null
                  ? FileImage(_pickedImageFile!)
                  : null,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      fit: BoxFit.cover, image: NetworkImage(pic!)

                      // sponseeList.first.pic != ""? NetworkImage(sponseeList.first.pic) :AssetImage("assets/ksuCPCLogo.png")
                      ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: CircleAvatar(
                  radius: 25,
                  backgroundColor: Color.fromARGB(255, 224, 224, 224),
                  child: GestureDetector(
                    child: const Icon(
                      Icons.add_a_photo,
                      size: 30,
                      color: Color.fromARGB(255, 91, 79, 158),
                    ),
                    onTap: () {
                      _pickImage();
                    },
                  )
                  // Container(
                  //   margin: const EdgeInsets.all(8.0),
                  //   decoration: const BoxDecoration(
                  //       color: Colors.green, shape: BoxShape.circle),
                  // ),
                  ),
            ),
          ],
        ),
        // TextButton.icon(
        //   onPressed: _pickImage,
        //   icon: const Icon(Icons.image),
        //   label: Text(
        //     'Add Image',
        //     style: TextStyle(
        //       color: Theme.of(context).colorScheme.primary,
        //     ),
        //   ),
        // )
      ],
    );
  }
}
