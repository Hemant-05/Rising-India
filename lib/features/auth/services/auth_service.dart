import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:raising_india/features/services/location_service.dart';
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
      await Future.delayed(Duration(milliseconds: 500));
      final doc = await _db.collection('users').doc(firebaseUser.uid).get();
      if (doc.exists) {
        _user = AppUser.fromMap(doc.data()!,doc.id);
      }
    }
    notifyListeners();
  }

  Future<String?> signUp({
    required String name,
    required String email,
    required String number,
    required String password,
    required String role,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = cred.user;
      if (user != null) {
        final appUser = AppUser(
          uid: user.uid,
          name: name,
          email: email,
          number: number,
          role: role,
        );
        await _db.collection('users').doc(user.uid).set(appUser.toMap());
        _user = appUser;
        notifyListeners();
        return null;
      }
      return "User creation failed";
    } on FirebaseAuthException catch (e) {
      if(e.code == 'email-already-in-use') {
        return "Email is already in use";
      } else if (e.code == 'weak-password') {
        return "Password is too weak";
      } else if(e.code == 'invalid-email') {
        return "Invalid email format";
      } else if(e.code == 'network-request-failed') {
        return "Network error, please try again";
      } else {
        return e.message;
      }
    } catch (e) {
      return "Server is Busy, please try again later";
    }
  }

  Future<String?> signIn(String email, String password) async {
    try {
      final x = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return x.user != null ? null : "Invalid email or password";
    } on FirebaseAuthException catch (e) {
      if(e.code == 'user-not-found') {
        return "No user found with this email";
      } else if (e.code == 'wrong-password') {
        return "Incorrect password";
      } else if (e.code == 'invalid-email') {
        return "Invalid email format";
      } else if (e.code == 'network-request-failed') {
        return "Network error, please try again";
      } else if( e.code == 'too-many-requests') {
        return "Too many login attempts, please try again later";
      }else if(e.code == 'invalid-credential') {
        return "Invalid credentials provided";
      } else {
        return e.message;
      }
    } catch (e) {
      return "An unknown error occurred";
    }
  }

  Future<String?> sendVerificationCode(String email) async{
    try{
      await _auth.sendPasswordResetEmail(email: email);
      return 'ok';
    } on FirebaseAuthException catch(e){
      return e.message;
    }catch (e){
      return "An Unknow error occurred $e";
    }
  }

  Future<String?> verifyCode(String code) async{
    try{
      return await _auth.verifyPasswordResetCode(code);
    } on FirebaseAuthException catch(e){
      if(e.code == 'expired-action-code'){
        return 'Code is Expired !!';
      }else if(e.code == 'invalid-action-code'){
        return 'Code is Invalid !!';
      }else{
        return 'Error occurred...';
      }
    }catch (e){
      return "An Unknow error occurred $e";
    }
  }

  Future<String?> resetPassword(String code,String newPass) async{
    try{
      await _auth.confirmPasswordReset(code: code, newPassword: newPass);
      return 'ok';
    } on FirebaseAuthException catch(e){
      return e.message;
    }catch (e){
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
    await _auth.signOut();
    _user = null;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('rememberMe', false);
    prefs.remove('isAdmin');
    notifyListeners();
  }

  Future<String?> updateUserLocation(String userId) async {
    // Get current position
    final position = await LocationService.getCurrentPosition();
    if (position == null) return 'Location not available';

    // Get human-readable address
    final address = await LocationService.getAddressFromLatLng(
      position.latitude,
      position.longitude,
    );

    // Update user in Firestore
    await _db.collection('users').doc(userId).update({
      'currentLocation': GeoPoint(position.latitude, position.longitude),
      'address': address,
    });
    return address;
  }

  Future<AppUser?> getCurrentUser() async {
    try{
      final firebaseUser = _auth.currentUser;

      if (firebaseUser == null) return null;
      final doc = await _db.collection('users').doc(firebaseUser.uid).get();
      if (doc.exists) {
        return AppUser.fromMap(doc.data()!,firebaseUser.uid);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
