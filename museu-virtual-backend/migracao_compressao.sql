-- =============================================================
--  migracao_compressao.sql
--  Adiciona colunas para suporte a multimédia comprimida
--  Uso: mysql -u root -p museuvirtual < migracao_compressao.sql
--  Museu Virtual Interativo — ISPTEC 2026
-- =============================================================

ALTER TABLE computadores
  ADD COLUMN audio_url VARCHAR(500) DEFAULT NULL
  AFTER imagem_url;

ALTER TABLE computadores
  ADD COLUMN video_url VARCHAR(500) DEFAULT NULL
  AFTER audio_url;

ALTER TABLE computadores
  ADD COLUMN relatorio_compressao JSON DEFAULT NULL
  AFTER video_url;
