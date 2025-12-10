# Code Editor

A clean and minimal code editor for Android built with Flutter, featuring Material Design 3.

![Android](https://img.shields.io/badge/Android-5.0+-green.svg)
![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)
![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)

## Features

### 🎨 Modern UI/UX
- Material Design 3 (Material You)
- Dynamic color theming (Android 12+)
- Light and dark mode support
- Clean, minimal interface optimized for coding

### 📁 File System
- Open and browse project directories
- Create, rename, and delete files/folders
- File tree navigation with expandable directories
- Support for all text-based files

### ✏️ Code Editing
- Syntax highlighting for 50+ programming languages
- Line numbers
- Word wrap toggle
- Configurable tab size and spaces
- Auto-indent
- Current line highlighting
- Multiple file tabs with reordering

### 🔍 Search System
- Search in current file
- Search across project files
- Case-sensitive and whole word matching
- Regular expression support
- Find and replace

### ⚙️ Customization
- Multiple monospace fonts (JetBrains Mono, Fira Code, etc.)
- Adjustable font size
- Theme customization
- Editor preferences persistence

### 🔌 LSP Integration
- Language Server Protocol support
- Auto-completion
- Hover information
- Diagnostics (errors/warnings)
- Go to definition
- Supported languages: Dart, Python, JavaScript/TypeScript, Go, Rust, Java, Kotlin

### 📱 Performance
- Native Android optimizations
- Code shrinking with R8/ProGuard
- Split APKs by architecture
- Minimal memory footprint

## Screenshots

| Welcome Screen | File Browser | Code Editor |
|:---:|:---:|:---:|
| Material You theming | Project navigation | Syntax highlighting |

| Settings | Search | Tabs |
|:---:|:---:|:---:|
| Customization options | Find in files | Multiple files |

## Supported Languages

The editor provides syntax highlighting for:

| Language | Extensions |
|----------|------------|
| Dart | .dart |
| Python | .py |
| JavaScript | .js, .jsx |
| TypeScript | .ts, .tsx |
| Java | .java |
| Kotlin | .kt, .kts |
| C/C++ | .c, .cpp, .h, .hpp |
| C# | .cs |
| Go | .go |
| Rust | .rs |
| Ruby | .rb |
| PHP | .php |
| Swift | .swift |
| HTML | .html, .htm |
| CSS | .css, .scss, .sass |
| JSON | .json |
| YAML | .yaml, .yml |
| XML | .xml |
| Markdown | .md |
| SQL | .sql |
| Shell | .sh, .bash |
| And many more... |

## Building

### Requirements

- Flutter SDK 3.0+
- Android SDK (API 21+)
- JDK 17

### Quick Start

```bash
# Clone the repository
git clone https://github.com/thertxnetwork/editor.git
cd editor

# Get dependencies
flutter pub get

# Build debug APK
flutter build apk --debug

# Build release APK (optimized)
flutter build apk --release --split-per-abi
```

### Detailed Build Instructions

See [docs/BUILDING.md](docs/BUILDING.md) for comprehensive build instructions including:
- Development environment setup
- APK signing configuration
- Size optimization techniques
- CI/CD integration

## Project Structure

```
lib/
├── main.dart                 # Application entry point
├── models/                   # Data models
│   ├── editor_tab.dart      # Editor tab model
│   ├── file_item.dart       # File system item
│   ├── lsp_models.dart      # LSP protocol models
│   └── search_result.dart   # Search result model
├── providers/               # State management
│   ├── editor_provider.dart # Editor state
│   ├── file_provider.dart   # File operations
│   ├── search_provider.dart # Search functionality
│   └── settings_provider.dart # App settings
├── screens/                 # Main screens
│   ├── home_screen.dart     # Main editor screen
│   └── settings_screen.dart # Settings page
├── services/                # Business logic
│   ├── lsp_service.dart     # LSP integration
│   └── syntax_highlight_service.dart
├── utils/                   # Utilities
│   └── theme.dart           # Material 3 theming
└── widgets/                 # Reusable widgets
    ├── code_editor.dart     # Code editor widget
    ├── editor_tabs.dart     # Tab bar
    ├── file_tree.dart       # File browser
    └── search_panel.dart    # Search interface
```

## Configuration

### Editor Settings

All settings are automatically persisted using SharedPreferences:

| Setting | Default | Description |
|---------|---------|-------------|
| Font Family | JetBrains Mono | Editor font |
| Font Size | 14 | Text size in pixels |
| Tab Size | 2 | Spaces per tab |
| Insert Spaces | true | Use spaces instead of tabs |
| Word Wrap | true | Wrap long lines |
| Line Numbers | true | Show line numbers |
| Auto Indent | true | Auto-indent new lines |
| Highlight Current Line | true | Highlight active line |
| Show Whitespace | false | Render spaces/tabs |
| Auto Close Brackets | true | Auto-insert closing brackets |

### LSP Configuration

The app automatically detects and connects to language servers when available:

- **Dart**: `dart language-server`
- **TypeScript/JavaScript**: `typescript-language-server`
- **Python**: `pylsp`
- **Go**: `gopls`
- **Rust**: `rust-analyzer`
- **Java**: `jdtls`
- **Kotlin**: `kotlin-language-server`

## Contributing

Contributions are welcome! Please read our contributing guidelines before submitting pull requests.

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Flutter](https://flutter.dev) - UI framework
- [Material Design 3](https://m3.material.io) - Design system
- [highlight.js](https://highlightjs.org) - Syntax highlighting

## Roadmap

- [ ] Git integration
- [ ] Terminal emulator
- [ ] Plugin system
- [ ] Cloud sync
- [ ] Collaborative editing
- [ ] Custom themes
- [ ] Keyboard shortcuts
- [ ] Split view editing
