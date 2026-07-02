-- =============================================================
--  migracao_streaming.sql
--  Tabela para transmissões ao vivo WebRTC (gestor -> visitantes)
--  Uso: mysql -u root -p museuvirtual < migracao_streaming.sql
--  Museu Virtual Interativo — ISPTEC 2026
-- =============================================================

CREATE TABLE IF NOT EXISTS streaming (
  id           INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  titulo       VARCHAR(200) NOT NULL DEFAULT 'Visita Guiada ao Vivo',
  gestor_nome  VARCHAR(200) NULL,
  gestor_id    INT UNSIGNED NULL,
  ativo        BOOLEAN      NOT NULL DEFAULT false,
  iniciado_em  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  terminado_em DATETIME     NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Migração a partir da versão anterior com video_id (YouTube)
-- Executar manualmente se a tabela já existir:
-- ALTER TABLE streaming DROP COLUMN video_id;
-- ALTER TABLE streaming ADD COLUMN gestor_nome VARCHAR(200) NULL AFTER titulo;
-- ALTER TABLE streaming ADD COLUMN gestor_id INT UNSIGNED NULL AFTER gestor_nome;
