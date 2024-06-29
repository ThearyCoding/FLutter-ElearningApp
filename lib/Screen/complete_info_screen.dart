import 'dart:io';
import 'package:e_leaningapp/Screen/profile_information_screen.dart';
import 'package:e_leaningapp/widgets/custom_check_box_widget_02.dart';
import 'package:e_leaningapp/widgets/custom_text_field_widget_02.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:random_avatar/random_avatar.dart';
import '../export/export.dart';
import '../utils/date_picker_utils.dart';
import '../widgets/custom_date_picker_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
  final DateTime _selectedDate = DateTime(2006, 1, 5);
  TextEditingController txtfirstname = TextEditingController();
  TextEditingController txtlastname = TextEditingController();

  void _populateTextFields() {
    if (txtfirstname.text.isEmpty) {
      txtfirstname.text = firstName ?? '';
    }

    if (txtlastname.text.isEmpty) {
      txtlastname.text = lastName ?? '';
    }
  }

  final _formKey = GlobalKey<FormState>();
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
    _checkCurrentUserSignInStatus();
    _populateTextFields();
    
  }
   String svg = '';
  void randomAvatar(){
    svg = RandomAvatarString(
                  DateTime.now().toIso8601String(),
                  trBackground: false,
                );
  }
  void _checkCurrentUserSignInStatus() {
    signedInWithGoogle = authServiceGoogle.isSignedInWithGoogle(_currentUser!);
    signedInWithFacebook =
        authServiceFacebook.isSignedInWithFacebook(_currentUser!);

    if (signedInWithGoogle) {
      _populateGoogleUserDetails();
      
    } else if (signedInWithFacebook) {
      _populateFacebookUserDetails();
    } else {
      email = _currentUser!.email;
      randomAvatar();
    }
  }

  void _populateGoogleUserDetails() {
    displayName = _currentUser!.displayName;
    email = _currentUser!.email;
    photoURL = _currentUser!.photoURL;

    final displayNameParts = _currentUser!.displayName?.split(' ') ?? [];
    if (displayNameParts.isNotEmpty) {
      lastName = displayNameParts.last;
    }
    if (displayNameParts.isNotEmpty) {
      firstName = displayNameParts.first;
    }
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
        debugPrint('Failed to fetch profile data from Facebook Graph API.');
      }
    } else {
      debugPrint('Facebook access token is null.');
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
        svg= '';
      });
    }
  }

  final FirebaseStorage storage = FirebaseStorage.instance;

  DateTime? selectedDate = DateTime(2006, 1, 5);
  Future<void> onDateSelected(BuildContext context) async {
    final DateTime? pickedDate = await selectDate(context, selectedDate!);
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  String? selectedGender;

  void _onGenderChanged(String? gender) {
    setState(() {
      selectedGender = gender;
    });
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
              icon: const Icon(Icons.exit_to_app))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                lastName != null?
                Text(
                  "Hey $lastName!",
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ): Container(),
                const Text(
                  "You're applying for E-Learning",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
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
          // Conditional rendering based on image or SVG availability
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
                  : (svg != ''
                      ? DecorationImage(
                          image: MemoryImage(
                            // Convert SVG string to bytes and create an ImageProvider
                            Uint8List.fromList(utf8.encode(svg)),
                          ),
                          fit: BoxFit.cover,
                        )
                      : null)),
        ),
        child: svg != ''
            ? SvgPicture.string(
                svg,
                width: 150,
                height: 150,
                placeholderBuilder: (BuildContext context) =>
                    const CircularProgressIndicator(), 
              )
            : null,
      ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(30),
                        child: Ink(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.background,
                            shape: BoxShape.circle,
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(30),
                            onTap: () async {
                              await _pickImage();
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(15.0),
                              child: Icon(
                                Icons.edit,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                CustomTextFieldWidget02(
                  labelText: 'First Name ',
                  hintText: 'E.g., Chorn',
                  controller: txtfirstname,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your first name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                CustomTextFieldWidget02(
                  labelText: 'Last Name ',
                  hintText: 'E.g., Chorn',
                  controller: txtlastname,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your last name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Text(
                      'Select Gender',
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CustomCheckBoxWidget02(
                      label: 'Male',
                      value: selectedGender == 'Male',
                      onChanged: (bool? value) {
                        _onGenderChanged(value == true ? 'Male' : null);
                      },
                    ),
                    const SizedBox(width: 20),
                    CustomCheckBoxWidget02(
                      label: 'Female',
                      value: selectedGender == 'Female',
                      onChanged: (bool? value) {
                        _onGenderChanged(value == true ? 'Female' : null);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                CustomDatePicker(
                  selectedValue: selectedDate != null
                      ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                      : '',
                  onPressed: () {
                    onDateSelected(context);
                  },
                ),
                const SizedBox(height: 20),
                CustomButtonWidget(
                  text: 'Save Changes',
                  onPressed: () async {
                    if (selectedGender == null) {
                      showSnackbar('Required field', 'Please select gender');
                      return;
                    }
                    if (_formKey.currentState!.validate()) {
                      EasyLoading.show(status: 'Uploading...');
                      if (_imageFile != null) {
                        photoURL = await firebaseService.uploadImageToStorage(
                            _imageFile!, 'image_user_profiles');
                      }
                      final int? gender;
                      if (selectedGender == 'Female') {
                        gender = 0;
                      } else {
                        gender = 1;
                      }
                      firebaseService.userRegistration(
                        _currentUser!.uid,
                        email,
                        photoURL,
                        txtfirstname.text,
                        txtlastname.text,
                        gender,
                        _selectedDate,
                        svg
                      );
                      localStorageController.saveUserLoginStatus(true);
                      EasyLoading.dismiss();
                      Get.offNamed('/home');
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showSnackbar(String title, String message,
      {Color backgroundColor = Colors.red, IconData icon = Icons.info}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: backgroundColor,
      colorText: Colors.white,
      icon: Icon(
        icon,
        color: Colors.white,
      ),
    );
  }
}
