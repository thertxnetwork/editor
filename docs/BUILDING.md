# Building the Code Editor APK

This guide provides comprehensive instructions for building the Code Editor app for Android.

## Prerequisites

### 1. Install Flutter SDK

1. Download Flutter from [flutter.dev](https://flutter.dev/docs/get-started/install)
2. Extract to a suitable location (e.g., `~/flutter`)
3. Add Flutter to your PATH:

```bash
export PATH="$PATH:$HOME/flutter/bin"
```

4. Run flutter doctor to verify installation:

```bash
flutter doctor
```

### 2. Install Android SDK

You can either:
- Install [Android Studio](https://developer.android.com/studio) (recommended)
- Use command-line tools only:

```bash
# Download command-line tools
mkdir -p ~/Android/sdk/cmdline-tools
cd ~/Android/sdk/cmdline-tools
wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip
unzip commandlinetools-linux-9477386_latest.zip
mv cmdline-tools latest

# Set environment variables
export ANDROID_HOME=$HOME/Android/sdk
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools

# Install required SDK components
sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"
sdkmanager --licenses
```

### 3. Install Java Development Kit (JDK)

Install JDK 17 (required for Android Gradle Plugin 8.x):

```bash
# Ubuntu/Debian
sudo apt install openjdk-17-jdk

# macOS (using Homebrew)
brew install openjdk@17

# Verify installation
java -version
```

## Building the APK

### Quick Build (Debug)

For development and testing:

```bash
cd /path/to/editor

# Get dependencies
flutter pub get

# Build debug APK
flutter build apk --debug
```

Output: `build/app/outputs/flutter-apk/app-debug.apk`

### Release Build

For production release:

```bash
# Build release APK (universal)
flutter build apk --release

# Build release APK with optimizations
flutter build apk --release --shrink
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### Split APKs (Recommended for smaller file size)

Build separate APKs for different CPU architectures:

```bash
flutter build apk --release --split-per-abi
```

Output files:
- `app-armeabi-v7a-release.apk` - ARM 32-bit (~15-20MB smaller)
- `app-arm64-v8a-release.apk` - ARM 64-bit (most modern devices)
- `app-x86_64-release.apk` - Intel/AMD 64-bit (emulators, ChromeOS)

### App Bundle (For Play Store)

Build an Android App Bundle for Google Play Store:

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

The Play Store will automatically generate optimized APKs for each device.

## Optimization Options

### Minimize APK Size

1. **Use split APKs:**
   ```bash
   flutter build apk --release --split-per-abi
   ```

2. **Enable tree shaking:**
   Already enabled by default in release builds.

3. **Use deferred components:**
   ```yaml
   # In pubspec.yaml
   deferred-components:
     - name: advanced_features
   ```

4. **Analyze APK size:**
   ```bash
   flutter build apk --analyze-size
   ```

### Performance Optimization

1. **Enable AOT compilation (default in release):**
   ```bash
   flutter build apk --release
   ```

2. **Profile build for performance testing:**
   ```bash
   flutter build apk --profile
   ```

## Signing the APK

### Generate a Keystore

```bash
keytool -genkey -v -keystore ~/my-release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias my-key-alias
```

### Configure Signing

1. Create `android/key.properties`:
   ```properties
   storePassword=<your-store-password>
   keyPassword=<your-key-password>
   keyAlias=my-key-alias
   storeFile=/path/to/my-release-key.jks
   ```

2. Update `android/app/build.gradle`:
   ```groovy
   def keystoreProperties = new Properties()
   def keystorePropertiesFile = rootProject.file('key.properties')
   if (keystorePropertiesFile.exists()) {
       keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
   }

   android {
       signingConfigs {
           release {
               keyAlias keystoreProperties['keyAlias']
               keyPassword keystoreProperties['keyPassword']
               storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
               storePassword keystoreProperties['storePassword']
           }
       }
       buildTypes {
           release {
               signingConfig signingConfigs.release
           }
       }
   }
   ```

3. Add to `.gitignore`:
   ```
   android/key.properties
   *.jks
   ```

## Troubleshooting

### Common Issues

1. **"Flutter SDK not found"**
   - Ensure Flutter is in your PATH
   - Run `flutter doctor` to verify

2. **"Android SDK not found"**
   - Set ANDROID_HOME environment variable
   - Accept SDK licenses: `flutter doctor --android-licenses`

3. **Gradle build fails**
   ```bash
   cd android
   ./gradlew clean
   cd ..
   flutter clean
   flutter pub get
   flutter build apk
   ```

4. **Out of memory during build**
   - Edit `android/gradle.properties`:
     ```properties
     org.gradle.jvmargs=-Xmx4G
     ```

5. **Minimum SDK version issues**
   - The app requires Android 5.0 (API 21) or higher
   - Update `minSdk` in `android/app/build.gradle` if needed

### Verify APK

```bash
# Check APK contents
unzip -l build/app/outputs/flutter-apk/app-release.apk

# Verify signature
apksigner verify --print-certs build/app/outputs/flutter-apk/app-release.apk
```

## Installing on Device

### Via ADB

```bash
# Enable USB debugging on your device
# Connect device via USB

# Install APK
adb install build/app/outputs/flutter-apk/app-release.apk

# Or install split APK for your architecture
adb install build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

### Direct Installation

1. Transfer the APK to your device
2. Enable "Install from unknown sources" in Settings > Security
3. Open the APK file and follow installation prompts

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Build APK

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup Java
      uses: actions/setup-java@v4
      with:
        distribution: 'zulu'
        java-version: '17'
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.24.5'
        channel: 'stable'
    
    - name: Get dependencies
      run: flutter pub get
    
    - name: Build APK
      run: flutter build apk --release --split-per-abi
    
    - name: Upload APK
      uses: actions/upload-artifact@v4
      with:
        name: release-apk
        path: build/app/outputs/flutter-apk/*.apk
```

## Additional Resources

- [Flutter Android deployment](https://docs.flutter.dev/deployment/android)
- [Android App Bundle](https://developer.android.com/guide/app-bundle)
- [ProGuard configuration](https://www.guardsquare.com/manual/configuration/usage)
- [APK size analysis](https://docs.flutter.dev/perf/app-size)
