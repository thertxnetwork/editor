import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

import '../models/search_result.dart';

/// Provider for search functionality
class SearchProvider extends ChangeNotifier {
  String _query = '';
  String _replaceText = '';
  SearchOptions _options = const SearchOptions();
  List<SearchResult> _results = [];
  bool _isSearching = false;
  int _selectedResultIndex = -1;
  String? _error;

  // Getters
  String get query => _query;
  String get replaceText => _replaceText;
  SearchOptions get options => _options;
  List<SearchResult> get results => List.unmodifiable(_results);
  bool get isSearching => _isSearching;
  int get selectedResultIndex => _selectedResultIndex;
  SearchResult? get selectedResult =>
      _selectedResultIndex >= 0 && _selectedResultIndex < _results.length
          ? _results[_selectedResultIndex]
          : null;
  String? get error => _error;
  int get resultCount => _results.length;

  /// Set search query
  void setQuery(String query) {
    _query = query;
    notifyListeners();
  }

  /// Set replacement text
  void setReplaceText(String text) {
    _replaceText = text;
    notifyListeners();
  }

  /// Update search options
  void setOptions(SearchOptions options) {
    _options = options;
    notifyListeners();
  }

  /// Toggle case sensitivity
  void toggleCaseSensitive() {
    _options = _options.copyWith(caseSensitive: !_options.caseSensitive);
    notifyListeners();
  }

  /// Toggle whole word search
  void toggleWholeWord() {
    _options = _options.copyWith(wholeWord: !_options.wholeWord);
    notifyListeners();
  }

  /// Toggle regex search
  void toggleUseRegex() {
    _options = _options.copyWith(useRegex: !_options.useRegex);
    notifyListeners();
  }

  /// Search in a single file content
  List<SearchResult> searchInContent(
    String content,
    String filePath,
    String fileName,
  ) {
    if (_query.isEmpty) return [];

    final results = <SearchResult>[];
    final lines = content.split('\n');

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final matches = _findMatches(line);

      for (final match in matches) {
        results.add(SearchResult(
          filePath: filePath,
          fileName: fileName,
          lineNumber: i + 1,
          lineContent: line,
          matchStart: match.start,
          matchEnd: match.end,
        ));
      }
    }

    return results;
  }

  /// Search in project files
  Future<void> searchInProject(String projectPath) async {
    if (_query.isEmpty) {
      _results = [];
      notifyListeners();
      return;
    }

    _isSearching = true;
    _error = null;
    _results = [];
    notifyListeners();

    try {
      final dir = Directory(projectPath);
      await _searchDirectory(dir);
    } catch (e) {
      _error = 'Search failed: $e';
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  /// Recursively search through directory
  Future<void> _searchDirectory(Directory dir) async {
    try {
      await for (final entity in dir.list(followLinks: false)) {
        final name = path.basename(entity.path);

        // Skip excluded patterns
        if (_shouldExclude(name)) continue;

        if (entity is Directory) {
          await _searchDirectory(entity);
        } else if (entity is File) {
          if (_shouldInclude(name)) {
            await _searchFile(entity);
          }
        }
      }
    } catch (e) {
      debugPrint('Error searching directory: $e');
    }
  }

  /// Search in a single file
  Future<void> _searchFile(File file) async {
    try {
      final content = await file.readAsString();
      final fileName = path.basename(file.path);
      final fileResults = searchInContent(content, file.path, fileName);

      if (fileResults.isNotEmpty) {
        _results.addAll(fileResults);
        notifyListeners();
      }
    } catch (e) {
      // Skip files that can't be read as text
      debugPrint('Could not read file ${file.path}: $e');
    }
  }

  /// Find all matches in a line
  Iterable<Match> _findMatches(String line) {
    try {
      Pattern pattern;

      if (_options.useRegex) {
        pattern = RegExp(
          _query,
          caseSensitive: _options.caseSensitive,
        );
      } else {
        var searchPattern = RegExp.escape(_query);
        if (_options.wholeWord) {
          searchPattern = '\\b$searchPattern\\b';
        }
        pattern = RegExp(
          searchPattern,
          caseSensitive: _options.caseSensitive,
        );
      }

      return (pattern as RegExp).allMatches(line);
    } catch (e) {
      return [];
    }
  }

  /// Check if file should be excluded
  bool _shouldExclude(String name) {
    for (final pattern in _options.excludePatterns) {
      if (_matchesGlob(name, pattern)) return true;
    }
    return false;
  }

  /// Check if file should be included
  bool _shouldInclude(String name) {
    if (_options.includePatterns.isEmpty ||
        _options.includePatterns.contains('*')) {
      return true;
    }
    for (final pattern in _options.includePatterns) {
      if (_matchesGlob(name, pattern)) return true;
    }
    return false;
  }

  /// Simple glob matching
  bool _matchesGlob(String name, String pattern) {
    if (pattern == '*') return true;
    if (pattern.startsWith('*.')) {
      return name.endsWith(pattern.substring(1));
    }
    return name == pattern;
  }

  /// Select a result
  void selectResult(int index) {
    if (index >= 0 && index < _results.length) {
      _selectedResultIndex = index;
      notifyListeners();
    }
  }

  /// Select next result
  void selectNextResult() {
    if (_results.isEmpty) return;
    _selectedResultIndex = (_selectedResultIndex + 1) % _results.length;
    notifyListeners();
  }

  /// Select previous result
  void selectPreviousResult() {
    if (_results.isEmpty) return;
    _selectedResultIndex =
        (_selectedResultIndex - 1 + _results.length) % _results.length;
    notifyListeners();
  }

  /// Clear search results
  void clearResults() {
    _results = [];
    _selectedResultIndex = -1;
    _error = null;
    notifyListeners();
  }

  /// Clear all search state
  void clear() {
    _query = '';
    _replaceText = '';
    _results = [];
    _selectedResultIndex = -1;
    _error = null;
    _isSearching = false;
    notifyListeners();
  }
}
