import 'package:flutter/material.dart';

/// A primary button widget with loading state support.
///
/// This button follows the app's design system and provides consistent
/// styling across the application.
class PrimaryButton extends StatelessWidget {
  /// Creates a [PrimaryButton].
  const PrimaryButton({
    required this.onPressed,
    required this.text,
    this.isLoading = false,
    this.isEnabled = true,
    this.icon,
    super.key,
  });

  /// The callback function when the button is pressed.
  ///
  /// If null or [isEnabled] is false, the button will be disabled.
  final VoidCallback? onPressed;

  /// The text to display on the button.
  final String text;

  /// Whether the button is in a loading state.
  ///
  /// When true, shows a loading indicator and disables interactions.
  final bool isLoading;

  /// Whether the button is enabled.
  ///
  /// When false, the button will be disabled even if [onPressed] is provided.
  final bool isEnabled;

  /// Optional icon to display before the text.
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveOnPressed = isEnabled && !isLoading ? onPressed : null;

    final buttonContent = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.onPrimary,
              ),
            ),
          )
        else if (icon != null) ...[
          icon!,
          const SizedBox(width: 8),
        ],
        Text(text),
      ],
    );

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: effectiveOnPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          disabledBackgroundColor: theme.colorScheme.surfaceContainerHighest,
          disabledForegroundColor: theme.colorScheme.onSurfaceVariant,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: buttonContent,
      ),
    );
  }
}

/// A secondary/outlined button widget with loading state support.
class SecondaryButton extends StatelessWidget {
  /// Creates a [SecondaryButton].
  const SecondaryButton({
    required this.onPressed,
    required this.text,
    this.isLoading = false,
    this.isEnabled = true,
    this.icon,
    super.key,
  });

  /// The callback function when the button is pressed.
  final VoidCallback? onPressed;

  /// The text to display on the button.
  final String text;

  /// Whether the button is in a loading state.
  final bool isLoading;

  /// Whether the button is enabled.
  final bool isEnabled;

  /// Optional icon to display before the text.
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveOnPressed = isEnabled && !isLoading ? onPressed : null;

    final buttonContent = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          )
        else if (icon != null) ...[
          icon!,
          const SizedBox(width: 8),
        ],
        Text(text),
      ],
    );

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: effectiveOnPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: theme.colorScheme.primary,
          disabledForegroundColor: theme.colorScheme.onSurfaceVariant,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          side: BorderSide(
            color: theme.colorScheme.outline,
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: buttonContent,
      ),
    );
  }
}
