import 'dart:io';
import 'package:e_leaningapp/utils/custom_cirular_progress_indicator_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_cropper/image_cropper.dart';
import '../export/export.dart';
import '../utils/show_dialog_sign_out_utils.dart';
export 'package:flutter/material.dart';

class ProfileInformation extends StatefulWidget {
  const ProfileInformation({
    Key? key,
  }) : super(key: key);

  @override
  State<ProfileInformation> createState() => _ProfileInformationState();
}

class _ProfileInformationState extends State<ProfileInformation> {
  bool _isFilePickerActive = false; // Boolean flag to track file picker state
  String photoURL = '';
  final UserController userController = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final user = userController.user.value;
        if (userController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return user == null ? _buildErrorState() : _build(user);
        }
      }),
    );
  }

  Future<void> _uploadImageAndSaveUrl(File imageFile) async {
    try {
      EasyLoading.show(status: 'Preparing to upload...');

      String? downloadURL = await FirebaseService().uploadImageToStorage(
          XFile(imageFile.path), 'user_images',
          oldPhotoUrl: photoURL);
      if (downloadURL != null) {
        await _saveImageUrlToFirestore(downloadURL);
      }

      EasyLoading.dismiss();
    } catch (e) {
      EasyLoading.dismiss();
      if (kDebugMode) {
        print('Error uploading image: $e');
      }
    }
  }

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  User? user = FirebaseAuth.instance.currentUser;
  Future<void> _saveImageUrlToFirestore(String imageUrl) async {
    try {
      if (user != null) {
        await firestore.collection('users').doc(user!.uid).update({
          'photoURL': imageUrl,
        });
        setState(() {
          photoURL = imageUrl;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving image URL to Firestore: $e');
      }
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> _pickImage() async {
    if (_isFilePickerActive) return; // Prevent re-entry
    _isFilePickerActive = true; // Set the flag

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg'],
      );

      if (result != null && result.files.single.path != null) {
        _pickedFile = File(result.files.single.path!);
        await _cropImage();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error picking file: $e');
      }
    } finally {
      _isFilePickerActive = false; // Reset the flag
    }
  }

  File? _pickedFile;
  File? _croppedFile;

  Future<void> _cropImage() async {
    if (_pickedFile != null) {
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: _pickedFile!.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ],
          ),
          IOSUiSettings(
            title: 'Cropper',
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ],
          ),
          WebUiSettings(
            context: context,
            presentStyle: WebPresentStyle.dialog,
            size: const CropperSize(
              width: 520,
              height: 520,
            ),
          ),
        ],
      );
      if (croppedFile != null) {
        File imageFile = File(croppedFile.path);
        setState(() {
          _croppedFile = imageFile;
          _uploadImageAndSaveUrl(_croppedFile!);
        });
      }
    }
  }

  final ThemeController themeController = Get.find<ThemeController>();
  Widget _build(UserModel userModel) {
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
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 140, // Diameter (2 * radius)
                    height: 140, // Diameter (2 * radius)
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF6803AE),
                          Color(0xFFE400A0)
                        ], // Gradient colors
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                        child: Container(
                      width: 130,
                      height: 130,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: CircleAvatar(
                        radius: 65,
                        backgroundColor: Colors.white,
                        child: userModel.photoURL != '' &&
                                userModel.photoURL.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: userModel.photoURL,
                                placeholder: (context, url) =>
                                    customCirularProgress(),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                                imageBuilder: (context, imageProvider) =>
                                    CircleAvatar(
                                  radius: 65,
                                  backgroundImage: imageProvider,
                                ),
                              )
                            : SvgPicture.string(userModel.avatar_svg,
                                width: 130,
                                height: 130,
                                placeholderBuilder: (context) =>
                                    customCirularProgress()),
                      ),
                    )),
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
                            // ignore: deprecated_member_use
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
                '${userModel.firstName} ${userModel.lastName}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                userModel.email,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
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
                  Get.to(
                      EditProfileInformation(
                        userModel: userModel,
                        auth: user!,
                      ),
                      transition: Transition.downToUp);
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
              const SizedBox(height: 10),
              CustomListTile(
                  leadingIcon: const Icon(Icons.school),
                  title: 'My Courses',
                  onTap: () {
                    Get.to(MyCoursesScreen(), transition: Transition.downToUp);
                  }),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () async {
                  bool? confirmSignOut = await showSignOutDialog(context);
                  if (confirmSignOut!) {
                    FirebaseAuth.instance.signOut();
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red,
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
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
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return const Center(
      child: Text(
        'Error loading user data. Please try again.',
        style: TextStyle(
          color: Colors.red,
          fontSize: 18,
        ),
      ),
    );
  }
}
