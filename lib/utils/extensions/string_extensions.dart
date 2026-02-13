/// Extensions on [String] for common operations.
extension StringExtensions on String {
  /// Validates if this string is a valid email address.
  ///
  /// Returns `true` if the string matches a basic email pattern.
  bool get isValidEmail {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(this);
  }

  /// Capitalizes the first letter of this string.
  ///
  /// Returns an empty string if this string is empty.
  ///
  /// Example:
  /// ```dart
  /// 'hello'.capitalize() // 'Hello'
  /// 'world'.capitalize() // 'World'
  /// ''.capitalize() // ''
  /// ```
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalizes the first letter of each word in this string.
  ///
  /// Example:
  /// ```dart
  /// 'hello world'.capitalizeWords() // 'Hello World'
  /// 'the quick brown fox'.capitalizeWords() // 'The Quick Brown Fox'
  /// ```
  String capitalizeWords() {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize()).join(' ');
  }

  /// Returns `true` if this string is null or empty.
  bool get isNullOrEmpty => isEmpty;

  /// Returns `true` if this string is not null and not empty.
  bool get isNotNullOrEmpty => isNotEmpty;

  /// Truncates this string to the specified [maxLength].
  ///
  /// If the string is longer than [maxLength], it will be truncated and
  /// [ellipsis] will be appended.
  ///
  /// Example:
  /// ```dart
  /// 'Hello World'.truncate(5) // 'Hello...'
  /// 'Hi'.truncate(5) // 'Hi'
  /// ```
  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}$ellipsis';
  }
}
