import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_leaningapp/FirebaseService/Firebase_Service.dart';
import 'package:e_leaningapp/Model/user_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileInformation extends StatefulWidget {
  final UserModel userModel;
  final FirebaseAuth auth;

  const EditProfileInformation({
    super.key,
    required this.userModel,
    required this.auth,
  });

  @override
  State<EditProfileInformation> createState() => _EditProfileInformationState();
}

class _EditProfileInformationState extends State<EditProfileInformation> {
  XFile? _imageFile;
  String? firstname;
  String? lastname;
  String? email;
  String? photoURL;
  String? uid;

  TextEditingController firstnameController = TextEditingController();
  TextEditingController lasttnameController = TextEditingController();
  TextEditingController shortdesciptionController = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  @override
  void initState() {
    super.initState();
    uid = widget.auth.currentUser!.uid;
    firstname = widget.userModel.firstName;
    lastname = widget.userModel.lastName;
    photoURL = widget.userModel.photoURL;

    firstnameController.text = firstname ?? '';
    lasttnameController.text = lastname ?? '';
  }

  Future<void> _pickImage() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        _imageFile = XFile(result.files.single.path!);
        _uploadImageAndSaveUrl(File(result.files.single.path!));
      });
    }
  }

  Future<void> _uploadImageAndSaveUrl(File imageFile) async {
    EasyLoading.show(status: 'Uploading...');
    String? downloadURL = await FirebaseService()
        .uploadImageToStorage(_imageFile!, 'user_images');
    if (downloadURL != null) {
      _saveImageUrlToFirestore(downloadURL);
    }
  }

  Future<void> _saveImageUrlToFirestore(String imageUrl) async {
    try {
      await firestore.collection('users').doc(uid).update({
        'photoURL': imageUrl,
      });
      setState(() {
        photoURL = imageUrl;
      });
    } catch (e) {
      print('Error saving image URL to Firestore: $e');
    } finally {
      EasyLoading.dismiss();
    }
  }

  Color myColor = Color.fromRGBO(31, 18, 56, 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
          left: 16.0,
          right: 16.0,
          bottom: 16.0,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.3,
                decoration: BoxDecoration(
                    color: myColor, borderRadius: BorderRadius.circular(15)),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => Get.back(),
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xff8a72f1),
                                ),
                                child: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const Text(
                              'Edit Profile',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[200],
                            ),
                            child: _imageFile != null
                                ? ClipOval(
                                    child: Image.file(
                                      File(_imageFile!
                                          .path), // Convert XFile to File
                                      fit: BoxFit.cover,
                                      width: 150,
                                      height: 150,
                                    ),
                                  )
                                : (photoURL != null
                                    ? ClipOval(
                                        child: Image.network(
                                          photoURL!,
                                          fit: BoxFit.cover,
                                          width: 150,
                                          height: 150,
                                        ),
                                      )
                                    : null),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: const CircleAvatar(
                                backgroundColor: Colors.white,
                                child: Icon(Icons.camera_alt),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ]),
              ),
              const SizedBox(height: 20),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: FormBuilderTextField(
                  maxLines: null,
                  name: 'Short Description',
                  controller: shortdesciptionController,
                  style: TextStyle(fontSize: 16.0, color: Colors.black),
                  decoration: const InputDecoration(
                    labelText: 'Short Description',
                    hintText: 'Enter a brief description...',
                    labelStyle: TextStyle(fontSize: 18.0, color: Colors.grey),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: FormBuilderTextField(
                        name: 'First Name',
                        controller: firstnameController,
                        style: TextStyle(fontSize: 16.0, color: Colors.black),
                        decoration: const InputDecoration(
                          labelText: 'First Name',
                          hintText: 'E.g., John',
                          labelStyle:
                              TextStyle(fontSize: 18.0, color: Colors.grey),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: FormBuilderTextField(
                        name: 'Last Name',
                        controller: lasttnameController,
                        style: const TextStyle(
                            fontSize: 16.0, color: Colors.black),
                        decoration: const InputDecoration(
                          labelText: 'Last Name',
                          hintText: 'E.g., Doe',
                          labelStyle:
                              TextStyle(fontSize: 18.0, color: Colors.grey),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.blueAccent,
                ),
                child: TextButton(
                  onPressed: () async {
                    if (firstnameController.text.isEmpty ||
                        lasttnameController.text.isEmpty) {
                      // Show a snackbar to request the user to input all required fields
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill in all fields.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } else {
                      EasyLoading.show(status: 'Uploading...');
                      await FirebaseService().updateUser(
                        uid: uid,
                        firstName: firstname,
                        lastName: lastname,
                        displayName: '$firstname ${lastname}',
                        shortDescription: shortdesciptionController.text,
                      );
                      EasyLoading.dismiss();

                      // Close the dialog after the update process is completed
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
