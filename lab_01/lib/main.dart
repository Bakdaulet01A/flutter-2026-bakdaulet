import 'package:flutter/material.dart';

import 'routes.dart';
import 'screens/shell_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _changeThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final seedColor = ThemeData().colorScheme.primary;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Campus Events',
      themeMode: _themeMode,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: seedColor)),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        ),
      ),
      initialRoute: Routes.shell,
      routes: {
        Routes.shell: (context) {
          return ShellScreen(
            themeMode: _themeMode,
            onThemeModeChanged: _changeThemeMode,
          );
        },
      },
    );
  }
}
