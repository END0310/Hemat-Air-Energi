import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _fadeController;
  late AnimationController _loadingController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _logoScale = CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );
    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _logoController.forward().then((_) {
      _fadeController.forward();
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, _, _) => const HomeScreen(),
            transitionsBuilder: (_, anim, _, child) => FadeTransition(
              opacity: anim,
              child: child,
            ),
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _fadeController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.splashGradient,
        ),
        child: Stack(
          children: [
            // Top-left glow orb
            Positioned(
              left: -80,
              top: -96,
              child: Container(
                width: 288,
                height: 288,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.greenMint.withOpacity(0.2),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
            // Bottom-right glow orb
            Positioned(
              right: -80,
              bottom: -80,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.bluePastel.withOpacity(0.2),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  // SDG Badge top
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: _SdgBadge(),
                  ),

                  const Spacer(),

                  // Logo + Heading
                  Column(
                    children: [
                      ScaleTransition(
                        scale: _logoScale,
                        child: FadeTransition(
                          opacity: _logoOpacity,
                          child: const _LogoWidget(),
                        ),
                      ),
                      const SizedBox(height: 28),
                      FadeTransition(
                        opacity: _fadeIn,
                        child: Column(
                          children: [
                            Text(
                              'Hemat Air & Energi',
                              style: AppTextStyles.heading1,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Catat, Hemat, Jaga Bumi',
                              style: AppTextStyles.splashSubtitle,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      FadeTransition(
                        opacity: _fadeIn,
                        child: const _SdgPillBadge(),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Loading + Version
                  FadeTransition(
                    opacity: _fadeIn,
                    child: _BottomSection(
                        loadingController: _loadingController),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SdgBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(9999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.greenMint,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'SDG 6 & SDG 7 INITIATIVE',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoWidget extends StatelessWidget {
  const _LogoWidget();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 144,
      height: 144,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.25),
            ),
          ),
          // Glass card container
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                width: 144,
                height: 144,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: Colors.white.withOpacity(0.1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 25,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: Center(
                  child: CustomPaint(
                    size: const Size(100, 100),
                    painter: _LogoPainter(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Water drop
    final dropPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF6FFBBE), Color(0xFF007BB9)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final dropPath = Path();
    dropPath.moveTo(cx, cy - 38);
    dropPath.cubicTo(cx + 30, cy - 12, cx + 30, cy + 18, cx, cy + 38);
    dropPath.cubicTo(cx - 30, cy + 18, cx - 30, cy - 12, cx, cy - 38);
    canvas.drawPath(dropPath, dropPaint);

    // Lightning bolt
    final boltPaint = Paint()
      ..color = Colors.white.withOpacity(0.95)
      ..style = PaintingStyle.fill;

    final boltPath = Path();
    boltPath.moveTo(cx + 7, cy - 20);
    boltPath.lineTo(cx - 8, cy + 2);
    boltPath.lineTo(cx + 2, cy + 2);
    boltPath.lineTo(cx - 7, cy + 20);
    boltPath.lineTo(cx + 10, cy - 2);
    boltPath.lineTo(cx + 0, cy - 2);
    boltPath.close();
    canvas.drawPath(boltPath, boltPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SdgPillBadge extends StatelessWidget {
  const _SdgPillBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.water_drop, color: Colors.white, size: 13),
          const SizedBox(width: 5),
          Text(
            'Air Bersih',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '•',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          const SizedBox(width: 6),
          Icon(Icons.bolt, color: AppColors.greenMint, size: 13),
          const SizedBox(width: 4),
          Text(
            'Energi Terjangkau',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomSection extends StatelessWidget {
  final AnimationController loadingController;
  const _BottomSection({required this.loadingController});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: loadingController,
              builder: (_, _) => SizedBox(
                width: 24,
                height: 24,
                child: CustomPaint(
                  painter: _LoadingArcPainter(loadingController.value),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Memuat data konsumsi...',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: const Color(0xD9EAF1FF),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('V1.0.0',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xB3EAF1FF),
                    letterSpacing: 0.5)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text('•',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xB3EAF1FF))),
            ),
            Text('Solusi Kos Berkelanjutan',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xB3EAF1FF),
                    letterSpacing: 0.5)),
          ],
        ),
      ],
    );
  }
}

class _LoadingArcPainter extends CustomPainter {
  final double progress;
  _LoadingArcPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = math.min(cx, cy) - 2;

    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(Offset(cx, cy), radius, bgPaint);

    final arcPaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      -math.pi / 2 + (2 * math.pi * progress),
      math.pi * 0.75,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(_LoadingArcPainter old) => old.progress != progress;
}
