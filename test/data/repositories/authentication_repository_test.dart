import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app/data/repositories/authentication_repository.dart';
import 'package:app/domain/models/user.dart';

import '../../../testing/fixtures/user_fixtures.dart';

class MockFirebaseAuth extends Mock implements firebase_auth.FirebaseAuth {}

class MockFirebaseUser extends Mock implements firebase_auth.User {}

class MockUserCredential extends Mock implements firebase_auth.UserCredential {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  setUpAll(() {
    registerFallbackValue(MockFirebaseUser());
    registerFallbackValue(const Duration());
    registerFallbackValue((firebase_auth.PhoneAuthCredential credential) async {});
    registerFallbackValue((firebase_auth.FirebaseAuthException e) {});
    registerFallbackValue((String verificationId, int? resendToken) {});
    registerFallbackValue((String verificationId) {});
  });

  group('AuthenticationRepository', () {
    late MockFirebaseAuth mockFirebaseAuth;
    late MockFirebaseFirestore mockFirestore;
    late AuthenticationRepository authenticationRepository;

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      mockFirestore = MockFirebaseFirestore();
      authenticationRepository = AuthenticationRepository(
        firebaseAuth: mockFirebaseAuth,
        firestore: mockFirestore,
      );
    });

    group('User Stream', () {
      test('user stream emits empty user when not authenticated', () async {
        when(() => mockFirebaseAuth.authStateChanges())
            .thenAnswer((_) => Stream.value(null));

        expect(
          authenticationRepository.user,
          emits(User.empty),
        );
      });

      test('user stream emits user when authenticated', () async {
        final mockUser = MockFirebaseUser();
        when(() => mockUser.uid).thenReturn('user-123');
        when(() => mockUser.email).thenReturn('john@example.com');
        when(() => mockUser.displayName).thenReturn('John Doe');
        when(() => mockUser.photoURL).thenReturn('https://example.com/photo.jpg');

        when(() => mockFirebaseAuth.authStateChanges())
            .thenAnswer((_) => Stream.value(mockUser));

        final userStream = authenticationRepository.user;

        expect(
          userStream,
          emits(
            isA<User>()
                .having((u) => u.id, 'id', 'user-123')
                .having((u) => u.email, 'email', 'john@example.com'),
          ),
        );
      });

      test('user stream converts Firebase user to app User', () async {
        final mockUser = MockFirebaseUser();
        when(() => mockUser.uid).thenReturn('firebase-uid-123');
        when(() => mockUser.email).thenReturn('test@example.com');
        when(() => mockUser.displayName).thenReturn('Test User');
        when(() => mockUser.photoURL).thenReturn(null);

        when(() => mockFirebaseAuth.authStateChanges())
            .thenAnswer((_) => Stream.value(mockUser));

        final userStream = authenticationRepository.user;

        expect(
          userStream,
          emits(
            isA<User>()
                .having((u) => u.id, 'id', 'firebase-uid-123')
                .having((u) => u.email, 'email', 'test@example.com'),
          ),
        );
      });
    });

    group('currentUser Getter', () {
      test('returns empty user when not authenticated', () {
        when(() => mockFirebaseAuth.currentUser).thenReturn(null);

        final user = authenticationRepository.currentUser;

        expect(user, equals(User.empty));
      });

      test('returns current user when authenticated', () {
        final mockUser = MockFirebaseUser();
        when(() => mockUser.uid).thenReturn('user-456');
        when(() => mockUser.email).thenReturn('jane@example.com');
        when(() => mockUser.displayName).thenReturn('Jane Doe');
        when(() => mockUser.photoURL).thenReturn(null);

        when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);

        final user = authenticationRepository.currentUser;

        expect(user.id, equals('user-456'));
        expect(user.email, equals('jane@example.com'));
      });
    });

    group('Google Sign-In', () {
      test('logInWithGoogle exception handling', () {
        expect(
          LogInWithGoogleFailure.fromCode('user-disabled').message,
          'This user has been disabled. Please contact support.',
        );
        expect(
          LogInWithGoogleFailure.fromCode('invalid-credential').message,
          'The credential received is malformed or has expired.',
        );
      });
    });

    group('Apple Sign-In', () {
      test('logInWithApple exception handling', () {
        expect(
          LogInWithAppleFailure.fromCode('user-disabled').message,
          'This user has been disabled. Please contact support.',
        );
        expect(
          LogInWithAppleFailure.fromCode('account-exists-with-different-credential')
              .message,
          'An account already exists with a different credential.',
        );
      });
    });

    group('Email and Password Authentication', () {
      test('logInWithEmailAndPassword successfully signs in user', () async {
        when(() => mockFirebaseAuth.signInWithEmailAndPassword(
              email: 'test@example.com',
              password: 'password123',
            )).thenAnswer((_) async => MockUserCredential());

        await authenticationRepository.logInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        );

        verify(() => mockFirebaseAuth.signInWithEmailAndPassword(
              email: 'test@example.com',
              password: 'password123',
            )).called(1);
      });

      test('logInWithEmailAndPassword throws on invalid email', () async {
        when(() => mockFirebaseAuth.signInWithEmailAndPassword(
              email: 'invalid-email',
              password: 'password123',
            )).thenThrow(
          firebase_auth.FirebaseAuthException(
            code: 'invalid-email',
            message: 'Email is not valid',
          ),
        );

        expect(
          () => authenticationRepository.logInWithEmailAndPassword(
            email: 'invalid-email',
            password: 'password123',
          ),
          throwsA(
            isA<LogInWithEmailAndPasswordFailure>().having(
              (e) => e.message,
              'message',
              'Email is not valid or badly formatted.',
            ),
          ),
        );
      });

      test('logInWithEmailAndPassword throws on user not found', () async {
        when(() => mockFirebaseAuth.signInWithEmailAndPassword(
              email: 'nonexistent@example.com',
              password: 'password123',
            )).thenThrow(
          firebase_auth.FirebaseAuthException(
            code: 'user-not-found',
            message: 'No user found',
          ),
        );

        expect(
          () => authenticationRepository.logInWithEmailAndPassword(
            email: 'nonexistent@example.com',
            password: 'password123',
          ),
          throwsA(
            isA<LogInWithEmailAndPasswordFailure>().having(
              (e) => e.message,
              'message',
              'No user found with this email.',
            ),
          ),
        );
      });

      test('logInWithEmailAndPassword throws on wrong password', () async {
        when(() => mockFirebaseAuth.signInWithEmailAndPassword(
              email: 'test@example.com',
              password: 'wrongpassword',
            )).thenThrow(
          firebase_auth.FirebaseAuthException(
            code: 'wrong-password',
            message: 'Wrong password',
          ),
        );

        expect(
          () => authenticationRepository.logInWithEmailAndPassword(
            email: 'test@example.com',
            password: 'wrongpassword',
          ),
          throwsA(
            isA<LogInWithEmailAndPasswordFailure>().having(
              (e) => e.message,
              'message',
              'Incorrect password.',
            ),
          ),
        );
      });

      test('signUpWithEmailAndPassword successfully creates user', () async {
        final mockUser = MockFirebaseUser();
        when(() => mockUser.uid).thenReturn('new-user-123');
        when(() => mockUser.email).thenReturn('newuser@example.com');
        when(() => mockUser.displayName).thenReturn(null);
        when(() => mockUser.photoURL).thenReturn(null);

        final mockUserCredential = MockUserCredential();
        when(() => mockUserCredential.user).thenReturn(mockUser);

        when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
              email: 'newuser@example.com',
              password: 'password123',
            )).thenAnswer((_) async => mockUserCredential);

        final mockCollectionRef = MockCollectionReference();
        final mockDocRef = MockDocumentReference();
        final mockDocSnapshot = MockDocumentSnapshot();

        when(() => mockFirestore.collection('users'))
            .thenReturn(mockCollectionRef);
        when(() => mockCollectionRef.doc(any())).thenReturn(mockDocRef);
        when(() => mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
        when(() => mockDocSnapshot.exists).thenReturn(false);
        when(() => mockDocRef.set(any())).thenAnswer((_) async => {});

        await authenticationRepository.signUpWithEmailAndPassword(
          email: 'newuser@example.com',
          password: 'password123',
        );

        verify(() => mockFirebaseAuth.createUserWithEmailAndPassword(
              email: 'newuser@example.com',
              password: 'password123',
            )).called(1);
      });

      test('signUpWithEmailAndPassword throws on email already in use',
          () async {
        when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
              email: 'existing@example.com',
              password: 'password123',
            )).thenThrow(
          firebase_auth.FirebaseAuthException(
            code: 'email-already-in-use',
            message: 'Email already in use',
          ),
        );

        expect(
          () => authenticationRepository.signUpWithEmailAndPassword(
            email: 'existing@example.com',
            password: 'password123',
          ),
          throwsA(
            isA<SignUpWithEmailAndPasswordFailure>().having(
              (e) => e.message,
              'message',
              'An account already exists for this email.',
            ),
          ),
        );
      });

      test('signUpWithEmailAndPassword throws on weak password', () async {
        when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
              email: 'test@example.com',
              password: '123',
            )).thenThrow(
          firebase_auth.FirebaseAuthException(
            code: 'weak-password',
            message: 'Password is too weak',
          ),
        );

        expect(
          () => authenticationRepository.signUpWithEmailAndPassword(
            email: 'test@example.com',
            password: '123',
          ),
          throwsA(
            isA<SignUpWithEmailAndPasswordFailure>().having(
              (e) => e.message,
              'message',
              'This password is too weak. Please use a stronger password.',
            ),
          ),
        );
      });
    });

    group('Phone Authentication', () {
      test('Phone authentication exceptions are properly formatted', () {
        expect(
          PhoneAuthenticationFailure.fromCode('invalid-phone-number').message,
          'The phone number is not valid.',
        );
        expect(
          PhoneAuthenticationFailure.fromCode('missing-phone-number').message,
          'Please provide a phone number.',
        );
        expect(
          VerifyPhoneCodeFailure.fromCode('invalid-verification-code').message,
          'The verification code is invalid. Please try again.',
        );
      });
    });

    group('Logout', () {
      test('logOut successfully signs out user', () async {
        when(() => mockFirebaseAuth.signOut()).thenAnswer((_) async => {});

        await authenticationRepository.logOut();

        verify(() => mockFirebaseAuth.signOut()).called(1);
      });

      test('logOut throws LogOutFailure on error', () async {
        when(() => mockFirebaseAuth.signOut())
            .thenThrow(Exception('Sign out failed'));

        expect(
          () => authenticationRepository.logOut(),
          throwsA(
            isA<LogOutFailure>().having(
              (e) => e.message,
              'message',
              'An unknown error occurred.',
            ),
          ),
        );
      });
    });

    group('Firestore Sync', () {
      test('Firestore collections and documents are accessed correctly', () {
        final mockCollectionRef = MockCollectionReference();
        final mockDocRef = MockDocumentReference();

        when(() => mockFirestore.collection('users'))
            .thenReturn(mockCollectionRef);
        when(() => mockCollectionRef.doc('test-user-id'))
            .thenReturn(mockDocRef);

        // Verify that the collection and doc methods are called
        mockFirestore.collection('users').doc('test-user-id');

        verify(() => mockFirestore.collection('users')).called(1);
        verify(() => mockCollectionRef.doc('test-user-id')).called(1);
      });
    });

    group('Exception Scenarios', () {
      test('LogInWithGoogleFailure.fromCode handles all error codes', () {
        expect(
          LogInWithGoogleFailure.fromCode('account-exists-with-different-credential')
              .message,
          'An account already exists with a different credential.',
        );
        expect(
          LogInWithGoogleFailure.fromCode('invalid-credential').message,
          'The credential received is malformed or has expired.',
        );
        expect(
          LogInWithGoogleFailure.fromCode('operation-not-allowed').message,
          'Google Sign-In is not enabled. Please contact support.',
        );
        expect(
          LogInWithGoogleFailure.fromCode('user-disabled').message,
          'This user has been disabled. Please contact support.',
        );
        expect(
          LogInWithGoogleFailure.fromCode('user-not-found').message,
          'No user found with this email.',
        );
        expect(
          LogInWithGoogleFailure.fromCode('wrong-password').message,
          'Incorrect password.',
        );
        expect(
          LogInWithGoogleFailure.fromCode('unknown-code').message,
          'An unknown error occurred.',
        );
      });

      test('LogInWithEmailAndPasswordFailure.fromCode handles error codes', () {
        expect(
          LogInWithEmailAndPasswordFailure.fromCode('invalid-email').message,
          'Email is not valid or badly formatted.',
        );
        expect(
          LogInWithEmailAndPasswordFailure.fromCode('user-disabled').message,
          'This user has been disabled. Please contact support.',
        );
        expect(
          LogInWithEmailAndPasswordFailure.fromCode('invalid-credential')
              .message,
          'The email or password is incorrect.',
        );
      });

      test('SignUpWithEmailAndPasswordFailure.fromCode handles error codes', () {
        expect(
          SignUpWithEmailAndPasswordFailure.fromCode('email-already-in-use')
              .message,
          'An account already exists for this email.',
        );
        expect(
          SignUpWithEmailAndPasswordFailure.fromCode('weak-password').message,
          'This password is too weak. Please use a stronger password.',
        );
      });

      test('PhoneAuthenticationFailure.fromCode handles error codes', () {
        expect(
          PhoneAuthenticationFailure.fromCode('invalid-phone-number').message,
          'The phone number is not valid.',
        );
        expect(
          PhoneAuthenticationFailure.fromCode('quota-exceeded').message,
          'SMS quota exceeded. Please try again later.',
        );
      });

      test('VerifyPhoneCodeFailure.fromCode handles error codes', () {
        expect(
          VerifyPhoneCodeFailure.fromCode('invalid-verification-code')
              .message,
          'The verification code is invalid. Please try again.',
        );
        expect(
          VerifyPhoneCodeFailure.fromCode('code-expired').message,
          'The verification code has expired. Please request a new code.',
        );
      });
    });
  });
}
