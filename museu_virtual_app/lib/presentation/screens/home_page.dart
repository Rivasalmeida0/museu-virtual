import 'dart:convert';
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/api_constants.dart';
import '../../domain/entities/museum_piece.dart';
import '../../data/models/museum_piece_model.dart';
import '../providers/piece_providers.dart';
import 'gallery_page.dart';
import 'piece_detail_page.dart';
import 'streaming_page.dart';
import 'streaming_ao_vivo_screen.dart';
import 'perfil_screen.dart';
import '../../services/socket_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _MuseumHomeContent(onNavigate: _onNavigate),
      GalleryPage(initialTab: 0),
      StreamingPage(),
      const StreamingAoVivoScreen(),
    ];
  }

  void _onNavigate(int index) {
    setState(() => _selectedIndex = index);
  }

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
        onTap: _onNavigate,
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
                    _TopIcon(
                      icon: Icons.search,
                      onTap: () {
                        showSearch(context: context, delegate: _PesquisaDelegate());
                      },
                    ),
                    const SizedBox(width: 4),
                    _TopIcon(
                      icon: Icons.person_outline,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PerfilScreen()),
                      ),
                    ),
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
  final VoidCallback? onTap;
  const _TopIcon({required this.icon, this.onTap});

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
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
      ),
    );
  }
}

class _MuseumHomeContent extends ConsumerWidget {
  final void Function(int index) onNavigate;

  const _MuseumHomeContent({required this.onNavigate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final piecesAsync = ref.watch(allPiecesProvider);
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
                _FeaturedSection(piecesAsync: piecesAsync),
                const SizedBox(height: 48),
                _CategoryRow(isWide: isWide, onNavigate: onNavigate),
                const SizedBox(height: 48),
                _LiveStreamBanner(onNavigate: onNavigate),
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
              value: '16+',
              label: 'Peças',
            ),
            const SizedBox(width: 16),
            _StatBadge(
              icon: Icons.history,
              value: '1945',
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

class _FeaturedSection extends StatelessWidget {
  final AsyncValue<List<MuseumPiece>> piecesAsync;

  const _FeaturedSection({required this.piecesAsync});

  @override
  Widget build(BuildContext context) {
    return piecesAsync.when(
      loading: () => _FeaturedLoading(),
      error: (_, __) => const SizedBox.shrink(),
      data: (pieces) {
        final featured = pieces.take(6).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Computadores em Destaque',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Ver todos',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: featured.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final piece = featured[index];
                  return _FeaturedCard(piece: piece);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FeaturedLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Computadores em Destaque',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, __) => Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final MuseumPiece piece;

  const _FeaturedCard({required this.piece});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PieceDetailPage(piece: piece),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 180,
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 10,
                child: CachedNetworkImage(
                  imageUrl: piece.imagemUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(color: Colors.white),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: AppColors.surface,
                    child: const Icon(Icons.computer,
                        size: 32, color: AppColors.textSecondary),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      piece.nome,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${piece.ano} · ${piece.fabricante}',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

class _CategoryRow extends StatelessWidget {
  final bool isWide;
  final void Function(int index) onNavigate;

  const _CategoryRow({required this.isWide, required this.onNavigate});

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
                subtitle: 'Dos anos 40 aos 90',
                color: AppColors.primary,
                onTap: () => onNavigate(1),
              )),
              const SizedBox(width: 16),
              Expanded(child: _CategoryCard(
                icon: Icons.dns,
                title: 'Supercomputadores',
                subtitle: 'Poder exascale',
                color: AppColors.angolaGold,
                onTap: () => onNavigate(1),
              )),
              const SizedBox(width: 16),
              Expanded(child: _CategoryCard(
                icon: Icons.live_tv,
                title: 'Streaming ao Vivo',
                subtitle: 'Visitas guiadas',
                color: AppColors.angolaRed,
                onTap: () => onNavigate(2),
              )),
            ],
          )
        else
          Column(
            children: [
              _CategoryCard(
                icon: Icons.computer,
                title: 'Computadores Históricos',
                subtitle: 'Dos anos 40 aos 90',
                color: AppColors.primary,
                onTap: () => onNavigate(1),
              ),
              const SizedBox(height: 12),
              _CategoryCard(
                icon: Icons.dns,
                title: 'Supercomputadores',
                subtitle: 'Poder exascale',
                color: AppColors.angolaGold,
                onTap: () => onNavigate(1),
              ),
              const SizedBox(height: 12),
              _CategoryCard(
                icon: Icons.live_tv,
                title: 'Streaming ao Vivo',
                subtitle: 'Visitas guiadas',
                color: AppColors.angolaRed,
                onTap: () => onNavigate(2),
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
                    icon: Icons.videocam,
                    label: 'Streaming',
                    isSelected: selectedIndex == 2,
                    onTap: () => onTap(2),
                  ),
                  _NavItem(
                    icon: Icons.live_tv,
                    label: 'Ao Vivo',
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

class _LiveStreamBanner extends StatefulWidget {
  final void Function(int index) onNavigate;
  const _LiveStreamBanner({required this.onNavigate});

  @override
  State<_LiveStreamBanner> createState() => _LiveStreamBannerState();
}

class _LiveStreamBannerState extends State<_LiveStreamBanner> {
  bool _streamAtivo = false;
  String? _titulo;

  @override
  void initState() {
    super.initState();
    _verificar();
    SocketService().iniciar(ApiConstants.baseUrl);
    SocketService().ouvir('stream_iniciado', (data) {
      if (!mounted) return;
      setState(() {
        _streamAtivo = true;
        _titulo = data['titulo'] as String?;
      });
    });
    SocketService().ouvir('stream_terminado', (_) {
      if (!mounted) return;
      setState(() { _streamAtivo = false; _titulo = null; });
    });
  }

  @override
  void dispose() {
    SocketService().removerOuvinte('stream_iniciado');
    SocketService().removerOuvinte('stream_terminado');
    super.dispose();
  }

  Future<void> _verificar() async {
    try {
      final resp = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/v1/streaming-ao-vivo/ativo'),
      ).timeout(ApiConstants.timeout);
      if (resp.statusCode != 200) return;
      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      if (body['ativo'] == true && mounted) {
        setState(() {
          _streamAtivo = true;
          _titulo = (body['dados'] as Map?)?['titulo'] as String?;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onNavigate(3),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _streamAtivo
                ? [AppColors.angolaRed.withValues(alpha: 0.15), const Color(0xFF1A1A2E)]
                : [AppColors.primary.withValues(alpha: 0.08), const Color(0xFF1A1A2E)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _streamAtivo
                ? AppColors.angolaRed.withValues(alpha: 0.3)
                : AppColors.primary.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: _streamAtivo
                    ? AppColors.angolaRed.withValues(alpha: 0.2)
                    : AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _streamAtivo ? Icons.live_tv : Icons.live_tv_outlined,
                color: _streamAtivo ? AppColors.angolaRed : AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (_streamAtivo) ...[
                        Container(
                          width: 8, height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.angolaRed,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        _streamAtivo ? 'AO VIVO' : 'Visita Guiada',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                          color: _streamAtivo ? AppColors.angolaRed : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _streamAtivo ? (_titulo ?? 'Assistir Visita Guiada') : 'Acompanhe visitas guiadas ao vivo',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.primary.withValues(alpha: 0.5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class _PesquisaDelegate extends SearchDelegate<MuseumPiece?> {
  @override
  String get searchFieldLabel => 'Pesquisar peças...';

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        iconTheme: IconThemeData(color: AppColors.primary),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: AppColors.textSecondary),
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildLista(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildLista(context);

  Widget _buildLista(BuildContext context) {
    if (query.length < 2) {
      return const Center(
        child: Text(
          'Digite pelo menos 2 caracteres',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return FutureBuilder<List<MuseumPiece>>(
      future: _pesquisar(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Erro: ${snapshot.error}'));
        }
        final itens = snapshot.data ?? [];
        if (itens.isEmpty) {
          return const Center(
            child: Text(
              'Nenhum resultado encontrado.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: itens.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final peca = itens[index];
            return ListTile(
              leading: peca.imagemUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        '${ApiConstants.baseUrl}/uploads/${peca.imagemUrl}',
                        width: 48, height: 48, fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(Icons.image, color: AppColors.primary),
              title: Text(peca.nome, style: const TextStyle(color: Colors.white)),
              subtitle: Text(peca.fabricante ?? '',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              onTap: () {
                close(context, null);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PieceDetailPage(piece: peca),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<List<MuseumPiece>> _pesquisar(String q) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/v1/conteudos/pesquisar')
        .replace(queryParameters: {'q': q});
    final resp = await http.get(uri);
    if (resp.statusCode != 200) return [];
    final json = jsonDecode(resp.body) as Map<String, dynamic>;
    final lista = json['dados'] as List? ?? [];
    return lista.map((e) => MuseumPieceModel.fromJson(e as Map<String, dynamic>).toEntity()).toList();
  }
}
