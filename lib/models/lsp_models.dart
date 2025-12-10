/// LSP-related models for Language Server Protocol integration

/// Represents a diagnostic from the LSP
class LspDiagnostic {
  final String message;
  final DiagnosticSeverity severity;
  final int startLine;
  final int startColumn;
  final int endLine;
  final int endColumn;
  final String? source;
  final String? code;

  const LspDiagnostic({
    required this.message,
    required this.severity,
    required this.startLine,
    required this.startColumn,
    required this.endLine,
    required this.endColumn,
    this.source,
    this.code,
  });
}

/// Diagnostic severity levels
enum DiagnosticSeverity {
  error(1),
  warning(2),
  information(3),
  hint(4);

  final int value;
  const DiagnosticSeverity(this.value);
}

/// Represents a code completion item from the LSP
class CompletionItem {
  final String label;
  final CompletionItemKind kind;
  final String? detail;
  final String? documentation;
  final String insertText;
  final int? sortPriority;

  const CompletionItem({
    required this.label,
    required this.kind,
    this.detail,
    this.documentation,
    required this.insertText,
    this.sortPriority,
  });
}

/// Completion item kinds
enum CompletionItemKind {
  text(1),
  method(2),
  function(3),
  constructor(4),
  field(5),
  variable(6),
  classKind(7),
  interface(8),
  module(9),
  property(10),
  unit(11),
  value(12),
  enumKind(13),
  keyword(14),
  snippet(15),
  color(16),
  file(17),
  reference(18),
  folder(19),
  enumMember(20),
  constant(21),
  struct(22),
  event(23),
  operator(24),
  typeParameter(25);

  final int value;
  const CompletionItemKind(this.value);
}

/// Represents a symbol from the document
class DocumentSymbol {
  final String name;
  final SymbolKind kind;
  final int startLine;
  final int startColumn;
  final int endLine;
  final int endColumn;
  final List<DocumentSymbol>? children;

  const DocumentSymbol({
    required this.name,
    required this.kind,
    required this.startLine,
    required this.startColumn,
    required this.endLine,
    required this.endColumn,
    this.children,
  });
}

/// Symbol kinds
enum SymbolKind {
  file(1),
  module(2),
  namespace(3),
  package(4),
  classKind(5),
  method(6),
  property(7),
  field(8),
  constructor(9),
  enumKind(10),
  interface(11),
  function(12),
  variable(13),
  constant(14),
  string(15),
  number(16),
  boolean(17),
  array(18),
  object(19),
  key(20),
  nullKind(21),
  enumMember(22),
  struct(23),
  event(24),
  operator(25),
  typeParameter(26);

  final int value;
  const SymbolKind(this.value);
}

/// Represents a hover response from the LSP
class HoverInfo {
  final String contents;
  final int? startLine;
  final int? startColumn;
  final int? endLine;
  final int? endColumn;

  const HoverInfo({
    required this.contents,
    this.startLine,
    this.startColumn,
    this.endLine,
    this.endColumn,
  });
}

/// Represents a location (for go-to-definition, references, etc.)
class LocationInfo {
  final String uri;
  final int startLine;
  final int startColumn;
  final int endLine;
  final int endColumn;

  const LocationInfo({
    required this.uri,
    required this.startLine,
    required this.startColumn,
    required this.endLine,
    required this.endColumn,
  });
}
