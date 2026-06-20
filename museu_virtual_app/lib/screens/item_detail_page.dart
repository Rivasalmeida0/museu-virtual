import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import '../models/museum_item.dart';

class ItemDetailPage extends StatefulWidget {
  final MuseumItem item;

  const ItemDetailPage({super.key, required this.item});

  @override
  State<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
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
                  children: [
                    _HeroSection(item: widget.item, isWide: isWide),
                    const SizedBox(height: 24),
                    _HistorySpecsSection(item: widget.item, isWide: isWide),
                    const SizedBox(height: 48),
                    _FunFactsSection(funFacts: widget.item.funFacts),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: _DetailBottomNav(),
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
                    _TopBarBtn(
                      icon: Icons.arrow_back,
                      onTap: () => Navigator.of(context).pop(),
                    ),
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
                    _TopBarBtn(icon: Icons.search, onTap: () {}),
                    const SizedBox(width: 4),
                    _TopBarBtn(icon: Icons.share, onTap: () {}),
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

class _TopBarBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _TopBarBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
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
  final MuseumItem item;
  final bool isWide;

  const _HeroSection({required this.item, required this.isWide});

  void _showHotspotDetail(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFF7F9FB),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Detalhe Técnico',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0041C8),
          ),
        ),
        content: Text(
          item.hotspotDetail,
          style: const TextStyle(
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
    if (isWide) return _buildDesktop(context);
    return _buildMobile(context);
  }

  Widget _buildMobile(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HeroImage(
          hotspotCallback: () => _showHotspotDetail(context),
          imageUrl: item.imageUrl,
        ),
        const SizedBox(height: 24),
        _HeroInfo(item: item),
        const SizedBox(height: 16),
        _HeroButtons(),
      ],
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 7,
          child: _HeroImage(
            hotspotCallback: () => _showHotspotDetail(context),
            imageUrl: item.imageUrl,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeroInfo(item: item),
              const SizedBox(height: 16),
              _HeroButtons(),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroImage extends StatefulWidget {
  final VoidCallback hotspotCallback;
  final String imageUrl;
  const _HeroImage({required this.hotspotCallback, required this.imageUrl});

  @override
  State<_HeroImage> createState() => _HeroImageState();
}

class _HeroImageState extends State<_HeroImage> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.maxWidth;
          return SizedBox(
            height: size > 0 ? size * 0.75 : 280,
            child: Stack(
              children: [
                // rotated background layer
                Positioned.fill(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    transform: _hovered
                        ? Matrix4.identity()
                        : (Matrix4.identity()..rotateZ(-0.017)),
                    transformAlignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0055FF).withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                // main image
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0041C8).withValues(alpha: 0.1),
                            blurRadius: 50,
                            offset: const Offset(0, 20),
                          ),
                        ],
                        image: DecorationImage(
                          image: NetworkImage(widget.imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                // hotspot pulse
                Positioned(
                  top: size * 0.25,
                  right: size * 0.25,
                  child: _ItemHotspot(onTap: widget.hotspotCallback),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ItemHotspot extends StatefulWidget {
  final VoidCallback onTap;
  const _ItemHotspot({required this.onTap});

  @override
  State<_ItemHotspot> createState() => _ItemHotspotState();
}

class _ItemHotspotState extends State<_ItemHotspot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          return Transform.scale(
            scale: 0.9 + _ctrl.value * 0.1,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0041C8),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0041C8).withValues(alpha: 0.3),
                    blurRadius: 12,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.info,
                size: 16,
                color: Colors.white,
                weight: 700,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HeroInfo extends StatelessWidget {
  final MuseumItem item;
  const _HeroInfo({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF0055FF).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            'Era: ${item.era}',
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.05 * 12,
              color: Color(0xFF0041C8),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          item.title,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.02 * 32,
            height: 1.1,
            color: const Color(0xFF191C1E),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'LANÇADO EM: ${item.releaseDate}',
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF515F78),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          item.description,
          style: const TextStyle(
            fontSize: 16,
            height: 1.6,
            color: Color(0xFF434656),
          ),
        ),
      ],
    );
  }
}

class _HeroButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 400;
        if (stacked) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [_buildArButton(), const SizedBox(height: 8), _buildGalleryButton()],
          );
        }
        return Row(
          children: [
            Expanded(child: _buildArButton()),
            const SizedBox(width: 12),
            Expanded(child: _buildGalleryButton()),
          ],
        );
      },
    );
  }

  Widget _buildArButton() {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.view_in_ar, size: 18),
      label: const Text('VER EM REALIDADE AUMENTADA'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0041C8),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.05 * 12,
        ),
      ),
    );
  }

  Widget _buildGalleryButton() {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.photo_library, size: 18),
      label: const Text('GALERIA DE FOTOS'),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF191C1E),
        side: const BorderSide(color: Color(0xFF737688)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.05 * 12,
        ),
      ),
    );
  }
}

// ─── History & Specs Section ─────────────────────────────────────────────────

class _HistorySpecsSection extends StatelessWidget {
  final MuseumItem item;
  final bool isWide;

  const _HistorySpecsSection({required this.item, required this.isWide});

  @override
  Widget build(BuildContext context) {
    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 8, child: _HistoryCard(paragraphs: item.historyParagraphs)),
          const SizedBox(width: 24),
          Expanded(flex: 4, child: _SpecsCard(specs: item.specs)),
        ],
      );
    }
    return Column(
      children: [
        _HistoryCard(paragraphs: item.historyParagraphs),
        const SizedBox(height: 16),
        _SpecsCard(specs: item.specs),
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final List<String> paragraphs;
  const _HistoryCard({required this.paragraphs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0041C8).withValues(alpha: 0.05),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history_edu, color: Color(0xFF0041C8), size: 24),
              const SizedBox(width: 8),
              Text(
                'História do Ícone',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                  color: const Color(0xFF191C1E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (final p in paragraphs) ...[
            Text(
              p,
              style: const TextStyle(
                fontSize: 15,
                height: 1.7,
                color: Color(0xFF434656),
              ),
            ),
            if (p != paragraphs.last) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _SpecsCard extends StatelessWidget {
  final List<ItemSpec> specs;
  const _SpecsCard({required this.specs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics, color: Color(0xFF0041C8), size: 24),
              const SizedBox(width: 8),
              Text(
                'Especificações',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                  color: const Color(0xFF191C1E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(1),
            },
            children: [
              for (int i = 0; i < specs.length; i++) ...[
                TableRow(
                  decoration: i.isOdd
                      ? BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.4),
                        )
                      : null,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                      child: Text(
                        specs[i].label.toUpperCase(),
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          color: Color(0xFF515F78),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                      child: Text(
                        specs[i].value,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: specs[i].highlight
                              ? const Color(0xFF0041C8)
                              : const Color(0xFF191C1E),
                        ),
                      ),
                    ),
                  ],
                ),
                if (i < specs.length - 1)
                  TableRow(
                    children: const [
                      SizedBox(height: 0),
                      SizedBox(height: 0),
                    ],
                  ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Fun Facts Section ──────────────────────────────────────────────────────

class _FunFactsSection extends StatelessWidget {
  final List<FunFact> funFacts;
  const _FunFactsSection({required this.funFacts});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Curiosidades',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            height: 1.3,
            color: const Color(0xFF191C1E),
          ),
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 900) {
              return Row(
                children: [
                  for (int i = 0; i < funFacts.length; i++) ...[
                    Expanded(child: _FunFactCard(funFact: funFacts[i])),
                    if (i < funFacts.length - 1) const SizedBox(width: 16),
                  ],
                ],
              );
            }
            if (constraints.maxWidth >= 500) {
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: funFacts
                    .map((f) => SizedBox(
                          width: (constraints.maxWidth - 16) / 2,
                          child: _FunFactCard(funFact: f),
                        ))
                    .toList(),
              );
            }
            return Column(
              children: funFacts
                  .map((f) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _FunFactCard(funFact: f),
                      ))
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _FunFactCard extends StatefulWidget {
  final FunFact funFact;
  const _FunFactCard({required this.funFact});

  @override
  State<_FunFactCard> createState() => _FunFactCardState();
}

class _FunFactCardState extends State<_FunFactCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _hovered
              ? const Color(0xFF0055FF).withValues(alpha: 0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _hovered
                    ? const Color(0xFF0041C8)
                    : const Color(0xFFD2E0FE).withValues(alpha: 0.5),
              ),
              child: Icon(
                widget.funFact.icon,
                color: _hovered ? Colors.white : const Color(0xFF0041C8),
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.funFact.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                height: 1.3,
                color: Color(0xFF191C1E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.funFact.description,
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Color(0xFF434656),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Bottom Nav (detail page variant) ────────────────────────────────────────

class _DetailBottomNav extends StatelessWidget {
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
                  _DetailNavItem(
                    icon: Icons.history_edu,
                    label: 'Timeline',
                    selected: false,
                  ),
                  _DetailNavItem(
                    icon: Icons.museum,
                    label: 'Exibições',
                    selected: true,
                  ),
                  _DetailNavItem(
                    icon: Icons.search,
                    label: 'Search',
                    selected: false,
                  ),
                  _DetailNavItem(
                    icon: Icons.menu_book,
                    label: 'Library',
                    selected: false,
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

class _DetailNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;

  const _DetailNavItem({
    required this.icon,
    required this.label,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: selected ? 16 : 8,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: selected
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
                weight: selected ? 700 : 400,
                color: selected
                    ? const Color(0xFF0041C8)
                    : const Color(0xFF515F78),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.05 * 10,
                  color: selected
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
