// File baru: lib/routes/app_routes.dart
// Konstanta nama route dan generator route terpusat.
// Gunakan AppRoutes.<nama> di screen – jangan tulis string route langsung.

import 'package:flutter/material.dart';
import '../models/penggunaan_energi.dart';  // (2) import model untuk type-check
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/detail_screen.dart';     // (2) import DetailScreen
import '../screens/catatan_form_screen.dart'; // import CatatanFormScreen

/// Konstanta nama route untuk seluruh aplikasi.
abstract class AppRoutes {
  AppRoutes._(); // Tidak boleh di-instansiasi

  static const String splash  = '/';          // SplashScreen (initial route)
  static const String home    = '/home';       // HomeScreen (dashboard utama)
  static const String login   = '/login';      // LoginScreen (form masuk)
  static const String detail      = '/detail';      // DetailScreen (detail catatan)
  static const String catatanForm = '/catatan-form'; // CatatanFormScreen (form catatan)
}

/// Generator route terpusat yang dipasang di MaterialApp.onGenerateRoute.
/// Semua navigasi wajib melewati fungsi ini agar type-checking argument aman.
Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {

    // ── Splash ──────────────────────────────────────────────────────────────
    case AppRoutes.splash:
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const SplashScreen(),
      );

    // ── Login ────────────────────────────────────────────────────────────────
    case AppRoutes.login:
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const LoginScreen(), // Ditambahkan: route login aktif
      );

    // ── Home ────────────────────────────────────────────────────────────────
    case AppRoutes.home:
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const HomeScreen(),
      );

    // ── Detail ──────────────────────────────────────────────────────────────
    case AppRoutes.detail:
      // (2) Periksa tipe argument dengan 'is' sebelum diteruskan ke screen
      final arg = settings.arguments;
      if (arg is PenggunaanEnergi) {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => DetailScreen(item: arg),
        );
      }
      // Jika argument tidak valid, kembalikan null agar ditangani onUnknownRoute
      return null;

    // ── CatatanForm ─────────────────────────────────────────────────────────
    case AppRoutes.catatanForm:
      // Argument: String? (catatan awal) – boleh null untuk catatan baru
      // Menggunakan MaterialPageRoute<String> karena mengembalikan String
      final argCatatan = settings.arguments;
      return MaterialPageRoute<String>(
        settings: settings,
        builder: (_) => CatatanFormScreen(
          catatanAwal: argCatatan is String ? argCatatan : null,
        ),
      );

    // ── 404 – Route tidak dikenal ────────────────────────────────────────────
    default:
      return null; // Route tidak terdaftar -> serahkan ke onUnknownRoute di main.dart
  }
}
