import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_leaningapp/FirebaseService/Firebase_Service.dart';
import 'package:e_leaningapp/GetxController/theme_controller.dart';
import 'package:e_leaningapp/Model/user_model.dart';
import 'package:e_leaningapp/Screen/Edit_Profile.dart';
import 'package:e_leaningapp/widgets/custom_listTile_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:iconly/iconly.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';

class ProfileInformation extends StatefulWidget {
  const ProfileInformation({
    Key? key,
  }) : super(key: key);

  @override
  State<ProfileInformation> createState() => _ProfileInformationState();
}

class _ProfileInformationState extends State<ProfileInformation> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> _getUser() async {
    final User? currentUser = _auth.currentUser;

    if (currentUser != null) {
      String uid = currentUser.uid;
      try {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(uid).get();
        if (userDoc.exists) {
          return UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
        } else {
          return null; // Return null if user document does not exist
        }
      } catch (e) {
        print('Error fetching user from Firestore: $e');
        return null; // Return null in case of error
      }
    } else {
      print('No user is currently signed in');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<UserModel?>(
          future: _getUser(),
          builder: (context, snapshot) {
            final UserModel? user = snapshot.data;
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildShimmerLoader();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              // return _buildShimmerLoader();
              return _build(user);
            }
          }),
    );
  }

  Future<void> _uploadImageAndSaveUrl(File imageFile) async {
    EasyLoading.show(status: 'Uploading...');
    String? downloadURL = await FirebaseService()
        .uploadImageToStorage(_imageFile!, 'user_images');
    if (downloadURL != null) {
      _saveImageUrlToFirestore(downloadURL);
    }
  }

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  User? user = FirebaseAuth.instance.currentUser;
  String photoURL = '';
  Future<void> _saveImageUrlToFirestore(String imageUrl) async {
    try {
      await firestore.collection('users').doc(user!.uid).update({
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

  XFile? _imageFile;
  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom, allowedExtensions: ['png', 'jpg', 'jpeg']);
    if (result != null) {
      setState(() {
        _imageFile = XFile(result.files.single.path!);
        _uploadImageAndSaveUrl(File(result.files.single.path!));
      });
    }
  }

  final ThemeController themeController = Get.find<ThemeController>();
  Widget _build(UserModel? user) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.4,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blueGrey[900]!,
                Colors.blueGrey[800]!,
              ],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(70),
              bottomRight: Radius.circular(70),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 10,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Hero(
                    tag: user!.photoURL,
                    child: CircleAvatar(
                      radius: 70,
                      backgroundColor: Colors.white,
                      backgroundImage: user.photoURL != null
                          ? NetworkImage(user.photoURL)
                          : null,
                      child: user.photoURL == null
                          ? Icon(Icons.person,
                              size: 50, color: Colors.blueGrey[900])
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 5,
                    right: 0,
                    child: InkWell(
                      onTap: () async {
                        await _pickImage();
                      },
                      child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.background,
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            color: Theme.of(context).iconTheme.color,
                          )),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '${user.firstName} ${user.lastName}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                user.email,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Account',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              CustomListTile(
                leadingIcon: Icon(
                  IconlyBold.profile,
                  color: Theme.of(context).iconTheme.color,
                ),
                title: 'Edit Profile',
                onTap: () {
                  Get.to(EditProfileInformation(
                    userModel: user,
                    auth: _auth,
                  ));
                },
              ),
              const SizedBox(height: 10),
              const Row(
                children: [
                  Text(
                    'App Settings',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              CustomListTile(
                leadingIcon: const Icon(Icons.question_mark_sharp, size: 18),
                title: 'Support',
                onTap: () {
                  // Handle Support tap
                },
              ),
              const SizedBox(height: 10),
               CustomListTile(
          leadingIcon: Obx(
            () => Icon(
              themeController.currentTheme.value == ThemeMode.dark
                  ? Icons.nightlight_outlined
                  : Icons.wb_sunny_outlined,
              size: 18,
            ),
          ),
          title: 'Change Theme',
          showSwitch: true,
          currentTheme: themeController.currentTheme,
          onSwitchChanged: (value) {
            themeController.switchTheme();
          },
          onTap: () {
            themeController.switchTheme();
          },
        ),
            ],
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        ElevatedButton(
          onPressed: () async {
            _auth.signOut();
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'Log Out',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.3,
            // decoration: const BoxDecoration(
            //   color: Colors.white,
            //   borderRadius: BorderRadius.only(
            //     bottomLeft: Radius.circular(70),
            //     bottomRight: Radius.circular(70),
            //   ),

            // ),
            child: Stack(
              children: [
                Positioned(
                  top: 20,
                  left: 20,
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xff8a72f1),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: 120,
                          height: 20,
                          color: Colors.white,
                        ),
                        SizedBox(height: 5),
                        Container(
                          width: 100,
                          height: 16,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 16,
                  color: Colors.white,
                ),
                SizedBox(height: 10),
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 50,
                  color: Colors.white,
                ),
                SizedBox(height: 10),
                Container(
                  width: 120,
                  height: 16,
                  color: Colors.white,
                ),
                SizedBox(height: 10),
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 50,
                  color: Colors.white,
                ),
                SizedBox(height: 10),
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 50,
                  color: Colors.white,
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
              height: 50,
            ),
          ),
        ],
      ),
    );
  }
}
