import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _tipDismissed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _DashboardTab(
            tipDismissed: _tipDismissed,
            onDismissTip: () => setState(() => _tipDismissed = true),
          ),
          const _CatatanTab(),
          const _TargetTab(),
          const _TipsTab(),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => _showCatatDialog(context),
              backgroundColor: AppColors.primaryGreen,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                'Catat Penggunaan',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              elevation: 4,
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }

  void _showCatatDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CatatBottomSheet(),
    );
  }
}

// ─── Dashboard Tab ───────────────────────────────────────────────────────────

class _DashboardTab extends StatelessWidget {
  final bool tipDismissed;
  final VoidCallback onDismissTip;
  const _DashboardTab(
      {required this.tipDismissed, required this.onDismissTip});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // AppBar custom
        SliverToBoxAdapter(child: _DashboardAppBar()),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 12),
              // Greeting row
              _GreetingRow(),
              const SizedBox(height: 24),
              // Weekly cards
              _WeeklySnapshotCards(),
              const SizedBox(height: 24),
              // Monthly target
              _MonthlyTargetSection(),
              const SizedBox(height: 24),
              // Roommate section
              _RoommateSection(),
              const SizedBox(height: 24),
              // Tip card
              if (!tipDismissed) _TipCard(onDismiss: onDismissTip),
              if (!tipDismissed) const SizedBox(height: 24),
              // Activity
              _ActivitySection(),
            ]),
          ),
        ),
      ],
    );
  }
}

class _DashboardAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ANAK KOS SMART',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryBlue,
                          letterSpacing: 0.8)),
                  Text('Dashboard',
                      style: AppTextStyles.heading2.copyWith(fontSize: 20)),
                ],
              ),
              Row(
                children: [
                  _IconButton(icon: Icons.notifications_outlined,
                      onTap: () {}),
                  const SizedBox(width: 8),
                  _AvatarButton(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.bluePastelLight.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: AppColors.primaryBlue),
      ),
    );
  }
}

class _AvatarButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.bluePastelLight,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3), width: 1.5),
      ),
      child: const Icon(Icons.person, color: AppColors.primaryBlue, size: 20),
    );
  }
}

// ─── Greeting Row ─────────────────────────────────────────────────────────────

class _GreetingRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Selamat Pagi!',
                style: AppTextStyles.heading2.copyWith(fontSize: 22)),
            const SizedBox(height: 2),
            Text('Minggu ini hemat lebih banyak yuk 🌱',
                style: AppTextStyles.bodyMedium),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.greenMint.withOpacity(0.4),
            borderRadius: BorderRadius.circular(9999),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1))
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primaryGreen,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text('Lantai 2',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryGreen,
                    letterSpacing: 0.4,
                  )),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Weekly Cards ─────────────────────────────────────────────────────────────

class _WeeklySnapshotCards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            sdgLabel: 'SDG 6',
            sdgColor: AppColors.primaryBlue,
            sdgBgColor: AppColors.bluePastelMed,
            iconBg: AppColors.bluePastel,
            iconColor: AppColors.primaryBlue,
            iconData: Icons.water_drop,
            label: 'Air Minggu Ini',
            value: '245',
            unit: 'Liter',
            trendUp: false,
            trendPercent: '12%',
            trendLabel: 'vs mgg lalu',
            glowColor: AppColors.bluePastel.withOpacity(0.3),
            accentColor: AppColors.primaryBlue,
            badgeBg: AppColors.bluePastelMed,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MetricCard(
            sdgLabel: 'SDG 7',
            sdgColor: AppColors.amber,
            sdgBgColor: AppColors.amberPastel.withOpacity(0.6),
            iconBg: AppColors.amberPastel,
            iconColor: AppColors.amber,
            iconData: Icons.bolt,
            label: 'Listrik Minggu Ini',
            value: '18.4',
            unit: 'kWh',
            trendUp: true,
            trendPercent: '4%',
            trendLabel: 'vs mgg lalu',
            glowColor: AppColors.amberPastel.withOpacity(0.4),
            accentColor: AppColors.amber,
            badgeBg: AppColors.amberPastel.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String sdgLabel;
  final Color sdgColor;
  final Color sdgBgColor;
  final Color iconBg;
  final Color iconColor;
  final IconData iconData;
  final String label;
  final String value;
  final String unit;
  final bool trendUp;
  final String trendPercent;
  final String trendLabel;
  final Color glowColor;
  final Color accentColor;
  final Color badgeBg;

  const _MetricCard({
    required this.sdgLabel,
    required this.sdgColor,
    required this.sdgBgColor,
    required this.iconBg,
    required this.iconColor,
    required this.iconData,
    required this.label,
    required this.value,
    required this.unit,
    required this.trendUp,
    required this.trendPercent,
    required this.trendLabel,
    required this.glowColor,
    required this.accentColor,
    required this.badgeBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: AppColors.textDark.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
            spreadRadius: -1,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Glow top-right
          Positioned(
            right: -12,
            top: -12,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: glowColor,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon row + SDG badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: iconBg,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        )
                      ],
                    ),
                    child: Icon(iconData, color: iconColor, size: 18),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(sdgLabel,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: sdgColor,
                          letterSpacing: 0.4,
                        )),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Label
              Text(label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMedium,
                    letterSpacing: 0.24,
                  )),
              const SizedBox(height: 4),
              // Value + unit
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(value, style: AppTextStyles.metricValue),
                  const SizedBox(width: 4),
                  Text(unit,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMedium,
                      )),
                ],
              ),
              const SizedBox(height: 10),
              // Trend
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: trendUp
                          ? AppColors.amberPastel.withOpacity(0.5)
                          : AppColors.greenMint.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          trendUp
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          size: 9,
                          color: trendUp
                              ? AppColors.amber
                              : AppColors.primaryGreen,
                        ),
                        Text(
                          trendPercent,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: trendUp
                                ? AppColors.amber
                                : AppColors.primaryGreen,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(trendLabel,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMedium,
                        letterSpacing: 0.4,
                      )),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Monthly Target ───────────────────────────────────────────────────────────

class _MonthlyTargetSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.track_changes,
                    color: AppColors.primaryBlue, size: 18),
                const SizedBox(width: 6),
                Text('Target Bulan Ini',
                    style: AppTextStyles.heading3),
              ],
            ),
            GestureDetector(
              onTap: () {},
              child: Row(
                children: [
                  Text('Atur Target',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryBlue,
                        letterSpacing: 0.24,
                      )),
                  const Icon(Icons.chevron_right,
                      color: AppColors.primaryBlue, size: 16),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(0.06),
                blurRadius: 24,
                offset: const Offset(0, 8),
                spreadRadius: -4,
              ),
              BoxShadow(
                color: AppColors.textDark.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
                spreadRadius: -1,
              ),
            ],
          ),
          child: Column(
            children: [
              // Water Goal
              _GoalProgressRow(
                icon: Icons.water_drop,
                iconColor: AppColors.primaryBlue,
                label: 'Konsumsi Air: 720 / 1.000 L',
                badgeLabel: '72%',
                badgeBg: AppColors.bluePastel,
                badgeText: AppColors.primaryBlue,
                progress: 0.72,
                progressColor: AppColors.primaryBlue,
                tipText: 'Sisa kuota aman untuk 9 hari ke depan',
                remainLabel: '280 L sisa',
                accentColor: AppColors.primaryBlue,
              ),
              const SizedBox(height: 16),
              Divider(height: 1, color: AppColors.blueBackground),
              const SizedBox(height: 16),
              // Electricity Goal
              _GoalProgressRow(
                icon: Icons.bolt,
                iconColor: AppColors.primaryGreen,
                label: 'Konsumsi Listrik: 65 / 100 kWh',
                badgeLabel: '65%',
                badgeBg: AppColors.greenMint.withOpacity(0.5),
                badgeText: AppColors.primaryGreen,
                progress: 0.65,
                progressColor: AppColors.primaryGreen,
                tipText: 'Hemat 35 kWh untuk bonus kredit kos!',
                remainLabel: '35 kWh sisa',
                accentColor: AppColors.primaryGreen,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GoalProgressRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String badgeLabel;
  final Color badgeBg;
  final Color badgeText;
  final double progress;
  final Color progressColor;
  final String tipText;
  final String remainLabel;
  final Color accentColor;

  const _GoalProgressRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.badgeLabel,
    required this.badgeBg,
    required this.badgeText,
    required this.progress,
    required this.progressColor,
    required this.tipText,
    required this.remainLabel,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 14),
                const SizedBox(width: 6),
                Text(label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                      letterSpacing: 0.24,
                    )),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Text(badgeLabel,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: badgeText,
                    letterSpacing: 0.4,
                  )),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Progress bar
        Container(
          height: 12,
          decoration: BoxDecoration(
            color: AppColors.blueBackground,
            borderRadius: BorderRadius.circular(9999),
          ),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: LayoutBuilder(
              builder: (ctx, constraints) => Align(
                alignment: Alignment.centerLeft,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  width: constraints.maxWidth * progress,
                  height: 8,
                  decoration: BoxDecoration(
                    color: progressColor,
                    borderRadius: BorderRadius.circular(9999),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        // Tip row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: accentColor, size: 12),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(tipText,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: accentColor,
                          letterSpacing: 0.4,
                        ),
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),
            Text(remainLabel,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textLight,
                  letterSpacing: 0.4,
                )),
          ],
        ),
      ],
    );
  }
}

// ─── Roommate Section ─────────────────────────────────────────────────────────

class _RoommateSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.group_outlined,
                    color: AppColors.primaryGreen, size: 20),
                const SizedBox(width: 6),
                Text('Pikett Air & Galon Bersama',
                    style: AppTextStyles.heading3),
              ],
            ),
            Text('Lantai 2',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMedium,
                  letterSpacing: 0.4,
                )),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(0.06),
                blurRadius: 24,
                offset: const Offset(0, 8),
                spreadRadius: -4,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Avatar with status dot
                  Stack(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.bluePastelLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person,
                            color: AppColors.primaryBlue, size: 26),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen,
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Giliran: Gilang (Kamar 10)',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          )),
                      Text('Refill galon air & bersihkan dispenser',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textMedium,
                          )),
                    ],
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.bluePastelMed,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Text('Ingatkan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryBlue,
                        letterSpacing: 0.4,
                      )),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Tip Card ─────────────────────────────────────────────────────────────────

class _TipCard extends StatelessWidget {
  final VoidCallback onDismiss;
  const _TipCard({required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.tipCardGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lightbulb_outline,
                color: AppColors.primaryBlue, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TIPS HEMAT ANAK KOS',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryBlue,
                      letterSpacing: 0.8,
                    )),
                const SizedBox(height: 4),
                Text(
                  'Matikan colokan rice cooker setelah nasi matang! Menghangatkan seharian menyedot hingga 5 kWh/minggu setara Rp7.500.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: Icon(Icons.close,
                size: 18, color: AppColors.textMedium.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }
}

// ─── Activity Section ─────────────────────────────────────────────────────────

class _ActivitySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final activities = [
      _ActivityItem(
        icon: Icons.electric_bolt,
        iconBg: AppColors.amberPastel,
        iconColor: AppColors.amber,
        title: 'Beli Token Listrik Kos',
        subtitle: 'Kemarin, 19:30 • +50.0 kWh',
        amount: 'Rp 82.500',
        amountColor: AppColors.amber,
      ),
      _ActivityItem(
        icon: Icons.water_drop,
        iconBg: AppColors.bluePastel,
        iconColor: AppColors.primaryBlue,
        title: 'Catat Meteran Air Mandi',
        subtitle: '22 Okt, 07:15 • Kamar 10',
        amount: '+12 L',
        amountColor: AppColors.primaryBlue,
      ),
      _ActivityItem(
        icon: Icons.battery_charging_full,
        iconBg: AppColors.greenMint.withOpacity(0.3),
        iconColor: AppColors.primaryGreen,
        title: 'Hemat Listrik AC Mati',
        subtitle: '21 Okt, 22:00 • -2.5 kWh',
        amount: '-2.5 kWh',
        amountColor: AppColors.primaryGreen,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('AKTIVITAS TERAKHIR',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppColors.textLight,
              letterSpacing: 0.8,
            )),
        const SizedBox(height: 10),
        ...activities
            .map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: a,
                ))
            ,
      ],
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String amount;
  final Color amountColor;

  const _ActivityItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.amountColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    )),
                Text(subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppColors.textMedium,
                    )),
              ],
            ),
          ),
          Text(amount,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: amountColor,
              )),
        ],
      ),
    );
  }
}

// ─── Bottom Nav ───────────────────────────────────────────────────────────────

class _AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _AppBottomNavBar(
      {required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
      _NavItem(icon: Icons.edit_note_rounded, label: 'Catatan'),
      _NavItem(icon: Icons.track_changes_rounded, label: 'Target'),
      _NavItem(icon: Icons.tips_and_updates_rounded, label: 'Tips'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              // Leave center space for FAB
              if (i == 2 && currentIndex == 0) {
                return const SizedBox(width: 70);
              }
              final selected = currentIndex == i;
              return GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: selected
                      ? BoxDecoration(
                          color: AppColors.primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        )
                      : null,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        items[i].icon,
                        color: selected
                            ? AppColors.primaryBlue
                            : AppColors.textLight,
                        size: 24,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        items[i].label,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: selected
                              ? AppColors.primaryBlue
                              : AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  _NavItem({required this.icon, required this.label});
}

// ─── Other Tabs (Stubs) ───────────────────────────────────────────────────────

class _CatatanTab extends StatelessWidget {
  const _CatatanTab();

  @override
  Widget build(BuildContext context) {
    return _PlaceholderTab(
      icon: Icons.edit_note_rounded,
      color: AppColors.primaryBlue,
      title: 'Catatan Penggunaan',
      subtitle: 'Riwayat pencatatan air & listrik kamu.',
    );
  }
}

class _TargetTab extends StatelessWidget {
  const _TargetTab();

  @override
  Widget build(BuildContext context) {
    return _PlaceholderTab(
      icon: Icons.track_changes_rounded,
      color: AppColors.primaryGreen,
      title: 'Atur Target',
      subtitle: 'Tetapkan target bulanan hemat air & listrik.',
    );
  }
}

class _TipsTab extends StatelessWidget {
  const _TipsTab();

  @override
  Widget build(BuildContext context) {
    return _PlaceholderTab(
      icon: Icons.tips_and_updates_rounded,
      color: AppColors.amber,
      title: 'Tips Hemat',
      subtitle: 'Kumpulan tips hemat air & energi anak kos.',
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  const _PlaceholderTab(
      {required this.icon,
      required this.color,
      required this.title,
      required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 36),
              ),
              const SizedBox(height: 20),
              Text(title,
                  style: AppTextStyles.heading3
                      .copyWith(color: AppColors.textDark)),
              const SizedBox(height: 8),
              Text(subtitle,
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Catat Bottom Sheet ───────────────────────────────────────────────────────

class _CatatBottomSheet extends StatefulWidget {
  const _CatatBottomSheet();

  @override
  State<_CatatBottomSheet> createState() => _CatatBottomSheetState();
}

class _CatatBottomSheetState extends State<_CatatBottomSheet> {
  int _selectedType = 0; // 0=Air, 1=Listrik
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.blueBackground,
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Catat Penggunaan',
              style: AppTextStyles.heading3
                  .copyWith(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          // Toggle
          Row(
            children: [
              Expanded(
                child: _TypeButton(
                  label: '💧 Air',
                  selected: _selectedType == 0,
                  onTap: () => setState(() => _selectedType = 0),
                  selectedColor: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TypeButton(
                  label: '⚡ Listrik',
                  selected: _selectedType == 1,
                  onTap: () => setState(() => _selectedType = 1),
                  selectedColor: AppColors.amber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Input
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: _selectedType == 0 ? 'Jumlah (Liter)' : 'Jumlah (kWh)',
              filled: true,
              fillColor: AppColors.blueBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              suffixText: _selectedType == 0 ? 'L' : 'kWh',
              suffixStyle: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: _selectedType == 0
                    ? AppColors.primaryBlue
                    : AppColors.amber,
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedType == 0
                    ? AppColors.primaryBlue
                    : AppColors.amber,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              onPressed: () => Navigator.pop(context),
              child: Text('Simpan',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  )),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color selectedColor;

  const _TypeButton({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? selectedColor : AppColors.blueBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(label,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: selected ? Colors.white : AppColors.textMedium,
              )),
        ),
      ),
    );
  }
}
