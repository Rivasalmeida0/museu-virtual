# gerar_certificados.ps1
# Cria a estrutura de PKI para o Museu Virtual
# Uso: .\gerar_certificados.ps1

$OPENSSL = "C:\Program Files\Git\usr\bin\openssl.exe"

# Cria as pastas
New-Item -ItemType Directory -Force -Path "certs\ca" | Out-Null
New-Item -ItemType Directory -Force -Path "certs\server" | Out-Null
New-Item -ItemType Directory -Force -Path "certs\clients" | Out-Null

Write-Host "=== 1. A gerar CA (Autoridade Certificadora) ==="

& $OPENSSL genrsa -out certs/ca/ca.key 4096

& $OPENSSL req -new -x509 -days 3650 `
  -key certs/ca/ca.key `
  -out certs/ca/ca.crt `
  -subj "/C=AO/ST=Luanda/L=Luanda/O=Museu Virtual CA/CN=MuseuVirtualCA"

Write-Host "=== 2. A gerar certificado do SERVIDOR (com SANs) ==="

& $OPENSSL genrsa -out certs/server/server.key 2048

& $OPENSSL req -new `
  -key certs/server/server.key `
  -out certs/server/server.csr `
  -subj "/C=AO/ST=Luanda/L=Luanda/O=Museu Virtual/CN=localhost"

# Criar ficheiro de extensoes com SANs (Subject Alternative Names)
# Isto e OBRIGATORIO para browsers modernos que ignoram o CN
$sansContent = @"
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = localhost
IP.1 = 127.0.0.1
IP.2 = 192.168.1.207
IP.3 = 192.168.56.1
"@

$sansContent | Out-File -FilePath "certs/server/server_sans.cnf" -Encoding ascii -NoNewline

& $OPENSSL x509 -req -days 365 `
  -in certs/server/server.csr `
  -CA certs/ca/ca.crt `
  -CAkey certs/ca/ca.key `
  -CAcreateserial `
  -out certs/server/server.crt `
  -extfile certs/server/server_sans.cnf

Write-Host "=== 3. A gerar certificado do ADMINISTRADOR ==="

& $OPENSSL genrsa -out certs/clients/admin.key 2048
& $OPENSSL req -new `
  -key certs/clients/admin.key `
  -out certs/clients/admin.csr `
  -subj "/C=AO/ST=Luanda/L=Luanda/O=Museu Virtual/CN=admin/emailAddress=admin@museu.ao"
& $OPENSSL x509 -req -days 365 `
  -in certs/clients/admin.csr `
  -CA certs/ca/ca.crt `
  -CAkey certs/ca/ca.key `
  -CAcreateserial `
  -out certs/clients/admin.crt

Write-Host "=== 4. A gerar certificado do GESTOR ==="

& $OPENSSL genrsa -out certs/clients/gestor.key 2048
& $OPENSSL req -new `
  -key certs/clients/gestor.key `
  -out certs/clients/gestor.csr `
  -subj "/C=AO/ST=Luanda/L=Luanda/O=Museu Virtual/CN=gestor/emailAddress=gestor@museu.ao"
& $OPENSSL x509 -req -days 365 `
  -in certs/clients/gestor.csr `
  -CA certs/ca/ca.crt `
  -CAkey certs/ca/ca.key `
  -CAcreateserial `
  -out certs/clients/gestor.crt

Write-Host "=== 5. A gerar certificado do UTILIZADOR ==="

& $OPENSSL genrsa -out certs/clients/utilizador.key 2048
& $OPENSSL req -new `
  -key certs/clients/utilizador.key `
  -out certs/clients/utilizador.csr `
  -subj "/C=AO/ST=Luanda/L=Luanda/O=Museu Virtual/CN=utilizador/emailAddress=user@museu.ao"
& $OPENSSL x509 -req -days 365 `
  -in certs/clients/utilizador.csr `
  -CA certs/ca/ca.crt `
  -CAkey certs/ca/ca.key `
  -CAcreateserial `
  -out certs/clients/utilizador.crt

Write-Host "=== 6. A gerar certificado CLIENTE SEM AUTORIZACAO ==="

& $OPENSSL genrsa -out certs/clients/sem_certificado.key 2048
& $OPENSSL req -new -x509 -days 365 `
  -key certs/clients/sem_certificado.key `
  -out certs/clients/sem_certificado.crt `
  -subj "/C=AO/ST=Luanda/L=Luanda/O=Desconhecido/CN=intruso"

Write-Host ""
Write-Host "============================================"
Write-Host "  Todos os certificados gerados com sucesso!"
Write-Host "============================================"
Write-Host ""
Write-Host "Estrutura criada:"
Write-Host "  certs/ca/ca.key                   -> Chave privada da CA (NUNCA partilhar)"
Write-Host "  certs/ca/ca.crt                   -> Certificado da CA (distribuir aos clientes)"
Write-Host "  certs/server/server.key           -> Chave privada do servidor"
Write-Host "  certs/server/server.crt           -> Certificado do servidor (com SANs)"
Write-Host "  certs/clients/admin.crt           -> Certificado do administrador"
Write-Host "  certs/clients/gestor.crt          -> Certificado do gestor"
Write-Host "  certs/clients/utilizador.crt      -> Certificado do utilizador"
Write-Host "  certs/clients/sem_certificado.crt -> Certificado INVALIDO (para testes)"
Write-Host ""
Write-Host "SANs do certificado do servidor:"
Write-Host "  DNS: localhost"
Write-Host "  IP:  127.0.0.1, 192.168.1.207, 192.168.56.1"
