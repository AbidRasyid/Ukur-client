import 'package:hive_flutter/hive_flutter.dart';
import '../models/customer.dart';

class CustomerService {
  static const String _boxName = 'customers';
  static Box<Customer>? _box;

  static Future<void> init() async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CustomerAdapter());
    }

    _box = await Hive.openBox<Customer>(_boxName);
  }

  static Box<Customer> get box {
    if (_box == null || !_box!.isOpen) {
      throw Exception(
          'Hive box belum dibuka. Panggil CustomerService.init() terlebih dahulu.');
    }
    return _box!;
  }

  // Tambah pelanggan baru
  static Future<void> addCustomer(Customer customer) async {
    await box.put(customer.id, customer);
  }

  // Update pelanggan
  static Future<void> updateCustomer(Customer customer) async {
    customer.updatedAt = DateTime.now();
    await box.put(customer.id, customer);
  }

  // Hapus pelanggan
  static Future<void> deleteCustomer(String id) async {
    await box.delete(id);
  }

  // Ambil semua pelanggan (sorted by updatedAt desc)
  static List<Customer> getAllCustomers() {
    final customers = <Customer>[];
    for (final customer in box.values) {
      customers.add(customer);
    }
    customers.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return customers;
  }

  // Cari pelanggan berdasarkan nama
  static List<Customer> searchCustomers(String query) {
    return box.values.where((c) {
      return c.nama.toLowerCase().contains(query) ||
          (c.noHp?.contains(query) ?? false);
    }).toList();
  }

  // Ambil satu pelanggan by id
  static Customer? getCustomer(String id) {
    return box.get(id);
  }

  // Hapus semua data
  static Future<void> deleteAll() async {
    await box.clear();
  }

  // Total pelanggan
  static int get totalCustomers => box.length;
}
