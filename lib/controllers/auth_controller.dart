// lib/controllers/auth_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// AuthController (MVC - Controller Layer)
/// Handles all Firebase Authentication related logic and returns
/// clean error messages back to the View.
class AuthController {
  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// SIGN IN METHOD
  /// Returns User on success, throws a String message on failure
  Future<User> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) throw 'Sign in failed. Please try again.';
      return user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw 'No user found for that email.';
        case 'wrong-password':
          throw 'Incorrect password. Please try again.';
        case 'invalid-email':
          throw 'The email address is badly formatted.';
        default:
          throw e.message ?? 'Sign in failed. Please try again.';
      }
    } catch (e) {
      throw 'An unexpected error occurred: $e';
    }
  }

  /// CREATE ACCOUNT METHOD
  /// Creates a user in Firebase Authentication and also stores data in Firestore
  Future<User> createAccount(String name, String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;

      if (user == null) throw 'Account creation failed. Please try again.';

      // Update displayName for local Firebase user object
      await user.updateDisplayName(name);

      // Create document in Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw 'This email is already registered. Please log in.';
        case 'weak-password':
          throw 'Weak password. Password should be at least 6 characters.';
        case 'invalid-email':
          throw 'The email address is badly formatted.';
        default:
          throw e.message ?? 'Account creation failed. Please try again.';
      }
    } catch (e) {
      throw 'Unexpected error: $e';
    }
  }

  /// SIGN OUT METHOD
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw 'Sign out failed: $e';
    }
  }
}
