import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/api_constants.dart';
import '../../domain/entities/museum_piece.dart';
import 'player_video_screen.dart';
import 'player_audio_screen.dart';

class PieceDetailPage extends StatelessWidget {
  final MuseumPiece piece;

  const PieceDetailPage({super.key, required this.piece});

  Future<void> _descarregar(String filename, String nomeFicheiro) async {
    final tipo = filename.endsWith('.mp4') ? 'video' : 'audio';
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/v1/download/$tipo/$filename');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          piece.nome,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 768;
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              isWide ? 48 : 16, 16, isWide ? 48 : 16, 100,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1280),
              child: Column(
                children: [
                  _HeroSection(piece: piece, isWide: isWide),
                  const SizedBox(height: 24),
                  _CuriosityCard(curiosidade: piece.curiosidade),
                  const SizedBox(height: 24),
                  _SpecsSection(specs: piece.especificacoes),
                  const SizedBox(height: 24),
                  _WikipediaButton(url: piece.wikipediaUrl),
                  if (piece.videoUrl.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _MultimediaButton(
                      icon: Icons.play_circle_filled,
                      label: 'Ver Vídeo Documentário',
                      color: Colors.purple,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PlayerVideoScreen(
                            videoUrl: piece.videoUrl,
                            titulo: piece.nome,
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (piece.audioUrl.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _MultimediaButton(
                      icon: Icons.headphones,
                      label: 'Ouvir Narração (Áudio-Guia)',
                      color: Colors.orange,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PlayerAudioScreen(
                            audioUrl: piece.audioUrl,
                            titulo: piece.nome,
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (piece.videoUrl.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _MultimediaButton(
                      icon: Icons.download,
                      label: 'Descarregar Vídeo',
                      color: Colors.teal,
                      onPressed: () => _descarregar(piece.videoUrl, '${piece.nome}.mp4'),
                    ),
                  ],
                  if (piece.audioUrl.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _MultimediaButton(
                      icon: Icons.download,
                      label: 'Descarregar Áudio',
                      color: Colors.teal,
                      onPressed: () => _descarregar(piece.audioUrl, '${piece.nome}.mp3'),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final MuseumPiece piece;
  final bool isWide;

  const _HeroSection({required this.piece, required this.isWide});

  @override
  Widget build(BuildContext context) {
    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 6, child: _ImageCard(piece: piece)),
          const SizedBox(width: 24),
          Expanded(flex: 5, child: _InfoCard(piece: piece)),
        ],
      );
    }
    return Column(
      children: [
        _ImageCard(piece: piece),
        const SizedBox(height: 16),
        _InfoCard(piece: piece),
      ],
    );
  }
}

class _ImageCard extends StatelessWidget {
  final MuseumPiece piece;
  const _ImageCard({required this.piece});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CachedNetworkImage(
        imageUrl: piece.imagemUrl,
        fit: BoxFit.cover,
        placeholder: (_, __) => Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 280,
            color: Colors.white,
          ),
        ),
        errorWidget: (_, __, ___) => Container(
          height: 280,
          color: AppColors.surface,
          child: const Center(
            child: Icon(Icons.computer, size: 64, color: AppColors.textSecondary),
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final MuseumPiece piece;
  const _InfoCard({required this.piece});

  @override
  Widget build(BuildContext context) {
    final isHistorico = piece.categoria == 'historico';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isHistorico
                ? AppColors.primaryVeryLight
                : AppColors.angolaGold.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            isHistorico ? 'Computador Histórico' : 'Supercomputador',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isHistorico ? AppColors.primary : AppColors.angolaBlack,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          piece.nome,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.02 * 28,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${piece.fabricante} · ${piece.ano}',
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          piece.descricao,
          style: const TextStyle(
            fontSize: 15,
            height: 1.6,
            color: AppColors.textBody,
          ),
        ),
      ],
    );
  }
}

class _CuriosityCard extends StatelessWidget {
  final String curiosidade;
  const _CuriosityCard({required this.curiosidade});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.angolaGold.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.angolaGold.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline,
              color: AppColors.angolaGold, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sabia que?',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.angolaGold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  curiosidade,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: AppColors.textBody,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecsSection extends StatelessWidget {
  final List<PieceSpec> specs;
  const _SpecsSection({required this.specs});

  @override
  Widget build(BuildContext context) {
    if (specs.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Especificações Técnicas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...specs.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 130,
                      child: Text(
                        s.label,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        s.value,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _MultimediaButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _MultimediaButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 22),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class _WikipediaButton extends StatelessWidget {
  final String url;
  const _WikipediaButton({required this.url});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () async {
          final uri = Uri.tryParse(url);
          if (uri != null && await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
        icon: const Icon(Icons.open_in_new, size: 18),
        label: const Text('Ver na Wikipedia'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
