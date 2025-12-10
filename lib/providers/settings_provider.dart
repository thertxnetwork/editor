import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for application settings
class SettingsProvider extends ChangeNotifier {
  // Theme settings
  ThemeMode _themeMode = ThemeMode.system;
  bool _useDynamicColor = true;

  // Editor settings
  String _fontFamily = 'JetBrainsMono';
  double _fontSize = 14.0;
  bool _showLineNumbers = true;
  bool _wordWrap = true;
  int _tabSize = 2;
  bool _insertSpaces = true;
  bool _autoIndent = true;
  bool _highlightCurrentLine = true;
  bool _showWhitespace = false;
  bool _autoCloseBrackets = true;
  bool _autoCloseTags = true;

  // File browser settings
  bool _showHiddenFiles = false;
  String? _lastOpenedDirectory;

  // LSP settings
  bool _enableLsp = true;
  bool _enableAutoComplete = true;
  bool _enableHover = true;
  bool _enableDiagnostics = true;

  // Getters
  ThemeMode get themeMode => _themeMode;
  bool get useDynamicColor => _useDynamicColor;
  String get fontFamily => _fontFamily;
  double get fontSize => _fontSize;
  bool get showLineNumbers => _showLineNumbers;
  bool get wordWrap => _wordWrap;
  int get tabSize => _tabSize;
  bool get insertSpaces => _insertSpaces;
  bool get autoIndent => _autoIndent;
  bool get highlightCurrentLine => _highlightCurrentLine;
  bool get showWhitespace => _showWhitespace;
  bool get autoCloseBrackets => _autoCloseBrackets;
  bool get autoCloseTags => _autoCloseTags;
  bool get showHiddenFiles => _showHiddenFiles;
  String? get lastOpenedDirectory => _lastOpenedDirectory;
  bool get enableLsp => _enableLsp;
  bool get enableAutoComplete => _enableAutoComplete;
  bool get enableHover => _enableHover;
  bool get enableDiagnostics => _enableDiagnostics;

  SettingsProvider() {
    _loadSettings();
  }

  /// Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    _themeMode = ThemeMode.values[prefs.getInt('themeMode') ?? 0];
    _useDynamicColor = prefs.getBool('useDynamicColor') ?? true;
    _fontFamily = prefs.getString('fontFamily') ?? 'JetBrainsMono';
    _fontSize = prefs.getDouble('fontSize') ?? 14.0;
    _showLineNumbers = prefs.getBool('showLineNumbers') ?? true;
    _wordWrap = prefs.getBool('wordWrap') ?? true;
    _tabSize = prefs.getInt('tabSize') ?? 2;
    _insertSpaces = prefs.getBool('insertSpaces') ?? true;
    _autoIndent = prefs.getBool('autoIndent') ?? true;
    _highlightCurrentLine = prefs.getBool('highlightCurrentLine') ?? true;
    _showWhitespace = prefs.getBool('showWhitespace') ?? false;
    _autoCloseBrackets = prefs.getBool('autoCloseBrackets') ?? true;
    _autoCloseTags = prefs.getBool('autoCloseTags') ?? true;
    _showHiddenFiles = prefs.getBool('showHiddenFiles') ?? false;
    _lastOpenedDirectory = prefs.getString('lastOpenedDirectory');
    _enableLsp = prefs.getBool('enableLsp') ?? true;
    _enableAutoComplete = prefs.getBool('enableAutoComplete') ?? true;
    _enableHover = prefs.getBool('enableHover') ?? true;
    _enableDiagnostics = prefs.getBool('enableDiagnostics') ?? true;

    notifyListeners();
  }

  /// Save a specific setting
  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();

    if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  // Setters with persistence
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _saveSetting('themeMode', mode.index);
    notifyListeners();
  }

  Future<void> setUseDynamicColor(bool value) async {
    _useDynamicColor = value;
    await _saveSetting('useDynamicColor', value);
    notifyListeners();
  }

  Future<void> setFontFamily(String family) async {
    _fontFamily = family;
    await _saveSetting('fontFamily', family);
    notifyListeners();
  }

  Future<void> setFontSize(double size) async {
    _fontSize = size.clamp(8.0, 32.0);
    await _saveSetting('fontSize', _fontSize);
    notifyListeners();
  }

  Future<void> setShowLineNumbers(bool value) async {
    _showLineNumbers = value;
    await _saveSetting('showLineNumbers', value);
    notifyListeners();
  }

  Future<void> setWordWrap(bool value) async {
    _wordWrap = value;
    await _saveSetting('wordWrap', value);
    notifyListeners();
  }

  Future<void> setTabSize(int size) async {
    _tabSize = size.clamp(1, 8);
    await _saveSetting('tabSize', _tabSize);
    notifyListeners();
  }

  Future<void> setInsertSpaces(bool value) async {
    _insertSpaces = value;
    await _saveSetting('insertSpaces', value);
    notifyListeners();
  }

  Future<void> setAutoIndent(bool value) async {
    _autoIndent = value;
    await _saveSetting('autoIndent', value);
    notifyListeners();
  }

  Future<void> setHighlightCurrentLine(bool value) async {
    _highlightCurrentLine = value;
    await _saveSetting('highlightCurrentLine', value);
    notifyListeners();
  }

  Future<void> setShowWhitespace(bool value) async {
    _showWhitespace = value;
    await _saveSetting('showWhitespace', value);
    notifyListeners();
  }

  Future<void> setAutoCloseBrackets(bool value) async {
    _autoCloseBrackets = value;
    await _saveSetting('autoCloseBrackets', value);
    notifyListeners();
  }

  Future<void> setAutoCloseTags(bool value) async {
    _autoCloseTags = value;
    await _saveSetting('autoCloseTags', value);
    notifyListeners();
  }

  Future<void> setShowHiddenFiles(bool value) async {
    _showHiddenFiles = value;
    await _saveSetting('showHiddenFiles', value);
    notifyListeners();
  }

  Future<void> setLastOpenedDirectory(String? path) async {
    _lastOpenedDirectory = path;
    if (path != null) {
      await _saveSetting('lastOpenedDirectory', path);
    }
    notifyListeners();
  }

  Future<void> setEnableLsp(bool value) async {
    _enableLsp = value;
    await _saveSetting('enableLsp', value);
    notifyListeners();
  }

  Future<void> setEnableAutoComplete(bool value) async {
    _enableAutoComplete = value;
    await _saveSetting('enableAutoComplete', value);
    notifyListeners();
  }

  Future<void> setEnableHover(bool value) async {
    _enableHover = value;
    await _saveSetting('enableHover', value);
    notifyListeners();
  }

  Future<void> setEnableDiagnostics(bool value) async {
    _enableDiagnostics = value;
    await _saveSetting('enableDiagnostics', value);
    notifyListeners();
  }

  /// Available font families for the editor
  static const List<String> availableFonts = [
    'JetBrainsMono',
    'FiraCode',
    'SourceCodePro',
    'RobotoMono',
    'Inconsolata',
    'UbuntuMono',
    'CascadiaCode',
    'Hack',
  ];
}
