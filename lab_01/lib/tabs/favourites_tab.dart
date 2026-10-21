import 'package:flutter/material.dart';

import '../models/event.dart';
import '../widgets/empty_state.dart';
import '../widgets/event_card.dart';

class FavouritesTab extends StatelessWidget {
  const FavouritesTab({
    super.key,
    required this.events,
    required this.onOpen,
    required this.onFavourite,
  });

  final List<Event> events;
  final ValueChanged<Event> onOpen;
  final ValueChanged<Event> onFavourite;

  @override
  Widget build(BuildContext context) {
    final favourites =
    events.where((event) => event.favourite).toList();

    if (favourites.isEmpty) {
      return const EmptyState(
        icon: Icons.favorite_border,
        message: 'No favourite events',
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 600) {
          final columns = (constraints.maxWidth / 360).ceil();

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: favourites.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              childAspectRatio: 2.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final event = favourites[index];

              return EventCard(
                event: event,
                onTap: () {
                  onOpen(event);
                },
                onFavourite: () {
                  onFavourite(event);
                },
              );
            },
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: favourites.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final event = favourites[index];

            return EventCard(
              event: event,
              onTap: () {
                onOpen(event);
              },
              onFavourite: () {
                onFavourite(event);
              },
            );
          },
        );
      },
    );
  }
}