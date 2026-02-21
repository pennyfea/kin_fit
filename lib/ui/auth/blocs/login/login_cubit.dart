import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/repositories/authentication_repository.dart';
import '../../../../utils/logger.dart';
import 'login_state.dart';

/// Cubit that manages the phone authentication flow.
class LoginCubit extends Cubit<LoginState> {
  /// Creates a [LoginCubit].
  LoginCubit({
    required AuthenticationRepository authenticationRepository,
  })  : _authenticationRepository = authenticationRepository,
        super(const LoginState.initial());

  final AuthenticationRepository _authenticationRepository;
  final _logger = const Logger('LoginCubit');

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
      if (!isClosed) emit(const LoginState.success());
      _logger.info('Phone code verified successfully');
    } on VerifyPhoneCodeFailure catch (e) {
      _logger.error('Phone code verification failed', e);
      if (!isClosed) {
        emit(LoginState.failure(
          e.message,
          verificationId: verificationId,
        ));
      }
    } catch (e) {
      _logger.error('Unexpected error during phone code verification', e);
      if (!isClosed) {
        emit(LoginState.failure(
          'An unexpected error occurred.',
          verificationId: verificationId,
        ));
      }
    }
  }

  /// Resets the state to initial.
  void reset() {
    emit(const LoginState.initial());
  }
}
