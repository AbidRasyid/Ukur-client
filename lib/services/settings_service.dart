import 'package:hive_flutter/hive_flutter.dart';

class SettingsService {
  static const String _boxName = 'settings';
  static const String _satuanKey = 'satuan';
  static Box? _box;

  static Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  static Box get box {
    if (_box == null || !_box!.isOpen) {
      throw Exception('Settings box belum dibuka.');
    }
    return _box!;
  }

  static String get satuan => box.get(_satuanKey, defaultValue: 'cm') as String;

  static Future<void> setSatuan(String value) async {
    await box.put(_satuanKey, value);
  }
}
