import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yugen/apis/email.dart';

/// Method used for username check in order to know if alredy exists in our database
Future<bool?> userExists(String username, {User? user}) async {
  try {
    if (user == null) {
      return await FirebaseFirestore.instance
          .collection('Users')
          .where('username', isEqualTo: username)
          .get()
          .then((value) => value.size > 0 ? true : false);
    } else {
      return await FirebaseFirestore.instance
          .collection('Users')
          .where('username', isEqualTo: username)
          .where(FieldPath.documentId, isNotEqualTo: user.uid)
          .get()
          .then((value) => value.size > 0 ? true : false);
    }
  } catch (error) {
    sendErrorMail(true, "ERROR", error);
  }
  return null;
}
