import '../models/event_item.dart';

/// Data contoh seminar. Nama `room` harus sama dengan label ruangan pada
/// denah venue (lihat widgets/venue_map_viewer.dart).
final List<EventItem> sampleEvents = [
  EventItem(
    id: 'ai-01',
    title: 'Generative AI untuk Produktivitas Kampus',
    speaker: 'Dr. Rani Kusumawardhani, M.Kom.',
    category: EventCategory.ai,
    startDate: DateTime(2026, 11, 14),
    endDate: DateTime(2026, 11, 14),
    time: '09:00 – 12:00 WIB',
    room: 'Main Hall',
    description:
        'Pelajari cara memanfaatkan large language model untuk merangkum '
        'jurnal, menyusun laporan, dan mengotomasi tugas administratif '
        'dengan tetap menjaga etika akademik.',
    price: 50000,
    quota: 150,
    registered: 112,
  ),
  EventItem(
    id: 'ai-02',
    title: 'Workshop Computer Vision dengan TensorFlow Lite',
    speaker: 'Bima Prakoso, M.T.',
    category: EventCategory.ai,
    startDate: DateTime(2026, 11, 21),
    endDate: DateTime(2026, 11, 21),
    time: '13:00 – 17:00 WIB',
    room: 'Main Hall',
    description:
        'Latih model klasifikasi gambar sederhana lalu jalankan di '
        'perangkat mobile. Peserta membawa laptop dengan Python terpasang.',
    price: 90000,
    quota: 80,
    registered: 63,
  ),
  EventItem(
    id: 'mob-01',
    title: 'Flutter Production Ready: dari Prototype ke Play Store',
    speaker: 'Aditya Nugraha',
    category: EventCategory.mobile,
    startDate: DateTime(2026, 11, 15),
    endDate: DateTime(2026, 11, 16),
    time: '08:30 – 16:00 WIB',
    room: 'Workshop Mobile',
    description:
        'Dua hari intensif: arsitektur proyek, state management, '
        'pengujian, hingga proses rilis ke Google Play. Peserta memilih '
        'salah satu hari kehadiran.',
    price: 75000,
    quota: 60,
    registered: 41,
  ),
  EventItem(
    id: 'mob-02',
    title: 'UI/UX Material 3 untuk Aplikasi Mobile',
    speaker: 'Salsabila Putri, S.Ds.',
    category: EventCategory.mobile,
    startDate: DateTime(2026, 11, 22),
    endDate: DateTime(2026, 11, 22),
    time: '10:00 – 12:30 WIB',
    room: 'Workshop Mobile',
    description:
        'Mengenal design token, dynamic color, dan komponen Material 3 '
        'serta cara menerapkannya secara konsisten di Flutter.',
    price: 0,
    quota: 60,
    registered: 57,
  ),
  EventItem(
    id: 'iot-01',
    title: 'Smart Farming dengan ESP32 dan MQTT',
    speaker: 'Ir. Hendra Wijaya, M.Eng.',
    category: EventCategory.iot,
    startDate: DateTime(2026, 11, 28),
    endDate: DateTime(2026, 11, 28),
    time: '09:00 – 15:00 WIB',
    room: 'Lab IoT',
    description:
        'Rangkai sensor kelembapan tanah, kirim data lewat MQTT, dan '
        'tampilkan di dashboard real-time. Kit praktik disediakan panitia.',
    price: 100000,
    quota: 40,
    registered: 31,
  ),
  EventItem(
    id: 'iot-02',
    title: 'Edge AI & TinyML untuk Sensor Pintar',
    speaker: 'Dr. Maya Anggraini',
    category: EventCategory.iot,
    startDate: DateTime(2026, 12, 5),
    endDate: DateTime(2026, 12, 5),
    time: '13:00 – 16:30 WIB',
    room: 'Lab IoT',
    description:
        'Menjalankan model machine learning ringan langsung pada '
        'mikrokontroler untuk deteksi anomali tanpa koneksi internet.',
    price: 85000,
    quota: 40,
    registered: 40,
  ),
  EventItem(
    id: 'cyb-01',
    title: 'Ethical Hacking: Web Penetration Testing Dasar',
    speaker: 'Rizky Maulana, CEH',
    category: EventCategory.cybersecurity,
    startDate: DateTime(2026, 12, 6),
    endDate: DateTime(2026, 12, 7),
    time: '09:00 – 16:00 WIB',
    room: 'Cyber Arena',
    description:
        'Praktik di lingkungan lab terisolasi: pemetaan target, '
        'kerentanan OWASP Top 10, dan penulisan laporan temuan. '
        'Seluruh latihan dilakukan secara legal dan etis.',
    price: 120000,
    quota: 50,
    registered: 44,
  ),
  EventItem(
    id: 'cyb-02',
    title: 'Keamanan Data Pribadi di Era UU PDP',
    speaker: 'Nadia Pramesti, S.H., CIPP',
    category: EventCategory.cybersecurity,
    startDate: DateTime(2026, 12, 12),
    endDate: DateTime(2026, 12, 12),
    time: '10:00 – 12:00 WIB',
    room: 'Cyber Arena',
    description:
        'Kewajiban pengendali data, hak subjek data, dan langkah teknis '
        'sederhana melindungi data pengguna pada aplikasi yang Anda bangun.',
    price: 25000,
    quota: 100,
    registered: 52,
  ),
];
