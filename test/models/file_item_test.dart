import 'package:flutter_test/flutter_test.dart';
import 'package:code_editor/models/file_item.dart';

void main() {
  group('FileItem', () {
    test('should identify directory correctly', () {
      const dirItem = FileItem(
        name: 'src',
        path: '/project/src',
        isDirectory: true,
      );

      expect(dirItem.isDirectory, true);
      expect(dirItem.extension, '');
      expect(dirItem.isCodeFile, false);
    });

    test('should extract extension from file name', () {
      const dartFile = FileItem(
        name: 'main.dart',
        path: '/project/lib/main.dart',
        isDirectory: false,
      );

      expect(dartFile.extension, 'dart');
      expect(dartFile.language, 'dart');
      expect(dartFile.isCodeFile, true);
    });

    test('should detect various code file types', () {
      final testCases = [
        ('test.py', 'python'),
        ('app.js', 'javascript'),
        ('index.ts', 'typescript'),
        ('Main.java', 'java'),
        ('app.kt', 'kotlin'),
        ('main.go', 'go'),
        ('lib.rs', 'rust'),
        ('style.css', 'css'),
        ('page.html', 'html'),
        ('config.json', 'json'),
        ('deploy.yaml', 'yaml'),
        ('readme.md', 'markdown'),
      ];

      for (final (fileName, expectedLanguage) in testCases) {
        final file = FileItem(
          name: fileName,
          path: '/project/$fileName',
          isDirectory: false,
        );

        expect(file.language, expectedLanguage,
            reason: '$fileName should be detected as $expectedLanguage');
        expect(file.isCodeFile, true,
            reason: '$fileName should be a code file');
      }
    });

    test('should handle files without extension', () {
      const file = FileItem(
        name: 'Makefile',
        path: '/project/Makefile',
        isDirectory: false,
      );

      expect(file.extension, '');
      expect(file.language, 'plaintext');
    });

    test('copyWith should create new instance with updated values', () {
      const original = FileItem(
        name: 'old.dart',
        path: '/project/old.dart',
        isDirectory: false,
      );

      final updated = original.copyWith(
        name: 'new.dart',
        path: '/project/new.dart',
      );

      expect(updated.name, 'new.dart');
      expect(updated.path, '/project/new.dart');
      expect(updated.isDirectory, false);
      expect(original.name, 'old.dart'); // Original unchanged
    });

    test('equality should work correctly', () {
      const file1 = FileItem(
        name: 'test.dart',
        path: '/project/test.dart',
        isDirectory: false,
      );

      const file2 = FileItem(
        name: 'test.dart',
        path: '/project/test.dart',
        isDirectory: false,
      );

      const file3 = FileItem(
        name: 'other.dart',
        path: '/project/other.dart',
        isDirectory: false,
      );

      expect(file1, file2);
      expect(file1 == file3, false);
    });
  });
}
