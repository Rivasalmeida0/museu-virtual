-- MySQL dump 10.13  Distrib 9.7.1, for Win64 (x86_64)
--
-- Host: localhost    Database: museuvirtual
-- ------------------------------------------------------
-- Server version	9.7.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `computadores`
--

DROP TABLE IF EXISTS `computadores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `computadores` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `nome` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ano` smallint unsigned NOT NULL,
  `fabricante` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `categoria` enum('historico','supercomputador') COLLATE utf8mb4_unicode_ci NOT NULL,
  `descricao` text COLLATE utf8mb4_unicode_ci,
  `curiosidade` text COLLATE utf8mb4_unicode_ci,
  `imagem_url` varchar(1000) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `wikipedia_url` varchar(1000) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `especificacoes` json DEFAULT NULL,
  `activa` tinyint(1) NOT NULL DEFAULT '1',
  `criado_em` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `actualizado_em` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_computadores_categoria` (`categoria`),
  KEY `idx_computadores_ano` (`ano`),
  KEY `idx_computadores_activa` (`activa`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `computadores`
--

LOCK TABLES `computadores` WRITE;
/*!40000 ALTER TABLE `computadores` DISABLE KEYS */;
INSERT INTO `computadores` VALUES (1,'ENIAC',1945,'Universidade da Pensilv├ónia','historico','O primeiro computador eletr├│nico de uso geral do mundo. Pesava 27 toneladas, ocupava uma sala inteira e usava 18.000 v├ílvulas termoi├│nicas. Foi criado para calcular tabelas bal├¡sticas para o ex├®rcito americano.','Consumia tanta eletricidade que, segundo a lenda, as luzes da cidade piscavam quando era ligado.','/uploads/imagens/eniac.jpg','https://pt.wikipedia.org/wiki/ENIAC',NULL,1,'2026-06-22 13:22:52','2026-06-22 14:42:02'),(2,'Apple I',1976,'Apple Computer','historico','O primeiro produto da Apple, criado por Steve Wozniak e vendido por Steve Jobs. Era vendido como placa-m├úe sem caixa, monitor ou teclado ÔÇö o utilizador montava o resto.','Foi vendido originalmente por 666,66 d├│lares. Apenas 200 unidades foram produzidas e hoje vale at├® 400.000 d├│lares em leil├úo.','/uploads/imagens/apple_i.jpg','https://pt.wikipedia.org/wiki/Apple_I',NULL,1,'2026-06-22 13:22:52','2026-06-22 14:42:10'),(3,'Commodore 64',1982,'Commodore Business Machines','historico','O computador pessoal mais vendido de todos os tempos, com estimativas entre 10 a 17 milh├Áes de unidades. Era famoso pelos seus jogos e capacidade musical avan├ºada para a ├®poca.','O seu chip de som SID foi t├úo revolucion├írio que ainda hoje existem m├║sicos que o usam em concertos ao vivo.','/uploads/imagens/commodore_64.jpg','https://pt.wikipedia.org/wiki/Commodore_64',NULL,1,'2026-06-22 13:22:52','2026-06-22 14:42:15'),(4,'IBM 5150 (IBM PC)',1981,'IBM','historico','O computador que definiu o padr├úo da arquitectura PC tal como conhecemos hoje. A IBM abriu a arquitectura para outros fabricantes, criando o ecossistema de PCs compat├¡veis que domina at├® hoje.','A IBM contratou a Microsoft para fornecer o sistema operativo ÔÇö Bill Gates comprou o DOS por 50.000 d├│lares e licenciou-o ├á IBM, mantendo os direitos para si.','/uploads/imagens/ibm_5150__ibm_pc_.jpg','https://pt.wikipedia.org/wiki/IBM_Personal_Computer',NULL,1,'2026-06-22 13:22:52','2026-06-22 14:42:17'),(5,'Macintosh 128K',1984,'Apple','historico','O primeiro computador pessoal de sucesso comercial com interface gr├ífica e rato. Mudou para sempre a forma como as pessoas interagem com computadores.','Steve Jobs apresentou-o com o famoso an├║ncio \'1984\' durante o Super Bowl, que ├® considerado at├® hoje um dos melhores an├║ncios publicit├írios da hist├│ria.','/uploads/imagens/macintosh_128k.jpg','https://pt.wikipedia.org/wiki/Macintosh_128K',NULL,1,'2026-06-22 13:22:52','2026-06-22 14:42:19'),(6,'Cray-1',1976,'Cray Research','historico','O supercomputador mais r├ípido do mundo quando foi lan├ºado. A sua forma circular ic├│nica n├úo era apenas est├®tica ÔÇö foi projectada para minimizar o comprimento dos cabos e aumentar a velocidade.','O primeiro Cray-1 foi vendido ao Laborat├│rio Nacional de Los Alamos por 8,8 milh├Áes de d├│lares. O banco circular em volta servia de assento e escondia os sistemas de refrigera├º├úo.','/uploads/imagens/cray_1.jpg','https://pt.wikipedia.org/wiki/Cray-1',NULL,1,'2026-06-22 13:22:52','2026-06-22 14:45:32'),(7,'ZX Spectrum',1982,'Sinclair Research','historico','O computador que introduziu a computa├º├úo pessoal para milh├Áes de europeus, especialmente no Reino Unido e Portugal. Foi a base da ind├║stria de videojogos europeia nos anos 80.','Em Portugal e Angola, o ZX Spectrum foi o primeiro contacto de muita gente com a programa├º├úo ÔÇö as revistas da ├®poca vinham com c├│digo para digitar linha a linha.','/uploads/imagens/zx_spectrum.jpg','https://pt.wikipedia.org/wiki/ZX_Spectrum',NULL,1,'2026-06-22 13:22:52','2026-06-22 14:42:31'),(8,'Altair 8800',1975,'MITS','historico','Considerado o computador que deu in├¡cio ├á revolu├º├úo dos computadores pessoais. Era vendido em kit para montar em casa e n├úo tinha teclado, monitor nem sistema operativo ÔÇö s├│ luzes e interruptores.','Foi a capa do Altair na revista Popular Electronics que inspirou Bill Gates e Paul Allen a fundar a Microsoft, para criar um interpretador BASIC para ele.','/uploads/imagens/altair_8800.jpg','https://pt.wikipedia.org/wiki/Altair_8800',NULL,1,'2026-06-22 13:22:52','2026-06-22 14:42:34'),(9,'Deep Blue',1996,'IBM','historico','O supercomputador da IBM especializado em xadrez que derrotou o campe├úo mundial Garry Kasparov em 1997. Foi um marco hist├│rico na intelig├¬ncia artificial.','Kasparov acusou a IBM de usar jogadores humanos a ajudar o Deep Blue durante a partida. A IBM negou e nunca permitiu uma revanche, encerrando o projecto logo depois.','/uploads/imagens/deep_blue.jpg','https://pt.wikipedia.org/wiki/Deep_Blue',NULL,1,'2026-06-22 13:22:52','2026-06-22 14:42:35'),(10,'Commodore Amiga 1000',1985,'Commodore','historico','Um computador muito ├á frente do seu tempo, com capacidades gr├íficas e de multitarefa que os PCs da ├®poca nem sonhavam ter. Era usado profissionalmente em produ├º├úo de v├¡deo e anima├º├úo.','As assinaturas dos engenheiros que o criaram est├úo gravadas na placa-m├úe para sempre ÔÇö incluindo a pata do c├úo de estima├º├úo do designer de hardware.','/uploads/imagens/commodore_amiga_1000.jpg','https://pt.wikipedia.org/wiki/Amiga_1000',NULL,1,'2026-06-22 13:22:52','2026-06-22 14:42:37'),(11,'IBM System/360',1964,'IBM','historico','A fam├¡lia de computadores que revolucionou a ind├║stria ao introduzir o conceito de arquitectura compat├¡vel ÔÇö diferentes modelos podiam correr o mesmo software. Mudou para sempre como os computadores s├úo desenhados.','O desenvolvimento do System/360 custou 5 mil milh├Áes de d├│lares ÔÇö mais do que o Projecto Manhattan da bomba at├│mica. Foi a maior aposta empresarial da hist├│ria at├® ent├úo.','/uploads/imagens/ibm_system_360.jpg','https://pt.wikipedia.org/wiki/IBM_System/360',NULL,1,'2026-06-22 13:22:52','2026-06-22 14:48:29'),(12,'Frontier',2022,'HPE / AMD ÔÇö Oak Ridge National Laboratory','supercomputador','O primeiro supercomputador a ultrapassar a barreira do exaflop ÔÇö 1 quintilh├úo de opera├º├Áes por segundo. ├ë actualmente o mais r├ípido do mundo na lista TOP500.','A velocidade do Frontier ├® t├úo grande que, se cada ser humano na Terra fizesse um c├ílculo por segundo, levariam mais de 4 anos para fazer o que o Frontier faz em apenas 1 segundo.','/uploads/imagens/frontier.jpg','https://pt.wikipedia.org/wiki/Frontier_(supercomputador)',NULL,1,'2026-06-22 13:22:52','2026-06-22 15:18:49'),(13,'Summit',2018,'IBM / NVIDIA ÔÇö Oak Ridge National Laboratory','supercomputador','Foi o supercomputador mais r├ípido do mundo entre 2018 e 2022. Usado para investiga├º├úo em medicina, clima, f├¡sica de part├¡culas e intelig├¬ncia artificial.','O Summit foi usado para identificar compostos que podiam combater o COVID-19 em 2020 ÔÇö analisou 8.000 compostos em dias, algo que levaria anos a um laborat├│rio convencional.','/uploads/imagens/summit.jpg','https://pt.wikipedia.org/wiki/Summit_(supercomputador)',NULL,1,'2026-06-22 13:22:52','2026-06-22 14:46:04'),(14,'Fugaku',2020,'RIKEN / Fujitsu','supercomputador','Supercomputador japon├¬s que foi o mais r├ípido do mundo em 2020-2021. Usa processadores ARM, provando que a arquitectura dos smartphones pode competir com hardware especializado.','O nome Fugaku ├® outro nome do Monte Fuji em japon├¬s. Foi usado para simular a dispers├úo de got├¡culas do v├¡rus em espa├ºos fechados durante a pandemia.','/uploads/imagens/fugaku.jpg','https://pt.wikipedia.org/wiki/Fugaku_(supercomputador)',NULL,1,'2026-06-22 13:22:52','2026-06-22 14:46:06'),(15,'Aurora',2023,'Intel / HPE ÔÇö Argonne National Laboratory','supercomputador','Um dos supercomputadores exascale mais recentes, projectado especificamente para intelig├¬ncia artificial e simula├º├Áes cient├¡ficas de larga escala.','O Aurora foi concebido para treinar modelos de IA cient├¡fica de n├¡vel nacional ÔÇö desde modelos clim├íticos at├® ao mapeamento do c├®rebro humano.','/uploads/imagens/aurora.jpg','https://en.wikipedia.org/wiki/Aurora_(supercomputer)',NULL,1,'2026-06-22 13:22:52','2026-06-22 14:49:11'),(16,'El Capitan',2024,'HPE / AMD ÔÇö Lawrence Livermore National Laboratory','supercomputador','O supercomputador mais recente e poderoso dos EUA, com capacidade de 2 exaflops. Destinado principalmente a simula├º├Áes de armas nucleares e seguran├ºa nacional.','O El Capitan ├® t├úo potente que pode fazer em 1 hora simula├º├Áes que levariam anos nos supercomputadores da d├®cada anterior.','/uploads/imagens/el_capitan.jpg','https://en.wikipedia.org/wiki/El_Capitan_(supercomputer)',NULL,1,'2026-06-22 13:22:52','2026-06-22 15:18:49'),(17,'sergio',2020,'22','historico','eqe2e','2e2','/uploads/imagens/1782249549430-792088.png','ddd',NULL,1,'2026-06-23 22:16:38','2026-06-23 22:19:09'),(18,'sergio',2020,'22','historico','eqe2e','2e2',NULL,'ddd',NULL,0,'2026-06-23 22:16:44','2026-06-23 22:19:00'),(19,'sergio',2020,'22','historico','eqe2e','2e2','/uploads/imagens/1782249525402-19716.jpg','ddd',NULL,0,'2026-06-23 22:18:45','2026-06-23 22:18:55');
/*!40000 ALTER TABLE `computadores` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `exposicoes`
--

DROP TABLE IF EXISTS `exposicoes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `exposicoes` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `titulo` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `descricao` text COLLATE utf8mb4_unicode_ci,
  `tema` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `url_miniatura` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `criado_por` int unsigned NOT NULL,
  `activa` tinyint(1) NOT NULL DEFAULT '1',
  `criado_em` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `actualizado_em` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_exposicoes_criado_por` (`criado_por`),
  KEY `idx_exposicoes_activa` (`activa`),
  CONSTRAINT `fk_exposicoes_utilizador` FOREIGN KEY (`criado_por`) REFERENCES `utilizadores` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `exposicoes`
--

LOCK TABLES `exposicoes` WRITE;
/*!40000 ALTER TABLE `exposicoes` DISABLE KEYS */;
INSERT INTO `exposicoes` VALUES (1,'Arte Tradicional Angolana','Exposi├º├úo dedicada ├ás manifesta├º├Áes art├¡sticas dos povos de Angola.','Cultura e Tradi├º├úo',NULL,1,1,'2026-06-22 10:26:41','2026-06-22 10:26:41');
/*!40000 ALTER TABLE `exposicoes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `favoritos`
--

DROP TABLE IF EXISTS `favoritos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `favoritos` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `id_utilizador` int unsigned NOT NULL,
  `id_peca` int unsigned NOT NULL,
  `criado_em` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_favorito` (`id_utilizador`,`id_peca`),
  KEY `idx_favoritos_utilizador` (`id_utilizador`),
  KEY `idx_favoritos_peca` (`id_peca`),
  CONSTRAINT `fk_favoritos_peca` FOREIGN KEY (`id_peca`) REFERENCES `pecas` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_favoritos_utilizador` FOREIGN KEY (`id_utilizador`) REFERENCES `utilizadores` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `favoritos`
--

LOCK TABLES `favoritos` WRITE;
/*!40000 ALTER TABLE `favoritos` DISABLE KEYS */;
/*!40000 ALTER TABLE `favoritos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ficheiros_media`
--

DROP TABLE IF EXISTS `ficheiros_media`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ficheiros_media` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `id_peca` int unsigned NOT NULL,
  `id_enviador` int unsigned NOT NULL,
  `tipo` enum('imagem','audio','video') COLLATE utf8mb4_unicode_ci NOT NULL,
  `tipo_mime` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nome_original` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `caminho_original` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `caminho_comprimido` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tamanho_original` bigint unsigned NOT NULL DEFAULT '0',
  `tamanho_comprimido` bigint unsigned DEFAULT NULL,
  `largura_px` smallint unsigned DEFAULT NULL,
  `altura_px` smallint unsigned DEFAULT NULL,
  `duracao_segundos` int unsigned DEFAULT NULL,
  `principal` tinyint(1) NOT NULL DEFAULT '0',
  `criado_em` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_ficheiros_media_peca` (`id_peca`),
  KEY `idx_ficheiros_media_enviador` (`id_enviador`),
  KEY `idx_ficheiros_media_tipo` (`tipo`),
  CONSTRAINT `fk_ficheiros_media_enviador` FOREIGN KEY (`id_enviador`) REFERENCES `utilizadores` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_ficheiros_media_peca` FOREIGN KEY (`id_peca`) REFERENCES `pecas` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ficheiros_media`
--

LOCK TABLES `ficheiros_media` WRITE;
/*!40000 ALTER TABLE `ficheiros_media` DISABLE KEYS */;
/*!40000 ALTER TABLE `ficheiros_media` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pecas`
--

DROP TABLE IF EXISTS `pecas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pecas` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `id_exposicao` int unsigned NOT NULL,
  `titulo` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `descricao` text COLLATE utf8mb4_unicode_ci,
  `origem` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `periodo` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `autor` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `etiquetas` varchar(300) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `criado_por` int unsigned NOT NULL,
  `activa` tinyint(1) NOT NULL DEFAULT '1',
  `criado_em` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `actualizado_em` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_pecas_exposicao` (`id_exposicao`),
  KEY `idx_pecas_criado_por` (`criado_por`),
  KEY `idx_pecas_activa` (`activa`),
  FULLTEXT KEY `ft_pecas_pesquisa` (`titulo`,`descricao`,`etiquetas`),
  CONSTRAINT `fk_pecas_exposicao` FOREIGN KEY (`id_exposicao`) REFERENCES `exposicoes` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_pecas_utilizador` FOREIGN KEY (`criado_por`) REFERENCES `utilizadores` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pecas`
--

LOCK TABLES `pecas` WRITE;
/*!40000 ALTER TABLE `pecas` DISABLE KEYS */;
/*!40000 ALTER TABLE `pecas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `registos_actividade`
--

DROP TABLE IF EXISTS `registos_actividade`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `registos_actividade` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `id_utilizador` int unsigned DEFAULT NULL,
  `accao` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `entidade` varchar(60) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `id_entidade` int unsigned DEFAULT NULL,
  `metadados` json DEFAULT NULL,
  `endereco_ip` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `criado_em` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_registos_actividade_utilizador` (`id_utilizador`),
  KEY `idx_registos_actividade_accao` (`accao`),
  KEY `idx_registos_actividade_entidade` (`entidade`,`id_entidade`),
  KEY `idx_registos_actividade_data` (`criado_em`),
  CONSTRAINT `fk_registos_actividade_utilizador` FOREIGN KEY (`id_utilizador`) REFERENCES `utilizadores` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `registos_actividade`
--

LOCK TABLES `registos_actividade` WRITE;
/*!40000 ALTER TABLE `registos_actividade` DISABLE KEYS */;
INSERT INTO `registos_actividade` VALUES (1,NULL,'LOGIN','users',NULL,NULL,'::1','2026-06-23 22:05:17'),(2,NULL,'LOGIN','users',NULL,NULL,'::1','2026-06-23 22:16:11'),(3,NULL,'REGISTO','users',NULL,NULL,'::1','2026-06-23 22:22:44');
/*!40000 ALTER TABLE `registos_actividade` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `registos_compressao`
--

DROP TABLE IF EXISTS `registos_compressao`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `registos_compressao` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `id_media` int unsigned NOT NULL,
  `codec` varchar(60) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tamanho_original` bigint unsigned NOT NULL,
  `tamanho_comprimido` bigint unsigned NOT NULL,
  `taxa_compressao` decimal(8,3) NOT NULL DEFAULT '0.000',
  `pontuacao_qualidade` tinyint unsigned DEFAULT NULL,
  `duracao_ms` int unsigned NOT NULL DEFAULT '0',
  `criado_em` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_registos_compressao_media` (`id_media`),
  CONSTRAINT `fk_registos_compressao_media` FOREIGN KEY (`id_media`) REFERENCES `ficheiros_media` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `registos_compressao`
--

LOCK TABLES `registos_compressao` WRITE;
/*!40000 ALTER TABLE `registos_compressao` DISABLE KEYS */;
/*!40000 ALTER TABLE `registos_compressao` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sessoes_streaming`
--

DROP TABLE IF EXISTS `sessoes_streaming`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sessoes_streaming` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `id_utilizador` int unsigned NOT NULL,
  `id_media` int unsigned NOT NULL,
  `tipo` enum('VOD','ao_vivo') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'VOD',
  `iniciado_em` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `terminado_em` datetime DEFAULT NULL,
  `ultima_posicao_s` int unsigned DEFAULT '0',
  `bytes_transferidos` bigint unsigned NOT NULL DEFAULT '0',
  `endereco_ip` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `agente_utilizador` varchar(300) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_sessoes_streaming_utilizador` (`id_utilizador`),
  KEY `idx_sessoes_streaming_media` (`id_media`),
  KEY `idx_sessoes_streaming_tipo` (`tipo`),
  CONSTRAINT `fk_sessoes_streaming_media` FOREIGN KEY (`id_media`) REFERENCES `ficheiros_media` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_sessoes_streaming_utilizador` FOREIGN KEY (`id_utilizador`) REFERENCES `utilizadores` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sessoes_streaming`
--

LOCK TABLES `sessoes_streaming` WRITE;
/*!40000 ALTER TABLE `sessoes_streaming` DISABLE KEYS */;
/*!40000 ALTER TABLE `sessoes_streaming` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `utilizadores`
--

DROP TABLE IF EXISTS `utilizadores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `utilizadores` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `nome` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(180) COLLATE utf8mb4_unicode_ci NOT NULL,
  `senha_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `funcao` enum('admin','curador','visitante','gestor') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'visitante',
  `url_avatar` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `biografia` text COLLATE utf8mb4_unicode_ci,
  `activo` tinyint(1) NOT NULL DEFAULT '1',
  `criado_em` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `actualizado_em` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_utilizadores_email` (`email`),
  KEY `idx_utilizadores_funcao` (`funcao`),
  KEY `idx_utilizadores_activo` (`activo`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `utilizadores`
--

LOCK TABLES `utilizadores` WRITE;
/*!40000 ALTER TABLE `utilizadores` DISABLE KEYS */;
INSERT INTO `utilizadores` VALUES (1,'Administrador','admin@museu.ao','$2b$12$K9Qm1e2WX3YZ4AB5CD6EFu7GHIjKLmNOpQrStUvWxYz0123456789ab','admin',NULL,NULL,1,'2026-06-22 10:26:41','2026-06-22 10:26:41'),(2,'Sergio Almeida','gestor@museu.com','$2a$12$6jFllZZfKFeMFJOd1MMesu3.Cvlhn3GB7aVbDA42SRCykA47qwML6','gestor',NULL,NULL,1,'2026-06-23 21:56:59','2026-06-23 21:56:59'),(3,'mario','mario@email.com','$2a$12$VLwHIagZj3MN98DOtbeOke69sM3puMVjZKvvD0mJq8ZPwZYjr4rxS','visitante',NULL,NULL,1,'2026-06-23 22:22:44','2026-06-23 22:22:44');
/*!40000 ALTER TABLE `utilizadores` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `vw_estatisticas_streaming`
--

DROP TABLE IF EXISTS `vw_estatisticas_streaming`;
/*!50001 DROP VIEW IF EXISTS `vw_estatisticas_streaming`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_estatisticas_streaming` AS SELECT 
 1 AS `id_media`,
 1 AS `nome_original`,
 1 AS `tipo`,
 1 AS `total_sessoes`,
 1 AS `total_bytes`,
 1 AS `duracao_media_segundos`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_relatorio_compressao`
--

DROP TABLE IF EXISTS `vw_relatorio_compressao`;
/*!50001 DROP VIEW IF EXISTS `vw_relatorio_compressao`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_relatorio_compressao` AS SELECT 
 1 AS `id_media`,
 1 AS `nome_original`,
 1 AS `tipo`,
 1 AS `codec`,
 1 AS `bytes_originais`,
 1 AS `bytes_comprimidos`,
 1 AS `taxa_compressao`,
 1 AS `espaco_poupado`,
 1 AS `pontuacao_qualidade`,
 1 AS `tempo_processamento_ms`,
 1 AS `titulo_peca`*/;
SET character_set_client = @saved_cs_client;

--
-- Final view structure for view `vw_estatisticas_streaming`
--

/*!50001 DROP VIEW IF EXISTS `vw_estatisticas_streaming`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_estatisticas_streaming` AS select `fm`.`id` AS `id_media`,`fm`.`nome_original` AS `nome_original`,`fm`.`tipo` AS `tipo`,count(`ss`.`id`) AS `total_sessoes`,coalesce(sum(`ss`.`bytes_transferidos`),0) AS `total_bytes`,round(avg(timestampdiff(SECOND,`ss`.`iniciado_em`,`ss`.`terminado_em`)),1) AS `duracao_media_segundos` from (`ficheiros_media` `fm` left join `sessoes_streaming` `ss` on((`ss`.`id_media` = `fm`.`id`))) group by `fm`.`id`,`fm`.`nome_original`,`fm`.`tipo` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_relatorio_compressao`
--

/*!50001 DROP VIEW IF EXISTS `vw_relatorio_compressao`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_relatorio_compressao` AS select `fm`.`id` AS `id_media`,`fm`.`nome_original` AS `nome_original`,`fm`.`tipo` AS `tipo`,`rc`.`codec` AS `codec`,`fm`.`tamanho_original` AS `bytes_originais`,`fm`.`tamanho_comprimido` AS `bytes_comprimidos`,`rc`.`taxa_compressao` AS `taxa_compressao`,concat(round(((1 - (`fm`.`tamanho_comprimido` / `fm`.`tamanho_original`)) * 100),1),' %') AS `espaco_poupado`,`rc`.`pontuacao_qualidade` AS `pontuacao_qualidade`,`rc`.`duracao_ms` AS `tempo_processamento_ms`,`p`.`titulo` AS `titulo_peca` from ((`ficheiros_media` `fm` join `registos_compressao` `rc` on((`rc`.`id_media` = `fm`.`id`))) join `pecas` `p` on((`p`.`id` = `fm`.`id_peca`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-06-24  1:53:20
