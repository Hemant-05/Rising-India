import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:raising_india/constant/ConString.dart';
import 'package:raising_india/features/services/location_service.dart';
import 'package:raising_india/models/address_model.dart';
import 'package:raising_india/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/user_model.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  AppUser? _user;
  AppUser? get user => _user;

  AuthService() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _user = null;
    } else {
      _user = await getCurrentUser();
    }
    notifyListeners();
  }

  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Refresh notification token after login
      await NotificationService.refreshToken();
      final user = cred.user;
      if (user != null) {
        final appUser = AppUser(
          uid: user.uid,
          name: name,
          email: email,
          number: '',
          role: role,
          isVerified: false,
          addressList: [],
        );
        if (admin == role) {
          await _db.collection('admin').doc(user.uid).set(appUser.toMap());
        } else {
          await _db.collection('users').doc(user.uid).set(appUser.toMap());
        }
        _user = appUser;
        notifyListeners();
        return null;
      }
      return "User creation failed";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return "Email is already in use";
      } else if (e.code == 'weak-password') {
        return "Password is too weak";
      } else if (e.code == 'invalid-email') {
        return "Invalid email format";
      } else if (e.code == 'network-request-failed') {
        return "Network error, please try again";
      } else {
        return e.message;
      }
    } catch (e) {
      return "Server is Busy, please try again later";
    }
  }

  Future<String> verifyOtpAndLink(String smsCode, String verificationId) async {
    final PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return await linkPhoneNumber(credential);
  }

  Future<String> linkPhoneNumber(PhoneAuthCredential credential) async {
    final user = _auth.currentUser;
    if (user == null) return "Error No user signed in!";

    try {
      final userId = user.uid;
      await user.linkWithCredential(credential);
      var doc = await _db.collection('users').doc(userId).get();
      if (doc.exists) {
        doc.reference.update({'isVerified': true, 'number' : user.phoneNumber});
      } else {
        await _db.collection('admin').doc(userId).update({'isVerified': true,'number' : user.phoneNumber});
      }
      return 'Success Phone number linked!';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'provider-already-linked') {
        return 'Error Number already Linked';
      } else if (e.code == 'credential-already-in-use') {
        return 'Error Number is already in user !!!';
      } else {
        print('Error linking phone: ${e.message}');
      }
    }
    return 'Error ......';
  }

  Future<String?> signIn(String email, String password) async {
    try {
      final x = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await NotificationService.refreshToken();
      return x.user != null ? null : "Invalid email or password";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return "No user found with this email";
      } else if (e.code == 'wrong-password') {
        return "Incorrect password";
      } else if (e.code == 'invalid-email') {
        return "Invalid email format";
      } else if (e.code == 'network-request-failed') {
        return "Network error, please try again";
      } else if (e.code == 'too-many-requests') {
        return "Too many login attempts, please try again later";
      } else if (e.code == 'invalid-credential') {
        return "Invalid credentials provided";
      } else {
        return e.message;
      }
    } catch (e) {
      return "An unknown error occurred";
    }
  }

  Future<String?> sendVerificationCode(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return 'ok';
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "An Unknow error occurred $e";
    }
  }

  Future<String?> verifyCode(String code) async {
    try {
      return await _auth.verifyPasswordResetCode(code);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'expired-action-code') {
        return 'Code is Expired !!';
      } else if (e.code == 'invalid-action-code') {
        return 'Code is Invalid !!';
      } else {
        return 'Error occurred...';
      }
    } catch (e) {
      return "An Unknow error occurred $e";
    }
  }

  Future<String?> resetPassword(String code, String newPass) async {
    try {
      await _auth.confirmPasswordReset(code: code, newPassword: newPass);
      return 'ok';
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "An Unknow error occurred $e";
    }
  }

  /* Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return "Google sign in aborted";
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCred = await _auth.signInWithCredential(credential);
      final user = userCred.user;
      if (user != null) {
        final doc = await _db.collection('users').doc(user.uid).get();
        if (!doc.exists) {
          final appUser = AppUser(
            uid: user.uid,
            name: user.displayName ?? '',
            email: user.email ?? '',
            number: '',
            role: UserRole.USER,
          );
          await _db.collection('users').doc(user.uid).set(appUser.toMap());
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "An unknown error occurred";
    }
  } */

  Future<void> signOut() async {
    await NotificationService.clearToken();
    await _auth.signOut();
    _user = null;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('rememberMe', false);
    prefs.remove('isAdmin');
    notifyListeners();
  }

  Future<String?> updateUserLocation() async {
    String userId = _auth.currentUser!.uid;
    final position = await LocationService.getCurrentPosition();
    if (position == null) return 'Location not available';

    final address = await LocationService.getReadableAddress(
      LatLng(position.latitude, position.longitude),
    );

    // Update user in Firestore
    await _db.collection('users').doc(userId).update({
      'addressList': FieldValue.arrayUnion([{}]),
    });
    return address;
  }

  Future<String?> addLocation(AddressModel address) async {
    String userId = _auth.currentUser!.uid;
    await _db.collection('users').doc(userId).update({
      'addressList': FieldValue.arrayUnion([address.toMap()]),
    });
    return 'ok';
  }

  Future<String?> deleteLocationFromList(int index) async {
    String userId = _auth.currentUser!.uid;
    try {
      // 1. Get the document
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      // 2. Get the current list
      List<dynamic> list = List.from(doc['addressList'] ?? []);
      // 3. Check if index is valid
      if (index >= 0 && index < list.length) {
        // 4. Remove the item at index
        list.removeAt(index);
        // 5. Update the entire array
        await doc.reference.update({'addressList': list});
      }
      return 'ok';
    } catch (e) {
      print('Error removing item: $e');
      throw Exception('Failed to remove item');
    }
  }

  Future<List<AddressModel>> getLocationList() async {
    var user = await getCurrentUser();
    return user!.addressList;
  }

  Future<AppUser?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    final user = await _db.collection('users').doc(firebaseUser.uid).get();
    if (user.exists) {
      return AppUser.fromMap(user.data()!, firebaseUser.uid);
    }
    final admin = await _db.collection('admin').doc(firebaseUser.uid).get();
    if (admin.exists) {
      final admin0 = AppUser.fromMap(admin.data()!, firebaseUser.uid);
      return admin0;
    }
    print('returning null');
    return null;
  }
}
