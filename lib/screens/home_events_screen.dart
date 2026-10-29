import 'dart:async';

import 'package:flutter/material.dart';

import '../data/sample_events.dart';
import '../models/event_item.dart';
import '../models/registration_ticket.dart';
import '../widgets/event_card.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/venue_map_viewer.dart';
import 'event_registration_screen.dart';
import 'registered_tickets_screen.dart';

/// Layar utama dengan tiga tab: seminar, galeri & denah, dan tiket.
class HomeEventsScreen extends StatefulWidget {
  const HomeEventsScreen({super.key});

  @override
  State<HomeEventsScreen> createState() => _HomeEventsScreenState();
}

class _HomeEventsScreenState extends State<HomeEventsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  /// true saat denah venue tampil; swipe antar-tab dimatikan agar geseran
  /// pada InteractiveViewer tidak berebut gestur dengan TabBarView.
  final ValueNotifier<bool> _mapActive = ValueNotifier<bool>(false);

  List<EventItem> _events = List<EventItem>.of(sampleEvents);
  final List<RegistrationTicket> _tickets = [];
  EventFilter _filter = const EventFilter();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _mapActive.dispose();
    super.dispose();
  }

  List<EventItem> get _filteredEvents {
    return _events.where((event) {
      final categoryOk =
          _filter.category == null || event.category == _filter.category;
      final availableOk = !_filter.onlyAvailable || !event.isSoldOut;
      return categoryOk && availableOk;
    }).toList();
  }

  void _adjustRegistered(String eventId, int delta) {
    _events = [
      for (final event in _events)
        if (event.id == eventId)
          event.copyWith(
            registered: (event.registered + delta)
                .clamp(0, event.quota)
                .toInt(),
          )
        else
          event,
    ];
  }

  Future<void> _openFilterSheet() async {
    final result = await showFilterBottomSheet(context, _filter);
    if (result != null && mounted) {
      setState(() => _filter = result);
    }
  }

  void _showEventDetail(EventItem event) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      constraints: const BoxConstraints(maxWidth: 640),
      builder: (sheetContext) => _EventDetailSheet(
        event: event,
        onRegister: () {
          Navigator.of(sheetContext).pop();
          _openRegistration(event);
        },
      ),
    );
  }

  Future<void> _openRegistration(EventItem event) async {
    final ticket = await Navigator.of(context).push<RegistrationTicket>(
      MaterialPageRoute(
        builder: (_) => EventRegistrationScreen(event: event),
      ),
    );
    if (ticket == null || !mounted) return;

    setState(() {
      _tickets.insert(0, ticket);
      _adjustRegistered(event.id, 1);
    });
    _tabController.animateTo(2);

    await _showRegistrationSuccessDialog(ticket);
    if (!mounted) return;
    _showTimedSnackBar(message: 'Tiket ${ticket.code} sudah aktif.');
  }

  /// Pop-up konfirmasi pendaftaran berhasil (gaya sama dengan dialog
  /// pembatalan tiket).
  Future<void> _showRegistrationSuccessDialog(RegistrationTicket ticket) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final scheme = Theme.of(dialogContext).colorScheme;
        return AlertDialog(
          scrollable: true,
          icon: Icon(
            Icons.check_circle_rounded,
            size: 40,
            color: scheme.primary,
          ),
          title: const Text('Pendaftaran berhasil!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tiket Anda sudah aktif dan siap digunakan.'),
              const SizedBox(height: 12),
              _SuccessLine(label: 'Kode', value: ticket.code),
              _SuccessLine(label: 'Seminar', value: ticket.event.title),
              _SuccessLine(
                label: 'Hadir',
                value: formatTanggal(ticket.attendanceDate),
              ),
              _SuccessLine(label: 'Total', value: formatRupiah(ticket.total)),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Lihat Tiket'),
            ),
          ],
        );
      },
    );
  }

  /// SnackBar yang dijamin tertutup sendiri setelah [duration].
  /// Flutter terbaru membuat SnackBar ber-action menetap tanpa batas
  /// (persist), sehingga penutupan dipaksa lewat Timer.
  void _showTimedSnackBar({
    required String message,
    SnackBarAction? action,
    Duration duration = const Duration(seconds: 3),
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    final controller = messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: duration,
        content: Text(message),
        action: action,
      ),
    );
    final timer = Timer(duration, controller.close);
    controller.closed.then((_) => timer.cancel());
  }

  void _cancelTicket(RegistrationTicket ticket) {
    setState(() {
      _tickets.removeWhere((t) => t.code == ticket.code);
      _adjustRegistered(ticket.event.id, -1);
    });

    _showTimedSnackBar(
      message: 'Tiket ${ticket.code} telah dibatalkan.',
      action: SnackBarAction(
        label: 'Urungkan',
        onPressed: () {
          if (!mounted) return;
          setState(() {
            _tickets.add(ticket);
            _tickets.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            _adjustRegistered(ticket.event.id, 1);
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 600;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final headerBase =
        theme.appBarTheme.backgroundColor ?? theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('NusaEvent Hub'),
        flexibleSpace: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [headerBase, Color.lerp(headerBase, Colors.white, 0.2)!],
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: narrow,
          tabAlignment: narrow ? TabAlignment.center : TabAlignment.fill,
          dividerColor: Colors.transparent,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          unselectedLabelStyle: const TextStyle(fontSize: 13),
          tabs: [
            _buildTab(Icons.event_note_rounded, 'Seminar & Workshop'),
            _buildTab(Icons.photo_library_rounded, 'Galeri & Denah Venue'),
            _buildTab(
              Icons.confirmation_number_rounded,
              'Tiket Terdaftar',
              badge: _tickets.length,
            ),
          ],
        ),
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          // Ice glass: gradasi putih-biru beku (mode terang saja).
          gradient: isDark
              ? null
              : const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFF7FBFF), Color(0xFFDCEEFA)],
                ),
        ),
        child: AnimatedBuilder(
        animation: Listenable.merge([_tabController, _mapActive]),
        builder: (context, _) {
          final lockSwipe = _mapActive.value && _tabController.index == 1;
          return TabBarView(
            controller: _tabController,
            physics: lockSwipe ? const NeverScrollableScrollPhysics() : null,
            children: [
              _SeminarTab(
                events: _filteredEvents,
                filter: _filter,
                onCategorySelected: (category) => setState(() {
                  _filter = category == null
                      ? _filter.copyWith(clearCategory: true)
                      : _filter.copyWith(category: category);
                }),
                onOpenFilter: _openFilterSheet,
                onReset: () => setState(() => _filter = const EventFilter()),
                onEventTap: _showEventDetail,
              ),
              _GalleryVenueTab(
                events: _events,
                onEventTap: _showEventDetail,
                onModeChanged: (venueMode) => _mapActive.value = venueMode,
              ),
              RegisteredTicketsScreen(
                tickets: _tickets,
                onCancel: _cancelTicket,
              ),
            ],
          );
        },
        ),
      ),
    );
  }

  /// Tab ringkas: ikon dan teks sejajar dalam satu baris.
  Tab _buildTab(IconData icon, String text, {int badge = 0}) {
    return Tab(
      height: 40,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Badge(
            isLabelVisible: badge > 0,
            label: Text('$badge'),
            child: Icon(icon, size: 18),
          ),
          const SizedBox(width: 6),
          Text(text),
        ],
      ),
    );
  }
}

class _SuccessLine extends StatelessWidget {
  const _SuccessLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 64,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 1: Seminar & Workshop
// ---------------------------------------------------------------------------

class _SeminarTab extends StatelessWidget {
  const _SeminarTab({
    required this.events,
    required this.filter,
    required this.onCategorySelected,
    required this.onOpenFilter,
    required this.onReset,
    required this.onEventTap,
  });

  final List<EventItem> events;
  final EventFilter filter;
  final ValueChanged<EventCategory?> onCategorySelected;
  final VoidCallback onOpenFilter;
  final VoidCallback onReset;
  final ValueChanged<EventItem> onEventTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: const Text('Semua'),
                              selected: filter.category == null,
                              onSelected: (_) => onCategorySelected(null),
                            ),
                          ),
                          for (final category in EventCategory.values)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                avatar: Icon(category.icon, size: 18),
                                label: Text(category.label),
                                selected: filter.category == category,
                                onSelected: (_) => onCategorySelected(category),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  IconButton.filledTonal(
                    tooltip: 'Filter lanjutan',
                    onPressed: onOpenFilter,
                    icon: Badge(
                      isLabelVisible: filter.onlyAvailable,
                      smallSize: 8,
                      child: const Icon(Icons.tune_rounded),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${events.length} seminar ditemukan',
                  style: theme.textTheme.labelLarge,
                ),
              ),
            ),
            Expanded(
              child: events.isEmpty
                  ? _EmptyFilterState(onReset: onReset)
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final event = events[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: EventCard(
                            event: event,
                            onTap: () => onEventTap(event),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyFilterState extends StatelessWidget {
  const _EmptyFilterState({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 12),
            Text(
              'Tidak ada seminar yang cocok',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Coba ubah kategori atau matikan filter kuota.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.filter_alt_off_rounded),
              label: const Text('Reset filter'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 2: Galeri & Denah Venue
// ---------------------------------------------------------------------------

enum _GalleryMode { poster, venue }

class _GalleryVenueTab extends StatefulWidget {
  const _GalleryVenueTab({
    required this.events,
    required this.onEventTap,
    required this.onModeChanged,
  });

  final List<EventItem> events;
  final ValueChanged<EventItem> onEventTap;
  final ValueChanged<bool> onModeChanged;

  @override
  State<_GalleryVenueTab> createState() => _GalleryVenueTabState();
}

class _GalleryVenueTabState extends State<_GalleryVenueTab>
    with AutomaticKeepAliveClientMixin {
  _GalleryMode _mode = _GalleryMode.poster;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: SizedBox(
                width: double.infinity,
                child: SegmentedButton<_GalleryMode>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(
                      value: _GalleryMode.poster,
                      label: Text('Galeri Poster'),
                    ),
                    ButtonSegment(
                      value: _GalleryMode.venue,
                      label: Text('Denah Venue'),
                    ),
                  ],
                  selected: {_mode},
                  onSelectionChanged: (selection) {
                    setState(() => _mode = selection.first);
                    widget.onModeChanged(_mode == _GalleryMode.venue);
                  },
                ),
              ),
            ),
            Expanded(
              child: _mode == _GalleryMode.poster
                  ? _PosterGrid(
                      events: widget.events,
                      onEventTap: widget.onEventTap,
                    )
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: VenueMapViewer(
                        events: widget.events,
                        onEventTap: widget.onEventTap,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PosterGrid extends StatelessWidget {
  const _PosterGrid({required this.events, required this.onEventTap});

  final List<EventItem> events;
  final ValueChanged<EventItem> onEventTap;

  @override
  Widget build(BuildContext context) {
    // Tinggi sel mengikuti skala teks agar judul tidak overflow.
    final textScale =
        (MediaQuery.textScalerOf(context).scale(14) / 14).clamp(1.0, 2.0);

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        mainAxisExtent: 235 + (textScale.toDouble() - 1) * 110,
      ),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return EventPosterTile(event: event, onTap: () => onEventTap(event));
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Detail seminar (bottom sheet)
// ---------------------------------------------------------------------------

class _EventDetailSheet extends StatelessWidget {
  const _EventDetailSheet({required this.event, required this.onRegister});

  final EventItem event;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 140,
              child: EventPoster(event: event, iconSize: 64, borderRadius: 16),
            ),
            const SizedBox(height: 16),
            CategoryBadge(category: event.category),
            const SizedBox(height: 8),
            Text(
              event.title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(event.speaker, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
            _DetailRow(icon: Icons.event_rounded, text: event.dateLabel),
            _DetailRow(icon: Icons.schedule_rounded, text: event.time),
            _DetailRow(icon: Icons.meeting_room_rounded, text: event.room),
            _DetailRow(
              icon: Icons.groups_rounded,
              text: event.isSoldOut
                  ? 'Kuota penuh'
                  : 'Sisa ${event.remainingQuota} dari ${event.quota} kursi',
            ),
            _DetailRow(
              icon: Icons.sell_rounded,
              text: event.isFree ? 'Gratis' : formatRupiah(event.price),
            ),
            const SizedBox(height: 12),
            Text(event.description, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: event.isSoldOut ? null : onRegister,
                icon: const Icon(Icons.confirmation_number_rounded),
                label: Text(
                  event.isSoldOut ? 'Kuota Penuh' : 'Daftar Sekarang',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
