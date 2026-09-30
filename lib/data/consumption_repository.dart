import '../models/consumption_item.dart';

class ConsumptionRepository {
  static const List<ConsumptionItem> _items = [
    ConsumptionItem(
      id: '1',
      title: 'Mandi pagi',
      subtitle: 'Air - 35 Liter',
      description: 'Catatan pemakaian air untuk mandi pagi.',
      type: 'Air',
      amount: 35,
    ),
    ConsumptionItem(
      id: '2',
      title: 'Kipas kamar',
      subtitle: 'Listrik - 1.2 kWh',
      description: 'Catatan pemakaian listrik kipas kamar.',
      type: 'Listrik',
      amount: 1.2,
    ),
    ConsumptionItem(
      id: '3',
      title: 'Cuci pakaian',
      subtitle: 'Air - 48 Liter',
      description: 'Catatan pemakaian air untuk mencuci pakaian.',
      type: 'Air',
      amount: 48,
    ),
  ];

  Future<List<ConsumptionItem>> fetchItems({bool simulateError = false }) async {
    await Future<void>.delayed(const Duration(seconds: 2));
    if (simulateError) {
      throw Exception('Gagal memuat data pemakaian.');
    }
    return _items;
  }
}