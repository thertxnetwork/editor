# Flutter Code Editor Blueprint - Material Design 3

## 🎯 Overview

A clean, simple Material Design 3 code editor with excellent UX. Focus on simplicity and native Android feel. 

---

## 📁 Simplified Project Structure

```
lib/
├── main.dart
├── app.dart
├── models/
│   ├── file_node.dart
│   ├── editor_tab.dart
│   └── ssh_config.dart
├── services/
│   ├── file_service.dart
│   ├── ssh_service.dart
│   └── settings_service.dart
├── providers/
│   ├── editor_provider.dart
│   ├── file_provider.dart
│   └── ssh_provider.dart
├── screens/
│   ├── home_screen.dart
│   ├── editor_screen.dart
│   ├── settings_screen.dart
│   └── ssh_connect_screen.dart
├── widgets/
│   ├── file_list_tile.dart
│   ├── editor_tab_bar.dart
│   └── code_editor_widget.dart
└── utils/
    ├── file_icons.dart
    ├── syntax_themes.dart
    └── constants.dart
```

---

## 🎨 Material Design 3 Theme Setup

```dart
// lib/app.dart
import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';

class CodeEditorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return MaterialApp(
          title: 'Code Editor',
          debugShowCheckedModeBanner: false,
          
          // Material 3 Light Theme
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: lightDynamic ?? ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness. light,
            ),
          ),
          
          // Material 3 Dark Theme (preferred for code editors)
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkDynamic?. copyWith(
              brightness: Brightness.dark,
            ) ?? ColorScheme.fromSeed(
              seedColor: Colors. blue,
              brightness: Brightness.dark,
            ),
          ),
          
          themeMode: ThemeMode.system,
          home: HomeScreen(),
        );
      },
    );
  }
}
```

---

## 🏠 Home Screen (Simple Navigation Drawer)

```dart
// lib/screens/home_screen.dart
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String?  _currentProjectPath;
  
  final List<Widget> _screens = [
    FileExplorerView(),
    EditorView(),
    TerminalView(),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      // Simple App Bar
      appBar: AppBar(
        title: Text(_currentProjectPath?. split('/').last ?? 'Code Editor'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            tooltip: 'Search in files',
            onPressed: () => _showSearch(context),
          ),
          IconButton(
            icon: Icon(Icons.more_vert),
            tooltip:  'More options',
            onPressed: () => _showMoreOptions(context),
          ),
        ],
      ),
      
      // Navigation Drawer
      drawer: NavigationDrawer(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
          Navigator.pop(context);
        },
        children: [
          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(16, 28, 16, 16),
            child: Text(
              'Code Editor',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          
          // Open Project Button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: FilledButton. icon(
              onPressed: _openProject,
              icon: Icon(Icons.folder_open),
              label: Text('Open Project'),
            ),
          ),
          
          Divider(indent: 16, endIndent:  16),
          
          NavigationDrawerDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder),
            label: Text('Files'),
          ),
          NavigationDrawerDestination(
            icon: Icon(Icons.code_outlined),
            selectedIcon:  Icon(Icons.code),
            label: Text('Editor'),
          ),
          NavigationDrawerDestination(
            icon: Icon(Icons.terminal_outlined),
            selectedIcon: Icon(Icons.terminal),
            label: Text('Terminal'),
          ),
          
          Divider(indent: 16, endIndent: 16),
          
          // Remote Connection
          NavigationDrawerDestination(
            icon: Icon(Icons.cloud_outlined),
            selectedIcon:  Icon(Icons.cloud),
            label: Text('Remote (SSH)'),
          ),
          
          Spacer(),
          
          // Settings at bottom
          Padding(
            padding: EdgeInsets.all(16),
            child: ListTile(
              leading: Icon(Icons.settings_outlined),
              title: Text('Settings'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              onTap: () => _openSettings(context),
            ),
          ),
        ],
      ),
      
      // Main Content
      body: _screens[_selectedIndex],
      
      // Bottom Navigation (Alternative - simpler)
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon:  Icon(Icons.folder),
            label: 'Files',
          ),
          NavigationDestination(
            icon: Icon(Icons.code_outlined),
            selectedIcon: Icon(Icons.code),
            label: 'Editor',
          ),
          NavigationDestination(
            icon: Icon(Icons.terminal_outlined),
            selectedIcon: Icon(Icons.terminal),
            label: 'Terminal',
          ),
        ],
      ),
      
      // FAB for quick actions
      floatingActionButton:  FloatingActionButton(
        onPressed: () => _showQuickActions(context),
        tooltip: 'Quick Actions',
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> _openProject() async {
    // Open folder picker
  }

  void _showSearch(BuildContext context) {
    showSearch(context: context, delegate: FileSearchDelegate());
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context:  context,
      builder: (context) => MoreOptionsSheet(),
    );
  }

  void _openSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SettingsScreen()),
    );
  }

  void _showQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => QuickActionsSheet(),
    );
  }
}
```

---

## 📂 File Explorer (Simple List View)

```dart
// lib/screens/file_explorer_view.dart
import 'package:flutter/material.dart';

class FileExplorerView extends StatefulWidget {
  @override
  _FileExplorerViewState createState() => _FileExplorerViewState();
}

class _FileExplorerViewState extends State<FileExplorerView> {
  List<FileNode> _files = [];
  String _currentPath = '';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    if (_files.isEmpty && _currentPath.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // Breadcrumb / Path Bar
        _buildPathBar(),
        
        // File List
        Expanded(
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _refreshFiles,
                  child: ListView.builder(
                    itemCount: _files.length,
                    itemBuilder: (context, index) {
                      return FileListTile(
                        file: _files[index],
                        onTap: () => _onFileTap(_files[index]),
                        onLongPress: () => _showFileOptions(_files[index]),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons. folder_open_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.outline,
          ),
          SizedBox(height: 16),
          Text(
            'No project opened',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: 8),
          Text(
            'Open a folder to start editing',
            style: Theme.of(context).textTheme.bodyMedium?. copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _openFolder,
            icon: Icon(Icons.folder_open),
            label: Text('Open Folder'),
          ),
          SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _connectSSH,
            icon: Icon(Icons.cloud_outlined),
            label: Text('Connect to Remote'),
          ),
        ],
      ),
    );
  }

  Widget _buildPathBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Back button
          if (_currentPath.isNotEmpty)
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: _goBack,
              tooltip: 'Go back',
            ),
          
          // Path chips
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _buildBreadcrumbs(),
              ),
            ),
          ),
          
          // Sort button
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: _showSortOptions,
            tooltip: 'Sort',
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBreadcrumbs() {
    final parts = _currentPath.split('/').where((p) => p.isNotEmpty).toList();
    return parts.asMap().entries.map((entry) {
      final isLast = entry.key == parts.length - 1;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ActionChip(
            label: Text(entry.value),
            onPressed: isLast ? null : () => _navigateTo(entry.key),
          ),
          if (!isLast) Icon(Icons.chevron_right, size: 16),
        ],
      );
    }).toList();
  }

  Future<void> _openFolder() async {
    // Implementation
  }

  Future<void> _connectSSH() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SSHConnectScreen()),
    );
  }

  void _onFileTap(FileNode file) {
    if (file.isDirectory) {
      // Navigate into directory
      setState(() {
        _currentPath = file. path;
        _loadFiles();
      });
    } else {
      // Open file in editor
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EditorScreen(file: file),
        ),
      );
    }
  }

  void _showFileOptions(FileNode file) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => FileOptionsSheet(file: file),
    );
  }

  Future<void> _refreshFiles() async {
    await _loadFiles();
  }

  Future<void> _loadFiles() async {
    // Load files from current path
  }

  void _goBack() {
    // Navigate to parent directory
  }

  void _navigateTo(int index) {
    // Navigate to specific breadcrumb
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => SortOptionsSheet(),
    );
  }
}
```

---

## 📄 File List Tile (Material 3 Style)

```dart
// lib/widgets/file_list_tile. dart
import 'package:flutter/material.dart';

class FileListTile extends StatelessWidget {
  final FileNode file;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const FileListTile({
    required this.file,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _getIconBackgroundColor(colorScheme),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          _getIcon(),
          color: _getIconColor(colorScheme),
          size: 24,
        ),
      ),
      title: Text(
        file.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        file.isDirectory 
            ? '${file.childCount ??  0} items' 
            : _formatFileSize(file.size),
        style: TextStyle(
          color: colorScheme.outline,
          fontSize: 12,
        ),
      ),
      trailing: file.isDirectory
          ? Icon(Icons.chevron_right)
          : null,
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }

  IconData _getIcon() {
    if (file.isDirectory) {
      return Icons.folder;
    }
    
    switch (file.extension) {
      case 'dart':
        return Icons.flutter_dash;
      case 'js':
      case 'ts':
      case 'jsx':
      case 'tsx':
        return Icons.javascript;
      case 'py':
        return Icons.code;
      case 'java':
      case 'kt':
        return Icons.android;
      case 'swift':
        return Icons.apple;
      case 'html':
        return Icons.html;
      case 'css': 
      case 'scss':
        return Icons.css;
      case 'json':
      case 'yaml':
      case 'yml':
        return Icons.data_object;
      case 'md':
        return Icons.description;
      case 'png':
      case 'jpg':
      case 'jpeg':
      case 'gif':
      case 'svg':
        return Icons.image;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'zip':
      case 'rar':
      case 'tar':
        return Icons.archive;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getIconBackgroundColor(ColorScheme colorScheme) {
    if (file.isDirectory) {
      return colorScheme.primaryContainer;
    }
    
    switch (file.extension) {
      case 'dart': 
        return Colors.blue. withOpacity(0.1);
      case 'js':
      case 'ts':
        return Colors.yellow.withOpacity(0.1);
      case 'py':
        return Colors.green. withOpacity(0.1);
      case 'html':
        return Colors.orange.withOpacity(0.1);
      case 'css':
        return Colors.blue.withOpacity(0.1);
      case 'json':
        return Colors.amber.withOpacity(0.1);
      default:
        return colorScheme. surfaceVariant;
    }
  }

  Color _getIconColor(ColorScheme colorScheme) {
    if (file.isDirectory) {
      return colorScheme.primary;
    }
    
    switch (file.extension) {
      case 'dart':
        return Colors.blue;
      case 'js':
      case 'ts':
        return Colors.amber. shade700;
      case 'py':
        return Colors.green. shade700;
      case 'html':
        return Colors.orange;
      case 'css': 
        return Colors.blue.shade700;
      case 'json': 
        return Colors.amber;
      default:
        return colorScheme.onSurfaceVariant;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
```

---

## ✏️ Editor Screen (Clean & Simple)

```dart
// lib/screens/editor_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:highlight/languages/all.dart';

class EditorScreen extends StatefulWidget {
  final FileNode file;

  const EditorScreen({required this.file});

  @override
  _EditorScreenState createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late CodeController _controller;
  bool _isModified = false;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initEditor();
  }

  Future<void> _initEditor() async {
    final content = await FileService().readFile(widget.file.path);
    
    _controller = CodeController(
      text: content,
      language: _getLanguage(widget.file. extension),
    );
    
    _controller.addListener(() {
      if (! _isModified) {
        setState(() => _isModified = true);
      }
    });

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.file.name),
            if (_isModified)
              Padding(
                padding: EdgeInsets.only(left: 4),
                child: Icon(
                  Icons.circle,
                  size: 8,
                  color: colorScheme.primary,
                ),
              ),
          ],
        ),
        centerTitle: true,
        actions:  [
          // Undo
          IconButton(
            icon:  Icon(Icons.undo),
            onPressed: _controller.canUndo ? () => _controller.undo() : null,
            tooltip: 'Undo',
          ),
          // Redo
          IconButton(
            icon: Icon(Icons.redo),
            onPressed: _controller.canRedo ? () => _controller.redo() : null,
            tooltip: 'Redo',
          ),
          // Save
          IconButton(
            icon: _isSaving 
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons. save),
            onPressed: _isModified ? _saveFile : null,
            tooltip: 'Save',
          ),
          // More options
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: ListTile(
                  leading:  Icon(Icons.content_copy),
                  title: Text('Copy all'),
                  contentPadding: EdgeInsets. zero,
                ),
                onTap: _copyAll,
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.find_replace),
                  title: Text('Find & Replace'),
                  contentPadding: EdgeInsets.zero,
                ),
                onTap: () => _showFindReplace(context),
              ),
              PopupMenuItem(
                child:  ListTile(
                  leading: Icon(Icons.format_align_left),
                  title: Text('Format code'),
                  contentPadding: EdgeInsets.zero,
                ),
                onTap:  _formatCode,
              ),
              Divider(),
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.text_fields),
                  title:  Text('Font settings'),
                  contentPadding: EdgeInsets.zero,
                ),
                onTap:  () => _showFontSettings(context),
              ),
            ],
          ),
        ],
      ),
      
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : CodeEditorWidget(controller: _controller),
      
      // Quick action bar at bottom
      bottomNavigationBar:  _buildEditorToolbar(),
    );
  }

  Widget _buildEditorToolbar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Row(
        children: [
          // Line & Column info
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Ln 1, Col 1',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          
          Spacer(),
          
          // Quick insert buttons
          _buildToolbarButton(Icons.arrow_right_alt, 'Tab', () => _insert('\t')),
          _buildToolbarButton(Icons.data_array, '[]', () => _insert('[]')),
          _buildToolbarButton(Icons.data_object, '{}', () => _insert('{}')),
          _buildToolbarButton(Icons.format_quote, '""', () => _insert('""')),
          _buildToolbarButton(Icons.code, '<>', () => _insert('<>')),
          
          SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildToolbarButton(IconData icon, String tooltip, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, size: 20),
      tooltip: tooltip,
      onPressed:  onTap,
      visualDensity: VisualDensity.compact,
    );
  }

  void _insert(String text) {
    // Insert text at cursor
  }

  Future<void> _saveFile() async {
    setState(() => _isSaving = true);
    
    try {
      await FileService().saveFile(widget.file.path, _controller.text);
      setState(() {
        _isModified = false;
        _isSaving = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File saved'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save:  $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _copyAll() {
    Clipboard.setData(ClipboardData(text: _controller.text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied to clipboard'),
        behavior: SnackBarBehavior. floating,
      ),
    );
  }

  void _showFindReplace(BuildContext context) {
    showModalBottomSheet(
      context:  context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => FindReplaceSheet(controller: _controller),
    );
  }

  void _formatCode() {
    // Format code based on language
  }

  void _showFontSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => FontSettingsSheet(),
    );
  }

  Mode?  _getLanguage(String extension) {
    final languages = {
      'dart': allLanguages['dart'],
      'js': allLanguages['javascript'],
      'ts': allLanguages['typescript'],
      'py': allLanguages['python'],
      'java': allLanguages['java'],
      'kt': allLanguages['kotlin'],
      'swift': allLanguages['swift'],
      'go': allLanguages['go'],
      'rs': allLanguages['rust'],
      'c': allLanguages['c'],
      'cpp': allLanguages['cpp'],
      'html': allLanguages['xml'],
      'css': allLanguages['css'],
      'json': allLanguages['json'],
      'yaml': allLanguages['yaml'],
      'yml': allLanguages['yaml'],
      'md': allLanguages['markdown'],
      'sql': allLanguages['sql'],
      'sh': allLanguages['bash'],
    };
    return languages[extension];
  }
}
```

---

## 🎨 Code Editor Widget with Theme

```dart
// lib/widgets/code_editor_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';

class CodeEditorWidget extends StatelessWidget {
  final CodeController controller;

  const CodeEditorWidget({required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return CodeTheme(
      data: isDark ? _darkTheme : _lightTheme,
      child: SingleChildScrollView(
        child:  CodeField(
          controller: controller,
          textStyle: TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: 14,
            height: 1.5,
          ),
          lineNumberStyle: LineNumberStyle(
            textStyle: TextStyle(
              color: Theme.of(context).colorScheme.outline,
              fontSize: 12,
            ),
          ),
          gutterStyle: GutterStyle(
            width: 48,
            margin: 8,
          ),
        ),
      ),
    );
  }

  // Material 3 inspired dark theme
  CodeThemeData get _darkTheme => CodeThemeData(
    styles: {
      'root': TextStyle(color: Color(0xFFE0E0E0), backgroundColor: Color(0xFF1E1E1E)),
      'keyword': TextStyle(color: Color(0xFF82AAFF)),
      'string': TextStyle(color: Color(0xFFC3E88D)),
      'number': TextStyle(color: Color(0xFFF78C6C)),
      'comment': TextStyle(color: Color(0xFF616161)),
      'class': TextStyle(color: Color(0xFFFFCB6B)),
      'function': TextStyle(color: Color(0xFF82AAFF)),
      'variable': TextStyle(color: Color(0xFFE0E0E0)),
      'type': TextStyle(color: Color(0xFFFFCB6B)),
      'built_in': TextStyle(color:  Color(0xFF89DDFF)),
      'params': TextStyle(color: Color(0xFFE0E0E0)),
      'attr':  TextStyle(color: Color(0xFFC792EA)),
      'meta': TextStyle(color: Color(0xFF89DDFF)),
      'title': TextStyle(color: Color(0xFFFFCB6B)),
    },
  );

  // Material 3 inspired light theme
  CodeThemeData get _lightTheme => CodeThemeData(
    styles:  {
      'root': TextStyle(color: Color(0xFF212121), backgroundColor: Color(0xFFFAFAFA)),
      'keyword': TextStyle(color: Color(0xFF1565C0)),
      'string': TextStyle(color: Color(0xFF2E7D32)),
      'number': TextStyle(color: Color(0xFFE65100)),
      'comment': TextStyle(color: Color(0xFF9E9E9E)),
      'class': TextStyle(color: Color(0xFFF57C00)),
      'function': TextStyle(color: Color(0xFF1565C0)),
      'variable': TextStyle(color:  Color(0xFF212121)),
      'type': TextStyle(color: Color(0xFFF57C00)),
      'built_in': TextStyle(color: Color(0xFF00838F)),
      'params': TextStyle(color: Color(0xFF212121)),
      'attr': TextStyle(color: Color(0xFF7B1FA2)),
      'meta': TextStyle(color: Color(0xFF00838F)),
      'title': TextStyle(color: Color(0xFFF57C00)),
    },
  );
}
```

---

## 🔐 SSH Connect Screen (Simple Form)

```dart
// lib/screens/ssh_connect_screen. dart
import 'package:flutter/material.dart';

class SSHConnectScreen extends StatefulWidget {
  @override
  _SSHConnectScreenState createState() => _SSHConnectScreenState();
}

class _SSHConnectScreenState extends State<SSHConnectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hostController = TextEditingController();
  final _portController = TextEditingController(text: '22');
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _pathController = TextEditingController(text: '/home');
  
  bool _isConnecting = false;
  bool _obscurePassword = true;
  List<SSHConfig> _savedConnections = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Connect to Remote'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Saved Connections
            if (_savedConnections.isNotEmpty) ...[
              Text(
                'Recent Connections',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 8),
              ..._savedConnections.map((config) => Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(Icons.cloud),
                  ),
                  title: Text(config.name),
                  subtitle: Text('${config.username}@${config.host}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete_outline),
                    onPressed:  () => _deleteConnection(config),
                  ),
                  onTap: () => _quickConnect(config),
                ),
              )),
              SizedBox(height: 24),
              Divider(),
              SizedBox(height: 16),
            ],
            
            // New Connection Form
            Text(
              'New Connection',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 16),
            
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Host
                  TextFormField(
                    controller:  _hostController,
                    decoration: InputDecoration(
                      labelText: 'Host',
                      hintText: 'example.com or 192.168.1.1',
                      prefixIcon:  Icon(Icons.dns),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v?.isEmpty ?? true ? 'Required' :  null,
                    keyboardType: TextInputType.url,
                  ),
                  SizedBox(height: 16),
                  
                  // Port
                  TextFormField(
                    controller: _portController,
                    decoration: InputDecoration(
                      labelText: 'Port',
                      prefixIcon: Icon(Icons.numbers),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 16),
                  
                  // Username
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      hintText: 'root',
                      prefixIcon:  Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  ),
                  SizedBox(height:  16),
                  
                  // Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword 
                              ? Icons.visibility 
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  // Remote Path
                  TextFormField(
                    controller: _pathController,
                    decoration: InputDecoration(
                      labelText:  'Remote Path (Optional)',
                      hintText:  '/home/user/projects',
                      prefixIcon:  Icon(Icons.folder),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  // Private Key Option
                  OutlinedButton. icon(
                    onPressed: _selectPrivateKey,
                    icon: Icon(Icons.key),
                    label: Text('Use Private Key Instead'),
                  ),
                  
                  SizedBox(height: 32),
                  
                  // Connect Button
                  SizedBox(
                    width:  double.infinity,
                    child: FilledButton. icon(
                      onPressed: _isConnecting ? null : _connect,
                      icon: _isConnecting
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Icon(Icons.cloud_outlined),
                      label: Text(_isConnecting ? 'Connecting...' : 'Connect'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectPrivateKey() async {
    // Open file picker for private key
  }

  void _quickConnect(SSHConfig config) async {
    setState(() => _isConnecting = true);
    
    // Connect using saved config
    final sshService = SSHService();
    final connected = await sshService.connect(config);
    
    setState(() => _isConnecting = false);
    
    if (connected) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RemoteFileExplorerScreen(sshService: sshService),
        ),
      );
    } else {
      _showError('Connection failed');
    }
  }

  Future<void> _connect() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isConnecting = true);
    
    final config = SSHConfig(
      name: _hostController.text,
      host: _hostController.text,
      port: int.tryParse(_portController.text) ?? 22,
      username:  _usernameController.text,
      password: _passwordController. text,
      remotePath: _pathController.text,
    );
    
    final sshService = SSHService();
    final connected = await sshService.connect(config);
    
    setState(() => _isConnecting = false);
    
    if (connected) {
      // Save connection for later
      _saveConnection(config);
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RemoteFileExplorerScreen(sshService: sshService),
        ),
      );
    } else {
      _showError('Connection failed.  Check credentials and try again.');
    }
  }

  void _saveConnection(SSHConfig config) {
    // Save to local storage
  }

  void _deleteConnection(SSHConfig config) {
    // Delete from local storage
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}
```

---

## ⚙️ Settings Screen (Material 3)

```dart
// lib/screens/settings_screen. dart
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Settings values
  String _selectedFont = 'JetBrains Mono';
  double _fontSize = 14;
  String _selectedTheme = 'System';
  bool _showLineNumbers = true;
  bool _wordWrap = false;
  bool _autoSave = true;
  int _tabSize = 2;

  final List<String> _fonts = [
    'JetBrains Mono',
    'Fira Code',
    'Cascadia Code',
    'Source Code Pro',
    'Roboto Mono',
    'Ubuntu Mono',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // Appearance Section
          _buildSectionHeader('Appearance'),
          
          // Theme
          ListTile(
            leading: Icon(Icons.palette_outlined),
            title: Text('Theme'),
            subtitle: Text(_selectedTheme),
            trailing:  Icon(Icons.chevron_right),
            onTap: () => _showThemeDialog(),
          ),
          
          Divider(indent: 72),
          
          // Editor Section
          _buildSectionHeader('Editor'),
          
          // Font Family
          ListTile(
            leading: Icon(Icons.font_download_outlined),
            title: Text('Font'),
            subtitle: Text(_selectedFont),
            trailing: Icon(Icons.chevron_right),
            onTap: () => _showFontDialog(),
          ),
          
          // Font Size
          ListTile(
            leading: Icon(Icons.format_size),
            title: Text('Font Size'),
            subtitle:  Slider(
              value: _fontSize,
              min: 10,
              max: 24,
              divisions: 14,
              label: '${_fontSize.toInt()}',
              onChanged: (value) => setState(() => _fontSize = value),
            ),
          ),
          
          // Tab Size
          ListTile(
            leading: Icon(Icons.space_bar),
            title: Text('Tab Size'),
            subtitle:  Text('$_tabSize spaces'),
            trailing: SegmentedButton<int>(
              segments: [
                ButtonSegment(value: 2, label: Text('2')),
                ButtonSegment(value: 4, label: Text('4')),
              ],
              selected: {_tabSize},
              onSelectionChanged: (value) {
                setState(() => _tabSize = value. first);
              },
            ),
          ),
          
          // Line Numbers
          SwitchListTile(
            secondary: Icon(Icons.format_list_numbered),
            title: Text('Show Line Numbers'),
            value: _showLineNumbers,
            onChanged: (value) => setState(() => _showLineNumbers = value),
          ),
          
          // Word Wrap
          SwitchListTile(
            secondary: Icon(Icons.wrap_text),
            title: Text('Word Wrap'),
            value: _wordWrap,
            onChanged:  (value) => setState(() => _wordWrap = value),
          ),
          
          // Auto Save
          SwitchListTile(
            secondary: Icon(Icons.save_outlined),
            title: Text('Auto Save'),
            subtitle: Text('Save files automatically'),
            value: _autoSave,
            onChanged:  (value) => setState(() => _autoSave = value),
          ),
          
          Divider(indent: 72),
          
          // About Section
          _buildSectionHeader('About'),
          
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Version'),
            subtitle: Text('1.0.0'),
          ),
          
          ListTile(
            leading: Icon(Icons.code),
            title: Text('Source Code'),
            trailing: Icon(Icons.open_in_new),
            onTap: () {
              // Open GitHub repo
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Theme'),
        content: Column(
          mainAxisSize: MainAxisSize. min,
          children: ['System', 'Light', 'Dark']. map((theme) {
            return RadioListTile<String>(
              title: Text(theme),
              value: theme,
              groupValue: _selectedTheme,
              onChanged: (value) {
                setState(() => _selectedTheme = value! );
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showFontDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Font'),
        content: SingleChildScrollView(
          child:  Column(
            mainAxisSize:  MainAxisSize.min,
            children: _fonts.map((font) {
              return RadioListTile<String>(
                title:  Text(font, style: TextStyle(fontFamily:  font)),
                value: font,
                groupValue: _selectedFont,
                onChanged: (value) {
                  setState(() => _selectedFont = value!);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
```

---

## 📦 Dependencies (Simplified)

```yaml
# pubspec.yaml
name: code_editor
description: A simple code editor built with Flutter and Material Design 3

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # Material Design
  dynamic_color: ^1.6.8        # Material You colors
  
  # Code Editor
  flutter_code_editor: ^0.3.0  # Code editor widget
  highlight: ^0.7.0            # Syntax highlighting
  
  # File System
  file_picker: ^6.1.1          # File/folder picker
  path:  ^1.8.3                 # Path utilities
  
  # SSH
  dartssh2: ^2.8.1             # SSH client
  
  # Terminal
  xterm: ^4.0.0                # Terminal emulator
  
  # State Management
  provider: ^6.1.1             # Simple state management
  
  # Storage
  shared_preferences: ^2.2.2   # Settings storage

flutter:
  uses-material-design: true
  
  fonts:
    - family: JetBrains Mono
      fonts:
        - asset: assets/fonts/JetBrainsMono-Regular.ttf
        - asset: assets/fonts/JetBrainsMono-Bold.ttf
          weight: 700
```

---

## 🎯 Key UX Improvements

| Feature | Implementation |
|---------|----------------|
| **Bottom Navigation** | Easy thumb access on mobile |
| **Floating Action Button** | Quick actions always accessible |
| **Modal Bottom Sheets** | Context menus, options, settings |
| **Pull to Refresh** | Refresh file list naturally |
| **Breadcrumb Navigation** | Easy path navigation with chips |
| **Snackbars** | Non-intrusive feedback |
| **Material You** | Dynamic color theming |
| **Simple Forms** | Clear SSH connection setup |
| **Progressive Disclosure** | Show complexity only when needed |

---

This simplified Material 3 design focuses on: 

1. **Native Android feel** - Uses standard Material components
2. **Better touch targets** - Large buttons, easy navigation
3. **Cleaner hierarchy** - Bottom nav + drawer for different use cases
4. **Less visual clutter** - Whitespace, simple icons, clear typography
5. **Faster workflows** - FAB for quick actions, bottom sheets for options

