import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
        _user = AppUser.fromMap(doc.data()!, firebaseUser.uid);
      }
    }
    notifyListeners();
  }

  Future<String?> signUp({
    required String name,
    required String email,
    required String number,
    required String password,
    required UserRole role,
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
      return e.message;
    } catch (e) {
      return "An unknown error occurred";
    }
  }

  Future<String?> signIn(String email, String password) async {
    try {
      final x = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("User signed in: ${x.user?.email}");
      return x.user != null ? null : "Invalid email or password";
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "An unknown error occurred";
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
    notifyListeners();
  }

  Future<AppUser?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    final doc = await _db.collection('users').doc(firebaseUser.uid).get();
    if (doc.exists) {
      return AppUser.fromMap(doc.data()!, firebaseUser.uid);
    }
    return null;
  }
}
