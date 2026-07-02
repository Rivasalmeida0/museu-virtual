import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'http_overrides.dart';

/// Configuração para plataformas nativas (Android/iOS/Desktop).
/// Cria o contexto mTLS e define os HttpOverrides globais.
Future<void> configurarPlataforma() async {
  SecurityContext? contextoMTLS;
  try {
    contextoMTLS = await _criarContextoMTLS();
    debugPrint('[main] Contexto mTLS global criado com sucesso');
  } catch (e) {
    debugPrint('[main] Erro ao criar contexto mTLS global: $e');
  }

  // Aceitar certificados auto-assinados E enviar certificado de cliente
  // globalmente (necessário para Image.network, CachedNetworkImage, etc.)
  HttpOverrides.global = MeuHttpOverrides(contextoMTLS);
}

/// Cria um [SecurityContext] com os certificados mTLS da app
/// para que todos os HttpClient globais enviem o certificado de cliente.
Future<SecurityContext> _criarContextoMTLS() async {
  final caBytes = await rootBundle.load('assets/certs/ca.crt');
  final clienteCertBytes = await rootBundle.load('assets/certs/utilizador.crt');
  final clienteKeyBytes = await rootBundle.load('assets/certs/utilizador.key');

  final ctx = SecurityContext(withTrustedRoots: false);
  ctx.setTrustedCertificatesBytes(caBytes.buffer.asUint8List());
  ctx.useCertificateChainBytes(clienteCertBytes.buffer.asUint8List());
  ctx.usePrivateKeyBytes(clienteKeyBytes.buffer.asUint8List());

  return ctx;
}
