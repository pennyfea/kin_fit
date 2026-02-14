/// Route path constants for the application.
///
/// Centralizes all route paths to avoid magic strings throughout the codebase.
class Routes {
  /// Private constructor to prevent instantiation.
  Routes._();

  /// The login route.
  static const String login = '/login';

  /// The home route.
  static const String home = '/';

  /// The groups route.
  static const String groups = '/groups';

  /// The group detail route (sub-route of groups).
  static const String groupDetail = ':groupId';

  /// The create group route.
  static const String createGroup = '/groups/create';

  /// The join group route.
  static const String joinGroup = '/groups/join';

  /// The check-in route.
  static const String checkIn = '/check-in';

  /// The profile route.
  static const String profile = '/profile';

  /// The edit profile route.
  static const String editProfile = '/profile/edit';

  /// The settings route.
  static const String settings = '/settings';
}
