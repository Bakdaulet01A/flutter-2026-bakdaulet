import 'package:flutter/material.dart';

import 'models/event.dart';
import 'routes.dart';
import 'screens/detail_screen.dart';
import 'screens/event_form_screen.dart';
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
      onGenerateRoute: (settings) {
        if (settings.name == Routes.detail) {
          final args = settings.arguments as DetailArgs;

          return MaterialPageRoute(
            builder: (context) {
              return DetailScreen(args: args);
            },
          );
        }

        if (settings.name == Routes.form) {
          final event = settings.arguments as Event?;

          return MaterialPageRoute<Event?>(
            builder: (context) {
              return EventFormScreen(event: event);
            },
          );
        }

        return null;
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) {
            return const Scaffold(body: Center(child: Text('Not found')));
          },
        );
      },
    );
  }
}
