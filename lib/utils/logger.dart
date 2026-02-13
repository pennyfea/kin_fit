import 'dart:developer' as developer;

/// Severity levels for log messages.
enum LogLevel {
  /// Informational messages.
  info,

  /// Warning messages.
  warning,

  /// Error messages.
  error,
}

/// A simple logger utility for the application.
///
/// Provides formatted logging with severity levels and emojis.
class Logger {
  /// Creates a [Logger] with an optional name.
  const Logger([this.name]);

  /// The name of this logger, used to identify the source of log messages.
  final String? name;

  /// Logs an informational message.
  ///
  /// Use this for general information about app flow.
  void info(String message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.info, message, error, stackTrace);
  }

  /// Logs a warning message.
  ///
  /// Use this for potentially problematic situations.
  void warning(String message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.warning, message, error, stackTrace);
  }

  /// Logs an error message.
  ///
  /// Use this for errors and exceptions.
  void error(String message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.error, message, error, stackTrace);
  }

  void _log(
    LogLevel level,
    String message,
    Object? error,
    StackTrace? stackTrace,
  ) {
    final emoji = _getEmoji(level);
    final levelName = level.name.toUpperCase();
    final prefix = name != null ? '[$name] ' : '';

    final buffer = StringBuffer()
      ..write(emoji)
      ..write(' ')
      ..write(levelName)
      ..write(': ')
      ..write(prefix)
      ..write(message);

    if (error != null) {
      buffer
        ..write('\nError: ')
        ..write(error.toString());
    }

    if (stackTrace != null) {
      buffer
        ..write('\nStack trace:\n')
        ..write(stackTrace.toString());
    }

    developer.log(
      buffer.toString(),
      name: name ?? 'App',
      error: error,
      stackTrace: stackTrace,
      level: _getLevel(level),
    );
  }

  String _getEmoji(LogLevel level) {
    switch (level) {
      case LogLevel.info:
        return 'INFO';
      case LogLevel.warning:
        return 'WARN';
      case LogLevel.error:
        return 'ERROR';
    }
  }

  int _getLevel(LogLevel level) {
    switch (level) {
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
    }
  }
}
