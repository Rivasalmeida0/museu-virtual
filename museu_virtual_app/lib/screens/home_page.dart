import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: _buildTopBar(),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 768;
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                isWide ? 48 : 16,
                80,
                isWide ? 48 : 16,
                100,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1280),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeroSection(),
                    const SizedBox(height: 48),
                    _TimelineGallery(isWide: isWide),
                  ],
                ),
              ),
            );
          },
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
              color: const Color(0xFFF7F9FB).withValues(alpha: 0.8),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0041C8).withValues(alpha: 0.05),
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
                    _TopIcon(icon: Icons.menu),
                    const SizedBox(width: 16),
                    Text(
                      'AngoTech Museu',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        color: const Color(0xFF0041C8),
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

// ─── Shared small widgets ────────────────────────────────────────────────────

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
          child: Icon(icon, color: const Color(0xFF0041C8), size: 24),
        ),
      ),
    );
  }
}

// ─── Hero Section ────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final centered = constraints.maxWidth >= 768;
        return Column(
          crossAxisAlignment:
              centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            Text(
              'Jornada Evolutiva'.toUpperCase(),
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.05 * 13,
                color: const Color(0xFF0041C8),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Rastreando o Pulso do Silício',
              textAlign: centered ? TextAlign.center : TextAlign.left,
              style: TextStyle(
                fontSize: centered ? 48 : 32,
                fontWeight: FontWeight.w700,
                letterSpacing: centered ? -0.02 * 48 : -0.02 * 32,
                height: 1.1,
                color: const Color(0xFF191C1E),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: centered ? 560 : double.infinity,
              child: Text(
                'Uma odisseia vertical curada pelas máquinas que definiram a capacidade humana. Role para atravessar décadas de inovação.',
                textAlign: centered ? TextAlign.center : TextAlign.left,
                style: TextStyle(
                  fontSize: 18,
                  height: 1.6,
                  color: const Color(0xFF515F78),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Timeline Gallery ────────────────────────────────────────────────────────

class _TimelineGallery extends StatelessWidget {
  final bool isWide;
  const _TimelineGallery({required this.isWide});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (isWide)
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: Container(
                width: 1,
                color: const Color(0xFFC3C5D9),
              ),
            ),
          ),
        Column(
          children: [
            _EraSection(
              isWide: isWide,
              eraLabel: 'Anos 40 — 1950',
              title: 'A Era dos Gigantes',
              description:
                  'Behemoths de tubos de vácuo do tamanho de salas que calcularam as primeiras trajetórias matemáticas complexas da era moderna.',
              buttonLabel: 'Explorar ENIAC',
              buttonOutlined: true,
              imageUrl:
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuByblnADO9XCv08fqBcipyEoB1Fa3k5qr8VuSeo_JCtI5VK0u5M-1F-tipRAaRCWOVfVIGSG5GfbgA7bTJCbQxkz5wMWA07BS4L1eVkkjqJmi8GQGCGK6VvCDeOYcwrPF6E0TeORJ9YqMO7BwtMdpl_1JvICsSA-GHfhghZ2lSIku1hF25kEp1lcrTMvgoufGu4lEuuDp37HBTQPn4uHgbRcqEwFqw8b2pfueVo46xidzPpcbcceG1qbmUWJj-bz-GXfonUxYK7K8dr',
              imageGrayscale: true,
              hasHotspot: true,
              textRight: true,
            ),
            const SizedBox(height: 48),
            _EraSection(
              isWide: isWide,
              eraLabel: 'Anos 70 — 1980',
              title: 'Libertação Pessoal',
              description:
                  'Quando o terminal saiu do laboratório para a sala de estar. Uma revolução de interfaces acessíveis e gabinetes de plástico.',
              buttonLabel: 'Tour Virtual',
              buttonOutlined: false,
              imageUrl:
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuC7yr8FCSw1Z7-Q_Em9yH4ubbGXnnu8Ck0w05ME3UIK6TF00YK1zQ4i1H6iAZwHoRpv9G1whzIrUDFHH63C-bbr9o94DQzqvfKUKQC1wsdDjgyNXcTMUzDZv75XX55ottmWg_N6ZHbQtjHqRgo_T3_bl9gBRiMA7WHJ2rgK9vlm8Tpw-ZJJ33lz7KYicpbepztna8-TfTmEHCE02RJ4Ja0g6Ea9wqOEebMYFF9LUjIc9nFsNhZS9B9LofSeYMvlOvpJj_OEnKOwx0qM',
              imageGrayscale: false,
              hasLabel: true,
              textRight: false,
            ),
            const SizedBox(height: 48),
            _EraSection(
              isWide: isWide,
              eraLabel: 'Anos 90 — Presente',
              title: 'Lógica de Hiperscala',
              description:
                  'Processamento paralelo em escalas arquitetônicas. O design da velocidade e a estética do resfriamento de data centers.',
              buttonLabel: null,
              buttonOutlined: false,
              imageUrl:
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuAjmvntaV-qN1VGC68Ioa8QH31rNkRB1bQ5gE4JOt0MyKUE0DzwIF2HZe96eX2Xq3eHSjQhJq21n3yVW_RB3ouj20Iih-jibGC_GRlRPAh4VItUB5z5Y1GgsfkNgrKLSmpzW34ZvOWWSaUurjdFFi6GT_-ICFplGfUomV7S50PDBkpnjNJfSSdoFxd43lbLdFJuzEym-vNtZOQjg5cm7sdk2nzA5x6jIJjjtUYneEnqS-N45vltykz0j_cqFITcUKXlLBGSlWcOR0gB',
              imageGrayscale: false,
              hasGradientOverlay: true,
              textRight: true,
              showStats: true,
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Era Section ─────────────────────────────────────────────────────────────

class _EraSection extends StatefulWidget {
  final bool isWide;
  final String eraLabel;
  final String title;
  final String description;
  final String? buttonLabel;
  final bool buttonOutlined;
  final String imageUrl;
  final bool imageGrayscale;
  final bool hasHotspot;
  final bool hasLabel;
  final bool hasGradientOverlay;
  final bool textRight;
  final bool showStats;

  const _EraSection({
    required this.isWide,
    required this.eraLabel,
    required this.title,
    required this.description,
    this.buttonLabel,
    required this.buttonOutlined,
    required this.imageUrl,
    this.imageGrayscale = false,
    this.hasHotspot = false,
    this.hasLabel = false,
    this.hasGradientOverlay = false,
    required this.textRight,
    this.showStats = false,
  });

  @override
  State<_EraSection> createState() => _EraSectionState();
}

class _EraSectionState extends State<_EraSection> {
  bool _hovered = false;

  void _showEniacSpecs() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFF7F9FB),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'ENIAC — Especificação Técnica',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0041C8),
          ),
        ),
        content: const Text(
          'O ENIAC utilizava mais de 17.000 tubos de vácuo e ocupava cerca de 167 metros quadrados.',
          style: TextStyle(
            fontSize: 15,
            height: 1.6,
            color: Color(0xFF434656),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isWide) return _buildMobile();
    return _buildDesktop();
  }

  Widget _buildMobile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextContent(),
        const SizedBox(height: 24),
        _buildImageCard(),
      ],
    );
  }

  Widget _buildDesktop() {
    final textCol = Expanded(child: _buildTextContent());
    final imageCol = Expanded(child: _buildImageCard());

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: widget.textRight
          ? [textCol, const SizedBox(width: 24), imageCol]
          : [imageCol, const SizedBox(width: 24), textCol],
    );
  }

  Widget _buildTextContent() {
    return Column(
      crossAxisAlignment: widget.isWide && widget.textRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          widget.eraLabel,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.05 * 13,
            color: Color(0xFF0055FF),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.title,
          style: TextStyle(
            fontSize: widget.isWide ? 28 : 24,
            fontWeight: FontWeight.w600,
            height: 1.3,
            color: const Color(0xFF191C1E),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          widget.description,
          style: const TextStyle(
            fontSize: 15,
            height: 1.6,
            color: Color(0xFF515F78),
          ),
        ),
        if (widget.showStats) ...[
          const SizedBox(height: 16),
          _StatsRow(),
        ],
        if (widget.buttonLabel != null) ...[
          const SizedBox(height: 16),
          _buildButton(),
        ],
      ],
    );
  }

  Widget _buildButton() {
    if (widget.buttonOutlined) {
      return OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.explore, size: 16),
        label: Text(widget.buttonLabel!),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF0041C8),
          side: const BorderSide(color: Color(0xFF0041C8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: TextStyle(
            fontFamily: 'monospace',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.05 * 13,
          ),
        ),
      );
    }
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0041C8),
        foregroundColor: const Color(0xFFFFFFFF),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 0,
        textStyle: TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.05 * 13,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.buttonLabel!),
          const SizedBox(width: 8),
          const Icon(Icons.vrpano, size: 16),
        ],
      ),
    );
  }

  Widget _buildImageCard() {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOut,
            height: widget.isWide ? 260 : 220,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFFF2F4F6),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0041C8).withValues(alpha: 0.05),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
              image: DecorationImage(
                image: NetworkImage(widget.imageUrl),
                fit: BoxFit.cover,
                colorFilter: widget.imageGrayscale && !_hovered
                    ? const ColorFilter.matrix(<double>[
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0, 0, 0, 0.6, 0,
                      ])
                    : null,
              ),
            ),
            transform: _hovered
                ? (Matrix4.diagonal3Values(1.05, 1.05, 1.05))
                : Matrix4.identity(),
            transformAlignment: Alignment.center,
          ),
          // hover overlay (era 1)
          if (widget.imageGrayscale)
            Positioned.fill(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: _hovered ? 1.0 : 0.0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFF0041C8).withValues(alpha: 0.1),
                  ),
                ),
              ),
            ),
          // gradient overlay (era 3)
          if (widget.hasGradientOverlay)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      const Color(0xFF0041C8).withValues(alpha: 0.2),
                    ],
                  ),
                ),
              ),
            ),
          // hotspot (era 1)
          if (widget.hasHotspot)
            Positioned(
              top: 65,
              right: 65,
              child: _HotspotPulse(onTap: _showEniacSpecs),
            ),
          // label (era 2)
          if (widget.hasLabel)
            Positioned(
              bottom: 16,
              left: 16,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Artefato #082: Macintosh 128K',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: Color(0xFF0041C8),
                      ),
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

// ─── Hotspot Pulse ───────────────────────────────────────────────────────────

class _HotspotPulse extends StatefulWidget {
  final VoidCallback onTap;
  const _HotspotPulse({required this.onTap});

  @override
  State<_HotspotPulse> createState() => _HotspotPulseState();
}

class _HotspotPulseState extends State<_HotspotPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: 32,
        height: 32,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + _controller.value * 1.5,
                  child: Opacity(
                    opacity: 1.0 - _controller.value,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF0041C8),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF0041C8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Stats Row (Era 3) ───────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(label: 'Poder de Pico', value: '1.1 Exaflops'),
        const SizedBox(width: 8),
        _StatCard(label: 'Nós', value: '9.408'),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              color: Color(0xFF515F78),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0041C8),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom Navigation ───────────────────────────────────────────────────────

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
            color: const Color(0xFFF7F9FB).withValues(alpha: 0.8),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0041C8).withValues(alpha: 0.05),
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
                    icon: Icons.history_edu,
                    label: 'Linha do Tempo',
                    isSelected: selectedIndex == 0,
                    filled: selectedIndex == 0,
                    onTap: () => onTap(0),
                  ),
                  _NavItem(
                    icon: Icons.museum,
                    label: 'Exibições',
                    isSelected: selectedIndex == 1,
                    onTap: () => onTap(1),
                  ),
                  _NavItem(
                    icon: Icons.search,
                    label: 'Buscar',
                    isSelected: selectedIndex == 2,
                    onTap: () => onTap(2),
                  ),
                  _NavItem(
                    icon: Icons.menu_book,
                    label: 'Biblioteca',
                    isSelected: selectedIndex == 3,
                    onTap: () => onTap(3),
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
  final bool filled;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    this.filled = false,
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
            color: isSelected
                ? const Color(0xFFDCE1FF)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 24,
                weight: filled ? 700 : 400,
                color: isSelected
                    ? const Color(0xFF0041C8)
                    : const Color(0xFF515F78),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.05 * 11,
                  color: isSelected
                      ? const Color(0xFF0041C8)
                      : const Color(0xFF515F78),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
