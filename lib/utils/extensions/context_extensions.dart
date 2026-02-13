import 'package:flutter/material.dart';

/// Extensions on [BuildContext] for common operations.
extension ContextExtensions on BuildContext {
  /// Returns the current [ThemeData].
  ThemeData get theme => Theme.of(this);

  /// Returns the current [TextTheme].
  TextTheme get textTheme => theme.textTheme;

  /// Returns the current [ColorScheme].
  ColorScheme get colorScheme => theme.colorScheme;

  /// Returns the current [MediaQueryData].
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Returns the current screen size.
  Size get screenSize => mediaQuery.size;

  /// Returns the current screen width.
  double get screenWidth => screenSize.width;

  /// Returns the current screen height.
  double get screenHeight => screenSize.height;

  /// Returns `true` if the device is in portrait mode.
  bool get isPortrait => mediaQuery.orientation == Orientation.portrait;

  /// Returns `true` if the device is in landscape mode.
  bool get isLandscape => mediaQuery.orientation == Orientation.landscape;

  /// Returns `true` if the keyboard is currently visible.
  bool get isKeyboardVisible => mediaQuery.viewInsets.bottom > 0;

  /// Shows a [SnackBar] with the given message.
  ///
  /// Optionally accepts a [duration] and [action].
  void showSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
    Color? backgroundColor,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        action: action,
        backgroundColor: backgroundColor,
      ),
    );
  }

  /// Shows an error [SnackBar] with the given message.
  void showErrorSnackBar(String message) {
    showSnackBar(
      message,
      backgroundColor: colorScheme.error,
    );
  }

  /// Shows a success [SnackBar] with the given message.
  void showSuccessSnackBar(String message) {
    showSnackBar(
      message,
      backgroundColor: Colors.green,
    );
  }

  /// Dismisses the keyboard.
  void dismissKeyboard() {
    FocusScope.of(this).unfocus();
  }

  /// Returns `true` if the current theme is dark.
  bool get isDarkMode => theme.brightness == Brightness.dark;

  /// Returns `true` if the current theme is light.
  bool get isLightMode => theme.brightness == Brightness.light;

  /// Shows a loading dialog.
  void showLoadingDialog() {
    showDialog<void>(
      context: this,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  /// Hides the loading dialog.
  void hideLoadingDialog() {
    Navigator.of(this).pop();
  }
}
