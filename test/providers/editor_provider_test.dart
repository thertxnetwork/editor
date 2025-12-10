import 'package:flutter_test/flutter_test.dart';
import 'package:code_editor/providers/editor_provider.dart';
import 'package:code_editor/models/editor_tab.dart';
import 'package:code_editor/models/file_item.dart';

void main() {
  group('EditorProvider', () {
    late EditorProvider provider;

    setUp(() {
      provider = EditorProvider();
    });

    test('should start with no tabs', () {
      expect(provider.tabs, isEmpty);
      expect(provider.activeTab, isNull);
      expect(provider.activeTabIndex, -1);
      expect(provider.hasUnsavedChanges, false);
    });

    test('should close tab correctly', () async {
      // First add a tab manually by simulating the openFile behavior
      const file = FileItem(
        name: 'test.dart',
        path: '/project/test.dart',
        isDirectory: false,
      );

      // Mock file reader
      Future<String> mockReader(String path) async => 'content';

      await provider.openFile(file, mockReader);
      expect(provider.tabs.length, 1);

      provider.closeTab(0);
      expect(provider.tabs, isEmpty);
      expect(provider.activeTab, isNull);
    });

    test('should handle close all tabs', () async {
      const file1 = FileItem(
        name: 'file1.dart',
        path: '/project/file1.dart',
        isDirectory: false,
      );
      const file2 = FileItem(
        name: 'file2.dart',
        path: '/project/file2.dart',
        isDirectory: false,
      );

      Future<String> mockReader(String path) async => 'content';

      await provider.openFile(file1, mockReader);
      await provider.openFile(file2, mockReader);
      expect(provider.tabs.length, 2);

      provider.closeAllTabs();
      expect(provider.tabs, isEmpty);
    });

    test('should switch to existing tab when opening same file', () async {
      const file = FileItem(
        name: 'test.dart',
        path: '/project/test.dart',
        isDirectory: false,
      );

      Future<String> mockReader(String path) async => 'content';

      await provider.openFile(file, mockReader);
      expect(provider.tabs.length, 1);

      await provider.openFile(file, mockReader);
      expect(provider.tabs.length, 1); // Still 1 tab
    });

    test('should find tab by path', () async {
      const file = FileItem(
        name: 'test.dart',
        path: '/project/test.dart',
        isDirectory: false,
      );

      Future<String> mockReader(String path) async => 'content';

      await provider.openFile(file, mockReader);

      expect(provider.findTabByPath('/project/test.dart'), 0);
      expect(provider.findTabByPath('/project/other.dart'), -1);
    });

    test('should set active tab correctly', () async {
      const file1 = FileItem(
        name: 'file1.dart',
        path: '/project/file1.dart',
        isDirectory: false,
      );
      const file2 = FileItem(
        name: 'file2.dart',
        path: '/project/file2.dart',
        isDirectory: false,
      );

      Future<String> mockReader(String path) async => 'content';

      await provider.openFile(file1, mockReader);
      await provider.openFile(file2, mockReader);

      provider.setActiveTab(0);
      expect(provider.activeTabIndex, 0);
      expect(provider.activeTab?.fileName, 'file1.dart');
    });

    test('should ignore invalid tab index', () async {
      const file = FileItem(
        name: 'test.dart',
        path: '/project/test.dart',
        isDirectory: false,
      );

      Future<String> mockReader(String path) async => 'content';

      await provider.openFile(file, mockReader);

      provider.setActiveTab(10); // Invalid index
      expect(provider.activeTabIndex, 0); // Should remain unchanged
    });

    test('closeOtherTabs should keep only specified tab', () async {
      const file1 = FileItem(
        name: 'file1.dart',
        path: '/project/file1.dart',
        isDirectory: false,
      );
      const file2 = FileItem(
        name: 'file2.dart',
        path: '/project/file2.dart',
        isDirectory: false,
      );
      const file3 = FileItem(
        name: 'file3.dart',
        path: '/project/file3.dart',
        isDirectory: false,
      );

      Future<String> mockReader(String path) async => 'content';

      await provider.openFile(file1, mockReader);
      await provider.openFile(file2, mockReader);
      await provider.openFile(file3, mockReader);
      expect(provider.tabs.length, 3);

      provider.closeOtherTabs(1);
      expect(provider.tabs.length, 1);
      expect(provider.tabs[0].fileName, 'file2.dart');
    });
  });
}
