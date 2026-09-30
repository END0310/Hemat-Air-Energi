// File baru: lib/models/penggunaan_energi.dart
// Model data untuk satu catatan penggunaan air atau listrik.

/// Jenis sumber daya yang dicatat.
enum JenisEnergi {
  air,     // SDG 6 – Air Bersih
  listrik, // SDG 7 – Energi Bersih
}

/// Model satu catatan penggunaan air atau listrik oleh penghuni kos.
class PenggunaanEnergi {
  // --- field utama ---
  final String id;           // ID unik catatan
  final JenisEnergi jenis;   // Air atau Listrik
  final double jumlah;       // Nilai penggunaan (Liter / kWh)
  final DateTime tanggal;    // Waktu pencatatan
  final String keterangan;   // Deskripsi singkat aktivitas
  final String nomorKamar;   // Kamar penghuni yang mencatat

  // Constructor
  const PenggunaanEnergi({
    required this.id,
    required this.jenis,
    required this.jumlah,
    required this.tanggal,
    required this.keterangan,
    required this.nomorKamar,
  });

  /// Satuan tampilan sesuai jenis energi.
  String get satuan => jenis == JenisEnergi.air ? 'L' : 'kWh';

  /// Label teks jenis energi untuk ditampilkan di UI.
  String get labelJenis => jenis == JenisEnergi.air ? 'Air' : 'Listrik';

  /// Salinan objek dengan field tertentu yang diubah.
  PenggunaanEnergi copyWith({
    String? id,
    JenisEnergi? jenis,
    double? jumlah,
    DateTime? tanggal,
    String? keterangan,
    String? nomorKamar,
  }) {
    return PenggunaanEnergi(
      id: id ?? this.id,
      jenis: jenis ?? this.jenis,
      jumlah: jumlah ?? this.jumlah,
      tanggal: tanggal ?? this.tanggal,
      keterangan: keterangan ?? this.keterangan,
      nomorKamar: nomorKamar ?? this.nomorKamar,
    );
  }
}
