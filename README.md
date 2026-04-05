#  Ukur Client

**Buku ukur digital untuk penjahit UMKM** — Simpan, kelola, dan akses data ukuran pelanggan kapan saja, di mana saja.

---

## 📱 Screenshot Fitur

| Home | Tambah Pelanggan | Detail |
|------|-----------------|--------|
| List pelanggan + search | Form preset otomatis | Semua ukuran tersimpan |

---

## 🚀 Cara Menjalankan

### Prasyarat

- Flutter SDK **3.x** (stable)
- Dart SDK **^3.0.0**
- Android Studio / VS Code dengan Flutter plugin
- Device/Emulator Android atau iOS

### Langkah Setup

```bash
# 1. Clone / extract project
cd ukur_client

# 2. Install dependencies
flutter pub get

# 3. Generate Hive adapter (WAJIB dijalankan sekali)
flutter pub run build_runner build --delete-conflicting-outputs

# 4. Jalankan aplikasi
flutter run
```

### Build Release APK

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

---

## 📦 Dependencies

| Package | Versi | Fungsi |
|---------|-------|--------|
| `hive` | ^2.2.3 | Local database NoSQL |
| `hive_flutter` | ^1.1.0 | Integrasi Hive dengan Flutter |
| `hive_generator` | ^2.0.1 | Generate TypeAdapter (dev) |
| `build_runner` | ^2.4.8 | Code generation tool (dev) |
| `intl` | ^0.19.0 | Format tanggal Bahasa Indonesia |
| `uuid` | ^4.3.3 | Generate ID unik untuk setiap pelanggan |
| `path_provider` | ^2.1.2 | Akses direktori lokal device |

---

## 🗂️ Struktur Folder

```
lib/
├── main.dart                    # Entry point, init Hive
├── models/
│   ├── customer.dart            # Model Customer + @HiveType
│   └── customer.g.dart          # Generated Hive adapter (auto)
├── pages/
│   ├── home_page.dart           # Home: list + search + drawer
│   ├── add_edit_page.dart       # Form tambah/edit pelanggan
│   ├── detail_page.dart         # Detail ukuran pelanggan
│   ├── settings_page.dart       # Pengaturan satuan & data
│   └── donate_page.dart         # Halaman donasi
├── services/
│   ├── customer_service.dart    # CRUD Hive operations
│   ├── preset_service.dart      # Preset ukuran (Atasan/Bawahan)
│   ├── settings_service.dart    # Simpan preferensi (satuan)
│   └── dummy_data_service.dart  # Data contoh untuk demo
└── widgets/
    ├── app_theme.dart           # ThemeData Material 3 + warna
    └── common_widgets.dart      # Widget reusable (EmptyState, dll)

assets/
├── images/    # Gambar/ilustrasi
├── icons/     # Icon custom
└── fonts/     # Font custom (opsional)
```

---

## 💾 Model Data (Hive)

```dart
@HiveType(typeId: 0)
class Customer extends HiveObject {
  @HiveField(0) String id;          // UUID unik
  @HiveField(1) String nama;        // Nama pelanggan
  @HiveField(2) String? noHp;       // Nomor HP (opsional)
  @HiveField(3) String jenisPakaian; // 'Atasan' | 'Bawahan' | 'custom'
  @HiveField(4) Map<String, double> ukuran; // {"Lingkar Dada": 98.0}
  @HiveField(5) DateTime createdAt;
  @HiveField(6) DateTime updatedAt;
}
```

---

## 📐 Preset Ukuran

### 👔 Atasan
- Lingkar Leher, Lingkar Dada, Lebar Punggung
- Panjang Bahu, Panjang Lengan, Lingkar Kerung Lengan, Panjang Atasan

### 👖 Bawahan
- Lingkar Pinggang, Lingkar Pinggul, Panjang Bawahan
- Lingkar Pesak, Lingkar Paha, Lingkar Lutut, Lingkar Bawah

###  Custom
- User bisa menambahkan field ukuran sendiri (dynamic form)
- Tidak ada preset default

---

## 🎨 Design System

```dart
// Brand Colors
primary:        #8C5A3C  // Coklat tembaga
primaryLight:   #B07D5A
primaryDark:    #6B3F25
accent:         #D4956A
background:     #FAF6F2  // Krem hangat
surface:        #FFFFFF
surfaceVariant: #F5EDE5
```

---

## ✨ Fitur Lengkap

- [x] **Home Page** — List pelanggan dengan card, avatar inisial, badge jenis pakaian
- [x] **Search** — Cari berdasarkan nama atau nomor HP, real-time
- [x] **Drawer Navigation** — Home, Dukung Kami, Pengaturan
- [x] **Tambah Pelanggan** — Form nama, HP, jenis pakaian + preset ukuran otomatis
- [x] **Edit Pelanggan** — Semua data bisa diubah, termasuk tambah ukuran custom
- [x] **Detail Page** — Tampilan lengkap semua ukuran + collapsible info
- [x] **Dynamic Form** — Tambah/hapus field ukuran secara bebas
- [x] **Settings** — Ganti satuan cm/inch, hapus semua data
- [x] **Donate Page** — Informasi cara mendukung developer
- [x] **Empty State** — UI informatif saat data kosong
- [x] **Snackbar Feedback** — Konfirmasi setiap aksi (simpan/hapus)
- [x] **Sorting** — Data otomatis diurutkan berdasarkan updatedAt terbaru
- [x] **Dummy Data** — 3 contoh pelanggan otomatis di-insert saat pertama buka

---

## 🔧 Perintah Penting

```bash
# Install dependencies
flutter pub get

# Generate Hive TypeAdapter (jalankan setelah ubah model)
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-generate saat file berubah)
flutter pub run build_runner watch

# Analisis kode
flutter analyze

# Build APK release
flutter build apk --release

# Build APK debug
flutter build apk --debug

# Clean build cache
flutter clean && flutter pub get
```

---

## 🧪 Data Dummy

Saat pertama kali aplikasi dibuka, 3 data pelanggan contoh akan otomatis ditambahkan:

1. **Budi Santoso** — Atasan (7 ukuran)
2. **Siti Rahayu** — Bawahan (7 ukuran)
3. **Ahmad Fauzi** — Custom (5 ukuran)

Data ini hanya dimasukkan jika database masih kosong. Untuk mereset, gunakan **Pengaturan → Hapus Semua Data**.

---

## ❓ Troubleshooting

**Error: `customer.g.dart` not found**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Error: Hive adapter already registered**
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

**Intl locale error**
Pastikan `initializeDateFormatting('id_ID', null)` dipanggil di `main()` sebelum `runApp()`.

---

## 📄 Lisensi

MIT License — bebas digunakan dan dimodifikasi untuk keperluan UMKM.

---