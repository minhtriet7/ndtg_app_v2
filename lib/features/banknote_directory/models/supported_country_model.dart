import 'banknote_directory_model.dart';

class SupportedCountryModel {
  final String country;
  final String currencyCode;
  final int noteCount;
  final List<BanknoteDirectoryModel> banknotes;

  const SupportedCountryModel({
    required this.country,
    required this.currencyCode,
    required this.noteCount,
    required this.banknotes,
  });

  String get countryCode {
    final clean = country.trim().toLowerCase();

    const map = {
      'vietnam': 'VN',
      'viet nam': 'VN',
      'thailand': 'TH',
      'indonesia': 'ID',
      'malaysia': 'MY',
      'singapore': 'SG',
      'philippines': 'PH',
      'cambodia': 'KH',
      'laos': 'LA',
      'myanmar': 'MM',
      'brunei': 'BN',
    };

    return map[clean] ?? _initials(country);
  }

  static List<SupportedCountryModel> fromBanknotes(List<BanknoteDirectoryModel> banknotes) {
    final map = <String, List<BanknoteDirectoryModel>>{};

    for (final note in banknotes) {
      final key = note.country.trim().isEmpty ? 'Unknown' : note.country.trim();
      map.putIfAbsent(key, () => []).add(note);
    }

    final countries = map.entries.map((entry) {
      final notes = [...entry.value];
      notes.sort((a, b) => a.numericDenomination.compareTo(b.numericDenomination));

      return SupportedCountryModel(
        country: entry.key,
        currencyCode: notes.isNotEmpty ? notes.first.currencyCode : 'N/A',
        noteCount: notes.length,
        banknotes: notes,
      );
    }).toList();

    const priority = [
      'Vietnam',
      'Thailand',
      'Indonesia',
      'Malaysia',
      'Singapore',
      'Philippines',
      'Cambodia',
      'Laos',
      'Myanmar',
      'Brunei',
    ];

    countries.sort((a, b) {
      final ai = priority.indexWhere((item) => item.toLowerCase() == a.country.toLowerCase());
      final bi = priority.indexWhere((item) => item.toLowerCase() == b.country.toLowerCase());

      if (ai != -1 && bi != -1) return ai.compareTo(bi);
      if (ai != -1) return -1;
      if (bi != -1) return 1;

      return a.country.compareTo(b.country);
    });

    return countries;
  }

  static String _initials(String value) {
    final clean = value.trim();
    if (clean.isEmpty) return '?';

    final parts = clean.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}