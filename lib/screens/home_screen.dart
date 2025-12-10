import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/file_provider.dart';
import '../providers/editor_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/file_tree.dart';
import '../widgets/editor_tabs.dart';
import '../widgets/code_editor.dart';
import '../widgets/search_panel.dart';
import 'settings_screen.dart';

/// Main home screen with file browser and editor
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showFileTree = true;
  bool _showSearchPanel = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final fileProvider = context.watch<FileProvider>();
    final editorProvider = context.watch<EditorProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          fileProvider.currentDirectory != null
              ? _getDirectoryName(fileProvider.currentDirectory!)
              : 'Code Editor',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        actions: [
          // Search toggle
          IconButton(
            icon: Icon(
              _showSearchPanel ? Icons.search_off : Icons.search,
              color: _showSearchPanel ? colorScheme.primary : null,
            ),
            tooltip: 'Search',
            onPressed: () {
              setState(() => _showSearchPanel = !_showSearchPanel);
            },
          ),
          // Open folder
          IconButton(
            icon: const Icon(Icons.folder_open_outlined),
            tooltip: 'Open Folder',
            onPressed: () => fileProvider.openDirectory(),
          ),
          // Settings
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: _buildDrawer(context),
      body: _buildBody(context, fileProvider, editorProvider),
      floatingActionButton: _buildFAB(context, fileProvider),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final fileProvider = context.watch<FileProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Drawer header
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.code,
                    size: 32,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Code Editor',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            const Divider(),
            // Menu items
            ListTile(
              leading: const Icon(Icons.folder_open_outlined),
              title: const Text('Open Folder'),
              onTap: () {
                Navigator.pop(context);
                fileProvider.openDirectory();
              },
            ),
            ListTile(
              leading: const Icon(Icons.create_new_folder_outlined),
              title: const Text('New Folder'),
              enabled: fileProvider.currentDirectory != null,
              onTap: fileProvider.currentDirectory != null
                  ? () {
                      Navigator.pop(context);
                      _showCreateFolderDialog(context);
                    }
                  : null,
            ),
            ListTile(
              leading: const Icon(Icons.note_add_outlined),
              title: const Text('New File'),
              enabled: fileProvider.currentDirectory != null,
              onTap: fileProvider.currentDirectory != null
                  ? () {
                      Navigator.pop(context);
                      _showCreateFileDialog(context);
                    }
                  : null,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.refresh_outlined),
              title: const Text('Refresh'),
              enabled: fileProvider.currentDirectory != null,
              onTap: fileProvider.currentDirectory != null
                  ? () {
                      Navigator.pop(context);
                      fileProvider.refresh();
                    }
                  : null,
            ),
            ListTile(
              leading: const Icon(Icons.close_outlined),
              title: const Text('Close Project'),
              enabled: fileProvider.currentDirectory != null,
              onTap: fileProvider.currentDirectory != null
                  ? () {
                      Navigator.pop(context);
                      fileProvider.closeProject();
                      context.read<EditorProvider>().closeAllTabs();
                    }
                  : null,
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    FileProvider fileProvider,
    EditorProvider editorProvider,
  ) {
    if (fileProvider.currentDirectory == null) {
      return _buildWelcomeView(context);
    }

    return Column(
      children: [
        // Search panel
        if (_showSearchPanel) const SearchPanel(),
        // Main content
        Expanded(
          child: Row(
            children: [
              // File tree
              if (_showFileTree)
                SizedBox(
                  width: 280,
                  child: Column(
                    children: [
                      // File tree header
                      Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left),
                              tooltip: 'Hide File Tree',
                              onPressed: () {
                                setState(() => _showFileTree = false);
                              },
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Explorer',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.refresh, size: 20),
                              tooltip: 'Refresh',
                              onPressed: () => fileProvider.refresh(),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      // File tree
                      const Expanded(child: FileTree()),
                    ],
                  ),
                ),
              // Divider
              if (_showFileTree)
                Container(
                  width: 1,
                  color: Theme.of(context).dividerColor,
                ),
              // Editor area
              Expanded(
                child: Column(
                  children: [
                    // Show file tree button when hidden
                    if (!_showFileTree)
                      Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              tooltip: 'Show File Tree',
                              onPressed: () {
                                setState(() => _showFileTree = true);
                              },
                            ),
                          ],
                        ),
                      ),
                    // Tabs
                    if (editorProvider.tabs.isNotEmpty) const EditorTabs(),
                    // Editor
                    const Expanded(child: CodeEditor()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeView(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final fileProvider = context.read<FileProvider>();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.code_rounded,
              size: 96,
              color: colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome to Code Editor',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Open a folder to start editing',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              icon: const Icon(Icons.folder_open_outlined),
              label: const Text('Open Folder'),
              onPressed: () => fileProvider.openDirectory(),
            ),
            const SizedBox(height: 48),
            // Feature cards
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                _buildFeatureCard(
                  context,
                  Icons.palette_outlined,
                  'Material Design 3',
                  'Beautiful, adaptive UI',
                ),
                _buildFeatureCard(
                  context,
                  Icons.highlight_outlined,
                  'Syntax Highlighting',
                  '50+ languages',
                ),
                _buildFeatureCard(
                  context,
                  Icons.auto_fix_high_outlined,
                  'LSP Support',
                  'Intelligent code assistance',
                ),
                _buildFeatureCard(
                  context,
                  Icons.search_outlined,
                  'Powerful Search',
                  'Find in files & project',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildFAB(BuildContext context, FileProvider fileProvider) {
    if (fileProvider.currentDirectory == null) return null;

    return FloatingActionButton(
      onPressed: () => _showCreateFileDialog(context),
      tooltip: 'New File',
      child: const Icon(Icons.add),
    );
  }

  String _getDirectoryName(String path) {
    final parts = path.split('/');
    return parts.isNotEmpty ? parts.last : path;
  }

  void _showCreateFileDialog(BuildContext context) {
    final controller = TextEditingController();
    final fileProvider = context.read<FileProvider>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New File'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'filename.txt',
            labelText: 'File name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                fileProvider.createFile(
                  fileProvider.currentDirectory!,
                  controller.text.trim(),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showCreateFolderDialog(BuildContext context) {
    final controller = TextEditingController();
    final fileProvider = context.read<FileProvider>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Folder'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'folder_name',
            labelText: 'Folder name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                fileProvider.createDirectory(
                  fileProvider.currentDirectory!,
                  controller.text.trim(),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
