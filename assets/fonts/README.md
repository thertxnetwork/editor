# Font Assets

This directory should contain the following font files for the code editor:

## Required Fonts

- `JetBrainsMono-Regular.ttf`
- `JetBrainsMono-Bold.ttf`
- `JetBrainsMono-Light.ttf`

## How to Add Fonts

1. Download JetBrains Mono from: https://www.jetbrains.com/lp/mono/
2. Extract the TTF files
3. Copy the required font files to this directory
4. Run `flutter pub get` to update assets

## Alternative

If you don't want to bundle fonts, you can modify `pubspec.yaml` to use Google Fonts
which loads fonts at runtime:

```yaml
dependencies:
  google_fonts: ^6.1.0
```

Then update the code to use `GoogleFonts.jetBrainsMono()` instead of the local font.
