import 'package:flutter/material.dart';

import '../data/seed.dart';
import '../models/event.dart';
import '../models/profile.dart';
import '../routes.dart';
import '../tabs/events_tab.dart';
import '../tabs/favourites_tab.dart';
import '../tabs/profile_tab.dart';
import 'detail_screen.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _selectedIndex = 0;

  final List<Event> _events = [...seedEvents];
  Profile _profile = const Profile.empty();

  void _toggleFavourite(Event event) {
    final index = _events.indexOf(event);

    if (index == -1) {
      return;
    }

    setState(() {
      _events[index] = event.copyWith(favourite: !event.favourite);
    });
  }

  void _replaceEvent(Event oldEvent, Event newEvent) {
    final index = _events.indexOf(oldEvent);

    if (index == -1) {
      return;
    }

    setState(() {
      _events[index] = newEvent;
    });
  }

  void _deleteEvent(Event event) {
    setState(() {
      _events.remove(event);
    });
  }

  void _changeProfile(Profile profile) {
    setState(() {
      _profile = profile;
    });
  }

  Future<void> _openEvent(Event event) async {
    await Navigator.of(context).pushNamed(
      Routes.detail,
      arguments: DetailArgs(
        event: event,
        profile: _profile,
        onChanged: (changed) {
          _replaceEvent(event, changed);
          event = changed;
        },
        onDelete: () {
          _deleteEvent(event);
        },
        onOpenProfile: () {
          setState(() {
            _selectedIndex = 2;
          });
        },
      ),
    );
  }

  Future<void> _addEvent() async {
    final result = await Navigator.of(context).pushNamed<Event>(Routes.form);

    if (!mounted || result == null) {
      return;
    }

    setState(() {
      _events.add(result);
    });
  }

  void _showAbout() {
    Navigator.of(context).pop();

    showAboutDialog(
      context: context,
      applicationName: 'Campus Events',
      applicationVersion: '1.0',
      children: const [
        Text('A Flutter app for browsing and joining campus events.'),
      ],
    );
  }

  Future<void> _resetData() async {
    Navigator.of(context).pop();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset data?'),
          content: const Text(
            'Events and profile data will return to the initial state.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) {
      return;
    }

    setState(() {
      _events
        ..clear()
        ..addAll(seedEvents);

      _profile = const Profile.empty();
      _selectedIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      EventsTab(
        events: _events,
        onOpen: _openEvent,
        onFavourite: _toggleFavourite,
        onAdd: _addEvent,
      ),
      FavouritesTab(
        events: _events,
        onOpen: _openEvent,
        onFavourite: _toggleFavourite,
      ),
      ProfileTab(
        profile: _profile,
        events: _events,
        themeMode: widget.themeMode,
        onProfileChanged: _changeProfile,
        onThemeModeChanged: widget.onThemeModeChanged,
      ),
    ];

    final titles = ['Campus Events', 'Favourites', 'Profile'];

    return Scaffold(
      appBar: AppBar(title: Text(titles[_selectedIndex])),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            children: [
              const ListTile(
                leading: Icon(Icons.event),
                title: Text('Campus Events'),
                subtitle: Text('Flutter Lab 01'),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About'),
                onTap: _showAbout,
              ),
              ListTile(
                leading: const Icon(Icons.restart_alt),
                title: const Text('Reset data'),
                onTap: _resetData,
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event),
            label: 'Events',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favourites',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
