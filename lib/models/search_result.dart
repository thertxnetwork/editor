import 'package:equatable/equatable.dart';

/// Represents a search result
class SearchResult extends Equatable {
  final String filePath;
  final String fileName;
  final int lineNumber;
  final String lineContent;
  final int matchStart;
  final int matchEnd;

  const SearchResult({
    required this.filePath,
    required this.fileName,
    required this.lineNumber,
    required this.lineContent,
    required this.matchStart,
    required this.matchEnd,
  });

  /// Get the matched text
  String get matchedText {
    if (matchStart >= 0 && matchEnd <= lineContent.length) {
      return lineContent.substring(matchStart, matchEnd);
    }
    return '';
  }

  @override
  List<Object?> get props => [filePath, lineNumber, matchStart, matchEnd];
}

/// Search options configuration
class SearchOptions {
  final bool caseSensitive;
  final bool wholeWord;
  final bool useRegex;
  final bool searchInFiles;
  final List<String> includePatterns;
  final List<String> excludePatterns;

  const SearchOptions({
    this.caseSensitive = false,
    this.wholeWord = false,
    this.useRegex = false,
    this.searchInFiles = true,
    this.includePatterns = const ['*'],
    this.excludePatterns = const [
      'node_modules',
      '.git',
      'build',
      '.dart_tool',
    ],
  });

  SearchOptions copyWith({
    bool? caseSensitive,
    bool? wholeWord,
    bool? useRegex,
    bool? searchInFiles,
    List<String>? includePatterns,
    List<String>? excludePatterns,
  }) {
    return SearchOptions(
      caseSensitive: caseSensitive ?? this.caseSensitive,
      wholeWord: wholeWord ?? this.wholeWord,
      useRegex: useRegex ?? this.useRegex,
      searchInFiles: searchInFiles ?? this.searchInFiles,
      includePatterns: includePatterns ?? this.includePatterns,
      excludePatterns: excludePatterns ?? this.excludePatterns,
    );
  }
}
