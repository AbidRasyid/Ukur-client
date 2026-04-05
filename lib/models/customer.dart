import 'package:hive/hive.dart';

part 'customer.g.dart';

@HiveType(typeId: 0)
class Customer extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String nama;

  @HiveField(2)
  String? noHp;

  @HiveField(3)
  late String jenisPakaian; // 'Atasan', 'Bawahan', 'custom'

  @HiveField(4)
  late Map<String, double> ukuran;

  @HiveField(5)
  late DateTime createdAt;

  @HiveField(6)
  late DateTime updatedAt;

  Customer({
    required this.id,
    required this.nama,
    this.noHp,
    required this.jenisPakaian,
    required this.ukuran,
    required this.createdAt,
    required this.updatedAt,
  });

  Customer copyWith({
    String? id,
    String? nama,
    String? noHp,
    String? jenisPakaian,
    Map<String, double>? ukuran,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      noHp: noHp ?? this.noHp,
      jenisPakaian: jenisPakaian ?? this.jenisPakaian,
      ukuran: ukuran ?? this.ukuran,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
