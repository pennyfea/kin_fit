import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

/// A text input field for phone numbers with country code picker.
///
/// Uses the intl_phone_field package for international phone number input
/// with automatic country code detection and validation.
class PhoneInput extends StatelessWidget {
  /// Creates a [PhoneInput].
  const PhoneInput({
    required this.controller,
    this.focusNode,
    this.onSubmitted,
    this.onChanged,
    this.enabled = true,
    super.key,
  });

  /// The controller for the text field.
  final TextEditingController controller;

  /// The focus node for the text field.
  final FocusNode? focusNode;

  /// Called when the user submits the field.
  final ValueChanged<String>? onSubmitted;

  /// Called when the phone number changes.
  ///
  /// Returns the complete phone number in E.164 format (e.g., +1234567890).
  final ValueChanged<String>? onChanged;

  /// Whether the field is enabled.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return IntlPhoneField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      decoration: const InputDecoration(
        labelText: 'Phone Number',
        hintText: 'Enter your phone number',
      ),
      initialCountryCode: 'US',
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.done,
      onChanged: (phone) {
        if (onChanged != null) {
          try {
            onChanged!(phone.completeNumber);
          } catch (_) {
            // Number still incomplete — ignore until valid
          }
        }
      },
      onSubmitted: (value) {
        if (onSubmitted != null) {
          // Get the complete phone number from the controller
          final phone = controller.text;
          onSubmitted!(phone);
        }
      },
      validator: (phone) {
        if (phone == null || phone.number.isEmpty) {
          return 'Phone number is required';
        }
        try {
          if (!phone.isValidNumber()) {
            return 'Please enter a valid phone number';
          }
        } catch (_) {
          return 'Please enter a valid phone number';
        }
        return null;
      },
    );
  }
}
