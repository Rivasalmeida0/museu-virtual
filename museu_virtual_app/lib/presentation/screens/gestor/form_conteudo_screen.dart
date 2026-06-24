import 'dart:async';
import 'dart:io' show File;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../services/conteudo_service.dart';
import '../../../services/auth_service.dart';
import '../../widgets/upload_multimidia_widget.dart';

class FormConteudoScreen extends StatefulWidget {
  final Map<String, dynamic>? conteudoExistente;

  const FormConteudoScreen({super.key, this.conteudoExistente});

  @override
  State<FormConteudoScreen> createState() => _FormConteudoScreenState();
}

class _FormConteudoScreenState extends State<FormConteudoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = ConteudoService(AuthService());

  late final TextEditingController _nomeCtrl;
  late final TextEditingController _anoCtrl;
  late final TextEditingController _fabricanteCtrl;
  late final TextEditingController _descricaoCtrl;
  late final TextEditingController _curiosidadeCtrl;
  late final TextEditingController _wikipediaCtrl;

  String _categoria = 'historico';
  XFile? _imagemSelecionada;
  Uint8List? _imagemBytes;
  bool _submitting = false;
  bool _isEditing = false;
  int? _conteudoId;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.conteudoExistente != null;
    final c = widget.conteudoExistente;

    _nomeCtrl = TextEditingController(text: c?['nome'] as String? ?? '');
    _anoCtrl = TextEditingController(text: c?['ano']?.toString() ?? '');
    _fabricanteCtrl = TextEditingController(text: c?['fabricante'] as String? ?? '');
    _descricaoCtrl = TextEditingController(text: c?['descricao'] as String? ?? '');
    _curiosidadeCtrl = TextEditingController(text: c?['curiosidade'] as String? ?? '');
    _wikipediaCtrl = TextEditingController(text: c?['wikipediaUrl'] as String? ?? '');

    if (c != null && c['categoria'] != null) {
      _categoria = c['categoria'] as String;
    }
    if (c != null && c['id'] != null) {
      _conteudoId = c['id'] as int;
    }
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _anoCtrl.dispose();
    _fabricanteCtrl.dispose();
    _descricaoCtrl.dispose();
    _curiosidadeCtrl.dispose();
    _wikipediaCtrl.dispose();
    super.dispose();
  }

  Future<void> _escolherImagem() async {
    final picker = ImagePicker();
    final ficheiro = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );
    if (ficheiro != null) {
      _imagemSelecionada = ficheiro;
      if (kIsWeb) {
        _imagemBytes = await ficheiro.readAsBytes();
      }
      setState(() {});
    }
  }

  Future<void> _submeter() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    try {
      final dados = <String, dynamic>{
        'nome': _nomeCtrl.text.trim(),
        'ano': int.tryParse(_anoCtrl.text.trim()),
        'fabricante': _fabricanteCtrl.text.trim(),
        'categoria': _categoria,
        'descricao': _descricaoCtrl.text.trim(),
        'curiosidade': _curiosidadeCtrl.text.trim(),
        'wikipedia_url': _wikipediaCtrl.text.trim(),
      };

      Map<String, dynamic>? resultado;

      if (_isEditing && _conteudoId != null) {
        resultado = await _service.actualizar(_conteudoId!, dados);
      } else {
        resultado = await _service.criar(dados);
        _conteudoId = resultado['id'] as int?;
      }

      if (mounted) {
        setState(() {});
        if (!_isEditing) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Conteúdo criado! Faça upload da multimédia abaixo.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: AppColors.angolaRed),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.angolaBlack,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(_isEditing ? 'Editar Conteúdo' : 'Novo Conteúdo'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCampo('Nome', _nomeCtrl, validator: (v) => v == null || v.trim().isEmpty ? 'Obrigatório' : null),
              const SizedBox(height: 16),
              _buildCampo('Ano', _anoCtrl, keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _buildCampo('Fabricante', _fabricanteCtrl),
              const SizedBox(height: 16),
              _buildCategoriaDropdown(),
              const SizedBox(height: 16),
              _buildCampoLongo('Descrição', _descricaoCtrl, maxLinhas: 5),
              const SizedBox(height: 16),
              _buildCampoLongo('Curiosidade', _curiosidadeCtrl, maxLinhas: 4),
              const SizedBox(height: 16),
              _buildCampo('URL Wikipedia', _wikipediaCtrl, keyboardType: TextInputType.url),
              const SizedBox(height: 24),
              _buildImagemPicker(),
              const SizedBox(height: 32),
              _buildSubmitButton(),

              if (_conteudoId != null) ...[
                const SizedBox(height: 32),
                const Divider(color: Colors.white12),
                const SizedBox(height: 16),
                UploadMultimidiaWidget(
                  conteudoId: _conteudoId!,
                  conteudo: widget.conteudoExistente,
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCampo(String label, TextEditingController ctrl,
      {TextInputType? keyboardType, String? Function(String?)? validator}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: _decoration(label),
      validator: validator,
    );
  }

  Widget _buildCampoLongo(String label, TextEditingController ctrl,
      {int maxLinhas = 4}) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLinhas,
      style: const TextStyle(color: Colors.white),
      decoration: _decoration(label),
    );
  }

  Widget _buildCategoriaDropdown() {
    return DropdownButtonFormField<String>(
      value: _categoria,
      dropdownColor: const Color(0xFF1A1A2E),
      style: const TextStyle(color: Colors.white),
      decoration: _decoration('Categoria'),
      items: const [
        DropdownMenuItem(value: 'historico', child: Text('Histórico')),
        DropdownMenuItem(value: 'supercomputador', child: Text('Supercomputador')),
      ],
      onChanged: (v) {
        if (v != null) setState(() => _categoria = v);
      },
    );
  }

  Widget _buildImagemPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Imagem', style: TextStyle(color: Colors.white54, fontSize: 13)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _escolherImagem,
          child: Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: _imagemSelecionada != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _previewImagemSelecionada(),
                  )
                : widget.conteudoExistente?['imagemUrl'] != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          '${ApiConstants.baseUrl}${widget.conteudoExistente!['imagemUrl']}',
                          fit: BoxFit.cover, width: double.infinity, height: 180,
                          loadingBuilder: (_, child, progress) => progress == null ? child : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          errorBuilder: (_, erro, __) {
                            debugPrint('Erro imagem preview: $erro');
                            return _placeholderImagem();
                          },
                        ),
                      )
                    : _placeholderImagem(),
          ),
        ),
      ],
    );
  }

  Widget _previewImagemSelecionada() {
    if (kIsWeb && _imagemBytes != null) {
      return Image.memory(_imagemBytes!, fit: BoxFit.cover, width: double.infinity, height: 180);
    }
    return Image.file(File(_imagemSelecionada!.path), fit: BoxFit.cover, width: double.infinity, height: 180);
  }

  Widget _placeholderImagem() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.add_photo_alternate_outlined, color: Colors.white24, size: 40),
        const SizedBox(height: 8),
        Text(
          _imagemSelecionada != null ? 'Tocar para alterar' : 'Tocar para selecionar imagem',
          style: const TextStyle(color: Colors.white38, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _submitting ? null : _submeter,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: _submitting
            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(_isEditing ? 'Guardar Alterações' : 'Publicar', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white38),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.06),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }
}
