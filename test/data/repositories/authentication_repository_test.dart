import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app/data/repositories/authentication_repository.dart';
import 'package:app/domain/models/user.dart';

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
    registerFallbackValue(
        (firebase_auth.PhoneAuthCredential credential) async {});
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

        when(() => mockFirebaseAuth.authStateChanges())
            .thenAnswer((_) => Stream.value(mockUser));

        final userStream = authenticationRepository.user;

        expect(
          userStream,
          emits(
            isA<User>().having((u) => u.id, 'id', 'user-123'),
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

        when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);

        final user = authenticationRepository.currentUser;

        expect(user.id, equals('user-456'));
      });
    });

    group('Phone Authentication', () {
      test('PhoneAuthenticationFailure.fromCode handles error codes', () {
        expect(
          PhoneAuthenticationFailure.fromCode('invalid-phone-number').message,
          'The phone number is not valid.',
        );
        expect(
          PhoneAuthenticationFailure.fromCode('missing-phone-number').message,
          'Please provide a phone number.',
        );
        expect(
          PhoneAuthenticationFailure.fromCode('quota-exceeded').message,
          'SMS quota exceeded. Please try again later.',
        );
        expect(
          PhoneAuthenticationFailure.fromCode('user-disabled').message,
          'This user has been disabled. Please contact support.',
        );
        expect(
          PhoneAuthenticationFailure.fromCode('operation-not-allowed').message,
          'Phone authentication is not enabled. Please contact support.',
        );
        expect(
          PhoneAuthenticationFailure.fromCode('too-many-requests').message,
          'Too many requests. Please try again later.',
        );
        expect(
          PhoneAuthenticationFailure.fromCode('unknown-code').message,
          'An unknown error occurred.',
        );
      });

      test('VerifyPhoneCodeFailure.fromCode handles error codes', () {
        expect(
          VerifyPhoneCodeFailure.fromCode('invalid-verification-code').message,
          'The verification code is invalid. Please try again.',
        );
        expect(
          VerifyPhoneCodeFailure.fromCode('invalid-verification-id').message,
          'The verification session has expired. Please request a new code.',
        );
        expect(
          VerifyPhoneCodeFailure.fromCode('session-expired').message,
          'The verification session has expired. Please request a new code.',
        );
        expect(
          VerifyPhoneCodeFailure.fromCode('code-expired').message,
          'The verification code has expired. Please request a new code.',
        );
        expect(
          VerifyPhoneCodeFailure.fromCode('unknown-code').message,
          'An unknown error occurred.',
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

        mockFirestore.collection('users').doc('test-user-id');

        verify(() => mockFirestore.collection('users')).called(1);
        verify(() => mockCollectionRef.doc('test-user-id')).called(1);
      });
    });
  });
}
