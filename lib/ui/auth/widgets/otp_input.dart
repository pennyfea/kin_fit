import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A specialized input field for entering 6-digit OTP codes.
///
/// Features:
/// - 6 separate text fields for each digit
/// - Auto-focus and auto-advance between fields
/// - Paste support for full OTP codes
/// - Backspace handling to move to previous field
class OtpInput extends StatefulWidget {
  /// Creates an [OtpInput].
  const OtpInput({
    required this.onCompleted,
    this.enabled = true,
    super.key,
  });

  /// Called when all 6 digits have been entered.
  ///
  /// Returns the complete 6-digit code as a string.
  final ValueChanged<String> onCompleted;

  /// Whether the input is enabled.
  final bool enabled;

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (_) => FocusNode(),
  );

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _handleTextChanged(int index, String value) {
    // Handle paste of full OTP code
    if (value.length > 1) {
      _handlePaste(value);
      return;
    }

    // If a digit was entered
    if (value.isNotEmpty) {
      // Move to next field if not the last one
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // All digits entered, submit
        _focusNodes[index].unfocus();
        _submitCode();
      }
    }
  }

  void _handleKeyEvent(int index, KeyEvent event) {
    // Handle backspace to move to previous field
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isEmpty && index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
  }

  void _handlePaste(String text) {
    // Remove non-digit characters
    final digits = text.replaceAll(RegExp(r'\D'), '');

    // Fill in the digits
    for (var i = 0; i < digits.length && i < 6; i++) {
      _controllers[i].text = digits[i];
    }

    // Focus the next empty field or unfocus if all filled
    if (digits.length >= 6) {
      _focusNodes[5].unfocus();
      _submitCode();
    } else if (digits.length < 6) {
      _focusNodes[digits.length].requestFocus();
    }
  }

  void _submitCode() {
    final code = _controllers.map((c) => c.text).join();
    if (code.length == 6) {
      widget.onCompleted(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) {
        return SizedBox(
          width: 48,
          child: KeyboardListener(
            focusNode: FocusNode(),
            onKeyEvent: (event) => _handleKeyEvent(index, event),
            child: TextFormField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              enabled: widget.enabled,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 1,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              decoration: InputDecoration(
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: colorScheme.primary,
                    width: 2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: colorScheme.outline,
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: colorScheme.outline.withValues(alpha: 0.5),
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                ),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(1),
              ],
              onChanged: (value) => _handleTextChanged(index, value),
              // Auto-focus the first field when widget is built
              autofocus: index == 0,
            ),
          ),
        );
      }),
    );
  }
}
