import 'package:flutter_test/flutter_test.dart';
import 'package:code_editor/providers/search_provider.dart';

void main() {
  group('SearchProvider', () {
    late SearchProvider provider;

    setUp(() {
      provider = SearchProvider();
    });

    test('should start with empty state', () {
      expect(provider.query, '');
      expect(provider.replaceText, '');
      expect(provider.results, isEmpty);
      expect(provider.isSearching, false);
      expect(provider.selectedResult, isNull);
    });

    test('should update query', () {
      provider.setQuery('test');
      expect(provider.query, 'test');
    });

    test('should update replace text', () {
      provider.setReplaceText('replacement');
      expect(provider.replaceText, 'replacement');
    });

    test('should toggle case sensitivity', () {
      expect(provider.options.caseSensitive, false);
      provider.toggleCaseSensitive();
      expect(provider.options.caseSensitive, true);
      provider.toggleCaseSensitive();
      expect(provider.options.caseSensitive, false);
    });

    test('should toggle whole word', () {
      expect(provider.options.wholeWord, false);
      provider.toggleWholeWord();
      expect(provider.options.wholeWord, true);
    });

    test('should toggle regex', () {
      expect(provider.options.useRegex, false);
      provider.toggleUseRegex();
      expect(provider.options.useRegex, true);
    });

    test('searchInContent should find matches', () {
      provider.setQuery('main');
      
      final results = provider.searchInContent(
        'void main() {\n  print("Hello");\n}',
        '/project/test.dart',
        'test.dart',
      );

      expect(results.length, 1);
      expect(results[0].lineNumber, 1);
      expect(results[0].matchedText, 'main');
    });

    test('searchInContent should find multiple matches', () {
      provider.setQuery('print');
      
      final results = provider.searchInContent(
        'print("one");\nprint("two");\nprint("three");',
        '/project/test.py',
        'test.py',
      );

      expect(results.length, 3);
    });

    test('searchInContent should respect case sensitivity', () {
      provider.setQuery('MAIN');
      
      // Case insensitive (default)
      var results = provider.searchInContent(
        'void main() {}',
        '/test.dart',
        'test.dart',
      );
      expect(results.length, 1);

      // Case sensitive
      provider.toggleCaseSensitive();
      results = provider.searchInContent(
        'void main() {}',
        '/test.dart',
        'test.dart',
      );
      expect(results.length, 0);
    });

    test('should select result correctly', () {
      provider.setQuery('test');
      final results = provider.searchInContent(
        'test one\ntest two\ntest three',
        '/test.txt',
        'test.txt',
      );

      // Manually add results for testing
      // Note: In real usage, results would be added via searchInProject

      provider.selectResult(1);
      expect(provider.selectedResultIndex, 1);
    });

    test('clear should reset all state', () {
      provider.setQuery('test');
      provider.setReplaceText('replacement');
      provider.toggleCaseSensitive();

      provider.clear();

      expect(provider.query, '');
      expect(provider.replaceText, '');
      expect(provider.results, isEmpty);
      expect(provider.selectedResultIndex, -1);
    });

    test('clearResults should only clear results', () {
      provider.setQuery('test');
      provider.clearResults();

      expect(provider.query, 'test'); // Query preserved
      expect(provider.results, isEmpty);
    });

    test('searchInContent should return empty for empty query', () {
      provider.setQuery('');
      
      final results = provider.searchInContent(
        'void main() {}',
        '/test.dart',
        'test.dart',
      );

      expect(results, isEmpty);
    });

    test('should handle whole word matching', () {
      provider.setQuery('test');
      provider.toggleWholeWord();

      // Should match whole word
      var results = provider.searchInContent(
        'test',
        '/test.txt',
        'test.txt',
      );
      expect(results.length, 1);

      // Should not match partial word
      results = provider.searchInContent(
        'testing',
        '/test.txt',
        'test.txt',
      );
      expect(results.length, 0);
    });

    test('should handle regex patterns', () {
      provider.setQuery('\\d+');
      provider.toggleUseRegex();

      final results = provider.searchInContent(
        'line 1\nline 2\nline 3',
        '/test.txt',
        'test.txt',
      );

      expect(results.length, 3);
    });
  });
}
