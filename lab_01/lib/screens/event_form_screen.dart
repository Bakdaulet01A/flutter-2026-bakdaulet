import 'package:flutter/material.dart';

import '../models/event.dart';
import '../utils/format.dart';

class EventFormScreen extends StatefulWidget {
  const EventFormScreen({super.key, this.event});

  final Event? event;

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _placeController;
  late final TextEditingController _limitController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _dateController;
  late final TextEditingController _timeController;

  final _titleFocus = FocusNode();
  final _placeFocus = FocusNode();
  final _limitFocus = FocusNode();
  final _descriptionFocus = FocusNode();

  EventCategory? _category;
  late DateTime _when;
  bool _online = false;
  bool _saving = false;
  bool _allowPop = false;

  late String _initialTitle;
  late String _initialPlace;
  late String _initialLimit;
  late String _initialDescription;
  late EventCategory? _initialCategory;
  late DateTime _initialWhen;
  late bool _initialOnline;

  bool get _isEditing => widget.event != null;

  bool get _isDirty {
    return _titleController.text != _initialTitle ||
        _placeController.text != _initialPlace ||
        _limitController.text != _initialLimit ||
        _descriptionController.text != _initialDescription ||
        _category != _initialCategory ||
        _when != _initialWhen ||
        _online != _initialOnline;
  }

  @override
  void initState() {
    super.initState();

    final event = widget.event;

    _titleController = TextEditingController(text: event?.title ?? '');

    _placeController = TextEditingController(text: event?.place ?? '');

    _limitController = TextEditingController(
      text: event?.limit.toString() ?? '',
    );

    _descriptionController = TextEditingController(
      text: event?.description ?? '',
    );

    _category = event?.category;
    _when = event?.when ?? DateTime.now().add(const Duration(days: 1));
    _online = event?.online ?? false;

    _dateController = TextEditingController();
    _timeController = TextEditingController();

    _updateDateTimeText();

    _initialTitle = _titleController.text;
    _initialPlace = _placeController.text;
    _initialLimit = _limitController.text;
    _initialDescription = _descriptionController.text;
    _initialCategory = _category;
    _initialWhen = _when;
    _initialOnline = _online;

    _titleController.addListener(_refresh);
    _placeController.addListener(_refresh);
    _limitController.addListener(_refresh);
    _descriptionController.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  void _updateDateTimeText() {
    _dateController.text =
        '${_when.day.toString().padLeft(2, '0')}.'
        '${_when.month.toString().padLeft(2, '0')}.'
        '${_when.year}';

    _timeController.text =
        '${_when.hour.toString().padLeft(2, '0')}:'
        '${_when.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _placeController.dispose();
    _limitController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    _timeController.dispose();

    _titleFocus.dispose();
    _placeFocus.dispose();
    _limitFocus.dispose();
    _descriptionFocus.dispose();

    super.dispose();
  }

  Future<void> _pickDate() async {
    final today = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: _when,
      firstDate: _isEditing ? DateTime(2000) : today,
      lastDate: DateTime(2100),
    );

    if (!mounted || date == null) {
      return;
    }

    setState(() {
      _when = DateTime(
        date.year,
        date.month,
        date.day,
        _when.hour,
        _when.minute,
      );

      _updateDateTimeText();
    });
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_when),
    );

    if (!mounted || time == null) {
      return;
    }

    setState(() {
      _when = DateTime(
        _when.year,
        _when.month,
        _when.day,
        time.hour,
        time.minute,
      );

      _updateDateTimeText();
    });
  }

  String? _validatePlace(String? value) {
    final place = value?.trim() ?? '';

    if (place.isEmpty) {
      return _online ? 'Enter meeting link' : 'Enter event place';
    }

    if (_online) {
      final uri = Uri.tryParse(place);

      if (uri == null ||
          !uri.hasScheme ||
          (uri.scheme != 'http' && uri.scheme != 'https') ||
          uri.host.isEmpty) {
        return 'Enter a valid http/https link';
      }
    }

    return null;
  }

  String? _validateLimit(String? value) {
    final limit = int.tryParse(value ?? '');

    if (limit == null || limit < 1 || limit > 500) {
      return 'Limit must be from 1 to 500';
    }

    final event = widget.event;

    if (event != null && limit < event.count) {
      return 'Limit cannot be below ${event.count}';
    }

    return null;
  }

  Future<bool> _confirmDiscard() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Discard changes?'),
          content: const Text('Your unsaved changes will be lost.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Stay'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Discard'),
            ),
          ],
        );
      },
    );

    return result == true;
  }

  Future<void> _save() async {
    if (_saving) {
      return;
    }

    final valid = _formKey.currentState?.validate() ?? false;

    if (!valid) {
      return;
    }

    final category = _category;

    if (category == null) {
      return;
    }

    if (!_isEditing && !_when.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose a future date and time')),
      );
      return;
    }

    final limit = int.tryParse(_limitController.text);

    if (limit == null) {
      return;
    }

    setState(() {
      _saving = true;
    });

    await Future<void>.delayed(const Duration(seconds: 1));

    if (!mounted) {
      return;
    }

    final oldEvent = widget.event;
    final description = _descriptionController.text.trim();

    final result = Event(
      title: _titleController.text.trim(),
      category: category,
      when: _when,
      place: _placeController.text.trim(),
      limit: limit,
      attendees: oldEvent?.attendees ?? const [],
      online: _online,
      description: description.isEmpty ? null : description,
      favourite: oldEvent?.favourite ?? false,
    );

    _allowPop = true;

    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _allowPop || !_isDirty,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop || !_isDirty) {
          return;
        }

        final discard = await _confirmDiscard();

        if (!context.mounted || !discard) {
          return;
        }

        setState(() {
          _allowPop = true;
        });

        Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(_isEditing ? 'Edit event' : 'Add event')),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _titleController,
                focusNode: _titleFocus,
                maxLength: 60,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final title = value?.trim() ?? '';

                  if (title.length < 3 || title.length > 60) {
                    return 'Title must contain 3–60 characters';
                  }

                  return null;
                },
                onFieldSubmitted: (_) {
                  _placeFocus.requestFocus();
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<EventCategory>(
                initialValue: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final category in EventCategory.values)
                    DropdownMenuItem(
                      value: category,
                      child: Text(category.label),
                    ),
                ],
                onChanged: _saving
                    ? null
                    : (value) {
                        setState(() {
                          _category = value;
                        });
                      },
                validator: (value) {
                  if (value == null) {
                    return 'Choose a category';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Online event'),
                subtitle: Text(
                  _online
                      ? 'Place field must contain a link'
                      : 'Place field must contain a location',
                ),
                value: _online,
                onChanged: _saving
                    ? null
                    : (value) {
                        setState(() {
                          _online = value;
                        });
                      },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _placeController,
                focusNode: _placeFocus,
                enabled: !_saving,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: _online ? 'Meeting link' : 'Place',
                  border: const OutlineInputBorder(),
                ),
                validator: _validatePlace,
                onFieldSubmitted: (_) {
                  _limitFocus.requestFocus();
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _limitController,
                focusNode: _limitFocus,
                enabled: !_saving,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Participant limit',
                  border: OutlineInputBorder(),
                ),
                validator: _validateLimit,
                onFieldSubmitted: (_) {
                  _descriptionFocus.requestFocus();
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dateController,
                readOnly: true,
                enabled: !_saving,
                decoration: const InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: _pickDate,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _timeController,
                readOnly: true,
                enabled: !_saving,
                decoration: const InputDecoration(
                  labelText: 'Time',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.access_time),
                ),
                onTap: _pickTime,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                focusNode: _descriptionFocus,
                enabled: !_saving,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Text('Selected: ${formatDateTime(_when)}'),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(),
                      )
                    : Text(_isEditing ? 'Save changes' : 'Create event'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
