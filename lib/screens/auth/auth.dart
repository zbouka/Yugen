import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:yugen/config/preferences.dart';
import 'package:yugen/screens/auth/change_username.dart';
import 'package:yugen/screens/auth/login.dart';
import 'package:yugen/helpers/user_exists.dart';
import 'package:yugen/widgets/Recycled/get_color.dart';

import 'dart:async';

import '../../apis/email.dart';
import '../../widgets/navigation_bar.dart';

class Auth {
  ///Skeleton for authentication
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _database = FirebaseFirestore.instance;
  bool _sendEmail = false;
  Future sendEmailVerification(User user) async {
    user.sendEmailVerification().then((value) {}).onError((error, stackTrace) {
      if (Get.isSnackbarOpen == false) Get.snackbar("ERROR", error.toString());
    });

    Get.offAll(() => const Login());
  }

  User? getUser() {
    return _auth.currentUser;
  }

  /// Method to change the username in Firestore using the [user] and [username] required to do that step
  Future<void> changeUsername(User user, String username) async {
    return await FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid)
        .set({'username': username});
  }

  ///Listens to user changes (login,logout or email verification status)
  handleAuth() {
    _auth.authStateChanges().listen((User? user) async {
      if (user == null) {
        Get.offAll(() => const Login());
      } else if (user.emailVerified &&
          await userExists(user.displayName!, user: user) == false) {
        Get.offAll(() => const MyNavigationBar());
      } else if (!user.emailVerified && _sendEmail == false) {
        if (!Get.isSnackbarOpen) {
          Get.snackbar("ERROR", "emailNotVerified".tr);
        }

        sendEmailVerification(user);
      } else if (await userExists(user.displayName!, user: Auth().getUser()!) ==
          true) {
        if (Get.isSnackbarOpen == false) {
          Get.snackbar("ERROR", "userIsValid".tr);
        }

        Get.off(() => const ChangeUsername());
      }
    });
  }

  /// Method used to save in our custom collection the profile pic and display name
  /// It triggers when the user registers using email/password authentication
  void updateProfileData(User user, String username) async {
    if (user.photoURL == null) {
      /*user.updatePhotoURL(
          "https://img.icons8.com/fluency/50/000000/cat-profile.png");*/
      user.updatePhotoURL("https://openclipart.org/image/800px/333568");

      user.updateDisplayName(username);
    }
  }

  /// First it checks if the username exists using the [userCredential] credential and the [username] string
  /// Then the new user is saved in our Users collection
  void registerUser(UserCredential userCredential, username) async {
    if (await userExists(username, user: userCredential.user!) == true) {
      Get.off(() => const ChangeUsername());
      return;
    } else {
      var docRef = _database.collection("Users").doc(userCredential.user!.uid);

      docRef.set({"username": username}, SetOptions(merge: true));
    }
  }

  /// Enrolls the new user using email and password
  Future register(String email, String password, String username) async {
    await _auth
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((user) async {
      await _auth.currentUser!.sendEmailVerification();
      _sendEmail = true;
      if (Get.isSnackbarOpen == false) {
        Get.snackbar("verification".tr, "sendEmail".trParams({"email": email}));
      }
      updateProfileData(getUser()!, username);
      registerUser(user, username);
      Get.off(() => const Login());
    }).onError((error, stackTrace) {
      FirebaseAuthException e = error as FirebaseAuthException;
      if (e.code == "email-already-in-use" && Get.isSnackbarOpen == false) {
        Get.snackbar("ERROR", 'emailInUse'.tr);
      }
    });
  }

  /// Allows the user to login using email/password
  Future<UserCredential?> signIn(
      String email, String password, bool save) async {
    try {
      var emailMehods = await _auth.fetchSignInMethodsForEmail(email);
      if (emailMehods.isEmpty && Get.isSnackbarOpen == false) {
        Get.snackbar("ERROR", "emailNotFound".tr);
        return null;
      }

      UserCredential userC = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      Preferences().saveIfRemember(save);
      if (save) {
        await Preferences().saveCreds(email, password);
      }
      if (save == false) {
        await Preferences().deleteCreds();
      }
      handleAuth();
      return userC;
    } on FirebaseAuthException catch (e) {
      var emailProviders =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      if (e.code == "user-not-found" && Get.isSnackbarOpen == false) {
        Get.snackbar("ERROR", 'userError'.tr,
            colorText: getCurrentColor(false));
      } else if (e.code == "wrong-password" &&
          Get.isSnackbarOpen == false &&
          !emailProviders.contains("google.com")) {
        Get.snackbar("ERROR", 'passwordIsWrong'.tr,
            colorText: getCurrentColor(false));
      } else if (e.code == "wrong-password" &&
          emailProviders.contains("google.com")) {
        Get.snackbar("ERROR", 'googleAccount'.tr,
            colorText: getCurrentColor(false));
      }
    }
    return null;
  }

  /// Deletes the user including all the comments, ratings and the user record in our collection
  Future deleteUser() async {
    try {
      QuerySnapshot<Map<String, dynamic>> commentsManga =
          await _database.collection('Mangas').get();
      QuerySnapshot<Map<String, dynamic>> commentsAnime =
          await _database.collection('Animes').get();

      for (var element in commentsManga.docs) {
        element.reference
            .collection("Comments")
            .where("uid", isEqualTo: Auth().getUser()!.uid)
            .get()
            .then((value) => value.docs.forEach((element) async {
                  await element.reference.delete();
                }));
      }

      for (var element in commentsManga.docs) {
        element.reference
            .collection("Ratings")
            .where(FieldPath.documentId, isEqualTo: Auth().getUser()!.uid)
            .get()
            .then((value) => value.docs.forEach((element) async {
                  await element.reference.delete();
                }));
      }

      for (var element in commentsAnime.docs) {
        element.reference
            .collection("Comments")
            .where("uid", isEqualTo: Auth().getUser()!.uid)
            .get()
            .then((value) => value.docs.forEach((element) async {
                  print(await element.reference.get());
                  await element.reference.delete();
                }));
      }

      for (var element in commentsAnime.docs) {
        element.reference
            .collection("Ratings")
            .where(FieldPath.documentId, isEqualTo: Auth().getUser()!.uid)
            .get()
            .then((value) => value.docs.forEach((element) async {
                  await element.reference.delete();
                }));
      }
      await _database.collection('Users').doc(_auth.currentUser!.uid).delete();
      await _auth.currentUser!.delete().onError(
          (error, stackTrace) => sendErrorMail(false, "ERROR", error!));
      await signOut();
    } catch (e) {
      sendErrorMail(false, "ERROR", e);
    }
  }

  ///Sign out method
  Future signOut() async {
    try {
      await _googleSignIn.isSignedIn()
          ? await Future.wait([
              _googleSignIn.disconnect(),
              _googleSignIn.signOut(),
              _database.terminate(),
              _auth.signOut(),
            ])
          : await Future.wait([
              _database.terminate(),
              _auth.signOut(),
            ]);
    } catch (e) {
      if (Get.isSnackbarOpen == false) {
        Get.snackbar("ERROR", e.toString());
      }
    }
  }

  //Method for reseting the password using the firebase autenthication
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email).then((value) {
      if (Get.isSnackbarOpen == false) {
        Get.snackbar("succeed".tr, "succeedMessage".tr);
      }
    }).onError((error, stackTrace) {
      FirebaseAuthException exception = error as FirebaseAuthException;
      if (exception.code == "user-not-found" && Get.isSnackbarOpen == false) {
        Get.snackbar("Error", "messageError".tr);
      } else if (exception.code == "too-many-requests" &&
          Get.isSnackbarOpen == false) {
        Get.snackbar("Error", "tooEmails".tr);
      }
    });
  }

  /// Signs in with google
  Future signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential

    final UserCredential userCredential =
        await _auth.signInWithCredential(credential);

    try {
      registerUser(userCredential, userCredential.user!.displayName!);
      handleAuth();
    } catch (error) {
      sendErrorMail(false, "ERROR", error);
    }
  }
}
