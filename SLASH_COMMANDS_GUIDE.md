# Slash Commands Guide

## ✨ Custom Commands for Claude Code

This template includes 4 custom slash commands to streamline Flutter development.

---

## 🚀 /new-project - Create New Project

Scaffolds a new Flutter project from this template with all configurations.

### Quick Start

```bash
/new-project my_awesome_app com.mycompany
```

### Where Can You Run This?

The command is **flexible** and works from multiple locations:

**Option 1: From inside the template directory** (recommended)
```bash
# Open Claude Code in flutter_template
cd /Users/austinpennyfeather/development/flutter_template
# Then run command - creates sibling directory
/new-project my_app
# Result: /Users/austinpennyfeather/development/my_app
```

**Option 2: From any directory with ../flutter_template**
```bash
# If template is in parent directory
cd /Users/austinpennyfeather/development/my_projects
/new-project my_app
# Result: /Users/austinpennyfeather/development/my_projects/my_app
```

**Option 3: From anywhere** (uses known template path)
```bash
# Works from any directory
cd ~/Desktop
/new-project my_app
# Result: ~/Desktop/my_app
# (Uses template from /Users/austinpennyfeather/development/flutter_template)
```

### What It Does

1. ✅ Copies template to `../my_awesome_app/`
2. ✅ Updates project name in `pubspec.yaml`
3. ✅ Updates app display name (e.g., `my_awesome_app` → "My Awesome App")
   - Android: AndroidManifest.xml
   - iOS: Info.plist
   - Web: manifest.json and index.html
   - Windows: CMakeLists.txt, Runner.rc, main.cpp
   - Linux: CMakeLists.txt, my_application.cc
   - macOS: AppInfo.xcconfig, project files
4. ✅ Updates bundle IDs
   - Android: `com.mycompany.my_awesome_app`
   - iOS: `com.mycompany.my_awesome_app`
   - Linux: `com.mycompany.my_awesome_app`
5. ✅ Updates all package imports
6. ✅ Runs `flutter pub get`
7. ✅ Runs `dart run build_runner build`
8. ✅ Initializes git repository
9. ✅ Creates `.env` file

### After Creation

```bash
cd ../my_awesome_app
flutterfire configure        # Configure Firebase
flutter run                  # Run the app
```

**Time:** ~2-3 minutes

---

## ✨ /add-feature - Scaffold Feature

Creates a new feature following the architecture (data by type, UI by feature).

### Quick Start

```bash
/add-feature profile yes
```

### What It Does

1. ✅ Creates `lib/ui/profile/blocs/profile/` with Cubit
2. ✅ Creates `lib/ui/profile/widgets/profile_screen.dart`
3. ✅ Creates `lib/data/repositories/profile_repository.dart` (if yes)
4. ✅ Creates `test/ui/profile/blocs/profile_cubit_test.dart`
5. ✅ Runs `dart run build_runner build`
6. ✅ Provides routing instructions

### Manual Steps Required

After the command completes, you need to:

1. Add route to `lib/routing/app_router.dart`:
```dart
GoRoute(
  path: Routes.profile,
  builder: (context, state) => const ProfileScreen(),
),
```

2. Add providers to `lib/main.dart`:
```dart
// If repository created:
RepositoryProvider(create: (_) => ProfileRepository()),

// BLoC provider:
BlocProvider(
  create: (context) => ProfileCubit(
    repository: context.read<ProfileRepository>(),
  ),
),
```

**Time:** ~1 minute + manual steps (~2-3 minutes)

---

## 🔥 /setup-firebase - Configure Firebase

Guides through complete Firebase setup with FlutterFire CLI.

### Quick Start

```bash
/setup-firebase
```

### What It Does

1. ✅ Checks prerequisites (Flutter, Firebase CLI, FlutterFire CLI)
2. ✅ Installs missing tools
3. ✅ Runs `firebase login`
4. ✅ Runs `flutterfire configure`
5. ✅ Generates `lib/firebase_options.dart`
6. ✅ Provides setup checklists
7. ✅ Shows security rules templates

### After Setup

Go to [Firebase Console](https://console.firebase.google.com) and enable:

- ✅ Authentication (Google, Apple, Email, Phone)
- ✅ Cloud Firestore
- ✅ Cloud Storage
- ✅ App Check

**Time:** ~5-10 minutes (including Firebase Console steps)

---

## 🧪 /test - Run Tests

Runs tests with various modes: all, coverage, watch, or specific files.

### Quick Start

```bash
/test coverage
```

### Modes

#### Run All Tests
```bash
/test
```

#### With Coverage Report
```bash
/test coverage
```
- Generates HTML coverage report
- Opens in browser automatically
- Shows line/function/branch coverage

#### Watch Mode (Re-run on Changes)
```bash
/test watch
```
- Automatically re-runs tests when files change
- Great for TDD workflow

#### Specific File
```bash
/test file:test/domain/models/user_test.dart
```

#### Specific Directory
```bash
/test dir:test/data/repositories/
```

**Time:** ~30 seconds - 2 minutes

---

## 📋 Command Reference

| Command | Arguments | Example |
|---------|-----------|---------|
| `/new-project` | `<name> [org]` | `/new-project my_app com.company` |
| `/add-feature` | `<name> [repo:yes\|no]` | `/add-feature settings yes` |
| `/setup-firebase` | None | `/setup-firebase` |
| `/test` | `[coverage\|watch\|file:<path>]` | `/test coverage` |

---

## 🎯 Common Workflows

### Starting a New Project

```bash
# 1. Create project
/new-project my_startup_app com.mystartup

# 2. Navigate to project
cd ../my_startup_app

# 3. Setup Firebase
/setup-firebase

# 4. Run app
flutter run
```

### Adding a Feature

```bash
# 1. Scaffold feature
/add-feature dashboard yes

# 2. Update routing (manual)
# Edit lib/routing/app_router.dart

# 3. Add providers (manual)
# Edit lib/main.dart

# 4. Test
/test file:test/ui/dashboard/blocs/dashboard_cubit_test.dart

# 5. Run app
flutter run
```

### TDD Workflow

```bash
# 1. Start watch mode
/test watch

# 2. Write test (it fails)
# Edit test/ui/my_feature/blocs/my_cubit_test.dart

# 3. Implement feature (test passes)
# Edit lib/ui/my_feature/blocs/my_cubit.dart

# 4. Refactor (tests still pass)

# 5. Check coverage
/test coverage
```

---

## 💡 Tips & Tricks

### Combine with MCP Server

The MCP server enhances slash commands:

```bash
# Before running /add-feature
"What features already exist in this project?"

# MCP analyzes codebase
# Shows: auth, home, profile

# Then run command
/add-feature settings yes
```

### Chain Commands

```bash
# Create project, add feature, test
/new-project my_app com.company
cd ../my_app
/add-feature dashboard yes
/test coverage
```

### Quick Testing

```bash
# Test specific area quickly
/test file:test/data/repositories/user_repository_test.dart

# Or entire layer
/test dir:test/data/
```

---

## 🔧 Customization

### Create Your Own Commands

1. Create file in `.claude/commands/`:
```bash
touch .claude/commands/my-command.md
```

2. Define command structure:
```markdown
# my-command - Description

## Usage
```
/my-command <arg>
```

## Steps

```bash
echo "Hello {{arg}}"
```
```

3. Use it:
```bash
/my-command world
```

### See Also

- [.claude/commands/README.md](.claude/commands/README.md) - Full command documentation
- [Creating Custom Commands Guide](.claude/commands/README.md#creating-custom-commands)

---

## 🐛 Troubleshooting

### Command Not Found

**Issue:** `/my-command` doesn't work

**Solution:**
1. Check file exists: `ls .claude/commands/my-command.md`
2. Restart Claude Code session
3. Check command syntax in file

### Variables Not Replacing

**Issue:** `{{arg}}` shows literally in output

**Solution:**
1. Check usage section defines arguments correctly
2. Ensure proper `{{argument_name}}` syntax
3. Verify argument names match between Usage and Steps

### Command Fails Silently

**Issue:** Command runs but doesn't complete

**Solution:**
1. Add `set -e` at start of bash blocks
2. Add `echo` statements for debugging
3. Check exit codes: `echo $?`
4. Run command steps manually to isolate issue

### Permission Denied

**Issue:** `Permission denied` errors

**Solution:**
```bash
# Make Flutter tools executable
chmod +x $(which flutter)
chmod +x $(which dart)

# Check PATH
echo $PATH
```

---

## 📊 Command Comparison

### vs Manual Steps

| Task | Manual | With Command | Time Saved |
|------|--------|--------------|-----------|
| Create project | 15 min | 3 min | 12 min |
| Add feature | 10 min | 4 min | 6 min |
| Setup Firebase | 20 min | 10 min | 10 min |
| Run tests | 1 min | 30 sec | 30 sec |

**Total time saved per project:** ~28 minutes

### vs Other Tools

| Feature | Slash Commands | CLI Scripts | Flutter CLI |
|---------|---------------|-------------|-------------|
| Interactive | ✅ Yes | ❌ No | ❌ No |
| Context-aware | ✅ Yes | ❌ No | ❌ No |
| Template-specific | ✅ Yes | ⚠️ Partial | ❌ No |
| Error guidance | ✅ Yes | ⚠️ Basic | ⚠️ Basic |
| AI integration | ✅ Yes | ❌ No | ❌ No |

---

## 🎓 Learning Resources

### Documentation

- **Command Files:** `.claude/commands/*.md`
- **Claude Code Docs:** https://code.claude.com/docs/en/slash-commands
- **Bash Guide:** https://www.gnu.org/software/bash/manual/
- **Flutter CLI:** https://docs.flutter.dev/reference/flutter-cli

### Example Projects

Use these commands on the template itself to see how they work:

```bash
# Create a test project
/new-project test_app com.test

# Explore the created structure
cd ../test_app
tree -L 3
```

---

## ✨ Benefits

### For You

- ⚡ **Faster development** - Automate repetitive tasks
- 🎯 **Consistent structure** - Follow architecture automatically
- 📚 **Less context switching** - Stay in Claude Code
- 🔍 **Better discoverability** - Commands are self-documenting

### For AI Assistants

- 🧠 **Better understanding** - Commands reveal project structure
- 🎨 **Accurate suggestions** - Knows your architecture patterns
- 🤖 **Automated workflows** - Can suggest and execute commands
- 📖 **Learning from usage** - Improves assistance over time

### For Teams

- 📋 **Standardized workflows** - Everyone uses same process
- 🚀 **Faster onboarding** - New devs productive faster
- 📖 **Self-documenting** - Commands explain the "how"
- ✅ **Quality consistency** - Less variation in output

---

## 🎉 Next Steps

1. **Try a command:**
   ```bash
   /test coverage
   ```

2. **Create a test project:**
   ```bash
   /new-project test_app
   ```

3. **Read command source:**
   ```bash
   cat .claude/commands/new-project.md
   ```

4. **Create your own command:**
   ```bash
   touch .claude/commands/deploy.md
   ```

---

**Template Version:** 1.0.0
**Commands Available:** 4
**Total Time Saved:** ~28 minutes per project
**Last Updated:** 2026-01-21
