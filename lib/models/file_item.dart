import 'package:equatable/equatable.dart';

/// Represents a file or directory in the file system
class FileItem extends Equatable {
  final String name;
  final String path;
  final bool isDirectory;
  final DateTime? modifiedTime;
  final int? size;
  final List<FileItem>? children;

  const FileItem({
    required this.name,
    required this.path,
    required this.isDirectory,
    this.modifiedTime,
    this.size,
    this.children,
  });

  /// Get file extension
  String get extension {
    if (isDirectory) return '';
    final dotIndex = name.lastIndexOf('.');
    return dotIndex != -1 ? name.substring(dotIndex + 1).toLowerCase() : '';
  }

  /// Check if this is a code file
  bool get isCodeFile {
    return _codeExtensions.contains(extension);
  }

  /// Get the programming language based on extension
  String get language {
    return _extensionToLanguage[extension] ?? 'plaintext';
  }

  /// Copy with new values
  FileItem copyWith({
    String? name,
    String? path,
    bool? isDirectory,
    DateTime? modifiedTime,
    int? size,
    List<FileItem>? children,
  }) {
    return FileItem(
      name: name ?? this.name,
      path: path ?? this.path,
      isDirectory: isDirectory ?? this.isDirectory,
      modifiedTime: modifiedTime ?? this.modifiedTime,
      size: size ?? this.size,
      children: children ?? this.children,
    );
  }

  @override
  List<Object?> get props => [path, name, isDirectory];

  /// Supported code file extensions
  static const Set<String> _codeExtensions = {
    'dart', 'py', 'js', 'ts', 'jsx', 'tsx', 'java', 'kt', 'kts',
    'c', 'cpp', 'cc', 'cxx', 'h', 'hpp', 'cs', 'go', 'rs', 'rb',
    'php', 'swift', 'scala', 'r', 'lua', 'pl', 'sh', 'bash', 'zsh',
    'html', 'htm', 'css', 'scss', 'sass', 'less', 'xml', 'json',
    'yaml', 'yml', 'toml', 'ini', 'conf', 'cfg', 'md', 'markdown',
    'sql', 'graphql', 'gql', 'vue', 'svelte', 'dockerfile', 'gradle',
  };

  /// Map of file extensions to language identifiers
  static const Map<String, String> _extensionToLanguage = {
    'dart': 'dart',
    'py': 'python',
    'js': 'javascript',
    'ts': 'typescript',
    'jsx': 'javascript',
    'tsx': 'typescript',
    'java': 'java',
    'kt': 'kotlin',
    'kts': 'kotlin',
    'c': 'c',
    'cpp': 'cpp',
    'cc': 'cpp',
    'cxx': 'cpp',
    'h': 'c',
    'hpp': 'cpp',
    'cs': 'csharp',
    'go': 'go',
    'rs': 'rust',
    'rb': 'ruby',
    'php': 'php',
    'swift': 'swift',
    'scala': 'scala',
    'r': 'r',
    'lua': 'lua',
    'pl': 'perl',
    'sh': 'bash',
    'bash': 'bash',
    'zsh': 'bash',
    'html': 'html',
    'htm': 'html',
    'css': 'css',
    'scss': 'scss',
    'sass': 'sass',
    'less': 'less',
    'xml': 'xml',
    'json': 'json',
    'yaml': 'yaml',
    'yml': 'yaml',
    'toml': 'toml',
    'ini': 'ini',
    'conf': 'properties',
    'cfg': 'properties',
    'md': 'markdown',
    'markdown': 'markdown',
    'sql': 'sql',
    'graphql': 'graphql',
    'gql': 'graphql',
    'vue': 'vue',
    'svelte': 'svelte',
    'dockerfile': 'dockerfile',
    'gradle': 'groovy',
  };
}
