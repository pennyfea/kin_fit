# add-feature - Scaffold a new feature following the architecture

Creates a new feature with proper structure (data by type, UI by feature).

## Usage

```
/add-feature <feature_name> [needs_repository:yes|no]
```

## Arguments

- `feature_name` (required): Name of the feature (snake_case)
- `needs_repository` (optional): Whether to create a new repository. Default: no

## Examples

```
/add-feature profile
/add-feature settings yes
/add-feature notifications no
```

## What It Does

1. **Creates UI feature structure**:
   - `lib/ui/{feature}/blocs/`
   - `lib/ui/{feature}/widgets/`

2. **Optionally creates data layer**:
   - `lib/data/repositories/{feature}_repository.dart` (if needs_repository=yes)

3. **Creates domain model** (if needs_repository=yes):
   - `lib/domain/models/{feature}.dart`

4. **Generates boilerplate**:
   - BLoC/Cubit with states and events
   - Screen widget
   - Repository (if needed)

5. **Updates routing**:
   - Adds route constant
   - Adds route configuration

## Steps

### Step 1: Validate Input

```bash
FEATURE_NAME="{{feature_name}}"
NEEDS_REPO="{{needs_repository:-no}}"

# Validate feature name
if ! [[ "$FEATURE_NAME" =~ ^[a-z][a-z0-9_]*$ ]]; then
  echo "❌ Error: Feature name must be snake_case"
  exit 1
fi

# Convert to PascalCase for class names
FEATURE_CLASS=$(echo "$FEATURE_NAME" | sed -r 's/(^|_)([a-z])/\U\2/g')

echo "✅ Creating feature: $FEATURE_NAME"
echo "✅ Class prefix: $FEATURE_CLASS"
```

### Step 2: Create UI Structure

```bash
echo "📁 Creating UI structure..."

# Create directories
mkdir -p "lib/ui/$FEATURE_NAME/blocs/${FEATURE_NAME}"
mkdir -p "lib/ui/$FEATURE_NAME/widgets"

echo "✅ Directories created"
```

### Step 3: Create BLoC Files

```bash
echo "🧠 Creating BLoC files..."

# Create Cubit
cat > "lib/ui/$FEATURE_NAME/blocs/${FEATURE_NAME}/${FEATURE_NAME}_cubit.dart" << 'EOF'
import 'package:flutter_bloc/flutter_bloc.dart';
import '${FEATURE_NAME}_state.dart';

/// Manages state for the $FEATURE_CLASS feature.
class ${FEATURE_CLASS}Cubit extends Cubit<${FEATURE_CLASS}State> {
  ${FEATURE_CLASS}Cubit() : super(const ${FEATURE_CLASS}State.initial());

  /// Loads $FEATURE_NAME data.
  Future<void> load() async {
    emit(const ${FEATURE_CLASS}State.loading());
    try {
      // TODO: Implement loading logic
      emit(const ${FEATURE_CLASS}State.loaded());
    } catch (e) {
      emit(${FEATURE_CLASS}State.error(e.toString()));
    }
  }
}
EOF

# Create State
cat > "lib/ui/$FEATURE_NAME/blocs/${FEATURE_NAME}/${FEATURE_NAME}_state.dart" << 'EOF'
import 'package:freezed_annotation/freezed_annotation.dart';

part '${FEATURE_NAME}_state.freezed.dart';

/// Represents the state of the $FEATURE_CLASS feature.
@freezed
class ${FEATURE_CLASS}State with _\$${FEATURE_CLASS}State {
  const factory ${FEATURE_CLASS}State.initial() = _Initial;
  const factory ${FEATURE_CLASS}State.loading() = _Loading;
  const factory ${FEATURE_CLASS}State.loaded() = _Loaded;
  const factory ${FEATURE_CLASS}State.error(String message) = _Error;
}
EOF

echo "✅ BLoC files created"
```

### Step 4: Create Screen Widget

```bash
echo "🎨 Creating screen widget..."

cat > "lib/ui/$FEATURE_NAME/widgets/${FEATURE_NAME}_screen.dart" << 'EOF'
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/$FEATURE_NAME/${FEATURE_NAME}_cubit.dart';
import '../blocs/$FEATURE_NAME/${FEATURE_NAME}_state.dart';

/// Main screen for the $FEATURE_CLASS feature.
class ${FEATURE_CLASS}Screen extends StatelessWidget {
  const ${FEATURE_CLASS}Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('$FEATURE_CLASS'),
      ),
      body: BlocBuilder<${FEATURE_CLASS}Cubit, ${FEATURE_CLASS}State>(
        builder: (context, state) {
          return state.when(
            initial: () => const Center(
              child: Text('Press the button to load'),
            ),
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            loaded: () => const Center(
              child: Text('Data loaded successfully'),
            ),
            error: (message) => Center(
              child: Text('Error: \$message'),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<${FEATURE_CLASS}Cubit>().load();
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
EOF

echo "✅ Screen widget created"
```

### Step 5: Create Repository (if needed)

```bash
if [ "$NEEDS_REPO" = "yes" ]; then
  echo "📦 Creating repository..."

  cat > "lib/data/repositories/${FEATURE_NAME}_repository.dart" << 'EOF'
import 'package:cloud_firestore/cloud_firestore.dart';

/// Repository for $FEATURE_NAME data access.
class ${FEATURE_CLASS}Repository {
  final FirebaseFirestore _firestore;

  ${FEATURE_CLASS}Repository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Fetches $FEATURE_NAME data.
  Future<void> fetch() async {
    // TODO: Implement data fetching
  }

  /// Saves $FEATURE_NAME data.
  Future<void> save() async {
    // TODO: Implement data saving
  }
}
EOF

  echo "✅ Repository created"
fi
```

### Step 6: Update Routing

```bash
echo "🛣️ Updating routing..."

# Add route constant
echo "  static const ${FEATURE_NAME} = '/${FEATURE_NAME}';" >> lib/routing/routes.dart

# Add to router (manual step - show instructions)
echo ""
echo "⚠️  Manual step required:"
echo "Add this route to lib/routing/app_router.dart:"
echo ""
echo "GoRoute("
echo "  path: Routes.${FEATURE_NAME},"
echo "  builder: (context, state) => const ${FEATURE_CLASS}Screen(),"
echo "),"
echo ""
```

### Step 7: Update main.dart

```bash
echo "🔧 Update required in main.dart..."
echo ""
echo "⚠️  Manual step required:"
echo "Add this BlocProvider to main.dart:"
echo ""
if [ "$NEEDS_REPO" = "yes" ]; then
echo "RepositoryProvider("
echo "  create: (_) => ${FEATURE_CLASS}Repository(),"
echo "),"
echo ""
fi
echo "BlocProvider("
echo "  create: (context) => ${FEATURE_CLASS}Cubit("
if [ "$NEEDS_REPO" = "yes" ]; then
echo "    repository: context.read<${FEATURE_CLASS}Repository>(),"
fi
echo "  ),"
echo "),"
echo ""
```

### Step 8: Run Code Generation

```bash
echo "⚙️ Running code generation..."

dart run build_runner build --delete-conflicting-outputs

echo "✅ Code generation complete"
```

### Step 9: Create Test Files

```bash
echo "🧪 Creating test files..."

mkdir -p "test/ui/$FEATURE_NAME/blocs"

cat > "test/ui/$FEATURE_NAME/blocs/${FEATURE_NAME}_cubit_test.dart" << 'EOF'
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_template/ui/$FEATURE_NAME/blocs/$FEATURE_NAME/${FEATURE_NAME}_cubit.dart';
import 'package:flutter_template/ui/$FEATURE_NAME/blocs/$FEATURE_NAME/${FEATURE_NAME}_state.dart';

void main() {
  group('${FEATURE_CLASS}Cubit', () {
    late ${FEATURE_CLASS}Cubit cubit;

    setUp(() {
      cubit = ${FEATURE_CLASS}Cubit();
    });

    test('initial state is initial', () {
      expect(cubit.state, const ${FEATURE_CLASS}State.initial());
    });

    blocTest<${FEATURE_CLASS}Cubit, ${FEATURE_CLASS}State>(
      'emits [loading, loaded] when load succeeds',
      build: () => cubit,
      act: (cubit) => cubit.load(),
      expect: () => [
        const ${FEATURE_CLASS}State.loading(),
        const ${FEATURE_CLASS}State.loaded(),
      ],
    );
  });
}
EOF

echo "✅ Test files created"
```

### Step 10: Summary

```bash
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✨ Feature scaffolded successfully!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📁 Created:"
echo "  - lib/ui/$FEATURE_NAME/blocs/${FEATURE_NAME}/"
echo "  - lib/ui/$FEATURE_NAME/widgets/${FEATURE_NAME}_screen.dart"
if [ "$NEEDS_REPO" = "yes" ]; then
echo "  - lib/data/repositories/${FEATURE_NAME}_repository.dart"
fi
echo "  - test/ui/$FEATURE_NAME/blocs/${FEATURE_NAME}_cubit_test.dart"
echo ""
echo "⚠️  Manual steps required:"
echo "  1. Update lib/routing/app_router.dart with new route"
echo "  2. Add BlocProvider to main.dart"
if [ "$NEEDS_REPO" = "yes" ]; then
echo "  3. Add RepositoryProvider to main.dart"
fi
echo "  4. Implement TODOs in generated files"
echo ""
echo "✅ Run 'flutter test' to verify setup"
```

## Notes

- Creates feature following architecture (data by type, UI by feature)
- Generates Freezed state classes (requires code generation)
- Creates basic test structure
- Requires manual routing and provider setup
- TODO comments mark areas needing implementation

## Next Steps

1. Implement business logic in the Cubit
2. Add repository methods (if created)
3. Design the UI in the screen widget
4. Write comprehensive tests
5. Update routing and dependency injection
