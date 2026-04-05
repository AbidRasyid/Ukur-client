class PresetService {
  static const Map<String, List<String>> presets = {
    'Atasan': [
      'Lingkar Leher',
      'Lingkar Dada',
      'Lebar Punggung',
      'Panjang Bahu',
      'Panjang Lengan',
      'Lingkar Kerung Lengan',
      'Panjang Atasan',
    ],
    'Bawahan': [
      'Lingkar Pinggang',
      'Lingkar Pinggul',
      'Panjang Bawahan',
      'Lingkar Pesak',
      'Lingkar Paha',
      'Lingkar Lutut',
      'Lingkar Bawah',
    ],
    'custom': [],
  };

  static List<String> getPreset(String jenisPakaian) {
    return presets[jenisPakaian] ?? [];
  }

  static Map<String, double> getDefaultUkuran(String jenisPakaian) {
    final fields = getPreset(jenisPakaian);
    return {for (var f in fields) f: 0.0};
  }

  static const Map<String, String> jenisPakaianLabel = {
    'Atasan': 'Atasan',
    'Bawahan': 'Bawahan',
    'custom': 'Custom',
  };

  static const Map<String, String> jenisPakaianIcon = {
    'Atasan': '👔',
    'Bawahan': '👖',
    'custom': '',
  };

  static List<String> get allJenis => ['Atasan', 'Bawahan', 'custom'];
}
