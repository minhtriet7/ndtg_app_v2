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

  static List<SupportedCountryModel> fromBanknotes(List<BanknoteDirectoryModel> banknotes) {
    final map = <String, List<BanknoteDirectoryModel>>{};

    for (final note in banknotes) {
      final key = note.country.trim().isEmpty ? 'Unknown' : note.country.trim();
      map.putIfAbsent(key, () => []).add(note);
    }

    final countries = map.entries.map((entry) {
      final notes = entry.value;
      notes.sort((a, b) {
        final aValue = double.tryParse(a.denomination.replaceAll(',', '')) ?? 0;
        final bValue = double.tryParse(b.denomination.replaceAll(',', '')) ?? 0;
        return aValue.compareTo(bValue);
      });

      return SupportedCountryModel(
        country: entry.key,
        currencyCode: notes.isNotEmpty ? notes.first.currencyCode : 'N/A',
        noteCount: notes.length,
        banknotes: notes,
      );
    }).toList();

    countries.sort((a, b) => a.country.compareTo(b.country));
    return countries;
  }
}