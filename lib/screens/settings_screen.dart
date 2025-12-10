import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';

/// Settings screen for app configuration
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: const _SettingsBody(),
    );
  }
}

class _SettingsBody extends StatelessWidget {
  const _SettingsBody();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: const [
        _AppearanceSection(),
        _EditorSection(),
        _FileBrowserSection(),
        _LspSection(),
        _AboutSection(),
      ],
    );
  }
}

class _SettingsSectionHeader extends StatelessWidget {
  final String title;

  const _SettingsSectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _AppearanceSection extends StatelessWidget {
  const _AppearanceSection();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SettingsSectionHeader(title: 'Appearance'),
        ListTile(
          leading: const Icon(Icons.brightness_6_outlined),
          title: const Text('Theme'),
          subtitle: Text(_themeModeLabel(settings.themeMode)),
          onTap: () => _showThemePicker(context, settings),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.color_lens_outlined),
          title: const Text('Dynamic Colors'),
          subtitle: const Text('Use system colors (Android 12+)'),
          value: settings.useDynamicColor,
          onChanged: (value) => settings.setUseDynamicColor(value),
        ),
      ],
    );
  }

  String _themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System default';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  void _showThemePicker(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ThemeMode.values.map((mode) {
            return RadioListTile<ThemeMode>(
              title: Text(_themeModeLabel(mode)),
              value: mode,
              groupValue: settings.themeMode,
              onChanged: (value) {
                if (value != null) {
                  settings.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _EditorSection extends StatelessWidget {
  const _EditorSection();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SettingsSectionHeader(title: 'Editor'),
        ListTile(
          leading: const Icon(Icons.font_download_outlined),
          title: const Text('Font Family'),
          subtitle: Text(settings.fontFamily),
          onTap: () => _showFontPicker(context, settings),
        ),
        ListTile(
          leading: const Icon(Icons.format_size_outlined),
          title: const Text('Font Size'),
          subtitle: Text('${settings.fontSize.toInt()} px'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () => settings.setFontSize(settings.fontSize - 1),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => settings.setFontSize(settings.fontSize + 1),
              ),
            ],
          ),
        ),
        ListTile(
          leading: const Icon(Icons.space_bar_outlined),
          title: const Text('Tab Size'),
          subtitle: Text('${settings.tabSize} spaces'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () => settings.setTabSize(settings.tabSize - 1),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => settings.setTabSize(settings.tabSize + 1),
              ),
            ],
          ),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.format_list_numbered_outlined),
          title: const Text('Line Numbers'),
          subtitle: const Text('Show line numbers'),
          value: settings.showLineNumbers,
          onChanged: (value) => settings.setShowLineNumbers(value),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.wrap_text_outlined),
          title: const Text('Word Wrap'),
          subtitle: const Text('Wrap long lines'),
          value: settings.wordWrap,
          onChanged: (value) => settings.setWordWrap(value),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.keyboard_tab_outlined),
          title: const Text('Insert Spaces'),
          subtitle: const Text('Use spaces instead of tabs'),
          value: settings.insertSpaces,
          onChanged: (value) => settings.setInsertSpaces(value),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.format_indent_increase_outlined),
          title: const Text('Auto Indent'),
          subtitle: const Text('Automatically indent new lines'),
          value: settings.autoIndent,
          onChanged: (value) => settings.setAutoIndent(value),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.highlight_outlined),
          title: const Text('Highlight Current Line'),
          subtitle: const Text('Highlight the active line'),
          value: settings.highlightCurrentLine,
          onChanged: (value) => settings.setHighlightCurrentLine(value),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.space_bar),
          title: const Text('Show Whitespace'),
          subtitle: const Text('Render spaces and tabs'),
          value: settings.showWhitespace,
          onChanged: (value) => settings.setShowWhitespace(value),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.code_outlined),
          title: const Text('Auto Close Brackets'),
          subtitle: const Text('Automatically insert closing brackets'),
          value: settings.autoCloseBrackets,
          onChanged: (value) => settings.setAutoCloseBrackets(value),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.html_outlined),
          title: const Text('Auto Close Tags'),
          subtitle: const Text('Automatically close HTML/XML tags'),
          value: settings.autoCloseTags,
          onChanged: (value) => settings.setAutoCloseTags(value),
        ),
      ],
    );
  }

  void _showFontPicker(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose font'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: SettingsProvider.availableFonts.length,
            itemBuilder: (context, index) {
              final font = SettingsProvider.availableFonts[index];
              return RadioListTile<String>(
                title: Text(font),
                value: font,
                groupValue: settings.fontFamily,
                onChanged: (value) {
                  if (value != null) {
                    settings.setFontFamily(value);
                    Navigator.pop(context);
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FileBrowserSection extends StatelessWidget {
  const _FileBrowserSection();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SettingsSectionHeader(title: 'File Browser'),
        SwitchListTile(
          secondary: const Icon(Icons.visibility_outlined),
          title: const Text('Show Hidden Files'),
          subtitle: const Text('Display files starting with .'),
          value: settings.showHiddenFiles,
          onChanged: (value) => settings.setShowHiddenFiles(value),
        ),
      ],
    );
  }
}

class _LspSection extends StatelessWidget {
  const _LspSection();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SettingsSectionHeader(title: 'Language Server'),
        SwitchListTile(
          secondary: const Icon(Icons.extension_outlined),
          title: const Text('Enable LSP'),
          subtitle: const Text('Language Server Protocol integration'),
          value: settings.enableLsp,
          onChanged: (value) => settings.setEnableLsp(value),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.auto_awesome_outlined),
          title: const Text('Auto Complete'),
          subtitle: const Text('Show code suggestions'),
          value: settings.enableAutoComplete,
          onChanged: settings.enableLsp
              ? (value) => settings.setEnableAutoComplete(value)
              : null,
        ),
        SwitchListTile(
          secondary: const Icon(Icons.info_outline),
          title: const Text('Hover Information'),
          subtitle: const Text('Show information on hover'),
          value: settings.enableHover,
          onChanged: settings.enableLsp
              ? (value) => settings.setEnableHover(value)
              : null,
        ),
        SwitchListTile(
          secondary: const Icon(Icons.warning_amber_outlined),
          title: const Text('Diagnostics'),
          subtitle: const Text('Show errors and warnings'),
          value: settings.enableDiagnostics,
          onChanged: settings.enableLsp
              ? (value) => settings.setEnableDiagnostics(value)
              : null,
        ),
      ],
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SettingsSectionHeader(title: 'About'),
        ListTile(
          leading: Icon(
            Icons.code_rounded,
            color: colorScheme.primary,
          ),
          title: const Text('Code Editor'),
          subtitle: const Text('Version 1.0.0'),
        ),
        ListTile(
          leading: const Icon(Icons.description_outlined),
          title: const Text('License'),
          subtitle: const Text('Apache License 2.0'),
          onTap: () => _showLicenseDialog(context),
        ),
      ],
    );
  }

  void _showLicenseDialog(BuildContext context) {
    showLicensePage(
      context: context,
      applicationName: 'Code Editor',
      applicationVersion: '1.0.0',
      applicationIcon: Padding(
        padding: const EdgeInsets.all(16),
        child: Icon(
          Icons.code_rounded,
          size: 64,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
