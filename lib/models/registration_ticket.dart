import 'package:flutter/material.dart';

import 'event_item.dart';

/// Tipe peserta; menentukan faktor harga tiket.
enum ParticipantType {
  mahasiswa('Mahasiswa', Icons.school_rounded, 0.5),
  dosen('Dosen', Icons.badge_rounded, 0.75),
  umum('Umum', Icons.person_rounded, 1.0);

  const ParticipantType(this.label, this.icon, this.priceFactor);

  final String label;
  final IconData icon;
  final double priceFactor;
}

/// Paket seminar kit.
enum KitPackage {
  none('Tanpa Kit', 0, 'Tidak memesan seminar kit.'),
  regular('Reguler', 35000, 'Tas, notebook, dan pulpen.'),
  premium(
    'Premium',
    75000,
    'Tas, notebook, merchandise, dan sertifikat cetak.',
  );

  const KitPackage(this.label, this.price, this.description);

  final String label;
  final int price;
  final String description;
}

/// Tiket hasil pendaftaran seorang peserta pada satu seminar.
class RegistrationTicket {
  const RegistrationTicket({
    required this.code,
    required this.event,
    required this.name,
    required this.nim,
    required this.email,
    required this.whatsapp,
    required this.participantType,
    required this.attendanceDate,
    required this.kitPackage,
    required this.donation,
    required this.createdAt,
  });

  final String code;
  final EventItem event;
  final String name;
  final String nim;
  final String email;
  final String whatsapp;
  final ParticipantType participantType;
  final DateTime attendanceDate;
  final KitPackage kitPackage;
  final int donation;
  final DateTime createdAt;

  /// Harga tiket setelah faktor tipe peserta.
  int get ticketPrice => priceFor(event, participantType);

  /// Total yang dibayar: tiket + seminar kit + donasi.
  int get total => ticketPrice + kitPackage.price + donation;

  static int priceFor(EventItem event, ParticipantType type) {
    return (event.price * type.priceFactor).round();
  }

  /// Kode tiket unik, contoh: NEH-AI01-LX3K9Q
  static String generateCode(EventItem event, DateTime now) {
    final suffix = now.millisecondsSinceEpoch
        .toRadixString(36)
        .toUpperCase()
        .padLeft(6, '0');
    final tail = suffix.substring(suffix.length - 6);
    final eventPart = event.id.replaceAll('-', '').toUpperCase();
    return 'NEH-$eventPart-$tail';
  }
}
