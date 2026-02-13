# App Icon Assets

Place your app icon here.

## Required File

- **icon.png** - Main app icon (1024x1024 recommended)

## Optional Files

- **foreground.png** - Adaptive icon foreground (Android, 1024x1024)
- **background.png** - Adaptive icon background (Android, 1024x1024)

## Generate Icons

After adding your icon.png file, run:

```bash
dart run flutter_launcher_icons
```

This will generate platform-specific icons for:
- Android (mipmap folders)
- iOS (Assets.xcassets/AppIcon.appiconset)

## Configuration

Edit `pubspec.yaml` under `flutter_launcher_icons:` to customize:
- Icon paths
- Adaptive icon settings
- Platform-specific options

## Resources

- [flutter_launcher_icons package](https://pub.dev/packages/flutter_launcher_icons)
- Icon should be PNG format
- Transparent background recommended for iOS
- For Android adaptive icons, use separate foreground/background
