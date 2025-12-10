import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/editor_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/file_provider.dart';

/// Code editor widget with syntax highlighting
class CodeEditor extends StatefulWidget {
  const CodeEditor({super.key});

  @override
  State<CodeEditor> createState() => _CodeEditorState();
}

class _CodeEditorState extends State<CodeEditor> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  
  String? _currentFilePath;
  bool _isUpdating = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editorProvider = context.watch<EditorProvider>();
    final settings = context.watch<SettingsProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    final activeTab = editorProvider.activeTab;

    if (activeTab == null) {
      return _buildEmptyState(context);
    }

    // Update controller when tab changes
    if (_currentFilePath != activeTab.filePath) {
      _currentFilePath = activeTab.filePath;
      _isUpdating = true;
      _controller.text = activeTab.content;
      _controller.selection = TextSelection.collapsed(
        offset: activeTab.cursorPosition.clamp(0, activeTab.content.length),
      );
      _isUpdating = false;
    }

    return Container(
      color: colorScheme.surface,
      child: Column(
        children: [
          // Editor toolbar
          _EditorToolbar(
            filePath: activeTab.filePath,
            language: activeTab.language,
            isModified: activeTab.isModified,
          ),
          const Divider(height: 1),
          // Editor content
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Line numbers
                if (settings.showLineNumbers)
                  _LineNumbers(
                    lineCount: _getLineCount(activeTab.content),
                    fontSize: settings.fontSize,
                    fontFamily: settings.fontFamily,
                    scrollController: _scrollController,
                  ),
                // Editor area
                Expanded(
                  child: _buildEditorField(
                    context,
                    settings,
                    editorProvider,
                  ),
                ),
              ],
            ),
          ),
          // Status bar
          _EditorStatusBar(
            line: _getCurrentLine(),
            column: _getCurrentColumn(),
            language: activeTab.language,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.edit_document,
            size: 64,
            color: colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No file open',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select a file from the file tree to start editing',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditorField(
    BuildContext context,
    SettingsProvider settings,
    EditorProvider editorProvider,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      controller: _scrollController,
      child: Container(
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          style: TextStyle(
            fontFamily: settings.fontFamily,
            fontSize: settings.fontSize,
            height: 1.5,
            color: colorScheme.onSurface,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            isDense: true,
          ),
          onChanged: (value) {
            if (!_isUpdating) {
              editorProvider.updateContent(value);
            }
          },
        ),
      ),
    );
  }

  int _getLineCount(String content) {
    return '\n'.allMatches(content).length + 1;
  }

  int _getCurrentLine() {
    if (_controller.text.isEmpty) return 1;
    
    final cursorPos = _controller.selection.baseOffset;
    final textBefore = _controller.text.substring(
      0,
      cursorPos.clamp(0, _controller.text.length),
    );
    return '\n'.allMatches(textBefore).length + 1;
  }

  int _getCurrentColumn() {
    if (_controller.text.isEmpty) return 1;
    
    final cursorPos = _controller.selection.baseOffset;
    final textBefore = _controller.text.substring(
      0,
      cursorPos.clamp(0, _controller.text.length),
    );
    final lastNewline = textBefore.lastIndexOf('\n');
    return cursorPos - lastNewline;
  }
}

class _EditorToolbar extends StatelessWidget {
  final String filePath;
  final String language;
  final bool isModified;

  const _EditorToolbar({
    required this.filePath,
    required this.language,
    required this.isModified,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final fileProvider = context.read<FileProvider>();
    final editorProvider = context.read<EditorProvider>();

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          // File path breadcrumb
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _buildBreadcrumbs(context, filePath),
              ),
            ),
          ),
          // Save button
          IconButton(
            icon: Icon(
              isModified ? Icons.save : Icons.save_outlined,
              size: 20,
              color: isModified ? colorScheme.primary : null,
            ),
            tooltip: 'Save (Ctrl+S)',
            onPressed: isModified
                ? () => _saveFile(context, fileProvider, editorProvider)
                : null,
          ),
          // More options
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 20),
            tooltip: 'More options',
            onSelected: (value) => _handleMenuAction(context, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'format',
                child: ListTile(
                  leading: Icon(Icons.auto_fix_high_outlined),
                  title: Text('Format Document'),
                  dense: true,
                ),
              ),
              const PopupMenuItem(
                value: 'copy_path',
                child: ListTile(
                  leading: Icon(Icons.content_copy_outlined),
                  title: Text('Copy Path'),
                  dense: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBreadcrumbs(BuildContext context, String path) {
    final parts = path.split('/');
    final widgets = <Widget>[];

    for (var i = 0; i < parts.length; i++) {
      if (parts[i].isEmpty) continue;

      if (widgets.isNotEmpty) {
        widgets.add(
          Icon(
            Icons.chevron_right,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        );
      }

      final isLast = i == parts.length - 1;
      widgets.add(
        Text(
          parts[i],
          style: TextStyle(
            fontSize: 12,
            fontWeight: isLast ? FontWeight.w500 : FontWeight.normal,
            color: isLast
                ? Theme.of(context).colorScheme.onSurface
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return widgets;
  }

  Future<void> _saveFile(
    BuildContext context,
    FileProvider fileProvider,
    EditorProvider editorProvider,
  ) async {
    final activeTab = editorProvider.activeTab;
    if (activeTab == null) return;

    try {
      await fileProvider.writeFile(activeTab.filePath, activeTab.content);
      editorProvider.markAsSaved();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File saved'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'copy_path':
        Clipboard.setData(ClipboardData(text: filePath));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Path copied to clipboard'),
            duration: Duration(seconds: 1),
          ),
        );
        break;
      case 'format':
        // TODO: Implement document formatting
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Document formatting coming soon'),
            duration: Duration(seconds: 1),
          ),
        );
        break;
    }
  }
}

class _LineNumbers extends StatelessWidget {
  final int lineCount;
  final double fontSize;
  final String fontFamily;
  final ScrollController scrollController;

  const _LineNumbers({
    required this.lineCount,
    required this.fontSize,
    required this.fontFamily,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 48,
      color: colorScheme.surfaceContainerLow,
      padding: const EdgeInsets.only(top: 12, right: 8),
      child: ListView.builder(
        controller: scrollController,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: lineCount,
        itemBuilder: (context, index) {
          return SizedBox(
            height: fontSize * 1.5,
            child: Text(
              '${index + 1}',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: fontFamily,
                fontSize: fontSize,
                height: 1.5,
                color: colorScheme.onSurfaceVariant.withOpacity(0.6),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EditorStatusBar extends StatelessWidget {
  final int line;
  final int column;
  final String language;

  const _EditorStatusBar({
    required this.line,
    required this.column,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      color: colorScheme.surfaceContainerLow,
      child: Row(
        children: [
          Text(
            'Ln $line, Col $column',
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              language.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
