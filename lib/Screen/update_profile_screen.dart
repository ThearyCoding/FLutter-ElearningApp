import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_leaningapp/service/firebase/firebase_service.dart';
import 'package:e_leaningapp/Model/user_model.dart';
import 'package:e_leaningapp/utils/date_picker_utils.dart';
import 'package:e_leaningapp/widgets/custom_date_picker_widget.dart';
import 'package:e_leaningapp/widgets/custom_textfield_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';


class EditProfileInformation extends StatefulWidget {
  final UserModel userModel;
  final User auth;
  

  const EditProfileInformation({
    super.key,
    required this.userModel,
    required this.auth,
  });

  @override
  State<EditProfileInformation> createState() => _EditProfileInformationState();
}

class _EditProfileInformationState extends State<EditProfileInformation> {
  String? email;
  String? photoURL;
  String? uid;

  TextEditingController txtfirstname = TextEditingController();
  TextEditingController txtlastname = TextEditingController();
  TextEditingController txtshortdescription = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  @override
  void initState() {
    super.initState();
    uid = widget.auth.uid;
    photoURL = widget.userModel.photoURL;
    txtfirstname.text = widget.userModel.firstName;
    txtlastname.text = widget.userModel.lastName;
    selectedDate = widget.userModel.dob;
  }



  DateTime? selectedDate = DateTime(2006, 1, 5);
  Future<void> onDateSelected(BuildContext context) async {
    final DateTime? pickedDate = await selectDate(context, selectedDate!);
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Profiles'),
      ),
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
              const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'General Information',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: txtfirstname,
                      labelText: 'First Name',
                      hintText: 'E.g., John',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextField(
                      controller: txtlastname,
                      labelText: 'Last Name',
                      hintText: 'E.g., Doe',
                    ),
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
              CustomTextField(
                  controller: txtshortdescription,
                  labelText: 'Short Description',
                  hintText: 'Enter a description...'),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.blueAccent,
                ),
                child: TextButton(
                  onPressed: () async {
                    if (txtfirstname.text.isEmpty ||
                        txtlastname.text.isEmpty) {
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
                        firstName: txtfirstname.text.trim(),
                        lastName: txtlastname.text.trim(),
                        displayName: '${txtfirstname.text.trim()} ${txtlastname.text.trim()}',
                        shortDescription: txtshortdescription.text,
                        dob: selectedDate
                      );
                      EasyLoading.dismiss();
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