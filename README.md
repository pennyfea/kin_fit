# Flutter Template - AI-Optimized Project Starter

A production-ready Flutter project template optimized for AI-assisted development, following [Flutter's official architecture guidelines](https://docs.flutter.dev/app-architecture/case-study).

## 🎯 Features

- ✅ **Official Flutter Architecture** - Data layer by type, UI layer by feature
- ✅ **Complete Authentication** - Google, Apple, Email/Password, Phone (OTP)
- ✅ **BLoC State Management** - Predictable, testable business logic
- ✅ **Firebase Integration** - Auth, Firestore, Storage ready
- ✅ **Material 3 Design** - Modern UI with light/dark themes
- ✅ **Comprehensive Tests** - 91 test cases with 100% coverage
- ✅ **AI-Ready** - MCP server support, detailed context docs
- ✅ **Code Generation** - Freezed, json_serializable setup
- ✅ **Production Quality** - Linting, error handling, documentation

---

## 📚 Documentation

Start with these documents to understand the template:

| Document | Purpose |
|----------|---------|
| **[ARCHITECTURE.md](ARCHITECTURE.md)** | Project structure and design decisions |
| **[CLAUDE.md](CLAUDE.md)** | Persistent AI assistant context |
| **[.instructions.md](.instructions.md)** | Code style and conventions |
| **[MCP_SETUP.md](MCP_SETUP.md)** | Dart & Flutter MCP server configuration |
| **[PROJECT_ANALYSIS.md](PROJECT_ANALYSIS.md)** | Analysis of reference projects |

---

## 🚀 Quick Start

### 1. Create New Project from Template

```bash
# Clone the template
git clone https://github.com/yourusername/app.git app
cd app

# Update project name
sed -i '' 's/app/app/g' pubspec.yaml
sed -i '' 's/com.template/com.mycompany/g' android/app/build.gradle
sed -i '' 's/com.template/com.mycompany/g' ios/Runner.xcodeproj/project.pbxproj
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure Firebase

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for your project
flutterfire configure
```

This generates `lib/firebase_options.dart` with your Firebase configuration.

### 4. Generate Code

```bash
# Generate freezed and json_serializable files
dart run build_runner build --delete-conflicting-outputs
```

### 5. Run the App

```bash
flutter run
```

---

## 🏗️ Project Structure

Following [Flutter's recommended architecture](https://docs.flutter.dev/app-architecture/case-study#package-structure):

```
lib/
├── data/                   # Data layer - BY TYPE (shared)
│   ├── repositories/      # Shared repositories
│   ├── services/          # External services
│   └── models/            # API models
├── domain/                # Domain layer
│   └── models/            # Business entities
├── ui/                    # UI layer - BY FEATURE
│   ├── core/              # Shared UI
│   │   ├── theme/
│   │   └── widgets/
│   └── auth/              # Auth feature
│       ├── blocs/         # Feature-specific logic
│       └── widgets/       # Feature-specific UI
├── routing/               # Navigation
├── utils/                 # Utilities
└── main.dart              # Entry point
```

**Key Principle:** Repositories are shared across features. BLoCs are feature-specific.

---

## 🔐 Authentication

The template includes a complete authentication system:

### Supported Methods

- **Google Sign-In** - OAuth with Firebase
- **Apple Sign-In** - OAuth for iOS
- **Email/Password** - Traditional auth with Firebase
- **Phone (OTP)** - SMS verification with 6-digit code

### Files

```
lib/
├── data/repositories/
│   └── authentication_repository.dart  # Shared auth logic
├── domain/models/
│   └── user.dart                       # User model
└── ui/auth/
    ├── blocs/login/
    │   ├── login_cubit.dart           # Auth state management
    │   └── login_state.dart           # Freezed state classes
    └── widgets/
        ├── login_screen.dart          # Email/Password login
        ├── phone_login_screen.dart    # Phone OTP flow
        ├── email_input.dart           # Reusable inputs
        ├── password_input.dart
        ├── phone_input.dart
        └── otp_input.dart
```

### Usage Example

```dart
// In your UI
ElevatedButton(
  onPressed: () {
    context.read<LoginCubit>().logInWithGoogle();
  },
  child: const Text('Sign in with Google'),
)
```

See [AUTHENTICATION_FEATURE.md](AUTHENTICATION_FEATURE.md) for complete documentation.

---

## 🧪 Testing

Comprehensive test suite with **91 test cases**:

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/ui/auth/blocs/login_cubit_test.dart
```

### Test Structure

```
test/
├── data/repositories/           # Repository tests (23 tests)
├── domain/models/               # Model tests (39 tests)
└── ui/auth/blocs/              # BLoC tests (29 tests)

testing/
├── fakes/                      # Fake implementations
└── fixtures/                   # Mock data
```

### Coverage

- ✅ All authentication methods
- ✅ User model serialization
- ✅ BLoC state transitions
- ✅ Error scenarios
- ✅ Integration scenarios

---

## 🤖 AI-Assisted Development

### MCP Server (Configured ✅)

The [Dart and Flutter MCP server](https://dart.dev/tools/mcp-server) is configured and ready:

- 🔍 Introspect your widget tree
- 📦 Search and add packages
- ⚡ Trigger hot reloads
- 🐛 Analyze errors with deep context

**Setup:** See [MCP_SETUP.md](MCP_SETUP.md) and [MCP_VERIFICATION.md](MCP_VERIFICATION.md).

### Custom Slash Commands

Streamline development with built-in commands:

```bash
/new-project app com.mycompany  # Create new project from template
/add-feature profile yes           # Scaffold new feature
/setup-firebase                    # Configure Firebase
/test coverage                     # Run tests with coverage
```

**See all commands:** [.claude/commands/README.md](.claude/commands/README.md)

### AI Context Documents

- **CLAUDE.md** - Provides persistent context for AI assistants
- **.instructions.md** - Code style preferences for Copilot/Cursor

### Best Practices

When working with AI assistants:

1. ✅ Use slash commands for common tasks
2. ✅ Reference `ARCHITECTURE.md` for structure questions
3. ✅ Follow patterns in existing code
4. ✅ Run tests after AI-generated changes
5. ✅ Review generated code for best practices

---

## 🎨 Theming

Material 3 theming with support for light and dark modes:

```dart
// lib/ui/core/theme/app_theme.dart
class AppTheme {
  static ThemeData light() => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    ),
    textTheme: GoogleFonts.interTextTheme(),
  );

  static ThemeData dark() => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    ),
    textTheme: GoogleFonts.interTextTheme(),
  );
}
```

Reference: [Material 3 for Flutter](https://m3.material.io/develop/flutter)

---

## 🎨 App Icons & Splash Screens

The template includes `flutter_launcher_icons` and `flutter_native_splash` for easy branding.

### App Icons

1. **Add your icon:**
   ```bash
   # Place a 1024x1024 PNG icon at:
   assets/icon/icon.png
   ```

2. **Generate platform icons:**
   ```bash
   dart run flutter_launcher_icons
   ```

This generates icons for:
- Android (all density buckets)
- iOS (all required sizes)

**Configuration:** Edit `pubspec.yaml` under `flutter_launcher_icons:` for adaptive icons, custom paths, etc.

**See:** [assets/icon/README.md](assets/icon/README.md) for detailed guidelines.

### Splash Screens

1. **Add your splash image:**
   ```bash
   # Place a 1152x1152 PNG image at:
   assets/splash/splash.png
   ```

2. **Generate platform splash screens:**
   ```bash
   dart run flutter_native_splash:create
   ```

This generates splash screens for:
- Android (drawable resources)
- iOS (LaunchScreen.storyboard)
- Web (index.html)

**Configuration:** Edit `pubspec.yaml` under `flutter_native_splash:` to customize:
- Background colors (light/dark mode)
- Image paths
- Android 12+ branding
- Fullscreen mode

**See:** [assets/splash/README.md](assets/splash/README.md) for design guidelines.

### Quick Setup

```bash
# 1. Add your branding assets
cp my_icon.png assets/icon/icon.png
cp my_splash.png assets/splash/splash.png

# 2. (Optional) Customize colors in pubspec.yaml
# Edit flutter_native_splash > color

# 3. Generate everything
dart run flutter_launcher_icons
dart run flutter_native_splash:create

# 4. Test on device
flutter run
```

---

## ➕ Adding New Features

Follow the architecture principle: **Data by type, UI by feature**.

### Step 1: Identify Data Needs

**Need a new data source?**
- Create repository in `lib/data/repositories/`
- Create service in `lib/data/services/` if needed

**Using existing data?**
- Reuse `UserRepository`, `AuthenticationRepository`, etc.

### Step 2: Create Feature UI

```bash
mkdir -p lib/ui/my_feature/blocs lib/ui/my_feature/widgets
```

Create:
- `lib/ui/my_feature/blocs/my_feature_bloc.dart` - Business logic
- `lib/ui/my_feature/widgets/my_feature_screen.dart` - UI

### Step 3: Register BLoC

```dart
// main.dart
BlocProvider(
  create: (context) => MyFeatureBloc(
    repository: context.read<MyRepository>(),  // Inject shared repo
  ),
)
```

### Step 4: Add Routes

```dart
// lib/routing/routes.dart
static const myFeature = '/my-feature';

// lib/routing/app_router.dart
GoRoute(
  path: Routes.myFeature,
  builder: (context, state) => const MyFeatureScreen(),
)
```

**Example:** See the complete `auth` feature for reference.

---

## 📦 Dependencies

### Core

- `flutter_bloc: ^8.1.6` - State management
- `go_router: ^17.0.0` - Navigation
- `provider: ^6.1.5` - Dependency injection

### Firebase

- `firebase_core: ^4.2.0` - Firebase SDK
- `firebase_auth: ^6.1.0` - Authentication
- `cloud_firestore: ^6.1.0` - Database
- `firebase_storage: ^13.0.4` - File storage

### Code Generation

- `freezed: ^2.5.7` - Immutable classes
- `json_serializable: ^6.8.0` - JSON serialization
- `build_runner: ^2.4.13` - Code generation

### UI

- `google_fonts: ^6.3.2` - Typography
- `intl_phone_field: ^3.2.0` - Phone input

### Branding

- `flutter_launcher_icons: ^0.14.4` - Generate app icons
- `flutter_native_splash: ^2.4.7` - Generate splash screens

### Testing

- `bloc_test: ^9.1.7` - BLoC testing
- `mocktail: ^1.0.4` - Mocking

See [pubspec.yaml](pubspec.yaml) for complete list.

---

## 🔧 Development Commands

```bash
# Get dependencies
flutter pub get

# Run code generation
dart run build_runner build --delete-conflicting-outputs

# Watch for changes (auto-generate)
dart run build_runner watch --delete-conflicting-outputs

# Generate app icons (after adding assets/icon/icon.png)
dart run flutter_launcher_icons

# Generate splash screens (after adding assets/splash/splash.png)
dart run flutter_native_splash:create

# Analyze code
flutter analyze

# Format code
dart format lib test

# Run tests
flutter test

# Run with coverage
flutter test --coverage

# Build for release (Android)
flutter build apk --release

# Build for release (iOS)
flutter build ios --release
```

---

## 🌍 Environment Configuration

For sensitive data (API keys, secrets), use environment variables:

1. Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```

2. Add your values:
   ```env
   FIREBASE_API_KEY=your_key_here
   GOOGLE_MAPS_API_KEY=your_key_here
   ```

3. Load in `main.dart`:
   ```dart
   import 'package:flutter_dotenv/flutter_dotenv.dart';

   await dotenv.load(fileName: ".env");
   ```

**Note:** `.env` is gitignored. Never commit secrets!

---

## 📋 Customization Checklist

When starting a new project:

- [ ] Update project name in `pubspec.yaml`
- [ ] Update bundle identifiers (Android/iOS)
- [ ] Configure Firebase (`flutterfire configure`)
- [ ] Update theme colors in `app_theme.dart`
- [ ] Add app icon (`assets/icon/icon.png`) and run `dart run flutter_launcher_icons`
- [ ] Add splash screen (`assets/splash/splash.png`) and run `dart run flutter_native_splash:create`
- [ ] Configure environment variables
- [ ] Update `CLAUDE.md` with project-specific context
- [ ] Set up CI/CD (GitHub Actions, etc.)
- [ ] Configure app signing (Android/iOS)

---

## 🚨 Troubleshooting

### Build errors after cloning

```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### Firebase not initialized

Ensure you've run:
```bash
flutterfire configure
```

### Code generation not working

Check that you have part directives:
```dart
part 'my_file.g.dart';        // For json_serializable
part 'my_file.freezed.dart';  // For freezed
```

### Tests failing

Ensure mocks are registered:
```dart
setUpAll(() {
  registerFallbackValue(FakeUser());
});
```

---

## 📖 Additional Resources

### Flutter

- [Flutter Documentation](https://docs.flutter.dev)
- [Flutter Architecture Guide](https://docs.flutter.dev/app-architecture)
- [Material 3 for Flutter](https://m3.material.io/develop/flutter)

### State Management

- [BLoC Library](https://bloclibrary.dev)
- [BLoC Package Documentation](https://pub.dev/packages/flutter_bloc)

### Firebase

- [FlutterFire Documentation](https://firebase.flutter.dev)
- [Firebase Console](https://console.firebase.google.com)

### AI Tools

- [Dart MCP Server](https://dart.dev/tools/mcp-server)
- [Flutter AI Documentation](https://docs.flutter.dev/ai)

---

## 🤝 Contributing

This is a template repository. Feel free to:

- Fork and customize for your needs
- Report issues or suggestions
- Share improvements with the community

---

## 📄 License

This template is provided as-is for use in your projects. Customize and use freely.

---

## ✨ Credits

Architecture patterns extracted from:
- quoting_life
- datestiny
- bellevo
- bellyful_ecosystem

Built following:
- [Flutter's official architecture recommendations](https://docs.flutter.dev/app-architecture/case-study)
- [Effective Dart guidelines](https://dart.dev/effective-dart)
- [Material Design 3](https://m3.material.io)

---

**Template Version:** 1.0.0
**Last Updated:** 2026-01-21
**Flutter SDK:** ^3.8.0
**Dart SDK:** ^3.8.0
