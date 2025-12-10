import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dynamic_color/dynamic_color.dart';

import 'providers/editor_provider.dart';
import 'providers/file_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/search_provider.dart';
import 'screens/home_screen.dart';
import 'utils/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CodeEditorApp());
}

/// Main application widget with Material Design 3 theming
class CodeEditorApp extends StatelessWidget {
  const CodeEditorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => FileProvider()),
        ChangeNotifierProvider(create: (_) => EditorProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return DynamicColorBuilder(
            builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
              return MaterialApp(
                title: 'Code Editor',
                debugShowCheckedModeBanner: false,
                themeMode: settings.themeMode,
                theme: AppTheme.lightTheme(lightDynamic),
                darkTheme: AppTheme.darkTheme(darkDynamic),
                home: const HomeScreen(),
              );
            },
          );
        },
      ),
    );
  }
}
