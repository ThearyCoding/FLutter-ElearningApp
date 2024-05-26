import 'dart:convert';
import 'dart:io';
import 'package:e_leaningapp/FirebaseService/Firebase_Service.dart';
import 'package:e_leaningapp/local_storage/user_authentication_local_storage.dart';
import 'package:e_leaningapp/utils/file_picker_utils.dart';
import 'package:e_leaningapp/widgets/bottom_navbar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:e_leaningapp/FirebaseService/auth_service_google.dart';
import 'package:e_leaningapp/FirebaseService/auth_service_facebook.dart';
import 'package:http/http.dart' as http;

class CompleteInformations extends StatefulWidget {
  const CompleteInformations({Key? key}) : super(key: key);

  @override
  State<CompleteInformations> createState() => _CompleteInformationsState();
}

class _CompleteInformationsState extends State<CompleteInformations> {
  final AuthServiceGoogle authServiceGoogle = AuthServiceGoogle(); // -> google
  final AuthServiceFacebook authServiceFacebook =
      AuthServiceFacebook(); // -> facebook

  final FirebaseService firebaseService = FirebaseService();
  String? lastName;
  String? firstName;
  String? _selectedGender;
  DateTime? _selectedDate = DateTime(2006, 1, 5);
  TextEditingController firstnameController = TextEditingController();
  TextEditingController lasttnameController = TextEditingController();
  final List<String> genders = ['Male', 'Female'];
  void _populateTextFields() {
    if (firstnameController.text.isEmpty) {
      firstnameController.text = firstName ?? '';
    }

    if (lasttnameController.text.isEmpty) {
      lasttnameController.text = lastName ?? '';
    }
  }

  String? displayName;
  String? email;
  String? photoURL;
  User? _currentUser;
  bool signedInWithGoogle = false;
  bool signedInWithFacebook = false;
  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    signedInWithGoogle = authServiceGoogle.isSignedInWithGoogle(_currentUser!);

    // Check if the user is signed in with Facebook
    signedInWithFacebook =
        authServiceFacebook.isSignedInWithFacebook(_currentUser!);

    // Perform sign-out based on the authentication provider
    if (signedInWithGoogle) {
      print('User logged in with Google');
      // User logged in with Google

      displayName = _currentUser!.displayName;
      email = _currentUser!.email;
      photoURL = _currentUser!.photoURL;
      // Extract first and last name
      final displayNameParts = _currentUser!.displayName?.split(' ') ?? [];
      if (displayNameParts.isNotEmpty) {
        lastName = displayNameParts.last;
      }
      if (displayNameParts.isNotEmpty) {
        firstName = displayNameParts.first;
      }
    } else if (signedInWithFacebook) {
      _populateFacebookUserDetails();
      print('User logged in with Facebook');
    } else {
      // Handle other authentication providers or scenarios
    }
    _populateTextFields();
  }

  Future<void> _populateFacebookUserDetails() async {
    final accessToken = await FacebookAuth.instance.accessToken;
    if (accessToken != null) {
      final graphResponse = await http.get(Uri.parse(
          'https://graph.facebook.com/v2.12/me?fields=name,picture.width(800).height(800),first_name,last_name,email&access_token=${accessToken.token}'));

      if (graphResponse.statusCode == 200) {
        final profileData = jsonDecode(graphResponse.body);

        setState(() {
          displayName = profileData['name'];
          email = profileData['email'];
          photoURL = profileData['picture']['data']['url'];

          // Extract first and last name
          final displayNameParts = displayName?.split(' ') ?? [];
          if (displayNameParts.isNotEmpty) {
            lastName = displayNameParts.last;
          }
          if (displayNameParts.isNotEmpty) {
            firstName = displayNameParts.first;
          }
          _populateTextFields();
        });
      } else {
        print('Failed to fetch profile data from Facebook Graph API.');
      }
    } else {
      print('Facebook access token is null.');
    }
  }

  final LocalStorageSharedPreferences localStorageController =
      Get.find<LocalStorageSharedPreferences>();
  XFile? _imageFile;

  Future<void> _pickImage() async {
    XFile? image = await FilePickerUtils.pickImage(context);
    if (image != null) {
      setState(() {
        _imageFile = image;
      });
    }
  }

  final FirebaseStorage storage = FirebaseStorage.instance;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate!,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue, // Header background color
              onPrimary: Colors.white, // Header  textcolor
              surface: Colors.white, // Background color
              onSurface: Colors.black, // Text color
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Information'),
        actions: [
          IconButton(
              tooltip: 'Sign Out',
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              icon: Icon(Icons.exit_to_app))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Hey $lastName!"),
              const Text("You're applying for E-Learning"),
              const SizedBox(height: 20),
              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: _imageFile != null
                          ? DecorationImage(
                              image: FileImage(File(_imageFile!.path)),
                              fit: BoxFit.cover,
                            )
                          : (photoURL != null
                              ? DecorationImage(
                                  image: NetworkImage(photoURL!),
                                  fit: BoxFit.cover,
                                )
                              : null),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(30),
                      child: Ink(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () async {
                            await _pickImage();
                          },
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.black,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: firstnameController,
                  style: const TextStyle(fontSize: 16.0, color: Colors.black),
                  decoration: const InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                    labelText: 'First Name',
                    hintText: 'E.g., Chorn',
                    labelStyle: TextStyle(fontSize: 18.0, color: Colors.grey),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: lasttnameController,
                  style: const TextStyle(fontSize: 16.0, color: Colors.black),
                  decoration: const InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                    labelText: 'Last Name',
                    hintText: 'E.g., Theary',
                    labelStyle: TextStyle(fontSize: 18.0, color: Colors.grey),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                      child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 7.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _selectedGender,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedGender = newValue;
                        });
                      },
                      items: genders.map((String gender) {
                        return DropdownMenuItem<String>(
                          value: gender,
                          child: Text(
                            gender,
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        );
                      }).toList(),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        labelText: 'Select Gender',
                        labelStyle: TextStyle(
                          fontSize: 18.0,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  )),
                ],
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Date of Birth',
                            border: InputBorder.none, // Remove the border
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                          controller: TextEditingController(
                            text: _selectedDate != null
                                ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                : '',
                          ),
                          readOnly: true, // Make the field read-only
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(
                            context), // Trigger date picker function
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (firstnameController.text.isEmpty ||
                        lasttnameController.text.isEmpty ||
                        _selectedGender == null ||
                        _selectedDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill in all fields.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } else {
                      try {
                        EasyLoading.show(status: 'Uploading...');
                        if (_imageFile != null) {
                          photoURL = await firebaseService.uploadImageToStorage(
                              _imageFile!, 'image_user_profiles');
                        }

                        // Update user information in Firestore based on the authentication provider
                        if (signedInWithGoogle) {
                          // ignore: use_build_context_synchronously
                          authServiceGoogle.updateUserInFirestore(
                            context,
                            _currentUser!.uid,
                            displayName,
                            email,
                            photoURL,
                            firstnameController.text,
                            lasttnameController.text,
                            _selectedGender!,
                            _selectedDate!,
                          );
                        }
                        if (signedInWithFacebook) {
                          // ignore: use_build_context_synchronously
                          authServiceFacebook.updateUserInFirestore(
                            context,
                            _currentUser!.uid,
                            displayName,
                            email,
                            photoURL,
                            firstnameController.text,
                            lasttnameController.text,
                            _selectedGender!,
                            _selectedDate!,
                          );
                        }
                        localStorageController.saveUserLoginStatus(true);
                        print(localStorageController.isLoggedIn.value);

                        EasyLoading.dismiss();
                        Get.to(HomeScreen());
                      } catch (error) {
                        print("Error updating user in Firestore: $error");
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(color: Colors.grey.withOpacity(0.5)),
                    ),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black,
                      ),
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
