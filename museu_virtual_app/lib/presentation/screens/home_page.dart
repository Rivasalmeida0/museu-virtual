import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import 'gallery_page.dart';
import 'streaming_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final _pages = const [
    _MuseumHomeContent(),
    GalleryPage(),
    StreamingPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildTopBar(),
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: _BottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
      ),
    );
  }

  PreferredSizeWidget _buildTopBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.background.withValues(alpha: 0.8),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    Text(
                      AppStrings.appName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        color: AppColors.primary,
                      ),
                    ),
                    const Spacer(),
                    _TopIcon(icon: Icons.search),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopIcon extends StatelessWidget {
  final IconData icon;
  const _TopIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
      ),
    );
  }
}

class _MuseumHomeContent extends StatelessWidget {
  const _MuseumHomeContent();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 768;
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            isWide ? 48 : 16, 80, isWide ? 48 : 16, 100,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1280),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroSection(),
                const SizedBox(height: 48),
                _CategoryRow(isWide: isWide),
                const SizedBox(height: 48),
                _AboutSection(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MUSEU VIRTUAL DE COMPUTADORES',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.05 * 13,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'A História da Computação\nem Angola e no Mundo',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.02 * 32,
            height: 1.1,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: Text(
            'Dos primeiros gigantes de válvulas aos supercomputadores exascale. '
            'Uma coleção curada das máquinas que definiram a era digital.',
            style: const TextStyle(
              fontSize: 16,
              height: 1.6,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            _StatBadge(
              icon: Icons.computer,
              value: '25+',
              label: 'Peças',
            ),
            const SizedBox(width: 16),
            _StatBadge(
              icon: Icons.history,
              value: '1941',
              label: 'Ano mais antigo',
            ),
            const SizedBox(width: 16),
            _StatBadge(
              icon: Icons.speed,
              value: '2+',
              label: 'Exaflops',
            ),
          ],
        ),
      ],
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatBadge({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final bool isWide;
  const _CategoryRow({required this.isWide});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Explorar Coleções',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        if (isWide)
          Row(
            children: [
              Expanded(child: _CategoryCard(
                icon: Icons.computer,
                title: 'Computadores Históricos',
                subtitle: 'Dos anos 40 aos 80',
                color: AppColors.primary,
                onTap: () {},
              )),
              const SizedBox(width: 16),
              Expanded(child: _CategoryCard(
                icon: Icons.dns,
                title: 'Supercomputadores',
                subtitle: 'Poder exascale',
                color: AppColors.angolaGold,
                onTap: () {},
              )),
              const SizedBox(width: 16),
              Expanded(child: _CategoryCard(
                icon: Icons.live_tv,
                title: 'Streaming ao Vivo',
                subtitle: 'Visitas guiadas',
                color: AppColors.angolaRed,
                onTap: () {},
              )),
            ],
          )
        else
          Column(
            children: [
              _CategoryCard(
                icon: Icons.computer,
                title: 'Computadores Históricos',
                subtitle: 'Dos anos 40 aos 80',
                color: AppColors.primary,
                onTap: () {},
              ),
              const SizedBox(height: 12),
              _CategoryCard(
                icon: Icons.dns,
                title: 'Supercomputadores',
                subtitle: 'Poder exascale',
                color: AppColors.angolaGold,
                onTap: () {},
              ),
              const SizedBox(height: 12),
              _CategoryCard(
                icon: Icons.live_tv,
                title: 'Streaming ao Vivo',
                subtitle: 'Visitas guiadas',
                color: AppColors.angolaRed,
                onTap: () {},
              ),
            ],
          ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.15)),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.04),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 14, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flag, color: AppColors.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                'Museu Virtual de Angola',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Um projeto dedicado à preservação e divulgação da história da '
            'computação, com identidade visual inspirada nas cores da bandeira '
            'de Angola — vermelho, preto e dourado.',
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: AppColors.textBody,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _AngolaColorBar(color: AppColors.angolaRed),
              const SizedBox(width: 4),
              _AngolaColorBar(color: AppColors.angolaBlack),
              const SizedBox(width: 4),
              _AngolaColorBar(color: AppColors.angolaGold),
            ],
          ),
        ],
      ),
    );
  }
}

class _AngolaColorBar extends StatelessWidget {
  final Color color;
  const _AngolaColorBar({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4,
      width: 60,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _BottomNavBar({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.background.withValues(alpha: 0.8),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.05),
                blurRadius: 30,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    icon: Icons.home_rounded,
                    label: 'Início',
                    isSelected: selectedIndex == 0,
                    onTap: () => onTap(0),
                  ),
                  _NavItem(
                    icon: Icons.computer,
                    label: 'Galeria',
                    isSelected: selectedIndex == 1,
                    onTap: () => onTap(1),
                  ),
                  _NavItem(
                    icon: Icons.live_tv,
                    label: 'Streaming',
                    isSelected: selectedIndex == 2,
                    onTap: () => onTap(2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: isSelected ? 16 : 8,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryVeryLight : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 24,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.05 * 11,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
