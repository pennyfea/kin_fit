# Flutter Template - AI Context Document

> **Purpose:** This document provides persistent context for AI assistants (Claude Code, GitHub Copilot) working on Flutter projects based on this template. Read this file at the start of each session to understand the project architecture, conventions, and patterns.

---

## Project Overview

This is a **Flutter project template** optimized for AI-assisted development. It provides a standardized architecture, conventions, and patterns extracted from multiple production Flutter applications.

**Target Use Cases:**
- Consumer mobile apps (iOS, Android)
- Business tools and SaaS applications
- Apps requiring Firebase backend
- Projects with authentication and user profiles
- Offline-first capable applications

**Tech Stack:**
- Flutter 3.8+ with Dart 3.0+
- BLoC pattern for state management
- Firebase (Auth, Firestore, Storage)
- GoRouter for navigation
- Material Design 3

---

## Architecture

### Flutter's Recommended Hybrid Organization

Following [Flutter's official architecture guide](https://docs.flutter.dev/app-architecture/case-study), this template uses:

- **Data layer** (repositories, services): Organized **by type** → Shared across features
- **UI layer** (views, blocs): Organized **by feature** → Feature-specific

See `ARCHITECTURE.md` for detailed explanation.

```
lib/
├── data/                   # Data layer - BY TYPE (shared)
│   ├── repositories/      # Repository implementations
│   │   ├── authentication_repository.dart
│   │   └── user_repository.dart
│   ├── services/          # External service wrappers
│   │   └── api_service.dart
│   └── models/            # API/Data models
│       └── api_user.dart
├── domain/                # Domain layer
│   └── models/            # Domain models (business entities)
│       └── user.dart
├── ui/                    # UI layer - BY FEATURE
│   ├── core/              # Shared UI components
│   │   ├── theme/         # App theming
│   │   └── widgets/       # Reusable widgets
│   └── auth/              # Auth feature (example)
│       ├── blocs/         # Feature-specific logic
│       │   └── login_cubit.dart
│       └── widgets/       # Feature-specific UI
│           ├── login_screen.dart
│           └── email_input.dart
├── routing/               # Navigation
│   ├── app_router.dart
│   └── routes.dart
├── utils/                 # Utilities and extensions
└── main.dart              # App entry point
```

**Key Principle:** Repositories like `UserRepository` are shared and used by multiple features (Profile, Settings, Auth), while BLoCs like `LoginCubit` are feature-specific.

### Data Flow

```
User Action (in ui/profile/widgets/profile_screen.dart)
      ↓
Event dispatched to Feature BLoC (ui/profile/blocs/profile_bloc.dart)
      ↓
BLoC calls Shared Repository (data/repositories/user_repository.dart)
      ↓
Repository interacts with Firebase/API
      ↓
Repository returns Domain Model (domain/models/user.dart)
      ↓
BLoC emits new State
      ↓
UI rebuilds with new data
```

---

## State Management

### BLoC vs Cubit Decision Matrix

| Use BLoC When | Use Cubit When |
|---------------|----------------|
| Multiple event types | Single state updates |
| Real-time Firestore streams | Simple UI state |
| Complex business logic | Form state |
| Global app state (auth, user) | Toggles and preferences |

### BLoC Pattern

**Structure:**
```dart
// Event (use sealed classes for Dart 3.0+)
sealed class AuthEvent extends Equatable {
  const AuthEvent();
}

final class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested(this.email, this.password);
  final String email;
  final String password;

  @override
  List<Object> get props => [email, password];
}

// State (use Freezed for unions)
@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(User user) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.failure(String message) = _Failure;
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthenticationRepository _authRepository;

  AuthBloc({required AuthenticationRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthState.initial()) {
    on<AuthLoginRequested>(_onLoginRequested);
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    try {
      final user = await _authRepository.logIn(
        email: event.email,
        password: event.password,
      );
      emit(AuthState.authenticated(user));
    } catch (e) {
      emit(AuthState.failure(e.toString()));
    }
  }
}
```

### Cubit Pattern

**Use for simpler state:**
```dart
class FavoritesCubit extends Cubit<FavoritesState> {
  final FavoritesRepository _repository;

  FavoritesCubit(this._repository) : super(FavoritesState.initial());

  Future<void> toggleFavorite(String itemId) async {
    try {
      final isFavorite = state.favoriteIds.contains(itemId);
      if (isFavorite) {
        await _repository.removeFavorite(itemId);
        emit(state.copyWith(
          favoriteIds: state.favoriteIds.where((id) => id != itemId).toList(),
        ));
      } else {
        await _repository.addFavorite(itemId);
        emit(state.copyWith(
          favoriteIds: [...state.favoriteIds, itemId],
        ));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }
}
```

---

## Firebase Integration

### Authentication Repository Pattern

```dart
class AuthenticationRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthenticationRepository({
    firebase_auth.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  /// Stream of authentication state changes
  Stream<User> get user {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      return firebaseUser?.toUser ?? User.empty;
    });
  }

  /// Google Sign-In with error handling
  Future<void> logInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _firebaseAuth.signInWithCredential(credential);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw LogInWithGoogleFailure.fromCode(e.code);
    } catch (_) {
      throw const LogInWithGoogleFailure();
    }
  }

  /// Sign out from all providers
  Future<void> logOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (_) {
      throw LogOutFailure();
    }
  }
}

/// Extension to convert Firebase User to app User
extension on firebase_auth.User {
  User get toUser {
    final nameParts = displayName?.split(' ') ?? [];
    return User(
      id: uid,
      email: email,
      firstName: nameParts.isNotEmpty ? nameParts.first : null,
      lastName: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : null,
      photoUrl: photoURL,
    );
  }
}
```

### Custom Exception Pattern

**Always create custom exceptions with factory constructors for Firebase error codes:**

```dart
class LogInWithGoogleFailure implements Exception {
  const LogInWithGoogleFailure([
    this.message = 'An unknown exception occurred.',
  ]);

  final String message;

  factory LogInWithGoogleFailure.fromCode(String code) {
    switch (code) {
      case 'account-exists-with-different-credential':
        return const LogInWithGoogleFailure(
          'Account exists with different credentials.',
        );
      case 'invalid-credential':
        return const LogInWithGoogleFailure(
          'The credential received is malformed or has expired.',
        );
      case 'user-disabled':
        return const LogInWithGoogleFailure(
          'This user has been disabled.',
        );
      default:
        return const LogInWithGoogleFailure();
    }
  }
}
```

### Firestore Repository Pattern

```dart
class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Real-time subscription to user data
  Stream<User?> watchUser(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return null;
      return User.fromFirestore(snapshot.data()!, snapshot.id);
    });
  }

  /// One-time fetch
  Future<User?> getUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return null;
      return User.fromFirestore(doc.data()!, doc.id);
    } on FirebaseException catch (e) {
      throw UserRepositoryException.fromCode(e.code);
    }
  }

  /// Create or update user
  Future<void> saveUser(User user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.id)
          .set(user.toFirestore(), SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw UserRepositoryException.fromCode(e.code);
    }
  }

  /// Delete user
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
    } on FirebaseException catch (e) {
      throw UserRepositoryException.fromCode(e.code);
    }
  }
}
```

### Model Serialization

**Use json_serializable with Firestore-specific methods:**

```dart
@JsonSerializable(explicitToJson: true)
class User extends Equatable {
  const User({
    required this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.photoUrl,
  });

  final String id;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? photoUrl;

  static const empty = User(id: '');

  /// JSON serialization (for general use)
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  /// Firestore serialization (with document ID)
  factory User.fromFirestore(Map<String, dynamic> data, String documentId) {
    return User(
      id: documentId,
      email: data['email'] as String?,
      firstName: data['first_name'] as String?,
      lastName: data['last_name'] as String?,
      photoUrl: data['photo_url'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'photo_url': photoUrl,
      'updated_at': FieldValue.serverTimestamp(),
    };
  }

  @override
  List<Object?> get props => [id, email, firstName, lastName, photoUrl];
}
```

---

## Routing

### GoRouter Configuration

```dart
class AppRouter {
  final AppBloc appBloc;

  AppRouter({required this.appBloc});

  late final GoRouter router = GoRouter(
    initialLocation: Routes.splash,
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: Routes.home,
        builder: (context, state) => const HomeScreen(),
      ),
    ],
    redirect: (context, state) {
      final isAuthenticated = appBloc.state is Authenticated;
      final isOnLoginPage = state.matchedLocation == Routes.login;
      final isOnSplash = state.matchedLocation == Routes.splash;

      // Don't redirect on splash (let it handle initialization)
      if (isOnSplash) return null;

      // Redirect unauthenticated users to login
      if (!isAuthenticated && !isOnLoginPage) {
        return Routes.login;
      }

      // Redirect authenticated users away from login
      if (isAuthenticated && isOnLoginPage) {
        return Routes.home;
      }

      return null;
    },
    refreshListenable: GoRouterRefreshStream(appBloc.stream),
  );
}

/// Helper to refresh router on bloc state changes
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
```

---

## Dependency Injection

### Provider Setup

```dart
// In main.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize repositories
  final authRepository = AuthenticationRepository();

  runApp(
    MultiProvider(
      providers: [
        // Repositories
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider(create: (_) => UserRepository()),

        // Blocs
        BlocProvider(
          create: (_) => AppBloc(
            authenticationRepository: authRepository,
          )..add(const AppUserSubscriptionRequested()),
        ),
      ],
      child: const App(),
    ),
  );
}
```

---

## Naming Conventions

### Files
- **snake_case** for all Dart files
- Pattern: `{feature}_{type}.dart`
  - `user_repository.dart`
  - `app_bloc.dart`
  - `login_screen.dart`

### Classes
- **PascalCase**
- Suffixes:
  - Blocs: `*Bloc`
  - Cubits: `*Cubit`
  - Repositories: `*Repository`
  - Screens: `*Screen`
  - Models: No suffix

### Variables/Methods
- **camelCase**
- Private: `_privateVariable`
- Constants: `kConstantName`

### Directories
- **snake_case**
- Plural for collections: `blocs/`, `models/`
- Singular for concepts: `data/`, `domain/`

---

## Code Generation Commands

```bash
# Generate code (json_serializable, freezed)
dart run build_runner build --delete-conflicting-outputs

# Watch for changes
dart run build_runner watch --delete-conflicting-outputs

# Clean generated files
dart run build_runner clean
```

---

## Common Tasks

### Adding a New Feature

**Step 1:** Identify if you need NEW shared data sources

- **If YES**, add to data layer (shared by type):
  - Create repository in `lib/data/repositories/{feature}_repository.dart`
  - Create service in `lib/data/services/{feature}_service.dart` if needed
  - Create API models in `lib/data/models/` if needed

- **If NO**, reuse existing repositories (e.g., `UserRepository`, `AuthenticationRepository`)

**Step 2:** Add domain models (if needed)

- Create business entities in `lib/domain/models/{model}.dart` if this feature introduces new concepts

**Step 3:** Create feature UI folder (always)

```bash
lib/ui/{feature_name}/
├── blocs/                    # Feature-specific business logic
│   ├── {feature}_bloc.dart
│   ├── {feature}_event.dart
│   └── {feature}_state.dart
└── widgets/                  # Feature-specific UI
    ├── {feature}_screen.dart
    └── {feature}_form.dart
```

**Step 4:** Register BLoC with shared repositories

```dart
// main.dart
BlocProvider(
  create: (context) => ProfileBloc(
    userRepository: context.read<UserRepository>(),  // Inject shared repo
  ),
)
```

**Step 5:** Add routes in `routing/routes.dart`

**Example:**
```dart
// Adding a "Profile" feature
// 1. Reuse existing UserRepository (no new repo needed)
// 2. Create UI folder
lib/ui/profile/
├── blocs/
│   └── profile_bloc.dart      // Uses UserRepository
└── widgets/
    └── profile_screen.dart

// 3. Register in main.dart
BlocProvider(
  create: (ctx) => ProfileBloc(
    userRepository: ctx.read<UserRepository>(),  // Shared repo
  ),
)
```

### Creating a New Model

```dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'my_model.g.dart';

@JsonSerializable(explicitToJson: true)
class MyModel extends Equatable {
  const MyModel({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  factory MyModel.fromJson(Map<String, dynamic> json) =>
      _$MyModelFromJson(json);

  Map<String, dynamic> toJson() => _$MyModelToJson(this);

  @override
  List<Object> get props => [id, name];
}
```

Then run: `dart run build_runner build --delete-conflicting-outputs`

### Updating App Branding

**App Icons:**

1. Create or obtain a 1024x1024 PNG icon
2. Place it at `assets/icon/icon.png`
3. Run: `dart run flutter_launcher_icons`

This generates all required icon sizes for Android and iOS.

**Customization** (in `pubspec.yaml` under `flutter_launcher_icons:`):
```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/icon.png"
  # Adaptive icon (Android)
  adaptive_icon_background: "#ffffff"
  adaptive_icon_foreground: "assets/icon/foreground.png"
```

**Splash Screens:**

1. Create or obtain a 1152x1152 PNG splash image (keep important content in center 512x512)
2. Place it at `assets/splash/splash.png`
3. Run: `dart run flutter_native_splash:create`

This generates splash screens for Android, iOS, and Web.

**Customization** (in `pubspec.yaml` under `flutter_native_splash:`):
```yaml
flutter_native_splash:
  color: "#ffffff"
  image: "assets/splash/splash.png"
  # Dark mode support
  color_dark: "#000000"
  image_dark: "assets/splash/splash_dark.png"
  # Android 12+ branding
  android_12:
    image: "assets/splash/splash_android12.png"
    color: "#ffffff"
```

**See:** `assets/icon/README.md` and `assets/splash/README.md` for detailed guidelines.

---

## Testing

### BLoC Testing

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthenticationRepository extends Mock
    implements AuthenticationRepository {}

void main() {
  group('AppBloc', () {
    late AuthenticationRepository authRepository;

    setUp(() {
      authRepository = MockAuthenticationRepository();
      when(() => authRepository.user).thenAnswer((_) => const Stream.empty());
    });

    test('initial state is unauthenticated', () {
      final bloc = AppBloc(authenticationRepository: authRepository);
      expect(bloc.state, const AppState.unauthenticated());
    });

    blocTest<AppBloc, AppState>(
      'emits authenticated when user stream emits user',
      build: () {
        when(() => authRepository.user).thenAnswer(
          (_) => Stream.value(const User(id: '1')),
        );
        return AppBloc(authenticationRepository: authRepository);
      },
      act: (bloc) => bloc.add(const AppUserSubscriptionRequested()),
      expect: () => [const AppState.authenticated(User(id: '1'))],
    );
  });
}
```

---

## AI Assistant Guidelines

### When to Use Subagents

**✅ USE subagents for:**
- Generating multiple related files (model + repository + bloc)
- Writing comprehensive tests for a feature
- Large refactoring across multiple files
- Code review tasks

**❌ DO NOT use subagents for:**
- Single file edits
- Debugging (context loss)
- Architectural decisions
- Sensitive logic (auth, payments)

### Code Generation Pattern

When creating a new feature, generate files in this order:
1. Models (data layer)
2. Repository (data layer)
3. BLoC/Cubit (domain layer)
4. Screens and widgets (presentation layer)
5. Tests for all layers

### Common Questions

**Q: Should I use BLoC or Cubit?**
A: Use BLoC for complex state with multiple events. Use Cubit for simple state.

**Q: Where do models go?**
A: In `features/{feature}/data/models/` for feature-specific models. In `core/models/` for shared models.

**Q: How do I handle Firebase errors?**
A: Create custom exception classes with `fromCode` factory constructors.

**Q: Should I use Freezed or Equatable?**
A: Use Freezed for state classes (better pattern matching). Use Equatable for models.

**Q: How do I test Blocs?**
A: Use `bloc_test` package with `mocktail` for mocking dependencies.

**Q: How do I update app icons and splash screens?**
A: Add your assets to `assets/icon/icon.png` and `assets/splash/splash.png`, then run `dart run flutter_launcher_icons` and `dart run flutter_native_splash:create`. See the README files in those directories for detailed guidelines.

---

## Key Architectural Decisions

### Why Feature-First?
- **Scalability**: Features grow independently
- **Team Collaboration**: Parallel development on different features
- **Code Discovery**: Related code is co-located
- **Deletion**: Easy to remove entire features

### Why BLoC Pattern?
- **Testability**: Business logic isolated from UI
- **Separation of Concerns**: Clear boundaries
- **Reusability**: Blocs can be shared across screens
- **State Management**: Predictable state changes

### Why Repository Pattern?
- **Abstraction**: Hide data source implementation
- **Testability**: Easy to mock for testing
- **Flexibility**: Swap data sources (Firestore → REST API)
- **Error Handling**: Centralized error logic

### Why GoRouter?
- **Type Safety**: Compile-time route checking
- **Deep Linking**: First-class support
- **Declarative**: Routes defined in one place
- **Redirects**: Auth-based navigation guards

---

## Project-Specific Customization

### When Starting a New Project

1. **Replace template name** throughout codebase
2. **Configure Firebase**:
   ```bash
   flutterfire configure
   ```
3. **Update pubspec.yaml** with project-specific dependencies
4. **Customize theme** in `core/theme/app_theme.dart`
5. **Update this file** with project-specific context

### Optional Enhancements

- **Remote Config**: For feature flags
- **Crashlytics**: For error monitoring
- **Analytics**: For user tracking
- **Local Database (Drift)**: For offline-first
- **Advanced DI (GetIt)**: For large projects

---

## Resources

- [Flutter Documentation](https://docs.flutter.dev)
- [BLoC Library](https://bloclibrary.dev)
- [Firebase for Flutter](https://firebase.flutter.dev)
- [GoRouter Documentation](https://pub.dev/packages/go_router)
- [Effective Dart](https://dart.dev/effective-dart)

---

**Last Updated:** 2026-01-21
**Template Version:** 1.0.0
