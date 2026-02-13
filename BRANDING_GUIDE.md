# App Branding Guide

Complete guide to customizing your app's visual identity with icons and splash screens.

---

## 🎨 Overview

This template includes two packages for easy app branding:

- **flutter_launcher_icons** (v0.14.4) - Generate app icons for all platforms
- **flutter_native_splash** (v2.4.7) - Generate splash screens for all platforms

Both are configured and ready to use. Just add your assets and run the generation commands.

---

## 📱 App Icons

### Quick Start

```bash
# 1. Add your icon (1024x1024 PNG recommended)
cp my_icon.png assets/icon/icon.png

# 2. Generate platform icons
dart run flutter_launcher_icons

# 3. Verify on device
flutter run
```

### Icon Requirements

| Platform | Size | Format | Notes |
|----------|------|--------|-------|
| **iOS** | 1024x1024 | PNG | Transparent background OK |
| **Android** | 1024x1024 | PNG | Will be scaled to all sizes |
| **Adaptive (Android)** | 1024x1024 | PNG | Separate foreground/background |

### Design Guidelines

#### Standard Icon (Android & iOS)
- **Size:** 1024x1024 pixels
- **Format:** PNG with transparency
- **Design:** Keep important elements in center 80% of canvas
- **Colors:** Use your brand colors
- **Simplicity:** Simple, recognizable design works best

#### Adaptive Icon (Android Only)
- **Foreground:** 1024x1024 PNG (centered logo/icon)
- **Background:** Solid color or 1024x1024 PNG
- **Safe area:** Keep content in center 66% (684x684)
- **Why:** Android can mask icons into different shapes

### Configuration

Edit `pubspec.yaml` under `flutter_launcher_icons:`:

```yaml
flutter_launcher_icons:
  android: true                              # Enable Android
  ios: true                                  # Enable iOS
  image_path: "assets/icon/icon.png"         # Path to icon

  # Optional: Adaptive icon for Android
  adaptive_icon_background: "#ffffff"        # Solid color
  # OR
  adaptive_icon_background: "assets/icon/background.png"  # Image
  adaptive_icon_foreground: "assets/icon/foreground.png"

  # Optional: Minimum SDK
  min_sdk_android: 21

  # Optional: Remove alpha channel (if needed)
  remove_alpha_ios: false
```

### Advanced Options

**Platform-specific icons:**
```yaml
flutter_launcher_icons:
  image_path_android: "assets/icon/android_icon.png"
  image_path_ios: "assets/icon/ios_icon.png"
```

**Disable specific platforms:**
```yaml
flutter_launcher_icons:
  android: false  # Skip Android
  ios: true       # Generate iOS only
```

### Troubleshooting

**Icons not updating?**
```bash
# Clean build and regenerate
flutter clean
dart run flutter_launcher_icons
flutter pub get
flutter run
```

**iOS icon has white background?**
- Ensure your PNG has transparency
- Check `remove_alpha_ios: false` in config

**Android adaptive icon looks wrong?**
- Test on different devices/launchers
- Keep content in center safe area (66%)
- Use higher contrast between foreground/background

---

## 🌊 Splash Screens

### Quick Start

```bash
# 1. Add your splash image (1152x1152 PNG recommended)
cp my_splash.png assets/splash/splash.png

# 2. Generate platform splash screens
dart run flutter_native_splash:create

# 3. Verify on device
flutter run
```

### Splash Image Requirements

| Aspect | Recommendation | Notes |
|--------|----------------|-------|
| **Size** | 1152x1152 | Safe area on all devices |
| **Safe zone** | 512x512 center | Important content here |
| **Format** | PNG | Transparency supported |
| **Design** | Simple logo/brand | Fast loading |

### Design Guidelines

#### Image Size & Safe Area

```
┌─────────────────────────────┐
│                             │ 1152x1152 total
│     ┌───────────────┐       │
│     │               │       │ 512x512 safe area
│     │   LOGO HERE   │       │ (keep important content)
│     │               │       │
│     └───────────────┘       │
│                             │
└─────────────────────────────┘
```

**Why 1152x1152?**
- Covers all screen sizes and aspect ratios
- Content in center 512x512 is always visible
- Edges may be cropped on some devices

#### Color Scheme
- Use your brand's primary color for background
- Consider light and dark mode variants
- Keep it simple - users see it briefly

#### Best Practices
- ✅ Simple logo or brand mark
- ✅ Fast loading (< 100KB PNG)
- ✅ Match your app's initial screen
- ✅ Test on multiple screen sizes
- ❌ Don't use photos or complex graphics
- ❌ Don't include text (may be cropped)
- ❌ Don't use large file sizes

### Configuration

Edit `pubspec.yaml` under `flutter_native_splash:`:

```yaml
flutter_native_splash:
  # Background color (hex)
  color: "#ffffff"

  # Splash image
  image: "assets/splash/splash.png"

  # Optional: Dark mode support
  color_dark: "#000000"
  image_dark: "assets/splash/splash_dark.png"

  # Optional: Branding mode (keeps splash visible longer)
  android_12:
    image: "assets/splash/splash_android12.png"
    color: "#ffffff"
    icon_background_color: "#ffffff"

  # Optional: Web support
  web: true

  # Optional: Image positioning
  android_gravity: center
  ios_content_mode: center

  # Optional: Fullscreen mode
  fullscreen: true

  # Optional: Show splash while initializing
  android_disable_fullscreen: false
```

### Platform-Specific Notes

#### Android
- Supports light/dark mode variants
- Android 12+ has special branding mode
- Splash stays visible while app initializes

#### iOS
- Uses LaunchScreen.storyboard
- Automatically adapts to device orientation
- Can use different images for iPhone/iPad

#### Web
- Updates index.html
- Shows splash while Flutter loads
- Customize with `web_image_mode` option

### Dark Mode Support

```yaml
flutter_native_splash:
  # Light mode
  color: "#ffffff"
  image: "assets/splash/splash.png"

  # Dark mode
  color_dark: "#000000"
  image_dark: "assets/splash/splash_dark.png"
```

### Android 12+ Branding

Android 12+ introduced a new splash screen system with branding:

```yaml
flutter_native_splash:
  color: "#ffffff"
  image: "assets/splash/splash.png"

  android_12:
    image: "assets/splash/splash_android12.png"  # 1152x1152
    color: "#ffffff"
    icon_background_color: "#ffffff"              # Behind icon
    branding: "assets/splash/branding.png"        # Optional bottom branding (max 200x80)
```

**Android 12+ Design:**
- Icon appears in center with animation
- Optional branding at bottom
- System provides animation and timing

### Troubleshooting

**Splash screen not updating?**
```bash
# Regenerate splash screens
dart run flutter_native_splash:create

# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

**Splash doesn't match preview?**
- Test on actual devices (emulators may differ)
- Check safe area - content may be cropped
- Verify image paths in pubspec.yaml

**Android 12+ splash looks wrong?**
- Ensure image is 1152x1152
- Use simple centered icon
- Test on Android 12+ device/emulator

**Dark mode splash not showing?**
- Verify device is in dark mode
- Check `color_dark` and `image_dark` paths
- Regenerate with `dart run flutter_native_splash:create`

---

## 🚀 Complete Branding Workflow

### 1. Prepare Assets

**App Icon:**
- Design 1024x1024 icon with transparency
- Save as `icon.png`
- (Optional) Create adaptive icon assets

**Splash Screen:**
- Design 1152x1152 splash with centered logo (512x512 safe area)
- Save as `splash.png`
- (Optional) Create dark mode variant

### 2. Add to Template

```bash
# Copy your prepared assets
cp icon.png assets/icon/icon.png
cp splash.png assets/splash/splash.png

# Optional: Dark mode splash
cp splash_dark.png assets/splash/splash_dark.png
```

### 3. Configure (Optional)

Edit `pubspec.yaml` to customize colors, adaptive icons, or platform-specific settings.

### 4. Generate

```bash
# Generate both at once
dart run flutter_launcher_icons && dart run flutter_native_splash:create
```

### 5. Test

```bash
# Test on device
flutter run

# Check:
# - App icon in launcher/home screen
# - Splash screen when launching app
# - Both light and dark modes (if configured)
```

### 6. Verify All Platforms

- **Android:** Check app drawer and home screen
- **iOS:** Check home screen and app switcher
- **Adaptive (Android):** Test on different launchers
- **Splash:** Launch app multiple times

---

## 🎨 Design Tools & Resources

### Design Tools

- **Figma** - Free, web-based design tool
- **Sketch** - Mac design tool
- **Adobe Illustrator** - Professional vector design
- **Canva** - Simple online tool with templates

### Icon Resources

- [Material Icons](https://fonts.google.com/icons) - Free Google icons
- [Flaticon](https://www.flaticon.com) - Free and premium icons
- [The Noun Project](https://thenounproject.com) - Icons and symbols

### Splash Screen Resources

- [Material Design - Splash Screens](https://m3.material.io/styles/motion/transitions/applying-transitions)
- [Human Interface Guidelines - Launch Screens](https://developer.apple.com/design/human-interface-guidelines/ios/visual-design/launch-screen/)

### Color Tools

- [Coolors](https://coolors.co) - Color palette generator
- [Adobe Color](https://color.adobe.com) - Color scheme tool
- [Material Color Tool](https://material.io/resources/color) - Material Design colors

---

## 📚 Package Documentation

- [flutter_launcher_icons on pub.dev](https://pub.dev/packages/flutter_launcher_icons)
- [flutter_native_splash on pub.dev](https://pub.dev/packages/flutter_native_splash)
- [Official Flutter Icon Guidelines](https://docs.flutter.dev/deployment/android#launcher-icons)
- [iOS App Icon Guidelines](https://developer.apple.com/design/human-interface-guidelines/app-icons)

---

## ✅ Branding Checklist

Use this checklist when branding a new project:

- [ ] Design app icon (1024x1024)
- [ ] Create adaptive icon assets (if needed)
- [ ] Design splash screen (1152x1152, content in center 512x512)
- [ ] Create dark mode variants (optional)
- [ ] Add assets to template directories
- [ ] Configure `pubspec.yaml` (if needed)
- [ ] Run `dart run flutter_launcher_icons`
- [ ] Run `dart run flutter_native_splash:create`
- [ ] Test on Android device/emulator
- [ ] Test on iOS device/simulator
- [ ] Verify light mode appearance
- [ ] Verify dark mode appearance (if configured)
- [ ] Test on multiple screen sizes
- [ ] Check adaptive icons on different launchers (Android)
- [ ] Verify Android 12+ splash (if configured)
- [ ] Document brand colors in theme file

---

## 💡 Pro Tips

1. **Reuse your theme colors** - Use your app's primary color for splash background
2. **Keep it simple** - Complex splashes take longer to load
3. **Test early** - Generate and test icons/splash early in development
4. **Version control** - Commit generated files to git
5. **Automate** - Add generation commands to your CI/CD pipeline
6. **Brand consistency** - Match splash screen to your first app screen
7. **Accessibility** - Ensure sufficient contrast for readability
8. **File size** - Optimize PNGs to reduce app size

---

**Last Updated:** 2026-01-22
**flutter_launcher_icons:** v0.14.4
**flutter_native_splash:** v2.4.7
