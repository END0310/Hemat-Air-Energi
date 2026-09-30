// File baru: lib/data/penggunaan_energi_repository.dart
// Repository yang menyediakan data dummy penggunaan air & listrik.

import '../models/penggunaan_energi.dart';

/// Repository statis berisi data dummy catatan penggunaan energi.
/// Ganti implementasi ini dengan pemanggilan API ketika backend tersedia.
class PenggunaanEnergiRepository {
  // Konstruktor private – gunakan sebagai singleton atau instance langsung.
  PenggunaanEnergiRepository._();

  // Singleton – akses via PenggunaanEnergiRepository.instance
  static final PenggunaanEnergiRepository instance =
      PenggunaanEnergiRepository._();


  // --- Data dummy ---
  static final List<PenggunaanEnergi> _dummyData = [
    // Catatan Air
    PenggunaanEnergi(
      id: 'cat-001',
      jenis: JenisEnergi.air,
      jumlah: 12.0,
      tanggal: DateTime(2026, 10, 22, 7, 15),
      keterangan: 'Catat Meteran Air Mandi',
      nomorKamar: 'Kamar 10',
    ),
    PenggunaanEnergi(
      id: 'cat-002',
      jenis: JenisEnergi.air,
      jumlah: 8.5,
      tanggal: DateTime(2026, 10, 21, 6, 45),
      keterangan: 'Mandi Pagi',
      nomorKamar: 'Kamar 10',
    ),
    PenggunaanEnergi(
      id: 'cat-003',
      jenis: JenisEnergi.air,
      jumlah: 20.0,
      tanggal: DateTime(2026, 10, 20, 18, 30),
      keterangan: 'Cuci Baju',
      nomorKamar: 'Kamar 11',
    ),
    PenggunaanEnergi(
      id: 'cat-004',
      jenis: JenisEnergi.air,
      jumlah: 5.0,
      tanggal: DateTime(2026, 10, 19, 20, 0),
      keterangan: 'Cuci Piring',
      nomorKamar: 'Kamar 10',
    ),
    PenggunaanEnergi(
      id: 'cat-005',
      jenis: JenisEnergi.air,
      jumlah: 15.0,
      tanggal: DateTime(2026, 10, 18, 7, 0),
      keterangan: 'Mandi + Sikat Gigi',
      nomorKamar: 'Kamar 12',
    ),
    // Catatan Listrik
    PenggunaanEnergi(
      id: 'cat-006',
      jenis: JenisEnergi.listrik,
      jumlah: 50.0,
      tanggal: DateTime(2026, 10, 23, 19, 30),
      keterangan: 'Beli Token Listrik Kos',
      nomorKamar: 'Kamar 10',
    ),
    PenggunaanEnergi(
      id: 'cat-007',
      jenis: JenisEnergi.listrik,
      jumlah: 2.5,
      tanggal: DateTime(2026, 10, 21, 22, 0),
      keterangan: 'Hemat Listrik AC Mati',
      nomorKamar: 'Kamar 10',
    ),
    PenggunaanEnergi(
      id: 'cat-008',
      jenis: JenisEnergi.listrik,
      jumlah: 1.8,
      tanggal: DateTime(2026, 10, 20, 23, 0),
      keterangan: 'Matikan Rice Cooker',
      nomorKamar: 'Kamar 11',
    ),
    PenggunaanEnergi(
      id: 'cat-009',
      jenis: JenisEnergi.listrik,
      jumlah: 3.2,
      tanggal: DateTime(2026, 10, 19, 21, 0),
      keterangan: 'Cas Laptop + HP Semalaman',
      nomorKamar: 'Kamar 12',
    ),
    PenggunaanEnergi(
      id: 'cat-010',
      jenis: JenisEnergi.listrik,
      jumlah: 0.5,
      tanggal: DateTime(2026, 10, 18, 22, 30),
      keterangan: 'Lampu Kamar Off Lebih Awal',
      nomorKamar: 'Kamar 10',
    ),
  ];

  /// Set true untuk menguji tampilan error di Home (Langkah 9 pengujian No. 4).
  /// Kembalikan ke false setelah selesai diuji.
  static bool simulateError = false;

  /// Mengembalikan semua catatan (simulasi async tanpa backend).
  Future<List<PenggunaanEnergi>> getAll({bool simulateError = false}) async {
    // Simulasi latensi jaringan (1.5 detik agar status loading terlihat jelas).
    await Future.delayed(const Duration(milliseconds: 1500));
    // Lempar error jika simulateError aktif (Langkah 9 No. 4)
    if (simulateError || PenggunaanEnergiRepository.simulateError) {
      throw Exception('Gagal memuat data. Periksa koneksi internet.');
    }
    // Kembalikan salinan list agar data asli tidak bisa diubah dari luar.
    return List.unmodifiable(_dummyData);
  }


  /// Mengembalikan catatan berdasarkan jenis energi.
  Future<List<PenggunaanEnergi>> getByJenis(JenisEnergi jenis) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(
      _dummyData.where((e) => e.jenis == jenis).toList(),
    );
  }

  /// Menambah catatan baru ke dalam list dummy.
  Future<void> tambah(PenggunaanEnergi catatan) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _dummyData.add(catatan); // Ditambahkan ke data dalam memori
  }

  /// Menghapus catatan berdasarkan ID.
  Future<void> hapus(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _dummyData.removeWhere((e) => e.id == id);
  }
}
