import 'package:highlight/highlight.dart' show highlight, Mode;
import 'package:highlight/languages/all.dart';

/// Service for syntax highlighting
class SyntaxHighlightService {
  SyntaxHighlightService._();

  static final SyntaxHighlightService instance = SyntaxHighlightService._();

  /// Initialize highlighting with all languages
  void initialize() {
    allLanguages.forEach((name, mode) {
      highlight.registerLanguage(name, mode);
    });
  }

  /// Get available languages
  List<String> get availableLanguages => allLanguages.keys.toList()..sort();

  /// Highlight code and return parsed result
  HighlightResult? highlightCode(String code, String language) {
    try {
      final result = highlight.parse(code, language: language);
      return HighlightResult(
        relevance: result.relevance ?? 0,
        language: result.language ?? language,
        nodes: _parseNodes(result.nodes),
      );
    } catch (e) {
      return null;
    }
  }

  /// Auto-detect language and highlight
  HighlightResult? autoHighlight(String code) {
    try {
      final result = highlight.highlightAuto(code);
      return HighlightResult(
        relevance: result.relevance ?? 0,
        language: result.language ?? 'plaintext',
        nodes: _parseNodes(result.nodes),
      );
    } catch (e) {
      return null;
    }
  }

  /// Parse highlight.js nodes to our model
  List<HighlightNode> _parseNodes(List<dynamic>? nodes) {
    if (nodes == null) return [];

    final result = <HighlightNode>[];
    for (final node in nodes) {
      if (node is String) {
        result.add(HighlightNode(text: node));
      } else if (node.className != null) {
        result.add(HighlightNode(
          text: node.value ?? _extractText(node.children),
          className: node.className,
          children: _parseNodes(node.children),
        ));
      }
    }
    return result;
  }

  /// Extract text from children nodes
  String _extractText(List<dynamic>? children) {
    if (children == null) return '';
    final buffer = StringBuffer();
    for (final child in children) {
      if (child is String) {
        buffer.write(child);
      } else {
        buffer.write(child.value ?? _extractText(child.children));
      }
    }
    return buffer.toString();
  }

  /// Get Mode for a language
  Mode? getModeForLanguage(String language) {
    return allLanguages[language];
  }
}

/// Result of syntax highlighting
class HighlightResult {
  final int relevance;
  final String language;
  final List<HighlightNode> nodes;

  HighlightResult({
    required this.relevance,
    required this.language,
    required this.nodes,
  });
}

/// A node in the highlight tree
class HighlightNode {
  final String text;
  final String? className;
  final List<HighlightNode>? children;

  HighlightNode({
    required this.text,
    this.className,
    this.children,
  });
}
