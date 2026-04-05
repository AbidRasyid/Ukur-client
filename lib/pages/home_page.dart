import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/customer.dart';
import '../services/customer_service.dart';
import '../services/settings_service.dart';
import '../widgets/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'add_edit_page.dart';
import 'detail_page.dart';
import 'settings_page.dart';
import 'donate_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSnackbar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.error : AppTheme.onBackground,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  // ignore: unused_element
  Future<void> _deleteCustomer(Customer customer) async {
    final confirm = await showConfirmDialog(
      context,
      title: 'Hapus Pelanggan',
      content:
          'Hapus data ukuran "${customer.nama}"? Tindakan ini tidak bisa dibatalkan.',
    );
    if (confirm == true) {
      await CustomerService.deleteCustomer(customer.id);
      _showSnackbar('Data "${customer.nama}" berhasil dihapus');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Row(
          children: [
            Text('Ukur Client'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            ),
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Pengaturan',
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: Column(
        children: [
          // Stats Banner
          _buildStatsBanner(),
          // Search Bar
          _buildSearchBar(),
          // Customer List
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: CustomerService.box.listenable(),
              builder: (context, box, _) {
                final customers = CustomerService.searchCustomers(_searchQuery);
                if (customers.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.people_outline_rounded,
                    title: _searchQuery.isEmpty
                        ? 'Belum ada pelanggan'
                        : 'Tidak ditemukan',
                    subtitle: _searchQuery.isEmpty
                        ? 'Tambahkan data ukuran pelanggan pertama Anda dengan menekan tombol + di bawah.'
                        : 'Coba cari dengan nama atau nomor HP yang berbeda.',
                    onAction: _searchQuery.isEmpty
                        ? () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const AddEditPage()),
                            )
                        : null,
                    actionLabel: 'Tambah Pelanggan',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 4, bottom: 100),
                  itemCount: customers.length,
                  itemBuilder: (context, index) {
                    return _buildCustomerCard(customers[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditPage()),
        ),
        tooltip: 'Tambah Pelanggan',
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppTheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              decoration: const BoxDecoration(
                color: AppTheme.primary,
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 56,
                    height: 56,
                    child: Center(
                      child: Image(
                          image: AssetImage('assets/icons/logo.png'),
                          width: 56,
                          height: 56),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Ukur Client',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Buku ukur digital untuk penjahit',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Menu Items
            _drawerItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home_rounded,
              label: 'Beranda',
              onTap: () => Navigator.pop(context),
              isActive: true,
            ),
            _drawerItem(
              icon: Icons.volunteer_activism_outlined,
              activeIcon: Icons.volunteer_activism,
              label: 'Dukung Kami',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DonatePage()),
                );
              },
            ),
            _drawerItem(
              icon: Icons.settings_outlined,
              activeIcon: Icons.settings,
              label: 'Pengaturan',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                );
              },
            ),

            const Spacer(),

            // Version
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Versi 1.0.0',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return ListTile(
      leading: Icon(
        isActive ? activeIcon : icon,
        color: isActive ? AppTheme.primary : AppTheme.textSecondary,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          color: isActive ? AppTheme.primary : AppTheme.onBackground,
        ),
      ),
      tileColor: isActive ? AppTheme.primary.withValues(alpha: 0.08) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      horizontalTitleGap: 12,
      onTap: onTap,
    );
  }

  Widget _buildStatsBanner() {
    return ValueListenableBuilder(
      valueListenable: CustomerService.box.listenable(),
      builder: (context, box, _) {
        final total = CustomerService.totalCustomers;
        return Container(
          color: AppTheme.primary,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Row(
            children: [
              _statItem('$total', 'Total Pelanggan', Icons.people_rounded),
            ],
          ),
        );
      },
    );
  }

  Widget _statItem(String value, String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(width: 8),
        Text(
          '$value $label',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: 'Cari nama atau no HP...',
          prefixIcon:
              const Icon(Icons.search_rounded, color: AppTheme.textSecondary),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          fillColor: AppTheme.surfaceVariant,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildCustomerCard(Customer customer) {
    final satuan = SettingsService.satuan;
    final ukuranCount = customer.ukuran.length;
    final dateFormat = DateFormat('d MMM yyyy', 'id_ID');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => DetailPage(customerId: customer.id)),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Avatar
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        customer.nama.isNotEmpty
                            ? customer.nama[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.nama,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.onBackground,
                          ),
                        ),
                        if (customer.noHp != null &&
                            customer.noHp!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            customer.noHp!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Badge
                  JenisPakaianBadge(jenis: customer.jenisPakaian),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.straighten_rounded,
                      size: 14, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    '$ukuranCount ukuran tersimpan ($satuan)',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.access_time_rounded,
                      size: 12, color: AppTheme.textSecondary),
                  const SizedBox(width: 3),
                  Text(
                    dateFormat.format(customer.updatedAt),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
