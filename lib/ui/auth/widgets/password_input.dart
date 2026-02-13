import 'package:flutter/material.dart';

/// A text input field for passwords.
///
/// Includes a visibility toggle button to show/hide the password.
class PasswordInput extends StatefulWidget {
  /// Creates a [PasswordInput].
  const PasswordInput({
    required this.controller,
    this.focusNode,
    this.onSubmitted,
    this.enabled = true,
    this.labelText = 'Password',
    this.hintText = 'Enter your password',
    this.isSignUp = false,
    super.key,
  });

  /// The controller for the text field.
  final TextEditingController controller;

  /// The focus node for the text field.
  final FocusNode? focusNode;

  /// Called when the user submits the field.
  final ValueChanged<String>? onSubmitted;

  /// Whether the field is enabled.
  final bool enabled;

  /// The label text for the field.
  final String labelText;

  /// The hint text for the field.
  final String hintText;

  /// Whether this is for sign up (enforces stricter validation).
  final bool isSignUp;

  @override
  State<PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
  bool _obscureText = true;

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      enabled: widget.enabled,
      obscureText: _obscureText,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.password],
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          ),
          onPressed: _toggleVisibility,
          tooltip: _obscureText ? 'Show password' : 'Hide password',
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Password is required';
        }
        if (widget.isSignUp && value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
      onFieldSubmitted: widget.onSubmitted,
    );
  }
}
