import 'dart:async';
import 'package:e_leaningapp/Model/user_model.dart';
import 'package:e_leaningapp/local_storage/user_authentication_local_storage.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Rx<UserModel?> user = Rx<UserModel?>(null);
  late StreamSubscription<User?> _authSubscription;
  StreamSubscription<DocumentSnapshot>? _userDocSubscription;
late LocalStorageSharedPreferences
      localStorageController = Get.find<LocalStorageSharedPreferences>();
  @override
  void onInit() {
    super.onInit();
   
    _authSubscription = _auth.authStateChanges().listen(_handleAuthStateChange);
  }

  @override
  void onClose() {
    _authSubscription.cancel();
    _userDocSubscription?.cancel();
    super.onClose();
  }

  void _handleAuthStateChange(User? firebaseUser) async {
    _userDocSubscription?.cancel();  // Cancel any existing subscription to avoid multiple listeners

    if (firebaseUser != null) {
      String uid = firebaseUser.uid;
      try {
        DocumentReference userRef = _firestore.collection('users').doc(uid);

        // Listen to changes in the user document
        _userDocSubscription = userRef.snapshots().listen((userDoc) async {
          if (userDoc.exists) {
            user.value = UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
          } else {
             localStorageController.logoutUser();
              Get.offAllNamed('/');// Navigate to the login page
            user.value = null; // Clear the user if the document does not exist
            await _auth.signOut(); // Sign out the user
             
              
          }
        });
      } catch (e) {
        print('Error fetching user from Firestore: $e');
         localStorageController.logoutUser();
            Get.offAllNamed('/'); // Navigate to the login page
        user.value = null; // Clear the user in case of error
        await _auth.signOut(); // Sign out the user
     
       
      }
    } else {
      print('No user is currently signed in');
      user.value = null;
    }
  }
}
