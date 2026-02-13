import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../domain/models/user.dart';

/// Exception thrown when login with Google fails.
class LogInWithGoogleFailure implements Exception {
  /// Creates a [LogInWithGoogleFailure] with an optional message.
  const LogInWithGoogleFailure([
    this.message = 'An unknown error occurred.',
  ]);

  /// Creates a [LogInWithGoogleFailure] from a Firebase error code.
  factory LogInWithGoogleFailure.fromCode(String code) {
    switch (code) {
      case 'account-exists-with-different-credential':
        return const LogInWithGoogleFailure(
          'An account already exists with a different credential.',
        );
      case 'invalid-credential':
        return const LogInWithGoogleFailure(
          'The credential received is malformed or has expired.',
        );
      case 'operation-not-allowed':
        return const LogInWithGoogleFailure(
          'Google Sign-In is not enabled. Please contact support.',
        );
      case 'user-disabled':
        return const LogInWithGoogleFailure(
          'This user has been disabled. Please contact support.',
        );
      case 'user-not-found':
        return const LogInWithGoogleFailure(
          'No user found with this email.',
        );
      case 'wrong-password':
        return const LogInWithGoogleFailure(
          'Incorrect password.',
        );
      case 'invalid-verification-code':
        return const LogInWithGoogleFailure(
          'The verification code is invalid.',
        );
      case 'invalid-verification-id':
        return const LogInWithGoogleFailure(
          'The verification ID is invalid.',
        );
      default:
        return const LogInWithGoogleFailure();
    }
  }

  /// The error message.
  final String message;
}

/// Exception thrown when login with Apple fails.
class LogInWithAppleFailure implements Exception {
  /// Creates a [LogInWithAppleFailure] with an optional message.
  const LogInWithAppleFailure([
    this.message = 'An unknown error occurred.',
  ]);

  /// Creates a [LogInWithAppleFailure] from a Firebase error code.
  factory LogInWithAppleFailure.fromCode(String code) {
    switch (code) {
      case 'account-exists-with-different-credential':
        return const LogInWithAppleFailure(
          'An account already exists with a different credential.',
        );
      case 'invalid-credential':
        return const LogInWithAppleFailure(
          'The credential received is malformed or has expired.',
        );
      case 'operation-not-allowed':
        return const LogInWithAppleFailure(
          'Apple Sign-In is not enabled. Please contact support.',
        );
      case 'user-disabled':
        return const LogInWithAppleFailure(
          'This user has been disabled. Please contact support.',
        );
      default:
        return const LogInWithAppleFailure();
    }
  }

  /// The error message.
  final String message;
}

/// Exception thrown when login with email and password fails.
class LogInWithEmailAndPasswordFailure implements Exception {
  /// Creates a [LogInWithEmailAndPasswordFailure] with an optional message.
  const LogInWithEmailAndPasswordFailure([
    this.message = 'An unknown error occurred.',
  ]);

  /// Creates a [LogInWithEmailAndPasswordFailure] from a Firebase error code.
  factory LogInWithEmailAndPasswordFailure.fromCode(String code) {
    switch (code) {
      case 'invalid-email':
        return const LogInWithEmailAndPasswordFailure(
          'Email is not valid or badly formatted.',
        );
      case 'user-disabled':
        return const LogInWithEmailAndPasswordFailure(
          'This user has been disabled. Please contact support.',
        );
      case 'user-not-found':
        return const LogInWithEmailAndPasswordFailure(
          'No user found with this email.',
        );
      case 'wrong-password':
        return const LogInWithEmailAndPasswordFailure(
          'Incorrect password.',
        );
      case 'invalid-credential':
        return const LogInWithEmailAndPasswordFailure(
          'The email or password is incorrect.',
        );
      default:
        return const LogInWithEmailAndPasswordFailure();
    }
  }

  /// The error message.
  final String message;
}

/// Exception thrown when sign up with email and password fails.
class SignUpWithEmailAndPasswordFailure implements Exception {
  /// Creates a [SignUpWithEmailAndPasswordFailure] with an optional message.
  const SignUpWithEmailAndPasswordFailure([
    this.message = 'An unknown error occurred.',
  ]);

  /// Creates a [SignUpWithEmailAndPasswordFailure] from a Firebase error code.
  factory SignUpWithEmailAndPasswordFailure.fromCode(String code) {
    switch (code) {
      case 'invalid-email':
        return const SignUpWithEmailAndPasswordFailure(
          'Email is not valid or badly formatted.',
        );
      case 'user-disabled':
        return const SignUpWithEmailAndPasswordFailure(
          'This user has been disabled. Please contact support.',
        );
      case 'email-already-in-use':
        return const SignUpWithEmailAndPasswordFailure(
          'An account already exists for this email.',
        );
      case 'operation-not-allowed':
        return const SignUpWithEmailAndPasswordFailure(
          'Email/password accounts are not enabled. Please contact support.',
        );
      case 'weak-password':
        return const SignUpWithEmailAndPasswordFailure(
          'This password is too weak. Please use a stronger password.',
        );
      default:
        return const SignUpWithEmailAndPasswordFailure();
    }
  }

  /// The error message.
  final String message;
}

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

/// Repository that manages user authentication.
///
/// This repository handles all authentication operations including:
/// - Google Sign-In
/// - Apple Sign-In
/// - Email/Password authentication
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

  /// Signs in with Google.
  ///
  /// Returns immediately if the user cancels the sign-in flow.
  /// Throws a [LogInWithGoogleFailure] if an exception occurs.
  Future<void> logInWithGoogle() async {
    try {
      // Initialize Google Sign-In if not already initialized
      if (!GoogleSignIn.instance.supportsAuthenticate()) {
        throw const LogInWithGoogleFailure(
          'Google Sign-In not supported on this platform.',
        );
      }

      // Authenticate with Google
      final googleUser = await GoogleSignIn.instance.authenticate();

      // Get authentication tokens
      final googleAuth = googleUser.authentication;
      final auth = googleUser.authorizationClient;

      // Request OAuth access token
      final scopes = <String>[
        'email',
        'profile',
      ];
      final authorization = await auth.authorizationForScopes(scopes);

      if (authorization?.accessToken == null) {
        throw const LogInWithGoogleFailure('Failed to get access token.');
      }

      // Create Firebase credential from Google tokens
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: authorization!.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      if (userCredential.user != null) {
        await _syncUserToFirestore(userCredential.user!);
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw LogInWithGoogleFailure.fromCode(e.code);
    } catch (e) {
      throw const LogInWithGoogleFailure();
    }
  }

  /// Signs in with Apple.
  ///
  /// Returns immediately if the user cancels the sign-in flow.
  /// Throws a [LogInWithAppleFailure] if an exception occurs.
  Future<void> logInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = firebase_auth.OAuthProvider('apple.com')
          .credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        oauthCredential,
      );

      if (userCredential.user != null) {
        await _syncUserToFirestore(
          userCredential.user!,
          appleFirstName: appleCredential.givenName,
          appleLastName: appleCredential.familyName,
        );
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw LogInWithAppleFailure.fromCode(e.code);
    } catch (e) {
      throw const LogInWithAppleFailure();
    }
  }

  /// Signs in with email and password.
  ///
  /// Throws a [LogInWithEmailAndPasswordFailure] if an exception occurs.
  Future<void> logInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw LogInWithEmailAndPasswordFailure.fromCode(e.code);
    } catch (e) {
      throw const LogInWithEmailAndPasswordFailure();
    }
  }

  /// Creates a new user with email and password.
  ///
  /// Throws a [SignUpWithEmailAndPasswordFailure] if an exception occurs.
  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await _syncUserToFirestore(userCredential.user!);
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw SignUpWithEmailAndPasswordFailure.fromCode(e.code);
    } catch (e) {
      throw const SignUpWithEmailAndPasswordFailure();
    }
  }

  /// Signs out the current user.
  ///
  /// Throws a [LogOutFailure] if an exception occurs.
  Future<void> logOut() async {
    try {
      await _firebaseAuth.signOut();
      // Note: Google Sign-In disconnect is handled automatically by Firebase Auth
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
  Future<void> _syncUserToFirestore(
    firebase_auth.User firebaseUser, {
    String? appleFirstName,
    String? appleLastName,
  }) async {
    final userDoc = _firestore.collection('users').doc(firebaseUser.uid);
    final docSnapshot = await userDoc.get();

    if (!docSnapshot.exists) {
      // Create new user document
      final user = User(
        id: firebaseUser.uid,
        email: firebaseUser.email,
        firstName: appleFirstName ?? firebaseUser.displayName?.split(' ').first,
        lastName: appleLastName ?? firebaseUser.displayName?.split(' ').last,
        photoUrl: firebaseUser.photoURL,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await userDoc.set(user.toFirestore());
    } else {
      // Update existing user document
      await userDoc.update({
        'updated_at': FieldValue.serverTimestamp(),
        if (firebaseUser.email != null) 'email': firebaseUser.email,
        if (firebaseUser.photoURL != null) 'photo_url': firebaseUser.photoURL,
      });
    }
  }
}

/// Extension on [firebase_auth.User] to convert to app [User].
extension on firebase_auth.User {
  /// Converts a [firebase_auth.User] to an app [User].
  User get toUser {
    return User(
      id: uid,
      email: email,
      firstName: displayName?.split(' ').first,
      lastName: displayName?.split(' ').last,
      photoUrl: photoURL,
    );
  }
}
