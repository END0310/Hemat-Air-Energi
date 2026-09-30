import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/app_colors.dart';
import 'routes/app_routes.dart'; // generator route terpusat
import 'screens/not_found_screen.dart'; // untuk onUnknownRoute

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const HematAirEnergiApp());
}

class HematAirEnergiApp extends StatelessWidget {
  const HematAirEnergiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hemat Air & Energi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryBlue,
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(),
        scaffoldBackgroundColor: AppColors.background,
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      ),
      initialRoute: AppRoutes.login,        // route awal: LoginScreen (sesuai Modul Langkah 6 & 9)
      onGenerateRoute: onGenerateRoute,      // semua named route lewat sini
      onUnknownRoute: (settings) =>          // fallback jika route tidak dikenal
          MaterialPageRoute<void>(
            builder: (_) => NotFoundScreen(routeName: settings.name),
          ),

    );
  }
}
