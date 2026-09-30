import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import '../models/penggunaan_energi.dart'; // (1) import model
import '../routes/app_routes.dart';        // untuk navigasi ke form catatan

/// Layar detail satu catatan penggunaan energi.
/// Data diterima lewat constructor (dikirim dari Home via arguments).
// (3) Diubah menjadi StatefulWidget agar bisa menyimpan state _catatan
class DetailScreen extends StatefulWidget {
  // (1) Field item – wajib diisi, tidak boleh null
  final PenggunaanEnergi item;

  // (1) Constructor dengan required this.item
  const DetailScreen({super.key, required this.item});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  // (2) _catatan – menyimpan catatan yang dikembalikan dari CatatanFormScreen
  String? _catatan;

  // (3) _bukaFormCatatan() – buka CatatanFormScreen dan terima hasil via pop
  Future<void> _bukaFormCatatan() async {
    // pushNamed mengembalikan String? (ketentuan poin 8)
    final hasil = await Navigator.pushNamed<String>(
      context,
      AppRoutes.catatanForm,
      arguments: _catatan, // kirim catatan awal jika sudah ada
    );
    if (!mounted) return; // cek mounted setelah await (ketentuan poin 4)
    if (hasil != null) {
      setState(() => _catatan = hasil); // (2) simpan catatan ke state
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Catatan berhasil disimpan!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // (3) Gunakan widget.item karena sekarang StatefulWidget
    final bool isAir = widget.item.jenis == JenisEnergi.air;
    final Color accentColor =
        isAir ? AppColors.primaryBlue : AppColors.amber;
    final Color bgColor =
        isAir ? AppColors.bluePastelLight : AppColors.amberPastel;
    final IconData icon =
        isAir ? Icons.water_drop_rounded : Icons.electric_bolt_rounded;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: AppColors.textDark,
          onPressed: () => Navigator.pop(context),
        ),
        // (1) Judul AppBar dari data item (bukan hardcode)
        title: Text(
          widget.item.labelJenis, // (3) widget.item karena StatefulWidget
          style: AppTextStyles.heading3,
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero icon + badge ─────────────────────────────────────────
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accentColor, size: 40),
              ),
            ),
            const SizedBox(height: 24),

            // ── Card detail ───────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.07),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // (1) Keterangan dari item.keterangan
                  _DetailRow(
                    label: 'Aktivitas',
                    value: widget.item.keterangan, // (3) widget.item
                  ),
                  const Divider(height: 32),
                  // (1) Jumlah + satuan dari item.jumlah dan item.satuan
                  _DetailRow(
                    label: 'Jumlah',
                    value: '${widget.item.jumlah} ${widget.item.satuan}', // (3)
                    valueStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                    ),
                  ),
                  const Divider(height: 32),
                  // (1) Nomor kamar dari item.nomorKamar
                  _DetailRow(
                    label: 'Kamar',
                    value: widget.item.nomorKamar, // (3) widget.item
                  ),
                  const Divider(height: 32),
                  // (1) Tanggal dari item.tanggal
                  _DetailRow(
                    label: 'Tanggal',
                    value: _formatTanggal(widget.item.tanggal), // (3)
                  ),
                  const Divider(height: 32),
                  // (1) Jenis dari item.labelJenis
                  _DetailRow(
                    label: 'Jenis',
                    value: widget.item.labelJenis, // (3) widget.item
                  ),
                  // (4) Tampilkan catatan jika sudah ada
                  if (_catatan != null) ...[
                    const Divider(height: 32),
                    _DetailRow(
                      label: 'Catatan',
                      value: _catatan!, // (2) dari state _catatan
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // (4) Tombol "Tulis Catatan" – buka CatatanFormScreen
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _bukaFormCatatan, // (3) panggil _bukaFormCatatan
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: Icon(
                  _catatan == null ? Icons.edit_note_rounded : Icons.edit_rounded,
                  size: 20,
                ),
                label: Text(
                  _catatan == null ? 'Tulis Catatan' : 'Edit Catatan',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Kembali ────────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: accentColor),
                  foregroundColor: accentColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Kembali',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  /// Format DateTime ke string yang mudah dibaca.
  // (3) Diubah dari static method milik class menjadi fungsi biasa
  static String _formatTanggal(DateTime dt) {
    const bulan = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    final jam = dt.hour.toString().padLeft(2, '0');
    final menit = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${bulan[dt.month]} ${dt.year}, $jam:$menit';
  }
}

/// Widget baris label–nilai yang dipakai berulang di card detail.
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textMedium,
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            style: valueStyle ??
                GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
