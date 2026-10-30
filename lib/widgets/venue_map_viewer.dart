import 'package:flutter/material.dart';

import '../models/event_item.dart';

class VenueRoom {
  const VenueRoom({
    required this.label,
    required this.icon,
    required this.color,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    this.hostsEvents = false,
  });

  final String label;
  final IconData icon;
  final Color color;
  final double left;
  final double top;
  final double width;
  final double height;
  final bool hostsEvents;
}

const List<VenueRoom> venueRooms = [
  VenueRoom(
    label: 'Main Hall',
    icon: Icons.groups_rounded,
    color: Color(0xFF6750A4),
    left: 0.03,
    top: 0.03,
    width: 0.44,
    height: 0.34,
    hostsEvents: true,
  ),
  VenueRoom(
    label: 'Lab IoT',
    icon: Icons.sensors_rounded,
    color: Color(0xFFE65100),
    left: 0.51,
    top: 0.03,
    width: 0.46,
    height: 0.34,
    hostsEvents: true,
  ),
  VenueRoom(
    label: 'Koridor Utama',
    icon: Icons.swap_horiz_rounded,
    color: Color(0xFF78909C),
    left: 0.03,
    top: 0.40,
    width: 0.94,
    height: 0.12,
  ),
  VenueRoom(
    label: 'Workshop Mobile',
    icon: Icons.phone_android_rounded,
    color: Color(0xFF00796B),
    left: 0.03,
    top: 0.55,
    width: 0.30,
    height: 0.25,
    hostsEvents: true,
  ),
  VenueRoom(
    label: 'Cyber Arena',
    icon: Icons.shield_rounded,
    color: Color(0xFFC62828),
    left: 0.35,
    top: 0.55,
    width: 0.30,
    height: 0.25,
    hostsEvents: true,
  ),
  VenueRoom(
    label: 'Food Court',
    icon: Icons.restaurant_rounded,
    color: Color(0xFF8D6E63),
    left: 0.67,
    top: 0.55,
    width: 0.30,
    height: 0.25,
  ),
  VenueRoom(
    label: 'Registrasi',
    icon: Icons.how_to_reg_rounded,
    color: Color(0xFF3F51B5),
    left: 0.03,
    top: 0.83,
    width: 0.44,
    height: 0.14,
  ),
  VenueRoom(
    label: 'Mushola & Toilet',
    icon: Icons.wc_rounded,
    color: Color(0xFF546E7A),
    left: 0.51,
    top: 0.83,
    width: 0.46,
    height: 0.14,
  ),
];

class VenueMapViewer extends StatefulWidget {
  const VenueMapViewer({super.key, required this.events, this.onEventTap});

  final List<EventItem> events;
  final ValueChanged<EventItem>? onEventTap;

  @override
  State<VenueMapViewer> createState() => _VenueMapViewerState();
}

class _VenueMapViewerState extends State<VenueMapViewer> {
  static const double _minScale = 0.8;
  static const double _maxScale = 5.0;
  static const double _aspectRatio = 5 / 4;

  final TransformationController _controller = TransformationController();
  VenueRoom? _selected;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _zoomBy(double factor, Size viewport) {
    final current = _controller.value.getMaxScaleOnAxis();
    final target = (current * factor).clamp(_minScale, _maxScale).toDouble();

    _controller.value = Matrix4.identity()
      ..setEntry(0, 0, target)
      ..setEntry(1, 1, target)
      ..setEntry(0, 3, viewport.width * (1 - target) / 2)
      ..setEntry(1, 3, viewport.height * (1 - target) / 2);
  }

  void _reset() {
    _controller.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewport = constraints.biggest;
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: ColoredBox(
            color: scheme.surfaceContainerHighest,
            child: Stack(
              children: [
                Positioned.fill(
                  child: InteractiveViewer(
                    transformationController: _controller,
                    minScale: _minScale,
                    maxScale: _maxScale,
                    boundaryMargin: const EdgeInsets.all(64),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: AspectRatio(
                          aspectRatio: _aspectRatio,
                          child: _MapCanvas(
                            selected: _selected,
                            onRoomTap: (room) => setState(
                              () => _selected =
                                  identical(_selected, room) ? null : room,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Column(
                    children: [
                      IconButton.filledTonal(
                        tooltip: 'Perbesar',
                        icon: const Icon(Icons.add_rounded),
                        onPressed: () => _zoomBy(1.4, viewport),
                      ),
                      const SizedBox(height: 4),
                      IconButton.filledTonal(
                        tooltip: 'Perkecil',
                        icon: const Icon(Icons.remove_rounded),
                        onPressed: () => _zoomBy(1 / 1.4, viewport),
                      ),
                      const SizedBox(height: 4),
                      IconButton.filledTonal(
                        tooltip: 'Reset tampilan',
                        icon: const Icon(Icons.restart_alt_rounded),
                        onPressed: _reset,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 8,
                  right: 8,
                  bottom: 8,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: viewport.height * 0.42,
                    ),
                    child: _InfoPanel(
                      room: _selected,
                      events: widget.events,
                      onEventTap: widget.onEventTap,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MapCanvas extends StatelessWidget {
  const _MapCanvas({required this.selected, required this.onRoomTap});

  final VenueRoom? selected;
  final ValueChanged<VenueRoom> onRoomTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        return DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: scheme.outline, width: 2),
          ),
          child: Stack(
            children: [
              for (final room in venueRooms)
                Positioned(
                  left: room.left * w,
                  top: room.top * h,
                  width: room.width * w,
                  height: room.height * h,
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: _RoomTile(
                      room: room,
                      selected: identical(selected, room),
                      onTap: () => onRoomTap(room),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _RoomTile extends StatelessWidget {
  const _RoomTile({
    required this.room,
    required this.selected,
    required this.onTap,
  });

  final VenueRoom room;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Material(
      color: room.color.withValues(alpha: selected ? 0.38 : 0.18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: room.color, width: selected ? 3 : 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(room.icon, color: room.color, size: 22),
                  const SizedBox(height: 2),
                  Text(
                    room.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({
    required this.room,
    required this.events,
    required this.onEventTap,
  });

  final VenueRoom? room;
  final List<EventItem> events;
  final ValueChanged<EventItem>? onEventTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final selected = room;

    if (selected == null) {
      return Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(Icons.touch_app_rounded, color: scheme.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Cubit untuk zoom, geser untuk menjelajah, ketuk ruangan '
                  'untuk melihat jadwal.',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final roomEvents = events.where((e) => e.room == selected.label).toList();

    return Card(
      margin: EdgeInsets.zero,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(selected.icon, color: selected.color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    selected.label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (roomEvents.isEmpty)
              Text(
                selected.hostsEvents
                    ? 'Belum ada seminar terjadwal.'
                    : 'Fasilitas pendukung (tidak ada seminar).',
                style: theme.textTheme.bodySmall,
              )
            else
              for (final event in roomEvents)
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: onEventTap == null ? null : () => onEventTap!(event),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${event.title}\n${event.dateLabel}',
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 20,
                          color: scheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
