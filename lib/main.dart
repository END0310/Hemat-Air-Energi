import 'package:flutter/material.dart';
import 'core/app_colors.dart';
import 'screens/device_list_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HematEnergiApp());
}

class HematEnergiApp extends StatelessWidget {
  const HematEnergiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hemat Energi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.surface,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryGreen,
          primary: AppColors.primaryGreen,
          surface: AppColors.surface,
          error: AppColors.errorRed,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      home: const DeviceListScreen(),
    );
  }
}
