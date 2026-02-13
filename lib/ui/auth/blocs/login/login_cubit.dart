import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/repositories/authentication_repository.dart';
import '../../../../utils/logger.dart';
import 'login_state.dart';

/// Cubit that manages the login flow.
///
/// Handles authentication through multiple providers:
/// - Google Sign-In
/// - Apple Sign-In
/// - Email/Password
class LoginCubit extends Cubit<LoginState> {
  /// Creates a [LoginCubit].
  LoginCubit({
    required AuthenticationRepository authenticationRepository,
  })  : _authenticationRepository = authenticationRepository,
        super(const LoginState.initial());

  final AuthenticationRepository _authenticationRepository;
  final _logger = const Logger('LoginCubit');

  /// Signs in with Google.
  ///
  /// Emits [LoginState.loading] while the operation is in progress.
  /// Emits [LoginState.success] if sign in succeeds.
  /// Emits [LoginState.failure] if sign in fails.
  Future<void> logInWithGoogle() async {
    emit(const LoginState.loading());
    try {
      await _authenticationRepository.logInWithGoogle();
      emit(const LoginState.success());
      _logger.info('User signed in with Google');
    } on LogInWithGoogleFailure catch (e) {
      _logger.error('Google sign in failed', e);
      emit(LoginState.failure(e.message));
    } catch (e) {
      _logger.error('Unexpected error during Google sign in', e);
      emit(const LoginState.failure('An unexpected error occurred.'));
    }
  }

  /// Signs in with Apple.
  ///
  /// Emits [LoginState.loading] while the operation is in progress.
  /// Emits [LoginState.success] if sign in succeeds.
  /// Emits [LoginState.failure] if sign in fails.
  Future<void> logInWithApple() async {
    emit(const LoginState.loading());
    try {
      await _authenticationRepository.logInWithApple();
      emit(const LoginState.success());
      _logger.info('User signed in with Apple');
    } on LogInWithAppleFailure catch (e) {
      _logger.error('Apple sign in failed', e);
      emit(LoginState.failure(e.message));
    } catch (e) {
      _logger.error('Unexpected error during Apple sign in', e);
      emit(const LoginState.failure('An unexpected error occurred.'));
    }
  }

  /// Signs in with email and password.
  ///
  /// Emits [LoginState.loading] while the operation is in progress.
  /// Emits [LoginState.success] if sign in succeeds.
  /// Emits [LoginState.failure] if sign in fails.
  Future<void> logInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    emit(const LoginState.loading());
    try {
      await _authenticationRepository.logInWithEmailAndPassword(
        email: email,
        password: password,
      );
      emit(const LoginState.success());
      _logger.info('User signed in with email');
    } on LogInWithEmailAndPasswordFailure catch (e) {
      _logger.error('Email/password sign in failed', e);
      emit(LoginState.failure(e.message));
    } catch (e) {
      _logger.error('Unexpected error during email/password sign in', e);
      emit(const LoginState.failure('An unexpected error occurred.'));
    }
  }

  /// Creates a new account with email and password.
  ///
  /// Emits [LoginState.loading] while the operation is in progress.
  /// Emits [LoginState.success] if sign up succeeds.
  /// Emits [LoginState.failure] if sign up fails.
  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    emit(const LoginState.loading());
    try {
      await _authenticationRepository.signUpWithEmailAndPassword(
        email: email,
        password: password,
      );
      emit(const LoginState.success());
      _logger.info('User signed up with email');
    } on SignUpWithEmailAndPasswordFailure catch (e) {
      _logger.error('Email/password sign up failed', e);
      emit(LoginState.failure(e.message));
    } catch (e) {
      _logger.error('Unexpected error during email/password sign up', e);
      emit(const LoginState.failure('An unexpected error occurred.'));
    }
  }

  /// Sends an OTP code to the provided phone number.
  ///
  /// Emits [LoginState.loading] while the operation is in progress.
  /// Emits [LoginState.phoneCodeSent] when the code is sent successfully.
  /// Emits [LoginState.failure] if sending the code fails.
  Future<void> sendPhoneCode(String phoneNumber) async {
    emit(const LoginState.loading());
    try {
      final verificationId = await _authenticationRepository.sendPhoneCode(
        phoneNumber,
      );
      emit(LoginState.phoneCodeSent(
        verificationId: verificationId,
        phoneNumber: phoneNumber,
      ));
      _logger.info('Phone code sent to $phoneNumber');
    } on PhoneAuthenticationFailure catch (e) {
      _logger.error('Phone code sending failed', e);
      emit(LoginState.failure(e.message));
    } catch (e) {
      _logger.error('Unexpected error during phone code sending', e);
      emit(const LoginState.failure('An unexpected error occurred.'));
    }
  }

  /// Verifies the OTP code and signs in the user.
  ///
  /// Emits [LoginState.loading] while the operation is in progress.
  /// Emits [LoginState.success] if verification succeeds.
  /// Emits [LoginState.failure] if verification fails.
  Future<void> verifyPhoneCode({
    required String verificationId,
    required String smsCode,
  }) async {
    emit(LoginState.loading(
      verificationId: verificationId,
    ));
    try {
      await _authenticationRepository.verifyPhoneCode(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      emit(const LoginState.success());
      _logger.info('Phone code verified successfully');
    } on VerifyPhoneCodeFailure catch (e) {
      _logger.error('Phone code verification failed', e);
      emit(LoginState.failure(
        e.message,
        verificationId: verificationId,
      ));
    } catch (e) {
      _logger.error('Unexpected error during phone code verification', e);
      emit(LoginState.failure(
        'An unexpected error occurred.',
        verificationId: verificationId,
      ));
    }
  }

  /// Resets the state to initial.
  void reset() {
    emit(const LoginState.initial());
  }
}
