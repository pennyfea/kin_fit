# test - Run tests with coverage and analysis

Runs Flutter tests with options for coverage, specific files, and watch mode.

## Usage

```
/test [coverage|watch|file:<path>]
```

## Arguments

- `coverage` (optional): Run tests with coverage report
- `watch` (optional): Run tests in watch mode
- `file:<path>` (optional): Run specific test file

## Examples

```
/test                          # Run all tests
/test coverage                 # Run with coverage
/test watch                    # Watch mode
/test file:test/domain/models/user_test.dart
```

## What It Does

1. **Runs Flutter tests**
2. **Generates coverage report** (if requested)
3. **Opens coverage HTML** (if requested)
4. **Provides test summary**

## Steps

### Default: Run All Tests

```bash
if [ -z "{{arg1}}" ]; then
  echo "🧪 Running all tests..."
  echo ""

  flutter test

  echo ""
  echo "✅ Tests complete"
  exit 0
fi
```

### Coverage Mode

```bash
if [ "{{arg1}}" = "coverage" ]; then
  echo "🧪 Running tests with coverage..."
  echo ""

  # Run tests with coverage
  flutter test --coverage

  if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Tests passed"
    echo ""
    echo "📊 Generating coverage report..."

    # Check if genhtml is installed (lcov package)
    if command -v genhtml &> /dev/null; then
      # Generate HTML coverage report
      genhtml coverage/lcov.info -o coverage/html

      echo ""
      echo "✅ Coverage report generated"
      echo ""
      echo "📁 Report location: coverage/html/index.html"
      echo ""
      echo "Opening coverage report..."
      open coverage/html/index.html
    else
      echo ""
      echo "⚠️  genhtml not found. Install with:"
      echo "    brew install lcov"
      echo ""
      echo "Coverage data saved to: coverage/lcov.info"
    fi
  else
    echo ""
    echo "❌ Tests failed"
    exit 1
  fi

  exit 0
fi
```

### Watch Mode

```bash
if [ "{{arg1}}" = "watch" ]; then
  echo "👀 Running tests in watch mode..."
  echo ""
  echo "Tests will re-run when files change."
  echo "Press Ctrl+C to stop."
  echo ""

  # Install test watcher if not present
  if ! dart pub global list | grep -q test_watcher; then
    echo "Installing test watcher..."
    dart pub global activate test_watcher
  fi

  # Run in watch mode
  test_watcher

  exit 0
fi
```

### Specific File

```bash
if [[ "{{arg1}}" == file:* ]]; then
  TEST_FILE="${{arg1}#file:}"

  echo "🧪 Running test file: $TEST_FILE"
  echo ""

  if [ ! -f "$TEST_FILE" ]; then
    echo "❌ File not found: $TEST_FILE"
    exit 1
  fi

  flutter test "$TEST_FILE"

  echo ""
  echo "✅ Test complete"
  exit 0
fi
```

### Test Specific Directory

```bash
if [[ "{{arg1}}" == dir:* ]]; then
  TEST_DIR="${{arg1}#dir:}"

  echo "🧪 Running tests in directory: $TEST_DIR"
  echo ""

  if [ ! -d "$TEST_DIR" ]; then
    echo "❌ Directory not found: $TEST_DIR"
    exit 1
  fi

  flutter test "$TEST_DIR"

  echo ""
  echo "✅ Tests complete"
  exit 0
fi
```

### Unknown Option

```bash
echo "❌ Unknown option: {{arg1}}"
echo ""
echo "Usage: /test [coverage|watch|file:<path>|dir:<path>]"
exit 1
```

## Coverage Report Details

The coverage report shows:

- **Line coverage**: Percentage of executed lines
- **Function coverage**: Percentage of executed functions
- **Branch coverage**: Percentage of executed branches
- **Color-coded**: Green (covered), Red (not covered)

### Interpreting Results

- **80%+**: Good coverage
- **60-80%**: Moderate coverage
- **<60%**: Needs more tests

### Focus Areas

Prioritize coverage for:
1. Business logic (Blocs/Cubits)
2. Repositories
3. Domain models
4. Utilities

UI widgets can have lower coverage (integration tests are better).

## Testing Best Practices

### Test Organization

```
test/
├── data/           # Repository tests
├── domain/         # Model tests
├── ui/             # BLoC and widget tests
└── utils/          # Utility tests
```

### Naming Conventions

- Test files: `*_test.dart`
- Test groups: `group('ClassName', () { ... })`
- Test cases: `test('should do something', () { ... })`

### What to Test

✅ **DO test:**
- Business logic (Blocs/Cubits)
- Data transformations
- Repository methods
- Utility functions
- Model serialization
- Error handling

❌ **DON'T test:**
- Third-party packages
- Flutter framework code
- Generated code (*.g.dart, *.freezed.dart)

### Mock vs Fake

- **Mock** (Mocktail): For simple stubs
- **Fake** (testing/fakes/): For complex behavior

Example:
```dart
// Mock (simple)
final mockRepo = MockUserRepository();
when(() => mockRepo.getUser(any())).thenAnswer((_) async => mockUser);

// Fake (complex)
final fakeRepo = FakeUserRepository();  // Has full implementation
```

## Common Test Commands

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific file
flutter test test/domain/models/user_test.dart

# Run tests matching pattern
flutter test --name "UserRepository"

# Run tests in specific directory
flutter test test/data/repositories/

# Run with increased timeout
flutter test --timeout=2m

# Run in watch mode (with test_watcher)
dart pub global activate test_watcher
test_watcher
```

## Troubleshooting

### Tests failing

```bash
# Clean and rebuild
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter test
```

### Coverage not generated

```bash
# Ensure flutter test supports coverage
flutter test --help | grep coverage

# Check permissions
ls -la coverage/
```

### Watch mode not working

```bash
# Install test watcher
dart pub global activate test_watcher

# Check PATH
export PATH="$PATH":"$HOME/.pub-cache/bin"
```

### Slow tests

```bash
# Run in parallel (default)
flutter test --concurrency=4

# Run single file at a time
flutter test --concurrency=1
```

## CI/CD Integration

### GitHub Actions Example

```yaml
- name: Run tests
  run: flutter test --coverage

- name: Upload coverage
  uses: codecov/codecov-action@v3
  with:
    files: ./coverage/lcov.info
```

### GitLab CI Example

```yaml
test:
  script:
    - flutter test --coverage
  coverage: '/lines\.*: \d+\.\d+%/'
```

## Resources

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [BLoC Testing](https://bloclibrary.dev/testing)
- [Mocktail Package](https://pub.dev/packages/mocktail)
- [Coverage Package](https://pub.dev/packages/coverage)
