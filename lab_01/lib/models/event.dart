// ignore_for_file: prefer_initializing_formals
import 'package:flutter/material.dart';

enum EventCategory {
  tech('Tech', Icons.computer),
  academic('Academic', Icons.school),
  sports('Sports', Icons.sports_basketball),
  social('Social', Icons.groups),
  career('Career', Icons.work),
  culture('Culture', Icons.palette);

  const EventCategory(this.label, this.icon);

  final String label;
  final IconData icon;

  Color color(ColorScheme colors) => switch (this) {
    EventCategory.tech => colors.primary,
    EventCategory.academic => colors.secondary,
    EventCategory.sports => colors.tertiary,
    EventCategory.social => colors.primaryContainer,
    EventCategory.career => colors.secondaryContainer,
    EventCategory.culture => colors.tertiaryContainer,
  };
}

sealed class Countdown {
  const Countdown();
}

class Upcoming extends Countdown {
  const Upcoming(this.duration);

  final Duration duration;
}

class Started extends Countdown {
  const Started(this.duration);

  final Duration duration;
}

class Ended extends Countdown {
  const Ended();
}

class Event {
  const Event({
    required this.title,
    required this.category,
    required this.when,
    required this.place,
    required this.limit,
    List<String> attendees = const [],
    this.online = false,
    this.description,
    this.favourite = false,
  }) : _attendees = attendees;

  Event.empty()
    : title = '',
      category = EventCategory.tech,
      when = DateTime.now().add(const Duration(days: 1)),
      place = '',
      limit = 1,
      _attendees = const [],
      online = false,
      description = null,
      favourite = false;

  final String title;
  final EventCategory category;
  final DateTime when;
  final String place;
  final int limit;
  final List<String> _attendees;
  final bool online;
  final String? description;
  final bool favourite;

  List<String> get attendees => List.unmodifiable(_attendees);

  int get count => _attendees.length;

  int get freePlaces => limit - count;

  bool get isFull => count >= limit;

  bool get isPast => when.isBefore(DateTime.now());

  bool contains(String name) => _attendees.contains(name);

  ({int taken, int free}) get places => (taken: count, free: freePlaces);

  Countdown get countdown {
    final now = DateTime.now();

    if (now.isBefore(when)) {
      return Upcoming(when.difference(now));
    }

    final elapsed = now.difference(when);

    if (elapsed.inHours < 1) {
      return Started(elapsed);
    }

    return const Ended();
  }

  Event copyWith({
    String? title,
    EventCategory? category,
    DateTime? when,
    String? place,
    int? limit,
    List<String>? attendees,
    bool? online,
    String? description,
    bool? favourite,
  }) {
    return Event(
      title: title ?? this.title,
      category: category ?? this.category,
      when: when ?? this.when,
      place: place ?? this.place,
      limit: limit ?? this.limit,
      attendees: attendees ?? _attendees,
      online: online ?? this.online,
      description: description ?? this.description,
      favourite: favourite ?? this.favourite,
    );
  }
}
