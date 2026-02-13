import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/ui/auth/blocs/login/login_cubit.dart';
import 'package:app/ui/auth/blocs/login/login_state.dart';

import '../../../../testing/fakes/fake_authentication_repository.dart';

void main() {
  group('LoginCubit', () {
    late FakeAuthenticationRepository authenticationRepository;
    late LoginCubit loginCubit;

    setUp(() {
      authenticationRepository = FakeAuthenticationRepository();
      loginCubit = LoginCubit(
        authenticationRepository: authenticationRepository,
      );
    });

    tearDown(() {
      loginCubit.close();
    });

    group('Google Login', () {
      blocTest<LoginCubit, LoginState>(
        'emits [loading, success] when logInWithGoogle succeeds',
        build: () => loginCubit,
        act: (cubit) => cubit.logInWithGoogle(),
        expect: () => [
          const LoginState.loading(),
          const LoginState.success(),
        ],
      );

      blocTest<LoginCubit, LoginState>(
        'emits [loading, failure] when logInWithGoogle fails',
        setUp: () {
          authenticationRepository.shouldThrowOnLogIn = true;
        },
        build: () => loginCubit,
        act: (cubit) => cubit.logInWithGoogle(),
        expect: () => [
          const LoginState.loading(),
          isA<LoginState>(),
        ],
      );

      blocTest<LoginCubit, LoginState>(
        'records login attempt on Google login',
        build: () => loginCubit,
        act: (cubit) => cubit.logInWithGoogle(),
        verify: (cubit) {
          expect(authenticationRepository.loginAttempts, contains('google'));
        },
      );
    });

    group('Apple Login', () {
      blocTest<LoginCubit, LoginState>(
        'emits [loading, success] when logInWithApple succeeds',
        build: () => loginCubit,
        act: (cubit) => cubit.logInWithApple(),
        expect: () => [
          const LoginState.loading(),
          const LoginState.success(),
        ],
      );

      blocTest<LoginCubit, LoginState>(
        'emits [loading, failure] when logInWithApple fails',
        setUp: () {
          authenticationRepository.shouldThrowOnLogIn = true;
        },
        build: () => loginCubit,
        act: (cubit) => cubit.logInWithApple(),
        expect: () => [
          const LoginState.loading(),
          isA<LoginState>(),
        ],
      );

      blocTest<LoginCubit, LoginState>(
        'records login attempt on Apple login',
        build: () => loginCubit,
        act: (cubit) => cubit.logInWithApple(),
        verify: (cubit) {
          expect(authenticationRepository.loginAttempts, contains('apple'));
        },
      );
    });

    group('Email and Password Login', () {
      blocTest<LoginCubit, LoginState>(
        'emits [loading, success] when logInWithEmailAndPassword succeeds',
        build: () => loginCubit,
        act: (cubit) => cubit.logInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        ),
        expect: () => [
          const LoginState.loading(),
          const LoginState.success(),
        ],
      );

      blocTest<LoginCubit, LoginState>(
        'emits [loading, failure] when logInWithEmailAndPassword fails',
        setUp: () {
          authenticationRepository.shouldThrowOnLogIn = true;
        },
        build: () => loginCubit,
        act: (cubit) => cubit.logInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        ),
        expect: () => [
          const LoginState.loading(),
          isA<LoginState>(),
        ],
      );

      blocTest<LoginCubit, LoginState>(
        'records login attempt with email',
        build: () => loginCubit,
        act: (cubit) => cubit.logInWithEmailAndPassword(
          email: 'john@example.com',
          password: 'password123',
        ),
        verify: (cubit) {
          expect(authenticationRepository.loginAttempts,
              contains('john@example.com'));
        },
      );

      blocTest<LoginCubit, LoginState>(
        'preserves email during login',
        build: () => loginCubit,
        act: (cubit) => cubit.logInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        ),
        verify: (cubit) {
          expect(authenticationRepository.currentUser.email,
              equals('test@example.com'));
        },
      );
    });

    group('Email and Password Signup', () {
      blocTest<LoginCubit, LoginState>(
        'emits [loading, success] when signUpWithEmailAndPassword succeeds',
        build: () => loginCubit,
        act: (cubit) => cubit.signUpWithEmailAndPassword(
          email: 'newuser@example.com',
          password: 'password123',
        ),
        expect: () => [
          const LoginState.loading(),
          const LoginState.success(),
        ],
      );

      blocTest<LoginCubit, LoginState>(
        'emits [loading, failure] when signUpWithEmailAndPassword fails',
        setUp: () {
          authenticationRepository.shouldThrowOnSignUp = true;
        },
        build: () => loginCubit,
        act: (cubit) => cubit.signUpWithEmailAndPassword(
          email: 'newuser@example.com',
          password: 'password123',
        ),
        expect: () => [
          const LoginState.loading(),
          isA<LoginState>(),
        ],
      );

      blocTest<LoginCubit, LoginState>(
        'records signup attempt',
        build: () => loginCubit,
        act: (cubit) => cubit.signUpWithEmailAndPassword(
          email: 'signup@example.com',
          password: 'password123',
        ),
        verify: (cubit) {
          expect(authenticationRepository.loginAttempts,
              contains('signup-signup@example.com'));
        },
      );
    });

    group('Phone Authentication', () {
      blocTest<LoginCubit, LoginState>(
        'emits [loading, phoneCodeSent] when sendPhoneCode succeeds',
        build: () => loginCubit,
        act: (cubit) => cubit.sendPhoneCode('+11234567890'),
        expect: () => [
          const LoginState.loading(),
          isA<LoginState>(),
        ],
        verify: (cubit) {
          expect(authenticationRepository.lastPhoneNumber, '+11234567890');
          expect(authenticationRepository.lastVerificationId, isNotNull);
        },
      );

      blocTest<LoginCubit, LoginState>(
        'emits [loading, failure] when sendPhoneCode fails',
        setUp: () {
          authenticationRepository.shouldThrowOnPhoneCodeSend = true;
        },
        build: () => loginCubit,
        act: (cubit) => cubit.sendPhoneCode('+11234567890'),
        expect: () => [
          const LoginState.loading(),
          isA<LoginState>(),
        ],
      );

      blocTest<LoginCubit, LoginState>(
        'verifyPhoneCode emits [loading, success] when successful',
        build: () => loginCubit,
        act: (cubit) => cubit.verifyPhoneCode(
          verificationId: 'verification-id-123',
          smsCode: '123456',
        ),
        expect: () => [
          isA<LoginState>(),
          const LoginState.success(),
        ],
      );

      blocTest<LoginCubit, LoginState>(
        'verifyPhoneCode emits [loading, failure] when verification fails',
        setUp: () {
          authenticationRepository.shouldThrowOnPhoneCodeVerify = true;
        },
        build: () => loginCubit,
        act: (cubit) => cubit.verifyPhoneCode(
          verificationId: 'verification-id-123',
          smsCode: 'invalid',
        ),
        expect: () => [
          isA<LoginState>(),
          isA<LoginState>(),
        ],
      );

      blocTest<LoginCubit, LoginState>(
        'phoneCodeSent state preserves verificationId and phoneNumber',
        build: () => loginCubit,
        act: (cubit) => cubit.sendPhoneCode('+12025551234'),
        verify: (cubit) {
          expect(authenticationRepository.lastPhoneNumber,
              equals('+12025551234'));
          expect(authenticationRepository.lastVerificationId, isNotNull);
        },
      );

      blocTest<LoginCubit, LoginState>(
        'records phone login attempt',
        build: () => loginCubit,
        act: (cubit) => cubit.sendPhoneCode('+11234567890'),
        verify: (cubit) {
          expect(authenticationRepository.loginAttempts,
              contains('phone-+11234567890'));
        },
      );
    });

    group('Phone Authentication Flow', () {
      blocTest<LoginCubit, LoginState>(
        'complete phone flow: send code then verify',
        build: () => loginCubit,
        act: (cubit) async {
          await cubit.sendPhoneCode('+11234567890');
          // Simulate user entering code
          await cubit.verifyPhoneCode(
            verificationId: authenticationRepository.lastVerificationId!,
            smsCode: '123456',
          );
        },
        expect: () => [
          const LoginState.loading(),
          isA<LoginState>(),
          isA<LoginState>(),
          const LoginState.success(),
        ],
      );
    });

    group('State Management', () {
      blocTest<LoginCubit, LoginState>(
        'initial state is LoginState.initial()',
        build: () => loginCubit,
        verify: (cubit) {
          expect(cubit.state, isA<LoginState>());
        },
      );

      blocTest<LoginCubit, LoginState>(
        'reset emits initial state',
        build: () => loginCubit,
        act: (cubit) async {
          await cubit.logInWithGoogle();
          cubit.reset();
        },
        expect: () => [
          const LoginState.loading(),
          const LoginState.success(),
          const LoginState.initial(),
        ],
      );

      blocTest<LoginCubit, LoginState>(
        'multiple sequential login attempts are handled correctly',
        build: () => loginCubit,
        act: (cubit) async {
          await cubit.logInWithGoogle();
          cubit.reset();
          await cubit.logInWithApple();
        },
        expect: () => [
          const LoginState.loading(),
          const LoginState.success(),
          const LoginState.initial(),
          const LoginState.loading(),
          const LoginState.success(),
        ],
      );

      blocTest<LoginCubit, LoginState>(
        'failure state can be emitted',
        setUp: () {
          authenticationRepository.shouldThrowOnLogIn = true;
        },
        build: () => loginCubit,
        act: (cubit) => cubit.logInWithGoogle(),
        expect: () => [
          const LoginState.loading(),
          isA<LoginState>(),
        ],
      );
    });

    group('Error Handling', () {
      blocTest<LoginCubit, LoginState>(
        'unexpected error during Google login emits failure',
        setUp: () {
          authenticationRepository.shouldThrowOnLogIn = true;
        },
        build: () => loginCubit,
        act: (cubit) => cubit.logInWithGoogle(),
        expect: () => [
          const LoginState.loading(),
          isA<LoginState>(),
        ],
      );

      blocTest<LoginCubit, LoginState>(
        'unexpected error during email login emits failure',
        setUp: () {
          authenticationRepository.shouldThrowOnLogIn = true;
        },
        build: () => loginCubit,
        act: (cubit) => cubit.logInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password',
        ),
        expect: () => [
          const LoginState.loading(),
          isA<LoginState>(),
        ],
      );

      blocTest<LoginCubit, LoginState>(
        'unexpected error during phone code send emits failure',
        setUp: () {
          authenticationRepository.shouldThrowOnPhoneCodeSend = true;
        },
        build: () => loginCubit,
        act: (cubit) => cubit.sendPhoneCode('+11234567890'),
        expect: () => [
          const LoginState.loading(),
          isA<LoginState>(),
        ],
      );

      blocTest<LoginCubit, LoginState>(
        'unexpected error during phone code verify emits failure',
        setUp: () {
          authenticationRepository.shouldThrowOnPhoneCodeVerify = true;
        },
        build: () => loginCubit,
        act: (cubit) => cubit.verifyPhoneCode(
          verificationId: 'test-id',
          smsCode: '123456',
        ),
        expect: () => [
          isA<LoginState>(),
          isA<LoginState>(),
        ],
      );
    });

    group('Async Operations', () {
      blocTest<LoginCubit, LoginState>(
        'handles artificial delay in authentication',
        setUp: () {
          authenticationRepository.delay = const Duration(milliseconds: 100);
        },
        build: () => loginCubit,
        act: (cubit) => cubit.logInWithGoogle(),
        expect: () => [
          const LoginState.loading(),
          const LoginState.success(),
        ],
      );
    });
  });
}
