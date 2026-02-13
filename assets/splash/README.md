# Splash Screen Assets

Place your splash screen images here.

## Required File

- **splash.png** - Splash screen image (recommended: 1152x1152 for safe area)

## Optional Files

- **splash_dark.png** - Dark mode splash screen image
- **splash_android12.png** - Android 12+ specific splash image

## Generate Splash Screens

After adding your splash.png file, run:

```bash
dart run flutter_native_splash:create
```

This will generate platform-specific splash screens for:
- Android (drawable folders, styles.xml)
- iOS (LaunchScreen.storyboard)
- Web (index.html)

## Configuration

Edit `pubspec.yaml` under `flutter_native_splash:` to customize:
- Background color (light/dark modes)
- Image paths
- Fullscreen mode
- Android 12+ specific settings

## Design Guidelines

### Image Size
- **Recommended**: 1152x1152px (safe area on all devices)
- Image will be centered on the background color
- Keep important content in center 512x512px area

### Background Color
- Use your brand's primary color or white/black
- Should match your app's initial screen

### Best Practices
- Keep it simple (logo or brand mark)
- Fast loading (don't use large images)
- Match your app's design language
- Test on multiple screen sizes

## Resources

- [flutter_native_splash package](https://pub.dev/packages/flutter_native_splash)
- [Material Design Splash Screens](https://m3.material.io/styles/motion/transitions/applying-transitions)
- Images should be PNG format with transparency
