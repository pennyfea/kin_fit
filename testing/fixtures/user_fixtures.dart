import '../../lib/domain/models/user.dart';

/// Mock User objects for testing various scenarios.
class UserFixtures {
  /// An empty user (unauthenticated state)
  static const User empty = User(id: '');

  /// A basic user with email
  static final User basicUser = User(
    id: 'user-123',
    email: 'john@example.com',
    firstName: null,
    lastName: null,
    photoUrl: null,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );

  /// A user with full profile information
  static final User fullUser = User(
    id: 'user-456',
    email: 'jane.doe@example.com',
    firstName: 'Jane',
    lastName: 'Doe',
    photoUrl: 'https://example.com/photo.jpg',
    createdAt: DateTime(2023, 6, 15),
    updatedAt: DateTime(2024, 1, 10),
  );

  /// A user with only first name
  static final User userWithFirstName = User(
    id: 'user-789',
    email: 'alice@example.com',
    firstName: 'Alice',
    lastName: null,
    photoUrl: null,
    createdAt: DateTime(2024, 1, 5),
    updatedAt: DateTime(2024, 1, 5),
  );

  /// A user with only last name
  static final User userWithLastName = User(
    id: 'user-101112',
    email: 'bob@example.com',
    firstName: null,
    lastName: 'Smith',
    photoUrl: null,
    createdAt: DateTime(2024, 1, 8),
    updatedAt: DateTime(2024, 1, 8),
  );

  /// A user without email (e.g., phone auth)
  static final User userWithoutEmail = User(
    id: 'user-131415',
    email: null,
    firstName: 'Charlie',
    lastName: 'Brown',
    photoUrl: null,
    createdAt: DateTime(2024, 1, 12),
    updatedAt: DateTime(2024, 1, 12),
  );

  /// A user with all optional fields as null
  static final User userMinimal = User(
    id: 'user-161718',
    email: null,
    firstName: null,
    lastName: null,
    photoUrl: null,
    createdAt: null,
    updatedAt: null,
  );

  /// A user who signed up via Google
  static final User googleUser = User(
    id: 'google-user-123',
    email: 'googleuser@gmail.com',
    firstName: 'Google',
    lastName: 'User',
    photoUrl: 'https://lh3.googleusercontent.com/a/default-user',
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );

  /// A user who signed up via Apple
  static final User appleUser = User(
    id: 'apple-user-456',
    email: 'appleuser@icloud.com',
    firstName: 'Apple',
    lastName: 'User',
    photoUrl: null,
    createdAt: DateTime(2024, 1, 2),
    updatedAt: DateTime(2024, 1, 2),
  );

  /// A user who signed up via phone
  static final User phoneUser = User(
    id: 'phone-user-789',
    email: null,
    firstName: 'Phone',
    lastName: 'User',
    photoUrl: null,
    createdAt: DateTime(2024, 1, 3),
    updatedAt: DateTime(2024, 1, 3),
  );
}
