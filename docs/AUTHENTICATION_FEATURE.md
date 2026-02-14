# Authentication Feature Documentation

## Overview

This document provides a comprehensive overview of the production-ready authentication feature that has been implemented in the Flutter template. The implementation follows the architecture guidelines defined in `ARCHITECTURE.md` and the coding standards in `.instructions.md`.

## Architecture

The authentication feature follows Flutter's hybrid architecture approach:

- **Data layer** (repositories): Organized BY TYPE in `lib/data/` - Shared across features
- **Domain models**: In `lib/domain/models/` - Business entities
- **UI layer** (blocs, widgets): Organized BY FEATURE in `lib/ui/auth/` - Feature-specific
- **Core utilities**: In `lib/utils/` and `lib/ui/core/` - Shared UI components

## Files Created

### 1. Domain Layer (`lib/domain/models/`)

#### `user.dart` - User Domain Model
- Represents a user entity in the application
- Uses `json_serializable` for JSON serialization
- Extends `Equatable` for value equality
- Provides methods for:
  - JSON serialization/deserialization (`fromJson`, `toJson`)
  - Firestore serialization/deserialization (`fromFirestore`, `toFirestore`)
  - Convenience getters: `isEmpty`, `isNotEmpty`, `fullName`, `displayName`
- Includes an `empty` constant for unauthenticated state

**Generated file**: `user.g.dart` (by build_runner)

### 2. Data Layer (`lib/data/repositories/`)

#### `authentication_repository.dart` - Authentication Repository
- Handles all authentication operations:
  - Google Sign-In (using GoogleSignIn SDK v7.2.0)
  - Apple Sign-In (iOS only)
  - Email/Password authentication
  - Sign up with email/password
  - Logout functionality
- Stream-based authentication state (`user` stream)
- Synchronizes user data with Firestore
- Custom exception classes for each auth method:
  - `LogInWithGoogleFailure`
  - `LogInWithAppleFailure`
  - `LogInWithEmailAndPasswordFailure`
  - `SignUpWithEmailAndPasswordFailure`
  - `LogOutFailure`
- Extension method to convert Firebase User to app User

**Key Features**:
- Firebase Auth integration
- Firestore user data persistence
- Error handling with descriptive messages
- Support for multiple authentication providers

### 3. UI Layer - Core Components (`lib/ui/core/`)

#### `theme/app_theme.dart` - Application Theme
- Material 3 theme implementation
- Light and dark mode support
- Uses Google Fonts (Inter font family)
- Comprehensive theming for:
  - App bar, cards, buttons (elevated, outlined, text)
  - Input fields with custom decoration
  - Snack bars, dividers
- Consistent color scheme based on seed color

#### `widgets/primary_button.dart` - Reusable Buttons
- **PrimaryButton**: Filled button with loading state
- **SecondaryButton**: Outlined button with loading state
- Features:
  - Loading indicator support
  - Enabled/disabled states
  - Optional icon support
  - Full-width layout
  - Consistent styling

### 4. UI Layer - Auth Feature (`lib/ui/auth/`)

#### `blocs/login/login_state.dart` - Login State
- Uses Freezed for immutable state classes
- Four states:
  - `initial`: Default state
  - `loading`: Authentication in progress
  - `success`: Authentication succeeded
  - `failure`: Authentication failed with error message
  
**Generated file**: `login_state.freezed.dart` (by build_runner)

#### `blocs/login/login_cubit.dart` - Login Cubit
- Manages login flow using BLoC pattern (Cubit)
- Methods for each authentication type:
  - `logInWithGoogle()`
  - `logInWithApple()`
  - `logInWithEmailAndPassword()`
  - `signUpWithEmailAndPassword()`
  - `reset()`: Resets state to initial
- Comprehensive error handling
- Logging using custom Logger utility

#### `widgets/email_input.dart` - Email Input Field
- Specialized TextFormField for email input
- Built-in email validation using string extensions
- Email-specific keyboard and autofill hints
- Proper text input actions (next)

#### `widgets/password_input.dart` - Password Input Field
- Specialized TextFormField for password input
- Visibility toggle button (show/hide password)
- Password validation (minimum length for sign-up)
- Secure text entry
- Autofill hints support

#### `widgets/login_screen.dart` - Login Screen
- Complete authentication UI
- Features:
  - Email/Password sign-in and sign-up toggle
  - Google Sign-In button
  - Apple Sign-In button (iOS only)
  - Form validation
  - Loading states
  - Error handling with snackbars
  - Responsive layout
  - Material 3 design
- Uses BlocConsumer for state management and side effects

### 5. Utilities (`lib/utils/`)

#### `logger.dart` - Logging Utility
- Simple logger with severity levels:
  - `info`: Informational messages
  - `warning`: Warning messages
  - `error`: Error messages with stack traces
- Structured log output with prefixes
- Integration with dart:developer

#### `extensions/string_extensions.dart` - String Extensions
- `isValidEmail`: Email validation regex
- `capitalize()`: Capitalize first letter
- `capitalizeWords()`: Capitalize all words
- `isNullOrEmpty` / `isNotNullOrEmpty`: Null checks
- `truncate()`: Truncate string with ellipsis

#### `extensions/context_extensions.dart` - BuildContext Extensions
- Theme access: `theme`, `textTheme`, `colorScheme`
- Media query helpers: `screenSize`, `screenWidth`, `screenHeight`
- Orientation checks: `isPortrait`, `isLandscape`
- Keyboard visibility: `isKeyboardVisible`
- Snackbar helpers:
  - `showSnackBar()`: Generic snackbar
  - `showErrorSnackBar()`: Error snackbar
  - `showSuccessSnackBar()`: Success snackbar
- Utility methods:
  - `dismissKeyboard()`: Hide keyboard
  - `isDarkMode` / `isLightMode`: Theme mode checks
  - `showLoadingDialog()` / `hideLoadingDialog()`: Loading dialogs

### 6. Routing (`lib/routing/`)

#### `routes.dart` - Route Constants
- Centralized route path constants:
  - `/` - Home route
  - `/login` - Login route
  - `/profile` - Profile route (placeholder)
  - `/settings` - Settings route (placeholder)

#### `app_router.dart` - Router Configuration
- GoRouter implementation with:
  - Authentication-based redirects
  - Automatic navigation to login when unauthenticated
  - Redirect to home when authenticated user accesses login
  - Stream-based refresh on auth state changes
- Includes placeholder `HomeScreen` with logout button

**Key Classes**:
- `AppRouter`: Main router configuration
- `HomeScreen`: Placeholder home screen (to be replaced)
- `GoRouterRefreshStream`: Helper for auth state stream

### 7. Main Entry Point (`lib/main.dart`)

- Firebase initialization
- Provider setup for `AuthenticationRepository`
- MaterialApp.router configuration
- Theme integration (light/dark mode support)
- Error handling for Firebase initialization

## Usage

### Running the Application

1. Ensure Firebase is properly configured:
   ```bash
   flutter pub get
   firebase configure # Follow Firebase setup
   ```

2. Generate code (for json_serializable and freezed):
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

3. Run the app:
   ```bash
   flutter run
   ```

### Authentication Flow

1. **Unauthenticated State**:
   - User is automatically redirected to `/login`
   - Login screen presents multiple authentication options

2. **Sign In Options**:
   - **Email/Password**: Enter credentials and tap "Sign In"
   - **Google Sign-In**: Tap "Continue with Google"
   - **Apple Sign-In** (iOS only): Tap "Continue with Apple"
   - Toggle to "Sign Up" mode for new accounts

3. **Authenticated State**:
   - User is redirected to home screen
   - Auth state is persisted across app restarts
   - User data is synced to Firestore

4. **Sign Out**:
   - Tap logout button in app bar
   - User is signed out and redirected to login

### Extending the Feature

#### Add a New Authentication Provider

1. Add exception class in `authentication_repository.dart`
2. Add method in `AuthenticationRepository`
3. Add method in `LoginCubit`
4. Add UI button in `LoginScreen`

#### Customize User Model

1. Edit `lib/domain/models/user.dart`
2. Add new fields
3. Update `toFirestore()` and `fromFirestore()` methods
4. Run `dart run build_runner build` to regenerate code

#### Add Password Reset

1. Add method to `AuthenticationRepository`:
   ```dart
   Future<void> resetPassword(String email) async {
     await _firebaseAuth.sendPasswordResetEmail(email: email);
   }
   ```

2. Add UI in login screen with a "Forgot Password?" button

## Dependencies

### Core Dependencies
- `flutter_bloc: ^8.1.6` - State management
- `equatable: ^2.0.7` - Value equality
- `provider: ^6.1.5` - Dependency injection
- `go_router: ^17.0.0` - Navigation

### Firebase
- `firebase_core: ^4.2.0` - Firebase core
- `firebase_auth: ^6.1.0` - Authentication
- `cloud_firestore: ^6.1.0` - Database

### Authentication Providers
- `google_sign_in: ^7.2.0` - Google Sign-In
- `sign_in_with_apple: ^7.0.1` - Apple Sign-In

### Code Generation
- `json_annotation: ^4.9.0` - JSON serialization annotations
- `freezed_annotation: ^2.4.4` - Freezed annotations

### Dev Dependencies
- `build_runner: ^2.4.13` - Code generation
- `json_serializable: ^6.8.0` - JSON serialization generator
- `freezed: ^2.5.7` - Immutable class generator
- `bloc_test: ^9.1.7` - BLoC testing
- `mocktail: ^1.0.4` - Mocking

## Testing

### Unit Tests (To be implemented)

1. **Repository Tests** (`test/data/repositories/authentication_repository_test.dart`):
   - Mock Firebase Auth and Firestore
   - Test each authentication method
   - Test exception handling

2. **BLoC Tests** (`test/ui/auth/blocs/login/login_cubit_test.dart`):
   - Use `bloc_test` package
   - Test state transitions
   - Mock AuthenticationRepository

3. **Widget Tests** (`test/ui/auth/widgets/login_screen_test.dart`):
   - Test UI interactions
   - Test form validation
   - Test navigation

### Example BLoC Test Structure

```dart
blocTest<LoginCubit, LoginState>(
  'emits [loading, success] when logInWithGoogle succeeds',
  build: () {
    when(() => authRepo.logInWithGoogle()).thenAnswer((_) async {});
    return LoginCubit(authenticationRepository: authRepo);
  },
  act: (cubit) => cubit.logInWithGoogle(),
  expect: () => [
    const LoginState.loading(),
    const LoginState.success(),
  ],
);
```

## Security Considerations

1. **Firebase Security Rules**: Ensure proper Firestore rules are configured:
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /users/{userId} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
       }
     }
   }
   ```

2. **Password Requirements**: Update `PasswordInput` widget for stronger validation

3. **Rate Limiting**: Consider implementing rate limiting for authentication attempts

4. **Token Management**: Tokens are automatically managed by Firebase Auth

## Known Limitations

1. **Email Verification**: Not currently implemented (can be added)
2. **Password Reset**: UI not implemented (repository method can be added)
3. **Multi-factor Authentication**: Not supported (can be added)
4. **Account Deletion**: Not implemented (can be added)

## Architecture Benefits

✅ **Separation of Concerns**: Data, domain, and UI layers are clearly separated
✅ **Reusability**: AuthenticationRepository can be used across features
✅ **Testability**: Easy to mock repositories and test BLoCs
✅ **Maintainability**: Feature-specific UI makes it easy to navigate code
✅ **Scalability**: Easy to add new features following the same pattern

## Next Steps

1. **Add Profile Feature**: Use the shared AuthenticationRepository
2. **Add Settings Feature**: Implement theme switching, account management
3. **Add Tests**: Write comprehensive unit and widget tests
4. **Add Analytics**: Track authentication events
5. **Add Error Reporting**: Integrate Crashlytics or Sentry

---

**Last Updated**: 2026-01-21
**Architecture Version**: Following ARCHITECTURE.md guidelines
