import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/customer.dart';
import '../services/customer_service.dart';
import '../services/settings_service.dart';
import '../widgets/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'add_edit_page.dart';

class DetailPage extends StatelessWidget {
  final String customerId;

  const DetailPage({super.key, required this.customerId});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: CustomerService.box.listenable(),
      builder: (context, box, _) {
        final customer = CustomerService.getCustomer(customerId);
        if (customer == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pop(context);
          });
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        return _DetailContent(customer: customer);
      },
    );
  }
}

class _DetailContent extends StatelessWidget {
  final Customer customer;

  const _DetailContent({required this.customer});

  void _delete(BuildContext context) async {
    final confirm = await showConfirmDialog(
      context,
      title: 'Hapus Pelanggan',
      content: 'Hapus data "${customer.nama}" beserta semua ukurannya?',
    );
    if (confirm == true) {
      await CustomerService.deleteCustomer(customer.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data "${customer.nama}" dihapus'),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final satuan = SettingsService.satuan;
    final dateFormat = DateFormat('d MMMM yyyy, HH:mm', 'id_ID');

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddEditPage(customer: customer),
                  ),
                ),
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit',
              ),
              IconButton(
                onPressed: () => _delete(context),
                icon: const Icon(Icons.delete_outline_rounded),
                tooltip: 'Hapus',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppTheme.primary,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
                    child: Row(
                      children: [
                        // Avatar
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              customer.nama.isNotEmpty
                                  ? customer.nama[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                customer.nama,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              if (customer.noHp != null &&
                                  customer.noHp!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.phone_outlined,
                                        size: 14, color: Colors.white70),
                                    const SizedBox(width: 4),
                                    Text(
                                      customer.noHp!,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 8),
                              JenisPakaianBadge(jenis: customer.jenisPakaian),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info chips
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                    child: Row(
                      children: [
                        _infoChip(
                          Icons.straighten_rounded,
                          '${customer.ukuran.length} ukuran',
                        ),
                        const SizedBox(width: 8),
                        _infoChip(
                          Icons.schedule_rounded,
                          dateFormat.format(customer.updatedAt),
                        ),
                      ],
                    ),
                  ),

                  // Ukuran Section
                  const SectionHeader(title: 'Data Ukuran'),
                  if (customer.ukuran.isEmpty)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.divider),
                      ),
                      child: const Center(
                        child: Text(
                          'Belum ada data ukuran',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      ),
                    )
                  else
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.divider),
                      ),
                      child: Column(
                        children: customer.ukuran.entries.map((entry) {
                          return Column(
                            children: [
                              UkuranRow(
                                label: entry.key,
                                value: entry.value,
                                satuan: satuan,
                              ),
                              if (entry.key != customer.ukuran.keys.last)
                                const Divider(height: 1, indent: 16),
                            ],
                          );
                        }).toList(),
                      ),
                    ),

                  // Timestamps
                  const SectionHeader(title: 'Informasi'),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.divider),
                    ),
                    child: Column(
                      children: [
                        _infoRow(
                          'Dibuat pada',
                          dateFormat.format(customer.createdAt),
                          Icons.calendar_today_outlined,
                        ),
                        const Divider(height: 1, indent: 16),
                        _infoRow(
                          'Terakhir diperbarui',
                          dateFormat.format(customer.updatedAt),
                          Icons.update_rounded,
                        ),
                      ],
                    ),
                  ),

                  // Action Buttons
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _delete(context),
                            icon: const Icon(Icons.delete_outline_rounded),
                            label: const Text('Hapus'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.error,
                              side: const BorderSide(color: AppTheme.error),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddEditPage(customer: customer),
                              ),
                            ),
                            icon: const Icon(Icons.edit_rounded),
                            label: const Text('Edit Ukuran'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppTheme.textSecondary),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.textSecondary),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppTheme.onBackground,
            ),
          ),
        ],
      ),
    );
  }
}
