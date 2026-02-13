# Dart and Flutter MCP Server Setup

## What is MCP?

The **MCP (Model Context Protocol) server** enables AI assistants to deeply understand and interact with your Flutter/Dart codebase by providing:

- 🔍 **Widget tree introspection** - Visualize and debug layout issues
- 📦 **Dependency management** - Search pub.dev and add packages
- ⚡ **Runtime control** - Trigger hot reloads and restarts
- 🐛 **Error analysis** - Fix complex errors with deep context

**Benefits:** Transforms AI from a generic code assistant into a Flutter-aware development partner that understands your project's architecture.

---

## Installation

### Prerequisites

- **Dart 3.9+** or **Flutter 3.35+** (you have this if your Flutter is up to date)
- The MCP server is **built into the Dart SDK** - no separate installation needed!

### Verify Installation

```bash
dart --version  # Should show 3.9 or later
dart mcp-server --help  # Should show MCP server options
```

### Option 1: Claude Code (Easiest) ✅ **RECOMMENDED**

The MCP server is already configured for this project! Run:

```bash
claude mcp add --transport stdio dart -- dart mcp-server
```

This command was already executed for this template - you're ready to go!

### Option 2: Using Gemini CLI

Install the Flutter extension:

```bash
gemini extensions install https://github.com/gemini-cli-extensions/flutter
```

### Option 3: Manual Setup (Cursor, etc.)

For other AI assistants, follow the setup guide:

📚 [Dart MCP Server Documentation](https://docs.flutter.dev/ai/mcp-server)
🔗 [GitHub Repository](https://github.com/dart-lang/ai/tree/main/pkgs/dart_mcp_server)

---

## Compatible AI Assistants

The MCP server works with these AI tools through the MCP specification:

| Assistant | Support | Notes |
|-----------|---------|-------|
| **Claude Code** | ✅ Full | Built-in MCP support |
| **Cursor** | ✅ Full | IDE with AI capabilities |
| **Gemini Code Assist** | ✅ Full | Best with VS Code or JetBrains |
| **Windsurf** | ✅ Full | AI-first editor |
| **Antigravity** | ✅ Full | In-IDE AI agent |
| **GitHub Copilot** | ⚠️ Limited | No MCP support yet |

---

## Configuration for Claude Code ✅ **ALREADY CONFIGURED**

The MCP server has been configured for this project!

### What Was Set Up

When you run Claude Code in this project, it automatically connects to the Dart MCP server with this configuration:

```json
{
  "mcpServers": {
    "dart": {
      "type": "stdio",
      "command": "dart",
      "args": ["mcp-server"],
      "env": {}
    }
  }
}
```

**Location:** `~/.claude.json`

**Flutter SDK Path:** `/Users/austinpennyfeather/development/flutter`

### Verify It's Working

You should now be able to ask Claude:
- "What's in my pubspec.yaml?"
- "Show me the widget tree of LoginScreen"
- "Add the http package"
- "Trigger a hot reload"

### No Restart Needed

The MCP server is active for your current session!

---

## Features Unlocked

### 1. Widget Tree Introspection

Ask Claude to analyze your widget hierarchy:

```
"What's the widget tree structure of HomeScreen?"
"Why is this widget overflowing?"
"Show me the render tree for this layout"
```

### 2. Smart Package Management

Ask Claude to find and add packages:

```
"Find a package for image caching"
"Add the http package to pubspec.yaml"
"What's the latest version of flutter_bloc?"
```

### 3. Runtime Control

Ask Claude to manage the running app:

```
"Trigger a hot reload"
"Restart the app"
"Run the app in debug mode"
```

### 4. Deep Error Analysis

Share error messages for context-aware fixes:

```
"Fix this overflow error: [paste error]"
"Why is this setState being called after dispose?"
"Analyze this null safety error"
```

---

## Usage Tips

### Best Practices

✅ **DO:**
- Keep your Flutter app running while working with AI
- Share specific error messages from the console
- Ask about widget hierarchies when debugging layouts
- Let AI search pub.dev for packages instead of manual searching

❌ **DON'T:**
- Ask about Flutter internals that change frequently (AI might have outdated info)
- Rely solely on AI for performance profiling (use Flutter DevTools)
- Skip testing AI-generated code

### Example Workflows

**Adding a new feature:**
```
You: "I need to add image caching. Find a suitable package."
AI: [Searches pub.dev via MCP] "I recommend cached_network_image..."
You: "Add it to pubspec.yaml"
AI: [Uses MCP to add dependency] "Added cached_network_image: ^3.4.1"
You: "Hot reload the app"
AI: [Triggers hot reload via MCP] "Reloaded"
```

**Debugging layout issues:**
```
You: "This column is overflowing. Here's the error: [paste]"
AI: [Uses MCP to inspect widget tree] "The issue is in line 45..."
You: "Fix it"
AI: [Provides fix] "Wrap the Text widget with Flexible"
```

---

## Template Integration

This template is **MCP-ready** with these configurations:

### 1. CLAUDE.md Context Document

The `CLAUDE.md` file provides persistent context for AI assistants, optimized for MCP-enhanced workflows.

### 2. Project Structure

The architecture (data by type, UI by feature) makes it easy for MCP to understand code organization.

### 3. Documentation

Comprehensive docs (`ARCHITECTURE.md`, `.instructions.md`) work with MCP to provide rich context.

---

## Troubleshooting

### MCP server not connecting

**Check Dart version (must be 3.9+):**
```bash
dart --version  # Should show 3.9 or later
```

**Verify MCP server command exists:**
```bash
dart mcp-server --help
```

**Check Claude configuration:**
```bash
cat ~/.claude.json | grep -A 5 '"dart"'
```

**Verify Flutter in PATH:**
```bash
flutter doctor -v
```

**If issues persist:**
```bash
# Re-add the MCP server
claude mcp add --transport stdio dart -- dart mcp-server
```

### AI not recognizing Flutter context

1. Ensure app is running: `flutter run`
2. Verify MCP server in config: Check `.claude/config.json`
3. Restart AI assistant
4. Check MCP logs for errors

### Hot reload not working via MCP

- Confirm app is running in debug mode
- Try manual hot reload: `r` in terminal
- Check for compilation errors first

---

## Advanced Configuration

### Available MCP Server Options

You can pass additional flags to the MCP server:

```bash
# Force roots fallback (for clients that claim root support but don't implement it)
claude mcp add --transport stdio dart -- dart mcp-server --force-roots-fallback
```

### Check Current Configuration

```bash
# View your Claude MCP configuration
cat ~/.claude.json

# List all configured MCP servers
claude mcp list
```

### Update Configuration

```bash
# Remove and re-add if needed
claude mcp remove dart
claude mcp add --transport stdio dart -- dart mcp-server
```

---

## Resources

- 📖 [Official Dart MCP Documentation](https://dart.dev/tools/mcp-server)
- 🔧 [MCP Server GitHub Repository](https://github.com/dart-lang/ai/tree/main/pkgs/dart_mcp_server)
- 🌐 [MCP Specification](https://modelcontextprotocol.io/)
- 📚 [Flutter AI Documentation](https://docs.flutter.dev/ai/create-with-ai)

---

## Future Enhancements

The MCP server is actively developed. Upcoming features may include:

- 🎨 Design system introspection
- 📊 Performance profiling integration
- 🧪 Test generation assistance
- 🔒 Security vulnerability scanning
- 📱 Device management and deployment

Stay updated by watching the [GitHub repository](https://github.com/dart-lang/ai).

---

**Last Updated:** 2026-01-21
**MCP Server Version:** Latest
