# Custom Slash Commands

This directory contains custom slash commands for Claude Code to streamline Flutter development with this template.

## Available Commands

### 🚀 /new-project

Create a new Flutter project from this template.

```bash
/new-project <project_name> [organization]
```

**Examples:**
```bash
/new-project my_awesome_app
/new-project my_awesome_app com.mycompany
```

**What it does:**
- Copies template to new directory
- Updates project name and bundle IDs
- Configures Android and iOS
- Runs pub get and build_runner
- Initializes git repository
- Creates .env file

**Time:** ~2-3 minutes

---

### ✨ /add-feature

Scaffold a new feature following the architecture.

```bash
/add-feature <feature_name> [needs_repository:yes|no]
```

**Examples:**
```bash
/add-feature profile
/add-feature settings yes
```

**What it does:**
- Creates feature folder structure
- Generates BLoC/Cubit with Freezed states
- Creates screen widget
- Optionally creates repository
- Generates test files
- Provides routing instructions

**Time:** ~1 minute

---

### 🔥 /setup-firebase

Configure Firebase for this project.

```bash
/setup-firebase
```

**What it does:**
- Checks prerequisites
- Installs FlutterFire CLI if needed
- Runs flutterfire configure
- Guides through Firebase Console setup
- Provides security rules templates
- Shows platform-specific configuration

**Time:** ~5-10 minutes (with manual steps)

---

### 🧪 /test

Run tests with various options.

```bash
/test [coverage|watch|file:<path>|dir:<path>]
```

**Examples:**
```bash
/test                      # Run all tests
/test coverage             # Run with coverage report
/test watch                # Watch mode (re-run on changes)
/test file:test/domain/models/user_test.dart
/test dir:test/data/repositories/
```

**What it does:**
- Runs Flutter tests
- Generates coverage report (if requested)
- Opens HTML coverage report
- Watches for changes (if requested)

**Time:** ~30 seconds - 2 minutes

---

## How Slash Commands Work

### Execution

Slash commands are executed by Claude Code when you type them in the chat:

1. You type: `/new-project my_app`
2. Claude reads: `.claude/commands/new-project.md`
3. Claude executes the bash commands in sequence
4. Results are shown in the chat

### Command Files

Each command is defined in a `.md` file with:

- **Description**: What the command does
- **Usage**: How to use it
- **Arguments**: Required and optional parameters
- **Steps**: Bash commands to execute
- **Examples**: Usage examples
- **Notes**: Additional information

### Variables

Commands can use variables from arguments:

```bash
PROJECT_NAME="{{project_name}}"
ORG="{{organization:-com.example}}"  # With default value
```

### Conditional Logic

Commands can include conditionals:

```bash
if [ "$NEEDS_REPO" = "yes" ]; then
  # Create repository
fi
```

---

## Creating Custom Commands

### 1. Create Command File

Create a new `.md` file in `.claude/commands/`:

```bash
touch .claude/commands/my-command.md
```

### 2. Define Command Structure

```markdown
# my-command - Short description

Longer description of what it does.

## Usage

```
/my-command <arg1> [arg2]
```

## Arguments

- `arg1` (required): Description
- `arg2` (optional): Description

## Examples

```
/my-command value1
/my-command value1 value2
```

## Steps

### Step 1: Do Something

```bash
echo "Hello {{arg1}}"
```

### Step 2: Do Something Else

```bash
if [ "{{arg2}}" = "special" ]; then
  echo "Special handling"
fi
```

## Notes

Additional information.
```

### 3. Test Your Command

```bash
# In Claude Code
/my-command test-value
```

---

## Best Practices

### Command Design

✅ **DO:**
- Use clear, descriptive names
- Provide helpful examples
- Include error handling
- Show progress with echo statements
- Provide manual fallback instructions
- Document prerequisites

❌ **DON'T:**
- Make commands too complex
- Assume environment state
- Skip validation
- Forget to handle errors

### Error Handling

Always validate inputs:

```bash
if [ -z "{{arg1}}" ]; then
  echo "❌ Error: Argument required"
  exit 1
fi
```

### User Feedback

Provide clear feedback:

```bash
echo "✅ Step completed"
echo "❌ Step failed"
echo "⚠️  Warning: Manual step required"
echo "📝 Note: Additional information"
```

### Manual Steps

When automation isn't possible:

```bash
echo ""
echo "⚠️  Manual step required:"
echo "1. Open Firebase Console"
echo "2. Enable Authentication"
echo "3. Add SHA-256 certificate"
echo ""
```

---

## Command Templates

### Simple Command

For commands that run a single operation:

```markdown
# command-name - Description

## Usage

```
/command-name
```

## Steps

```bash
echo "Doing something..."
flutter build apk
echo "✅ Done"
```
```

### Command with Arguments

For commands that need user input:

```markdown
# command-name - Description

## Usage

```
/command-name <arg1> [arg2]
```

## Steps

```bash
ARG1="{{arg1}}"
ARG2="{{arg2:-default}}"

# Validate
if [ -z "$ARG1" ]; then
  echo "❌ Error: arg1 required"
  exit 1
fi

# Execute
echo "Processing $ARG1..."
```
```

### Multi-Step Command

For complex workflows:

```markdown
# command-name - Description

## Steps

### Step 1: Preparation

```bash
echo "Preparing..."
```

### Step 2: Main Work

```bash
echo "Working..."
```

### Step 3: Cleanup

```bash
echo "Cleaning up..."
echo "✅ Complete"
```
```

---

## Useful Command Ideas

### For This Template

- `/deploy` - Build and deploy to app stores
- `/lint` - Run linters and formatters
- `/update-deps` - Update all dependencies
- `/clean-build` - Clean and rebuild project
- `/analyze` - Run static analysis

### General Flutter

- `/add-package <name>` - Add package from pub.dev
- `/remove-package <name>` - Remove package
- `/create-model <name>` - Generate model with Freezed
- `/create-screen <name>` - Generate screen boilerplate

---

## Debugging Commands

### Check Command Files

```bash
# List all commands
ls -la .claude/commands/

# View command content
cat .claude/commands/new-project.md
```

### Test Bash Snippets

Extract and test bash snippets independently:

```bash
# Copy bash from command file
PROJECT_NAME="test_app"
echo "Creating $PROJECT_NAME..."
```

### Common Issues

**Command not found:**
- Check file exists in `.claude/commands/`
- File must end in `.md`
- Name must match command usage

**Variables not replacing:**
- Use `{{variable_name}}` syntax
- Check spelling matches usage

**Command fails silently:**
- Add `set -e` to stop on first error
- Add echo statements for debugging
- Check exit codes

---

## Resources

- [Claude Code Slash Commands Docs](https://code.claude.com/docs/en/slash-commands)
- [Bash Scripting Guide](https://www.gnu.org/software/bash/manual/)
- [Flutter CLI Reference](https://docs.flutter.dev/reference/flutter-cli)

---

## Contributing

To add new commands to the template:

1. Create command file in `.claude/commands/`
2. Follow naming convention (kebab-case)
3. Include comprehensive documentation
4. Test thoroughly
5. Update this README

---

**Template Version:** 1.0.0
**Commands:** 4
**Last Updated:** 2026-01-21
