import 'package:equatable/equatable.dart';

/// Represents an open file tab in the editor
class EditorTab extends Equatable {
  final String id;
  final String filePath;
  final String fileName;
  final String content;
  final String language;
  final bool isModified;
  final int cursorPosition;
  final int scrollPosition;

  const EditorTab({
    required this.id,
    required this.filePath,
    required this.fileName,
    required this.content,
    required this.language,
    this.isModified = false,
    this.cursorPosition = 0,
    this.scrollPosition = 0,
  });

  /// Copy with new values
  EditorTab copyWith({
    String? id,
    String? filePath,
    String? fileName,
    String? content,
    String? language,
    bool? isModified,
    int? cursorPosition,
    int? scrollPosition,
  }) {
    return EditorTab(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      content: content ?? this.content,
      language: language ?? this.language,
      isModified: isModified ?? this.isModified,
      cursorPosition: cursorPosition ?? this.cursorPosition,
      scrollPosition: scrollPosition ?? this.scrollPosition,
    );
  }

  @override
  List<Object?> get props => [id, filePath, isModified];
}
