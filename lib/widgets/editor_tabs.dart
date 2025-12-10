import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/editor_provider.dart';

/// Tab bar for open editor files
class EditorTabs extends StatelessWidget {
  const EditorTabs({super.key});

  @override
  Widget build(BuildContext context) {
    final editorProvider = context.watch<EditorProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    if (editorProvider.tabs.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 44,
      color: colorScheme.surfaceContainerLow,
      child: Row(
        children: [
          Expanded(
            child: ReorderableListView.builder(
              scrollDirection: Axis.horizontal,
              buildDefaultDragHandles: false,
              onReorder: editorProvider.reorderTabs,
              itemCount: editorProvider.tabs.length,
              proxyDecorator: (child, index, animation) {
                return Material(
                  elevation: 4,
                  color: colorScheme.surfaceContainerHighest,
                  child: child,
                );
              },
              itemBuilder: (context, index) {
                final tab = editorProvider.tabs[index];
                final isActive = index == editorProvider.activeTabIndex;

                return ReorderableDragStartListener(
                  key: ValueKey(tab.id),
                  index: index,
                  child: InkWell(
                    onTap: () => editorProvider.setActiveTab(index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: isActive
                            ? colorScheme.surfaceContainerHighest
                            : null,
                        border: Border(
                          bottom: BorderSide(
                            color: isActive
                                ? colorScheme.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // File icon
                          Icon(
                            _getLanguageIcon(tab.language),
                            size: 16,
                            color: isActive
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          // File name
                          Text(
                            tab.fileName,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight:
                                  isActive ? FontWeight.w500 : FontWeight.normal,
                              color: isActive
                                  ? colorScheme.onSurface
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                          // Modified indicator
                          if (tab.isModified) ...[
                            const SizedBox(width: 4),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                          const SizedBox(width: 8),
                          // Close button
                          _TabCloseButton(
                            onPressed: () => _handleClose(context, index),
                            isModified: tab.isModified,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // More actions menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz),
            tooltip: 'Tab actions',
            onSelected: (value) => _handleMenuAction(context, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'close_all',
                child: ListTile(
                  leading: Icon(Icons.close_outlined),
                  title: Text('Close All'),
                  dense: true,
                ),
              ),
              if (editorProvider.activeTab != null)
                const PopupMenuItem(
                  value: 'close_others',
                  child: ListTile(
                    leading: Icon(Icons.tab_unselected_outlined),
                    title: Text('Close Others'),
                    dense: true,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getLanguageIcon(String language) {
    switch (language) {
      case 'dart':
        return Icons.flutter_dash;
      case 'python':
        return Icons.code;
      case 'javascript':
      case 'typescript':
        return Icons.javascript;
      case 'java':
      case 'kotlin':
        return Icons.coffee;
      case 'html':
        return Icons.html;
      case 'css':
      case 'scss':
      case 'sass':
        return Icons.css;
      case 'json':
        return Icons.data_object;
      case 'yaml':
        return Icons.settings;
      case 'markdown':
        return Icons.description;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  void _handleClose(BuildContext context, int index) {
    final editorProvider = context.read<EditorProvider>();
    final tab = editorProvider.tabs[index];

    if (tab.isModified) {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Unsaved Changes'),
          content: Text(
            'Do you want to save changes to "${tab.fileName}" before closing?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                editorProvider.closeTab(index);
              },
              child: const Text("Don't Save"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                // Save and close
                Navigator.pop(dialogContext);
                // TODO: Implement save
                editorProvider.closeTab(index);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      );
    } else {
      editorProvider.closeTab(index);
    }
  }

  void _handleMenuAction(BuildContext context, String action) {
    final editorProvider = context.read<EditorProvider>();

    switch (action) {
      case 'close_all':
        if (editorProvider.hasUnsavedChanges) {
          _showUnsavedDialog(context, () {
            editorProvider.closeAllTabs();
          });
        } else {
          editorProvider.closeAllTabs();
        }
        break;
      case 'close_others':
        final activeIndex = editorProvider.activeTabIndex;
        if (activeIndex >= 0) {
          final hasOtherUnsaved = editorProvider.tabs
              .asMap()
              .entries
              .where((e) => e.key != activeIndex)
              .any((e) => e.value.isModified);

          if (hasOtherUnsaved) {
            _showUnsavedDialog(context, () {
              editorProvider.closeOtherTabs(activeIndex);
            });
          } else {
            editorProvider.closeOtherTabs(activeIndex);
          }
        }
        break;
    }
  }

  void _showUnsavedDialog(BuildContext context, VoidCallback onDiscard) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text(
          'Some files have unsaved changes. Do you want to discard them?',
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
              Navigator.pop(dialogContext);
              onDiscard();
            },
            child: const Text('Discard'),
          ),
        ],
      ),
    );
  }
}

class _TabCloseButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isModified;

  const _TabCloseButton({
    required this.onPressed,
    required this.isModified,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: IconButton(
        padding: EdgeInsets.zero,
        iconSize: 16,
        icon: const Icon(Icons.close),
        onPressed: onPressed,
        style: IconButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
