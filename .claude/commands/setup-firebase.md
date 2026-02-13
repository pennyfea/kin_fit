# setup-firebase - Configure Firebase for this project

Guides you through Firebase configuration with FlutterFire CLI.

## Usage

```
/setup-firebase
```

## What It Does

1. **Checks prerequisites**
2. **Runs FlutterFire configure**
3. **Verifies configuration**
4. **Updates documentation**
5. **Provides next steps**

## Steps

### Step 1: Check Prerequisites

```bash
echo "🔍 Checking prerequisites..."

# Check Flutter
if ! command -v flutter &> /dev/null; then
  echo "❌ Flutter not found. Please install Flutter first."
  exit 1
fi

# Check Firebase CLI
if ! command -v firebase &> /dev/null; then
  echo "⚠️  Firebase CLI not installed"
  echo "Installing Firebase CLI..."
  npm install -g firebase-tools
fi

# Check FlutterFire CLI
if ! dart pub global list | grep -q flutterfire_cli; then
  echo "📦 Installing FlutterFire CLI..."
  dart pub global activate flutterfire_cli
else
  echo "✅ FlutterFire CLI already installed"
fi

echo "✅ Prerequisites checked"
```

### Step 2: Login to Firebase

```bash
echo "🔐 Logging in to Firebase..."

firebase login

echo "✅ Firebase login complete"
```

### Step 3: Run FlutterFire Configure

```bash
echo "⚙️ Configuring Firebase..."
echo ""
echo "Select your Firebase project or create a new one."
echo "Enable the platforms you need (iOS, Android, Web, etc.)"
echo ""

flutterfire configure

echo ""
echo "✅ Firebase configuration complete"
```

### Step 4: Verify Configuration

```bash
echo "🔍 Verifying configuration..."

if [ -f "lib/firebase_options.dart" ]; then
  echo "✅ firebase_options.dart created"
else
  echo "❌ firebase_options.dart not found"
  exit 1
fi

# Check if Firebase is initialized in main.dart
if grep -q "Firebase.initializeApp" lib/main.dart; then
  echo "✅ Firebase initialization found in main.dart"
else
  echo "⚠️  Add Firebase initialization to main.dart"
fi

echo "✅ Configuration verified"
```

### Step 5: Enable Firebase Services

```bash
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔧 Next: Enable Firebase Services"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Go to Firebase Console: https://console.firebase.google.com"
echo ""
echo "Enable these services for your project:"
echo ""
echo "1. Authentication"
echo "   - Enable Google Sign-In"
echo "   - Enable Apple Sign-In (iOS)"
echo "   - Enable Email/Password"
echo "   - Enable Phone Authentication"
echo "   - Add SHA-256 certificate for Android"
echo ""
echo "2. Cloud Firestore"
echo "   - Create database (start in test mode)"
echo "   - Set up security rules"
echo ""
echo "3. Cloud Storage"
echo "   - Enable storage"
echo "   - Set up security rules"
echo ""
echo "4. App Check (Recommended)"
echo "   - Enable App Check"
echo "   - Configure for each platform"
echo ""
```

### Step 6: Configure Platform-Specific Settings

```bash
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📱 Platform-Specific Configuration"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Android:"
echo "  1. Get SHA-256 certificate:"
echo "     cd android && ./gradlew signingReport"
echo "  2. Add SHA-256 to Firebase Console"
echo "  3. Download google-services.json (if updated)"
echo ""
echo "iOS:"
echo "  1. Enable Sign in with Apple in Xcode"
echo "  2. Add Apple Sign-In capability"
echo "  3. Download GoogleService-Info.plist (if updated)"
echo ""
```

### Step 7: Test Firebase Connection

```bash
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🧪 Test Firebase Connection"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Run the app and try:"
echo "  1. Google Sign-In"
echo "  2. Check console for Firebase initialization logs"
echo "  3. Verify data appears in Firestore"
echo ""
echo "Run: flutter run"
echo ""
```

### Step 8: Update Documentation

```bash
echo "📚 Updating documentation..."

# Add Firebase project info to CLAUDE.md
echo ""
echo "⚠️  Update CLAUDE.md with your Firebase project details:"
echo "  - Project ID"
echo "  - Enabled services"
echo "  - Any custom configuration"
echo ""
```

### Step 9: Security Rules

```bash
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔒 Security Rules Templates"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Firestore Rules (firestore.rules):"
echo ""
cat << 'RULES'
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }

    // Add more collections as needed
  }
}
RULES
echo ""
echo "Storage Rules (storage.rules):"
echo ""
cat << 'RULES'
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // User profile images
    match /users/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
  }
}
RULES
echo ""
echo "Deploy rules: firebase deploy --only firestore:rules,storage:rules"
echo ""
```

### Step 10: Final Summary

```bash
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✨ Firebase Setup Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "✅ Configuration file created: lib/firebase_options.dart"
echo "✅ Firebase services ready to use"
echo ""
echo "📋 Checklist:"
echo "  ☐ Enable Authentication providers in Firebase Console"
echo "  ☐ Create Firestore database"
echo "  ☐ Enable Cloud Storage"
echo "  ☐ Add SHA-256 certificate (Android)"
echo "  ☐ Enable Apple Sign-In capability (iOS)"
echo "  ☐ Set up security rules"
echo "  ☐ Enable App Check"
echo "  ☐ Test authentication in the app"
echo ""
echo "🔗 Firebase Console: https://console.firebase.google.com"
echo "📚 FlutterFire Docs: https://firebase.flutter.dev"
echo ""
```

## Troubleshooting

### FlutterFire CLI not found

```bash
# Add to PATH
export PATH="$PATH":"$HOME/.pub-cache/bin"

# Or reinstall
dart pub global activate flutterfire_cli
```

### Firebase login issues

```bash
# Logout and login again
firebase logout
firebase login
```

### Configuration errors

```bash
# Remove existing config and reconfigure
rm lib/firebase_options.dart
flutterfire configure
```

## Manual Steps

If automatic configuration fails, follow manual setup:

1. Create Firebase project at https://console.firebase.google.com
2. Add Android app (download google-services.json)
3. Add iOS app (download GoogleService-Info.plist)
4. Run `flutterfire configure` to generate firebase_options.dart

## Security Checklist

- [ ] Use environment variables for sensitive keys
- [ ] Never commit Firebase config files to public repos
- [ ] Set up proper security rules
- [ ] Enable App Check for production
- [ ] Use different projects for dev/staging/prod
- [ ] Regularly review Firebase usage and logs

## Resources

- [Firebase Setup Guide](https://firebase.google.com/docs/flutter/setup)
- [FlutterFire Documentation](https://firebase.flutter.dev)
- [Security Rules Reference](https://firebase.google.com/docs/firestore/security/get-started)
