import 'package:flutter/material.dart';

/// Kategori seminar yang dipakai pada filter dan label kartu.
enum EventCategory {
  ai('AI', Icons.psychology_alt_rounded, Color(0xFF6750A4)),
  mobile('Mobile', Icons.phone_android_rounded, Color(0xFF00796B)),
  iot('IoT', Icons.sensors_rounded, Color(0xFFE65100)),
  cybersecurity('Cybersecurity', Icons.shield_rounded, Color(0xFFC62828));

  const EventCategory(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;
}

/// Data satu seminar / workshop.
class EventItem {
  const EventItem({
    required this.id,
    required this.title,
    required this.speaker,
    required this.category,
    required this.startDate,
    required this.endDate,
    required this.time,
    required this.room,
    required this.description,
    required this.price,
    required this.quota,
    required this.registered,
  });

  final String id;
  final String title;
  final String speaker;
  final EventCategory category;
  final DateTime startDate;
  final DateTime endDate;
  final String time;

  /// Nama ruangan; harus sama dengan label ruangan pada denah venue.
  final String room;
  final String description;

  /// Harga dasar tiket dalam rupiah (0 = gratis).
  final int price;
  final int quota;
  final int registered;

  int get remainingQuota => quota - registered;
  bool get isFree => price == 0;
  bool get isSoldOut => remainingQuota <= 0;
  bool get isMultiDay =>
      startDate.year != endDate.year ||
      startDate.month != endDate.month ||
      startDate.day != endDate.day;

  String get dateLabel => isMultiDay
      ? '${formatTanggal(startDate)} – ${formatTanggal(endDate)}'
      : formatTanggal(startDate);

  EventItem copyWith({int? registered}) {
    return EventItem(
      id: id,
      title: title,
      speaker: speaker,
      category: category,
      startDate: startDate,
      endDate: endDate,
      time: time,
      room: room,
      description: description,
      price: price,
      quota: quota,
      registered: registered ?? this.registered,
    );
  }
}

const List<String> _namaBulan = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

/// Contoh: 14 Nov 2026
String formatTanggal(DateTime date) {
  return '${date.day} ${_namaBulan[date.month - 1]} ${date.year}';
}

/// Contoh: Rp 35.000
String formatRupiah(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  final sign = value < 0 ? '-' : '';
  return '${sign}Rp $buffer';
}
