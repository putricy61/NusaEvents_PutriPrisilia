import 'package:flutter/material.dart';

import '../models/event_item.dart';
import '../models/registration_ticket.dart';

/// Isi tab "Tiket Terdaftar": daftar tiket aktif dengan fitur pembatalan
/// lewat geser (Dismissible) atau tombol, keduanya memakai AlertDialog.
class RegisteredTicketsScreen extends StatelessWidget {
  const RegisteredTicketsScreen({
    super.key,
    required this.tickets,
    required this.onCancel,
  });

  final List<RegistrationTicket> tickets;
  final ValueChanged<RegistrationTicket> onCancel;

  Future<bool> _confirmCancel(
    BuildContext context,
    RegistrationTicket ticket,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final scheme = Theme.of(dialogContext).colorScheme;
        return AlertDialog(
          icon: const Icon(Icons.warning_amber_rounded),
          title: const Text('Batalkan tiket?'),
          content: Text(
            'Tiket ${ticket.code} untuk "${ticket.event.title}" '
            'atas nama ${ticket.name} akan dibatalkan.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Tidak, simpan'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: scheme.error,
                foregroundColor: scheme.onError,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Ya, batalkan'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    if (tickets.isEmpty) return const _EmptyTickets();

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Geser tiket ke kiri untuk membatalkan pendaftaran.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: tickets.length,
                itemBuilder: (context, index) {
                  final ticket = tickets[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Dismissible(
                      key: ValueKey(ticket.code),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (_) => _confirmCancel(context, ticket),
                      onDismissed: (_) => onCancel(ticket),
                      background: DecoratedBox(
                        decoration: BoxDecoration(
                          color: scheme.errorContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Batalkan',
                                  style: TextStyle(
                                    color: scheme.onErrorContainer,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.delete_rounded,
                                  color: scheme.onErrorContainer,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      child: _TicketCard(
                        ticket: ticket,
                        onCancelPressed: () async {
                          final confirmed = await _confirmCancel(
                            context,
                            ticket,
                          );
                          if (confirmed && context.mounted) onCancel(ticket);
                        },
                      ),
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

class _TicketCard extends StatelessWidget {
  const _TicketCard({required this.ticket, required this.onCancelPressed});

  final RegistrationTicket ticket;
  final VoidCallback onCancelPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card.outlined(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.qr_code_2_rounded, color: scheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ticket.code,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    child: Text(
                      'Aktif',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              ticket.event.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${ticket.event.room} • ${ticket.event.time}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const Divider(height: 24),
            _InfoRow(label: 'Peserta', value: '${ticket.name} (${ticket.nim})'),
            _InfoRow(label: 'Tipe', value: ticket.participantType.label),
            _InfoRow(
              label: 'Hadir',
              value: formatTanggal(ticket.attendanceDate),
            ),
            _InfoRow(
              label: 'Seminar kit',
              value: ticket.kitPackage == KitPackage.none
                  ? ticket.kitPackage.label
                  : '${ticket.kitPackage.label} (${formatRupiah(ticket.kitPackage.price)})',
            ),
            _InfoRow(
              label: 'Donasi',
              value: ticket.donation == 0
                  ? '-'
                  : formatRupiah(ticket.donation),
            ),
            _InfoRow(
              label: 'Total',
              value: formatRupiah(ticket.total),
              emphasize: true,
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: scheme.error),
                onPressed: onCancelPressed,
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Batalkan tiket'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: emphasize
                  ? theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.primary,
                    )
                  : theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyTickets extends StatelessWidget {
  const _EmptyTickets();

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
              Icons.confirmation_number_outlined,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 12),
            Text(
              'Belum ada tiket aktif',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Pilih seminar di tab pertama lalu daftar untuk mendapatkan tiket.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
