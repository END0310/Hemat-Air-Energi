import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import '../utils/validators.dart'; // validator dari validators.dart

/// Layar form untuk menulis/mengedit catatan pada satu item penggunaan.
/// Menerima catatan awal (String?) via arguments, mengembalikan String via pop.
class CatatanFormScreen extends StatefulWidget {
  // Catatan awal – null jika belum ada catatan sebelumnya
  final String? catatanAwal;

  const CatatanFormScreen({super.key, this.catatanAwal});

  @override
  State<CatatanFormScreen> createState() => _CatatanFormScreenState();
}

class _CatatanFormScreenState extends State<CatatanFormScreen> {
  // Form key untuk validasi
  final _formKey = GlobalKey<FormState>();

  // Controller – wajib dibuang di dispose()
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    // Isi controller dengan catatan awal jika sudah ada
    _controller = TextEditingController(text: widget.catatanAwal ?? '');
  }

  // dispose() – buang controller agar tidak memory leak
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // _simpan() – validasi lalu kembalikan hasil ke layar pemanggil
  void _simpan() {
    if (!_formKey.currentState!.validate()) return;
    // Kembalikan data dengan Navigator.pop (ketentuan poin 8)
    Navigator.pop<String>(context, _controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          color: AppColors.textDark,
          // Batalkan → pop tanpa mengembalikan data
          onPressed: () => Navigator.pop<String>(context),
        ),
        title: Text(
          widget.catatanAwal == null ? 'Tulis Catatan' : 'Edit Catatan',
          style: AppTextStyles.heading3,
        ),
        centerTitle: false,
        actions: [
          // Tombol simpan di AppBar
          TextButton(
            onPressed: _simpan,
            child: Text(
              'Simpan',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Catatan', style: AppTextStyles.heading3.copyWith(fontSize: 14)),
              const SizedBox(height: 8),

              // TextFormField + validator dari validators.dart
              Expanded(
                child: TextFormField(
                  controller: _controller,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  keyboardType: TextInputType.multiline,
                  // Validator dari validators.dart – wajib diisi & min 5 karakter (Langkah 8 & 9)
                  validator: (value) => Validators.minLength(
                    value, 5,
                    fieldName: 'Catatan',
                  ),
                  decoration: InputDecoration(
                    hintText: 'Tulis catatan tentang penggunaan ini...',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      color: AppColors.textLight,
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: AppColors.white,
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: AppColors.blueBackground,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppColors.primaryBlue,
                        width: 1.5,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Colors.red, width: 1.5),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Colors.red, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Tombol Simpan di bawah
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _simpan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Simpan Catatan',
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
      ),
    );
  }
}
