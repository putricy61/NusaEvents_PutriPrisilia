import 'package:flutter/material.dart';

import '../models/event_item.dart';


class EventFilter {
  const EventFilter({this.category, this.onlyAvailable = false});


  final EventCategory? category;

  final bool onlyAvailable;

  bool get isActive => category != null || onlyAvailable;

  EventFilter copyWith({
    EventCategory? category,
    bool clearCategory = false,
    bool? onlyAvailable,
  }) {
    return EventFilter(
      category: clearCategory ? null : (category ?? this.category),
      onlyAvailable: onlyAvailable ?? this.onlyAvailable,
    );
  }
}

Future<EventFilter?> showFilterBottomSheet(
  BuildContext context,
  EventFilter current,
) {
  return showModalBottomSheet<EventFilter>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    constraints: const BoxConstraints(maxWidth: 560),
    builder: (sheetContext) => FilterBottomSheet(initial: current),
  );
}

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key, required this.initial});

  final EventFilter initial;

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late EventFilter _draft = widget.initial;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Seminar',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Text('Kategori', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Semua'),
                  selected: _draft.category == null,
                  onSelected: (_) => setState(
                    () => _draft = _draft.copyWith(clearCategory: true),
                  ),
                ),
                for (final category in EventCategory.values)
                  ChoiceChip(
                    avatar: Icon(category.icon, size: 18),
                    label: Text(category.label),
                    selected: _draft.category == category,
                    onSelected: (_) => setState(
                      () => _draft = _draft.copyWith(category: category),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Hanya yang masih ada kuota'),
              subtitle: const Text('Sembunyikan seminar yang sudah penuh'),
              value: _draft.onlyAvailable,
              onChanged: (value) => setState(
                () => _draft = _draft.copyWith(onlyAvailable: value),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        Navigator.of(context).pop(const EventFilter()),
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(_draft),
                    child: const Text('Terapkan'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
