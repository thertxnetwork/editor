import 'package:flutter/foundation.dart';

import '../models/editor_tab.dart';
import '../models/file_item.dart';

/// Provider for editor state management
class EditorProvider extends ChangeNotifier {
  final List<EditorTab> _tabs = [];
  int _activeTabIndex = -1;
  bool _isLoading = false;

  // Getters
  List<EditorTab> get tabs => List.unmodifiable(_tabs);
  int get activeTabIndex => _activeTabIndex;
  EditorTab? get activeTab =>
      _activeTabIndex >= 0 && _activeTabIndex < _tabs.length
          ? _tabs[_activeTabIndex]
          : null;
  bool get isLoading => _isLoading;
  bool get hasUnsavedChanges => _tabs.any((tab) => tab.isModified);

  /// Open a file in a new tab or switch to existing tab
  Future<void> openFile(
    FileItem file,
    Future<String> Function(String) readFile,
  ) async {
    // Check if file is already open
    final existingIndex = _tabs.indexWhere((tab) => tab.filePath == file.path);
    if (existingIndex >= 0) {
      _activeTabIndex = existingIndex;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final content = await readFile(file.path);
      final tab = EditorTab(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        filePath: file.path,
        fileName: file.name,
        content: content,
        language: file.language,
      );

      _tabs.add(tab);
      _activeTabIndex = _tabs.length - 1;
    } catch (e) {
      debugPrint('Error opening file: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Close a tab
  void closeTab(int index) {
    if (index < 0 || index >= _tabs.length) return;

    _tabs.removeAt(index);

    // Adjust active tab index
    if (_tabs.isEmpty) {
      _activeTabIndex = -1;
    } else if (_activeTabIndex >= _tabs.length) {
      _activeTabIndex = _tabs.length - 1;
    } else if (index < _activeTabIndex) {
      _activeTabIndex--;
    }

    notifyListeners();
  }

  /// Close all tabs
  void closeAllTabs() {
    _tabs.clear();
    _activeTabIndex = -1;
    notifyListeners();
  }

  /// Close other tabs (keep only the specified one)
  void closeOtherTabs(int keepIndex) {
    if (keepIndex < 0 || keepIndex >= _tabs.length) return;

    final tabToKeep = _tabs[keepIndex];
    _tabs.clear();
    _tabs.add(tabToKeep);
    _activeTabIndex = 0;
    notifyListeners();
  }

  /// Set the active tab
  void setActiveTab(int index) {
    if (index >= 0 && index < _tabs.length) {
      _activeTabIndex = index;
      notifyListeners();
    }
  }

  /// Update the content of the active tab
  void updateContent(String content) {
    if (activeTab == null) return;

    final updatedTab = activeTab!.copyWith(
      content: content,
      isModified: content != activeTab!.content,
    );

    _tabs[_activeTabIndex] = updatedTab;
    notifyListeners();
  }

  /// Mark the active tab as saved
  void markAsSaved() {
    if (activeTab == null) return;

    final updatedTab = activeTab!.copyWith(isModified: false);
    _tabs[_activeTabIndex] = updatedTab;
    notifyListeners();
  }

  /// Update cursor position of active tab
  void updateCursorPosition(int position) {
    if (activeTab == null) return;

    final updatedTab = activeTab!.copyWith(cursorPosition: position);
    _tabs[_activeTabIndex] = updatedTab;
    // Don't notify listeners for cursor updates to avoid rebuilds
  }

  /// Update scroll position of active tab
  void updateScrollPosition(int position) {
    if (activeTab == null) return;

    final updatedTab = activeTab!.copyWith(scrollPosition: position);
    _tabs[_activeTabIndex] = updatedTab;
    // Don't notify listeners for scroll updates to avoid rebuilds
  }

  /// Reorder tabs
  void reorderTabs(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final tab = _tabs.removeAt(oldIndex);
    _tabs.insert(newIndex, tab);

    // Update active tab index if needed
    if (_activeTabIndex == oldIndex) {
      _activeTabIndex = newIndex;
    } else if (_activeTabIndex > oldIndex && _activeTabIndex <= newIndex) {
      _activeTabIndex--;
    } else if (_activeTabIndex < oldIndex && _activeTabIndex >= newIndex) {
      _activeTabIndex++;
    }

    notifyListeners();
  }

  /// Find a tab by file path
  int findTabByPath(String filePath) {
    return _tabs.indexWhere((tab) => tab.filePath == filePath);
  }

  /// Get unsaved tabs
  List<EditorTab> getUnsavedTabs() {
    return _tabs.where((tab) => tab.isModified).toList();
  }
}
