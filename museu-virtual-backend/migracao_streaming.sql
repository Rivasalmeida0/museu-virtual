-- =============================================================
--  migracao_streaming.sql
--  Adiciona tabela para transmissões ao vivo (YouTube Live)
--  Uso: mysql -u root -p museuvirtual < migracao_streaming.sql
--  Museu Virtual Interativo — ISPTEC 2026
-- =============================================================

CREATE TABLE IF NOT EXISTS streaming (
  id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  video_id    VARCHAR(50)  NOT NULL,
  titulo      VARCHAR(200) NOT NULL DEFAULT 'Visita Guiada ao Vivo',
  ativo       BOOLEAN      NOT NULL DEFAULT false,
  iniciado_em DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  terminado_em DATETIME    NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
