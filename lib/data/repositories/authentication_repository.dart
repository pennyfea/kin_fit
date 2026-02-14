import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../domain/models/user.dart';

/// Exception thrown when logout fails.
class LogOutFailure implements Exception {
  /// Creates a [LogOutFailure] with an optional message.
  const LogOutFailure([
    this.message = 'An unknown error occurred.',
  ]);

  /// The error message.
  final String message;
}

/// Exception thrown when phone authentication fails.
class PhoneAuthenticationFailure implements Exception {
  /// Creates a [PhoneAuthenticationFailure] with an optional message.
  const PhoneAuthenticationFailure([
    this.message = 'An unknown error occurred.',
  ]);

  /// Creates a [PhoneAuthenticationFailure] from a Firebase error code.
  factory PhoneAuthenticationFailure.fromCode(String code) {
    switch (code) {
      case 'invalid-phone-number':
        return const PhoneAuthenticationFailure(
          'The phone number is not valid.',
        );
      case 'missing-phone-number':
        return const PhoneAuthenticationFailure(
          'Please provide a phone number.',
        );
      case 'quota-exceeded':
        return const PhoneAuthenticationFailure(
          'SMS quota exceeded. Please try again later.',
        );
      case 'user-disabled':
        return const PhoneAuthenticationFailure(
          'This user has been disabled. Please contact support.',
        );
      case 'operation-not-allowed':
        return const PhoneAuthenticationFailure(
          'Phone authentication is not enabled. Please contact support.',
        );
      case 'too-many-requests':
        return const PhoneAuthenticationFailure(
          'Too many requests. Please try again later.',
        );
      default:
        return const PhoneAuthenticationFailure();
    }
  }

  /// The error message.
  final String message;
}

/// Exception thrown when verifying phone code fails.
class VerifyPhoneCodeFailure implements Exception {
  /// Creates a [VerifyPhoneCodeFailure] with an optional message.
  const VerifyPhoneCodeFailure([
    this.message = 'An unknown error occurred.',
  ]);

  /// Creates a [VerifyPhoneCodeFailure] from a Firebase error code.
  factory VerifyPhoneCodeFailure.fromCode(String code) {
    switch (code) {
      case 'invalid-verification-code':
        return const VerifyPhoneCodeFailure(
          'The verification code is invalid. Please try again.',
        );
      case 'invalid-verification-id':
        return const VerifyPhoneCodeFailure(
          'The verification session has expired. Please request a new code.',
        );
      case 'session-expired':
        return const VerifyPhoneCodeFailure(
          'The verification session has expired. Please request a new code.',
        );
      case 'code-expired':
        return const VerifyPhoneCodeFailure(
          'The verification code has expired. Please request a new code.',
        );
      default:
        return const VerifyPhoneCodeFailure();
    }
  }

  /// The error message.
  final String message;
}

/// Repository that manages user authentication via phone OTP.
///
/// This repository handles all authentication operations including:
/// - Phone OTP authentication (send code, verify code)
/// - Auth state changes
/// - User data synchronization with Firestore
class AuthenticationRepository {
  /// Creates an [AuthenticationRepository].
  AuthenticationRepository({
    firebase_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  /// Stream of [User] which will emit the current user when
  /// the authentication state changes.
  ///
  /// Emits [User.empty] if the user is not authenticated.
  Stream<User> get user {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return User.empty;
      return firebaseUser.toUser;
    });
  }

  /// Returns the current authenticated [User].
  ///
  /// Returns [User.empty] if the user is not authenticated.
  User get currentUser {
    final firebaseUser = _firebaseAuth.currentUser;
    return firebaseUser?.toUser ?? User.empty;
  }

  /// Signs out the current user.
  ///
  /// Throws a [LogOutFailure] if an exception occurs.
  Future<void> logOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw const LogOutFailure();
    }
  }

  /// Sends an OTP code to the provided phone number.
  ///
  /// Returns the verification ID needed for code verification.
  /// The phone number should be in E.164 format (e.g., +1234567890).
  ///
  /// Throws a [PhoneAuthenticationFailure] if an exception occurs.
  Future<String> sendPhoneCode(String phoneNumber) async {
    try {
      final completer = Completer<String>();

      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        // Timeout for auto-retrieval on Android
        timeout: const Duration(seconds: 60),
        // Called when verification completes automatically (Android only)
        verificationCompleted: (firebase_auth.PhoneAuthCredential credential) async {
          try {
            final userCredential = await _firebaseAuth.signInWithCredential(
              credential,
            );
            if (userCredential.user != null) {
              await _syncUserToFirestore(userCredential.user!);
            }
          } catch (e) {
            // Auto-verification failed, user will need to enter code manually
          }
        },
        // Called when verification fails
        verificationFailed: (firebase_auth.FirebaseAuthException e) {
          if (!completer.isCompleted) {
            completer.completeError(
              PhoneAuthenticationFailure.fromCode(e.code),
            );
          }
        },
        // Called when code is sent
        codeSent: (String verificationId, int? resendToken) {
          if (!completer.isCompleted) {
            completer.complete(verificationId);
          }
        },
        // Called when auto-retrieval timeout is reached
        codeAutoRetrievalTimeout: (String verificationId) {
          // Auto-retrieval timeout reached, user needs to enter code manually
        },
      );

      return completer.future;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw PhoneAuthenticationFailure.fromCode(e.code);
    } catch (e) {
      if (e is PhoneAuthenticationFailure) rethrow;
      throw const PhoneAuthenticationFailure();
    }
  }

  /// Verifies the OTP code and signs in the user.
  ///
  /// Uses the verification ID from [sendPhoneCode] and the SMS code
  /// entered by the user to complete the authentication.
  ///
  /// Throws a [VerifyPhoneCodeFailure] if an exception occurs.
  Future<void> verifyPhoneCode({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = firebase_auth.PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      if (userCredential.user != null) {
        await _syncUserToFirestore(userCredential.user!);
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw VerifyPhoneCodeFailure.fromCode(e.code);
    } catch (e) {
      throw const VerifyPhoneCodeFailure();
    }
  }

  /// Syncs the Firebase Auth user to Firestore.
  ///
  /// Creates or updates the user document in the 'users' collection.
  Future<void> _syncUserToFirestore(firebase_auth.User firebaseUser) async {
    final userDoc = _firestore.collection('users').doc(firebaseUser.uid);
    final docSnapshot = await userDoc.get();

    if (!docSnapshot.exists) {
      final user = User(
        id: firebaseUser.uid,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await userDoc.set(user.toFirestore());
    } else {
      await userDoc.update({
        'updated_at': FieldValue.serverTimestamp(),
      });
    }
  }
}

/// Extension on [firebase_auth.User] to convert to app [User].
extension on firebase_auth.User {
  /// Converts a [firebase_auth.User] to an app [User].
  User get toUser {
    return User(id: uid);
  }
}
