# Project Architecture

## Overview

This template follows [Flutter's official architecture recommendations](https://docs.flutter.dev/app-architecture/case-study#package-structure) with a **hybrid organization approach**:

- **Data layer** (repositories, services): Organized **by type** → Shared across features
- **UI layer** (views, blocs): Organized **by feature** → Feature-specific

This balances code reusability with feature-focused development.

---

## Folder Structure

```
lib/
├── data/                           # Data layer - organized BY TYPE
│   ├── repositories/              # Repository implementations (shared)
│   │   ├── authentication_repository.dart
│   │   ├── user_repository.dart
│   │   └── settings_repository.dart
│   ├── services/                  # External service wrappers (shared)
│   │   ├── firebase_service.dart
│   │   ├── api_service.dart
│   │   └── storage_service.dart
│   └── models/                    # API/Data models
│       └── api_user.dart
│
├── domain/                        # Domain layer
│   └── models/                    # Domain models (business entities)
│       ├── user.dart
│       └── settings.dart
│
├── ui/                            # UI layer - organized BY FEATURE
│   ├── core/                      # Shared UI components
│   │   ├── theme/                # App theming
│   │   │   ├── app_theme.dart
│   │   │   └── app_colors.dart
│   │   └── widgets/              # Reusable widgets
│   │       ├── primary_button.dart
│   │       ├── loading_indicator.dart
│   │       └── user_avatar.dart
│   │
│   ├── auth/                      # Auth feature
│   │   ├── blocs/                # Feature-specific business logic
│   │   │   ├── login/
│   │   │   │   ├── login_cubit.dart
│   │   │   │   └── login_state.dart
│   │   │   └── signup/
│   │   │       ├── signup_cubit.dart
│   │   │       └── signup_state.dart
│   │   └── widgets/              # Feature-specific UI
│   │       ├── login_screen.dart
│   │       ├── signup_screen.dart
│   │       ├── email_input.dart
│   │       └── password_input.dart
│   │
│   ├── home/                      # Home feature
│   │   ├── blocs/
│   │   │   └── home_bloc.dart
│   │   └── widgets/
│   │       └── home_screen.dart
│   │
│   └── profile/                   # Profile feature
│       ├── blocs/
│       │   └── profile_bloc.dart
│       └── widgets/
│           ├── profile_screen.dart
│           └── profile_avatar.dart
│
├── routing/                       # Navigation
│   ├── app_router.dart           # GoRouter configuration
│   └── routes.dart               # Route constants
│
├── utils/                         # Utilities
│   ├── logger.dart
│   ├── validators.dart
│   └── extensions/
│       ├── string_extensions.dart
│       └── context_extensions.dart
│
├── firebase_options.dart          # Generated Firebase config
├── main_development.dart          # Dev environment entry
├── main_staging.dart              # Staging environment entry
└── main.dart                      # Production entry point

test/
├── data/
│   ├── repositories/
│   └── services/
├── domain/
│   └── models/
├── ui/
│   ├── auth/
│   ├── home/
│   └── profile/
└── utils/

testing/
├── fakes/                         # Fake implementations for testing
│   ├── fake_authentication_repository.dart
│   └── fake_user_repository.dart
└── fixtures/                      # Test data
    └── user_fixtures.dart
```

---

## Layer Responsibilities

### Data Layer (Organized by Type)

**Purpose:** Abstract data access and external dependencies.

**Key Principle:** Repositories and services are **NOT tied to a single feature**. They are shared across multiple features.

#### Repositories (`data/repositories/`)

Repositories abstract data access patterns and can be reused across features.

**Example:**
```dart
// data/repositories/user_repository.dart
// This repository can be used by Profile, Settings, and Auth features

class UserRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  UserRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  Stream<User?> watchUser(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? User.fromFirestore(doc.data()!) : null);
  }

  Future<void> updateUser(User user) async {
    await _firestore
        .collection('users')
        .doc(user.id)
        .update(user.toFirestore());
  }
}
```

#### Services (`data/services/`)

Services encapsulate external dependencies (HTTP clients, analytics, auth providers).

**Example:**
```dart
// data/services/api_service.dart
// This service can be used by any repository that needs HTTP requests

class ApiService {
  final http.Client _client;
  final String baseUrl;

  ApiService({
    http.Client? client,
    required this.baseUrl,
  }) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> get(String endpoint) async {
    final response = await _client.get(Uri.parse('$baseUrl/$endpoint'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw ApiException('Failed to fetch data');
  }
}
```

### Domain Layer

**Purpose:** Define business entities and domain logic.

#### Models (`domain/models/`)

Domain models represent business entities used throughout the app.

**Example:**
```dart
// domain/models/user.dart
// This model is used by both data and UI layers

@JsonSerializable()
class User extends Equatable {
  const User({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
  });

  final String id;
  final String email;
  final String? firstName;
  final String? lastName;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  factory User.fromFirestore(Map<String, dynamic> data) {
    return User(
      id: data['id'] as String,
      email: data['email'] as String,
      firstName: data['first_name'] as String?,
      lastName: data['last_name'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'updated_at': FieldValue.serverTimestamp(),
    };
  }

  @override
  List<Object?> get props => [id, email, firstName, lastName];
}
```

### UI Layer (Organized by Feature)

**Purpose:** Present data to users and handle user interactions.

**Key Principle:** UI components and business logic (BLoCs/Cubits) are **feature-specific** and tightly coupled.

#### BLoCs/Cubits (`ui/{feature}/blocs/`)

Feature-specific business logic that manages state.

**Example:**
```dart
// ui/profile/blocs/profile_bloc.dart
// This bloc is ONLY used by the Profile feature

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserRepository _userRepository;  // Uses shared repository

  ProfileBloc({
    required UserRepository userRepository,
  })  : _userRepository = userRepository,
        super(const ProfileState.initial()) {
    on<ProfileLoadRequested>(_onLoadRequested);
    on<ProfileUpdateRequested>(_onUpdateRequested);
  }

  Future<void> _onLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileState.loading());
    await emit.forEach<User?>(
      _userRepository.watchUser(event.userId),
      onData: (user) => user != null
          ? ProfileState.loaded(user)
          : const ProfileState.error('User not found'),
    );
  }
}
```

#### Widgets (`ui/{feature}/widgets/`)

Feature-specific screens and UI components.

**Example:**
```dart
// ui/profile/widgets/profile_screen.dart
// This screen is ONLY used by the Profile feature

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        return state.when(
          initial: () => const SizedBox.shrink(),
          loading: () => const LoadingIndicator(),
          loaded: (user) => ProfileView(user: user),
          error: (message) => ErrorView(message: message),
        );
      },
    );
  }
}
```

---

## Why This Architecture?

### Data Layer by Type

**Benefits:**
- ✅ **Reusability**: Repositories like `UserRepository` can be used by Profile, Settings, and Auth features
- ✅ **Single Source of Truth**: One repository for user data, not scattered across features
- ✅ **Easier Testing**: Mock repositories once, use across all feature tests
- ✅ **Reduced Duplication**: No repeated data access logic

**Example:**
```dart
// ✅ GOOD: Shared repository
data/repositories/user_repository.dart  // Used by Profile, Settings, Auth

// ❌ BAD: Duplicated repository
ui/profile/data/user_repository.dart
ui/settings/data/user_repository.dart
ui/auth/data/user_repository.dart
```

### UI Layer by Feature

**Benefits:**
- ✅ **Feature Isolation**: All code for a feature in one place
- ✅ **Easier Navigation**: New devs find feature code quickly
- ✅ **Parallel Development**: Teams work on different features without conflicts
- ✅ **Easy Deletion**: Remove entire feature by deleting one folder

**Example:**
```dart
// ✅ GOOD: Feature-specific bloc
ui/profile/blocs/profile_bloc.dart  // Only used by Profile feature

// ✅ GOOD: Feature can be deleted easily
rm -rf lib/ui/profile/  // Removes entire feature
```

---

## Data Flow

```
┌─────────────────────────────────────────────────────┐
│                 UI Layer (by Feature)               │
├─────────────────────────────────────────────────────┤
│  ui/profile/                                        │
│    ├── blocs/profile_bloc.dart   (Feature Logic)   │
│    └── widgets/profile_screen.dart  (View)         │
└─────────────────────────────────────────────────────┘
                         ↓
                    (uses shared)
                         ↓
┌─────────────────────────────────────────────────────┐
│             Domain Layer (Models)                   │
├─────────────────────────────────────────────────────┤
│  domain/models/user.dart  (Business Entity)         │
└─────────────────────────────────────────────────────┘
                         ↓
                    (uses shared)
                         ↓
┌─────────────────────────────────────────────────────┐
│             Data Layer (by Type)                    │
├─────────────────────────────────────────────────────┤
│  data/repositories/user_repository.dart (Shared)    │
│  data/services/api_service.dart (Shared)            │
└─────────────────────────────────────────────────────┘
```

**Example Flow:**
1. User taps "Save Profile" in `ui/profile/widgets/profile_screen.dart`
2. Screen dispatches event to `ui/profile/blocs/profile_bloc.dart`
3. Bloc calls `data/repositories/user_repository.dart` (shared)
4. Repository updates Firestore and returns updated `domain/models/user.dart`
5. Bloc emits new state with updated user
6. Screen rebuilds with new data

---

## When to Add a New Feature

### 1. Identify Data Needs

**Question:** Does this feature need NEW data sources?

**If YES:** Add to `data/` layer:
- Create repository in `data/repositories/`
- Create service in `data/services/` if needed
- Create API models in `data/models/` if needed

**If NO:** Reuse existing repositories

### 2. Create Feature UI

**Always create:**
```
ui/{new_feature}/
├── blocs/              # Feature-specific logic
│   ├── {feature}_bloc.dart
│   ├── {feature}_event.dart
│   └── {feature}_state.dart
└── widgets/            # Feature-specific UI
    ├── {feature}_screen.dart
    └── {feature}_form.dart
```

### 3. Add Domain Models (if needed)

If this feature introduces NEW business entities, add to `domain/models/`.

---

## Dependency Injection

Repositories and services are provided at the app root and injected into feature BLoCs.

```dart
// main.dart
MultiProvider(
  providers: [
    // Shared repositories (data layer)
    RepositoryProvider(create: (_) => AuthenticationRepository()),
    RepositoryProvider(create: (_) => UserRepository()),
    RepositoryProvider(create: (_) => SettingsRepository()),

    // Feature-specific blocs (UI layer)
    BlocProvider(
      create: (context) => ProfileBloc(
        userRepository: context.read<UserRepository>(),  // Inject shared repo
      ),
    ),
    BlocProvider(
      create: (context) => SettingsBloc(
        settingsRepository: context.read<SettingsRepository>(),
        userRepository: context.read<UserRepository>(),  // Reuse same repo
      ),
    ),
  ],
  child: const App(),
)
```

---

## Testing Strategy

### Data Layer Tests

Test repositories and services in isolation.

```dart
// test/data/repositories/user_repository_test.dart
void main() {
  group('UserRepository', () {
    late FakeFirebaseFirestore firestore;
    late UserRepository repository;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      repository = UserRepository(firestore: firestore);
    });

    test('watchUser returns user stream', () async {
      // Test shared repository logic
    });
  });
}
```

### UI Layer Tests

Test feature blocs with mocked repositories.

```dart
// test/ui/profile/blocs/profile_bloc_test.dart
void main() {
  group('ProfileBloc', () {
    late MockUserRepository userRepository;
    late ProfileBloc bloc;

    setUp(() {
      userRepository = MockUserRepository();
      bloc = ProfileBloc(userRepository: userRepository);
    });

    blocTest<ProfileBloc, ProfileState>(
      'loads user profile on ProfileLoadRequested',
      build: () {
        when(() => userRepository.watchUser(any()))
            .thenAnswer((_) => Stream.value(mockUser));
        return bloc;
      },
      act: (bloc) => bloc.add(const ProfileLoadRequested('123')),
      expect: () => [
        const ProfileState.loading(),
        ProfileState.loaded(mockUser),
      ],
    );
  });
}
```

---

## Key Takeaways

1. **Data layer (repositories, services)**: Organized **by type**, shared across features
2. **UI layer (blocs, widgets)**: Organized **by feature**, tightly coupled
3. **Domain models**: Shared business entities in `domain/models/`
4. **Reusability**: Repositories can be used by multiple features
5. **Testability**: Mock repositories once, test features independently

---

**References:**
- [Flutter Architecture Guide](https://docs.flutter.dev/app-architecture)
- [Compass App Case Study](https://docs.flutter.dev/app-architecture/case-study)
