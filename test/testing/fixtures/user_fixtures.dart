import 'package:bod_squad/domain/models/user.dart';

/// Test fixtures for [User] model.
class UserFixtures {
  UserFixtures._();

  static final fullUser = User(
    id: 'user-full-123',
    firstName: 'Jane',
    lastName: 'Doe',
    photoUrl: 'https://example.com/jane.jpg',
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 10),
  );

  static const basicUser = User(
    id: 'user-basic-123',
  );

  static const userWithFirstName = User(
    id: 'user-firstname',
    firstName: 'Alice',
  );

  static const userWithLastName = User(
    id: 'user-lastname',
    lastName: 'Smith',
  );

  static const userWithFullName = User(
    id: 'user-fullname',
    firstName: 'Charlie',
    lastName: 'Brown',
  );

  static const userMinimal = User(
    id: 'user-minimal',
  );
}
