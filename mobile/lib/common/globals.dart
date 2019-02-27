import 'package:core/core.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class GlobalFunctions {
  static bool isNumeric(String str) {
    if (str == null) {
      return false;
    }

    return double.tryParse(str) != null;
  }
}

class GlobalValues {
  static FirebaseUser user; // Logged in user uuid

  /// For editing record
  static bool bAddOrEdit = true; // true: Add, false: Edit
  static Record record;
  static String recordId;
  /// ///////////////////////
}

FirebaseApp globalFirebaseApp;
Firestore firestore;
FirebaseStorage firebaseStorage;