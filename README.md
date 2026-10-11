# Ukur Client

Aplikasi manajemen data pelanggan dan ukuran baju/pakaian berbasis Flutter. Aplikasi ini dirancang untuk bekerja secara **offline** menggunakan **Hive** sebagai basis data lokal[cite: 2].

## 📌 Fitur Utama

- **Kelola Data Pelanggan**: Menambah, mengubah, mencari, dan menghapus data pelanggan beserta detail pengukurannya[cite: 2].
- **Sistem Preset**: Memudahkan pengisian detail ukuran pakaian berdasarkan template/preset yang sering digunakan[cite: 2].
- **Dukungan Tema**: Pengaturan tema aplikasi (Terang, Gelap, atau Mengikuti Sistem)[cite: 2].
- **Halaman Donasi**: Dukungan pengembangan aplikasi bagi pengguna yang ingin berkontribusi[cite: 2].
- **Penyimpanan Lokal (Offline)**: Seluruh data tersimpan aman di perangkat pengguna menggunakan Hive[cite: 2].

## 🛠️ Teknologi & Libs

- **Framework**: [Flutter](https://flutter.dev)
- **Database**: [Hive](https://pub.dev/packages/hive) & [Hive Flutter](https://pub.dev/packages/hive_flutter)
- **Code Generation**: [Hive Generator](https://pub.dev/packages/hive_generator) & [Build Runner](https://pub.dev/packages/build_runner)

## 📁 Struktur Proyek

```text
lib/
├── models/         # Model data (Customer, TypeAdapter Hive)
├── pages/          # Layar UI (Home, Add/Edit, Detail, Settings, Donate)
├── services/       # Layanan data (CustomerService, PresetService, SettingsService)
├── widgets/        # Komponen UI dan tema aplikasi
└── main.dart       # Titik masuk utama aplikasi
```[cite: 2]

## 📱 Deployment & Platform

- **Android**: *Fokus Utama / Didukung* (Siap dijalankan dan dipasang melalui berkas APK).
- **iOS, Web, & Desktop**: *Tahap Rencana / Eksperimental* (Berkas konfigurasi tersedia, namun fokus pengujian saat ini masih pada Android)[cite: 2].

## 🚀 Cara Menjalankan Proyek

1. **Prasyarat**: Pastikan Flutter SDK sudah terpasang di komputer Anda.
2. **Klon Repositori**:
   ```bash
   git clone [https://github.com/username/Ukur-client.git](https://github.com/username/Ukur-client.git)
   cd Ukur-client
