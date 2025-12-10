import 'package:flutter_test/flutter_test.dart';
import 'package:code_editor/models/search_result.dart';

void main() {
  group('SearchResult', () {
    test('should create search result with all properties', () {
      const result = SearchResult(
        filePath: '/project/main.dart',
        fileName: 'main.dart',
        lineNumber: 5,
        lineContent: '  void main() {',
        matchStart: 7,
        matchEnd: 11,
      );

      expect(result.filePath, '/project/main.dart');
      expect(result.fileName, 'main.dart');
      expect(result.lineNumber, 5);
      expect(result.lineContent, '  void main() {');
      expect(result.matchStart, 7);
      expect(result.matchEnd, 11);
    });

    test('matchedText should return correct substring', () {
      const result = SearchResult(
        filePath: '/project/main.dart',
        fileName: 'main.dart',
        lineNumber: 1,
        lineContent: 'void main() {}',
        matchStart: 5,
        matchEnd: 9,
      );

      expect(result.matchedText, 'main');
    });

    test('matchedText should handle edge cases', () {
      const result = SearchResult(
        filePath: '/project/test.dart',
        fileName: 'test.dart',
        lineNumber: 1,
        lineContent: 'test',
        matchStart: 0,
        matchEnd: 4,
      );

      expect(result.matchedText, 'test');
    });

    test('equality should be based on file, line, and match position', () {
      const result1 = SearchResult(
        filePath: '/project/main.dart',
        fileName: 'main.dart',
        lineNumber: 5,
        lineContent: 'void main() {}',
        matchStart: 5,
        matchEnd: 9,
      );

      const result2 = SearchResult(
        filePath: '/project/main.dart',
        fileName: 'main.dart',
        lineNumber: 5,
        lineContent: 'void main() {}',
        matchStart: 5,
        matchEnd: 9,
      );

      const result3 = SearchResult(
        filePath: '/project/main.dart',
        fileName: 'main.dart',
        lineNumber: 10,
        lineContent: 'void main() {}',
        matchStart: 5,
        matchEnd: 9,
      );

      expect(result1, result2);
      expect(result1 == result3, false);
    });
  });

  group('SearchOptions', () {
    test('should have sensible defaults', () {
      const options = SearchOptions();

      expect(options.caseSensitive, false);
      expect(options.wholeWord, false);
      expect(options.useRegex, false);
      expect(options.searchInFiles, true);
      expect(options.includePatterns, ['*']);
      expect(options.excludePatterns, isNotEmpty);
    });

    test('copyWith should update specified fields', () {
      const original = SearchOptions();
      final modified = original.copyWith(
        caseSensitive: true,
        wholeWord: true,
      );

      expect(modified.caseSensitive, true);
      expect(modified.wholeWord, true);
      expect(modified.useRegex, false); // Unchanged
    });

    test('default exclude patterns should include common directories', () {
      const options = SearchOptions();

      expect(options.excludePatterns, contains('node_modules'));
      expect(options.excludePatterns, contains('.git'));
      expect(options.excludePatterns, contains('build'));
    });
  });
}
