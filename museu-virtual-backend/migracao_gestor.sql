-- =============================================================
--  migracao_gestor.sql
--  Adiciona o papel 'gestor' ao ENUM da coluna `funcao`
--  na tabela `utilizadores`.
--  Uso: mysql -u root -p museuvirtual < migracao_gestor.sql
--  Museu Virtual Interativo — ISPTEC 2026
-- =============================================================

ALTER TABLE utilizadores
  MODIFY COLUMN funcao ENUM('admin','curador','visitante','gestor')
  NOT NULL DEFAULT 'visitante';

-- Opcional: criar um gestor de exemplo (email: gestor@exemplo.com, senha: gestor123)
-- INSERT INTO utilizadores (nome, email, senha_hash, funcao, activo)
-- VALUES (
--   'Gestor Exemplo',
--   'gestor@exemplo.com',
--   '$2a$12$...hash_do_bcrypt...',
--   'gestor',
--   1
-- );
