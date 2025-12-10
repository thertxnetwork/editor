import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/search_provider.dart';
import '../providers/file_provider.dart';
import '../providers/editor_provider.dart';
import '../models/file_item.dart';

/// Search panel for searching in files
class SearchPanel extends StatefulWidget {
  const SearchPanel({super.key});

  @override
  State<SearchPanel> createState() => _SearchPanelState();
}

class _SearchPanelState extends State<SearchPanel> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _replaceController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  bool _showReplace = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _replaceController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final searchProvider = context.read<SearchProvider>();
    searchProvider.setQuery(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final searchProvider = context.watch<SearchProvider>();
    final fileProvider = context.watch<FileProvider>();

    return Container(
      color: colorScheme.surfaceContainerLow,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Search input row
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Row(
              children: [
                // Expand/collapse replace
                IconButton(
                  icon: Icon(
                    _showReplace
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_right,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() => _showReplace = !_showReplace);
                  },
                  tooltip: _showReplace ? 'Hide replace' : 'Show replace',
                ),
                // Search field
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocus,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      isDense: true,
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                searchProvider.clear();
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    style: const TextStyle(fontSize: 14),
                    onSubmitted: (_) => _performSearch(),
                  ),
                ),
                const SizedBox(width: 8),
                // Search options
                _SearchOptionButton(
                  icon: Icons.text_fields,
                  tooltip: 'Match case',
                  isActive: searchProvider.options.caseSensitive,
                  onPressed: () => searchProvider.toggleCaseSensitive(),
                ),
                _SearchOptionButton(
                  icon: Icons.border_all,
                  tooltip: 'Match whole word',
                  isActive: searchProvider.options.wholeWord,
                  onPressed: () => searchProvider.toggleWholeWord(),
                ),
                _SearchOptionButton(
                  icon: Icons.code,
                  tooltip: 'Use regular expression',
                  isActive: searchProvider.options.useRegex,
                  onPressed: () => searchProvider.toggleUseRegex(),
                ),
                const SizedBox(width: 8),
                // Search button
                FilledButton.tonal(
                  onPressed: fileProvider.currentDirectory != null
                      ? _performSearch
                      : null,
                  child: const Text('Search'),
                ),
              ],
            ),
          ),
          // Replace input row
          if (_showReplace)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
              child: Row(
                children: [
                  const SizedBox(width: 40),
                  Expanded(
                    child: TextField(
                      controller: _replaceController,
                      decoration: const InputDecoration(
                        hintText: 'Replace',
                        isDense: true,
                        prefixIcon: Icon(Icons.find_replace, size: 20),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      style: const TextStyle(fontSize: 14),
                      onChanged: (value) {
                        searchProvider.setReplaceText(value);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward, size: 20),
                    tooltip: 'Replace',
                    onPressed: searchProvider.selectedResult != null
                        ? () => _replaceSelected()
                        : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.done_all, size: 20),
                    tooltip: 'Replace all',
                    onPressed: searchProvider.results.isNotEmpty
                        ? () => _replaceAll()
                        : null,
                  ),
                ],
              ),
            ),
          // Results summary
          if (searchProvider.query.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              color: colorScheme.surfaceContainerHighest,
              child: Row(
                children: [
                  if (searchProvider.isSearching)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Text(
                      '${searchProvider.resultCount} results',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  const Spacer(),
                  if (searchProvider.results.isNotEmpty) ...[
                    IconButton(
                      icon: const Icon(Icons.arrow_upward, size: 18),
                      tooltip: 'Previous match',
                      onPressed: () => searchProvider.selectPreviousResult(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_downward, size: 18),
                      tooltip: 'Next match',
                      onPressed: () => searchProvider.selectNextResult(),
                    ),
                  ],
                ],
              ),
            ),
          // Results list
          if (searchProvider.results.isNotEmpty)
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: searchProvider.results.length,
                itemBuilder: (context, index) {
                  final result = searchProvider.results[index];
                  final isSelected = index == searchProvider.selectedResultIndex;

                  return InkWell(
                    onTap: () {
                      searchProvider.selectResult(index);
                      _openResult(result.filePath, result.lineNumber);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      color: isSelected
                          ? colorScheme.primaryContainer.withOpacity(0.3)
                          : null,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.insert_drive_file_outlined,
                                size: 14,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  result.fileName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: colorScheme.primary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                'Line ${result.lineNumber}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          _buildHighlightedLine(
                            result.lineContent,
                            result.matchStart,
                            result.matchEnd,
                            colorScheme,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          const Divider(height: 1),
        ],
      ),
    );
  }

  Widget _buildHighlightedLine(
    String line,
    int matchStart,
    int matchEnd,
    ColorScheme colorScheme,
  ) {
    final trimmedLine = line.trim();
    final trimOffset = line.indexOf(trimmedLine);
    final adjustedStart = (matchStart - trimOffset).clamp(0, trimmedLine.length);
    final adjustedEnd = (matchEnd - trimOffset).clamp(0, trimmedLine.length);

    if (adjustedStart >= adjustedEnd) {
      return Text(
        trimmedLine,
        style: TextStyle(
          fontSize: 12,
          color: colorScheme.onSurfaceVariant,
          fontFamily: 'monospace',
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: TextStyle(
          fontSize: 12,
          color: colorScheme.onSurfaceVariant,
          fontFamily: 'monospace',
        ),
        children: [
          TextSpan(text: trimmedLine.substring(0, adjustedStart)),
          TextSpan(
            text: trimmedLine.substring(adjustedStart, adjustedEnd),
            style: TextStyle(
              backgroundColor: colorScheme.primaryContainer,
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w500,
            ),
          ),
          TextSpan(text: trimmedLine.substring(adjustedEnd)),
        ],
      ),
    );
  }

  void _performSearch() {
    final fileProvider = context.read<FileProvider>();
    final searchProvider = context.read<SearchProvider>();

    if (fileProvider.currentDirectory != null && _searchController.text.isNotEmpty) {
      searchProvider.searchInProject(fileProvider.currentDirectory!);
    }
  }

  void _openResult(String filePath, int lineNumber) {
    final fileProvider = context.read<FileProvider>();
    final editorProvider = context.read<EditorProvider>();

    final fileItem = FileItem(
      name: filePath.split('/').last,
      path: filePath,
      isDirectory: false,
    );

    editorProvider.openFile(fileItem, fileProvider.readFile);
    // TODO: Navigate to specific line
  }

  void _replaceSelected() {
    // TODO: Implement replace selected
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Replace functionality coming soon'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _replaceAll() {
    // TODO: Implement replace all
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Replace all functionality coming soon'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}

class _SearchOptionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool isActive;
  final VoidCallback onPressed;

  const _SearchOptionButton({
    required this.icon,
    required this.tooltip,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IconButton(
      icon: Icon(icon, size: 18),
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor:
            isActive ? colorScheme.primaryContainer : Colors.transparent,
        foregroundColor:
            isActive ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
      ),
    );
  }
}
