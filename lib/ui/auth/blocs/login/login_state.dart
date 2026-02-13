import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_state.freezed.dart';

/// Represents the state of the login feature.
@freezed
class LoginState with _$LoginState {
  /// Initial state when the login screen is first loaded.
  const factory LoginState.initial({
    @Default(null) String? verificationId,
    @Default(null) String? phoneNumber,
  }) = _Initial;

  /// Loading state when an authentication operation is in progress.
  const factory LoginState.loading({
    @Default(null) String? verificationId,
    @Default(null) String? phoneNumber,
  }) = _Loading;

  /// Success state when authentication is successful.
  const factory LoginState.success({
    @Default(null) String? verificationId,
    @Default(null) String? phoneNumber,
  }) = _Success;

  /// Failure state when authentication fails.
  ///
  /// Contains an error [message] describing what went wrong.
  const factory LoginState.failure(
    String message, {
    @Default(null) String? verificationId,
    @Default(null) String? phoneNumber,
  }) = _Failure;

  /// Phone code sent state when OTP has been sent to the phone.
  ///
  /// Contains the [verificationId] needed for code verification
  /// and the [phoneNumber] that received the code.
  const factory LoginState.phoneCodeSent({
    required String verificationId,
    required String phoneNumber,
  }) = _PhoneCodeSent;
}
