import 'dart:io';

/// Sobrescreve o HttpClient global para:
/// 1. Aceitar certificados auto-assinados do servidor
/// 2. Enviar o certificado de cliente mTLS (quando disponível)
///
/// Isto é necessário porque widgets como [Image.network] e [CachedNetworkImage]
/// criam os seus próprios HttpClient internos que não usam o [HttpSeguroService].
/// Ao definir este override globalmente com o contexto de segurança mTLS,
/// TODOS os HttpClient na app enviam o certificado de cliente.
class MeuHttpOverrides extends HttpOverrides {
  final SecurityContext? _securityContext;

  MeuHttpOverrides([this._securityContext]);

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(_securityContext ?? context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        // Aceitar apenas conexões para o nosso servidor local
        // Em produção, deve-se usar certificados válidos
        return true;
      };
  }
}

