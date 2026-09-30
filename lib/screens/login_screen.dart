import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import '../routes/app_routes.dart';
import '../utils/validators.dart'; // (1) import validators

// (1) StatefulWidget – dibutuhkan karena ada controller & _formKey
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // (1) _formKey – dibutuhkan Form + validate()
  final _formKey = GlobalKey<FormState>();

  // (1) Controller – wajib pakai TextEditingController, dibuang di dispose()
  final _usernameController = TextEditingController(); // diganti: username, bukan email
  final _passwordController = TextEditingController();

  bool _obscurePassword = true; // state untuk toggle show/hide password
  bool _isLoading       = false; // state saat proses login berlangsung

  // (2) dispose() – buang semua controller agar tidak memory leak
  @override
  void dispose() {
    _usernameController.dispose(); // diganti: _usernameController
    _passwordController.dispose();
    super.dispose();
  }

  // (2) _submit() – validasi form lalu proses login
  Future<void> _submit() async {
    // Jika ada field tidak valid, Form menampilkan error dan langsung berhenti
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true); // aktifkan loading indicator

    try {
      // Simulasi proses login async (ganti dengan API call nyata nanti)
      await Future.delayed(const Duration(seconds: 2));

      // Periksa mounted sebelum pakai context setelah await (ketentuan poin 4)
      if (!mounted) return;

      // Login berhasil → navigasi ke home, hapus semua route sebelumnya
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } catch (e) {
      // Periksa mounted sebelum setState setelah await (ketentuan poin 4)
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login gagal: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // Matikan loading di finally agar selalu dijalankan (ketentuan poin 3)
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              // ── Logo / header ────────────────────────────────────────────
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.bluePastelLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.water_drop_rounded,
                    color: AppColors.primaryBlue,
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'Hemat Air & Energi',
                  style: AppTextStyles.heading2.copyWith(fontSize: 22),
                ),
              ),
              Center(
                child: Text(
                  'Masuk untuk melanjutkan',
                  style: AppTextStyles.bodyMedium,
                ),
              ),
              const SizedBox(height: 40),

              // (4) Form – membungkus Column berisi field
              Form(
                key: _formKey, // pasang _formKey ke Form
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Label Username ───────────────────────────────────
                    Text('Username', style: AppTextStyles.heading3.copyWith(fontSize: 14)), // diganti: Username
                    const SizedBox(height: 6),

                    // (5) TextFormField Username – validator minLength dari validators.dart
                    TextFormField(
                      controller: _usernameController,  // diganti: _usernameController
                      keyboardType: TextInputType.text,  // diganti: teks biasa
                      textInputAction: TextInputAction.next,
                      validator: (value) => Validators.minLength(
                        value, 3,
                        fieldName: 'Username',            // validator dari validators.dart
                      ),
                      decoration: InputDecoration(
                        hintText: 'Minimal 3 karakter',   // diganti: hint username
                        filled: true,
                        fillColor: AppColors.white,
                        prefixIcon: const Icon(
                          Icons.person_outline,           // diganti: ikon person
                          color: AppColors.primaryBlue,
                        ),
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
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Label Password ───────────────────────────────────
                    Text('Password', style: AppTextStyles.heading3.copyWith(fontSize: 14)),
                    const SizedBox(height: 6),

                    // (5) TextFormField Password – ganti TextField, tambah controller & validator
                    TextFormField(
                      controller: _passwordController,  // controller terpasang
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(), // submit saat tekan Enter
                      validator: Validators.password,    // validator dari validators.dart
                      decoration: InputDecoration(
                        hintText: 'Minimal 8 karakter',
                        filled: true,
                        fillColor: AppColors.white,
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: AppColors.primaryBlue,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.textMedium,
                          ),
                          onPressed: () =>
                              setState(() => _obscurePassword = !_obscurePassword),
                        ),
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
                      ),
                    ),
                    const SizedBox(height: 28),

                    // (6) Tombol Login – onPressed: _submit
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit, // (6) _submit dipasang di sini
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              AppColors.primaryBlue.withValues(alpha: 0.5),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                'Masuk',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
