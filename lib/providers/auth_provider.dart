import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  bool _isLoading = true;
  String _userName = 'Guest';
  String? _userPhotoUrl;

  // Document ID in tracker collection that will contain the users subcollection
  static const String _usersDocId = 'user_data';

  AuthProvider() {
    _initializeAuth();
  }

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String get userName => _userName;
  String get userEmail => _user?.email ?? '';
  String? get userPhotoUrl => _userPhotoUrl;
  String get uid => _user?.uid ?? '';
  String? get email => _user?.email;

  Future<void> _initializeAuth() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Listen to auth state changes
      _auth.authStateChanges().listen((User? user) async {
        _user = user;
        if (user != null) {
          // Get user data from Firestore - proper subcollection path
          final userDoc = await _firestore
              .collection('tracker')
              .doc(_usersDocId)
              .collection('users')
              .doc(user.uid)
              .get();

          if (userDoc.exists) {
            final userData = userDoc.data() as Map<String, dynamic>;
            _userName = userData['displayName'] ?? user.displayName ?? 'Guest';
            _userPhotoUrl = userData['photoURL'] ?? user.photoURL;
          } else {
            _userName = user.displayName ?? 'Guest';
            _userPhotoUrl = user.photoURL;
            // Save user data if not exists
            await _saveUserToFirestore(user);
          }
        } else {
          _userName = 'Guest';
          _userPhotoUrl = null;
        }
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveUserToFirestore(User user) async {
    try {
      // Proper path to users subcollection
      final userRef = _firestore
          .collection('tracker')
          .doc(_usersDocId)
          .collection('users')
          .doc(user.uid);

      final userDoc = await userRef.get();

      if (!userDoc.exists) {
        await userRef.set({
          'userId': user.uid,
          'email': user.email,
          'displayName': user.displayName,
          'photoURL': user.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
          'provider': 'google',
        });
      } else {
        await userRef.update({
          'lastLogin': FieldValue.serverTimestamp(),
          'email': user.email,
          'displayName': user.displayName,
          'photoURL': user.photoURL,
        });
      }
    } catch (e) {
      debugPrint('Error saving user to Firestore: $e');
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Clear any existing sign in
      await _googleSignIn.signOut();
      await _auth.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      _user = userCredential.user;

      if (_user != null) {
        await _saveUserToFirestore(_user!);
        // Update local state after saving to Firestore
        final userDoc = await _firestore
            .collection('tracker')
            .doc(_usersDocId)
            .collection('users')
            .doc(_user!.uid)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          _userName = userData['displayName'] ?? _user!.displayName ?? 'Guest';
          _userPhotoUrl = userData['photoURL'] ?? _user!.photoURL;
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);

      _user = null;
      _userName = 'Guest';
      _userPhotoUrl = null;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
