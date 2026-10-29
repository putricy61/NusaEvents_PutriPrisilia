import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/event_item.dart';
import '../models/registration_ticket.dart';
import '../widgets/event_card.dart';

/// Formulir pendaftaran tiket. Mengembalikan [RegistrationTicket] lewat
/// Navigator.pop bila pendaftaran berhasil.
class EventRegistrationScreen extends StatefulWidget {
  const EventRegistrationScreen({super.key, required this.event});

  final EventItem event;

  @override
  State<EventRegistrationScreen> createState() =>
      _EventRegistrationScreenState();
}

class _EventRegistrationScreenState extends State<EventRegistrationScreen> {
  static const int _maxDonation = 100000;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nimController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  ParticipantType _participantType = ParticipantType.mahasiswa;
  DateTime? _attendanceDate;
  KitPackage _kitPackage = KitPackage.none;
  double _donation = 0;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _nimController.dispose();
    _emailController.dispose();
    _whatsappController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  // ----------------------------- Validator --------------------------------

  String? _validateName(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Nama lengkap wajib diisi';
    if (text.length < 3) return 'Nama minimal 3 karakter';
    if (!RegExp(r"^[A-Za-z .'\-]+$").hasMatch(text)) {
      return 'Nama hanya boleh berisi huruf dan spasi';
    }
    return null;
  }

  String? _validateNim(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'NIM wajib diisi';
    if (!RegExp(r'^\d+$').hasMatch(text)) return 'NIM hanya boleh berisi angka';
    if (text.length < 8 || text.length > 12) return 'NIM harus 8–12 digit';
    return null;
  }

  String? _validateEmail(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Email wajib diisi';
    if (!RegExp(r'^[\w.+\-]+@([\w\-]+\.)+[A-Za-z]{2,}$').hasMatch(text)) {
      return 'Format email tidak valid (contoh: nama@kampus.ac.id)';
    }
    return null;
  }

  String? _validateWhatsapp(String? value) {
    final text = (value ?? '').replaceAll(RegExp(r'[\s\-]'), '');
    if (text.isEmpty) return 'Nomor WhatsApp wajib diisi';
    if (!RegExp(r'^(\+62|62|0)8[1-9][0-9]{7,10}$').hasMatch(text)) {
      return 'Gunakan nomor Indonesia, contoh: 081234567890';
    }
    return null;
  }

  // ------------------------------ Aksi ------------------------------------

  Future<void> _pickDate() async {
    FocusScope.of(context).unfocus();
    final event = widget.event;
    final picked = await showDatePicker(
      context: context,
      initialDate: _attendanceDate ?? event.startDate,
      firstDate: event.startDate,
      lastDate: event.endDate,
      helpText: 'Pilih tanggal kehadiran',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );
    if (picked == null || !mounted) return;
    setState(() {
      _attendanceDate = picked;
      _dateController.text = formatTanggal(picked);
    });
  }

  Future<void> _submit() async {
    if (_submitting) return;
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Periksa kembali data yang belum benar.'),
          ),
        );
      return;
    }

    setState(() => _submitting = true);
    // Simulasi proses ke server.
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final now = DateTime.now();
    final ticket = RegistrationTicket(
      code: RegistrationTicket.generateCode(widget.event, now),
      event: widget.event,
      name: _nameController.text.trim(),
      nim: _nimController.text.trim(),
      email: _emailController.text.trim(),
      whatsapp: _whatsappController.text.trim(),
      participantType: _participantType,
      attendanceDate: _attendanceDate!,
      kitPackage: _kitPackage,
      donation: _donation.round(),
      createdAt: now,
    );

    setState(() => _submitting = false);
    Navigator.of(context).pop(ticket);
  }

  InputDecoration _decoration({
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      border: const OutlineInputBorder(),
    );
  }

  // ------------------------------ Tampilan --------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final event = widget.event;

    final ticketPrice = RegistrationTicket.priceFor(event, _participantType);
    final donation = _donation.round();
    final total = ticketPrice + _kitPackage.price + donation;

    return PopScope(
      canPop: !_submitting,
      child: Scaffold(
        appBar: AppBar(title: const Text('Pendaftaran Tiket')),
        body: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _EventSummary(event: event),
                          const SizedBox(height: 20),
                          _SectionTitle('Data peserta', theme: theme),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _nameController,
                            textInputAction: TextInputAction.next,
                            textCapitalization: TextCapitalization.words,
                            autofillHints: const [AutofillHints.name],
                            decoration: _decoration(
                              label: 'Nama lengkap',
                              icon: Icons.person_rounded,
                            ),
                            validator: _validateName,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _nimController,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(12),
                            ],
                            decoration: _decoration(
                              label: 'NIM',
                              icon: Icons.badge_rounded,
                              hint: '8–12 digit angka',
                            ),
                            validator: _validateNim,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.email],
                            decoration: _decoration(
                              label: 'Email',
                              icon: Icons.email_rounded,
                              hint: 'nama@kampus.ac.id',
                            ),
                            validator: _validateEmail,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _whatsappController,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.done,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9+\- ]'),
                              ),
                              LengthLimitingTextInputFormatter(16),
                            ],
                            decoration: _decoration(
                              label: 'Nomor WhatsApp',
                              icon: Icons.chat_rounded,
                              hint: '081234567890',
                            ),
                            validator: _validateWhatsapp,
                          ),
                          const SizedBox(height: 24),
                          _SectionTitle('Tipe peserta', theme: theme),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final type in ParticipantType.values)
                                ChoiceChip(
                                  avatar: Icon(type.icon, size: 18),
                                  label: Text(type.label),
                                  selected: _participantType == type,
                                  onSelected: (_) =>
                                      setState(() => _participantType = type),
                                ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _SectionTitle('Tanggal kehadiran', theme: theme),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _dateController,
                            readOnly: true,
                            onTap: _pickDate,
                            decoration: _decoration(
                              label: 'Tanggal kehadiran',
                              icon: Icons.calendar_month_rounded,
                              hint: 'Ketuk untuk memilih tanggal',
                            ).copyWith(
                              suffixIcon: const Icon(
                                Icons.arrow_drop_down_rounded,
                              ),
                            ),
                            validator: (_) => _attendanceDate == null
                                ? 'Pilih tanggal kehadiran'
                                : null,
                          ),
                          const SizedBox(height: 24),
                          _SectionTitle('Paket seminar kit', theme: theme),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final kit in KitPackage.values)
                                ChoiceChip(
                                  label: Text(
                                    kit.price == 0
                                        ? kit.label
                                        : '${kit.label} • ${formatRupiah(kit.price)}',
                                  ),
                                  selected: _kitPackage == kit,
                                  onSelected: (_) =>
                                      setState(() => _kitPackage = kit),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _kitPackage.description,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: _SectionTitle(
                                  'Donasi (opsional)',
                                  theme: theme,
                                ),
                              ),
                              Text(
                                formatRupiah(donation),
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: scheme.primary,
                                ),
                              ),
                            ],
                          ),
                          Slider(
                            value: _donation,
                            min: 0,
                            max: _maxDonation.toDouble(),
                            divisions: 10,
                            label: formatRupiah(donation),
                            onChanged: (value) =>
                                setState(() => _donation = value),
                          ),
                          Text(
                            'Donasi digunakan untuk beasiswa pelatihan mahasiswa.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 16),
                          FormField<bool>(
                            initialValue: false,
                            validator: (value) => (value ?? false)
                                ? null
                                : 'Anda harus menyetujui tata tertib acara',
                            builder: (state) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CheckboxListTile(
                                    contentPadding: EdgeInsets.zero,
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                    value: state.value ?? false,
                                    onChanged: (value) =>
                                        state.didChange(value ?? false),
                                    title: const Text(
                                      'Saya menyetujui tata tertib acara',
                                    ),
                                    subtitle: const Text(
                                      'Hadir tepat waktu, membawa kartu '
                                      'identitas, dan menjaga ketertiban.',
                                    ),
                                  ),
                                  if (state.hasError)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 4,
                                        bottom: 4,
                                      ),
                                      child: Text(
                                        state.errorText!,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(color: scheme.error),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          _CostSummary(
                            ticketPrice: ticketPrice,
                            kitPrice: _kitPackage.price,
                            donation: donation,
                            total: total,
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: _submit,
                              icon: _submitting
                                  ? SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: scheme.onPrimary,
                                      ),
                                    )
                                  : const Icon(Icons.how_to_reg_rounded),
                              label: Text(
                                _submitting
                                    ? 'Memproses...'
                                    : 'Daftar Sekarang',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (_submitting)
              Positioned.fill(
                child: ColoredBox(
                  color: Colors.black38,
                  child: Center(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 24,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 16),
                            Text(
                              'Memproses pendaftaran...',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text, {required this.theme});

  final String text;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _EventSummary extends StatelessWidget {
  const _EventSummary({required this.event});

  final EventItem event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card.filled(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            SizedBox(
              width: 56,
              height: 56,
              child: EventPoster(event: event, iconSize: 28),
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
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${event.dateLabel} • ${event.room}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CostSummary extends StatelessWidget {
  const _CostSummary({
    required this.ticketPrice,
    required this.kitPrice,
    required this.donation,
    required this.total,
  });

  final int ticketPrice;
  final int kitPrice;
  final int donation;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget row(String label, int value, {bool bold = false}) {
      final style = bold
          ? theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)
          : theme.textTheme.bodyMedium;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Expanded(child: Text(label, style: style)),
            Text(value == 0 && !bold ? '-' : formatRupiah(value), style: style),
          ],
        ),
      );
    }

    return Card.outlined(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            row('Tiket', ticketPrice),
            row('Seminar kit', kitPrice),
            row('Donasi', donation),
            const Divider(height: 20),
            row('Total', total, bold: true),
          ],
        ),
      ),
    );
  }
}
