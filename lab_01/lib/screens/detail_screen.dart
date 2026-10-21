import 'dart:async';

import 'package:flutter/material.dart';

import '../models/event.dart';
import '../models/profile.dart';
import '../routes.dart';
import '../utils/format.dart';
import '../widgets/empty_state.dart';

class DetailArgs {
  const DetailArgs({
    required this.event,
    required this.profile,
    required this.onChanged,
    required this.onDelete,
    required this.onOpenProfile,
  });

  final Event event;
  final Profile profile;
  final ValueChanged<Event> onChanged;
  final VoidCallback onDelete;
  final VoidCallback onOpenProfile;
}

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.args});

  final DetailArgs args;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  Timer? _timer;
  late Event _event;

  @override
  void initState() {
    super.initState();

    _event = widget.args.event;

    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _countdownText(Countdown countdown) {
    return switch (countdown) {
      Upcoming(:final duration) =>
        'Starts in ${duration.inDays > 0 ? '${duration.inDays}d ' : ''}${duration.inHours % 24}h ${duration.inMinutes % 60}m',
      Started(:final duration) => 'Started ${duration.inMinutes} min ago',
      Ended() => 'Ended',
    };
  }

  Future<void> _changeRegistration() async {
    final name = widget.args.profile.name.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Add your name in Profile first'),
          action: SnackBarAction(
            label: 'Profile',
            onPressed: () {
              widget.args.onOpenProfile();
              Navigator.of(context).pop();
            },
          ),
        ),
      );
      return;
    }

    final registered = _event.contains(name);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(registered ? 'Leave event?' : 'Register for event?'),
          content: Text(
            registered
                ? 'Remove your name from this event?'
                : 'Add your name to this event?',
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
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) {
      return;
    }

    final attendees = [..._event.attendees];

    if (registered) {
      attendees.removeWhere((person) => person == name);
    } else {
      attendees.add(name);
    }

    final changed = _event.copyWith(attendees: attendees);

    setState(() {
      _event = changed;
    });

    widget.args.onChanged(changed);
  }

  Future<void> _editEvent() async {
    final result = await Navigator.of(context)
        .pushNamed<Event>(Routes.form, arguments: _event);

    if (!mounted || result == null) {
      return;
    }

    setState(() {
      _event = result;
    });

    widget.args.onChanged(result);
  }

  Future<void> _deleteEvent() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete event?'),
          content: const Text('This event will be removed from the list.'),
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
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) {
      return;
    }

    widget.args.onDelete();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final description = _event.description;
    final name = widget.args.profile.name.trim();

    final registered = name.isNotEmpty && _event.contains(name);

    final (:taken, :free) = _event.places;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Event details'),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _editEvent();
                }

                if (value == 'delete') {
                  _deleteEvent();
                }
              },
              itemBuilder: (context) {
                return const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ];
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 180,
                  child: Image.asset(
                    'assets/event_header.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return ColoredBox(
                        color: colorScheme.surfaceContainerHighest,
                        child: Center(
                          child: Icon(
                            _event.category.icon,
                            color: colorScheme.primary,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  left: 12,
                  top: 12,
                  child: Chip(
                    avatar: Icon(_event.category.icon),
                    label: Text(_event.category.label),
                  ),
                ),
                Positioned(
                  right: 12,
                  top: 12,
                  child: Chip(label: Text(_countdownText(_event.countdown))),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _event.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(formatDateTime(_event.when)),
                  const SizedBox(height: 4),
                  Text(_event.place),
                  const SizedBox(height: 4),
                  Text('$taken taken • $free free'),
                ],
              ),
            ),
            const TabBar(
              tabs: [
                Tab(text: 'About'),
                Tab(text: 'Names'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(
                        description ?? 'No additional information provided.',
                      ),
                      const SizedBox(height: 16),
                      Text(_event.online ? 'Online event' : 'In-person event'),
                    ],
                  ),
                  _event.attendees.isEmpty
                      ? const EmptyState(
                          icon: Icons.people_outline,
                          message: 'Nobody is on the list yet',
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _event.attendees.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: const Icon(Icons.person),
                              title: Text(_event.attendees[index]),
                            );
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.all(12),
          child: FilledButton(
            onPressed: _event.isFull && !registered
                ? null
                : _changeRegistration,
            child: Text(registered ? 'Leave event' : 'Register'),
          ),
        ),
      ),
    );
  }
}
