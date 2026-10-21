import 'package:flutter/material.dart';

import '../models/event.dart';
import '../widgets/empty_state.dart';
import '../widgets/event_card.dart';

class EventsTab extends StatefulWidget {
  const EventsTab({
    super.key,
    required this.events,
    required this.onOpen,
    required this.onFavourite,
    required this.onAdd,
  });

  final List<Event> events;
  final ValueChanged<Event> onOpen;
  final ValueChanged<Event> onFavourite;
  final VoidCallback onAdd;

  @override
  State<EventsTab> createState() => _EventsTabState();
}

class _EventsTabState extends State<EventsTab> {
  final _search = TextEditingController();

  EventCategory? _category;
  bool _pastOnly = false;

  List<Event> get _visible {
    final query = _search.text.trim().toLowerCase();

    return widget.events.where((event) {
      final matchesSearch = event.title.toLowerCase().contains(query);

      final matchesCategory = _category == null || event.category == _category;

      final matchesPast = !_pastOnly || event.isPast;

      return matchesSearch && matchesCategory && matchesPast;
    }).toList();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _search,
              onChanged: (_) {
                setState(() {});
              },
              decoration: InputDecoration(
                labelText: 'Search events',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _search.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _search.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.clear),
                      ),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: _category == null,
                  onSelected: (_) {
                    setState(() {
                      _category = null;
                    });
                  },
                ),
                const SizedBox(width: 8),
                for (final category in EventCategory.values) ...[
                  ChoiceChip(
                    label: Text(category.label),
                    selected: _category == category,
                    onSelected: (_) {
                      setState(() {
                        _category = category;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                ],
                FilterChip(
                  label: const Text('Past'),
                  selected: _pastOnly,
                  onSelected: (value) {
                    setState(() {
                      _pastOnly = value;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: visible.isEmpty
                ? const EmptyState(
                    icon: Icons.search_off,
                    message: 'No matching events',
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth >= 600) {
                        final columns = (constraints.maxWidth / 360).ceil();

                        return GridView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: visible.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                childAspectRatio: 2.5,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                          itemBuilder: (context, index) {
                            final event = visible[index];

                            return EventCard(
                              event: event,
                              onTap: () {
                                widget.onOpen(event);
                              },
                              onFavourite: () {
                                widget.onFavourite(event);
                              },
                            );
                          },
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: visible.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final event = visible[index];

                          return EventCard(
                            event: event,
                            onTap: () {
                              widget.onOpen(event);
                            },
                            onFavourite: () {
                              widget.onFavourite(event);
                            },
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: widget.onAdd,
        child: const Icon(Icons.add),
      ),
    );
  }
}
