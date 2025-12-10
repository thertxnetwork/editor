import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/file_item.dart';
import '../providers/file_provider.dart';
import '../providers/editor_provider.dart';

/// File tree widget for browsing project files
class FileTree extends StatelessWidget {
  const FileTree({super.key});

  @override
  Widget build(BuildContext context) {
    final fileProvider = context.watch<FileProvider>();

    if (fileProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (fileProvider.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                fileProvider.error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: () => fileProvider.refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (fileProvider.files.isEmpty) {
      return Center(
        child: Text(
          'Empty folder',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: fileProvider.files.length,
      itemBuilder: (context, index) {
        return _FileTreeItem(
          item: fileProvider.files[index],
          depth: 0,
        );
      },
    );
  }
}

class _FileTreeItem extends StatelessWidget {
  final FileItem item;
  final int depth;

  const _FileTreeItem({
    required this.item,
    required this.depth,
  });

  @override
  Widget build(BuildContext context) {
    final fileProvider = context.watch<FileProvider>();
    final editorProvider = context.read<EditorProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    final isExpanded = fileProvider.isExpanded(item.path);
    final indent = EdgeInsets.only(left: 16.0 + (depth * 16.0));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            if (item.isDirectory) {
              fileProvider.toggleDirectory(item.path);
            } else {
              editorProvider.openFile(
                item,
                fileProvider.readFile,
              );
            }
          },
          onLongPress: () => _showContextMenu(context),
          child: Container(
            padding: indent,
            height: 36,
            child: Row(
              children: [
                if (item.isDirectory)
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_right,
                    size: 20,
                    color: colorScheme.onSurfaceVariant,
                  )
                else
                  const SizedBox(width: 20),
                const SizedBox(width: 4),
                Icon(
                  _getFileIcon(),
                  size: 18,
                  color: _getIconColor(colorScheme),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.name,
                    style: Theme.of(context).textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (item.isDirectory && isExpanded && item.children != null)
          ...item.children!.map((child) => _FileTreeItem(
                item: child,
                depth: depth + 1,
              )),
      ],
    );
  }

  IconData _getFileIcon() {
    if (item.isDirectory) {
      return Icons.folder_outlined;
    }

    switch (item.extension) {
      case 'dart':
        return Icons.flutter_dash;
      case 'py':
        return Icons.code;
      case 'js':
      case 'ts':
      case 'jsx':
      case 'tsx':
        return Icons.javascript;
      case 'java':
      case 'kt':
        return Icons.coffee;
      case 'html':
      case 'htm':
        return Icons.html;
      case 'css':
      case 'scss':
      case 'sass':
        return Icons.css;
      case 'json':
        return Icons.data_object;
      case 'yaml':
      case 'yml':
        return Icons.settings;
      case 'md':
      case 'markdown':
        return Icons.description;
      case 'xml':
        return Icons.code;
      case 'sql':
        return Icons.storage;
      case 'sh':
      case 'bash':
        return Icons.terminal;
      case 'png':
      case 'jpg':
      case 'jpeg':
      case 'gif':
      case 'svg':
        return Icons.image;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  Color _getIconColor(ColorScheme colorScheme) {
    if (item.isDirectory) {
      return colorScheme.primary;
    }

    switch (item.extension) {
      case 'dart':
        return const Color(0xFF02569B);
      case 'py':
        return const Color(0xFF3776AB);
      case 'js':
        return const Color(0xFFF7DF1E);
      case 'ts':
      case 'tsx':
        return const Color(0xFF3178C6);
      case 'java':
        return const Color(0xFFB07219);
      case 'kt':
        return const Color(0xFFA97BFF);
      case 'html':
        return const Color(0xFFE34F26);
      case 'css':
      case 'scss':
      case 'sass':
        return const Color(0xFF1572B6);
      case 'json':
        return const Color(0xFF5B5B5B);
      case 'yaml':
      case 'yml':
        return const Color(0xFFCB171E);
      case 'md':
      case 'markdown':
        return colorScheme.onSurfaceVariant;
      default:
        return colorScheme.onSurfaceVariant;
    }
  }

  void _showContextMenu(BuildContext context) {
    final fileProvider = context.read<FileProvider>();
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset offset = box.localToGlobal(Offset.zero);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy,
        offset.dx + box.size.width,
        offset.dy + box.size.height,
      ),
      items: [
        if (!item.isDirectory)
          PopupMenuItem(
            child: const ListTile(
              leading: Icon(Icons.edit_outlined),
              title: Text('Open'),
              dense: true,
            ),
            onTap: () {
              final editorProvider = context.read<EditorProvider>();
              editorProvider.openFile(item, fileProvider.readFile);
            },
          ),
        PopupMenuItem(
          child: const ListTile(
            leading: Icon(Icons.drive_file_rename_outline),
            title: Text('Rename'),
            dense: true,
          ),
          onTap: () => _showRenameDialog(context),
        ),
        PopupMenuItem(
          child: ListTile(
            leading: Icon(
              Icons.delete_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              'Delete',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            dense: true,
          ),
          onTap: () => _showDeleteDialog(context),
        ),
        if (item.isDirectory) ...[
          const PopupMenuDivider(),
          PopupMenuItem(
            child: const ListTile(
              leading: Icon(Icons.create_new_folder_outlined),
              title: Text('New Folder'),
              dense: true,
            ),
            onTap: () => _showCreateFolderDialog(context),
          ),
          PopupMenuItem(
            child: const ListTile(
              leading: Icon(Icons.note_add_outlined),
              title: Text('New File'),
              dense: true,
            ),
            onTap: () => _showCreateFileDialog(context),
          ),
        ],
      ],
    );
  }

  void _showRenameDialog(BuildContext context) {
    final controller = TextEditingController(text: item.name);
    final fileProvider = context.read<FileProvider>();

    // Delay to avoid context issues after menu closes
    Future.microtask(() {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Rename'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'New name',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  fileProvider.rename(item.path, controller.text.trim());
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Rename'),
            ),
          ],
        ),
      );
    });
  }

  void _showDeleteDialog(BuildContext context) {
    final fileProvider = context.read<FileProvider>();

    Future.microtask(() {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Delete'),
          content: Text(
            'Are you sure you want to delete "${item.name}"?${item.isDirectory ? '\n\nThis will delete all contents inside.' : ''}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(dialogContext).colorScheme.error,
              ),
              onPressed: () {
                fileProvider.delete(item.path);
                Navigator.pop(dialogContext);
              },
              child: const Text('Delete'),
            ),
          ],
        ),
      );
    });
  }

  void _showCreateFolderDialog(BuildContext context) {
    final controller = TextEditingController();
    final fileProvider = context.read<FileProvider>();

    Future.microtask(() {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
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
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  fileProvider.createDirectory(
                      item.path, controller.text.trim());
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      );
    });
  }

  void _showCreateFileDialog(BuildContext context) {
    final controller = TextEditingController();
    final fileProvider = context.read<FileProvider>();

    Future.microtask(() {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
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
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  fileProvider.createFile(item.path, controller.text.trim());
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      );
    });
  }
}
