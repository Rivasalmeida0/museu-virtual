import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/conteudo_service.dart';

class RelatorioCompressaoScreen extends StatefulWidget {
  const RelatorioCompressaoScreen({super.key});

  @override
  State<RelatorioCompressaoScreen> createState() =>
      _RelatorioCompressaoScreenState();
}

class _RelatorioCompressaoScreenState
    extends State<RelatorioCompressaoScreen> {
  final _service = ConteudoService();
  List<dynamic> _relatorios = [];
  bool _aCarregar = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregarRelatorios();
  }

  Future<void> _carregarRelatorios() async {
    setState(() {
      _aCarregar = true;
      _erro = null;
    });
    try {
      final dados = await _service.obterRelatoriosCompressao();
      setState(() {
        _relatorios = dados['compressoes'] ?? [];
        _aCarregar = false;
      });
    } catch (e) {
      setState(() {
        _erro = e.toString();
        _aCarregar = false;
      });
    }
  }

  Color _corTipo(String tipo) {
    switch (tipo) {
      case 'imagem':
        return Colors.blue;
      case 'audio':
        return Colors.orange;
      case 'video':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.angolaBlack,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Relatório de Compressão'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarRelatorios,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_aCarregar) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_erro != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.white38, size: 48),
            const SizedBox(height: 16),
            Text(_erro!, style: const TextStyle(color: Colors.white54)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _carregarRelatorios,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }
    if (_relatorios.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma compressão registada.',
          style: TextStyle(color: Colors.white54, fontSize: 16),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _carregarRelatorios,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _relatorios.length,
        itemBuilder: (context, index) {
          final r = _relatorios[index] as Map<String, dynamic>;
          return _buildCard(r);
        },
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> r) {
    final tipo = r['tipo'] as String? ?? 'desconhecido';
    final cor = _corTipo(tipo);
    final formatoOrig = r['formato_original'] as String? ?? '?';
    final formatoFinal = r['formato_final'] as String? ?? '?';
    final tamOrig = r['tamanho_original_legivel'] as String? ?? '?';
    final tamComp = r['tamanho_comprimido_legivel'] as String? ?? '?';
    final taxa = r['taxa_compressao'] as String? ?? '?';
    final tempo = r['tempo_processamento_ms'] as int? ?? 0;
    final data = r['data'] as String? ?? '';

    String dataFormatada = '';
    if (data.isNotEmpty) {
      try {
        final dt = DateTime.parse(data);
        dataFormatada =
            '${dt.day.toString().padLeft(2, '0')}/'
            '${dt.month.toString().padLeft(2, '0')}/'
            '${dt.year} ${dt.hour.toString().padLeft(2, '0')}:'
            '${dt.minute.toString().padLeft(2, '0')}';
      } catch (_) {
        dataFormatada = data;
      }
    }

    return Card(
      color: const Color(0xFF1A1A2E),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: cor,
          child: Text(
            tipo[0].toUpperCase(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          '$formatoOrig → $formatoFinal',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          '$tamOrig → $tamComp  |  Redução: $taxa',
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(color: Colors.white12),
                _detalhe('Tipo', tipo.toUpperCase()),
                _detalhe('Formato original', formatoOrig),
                _detalhe('Formato final', formatoFinal),
                const SizedBox(height: 8),
                _detalhe('Tamanho original', tamOrig),
                _detalhe('Tamanho comprimido', tamComp),
                _detalhe('Taxa de compressão', taxa, destaque: true),
                _detalhe('Qualidade', r['qualidade_percebida'] as String? ?? ''),
                _detalhe('Tempo de processamento', '${tempo}ms'),
                if (dataFormatada.isNotEmpty)
                  _detalhe('Data', dataFormatada),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detalhe(String label, String valor, {bool destaque = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(
            valor,
            style: TextStyle(
              color: destaque ? Colors.green : Colors.white,
              fontWeight: destaque ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}