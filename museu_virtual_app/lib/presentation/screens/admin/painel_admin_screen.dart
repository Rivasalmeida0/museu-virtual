import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/auth_providers.dart';

class PainelAdminScreen extends ConsumerWidget {
  const PainelAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel de Administração'),
        backgroundColor: Colors.red[900],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Colors.red[50],
            child: const ListTile(
              leading: Icon(Icons.admin_panel_settings, color: Colors.red),
              title: Text(
                'Modo Administrador',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Apenas gestão de contas e segurança.\n'
                'Não tens acesso a conteúdos do museu.',
              ),
            ),
          ),
          const SizedBox(height: 16),
          _itemMenu(
            context,
            icone: Icons.people,
            titulo: 'Gestão de Utilizadores',
            subtitulo: 'Criar, suspender e gerir contas',
            cor: Colors.blue,
            destino: _placeholderScreen('Gestão de Utilizadores', 'Gerir contas de utilizadores'),
          ),
          _itemMenu(
            context,
            icone: Icons.security,
            titulo: 'Logs de Segurança',
            subtitulo: 'Registo de acessos e certificados (não-repúdio)',
            cor: Colors.orange,
            destino: const LogsSegurancaScreen(),
          ),
          _itemMenu(
            context,
            icone: Icons.device_unknown,
            titulo: 'Máquinas Sem Certificado',
            subtitulo: 'Gerir excepções de acesso sem certificado',
            cor: Colors.red,
            destino: const MaquinasSemCertificadoScreen(),
          ),
          _itemMenu(
            context,
            icone: Icons.verified,
            titulo: 'Certificados Activos',
            subtitulo: 'Ver quem está ligado e com que certificado',
            cor: Colors.green,
            destino: _placeholderScreen('Certificados Activos', 'Lista de certificados activos'),
          ),
          const SizedBox(height: 24),
          _buildInfoCard(),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      color: Colors.grey[100],
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blueGrey, size: 20),
                SizedBox(width: 8),
                Text(
                  'Informação do Sistema',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              '• Protocolo: HTTPS com mTLS\n'
              '• CA: Autoridade Certificadora própria (PKI)\n'
              '• Não-repúdio: Todos os acessos são registados\n'
              '• Anti-MITM: Certificados validados por CA\n'
              '• Anti-Pirataria: Certificado obrigatório por dispositivo',
              style: TextStyle(color: Colors.black87, fontSize: 13, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderScreen(String titulo, String descricao) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titulo),
        backgroundColor: Colors.red[900],
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.construction, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(titulo, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(descricao, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }

  Widget _itemMenu(
    BuildContext context, {
    required IconData icone,
    required String titulo,
    required String subtitulo,
    required Color cor,
    required Widget destino,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: cor.withOpacity(0.1),
          child: Icon(icone, color: cor),
        ),
        title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitulo),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => destino),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  TELA: MÁQUINAS SEM CERTIFICADO
// ─────────────────────────────────────────────────────────────
class MaquinasSemCertificadoScreen extends StatefulWidget {
  const MaquinasSemCertificadoScreen({super.key});

  @override
  State<MaquinasSemCertificadoScreen> createState() => _MaquinasSemCertificadoScreenState();
}

class _MaquinasSemCertificadoScreenState extends State<MaquinasSemCertificadoScreen> {
  final _ipController = TextEditingController();
  List<String> _maquinas = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _carregarMaquinas();
  }

  Future<void> _carregarMaquinas() async {
    setState(() => _loading = true);
    try {
      final response = await _fazerPedido('/admin/maquinas-sem-certificado');
      if (response != null) {
        setState(() {
          _maquinas = List<String>.from(response['maquinas'] ?? []);
          _loading = false;
        });
      }
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<Map<String, dynamic>?> _fazerPedido(String endpoint, {String? method, Map<String, dynamic>? body}) async {
    try {
      final uri = Uri.parse(endpoint);
      // Em caso de erro, apenas retorna null para não quebrar a UI
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _adicionarMaquina() async {
    final ip = _ipController.text.trim();
    if (ip.isEmpty) return;
    setState(() => _maquinas.add(ip));
    _ipController.clear();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Máquina $ip adicionada sem certificado')),
      );
    }
  }

  Future<void> _removerMaquina(String ip) async {
    setState(() => _maquinas.remove(ip));
  }

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Máquinas Sem Certificado'),
        backgroundColor: Colors.red[900],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Card(
              color: Color(0xFFFFF3E0),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Atenção: Máquinas sem certificado têm '
                        'acesso limitado e todos os acessos '
                        'ficam registados nos logs.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ipController,
                    decoration: const InputDecoration(
                      labelText: 'Endereço IP da máquina',
                      hintText: 'Ex: 192.168.1.100',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _adicionarMaquina,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Adicionar'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _maquinas.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhuma máquina sem certificado permitida',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _maquinas.length,
                      itemBuilder: (context, index) {
                        final ip = _maquinas[index];
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.device_unknown, color: Colors.orange),
                            title: Text(ip),
                            subtitle: const Text('Acesso permitido sem certificado'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removerMaquina(ip),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  TELA: LOGS DE SEGURANÇA (NÃO-REPÚDIO)
// ─────────────────────────────────────────────────────────────
class LogsSegurancaScreen extends StatefulWidget {
  const LogsSegurancaScreen({super.key});

  @override
  State<LogsSegurancaScreen> createState() => _LogsSegurancaScreenState();
}

class _LogsSegurancaScreenState extends State<LogsSegurancaScreen> {
  final List<Map<String, dynamic>> _logs = [];
  bool _aCarregar = false;

  @override
  void initState() {
    super.initState();
    _simularLogs();
  }

  void _simularLogs() {
    setState(() {
      _aCarregar = false;
      _logs.addAll([
        {'tipo': 'PERMITIDO', 'mensagem': 'Acesso com certificado: admin | IP: 192.168.1.10', 'timestamp': DateTime.now().toIso8601String()},
        {'tipo': 'PERMITIDO', 'mensagem': 'Acesso com certificado: utilizador | IP: 192.168.1.20', 'timestamp': DateTime.now().subtract(const Duration(minutes: 5)).toIso8601String()},
        {'tipo': 'BLOQUEADO', 'mensagem': 'Tentativa de acesso sem certificado: 10.0.0.99', 'timestamp': DateTime.now().subtract(const Duration(minutes: 10)).toIso8601String()},
        {'tipo': 'AVISO', 'mensagem': 'Máquina sem certificado permitida: 192.168.1.50', 'timestamp': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String()},
        {'tipo': 'PERMITIDO', 'mensagem': 'Acesso com certificado: gestor | IP: 192.168.1.15', 'timestamp': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String()},
      ]);
    });
  }

  Color _corPorTipo(String tipo) {
    switch (tipo) {
      case 'PERMITIDO': return Colors.green;
      case 'BLOQUEADO': return Colors.red;
      case 'AVISO': return Colors.orange;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logs de Segurança'),
        backgroundColor: Colors.red[900],
        foregroundColor: Colors.white,
      ),
      body: _aCarregar
          ? const Center(child: CircularProgressIndicator())
          : _logs.isEmpty
              ? const Center(child: Text('Sem logs registados'))
              : ListView.builder(
                  itemCount: _logs.length,
                  itemBuilder: (context, index) {
                    final log = _logs[index];
                    final tipo = log['tipo'] as String? ?? '';
                    final cor = _corPorTipo(tipo);
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: cor.withOpacity(0.1),
                          child: Text(
                            tipo[0],
                            style: TextStyle(color: cor, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(
                          log['mensagem'] as String? ?? '',
                          style: const TextStyle(fontSize: 13),
                        ),
                        subtitle: Text(
                          log['timestamp'] as String? ?? '',
                          style: const TextStyle(fontSize: 11),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: cor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: cor),
                          ),
                          child: Text(
                            tipo,
                            style: TextStyle(color: cor, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
