-- =============================================================
--  database/migration_vod.sql
--  Migração VOD — Museu Virtual Interativo
--  Novas tabelas para plataforma de Streaming Sob Demanda
-- =============================================================

-- ── Categorias VOD ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS `categorias_vod` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `descricao` TEXT COLLATE utf8mb4_unicode_ci,
  `icone` VARCHAR(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cor` VARCHAR(7) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ordem` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  `activa` TINYINT(1) NOT NULL DEFAULT 1,
  `criado_em` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `actualizado_em` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_categorias_vod_activa` (`activa`),
  KEY `idx_categorias_vod_ordem` (`ordem`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ── Relação vídeo ↔ categoria ─────────────────────────────────
CREATE TABLE IF NOT EXISTS `conteudo_categorias` (
  `id_conteudo` INT UNSIGNED NOT NULL,
  `id_categoria` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`id_conteudo`, `id_categoria`),
  KEY `idx_cc_categoria` (`id_categoria`),
  CONSTRAINT `fk_cc_categoria` FOREIGN KEY (`id_categoria`)
    REFERENCES `categorias_vod` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ── Progresso de reprodução (continuar a assistir) ────────────
CREATE TABLE IF NOT EXISTS `progresso_reproducao` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_utilizador` INT UNSIGNED NOT NULL,
  `id_conteudo` INT UNSIGNED NOT NULL,
  `posicao_segundos` INT UNSIGNED NOT NULL DEFAULT 0,
  `duracao_total_segundos` INT UNSIGNED NOT NULL DEFAULT 0,
  `percentagem` DECIMAL(5,2) NOT NULL DEFAULT 0.00,
  `actualizado_em` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_progresso` (`id_utilizador`, `id_conteudo`),
  KEY `idx_progresso_utilizador` (`id_utilizador`),
  CONSTRAINT `fk_progresso_utilizador` FOREIGN KEY (`id_utilizador`)
    REFERENCES `utilizadores` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ── Histórico de visualizações ────────────────────────────────
CREATE TABLE IF NOT EXISTS `historico_visualizacoes` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_utilizador` INT UNSIGNED NOT NULL,
  `id_conteudo` INT UNSIGNED NOT NULL,
  `visto_em` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_historico_utilizador` (`id_utilizador`),
  KEY `idx_historico_conteudo` (`id_conteudo`),
  KEY `idx_historico_visto_em` (`visto_em`),
  CONSTRAINT `fk_historico_utilizador` FOREIGN KEY (`id_utilizador`)
    REFERENCES `utilizadores` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ── Refresh Tokens ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS `refresh_tokens` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_utilizador` INT UNSIGNED NOT NULL,
  `token` VARCHAR(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expira_em` DATETIME NOT NULL,
  `revogado` TINYINT(1) NOT NULL DEFAULT 0,
  `criado_em` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_refresh_token` (`token`(191)),
  KEY `idx_rt_utilizador` (`id_utilizador`),
  KEY `idx_rt_expira` (`expira_em`),
  CONSTRAINT `fk_rt_utilizador` FOREIGN KEY (`id_utilizador`)
    REFERENCES `utilizadores` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ── Dados iniciais: Categorias ────────────────────────────────
INSERT INTO `categorias_vod` (`nome`, `descricao`, `icone`, `cor`, `ordem`) VALUES
  ('Documentários', 'Documentários sobre a história da computação', 'movie', '#E53935', 1),
  ('Tutoriais', 'Vídeos educativos e demonstrações', 'school', '#1E88E5', 2),
  ('Visitas Guiadas', 'Tours virtuais pelo museu', 'tour', '#43A047', 3),
  ('Conferências', 'Palestras e apresentações', 'mic', '#FB8C00', 4),
  ('Restauro', 'Processos de restauro de máquinas históricas', 'build', '#8E24AA', 5);

-- ── Adicionar campo categoria ao conteudo (se a tabela existir) ──
-- ALTER TABLE `conteudos` ADD COLUMN `id_categoria` INT UNSIGNED DEFAULT NULL;
-- ALTER TABLE `conteudos` ADD COLUMN `thumbnail_url` VARCHAR(500) DEFAULT NULL;
