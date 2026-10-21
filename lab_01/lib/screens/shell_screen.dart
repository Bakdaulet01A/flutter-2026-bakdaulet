import 'package:flutter/material.dart';

import '../data/seed.dart';
import '../models/event.dart';
import '../models/profile.dart';
import '../tabs/events_tab.dart';
import '../tabs/favourites_tab.dart';
import '../tabs/profile_tab.dart';

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

  List<Event> _events = [...seedEvents];
  Profile _profile = const Profile.empty();

  void _toggleFavourite(Event event) {
    final index = _events.indexOf(event);

    if (index == -1) {
      return;
    }

    setState(() {
      _events[index] = event.copyWith(
        favourite: !event.favourite,
      );
    });
  }

  void _changeProfile(Profile profile) {
    setState(() {
      _profile = profile;
    });
  }

  void _openEvent(Event event) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Open: ${event.title}'),
      ),
    );
  }

  void _addEvent() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Event form will be added next'),
      ),
    );
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

    final titles = [
      'Campus Events',
      'Favourites',
      'Profile',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_selectedIndex]),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
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