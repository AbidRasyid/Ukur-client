import 'package:flutter/material.dart';
import '../services/customer_service.dart';

import '../widgets/app_theme.dart';
import '../widgets/common_widgets.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> _hapusSemua() async {
    final confirm = await showConfirmDialog(
      context,
      title: 'Hapus Semua Data',
      content:
          'Semua data pelanggan akan dihapus permanen dan tidak bisa dikembalikan. Yakin?',
      confirmLabel: 'Hapus Semua',
    );
    if (confirm == true) {
      await CustomerService.deleteAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ Semua data berhasil dihapus'),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          // ─ Data ─
          const SectionHeader(title: 'Data'),
          _settingsCard([
            ListTile(
              leading: const Icon(Icons.delete_forever_rounded,
                  color: AppTheme.error),
              title: const Text(
                'Hapus Semua Data',
                style: TextStyle(color: AppTheme.error),
              ),
              subtitle: const Text('Menghapus semua data pelanggan'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: _hapusSemua,
            ),
          ]),

          // ─ Tentang ─
          const SectionHeader(title: 'Tentang Aplikasi'),
          _settingsCard([
            const ListTile(
              leading:
                  Icon(Icons.info_outline_rounded, color: AppTheme.primary),
              title: Text('Ukur Client'),
              subtitle: Text('Versi 1.0.0'),
            ),
            const Divider(height: 1, indent: 56),
            const ListTile(
              leading: Icon(Icons.code_rounded, color: AppTheme.primary),
              title: Text('Teknologi'),
              subtitle: Text('Flutter + Hive (Local Database)'),
            ),
            const Divider(height: 1, indent: 56),
            const ListTile(
              leading:
                  Icon(Icons.description_outlined, color: AppTheme.primary),
              title: Text('Lisensi'),
              subtitle: Text('MIT License'),
            ),
          ]),

          // ─ catatan ─
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('', style: TextStyle(fontSize: 24)),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ukur Client',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Aplikasi buku ukur digital untuk penjahit UMKM. Simpan, kelola, dan akses data ukuran pelanggan kapan saja, di mana saja.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(children: children),
    );
  }
}
