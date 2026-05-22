import 'package:hive/hive.dart';

part 'customer.g.dart';

@HiveType(typeId: 0)
class Customer extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String nama;

  @HiveField(2)
  String? noHp;

  @HiveField(3)
  final String jenisPakaian; // 'Atasan', 'Bawahan', 'custom'

  @HiveField(4)
  final Map<String, double> ukuran;

  @HiveField(5)
  String? catatan;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  DateTime updatedAt;

  Customer({
    required this.id,
    required this.nama,
    this.noHp,
    required this.jenisPakaian,
    required this.ukuran,
    this.catatan,
    required this.createdAt,
    required this.updatedAt,
  });

  Customer copyWith({
    String? id,
    String? nama,
    String? noHp,
    String? jenisPakaian,
    Map<String, double>? ukuran,
    String? catatan,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      noHp: noHp ?? this.noHp,
      jenisPakaian: jenisPakaian ?? this.jenisPakaian,
      ukuran: ukuran ?? this.ukuran,
      catatan: catatan ?? this.catatan,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
