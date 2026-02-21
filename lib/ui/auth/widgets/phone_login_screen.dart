import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/authentication_repository.dart';
import '../../../utils/extensions/context_extensions.dart';
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
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
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
      ),
    );
  }

  Widget _buildPhoneInputView(BuildContext context, LoginState state) {
    final isLoading = state.maybeWhen(
      loading: (_, __) => true,
      orElse: () => false,
    );

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: context.colorScheme.primaryContainer.withValues(
                          alpha: 0.3,
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Icon(
                        Icons.bolt_rounded, // More energetic icon
                        size: 48,
                        color: context.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Never Miss\nA Workout.',
                      style: context.textTheme.displaySmall?.copyWith(
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Enter your phone number to join your squad and start your streak.',
                      style: context.textTheme.bodyLarge?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Phone Input
                    Container(
                      decoration: BoxDecoration(
                        color: context.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: context.colorScheme.outlineVariant.withValues(
                            alpha: 0.2,
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: PhoneInput(
                        controller: _phoneController,
                        focusNode: _phoneFocusNode,
                        enabled: !isLoading,
                        onChanged: (phoneNumber) {
                          _completePhoneNumber = phoneNumber;
                        },
                        onSubmitted: (_) => _sendPhoneCode(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom CTA Area
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: SizedBox(
              width: double.infinity,
              height: 64, // Taller, premium button
              child: ElevatedButton(
                onPressed: isLoading ? null : _sendPhoneCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colorScheme.primary,
                  foregroundColor: context.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  elevation: 0,
                ),
                child: isLoading
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            context.colorScheme.onPrimary,
                          ),
                        ),
                      )
                    : const Text('Continue'),
              ),
            ),
          ),
        ],
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
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button wrapper
                  GestureDetector(
                    onTap: isLoading
                        ? null
                        : () {
                            context.read<LoginCubit>().reset();
                            _resendTimer?.cancel();
                            setState(() {
                              _resendCountdown = 0;
                            });
                          },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: context.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text('Verify Code', style: context.textTheme.displaySmall),
                  const SizedBox(height: 16),
                  RichText(
                    text: TextSpan(
                      style: context.textTheme.bodyLarge?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                      children: [
                        const TextSpan(text: 'We sent a 6-digit code to\n'),
                        TextSpan(
                          text: phoneNumber,
                          style: TextStyle(
                            color: context.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),

                  // OTP Input
                  OtpInput(
                    enabled: !isLoading,
                    onCompleted: (code) {
                      _verifyPhoneCode(verificationId, code);
                    },
                  ),

                  const SizedBox(height: 48),

                  // Resend Action
                  Center(
                    child: _resendCountdown > 0
                        ? Text(
                            'Resend code in $_resendCountdown s',
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : TextButton(
                            onPressed: isLoading ? null : _resendPhoneCode,
                            style: TextButton.styleFrom(
                              foregroundColor: context.colorScheme.primary,
                            ),
                            child: const Text(
                              'Resend Code',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),

          // Loading Overlay State at bottom
          if (isLoading)
            Container(
              padding: const EdgeInsets.all(32),
              child: const CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
