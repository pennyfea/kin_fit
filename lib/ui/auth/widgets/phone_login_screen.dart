import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/authentication_repository.dart';
import '../../../utils/extensions/context_extensions.dart';
import '../../core/widgets/primary_button.dart';
import '../blocs/login/login_cubit.dart';
import '../blocs/login/login_state.dart';
import 'otp_input.dart';
import 'phone_input.dart';

/// The phone login screen for the application.
///
/// Provides a two-step authentication flow:
/// 1. Phone number input - User enters their phone number
/// 2. OTP verification - User enters the 6-digit code sent via SMS
class PhoneLoginScreen extends StatelessWidget {
  /// Creates a [PhoneLoginScreen].
  const PhoneLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(
        authenticationRepository: context.read<AuthenticationRepository>(),
      ),
      child: const _PhoneLoginView(),
    );
  }
}

class _PhoneLoginView extends StatefulWidget {
  const _PhoneLoginView();

  @override
  State<_PhoneLoginView> createState() => _PhoneLoginViewState();
}

class _PhoneLoginViewState extends State<_PhoneLoginView> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _phoneFocusNode = FocusNode();

  String _completePhoneNumber = '';
  Timer? _resendTimer;
  int _resendCountdown = 0;

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _resendCountdown = 60;
    });

    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _resendCountdown--;
      });

      if (_resendCountdown <= 0) {
        timer.cancel();
      }
    });
  }

  Future<void> _sendPhoneCode() async {
    if (!_formKey.currentState!.validate()) return;

    context.dismissKeyboard();

    // Start the resend timer
    _startResendTimer();

    await context.read<LoginCubit>().sendPhoneCode(_completePhoneNumber);
  }

  Future<void> _resendPhoneCode() async {
    if (_resendCountdown > 0) return;

    _startResendTimer();

    await context.read<LoginCubit>().sendPhoneCode(_completePhoneNumber);
  }

  Future<void> _verifyPhoneCode(String verificationId, String smsCode) async {
    await context.read<LoginCubit>().verifyPhoneCode(
          verificationId: verificationId,
          smsCode: smsCode,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kin'),
      ),
      body: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) {
          state.whenOrNull(
            failure: (message, _, __) {
              context.showErrorSnackBar(message);
            },
            phoneCodeSent: (_, __) {
              context.showSnackBar('Verification code sent!');
            },
          );
        },
        builder: (context, state) {
          return state.maybeWhen(
            // Show OTP verification screen
            phoneCodeSent: (verificationId, phoneNumber) =>
                _buildOtpVerificationView(
              context,
              state,
              verificationId,
              phoneNumber,
            ),
            // Show OTP verification screen with error
            failure: (message, verificationId, phoneNumber) {
              if (verificationId != null) {
                return _buildOtpVerificationView(
                  context,
                  state,
                  verificationId,
                  phoneNumber ?? _completePhoneNumber,
                );
              }
              return _buildPhoneInputView(context, state);
            },
            // Show phone input screen for all other states
            orElse: () => _buildPhoneInputView(context, state),
          );
        },
      ),
    );
  }

  Widget _buildPhoneInputView(BuildContext context, LoginState state) {
    final isLoading = state.maybeWhen(
      loading: (_, __) => true,
      orElse: () => false,
    );

    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icon
                Icon(
                  Icons.phone_android,
                  size: 80,
                  color: context.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Enter Phone Number',
                  style: context.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'We will send you a verification code',
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Phone Input
                PhoneInput(
                  controller: _phoneController,
                  focusNode: _phoneFocusNode,
                  enabled: !isLoading,
                  onChanged: (phoneNumber) {
                    _completePhoneNumber = phoneNumber;
                  },
                  onSubmitted: (_) => _sendPhoneCode(),
                ),
                const SizedBox(height: 24),

                // Send Code Button
                PrimaryButton(
                  onPressed: _sendPhoneCode,
                  text: 'Send Code',
                  isLoading: isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtpVerificationView(
    BuildContext context,
    LoginState state,
    String verificationId,
    String phoneNumber,
  ) {
    final isLoading = state.maybeWhen(
      loading: (_, __) => true,
      orElse: () => false,
    );

    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon
              Icon(
                Icons.sms_outlined,
                size: 80,
                color: context.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Enter Verification Code',
                style: context.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'We sent a code to $phoneNumber',
                style: context.textTheme.bodyLarge?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // OTP Input
              OtpInput(
                enabled: !isLoading,
                onCompleted: (code) {
                  _verifyPhoneCode(verificationId, code);
                },
              ),
              const SizedBox(height: 32),

              // Resend Code Button
              if (_resendCountdown > 0)
                Text(
                  'Resend code in $_resendCountdown seconds',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                )
              else
                TextButton(
                  onPressed: isLoading ? null : _resendPhoneCode,
                  child: const Text('Resend Code'),
                ),
              const SizedBox(height: 16),

              // Change Phone Number
              TextButton(
                onPressed: isLoading
                    ? null
                    : () {
                        context.read<LoginCubit>().reset();
                        _resendTimer?.cancel();
                        setState(() {
                          _resendCountdown = 0;
                        });
                      },
                child: const Text('Change Phone Number'),
              ),

              // Loading Indicator
              if (isLoading) ...[
                const SizedBox(height: 24),
                const Center(
                  child: CircularProgressIndicator(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
