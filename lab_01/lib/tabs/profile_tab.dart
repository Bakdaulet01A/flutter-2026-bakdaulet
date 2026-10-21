import 'package:flutter/material.dart';

import '../models/event.dart';
import '../models/profile.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({
    super.key,
    required this.profile,
    required this.events,
    required this.themeMode,
    required this.onProfileChanged,
    required this.onThemeModeChanged,
  });

  final Profile profile;
  final List<Event> events;
  final ThemeMode themeMode;
  final ValueChanged<Profile> onProfileChanged;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final _groupPattern = RegExp(r'^[A-Za-z0-9-]{2,20}$');

  late final TextEditingController _nameController;
  late final TextEditingController _groupController;

  String? _groupError;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.profile.name);

    _groupController = TextEditingController(text: widget.profile.group);
  }

  @override
  void didUpdateWidget(covariant ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.profile.name != widget.profile.name) {
      _nameController.text = widget.profile.name;
    }

    if (oldWidget.profile.group != widget.profile.group) {
      _groupController.text = widget.profile.group;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _groupController.dispose();
    super.dispose();
  }

  void _saveName(String value) {
    widget.onProfileChanged(widget.profile.copyWith(name: value.trim()));
  }

  void _saveGroup(String value) {
    final group = value.trim();

    if (group.isNotEmpty && !_groupPattern.hasMatch(group)) {
      setState(() {
        _groupError = 'Use letters, numbers and -';
      });

      return;
    }

    setState(() {
      _groupError = null;
    });

    widget.onProfileChanged(widget.profile.copyWith(group: group));
  }

  String _themeLabel(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.system => 'System',
      ThemeMode.light => 'Light',
      ThemeMode.dark => 'Dark',
    };
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.profile.name.trim();

    final joinedCount = name.isEmpty
        ? 0
        : widget.events
              .map((event) {
                final joined = event.attendees.any((person) => person == name);

                return joined ? 1 : 0;
              })
              .fold<int>(0, (count, value) => count + value);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Profile', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        TextField(
          controller: _nameController,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(),
          ),
          onSubmitted: _saveName,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _groupController,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: 'Group',
            border: const OutlineInputBorder(),
            errorText: _groupError,
          ),
          onSubmitted: _saveGroup,
        ),
        const SizedBox(height: 20),
        Text(
          'You are on $joinedCount lists',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 24),
        Text('Theme', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final mode in ThemeMode.values)
              ChoiceChip(
                label: Text(_themeLabel(mode)),
                selected: widget.themeMode == mode,
                onSelected: (_) {
                  widget.onThemeModeChanged(mode);
                },
              ),
          ],
        ),
      ],
    );
  }
}
