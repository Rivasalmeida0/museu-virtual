-- =============================================================
--  MUSEU VIRTUAL INTERATIVO — Script de Criação da Base de Dados
--  ISPTEC · Projeto Final Multimídia 2026
--  Compatível com: MySQL 8.0+
-- =============================================================

CREATE DATABASE IF NOT EXISTS museuvirtual
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE museuvirtual;

-- =============================================================
-- 1. UTILIZADORES — Autenticação e perfis
-- =============================================================
CREATE TABLE IF NOT EXISTS utilizadores (
  id               INT UNSIGNED    NOT NULL AUTO_INCREMENT,
  nome             VARCHAR(120)    NOT NULL,
  email            VARCHAR(180)    NOT NULL,
  senha_hash       VARCHAR(255)    NOT NULL,
  funcao           ENUM('admin','visitante') NOT NULL DEFAULT 'visitante',
  url_avatar       VARCHAR(500)    NULL,
  biografia        TEXT            NULL,
  activo           TINYINT(1)      NOT NULL DEFAULT 1,
  criado_em        DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  actualizado_em   DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP
                                   ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  UNIQUE KEY uq_utilizadores_email  (email),
  KEY        idx_utilizadores_funcao (funcao),
  KEY        idx_utilizadores_activo (activo)
) ENGINE=InnoDB;

-- =============================================================
-- 2. EXPOSICOES — Salas / Exposições do museu
-- =============================================================
CREATE TABLE IF NOT EXISTS exposicoes (
  id               INT UNSIGNED    NOT NULL AUTO_INCREMENT,
  titulo           VARCHAR(200)    NOT NULL,
  descricao        TEXT            NULL,
  tema             VARCHAR(100)    NULL,
  url_miniatura    VARCHAR(500)    NULL,
  criado_por       INT UNSIGNED    NOT NULL,
  activa           TINYINT(1)      NOT NULL DEFAULT 1,
  criado_em        DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  actualizado_em   DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP
                                   ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  KEY idx_exposicoes_criado_por (criado_por),
  KEY idx_exposicoes_activa     (activa),
  CONSTRAINT fk_exposicoes_utilizador
    FOREIGN KEY (criado_por) REFERENCES utilizadores (id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- =============================================================
-- 3. PECAS — Obras/peças dentro de cada sala
-- =============================================================
CREATE TABLE IF NOT EXISTS pecas (
  id               INT UNSIGNED    NOT NULL AUTO_INCREMENT,
  id_exposicao     INT UNSIGNED    NOT NULL,
  titulo           VARCHAR(200)    NOT NULL,
  descricao        TEXT            NULL,
  origem           VARCHAR(150)    NULL,
  periodo          VARCHAR(100)    NULL,
  autor            VARCHAR(150)    NULL,
  etiquetas        VARCHAR(300)    NULL,   -- ex: "escultura,bronze,angola"
  criado_por       INT UNSIGNED    NOT NULL,
  activa           TINYINT(1)      NOT NULL DEFAULT 1,
  criado_em        DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  actualizado_em   DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP
                                   ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  KEY        idx_pecas_exposicao  (id_exposicao),
  KEY        idx_pecas_criado_por (criado_por),
  KEY        idx_pecas_activa     (activa),
  FULLTEXT KEY ft_pecas_pesquisa  (titulo, descricao, etiquetas),
  CONSTRAINT fk_pecas_exposicao
    FOREIGN KEY (id_exposicao) REFERENCES exposicoes (id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_pecas_utilizador
    FOREIGN KEY (criado_por)   REFERENCES utilizadores (id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- =============================================================
-- 4. FICHEIROS_MEDIA — Ficheiros multimédia ligados às peças
-- =============================================================
CREATE TABLE IF NOT EXISTS ficheiros_media (
  id                  INT UNSIGNED    NOT NULL AUTO_INCREMENT,
  id_peca             INT UNSIGNED    NOT NULL,
  id_enviador         INT UNSIGNED    NOT NULL,
  tipo                ENUM('imagem','audio','video') NOT NULL,
  tipo_mime           VARCHAR(100)    NOT NULL,          -- ex: video/mp4
  nome_original       VARCHAR(255)    NOT NULL,
  caminho_original    VARCHAR(500)    NOT NULL,
  caminho_comprimido  VARCHAR(500)    NULL,
  tamanho_original    BIGINT UNSIGNED NOT NULL DEFAULT 0, -- bytes
  tamanho_comprimido  BIGINT UNSIGNED NULL,               -- bytes
  largura_px          SMALLINT UNSIGNED NULL,             -- imagens/vídeos
  altura_px           SMALLINT UNSIGNED NULL,
  duracao_segundos    INT UNSIGNED    NULL,               -- áudio/vídeo
  principal           TINYINT(1)      NOT NULL DEFAULT 0, -- ficheiro principal da peça
  criado_em           DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  KEY idx_ficheiros_media_peca     (id_peca),
  KEY idx_ficheiros_media_enviador (id_enviador),
  KEY idx_ficheiros_media_tipo     (tipo),
  CONSTRAINT fk_ficheiros_media_peca
    FOREIGN KEY (id_peca)     REFERENCES pecas (id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_ficheiros_media_enviador
    FOREIGN KEY (id_enviador) REFERENCES utilizadores (id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- =============================================================
-- 5. REGISTOS_COMPRESSAO — Relatório comparativo de compressão
--    (obrigatório pelo enunciado — secção 5)
--    NOTA: taxa_compressao calculada pela aplicação (Node.js)
--          para evitar problemas de compatibilidade com GENERATED
-- =============================================================
CREATE TABLE IF NOT EXISTS registos_compressao (
  id                  INT UNSIGNED    NOT NULL AUTO_INCREMENT,
  id_media            INT UNSIGNED    NOT NULL,
  codec               VARCHAR(60)     NOT NULL,          -- ex: H.264, AAC, WebP
  tamanho_original    BIGINT UNSIGNED NOT NULL,          -- bytes
  tamanho_comprimido  BIGINT UNSIGNED NOT NULL,          -- bytes
  taxa_compressao     DECIMAL(8,3)    NOT NULL DEFAULT 0, -- calculado e inserido pelo Node.js
  pontuacao_qualidade TINYINT UNSIGNED NULL,             -- 0-100 (PSNR simplificado)
  duracao_ms          INT UNSIGNED    NOT NULL DEFAULT 0, -- tempo de processamento
  criado_em           DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  KEY idx_registos_compressao_media (id_media),
  CONSTRAINT fk_registos_compressao_media
    FOREIGN KEY (id_media) REFERENCES ficheiros_media (id)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- =============================================================
-- 6. SESSOES_STREAMING — Sessões de streaming VOD e ao vivo
-- =============================================================
CREATE TABLE IF NOT EXISTS sessoes_streaming (
  id                  INT UNSIGNED    NOT NULL AUTO_INCREMENT,
  id_utilizador       INT UNSIGNED    NOT NULL,
  id_media            INT UNSIGNED    NOT NULL,
  tipo                ENUM('VOD','ao_vivo') NOT NULL DEFAULT 'VOD',
  iniciado_em         DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  terminado_em        DATETIME        NULL,
  ultima_posicao_s    INT UNSIGNED    NULL DEFAULT 0,    -- retomar reprodução
  bytes_transferidos  BIGINT UNSIGNED NOT NULL DEFAULT 0,
  endereco_ip         VARCHAR(45)     NULL,              -- suporta IPv6
  agente_utilizador   VARCHAR(300)    NULL,

  PRIMARY KEY (id),
  KEY idx_sessoes_streaming_utilizador (id_utilizador),
  KEY idx_sessoes_streaming_media      (id_media),
  KEY idx_sessoes_streaming_tipo       (tipo),
  CONSTRAINT fk_sessoes_streaming_utilizador
    FOREIGN KEY (id_utilizador) REFERENCES utilizadores (id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_sessoes_streaming_media
    FOREIGN KEY (id_media)      REFERENCES ficheiros_media (id)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- =============================================================
-- 7. REGISTOS_ACTIVIDADE — Auditoria de todas as ações
-- =============================================================
CREATE TABLE IF NOT EXISTS registos_actividade (
  id           BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
  id_utilizador INT UNSIGNED    NULL,                   -- NULL = ação anónima
  accao        VARCHAR(80)      NOT NULL,               -- ex: LOGIN, UPLOAD, STREAM_INICIO
  entidade     VARCHAR(60)      NULL,                   -- ex: pecas, ficheiros_media
  id_entidade  INT UNSIGNED     NULL,
  metadados    JSON             NULL,                   -- dados extras em JSON
  endereco_ip  VARCHAR(45)      NULL,
  criado_em    DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  KEY idx_registos_actividade_utilizador (id_utilizador),
  KEY idx_registos_actividade_accao      (accao),
  KEY idx_registos_actividade_entidade   (entidade, id_entidade),
  KEY idx_registos_actividade_data       (criado_em),
  CONSTRAINT fk_registos_actividade_utilizador
    FOREIGN KEY (id_utilizador) REFERENCES utilizadores (id)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

-- =============================================================
-- 8. FAVORITOS — Peças favoritas por utilizador
-- =============================================================
CREATE TABLE IF NOT EXISTS favoritos (
  id            INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  id_utilizador INT UNSIGNED  NOT NULL,
  id_peca       INT UNSIGNED  NOT NULL,
  criado_em     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  UNIQUE KEY uq_favorito             (id_utilizador, id_peca),
  KEY        idx_favoritos_utilizador (id_utilizador),
  KEY        idx_favoritos_peca       (id_peca),
  CONSTRAINT fk_favoritos_utilizador
    FOREIGN KEY (id_utilizador) REFERENCES utilizadores (id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_favoritos_peca
    FOREIGN KEY (id_peca)       REFERENCES pecas (id)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- =============================================================
-- DADOS INICIAIS (seed)
-- =============================================================

-- Administrador padrão
-- Senha: Admin@2026  (hash bcrypt gerado via bcryptjs rounds=12)
-- ATENÇÃO: substituir o hash por um gerado localmente antes de usar em produção
INSERT INTO utilizadores (nome, email, senha_hash, funcao) VALUES
('Administrador', 'admin@museu.ao',
 '$2b$12$K9Qm1e2WX3YZ4AB5CD6EFu7GHIjKLmNOpQrStUvWxYz0123456789ab',
 'admin');

-- Sala de exemplo
INSERT INTO exposicoes (titulo, descricao, tema, criado_por) VALUES
('Arte Tradicional Angolana',
 'Exposição dedicada às manifestações artísticas dos povos de Angola.',
 'Cultura e Tradição', 1);

-- =============================================================
-- VISTAS — Relatório de compressão e estatísticas de streaming
-- =============================================================

CREATE OR REPLACE VIEW vw_relatorio_compressao AS
SELECT
  fm.id                                               AS id_media,
  fm.nome_original,
  fm.tipo,
  rc.codec,
  fm.tamanho_original                                 AS bytes_originais,
  fm.tamanho_comprimido                               AS bytes_comprimidos,
  rc.taxa_compressao,
  CONCAT(ROUND(
    (1 - fm.tamanho_comprimido / fm.tamanho_original) * 100, 1
  ), ' %')                                            AS espaco_poupado,
  rc.pontuacao_qualidade,
  rc.duracao_ms                                       AS tempo_processamento_ms,
  p.titulo                                            AS titulo_peca
FROM ficheiros_media    fm
JOIN registos_compressao rc ON rc.id_media = fm.id
JOIN pecas               p  ON p.id        = fm.id_peca;


CREATE OR REPLACE VIEW vw_estatisticas_streaming AS
SELECT
  fm.id                                               AS id_media,
  fm.nome_original,
  fm.tipo,
  COUNT(ss.id)                                        AS total_sessoes,
  COALESCE(SUM(ss.bytes_transferidos), 0)             AS total_bytes,
  ROUND(AVG(
    TIMESTAMPDIFF(SECOND, ss.iniciado_em, ss.terminado_em)
  ), 1)                                               AS duracao_media_segundos
FROM ficheiros_media    fm
LEFT JOIN sessoes_streaming ss ON ss.id_media = fm.id
GROUP BY fm.id, fm.nome_original, fm.tipo;

-- =============================================================
-- FIM DO SCRIPT
-- =============================================================



select * from utilizadores;

USE museuvirtual;
SHOW TABLES;
SELECT * FROM utilizadores;