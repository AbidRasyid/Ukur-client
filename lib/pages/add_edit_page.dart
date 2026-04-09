import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../models/customer.dart';
import '../services/customer_service.dart';
import '../services/preset_service.dart';
import '../services/settings_service.dart';
import '../widgets/app_theme.dart';
import '../widgets/common_widgets.dart';

class AddEditPage extends StatefulWidget {
  final Customer? customer; // null = add mode

  const AddEditPage({super.key, this.customer});

  @override
  State<AddEditPage> createState() => _AddEditPageState();
}

class _AddEditPageState extends State<AddEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _noHpController = TextEditingController();
  final _catatanController = TextEditingController();

  String _jenisPakaian = 'Atasan';
  final Map<String, TextEditingController> _ukuranControllers = {};
  bool _isSaving = false;

  bool get isEdit => widget.customer != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      _namaController.text = widget.customer!.nama;
      _noHpController.text = widget.customer!.noHp ?? '';
      _jenisPakaian = widget.customer!.jenisPakaian;
      // Load existing ukuran
      widget.customer!.ukuran.forEach(
        (key, value) {
          _ukuranControllers[key] = TextEditingController(
            text: value > 0
                ? (value % 1 == 0 ? value.toInt().toString() : value.toString())
                : '',
          );
        },
      );
      _catatanController.text = widget.customer!.catatan ?? '';
    } else {
      _loadPreset(_jenisPakaian);
    }
  }

  void _loadPreset(String jenis) {
    // Save existing custom fields
    final currentCustom = <String, String>{};
    if (_jenisPakaian == 'custom') {
      _ukuranControllers.forEach((k, v) => currentCustom[k] = v.text);
    }

    // Dispose old
    for (var c in _ukuranControllers.values) {
      c.dispose();
    }
    _ukuranControllers.clear();

    // Load preset
    final preset = PresetService.getPreset(jenis);
    for (var field in preset) {
      _ukuranControllers[field] = TextEditingController();
    }

    // Restore custom if switching to custom
    if (jenis == 'custom') {
      currentCustom.forEach((k, v) {
        _ukuranControllers[k] = TextEditingController(text: v);
      });
    }
  }

  void _addCustomField() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Tambah Ukuran Baru'),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Nama Ukuran',
              hintText: 'Contoh: Lingkar Perut',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                final label = controller.text.trim();
                if (label.isNotEmpty) {
                  setState(() {
                    _ukuranControllers[label] = TextEditingController();
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Tambah'),
            ),
          ],
        );
      },
    );
  }

  void _removeField(String key) {
    final isPreset = PresetService.getPreset(_jenisPakaian).contains(key);
    if (isPreset) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Field preset tidak bisa dihapus')),
      );
      return;
    }
    setState(() {
      _ukuranControllers[key]?.dispose();
      _ukuranControllers.remove(key);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final ukuran = <String, double>{};
      _ukuranControllers.forEach((key, ctrl) {
        ukuran[key] = double.tryParse(ctrl.text.replaceAll(',', '.')) ?? 0.0;
      });

      final now = DateTime.now();

      if (isEdit) {
        final updated = widget.customer!.copyWith(
          nama: _namaController.text.trim(),
          noHp: _noHpController.text.trim().isEmpty
              ? null
              : _noHpController.text.trim(),
          jenisPakaian: _jenisPakaian,
          ukuran: ukuran,
          catatan: _catatanController.text.trim().isEmpty
              ? null
              : _catatanController.text.trim(),
          updatedAt: now,
        );
        await CustomerService.updateCustomer(updated);
      } else {
        final customer = Customer(
          id: const Uuid().v4(),
          nama: _namaController.text.trim(),
          noHp: _noHpController.text.trim().isEmpty
              ? null
              : _noHpController.text.trim(),
          jenisPakaian: _jenisPakaian,
          ukuran: ukuran,
          catatan: _catatanController.text.trim().isEmpty
              ? null
              : _catatanController.text.trim(),
          createdAt: now,
          updatedAt: now,
        );
        await CustomerService.addCustomer(customer);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEdit
                ? 'Data berhasil diperbarui'
                : 'Pelanggan berhasil ditambahkan'),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _noHpController.dispose();
    _catatanController.dispose();
    for (var c in _ukuranControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final satuan = SettingsService.satuan;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Pelanggan' : 'Tambah Pelanggan'),
        actions: [
          TextButton.icon(
            onPressed: _isSaving ? null : _save,
            icon: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.save_rounded, color: Colors.white),
            label: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            // ─ Data Pelanggan ─
            const SectionHeader(title: 'Data Pelanggan'),
            _buildDataPelangganSection(),

            // ─ Jenis Pakaian ─
            const SectionHeader(title: 'Jenis Pakaian'),
            _buildJenisPakaianSection(),

            // ─ Ukuran ─
            SectionHeader(
              title: 'Ukuran ($satuan)',
              trailing: TextButton.icon(
                onPressed: _addCustomField,
                icon: const Icon(Icons.add_circle_outline, size: 16),
                label: const Text('Tambah'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
            _buildUkuranSection(satuan),
            const SizedBox(height: 16),
            const SectionHeader(title: "catatan"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextFormField(
                controller: _catatanController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'catatan (opsional)',
                  prefixIcon: Icon(Icons.description),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataPelangganSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextFormField(
              controller: _namaController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nama Pelanggan *',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TextFormField(
              controller: _noHpController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9+\- ]'))
              ],
              decoration: const InputDecoration(
                labelText: 'No HP (opsional)',
                prefixIcon: Icon(Icons.phone_outlined),
                hintText: 'Contoh: 0812-3456-7890',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJenisPakaianSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: PresetService.allJenis.map((jenis) {
            final isSelected = _jenisPakaian == jenis;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () {
                    if (jenis != _jenisPakaian) {
                      setState(() {
                        _jenisPakaian = jenis;
                        if (!isEdit) {
                          _loadPreset(jenis);
                        } else {
                          // In edit mode, only load preset if no existing ukuran for new jenis
                          _loadPreset(jenis);
                          // Re-fill existing values
                          widget.customer!.ukuran.forEach((k, v) {
                            if (_ukuranControllers.containsKey(k)) {
                              _ukuranControllers[k]!.text = v > 0
                                  ? (v % 1 == 0
                                      ? v.toInt().toString()
                                      : v.toString())
                                  : '';
                            }
                          });
                        }
                      });
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primary
                          : AppTheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? AppTheme.primary : AppTheme.divider,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          PresetService.jenisPakaianIcon[jenis] ?? '',
                          style: const TextStyle(fontSize: 22),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          PresetService.jenisPakaianLabel[jenis] ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : AppTheme.onBackground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildUkuranSection(String satuan) {
    if (_ukuranControllers.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Column(
          children: [
            const Icon(Icons.add_circle_outline,
                color: AppTheme.textSecondary, size: 40),
            const SizedBox(height: 8),
            const Text(
              'Belum ada ukuran',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _addCustomField,
              icon: const Icon(Icons.add),
              label: const Text('Tambah Ukuran'),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        children: _ukuranControllers.entries.map((entry) {
          final isPreset =
              PresetService.getPreset(_jenisPakaian).contains(entry.key);
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
                child: Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.onBackground,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 4,
                      child: TextFormField(
                        controller: entry.value,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                        ],
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          suffixText: satuan,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                    if (!isPreset) ...[
                      const SizedBox(width: 4),
                      IconButton(
                        onPressed: () => _removeField(entry.key),
                        icon: const Icon(Icons.remove_circle_outline_rounded,
                            color: AppTheme.error, size: 20),
                        padding: const EdgeInsets.all(8),
                        constraints:
                            const BoxConstraints(minWidth: 36, minHeight: 36),
                      ),
                    ] else
                      const SizedBox(width: 44),
                  ],
                ),
              ),
              if (entry.key != _ukuranControllers.keys.last)
                const Divider(height: 1, indent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }
}
