import 'package:flutter_test/flutter_test.dart';
import 'package:code_editor/models/editor_tab.dart';

void main() {
  group('EditorTab', () {
    test('should create tab with required properties', () {
      const tab = EditorTab(
        id: '1',
        filePath: '/project/main.dart',
        fileName: 'main.dart',
        content: 'void main() {}',
        language: 'dart',
      );

      expect(tab.id, '1');
      expect(tab.filePath, '/project/main.dart');
      expect(tab.fileName, 'main.dart');
      expect(tab.content, 'void main() {}');
      expect(tab.language, 'dart');
      expect(tab.isModified, false);
      expect(tab.cursorPosition, 0);
      expect(tab.scrollPosition, 0);
    });

    test('copyWith should update specified fields', () {
      const original = EditorTab(
        id: '1',
        filePath: '/project/main.dart',
        fileName: 'main.dart',
        content: 'void main() {}',
        language: 'dart',
      );

      final modified = original.copyWith(
        content: 'void main() { print("Hello"); }',
        isModified: true,
      );

      expect(modified.content, 'void main() { print("Hello"); }');
      expect(modified.isModified, true);
      expect(modified.id, '1'); // Unchanged
      expect(modified.filePath, '/project/main.dart'); // Unchanged
    });

    test('copyWith should preserve original values when not specified', () {
      const original = EditorTab(
        id: '1',
        filePath: '/project/test.py',
        fileName: 'test.py',
        content: 'print("test")',
        language: 'python',
        isModified: true,
        cursorPosition: 10,
        scrollPosition: 100,
      );

      final updated = original.copyWith(cursorPosition: 20);

      expect(updated.cursorPosition, 20);
      expect(updated.isModified, true); // Preserved
      expect(updated.scrollPosition, 100); // Preserved
    });

    test('equality should be based on id, filePath, and isModified', () {
      const tab1 = EditorTab(
        id: '1',
        filePath: '/project/main.dart',
        fileName: 'main.dart',
        content: 'void main() {}',
        language: 'dart',
      );

      const tab2 = EditorTab(
        id: '1',
        filePath: '/project/main.dart',
        fileName: 'main.dart',
        content: 'different content',
        language: 'dart',
      );

      const tab3 = EditorTab(
        id: '2',
        filePath: '/project/other.dart',
        fileName: 'other.dart',
        content: 'void main() {}',
        language: 'dart',
      );

      // Same id, filePath, and isModified = equal
      expect(tab1, tab2);
      // Different id and filePath = not equal
      expect(tab1 == tab3, false);
    });
  });
}
