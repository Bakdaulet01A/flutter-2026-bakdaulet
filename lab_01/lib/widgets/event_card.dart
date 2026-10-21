import 'package:flutter/material.dart';

import '../models/event.dart';
import '../utils/format.dart';

class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
    required this.onFavourite,
  });

  final Event event;
  final VoidCallback onTap;
  final VoidCallback onFavourite;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final badgeText = event.isFull
        ? 'FULL'
        : event.freePlaces <= 5
        ? '${event.freePlaces} left'
        : null;

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    backgroundColor: event.category.color(colorScheme),
                    foregroundColor: colorScheme.onPrimary,
                    child: Icon(event.category.icon),
                  ),
                  if (badgeText != null)
                    Positioned(
                      right: -20,
                      top: -10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.error,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          badgeText,
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onError,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatDateTime(event.when),
                      style: textTheme.bodySmall,
                    ),
                    Text(
                      event.place,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onFavourite,
                icon: Icon(
                  event.favourite
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}