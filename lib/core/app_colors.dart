import 'package:flutter/material.dart';

class AppColors {
  // Primary Blues (Air / SDG 6)
  static const Color primaryBlue = Color(0xFF006194);
  static const Color primaryBlueMid = Color(0xFF007BB9);
  static const Color bluePastel = Color(0xFFCCE5FF);
  static const Color bluePastelLight = Color(0xFFDCE9FF);
  static const Color bluePastelMed = Color(0xFFD3E4FE);
  static const Color blueBackground = Color(0xFFE5EEFF);

  // Primary Greens (Energi / SDG 7)
  static const Color primaryGreen = Color(0xFF006C49);
  static const Color greenMint = Color(0xFF6FFBBE);
  static const Color greenMintBg = Color(0xFF6CF8BB);

  // Amber / Electricity
  static const Color amber = Color(0xFF825100);
  static const Color amberPastel = Color(0xFFFFDDB8);

  // Dark Text
  static const Color textDark = Color(0xFF0B1C30);
  static const Color textMedium = Color(0xFF3F4850);
  static const Color textLight = Color(0xFF707881);

  // Background
  static const Color background = Color(0xFFF8F9FF);
  static const Color white = Colors.white;

  // Gradient
  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF006194), Color(0xFF007BB9), Color(0xFF006C49)],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient tipCardGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFDCE9FF), Color(0xFFD3E4FE)],
  );
}
