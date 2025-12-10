import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart';

import '../models/file_item.dart';

/// Provider for file system operations
class FileProvider extends ChangeNotifier {
  String? _currentDirectory;
  List<FileItem> _files = [];
  List<String> _expandedDirs = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  String? get currentDirectory => _currentDirectory;
  List<FileItem> get files => _files;
  List<String> get expandedDirs => _expandedDirs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Open a directory using file picker
  Future<void> openDirectory() async {
    try {
      final result = await FilePicker.platform.getDirectoryPath();
      if (result != null) {
        await loadDirectory(result);
      }
    } catch (e) {
      _error = 'Failed to open directory: $e';
      notifyListeners();
    }
  }

  /// Load a specific directory
  Future<void> loadDirectory(String dirPath) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final dir = Directory(dirPath);
      if (!await dir.exists()) {
        throw Exception('Directory does not exist');
      }

      _currentDirectory = dirPath;
      _files = await _loadDirectoryContents(dir);
      _expandedDirs = [dirPath];
    } catch (e) {
      _error = 'Failed to load directory: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load contents of a directory
  Future<List<FileItem>> _loadDirectoryContents(Directory dir) async {
    final items = <FileItem>[];

    try {
      await for (final entity in dir.list(followLinks: false)) {
        final name = path.basename(entity.path);

        // Skip hidden files if setting is disabled
        if (name.startsWith('.')) continue;

        final stat = await entity.stat();
        final isDir = entity is Directory;

        items.add(FileItem(
          name: name,
          path: entity.path,
          isDirectory: isDir,
          modifiedTime: stat.modified,
          size: isDir ? null : stat.size,
        ));
      }

      // Sort: directories first, then alphabetically
      items.sort((a, b) {
        if (a.isDirectory && !b.isDirectory) return -1;
        if (!a.isDirectory && b.isDirectory) return 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
    } catch (e) {
      debugPrint('Error loading directory contents: $e');
    }

    return items;
  }

  /// Toggle directory expansion
  Future<void> toggleDirectory(String dirPath) async {
    if (_expandedDirs.contains(dirPath)) {
      _expandedDirs.remove(dirPath);
    } else {
      _expandedDirs.add(dirPath);
      await _loadSubdirectory(dirPath);
    }
    notifyListeners();
  }

  /// Load subdirectory contents
  Future<void> _loadSubdirectory(String dirPath) async {
    final dir = Directory(dirPath);
    final children = await _loadDirectoryContents(dir);

    // Update the file tree
    _updateFileTree(_files, dirPath, children);
    notifyListeners();
  }

  /// Recursively update file tree with children
  void _updateFileTree(
      List<FileItem> items, String targetPath, List<FileItem> children) {
    for (var i = 0; i < items.length; i++) {
      if (items[i].path == targetPath) {
        items[i] = items[i].copyWith(children: children);
        return;
      }
      if (items[i].children != null) {
        _updateFileTree(items[i].children!, targetPath, children);
      }
    }
  }

  /// Read file content
  Future<String> readFile(String filePath) async {
    try {
      final file = File(filePath);
      return await file.readAsString();
    } catch (e) {
      throw Exception('Failed to read file: $e');
    }
  }

  /// Write file content
  Future<void> writeFile(String filePath, String content) async {
    try {
      final file = File(filePath);
      await file.writeAsString(content);
    } catch (e) {
      throw Exception('Failed to write file: $e');
    }
  }

  /// Create a new file
  Future<void> createFile(String dirPath, String fileName) async {
    try {
      final filePath = path.join(dirPath, fileName);
      final file = File(filePath);
      await file.create();
      await loadDirectory(_currentDirectory!);
    } catch (e) {
      throw Exception('Failed to create file: $e');
    }
  }

  /// Create a new directory
  Future<void> createDirectory(String parentPath, String dirName) async {
    try {
      final dirPath = path.join(parentPath, dirName);
      final dir = Directory(dirPath);
      await dir.create();
      await loadDirectory(_currentDirectory!);
    } catch (e) {
      throw Exception('Failed to create directory: $e');
    }
  }

  /// Delete a file or directory
  Future<void> delete(String itemPath) async {
    try {
      final entity = FileSystemEntity.typeSync(itemPath) ==
              FileSystemEntityType.directory
          ? Directory(itemPath)
          : File(itemPath);
      await entity.delete(recursive: true);
      await loadDirectory(_currentDirectory!);
    } catch (e) {
      throw Exception('Failed to delete: $e');
    }
  }

  /// Rename a file or directory
  Future<void> rename(String oldPath, String newName) async {
    try {
      final newPath = path.join(path.dirname(oldPath), newName);
      final entity = FileSystemEntity.typeSync(oldPath) ==
              FileSystemEntityType.directory
          ? Directory(oldPath)
          : File(oldPath);
      await entity.rename(newPath);
      await loadDirectory(_currentDirectory!);
    } catch (e) {
      throw Exception('Failed to rename: $e');
    }
  }

  /// Refresh current directory
  Future<void> refresh() async {
    if (_currentDirectory != null) {
      await loadDirectory(_currentDirectory!);
    }
  }

  /// Close the current project
  void closeProject() {
    _currentDirectory = null;
    _files = [];
    _expandedDirs = [];
    _error = null;
    notifyListeners();
  }

  /// Check if a path is expanded
  bool isExpanded(String dirPath) {
    return _expandedDirs.contains(dirPath);
  }
}
