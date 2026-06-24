import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/streaming_models.dart';
import '../providers/streaming_providers.dart';
import '../providers/auth_providers.dart';
import 'streaming_room_page.dart';

class StreamingPage extends ConsumerWidget {
  const StreamingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salasAsync = ref.watch(streamingSalasProvider);

    return salasAsync.when(
      loading: () => _buildLoading(),
      error: (err, _) => _buildError(ref, err),
      data: (salas) => _buildContent(context, ref, salas),
    );
  }

  Widget _buildLoading() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.streamingAovivo,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Visitas guiadas, apresentações de peças e eventos especiais ao vivo.',
            style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          ...List.generate(
            3,
            (_) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  height: 88,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(WidgetRef ref, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              AppStrings.erroCarregar,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(streamingSalasProvider),
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(AppStrings.tentarNovamente),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, List<StreamingSala> salas) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.streamingAovivo,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Visitas guiadas, apresentações de peças e eventos especiais ao vivo.',
            style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),

          // Banner informativo
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.angolaRed.withValues(alpha: 0.08),
                  AppColors.angolaGold.withValues(alpha: 0.06),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.angolaRed.withValues(alpha: 0.12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.angolaRed.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.cast_connected,
                    color: AppColors.angolaRed,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Partilha e Assiste',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Transmite a tua câmera ou ecrã e outros dispositivos visualizam ao vivo.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Lista de salas
          ...salas.map((sala) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _StreamingRoomCard(
                  sala: sala,
                  onTap: sala.activa
                      ? () => _showRoleDialog(context, ref, sala)
                      : null,
                ),
              )),
        ],
      ),
    );
  }

  void _showRoleDialog(BuildContext context, WidgetRef ref, StreamingSala sala) {
    final authState = ref.read(authProvider);
    final funcao = (authState.utilizador?['funcao'] as String? ?? '').toLowerCase();
    final isGestor = funcao == 'gestor' || funcao == 'admin';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              sala.nome,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Como queres entrar nesta sala?',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            if (isGestor) ...[
              _RoleOption(
                icon: Icons.videocam,
                title: 'Transmitir',
                subtitle: 'Partilha câmera, mic ou ecrã',
                color: AppColors.angolaRed,
                onTap: () {
                  Navigator.pop(ctx);
                  _enterRoom(context, sala, 'anfitriao');
                },
              ),
              const SizedBox(height: 12),
            ],

            _RoleOption(
              icon: Icons.visibility,
              title: 'Assistir',
              subtitle: 'Visualiza a transmissão ao vivo',
              color: AppColors.primary,
              onTap: () {
                Navigator.pop(ctx);
                _enterRoom(context, sala, 'viewer');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _enterRoom(
      BuildContext context, StreamingSala sala, String papel) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StreamingRoomPage(
          salaId: sala.id,
          salaNome: sala.nome,
          papel: papel,
        ),
      ),
    );
  }
}

// ─── Role Option Button ──────────────────────────────────────

class _RoleOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _RoleOption({
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
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
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

// ─── Room Card ───────────────────────────────────────────────

class _StreamingRoomCard extends StatelessWidget {
  final StreamingSala sala;
  final VoidCallback? onTap;

  const _StreamingRoomCard({
    required this.sala,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = sala.activa;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: active ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: active
                ? Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2))
                : Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color:
                      active ? AppColors.primaryBg : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  active ? Icons.live_tv : Icons.live_tv_outlined,
                  color: active ? AppColors.primary : Colors.grey,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sala.nome,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: active
                            ? AppColors.textPrimary
                            : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sala.descricao,
                      style: TextStyle(
                        fontSize: 13,
                        color: active
                            ? AppColors.textSecondary
                            : Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
              if (active)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        AppColors.angolaRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle,
                          size: 8, color: AppColors.angolaRed),
                      SizedBox(width: 4),
                      Text(
                        'AO VIVO',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.angolaRed,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'BREVEMENTE',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
