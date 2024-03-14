import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> signUpWithEmailAndPassword(
    String email,
    String password,
    String username,
  ) async {
    try {
      // Create user with email and password
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get the newly created user
      final User? user = userCredential.user;

      // Update user profile
      await user?.updateDisplayName(username);

      // Save additional user data to Firestore
      await _firestore.collection('users').doc(user?.uid).set({
        'email': email,
        'username': username,
        // Add other fields as needed
      });
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }
}
