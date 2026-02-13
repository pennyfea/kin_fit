import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/authentication_repository.dart';
import '../../../utils/extensions/context_extensions.dart';
import '../../core/widgets/primary_button.dart';
import '../blocs/login/login_cubit.dart';
import '../blocs/login/login_state.dart';
import 'email_input.dart';
import 'password_input.dart';

/// The login screen for the application.
///
/// Provides multiple authentication options:
/// - Email/Password
/// - Google Sign-In
/// - Apple Sign-In (iOS only)
class LoginScreen extends StatelessWidget {
  /// Creates a [LoginScreen].
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(
        authenticationRepository: context.read<AuthenticationRepository>(),
      ),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _isSignUpMode = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isSignUpMode = !_isSignUpMode;
    });
    context.read<LoginCubit>().reset();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    context.dismissKeyboard();

    final cubit = context.read<LoginCubit>();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (_isSignUpMode) {
      await cubit.signUpWithEmailAndPassword(
        email: email,
        password: password,
      );
    } else {
      await cubit.logInWithEmailAndPassword(
        email: email,
        password: password,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) {
          state.whenOrNull(
            failure: (message, _, __) {
              context.showErrorSnackBar(message);
            },
          );
        },
        builder: (context, state) {
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
                      // App Logo/Title
                      Icon(
                        Icons.lock_outline,
                        size: 80,
                        color: context.colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _isSignUpMode ? 'Create Account' : 'Welcome Back',
                        style: context.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isSignUpMode
                            ? 'Sign up to get started'
                            : 'Sign in to continue',
                        style: context.textTheme.bodyLarge?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),

                      // Email Input
                      EmailInput(
                        controller: _emailController,
                        focusNode: _emailFocusNode,
                        enabled: !isLoading,
                        onSubmitted: (_) {
                          _passwordFocusNode.requestFocus();
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password Input
                      PasswordInput(
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        enabled: !isLoading,
                        isSignUp: _isSignUpMode,
                        onSubmitted: (_) => _submitForm(),
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      PrimaryButton(
                        onPressed: _submitForm,
                        text: _isSignUpMode ? 'Sign Up' : 'Sign In',
                        isLoading: isLoading,
                      ),
                      const SizedBox(height: 16),

                      // Toggle Sign In/Sign Up
                      TextButton(
                        onPressed: isLoading ? null : _toggleMode,
                        child: Text(
                          _isSignUpMode
                              ? 'Already have an account? Sign In'
                              : "Don't have an account? Sign Up",
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Divider
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'OR',
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Social Sign In Buttons
                      SecondaryButton(
                        onPressed: () {
                          context.read<LoginCubit>().logInWithGoogle();
                        },
                        text: 'Continue with Google',
                        isLoading: isLoading,
                        icon: const Icon(Icons.g_mobiledata, size: 24),
                      ),
                      if (Platform.isIOS) ...[
                        const SizedBox(height: 12),
                        SecondaryButton(
                          onPressed: () {
                            context.read<LoginCubit>().logInWithApple();
                          },
                          text: 'Continue with Apple',
                          isLoading: isLoading,
                          icon: const Icon(Icons.apple, size: 24),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
