import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/domain/models/user.dart';

import '../../testing/fixtures/user_fixtures.dart';

void main() {
  group('User', () {
    group('JSON Serialization', () {
      test('fromJson creates User from JSON with all fields', () {
        final json = {
          'id': 'user-123',
          'firstName': 'John',
          'lastName': 'Doe',
          'photoUrl': 'https://example.com/photo.jpg',
          'createdAt': '2024-01-01T00:00:00.000Z',
          'updatedAt': '2024-01-10T00:00:00.000Z',
        };

        final user = User.fromJson(json);

        expect(user.id, equals('user-123'));
        expect(user.firstName, equals('John'));
        expect(user.lastName, equals('Doe'));
        expect(user.photoUrl, equals('https://example.com/photo.jpg'));
        expect(user.createdAt, isNotNull);
        expect(user.updatedAt, isNotNull);
      });

      test('fromJson creates User from JSON with minimal fields', () {
        final json = {
          'id': 'user-123',
        };

        final user = User.fromJson(json);

        expect(user.id, equals('user-123'));
        expect(user.firstName, isNull);
        expect(user.lastName, isNull);
        expect(user.photoUrl, isNull);
        expect(user.createdAt, isNull);
        expect(user.updatedAt, isNull);
      });

      test('fromJson creates User from JSON with null optional fields', () {
        final json = {
          'id': 'user-123',
          'firstName': null,
          'lastName': null,
          'photoUrl': null,
        };

        final user = User.fromJson(json);

        expect(user.id, equals('user-123'));
        expect(user.firstName, isNull);
        expect(user.lastName, isNull);
        expect(user.photoUrl, isNull);
      });

      test('toJson converts User to JSON with all fields', () {
        final user = UserFixtures.fullUser;

        final json = user.toJson();

        expect(json['id'], equals(user.id));
        expect(json['firstName'], equals(user.firstName));
        expect(json['lastName'], equals(user.lastName));
        expect(json['photoUrl'], equals(user.photoUrl));
        expect(json['createdAt'], isNotNull);
        expect(json['updatedAt'], isNotNull);
      });

      test('toJson converts User with null fields to JSON', () {
        final user = UserFixtures.basicUser;

        final json = user.toJson();

        expect(json['id'], equals(user.id));
        expect(json['firstName'], isNull);
        expect(json['lastName'], isNull);
        expect(json['photoUrl'], isNull);
      });

      test('fromJson and toJson are inverses', () {
        final original = UserFixtures.fullUser;
        final json = original.toJson();
        final restored = User.fromJson(json);

        expect(restored.id, equals(original.id));
        expect(restored.firstName, equals(original.firstName));
        expect(restored.lastName, equals(original.lastName));
        expect(restored.photoUrl, equals(original.photoUrl));
      });
    });

    group('Firestore Serialization', () {
      test('fromFirestore creates User from Firestore data', () {
        final firestoreData = {
          'first_name': 'Jane',
          'last_name': 'Doe',
          'photo_url': 'https://example.com/jane.jpg',
          'created_at': Timestamp.fromDate(DateTime(2024, 1, 1)),
          'updated_at': Timestamp.fromDate(DateTime(2024, 1, 10)),
        };

        final user = User.fromFirestore(firestoreData, 'firestore-id-123');

        expect(user.id, equals('firestore-id-123'));
        expect(user.firstName, equals('Jane'));
        expect(user.lastName, equals('Doe'));
        expect(user.photoUrl, equals('https://example.com/jane.jpg'));
        expect(user.createdAt, equals(DateTime(2024, 1, 1)));
        expect(user.updatedAt, equals(DateTime(2024, 1, 10)));
      });

      test('fromFirestore creates User with null fields', () {
        final firestoreData = {
          'first_name': 'Alice',
          'last_name': null,
          'photo_url': null,
          'created_at': null,
          'updated_at': null,
        };

        final user = User.fromFirestore(firestoreData, 'user-alice');

        expect(user.id, equals('user-alice'));
        expect(user.firstName, equals('Alice'));
        expect(user.lastName, isNull);
        expect(user.photoUrl, isNull);
        expect(user.createdAt, isNull);
        expect(user.updatedAt, isNull);
      });

      test('fromFirestore creates User with missing optional fields', () {
        final firestoreData = <String, dynamic>{};

        final user = User.fromFirestore(firestoreData, 'user-bob');

        expect(user.id, equals('user-bob'));
        expect(user.firstName, isNull);
        expect(user.lastName, isNull);
        expect(user.photoUrl, isNull);
        expect(user.createdAt, isNull);
        expect(user.updatedAt, isNull);
      });

      test('toFirestore converts User to Firestore format', () {
        final user = UserFixtures.fullUser;

        final firestoreData = user.toFirestore();

        expect(firestoreData['first_name'], equals(user.firstName));
        expect(firestoreData['last_name'], equals(user.lastName));
        expect(firestoreData['photo_url'], equals(user.photoUrl));
        expect(firestoreData['created_at'], isA<Timestamp>());
        expect(firestoreData['updated_at'], isA<FieldValue>());
      });

      test('toFirestore converts User with null fields', () {
        const user = User(
          id: 'user-123',
          firstName: null,
          lastName: null,
          photoUrl: null,
          createdAt: null,
          updatedAt: null,
        );

        final firestoreData = user.toFirestore();

        expect(firestoreData['first_name'], isNull);
        expect(firestoreData['last_name'], isNull);
        expect(firestoreData['photo_url'], isNull);
        expect(firestoreData['created_at'], isNull);
      });

      test('roundtrip Firestore serialization preserves data', () {
        final original = UserFixtures.fullUser;

        final firestoreData = {
          'first_name': original.firstName,
          'last_name': original.lastName,
          'photo_url': original.photoUrl,
          'created_at': original.createdAt != null
              ? Timestamp.fromDate(original.createdAt!)
              : null,
          'updated_at': original.updatedAt != null
              ? Timestamp.fromDate(original.updatedAt!)
              : null,
        };

        final restored = User.fromFirestore(firestoreData, original.id);

        expect(restored.id, equals(original.id));
        expect(restored.firstName, equals(original.firstName));
        expect(restored.lastName, equals(original.lastName));
        expect(restored.photoUrl, equals(original.photoUrl));
      });
    });

    group('Equatable Equality', () {
      test('two Users with same fields are equal', () {
        const user1 = User(
          id: 'user-123',
          firstName: 'John',
          lastName: 'Doe',
        );
        const user2 = User(
          id: 'user-123',
          firstName: 'John',
          lastName: 'Doe',
        );

        expect(user1, equals(user2));
      });

      test('two Users with different ids are not equal', () {
        const user1 = User(id: 'user-123');
        const user2 = User(id: 'user-456');

        expect(user1, isNot(equals(user2)));
      });

      test('User.empty equals User with empty id', () {
        const emptyUser = User(id: '');

        expect(emptyUser, equals(User.empty));
      });

      test('hashCode is consistent for equal Users', () {
        const user1 = User(
          id: 'user-123',
          firstName: 'John',
        );
        const user2 = User(
          id: 'user-123',
          firstName: 'John',
        );

        expect(user1.hashCode, equals(user2.hashCode));
      });

      test('User with different timestamp is not equal', () {
        final user1 = User(
          id: 'user-123',
          createdAt: DateTime(2024, 1, 1),
        );
        final user2 = User(
          id: 'user-123',
          createdAt: DateTime(2024, 1, 2),
        );

        expect(user1, isNot(equals(user2)));
      });
    });

    group('fullName Getter', () {
      test('returns full name when both first and last names are present', () {
        final user = UserFixtures.fullUser;

        expect(user.fullName, equals('Jane Doe'));
      });

      test('returns only first name when last name is null', () {
        final user = UserFixtures.userWithFirstName;

        expect(user.fullName, equals('Alice'));
      });

      test('returns only last name when first name is null', () {
        final user = UserFixtures.userWithLastName;

        expect(user.fullName, equals('Smith'));
      });

      test('returns empty string when both names are null', () {
        final user = UserFixtures.basicUser;

        expect(user.fullName, isEmpty);
      });

      test('trims whitespace from full name', () {
        const user = User(
          id: 'user-123',
          firstName: 'John',
          lastName: 'Doe',
        );

        expect(user.fullName, equals('John Doe'));
      });
    });

    group('isEmpty Getter', () {
      test('returns true for User.empty', () {
        expect(User.empty.isEmpty, isTrue);
      });

      test('returns true for User with empty id', () {
        const user = User(id: '');

        expect(user.isEmpty, isTrue);
      });

      test('returns false for user with non-empty id', () {
        expect(UserFixtures.fullUser.isEmpty, isFalse);
      });

      test('returns false for basic user', () {
        expect(UserFixtures.basicUser.isEmpty, isFalse);
      });

      test('isNotEmpty is opposite of isEmpty', () {
        expect(UserFixtures.fullUser.isNotEmpty, isTrue);
        expect(User.empty.isNotEmpty, isFalse);
      });
    });

    group('copyWith', () {
      test('copyWith creates copy with updated id', () {
        final original = UserFixtures.fullUser;
        final copy = original.copyWith(id: 'new-id');

        expect(copy.id, equals('new-id'));
        expect(copy.firstName, equals(original.firstName));
      });

      test('copyWith creates copy with all fields updated', () {
        final original = UserFixtures.basicUser;
        final newDate = DateTime(2024, 6, 15);

        final copy = original.copyWith(
          firstName: 'Updated',
          lastName: 'Name',
          photoUrl: 'https://new.url/photo.jpg',
          createdAt: newDate,
        );

        expect(copy.id, equals(original.id));
        expect(copy.firstName, equals('Updated'));
        expect(copy.lastName, equals('Name'));
        expect(copy.photoUrl, equals('https://new.url/photo.jpg'));
        expect(copy.createdAt, equals(newDate));
      });

      test('copyWith without arguments creates identical copy', () {
        final original = UserFixtures.fullUser;
        final copy = original.copyWith();

        expect(copy, equals(original));
      });
    });

    group('displayName Getter', () {
      test('returns full name when available', () {
        final user = UserFixtures.fullUser;

        expect(user.displayName, equals('Jane Doe'));
      });

      test('returns Unknown User when no name available', () {
        final user = UserFixtures.userMinimal;

        expect(user.displayName, equals('Unknown User'));
      });

      test('returns full name when both parts present', () {
        final user = UserFixtures.userWithFullName;

        expect(user.displayName, equals('Charlie Brown'));
      });

      test('returns first name only when last name missing', () {
        final user = UserFixtures.userWithFirstName;

        expect(user.displayName, equals('Alice'));
      });
    });
  });
}
