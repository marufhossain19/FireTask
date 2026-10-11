import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/firebase_service.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;
  String? _errorCode;
  bool _isGuestMode = false;
  String _userEmail = 'user@example.com';

  AuthProvider() {
    _init();
  }

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get errorCode => _errorCode;
  bool get isAuthenticated => _user != null || _isGuestMode;
  String get userEmail => _user?.email ?? _userEmail;
  String? get effectiveUserId {
    if (_user != null) return _user!.uid;
    if (_isGuestMode) return _userEmail;
    return null;
  }

  bool get hasPasswordProvider {
    if (_user == null) return false;
    return _user!.providerData.any((info) => info.providerId == 'password');
  }

  bool get isGoogleUser {
    if (_user == null) return false;
    return _user!.providerData.any((info) => info.providerId == 'google.com');
  }

  void _init() {
    if (_firebaseService.isInitialized && _firebaseService.auth != null) {
      _user = _firebaseService.currentUser;
      _firebaseService.authStateChanges.listen((User? user) {
        _user = user;
        notifyListeners();
      });
    }
  }

  Future<bool> signInWithEmail(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    _errorCode = null;
    notifyListeners();

    try {
      if (_firebaseService.isInitialized && _firebaseService.auth != null) {
        final credential = await _firebaseService.auth!.signInWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        _user = credential.user;
        _isGuestMode = false;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // Safe preview / demo mode if Firebase is not yet configured
        await Future.delayed(const Duration(milliseconds: 600));
        _userEmail = email.trim().isEmpty ? 'user@example.com' : email.trim();
        _isGuestMode = true;
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on FirebaseAuthException catch (e) {
      _errorCode = e.code;
      _errorMessage = e.message ?? 'Authentication failed';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorCode = 'unknown';
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUpWithEmail(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    _errorCode = null;
    notifyListeners();

    try {
      if (_firebaseService.isInitialized && _firebaseService.auth != null) {
        final credential = await _firebaseService.auth!.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        _user = credential.user;
        _isGuestMode = false;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        await Future.delayed(const Duration(milliseconds: 600));
        _userEmail = email.trim();
        _isGuestMode = true;
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on FirebaseAuthException catch (e) {
      _errorCode = e.code;
      _errorMessage = e.message ?? 'Registration failed';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorCode = 'unknown';
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_firebaseService.isInitialized && _firebaseService.auth != null) {
        final googleSignIn = GoogleSignIn.instance;
        await googleSignIn.initialize();
        final GoogleSignInAccount account = await googleSignIn.authenticate();
        final GoogleSignInAuthentication googleAuth = account.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential =
            await _firebaseService.auth!.signInWithCredential(credential);
        _user = userCredential.user;
        _isGuestMode = false;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // Safe preview / demo fallback when Firebase backend is unconfigured
        await Future.delayed(const Duration(milliseconds: 500));
        _userEmail = 'google_user@example.com';
        _isGuestMode = true;
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
      _errorMessage = e.description ?? 'Google Sign-In canceled or failed';
      _isLoading = false;
      notifyListeners();
      return false;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Google Sign-In failed';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> sendPasswordReset(String email) async {
    if (_firebaseService.isInitialized && _firebaseService.auth != null) {
      await _firebaseService.auth!.sendPasswordResetEmail(email: email.trim());
    }
  }

  Future<Map<String, dynamic>> setOrUpdatePassword(String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_firebaseService.isInitialized && _firebaseService.auth != null && _user != null) {
        final email = _user!.email;
        if (email == null || email.isEmpty) {
          throw Exception('No email associated with this account');
        }

        final hasPassword = hasPasswordProvider;
        if (hasPassword) {
          await _user!.updatePassword(newPassword);
        } else {
          try {
            final credential = EmailAuthProvider.credential(
              email: email,
              password: newPassword,
            );
            final userCred = await _user!.linkWithCredential(credential);
            _user = userCred.user ?? _user;
          } on FirebaseAuthException catch (e) {
            if (e.code == 'provider-already-linked' ||
                e.code == 'credential-already-in-use') {
              await _user!.updatePassword(newPassword);
            } else {
              rethrow;
            }
          }
        }

        _isLoading = false;
        notifyListeners();
        return {'success': true, 'message': 'Password set successfully!'};
      } else {
        await Future.delayed(const Duration(milliseconds: 600));
        _isLoading = false;
        notifyListeners();
        return {'success': true, 'message': 'Password set successfully!'};
      }
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      String message = e.message ?? 'Failed to set password';
      if (e.code == 'requires-recent-login') {
        message =
            'For security reasons, please log out and sign in again before setting a new password.';
      } else if (e.code == 'weak-password') {
        message = 'The password is too weak. Please use at least 6 characters.';
      }
      return {'success': false, 'message': message, 'code': e.code};
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<void> signOut() async {
    if (_firebaseService.isInitialized && _firebaseService.auth != null) {
      await _firebaseService.auth!.signOut();
    }
    _user = null;
    _isGuestMode = false;
    notifyListeners();
  }
}
