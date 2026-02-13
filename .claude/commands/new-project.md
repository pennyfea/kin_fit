# new-project - Create a new Flutter project from this template

Creates a new Flutter project from the template with proper configuration.

## Usage

```
/new-project <project_name> [organization]
```

## Arguments

- `project_name` (required): Name of your new project (snake_case)
- `organization` (optional): Organization identifier (e.g., com.mycompany). Default: com.example

## Examples

```
/new-project my_awesome_app
/new-project my_awesome_app com.mycompany
```

## What It Does

1. **Copies template** to parent directory with new name
2. **Updates project name** in pubspec.yaml
3. **Updates app display name** (converts snake_case to Title Case, e.g., my_app → My App)
   - Android: AndroidManifest.xml label
   - iOS: Info.plist CFBundleName and CFBundleDisplayName
   - Web: manifest.json and index.html
   - Windows: CMakeLists.txt, Runner.rc, main.cpp
   - Linux: CMakeLists.txt, my_application.cc
   - macOS: AppInfo.xcconfig, project.pbxproj
4. **Updates bundle identifiers** in Android, iOS, and Linux configs
5. **Updates imports** to use new package name
6. **Runs initial setup**:
   - `flutter pub get`
   - `dart run build_runner build`
7. **Creates project-specific docs**
8. **Initializes git repository**

## Steps

Execute these commands in order:

### Step 1: Validate Inputs

```bash
PROJECT_NAME="{{project_name}}"
ORG="{{organization:-com.example}}"

# Validate project name (must be snake_case)
if ! [[ "$PROJECT_NAME" =~ ^[a-z][a-z0-9_]*$ ]]; then
  echo "❌ Error: Project name must be snake_case (lowercase letters, numbers, underscores)"
  exit 1
fi

echo "✅ Creating project: $PROJECT_NAME"
echo "✅ Organization: $ORG"
```

### Step 2: Locate Template and Set Destination

```bash
# Find the template directory
# Option 1: If we're in the template directory
if [ -f "ARCHITECTURE.md" ] && [ -d ".claude/commands" ]; then
  TEMPLATE_DIR="$PWD"
  echo "✅ Using current directory as template: $TEMPLATE_DIR"
# Option 2: If template is at known location
elif [ -d "/Users/austinpennyfeather/development/flutter_template" ]; then
  TEMPLATE_DIR="/Users/austinpennyfeather/development/flutter_template"
  echo "✅ Using template at: $TEMPLATE_DIR"
# Option 3: Search in parent directories
elif [ -d "../flutter_template" ]; then
  TEMPLATE_DIR="$(cd ../flutter_template && pwd)"
  echo "✅ Found template at: $TEMPLATE_DIR"
else
  echo "❌ Error: Cannot find flutter_template directory"
  echo "   Please ensure you're running this from:"
  echo "   1. Inside the flutter_template directory, OR"
  echo "   2. From a directory with ../flutter_template, OR"
  echo "   3. The template exists at /Users/austinpennyfeather/development/flutter_template"
  exit 1
fi

# Set destination directory (in current directory or template parent)
if [ "$PWD" = "$TEMPLATE_DIR" ]; then
  # We're in template, create sibling directory
  PARENT_DIR="$(dirname "$TEMPLATE_DIR")"
  NEW_PROJECT_DIR="$PARENT_DIR/$PROJECT_NAME"
else
  # We're somewhere else, create in current directory
  NEW_PROJECT_DIR="$PWD/$PROJECT_NAME"
fi

echo "📁 New project will be created at: $NEW_PROJECT_DIR"

# Check if project already exists
if [ -d "$NEW_PROJECT_DIR" ]; then
  echo "❌ Error: Directory $NEW_PROJECT_DIR already exists"
  exit 1
fi

# Copy template
echo "📁 Copying template..."
cp -r "$TEMPLATE_DIR" "$NEW_PROJECT_DIR"

# Remove template-specific files
cd "$NEW_PROJECT_DIR"
rm -rf .git
rm -f MCP_VERIFICATION.md TEMPLATE_SUMMARY.md PROJECT_ANALYSIS.md MIGRATION_GUIDE.md FINAL_SUMMARY.md QUICK_REFERENCE.md

echo "✅ Template copied"
```

### Step 3: Update Project Name in pubspec.yaml

```bash
echo "📝 Updating pubspec.yaml..."

# Update name
sed -i '' "s/^name: flutter_template/name: $PROJECT_NAME/" pubspec.yaml

# Update description
sed -i '' "s/A reusable Flutter project template/A new Flutter project created from template/" pubspec.yaml

echo "✅ pubspec.yaml updated"
```

### Step 4: Update App Display Name

```bash
echo "🏷️  Updating app display name..."

# Convert snake_case to Title Case (e.g., my_awesome_app -> My Awesome App)
DISPLAY_NAME=$(echo "$PROJECT_NAME" | sed 's/_/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1')

echo "   Display name will be: $DISPLAY_NAME"

# Update Android app label
if [ -f "android/app/src/main/AndroidManifest.xml" ]; then
  sed -i '' "s/android:label=\"flutter_template\"/android:label=\"$DISPLAY_NAME\"/" android/app/src/main/AndroidManifest.xml
  echo "✅ Android app label updated"
fi

# Update iOS app name
if [ -f "ios/Runner/Info.plist" ]; then
  # Update CFBundleName (handles both formats: flutter_template and Flutter Template)
  sed -i '' "/<key>CFBundleName<\/key>/{n;s/<string>.*<\/string>/<string>$DISPLAY_NAME<\/string>/;}" ios/Runner/Info.plist
  # Update CFBundleDisplayName (handles both formats)
  sed -i '' "/<key>CFBundleDisplayName<\/key>/{n;s/<string>.*<\/string>/<string>$DISPLAY_NAME<\/string>/;}" ios/Runner/Info.plist
  echo "✅ iOS app name updated"
fi

echo "✅ App display name set to: $DISPLAY_NAME"
```

### Step 5: Update Android Bundle ID

```bash
echo "📱 Updating Android configuration..."

# Update build.gradle
if [ -f "android/app/build.gradle" ]; then
  sed -i '' "s/com\.template/$ORG/" android/app/build.gradle
  echo "✅ Android bundle ID updated to $ORG.$PROJECT_NAME"
fi

# Update AndroidManifest.xml package
if [ -f "android/app/src/main/AndroidManifest.xml" ]; then
  sed -i '' "s/com\.template\.flutter_template/$ORG.$PROJECT_NAME/" android/app/src/main/AndroidManifest.xml
fi
```

### Step 6: Update iOS Bundle ID

```bash
echo "🍎 Updating iOS configuration..."

if [ -d "ios/Runner.xcodeproj" ]; then
  # Update project.pbxproj
  if [ -f "ios/Runner.xcodeproj/project.pbxproj" ]; then
    sed -i '' "s/com\.template\.flutterTemplate/$ORG.$PROJECT_NAME/" ios/Runner.xcodeproj/project.pbxproj
    echo "✅ iOS bundle ID updated to $ORG.$PROJECT_NAME"
  fi
fi
```

### Step 7: Update Package Imports and App Title

```bash
echo "📦 Updating package imports and app title..."

# Update all Dart files to use new package name
find lib test -name "*.dart" -type f -exec sed -i '' \
  "s/package:flutter_template/package:$PROJECT_NAME/g" {} \;

# Update MaterialApp title in main.dart
if [ -f "lib/main.dart" ]; then
  sed -i '' "s/title: 'Flutter Template'/title: '$DISPLAY_NAME'/" lib/main.dart
  echo "✅ App title in main.dart updated"
fi

echo "✅ Package imports and app title updated"
```

### Step 8: Update Documentation

```bash
echo "📚 Updating documentation..."

# Update CLAUDE.md with project name
sed -i '' "s/flutter_template/$PROJECT_NAME/g" CLAUDE.md

# Update README.md
sed -i '' "s/flutter_template/$PROJECT_NAME/g" README.md
sed -i '' "s/my_app/$PROJECT_NAME/g" README.md

echo "✅ Documentation updated"
```

### Step 9: Update Web Configuration

```bash
echo "🌐 Updating web configuration..."

# Update web/manifest.json
if [ -f "web/manifest.json" ]; then
  sed -i '' "s/\"name\": \"flutter_template\"/\"name\": \"$DISPLAY_NAME\"/" web/manifest.json
  sed -i '' "s/\"short_name\": \"flutter_template\"/\"short_name\": \"$DISPLAY_NAME\"/" web/manifest.json
  echo "✅ Web manifest updated"
fi

# Update web/index.html
if [ -f "web/index.html" ]; then
  sed -i '' "s/<title>flutter_template<\/title>/<title>$DISPLAY_NAME<\/title>/" web/index.html
  sed -i '' "s/content=\"flutter_template\"/content=\"$DISPLAY_NAME\"/" web/index.html
  echo "✅ Web index.html updated"
fi

echo "✅ Web configuration updated"
```

### Step 10: Update Desktop Platform Configurations

```bash
echo "🖥️  Updating desktop platform configurations..."

# Windows
if [ -f "windows/CMakeLists.txt" ]; then
  sed -i '' "s/project(flutter_template LANGUAGES CXX)/project($PROJECT_NAME LANGUAGES CXX)/" windows/CMakeLists.txt
  sed -i '' "s/set(BINARY_NAME \"flutter_template\")/set(BINARY_NAME \"$PROJECT_NAME\")/" windows/CMakeLists.txt
  echo "✅ Windows CMakeLists.txt updated"
fi

if [ -f "windows/runner/Runner.rc" ]; then
  sed -i '' "s/\"flutter_template\"/\"$DISPLAY_NAME\"/g" windows/runner/Runner.rc
  sed -i '' "s/flutter_template.exe/$PROJECT_NAME.exe/" windows/runner/Runner.rc
  echo "✅ Windows Runner.rc updated"
fi

if [ -f "windows/runner/main.cpp" ]; then
  sed -i '' "s/L\"flutter_template\"/L\"$DISPLAY_NAME\"/" windows/runner/main.cpp
  echo "✅ Windows main.cpp updated"
fi

# Linux
if [ -f "linux/CMakeLists.txt" ]; then
  sed -i '' "s/set(BINARY_NAME \"flutter_template\")/set(BINARY_NAME \"$PROJECT_NAME\")/" linux/CMakeLists.txt
  sed -i '' "s/set(APPLICATION_ID \"com.template.flutter_template\")/set(APPLICATION_ID \"$ORG.$PROJECT_NAME\")/" linux/CMakeLists.txt
  echo "✅ Linux CMakeLists.txt updated"
fi

if [ -f "linux/runner/my_application.cc" ]; then
  sed -i '' "s/\"flutter_template\"/\"$DISPLAY_NAME\"/g" linux/runner/my_application.cc
  echo "✅ Linux my_application.cc updated"
fi

# macOS
if [ -f "macos/Runner/Configs/AppInfo.xcconfig" ]; then
  sed -i '' "s/PRODUCT_NAME = flutter_template/PRODUCT_NAME = $PROJECT_NAME/" macos/Runner/Configs/AppInfo.xcconfig
  echo "✅ macOS AppInfo.xcconfig updated"
fi

if [ -f "macos/Runner.xcodeproj/project.pbxproj" ]; then
  sed -i '' "s/flutter_template.app/$PROJECT_NAME.app/g" macos/Runner.xcodeproj/project.pbxproj
  sed -i '' "s/flutter_template/$PROJECT_NAME/g" macos/Runner.xcodeproj/project.pbxproj
  echo "✅ macOS project.pbxproj updated"
fi

if [ -f "macos/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme" ]; then
  sed -i '' "s/flutter_template.app/$PROJECT_NAME.app/g" macos/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme
  echo "✅ macOS Runner.xcscheme updated"
fi

echo "✅ Desktop platform configurations updated"
```

### Step 11: Install Dependencies

```bash
echo "📥 Installing dependencies..."

# Get dependencies
flutter pub get

echo "✅ Dependencies installed"
```

### Step 12: Generate Code

```bash
echo "⚙️ Generating code (Freezed, json_serializable)..."

# Run build_runner
dart run build_runner build --delete-conflicting-outputs

echo "✅ Code generated"
```

### Step 13: Initialize Git

```bash
echo "🔧 Initializing git repository..."

git init
git add .
git commit -m "Initial commit from Flutter template

Project: $PROJECT_NAME
Organization: $ORG
Template version: 1.0.0"

echo "✅ Git repository initialized"
```

### Step 14: Create .env File

```bash
echo "🔐 Creating .env file..."

cp .env.example .env

echo "✅ .env file created (remember to add your API keys)"
```

### Step 15: Final Summary

```bash
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✨ Project created successfully!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📁 Location: $NEW_PROJECT_DIR"
echo "📦 Package: $PROJECT_NAME"
echo "📱 App Name: $DISPLAY_NAME"
echo "🏢 Organization: $ORG"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 Next Steps:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1. Navigate to your project:"
echo "   cd $NEW_PROJECT_DIR"
echo ""
echo "2. Configure Firebase:"
echo "   flutterfire configure"
echo ""
echo "3. Update .env with your API keys"
echo ""
echo "4. Run the app:"
echo "   flutter run"
echo ""
echo "5. Update CLAUDE.md with project-specific context"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📚 Documentation:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "- README.md           - Quick start guide"
echo "- ARCHITECTURE.md     - Project structure"
echo "- CLAUDE.md           - AI assistant context"
echo "- MCP_SETUP.md        - MCP server info"
echo ""
echo "✅ Happy coding!"
```

## Notes

- The command creates the project in the **parent directory** of the template
- All template files are copied except git history and template-specific docs
- Firebase configuration must be done manually after creation
- The command runs `flutter pub get` and `dart run build_runner build`
- A git repository is initialized with an initial commit

## Troubleshooting

If the command fails:

1. **Check project name**: Must be snake_case (lowercase, underscores only)
2. **Check directory**: Parent directory must be writable
3. **Check Flutter**: Ensure Flutter is in PATH
4. **Manual cleanup**: If partially created, delete the new directory and try again

## Alternative: Manual Creation

If you prefer manual steps, see the README.md "Quick Start" section for detailed instructions.
