import 'package:flutter/material.dart';

import '../../../utils/extensions/string_extensions.dart';

/// A text input field for email addresses.
///
/// Includes built-in validation for email format.
class EmailInput extends StatelessWidget {
  /// Creates an [EmailInput].
  const EmailInput({
    required this.controller,
    this.focusNode,
    this.onSubmitted,
    this.enabled = true,
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

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.email],
      decoration: const InputDecoration(
        labelText: 'Email',
        hintText: 'Enter your email',
        prefixIcon: Icon(Icons.email_outlined),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Email is required';
        }
        if (!value.isValidEmail) {
          return 'Please enter a valid email';
        }
        return null;
      },
      onFieldSubmitted: onSubmitted,
    );
  }
}
