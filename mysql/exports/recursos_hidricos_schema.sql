CREATE DATABASE  IF NOT EXISTS `recursos_hidricos` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `recursos_hidricos`;
-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: localhost    Database: recursos_hidricos
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `acao_ocorrencia`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `acao_ocorrencia` (
  `id_acao` bigint unsigned NOT NULL AUTO_INCREMENT,
  `id_ocorrencia` bigint unsigned NOT NULL,
  `descricao` text NOT NULL,
  `realizada_em` datetime(3) NOT NULL,
  `id_usuario_responsavel` int unsigned NOT NULL,
  PRIMARY KEY (`id_acao`),
  KEY `ix_acao_ocorrencia_id_ocorrencia` (`id_ocorrencia`),
  KEY `ix_acao_ocorrencia_id_usuario_responsavel` (`id_usuario_responsavel`),
  CONSTRAINT `fk_acao_ocorrencia_id_ocorrencia` FOREIGN KEY (`id_ocorrencia`) REFERENCES `ocorrencia` (`id_ocorrencia`),
  CONSTRAINT `fk_acao_ocorrencia_id_usuario_responsavel` FOREIGN KEY (`id_usuario_responsavel`) REFERENCES `usuario` (`id_usuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `alerta`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `alerta` (
  `id_alerta` bigint unsigned NOT NULL AUTO_INCREMENT,
  `id_versao_abertura` int unsigned NOT NULL,
  `aberto_em` datetime(3) NOT NULL,
  `id_usuario_abertura` int unsigned NOT NULL,
  `reconhecido_em` datetime(3) DEFAULT NULL,
  `id_usuario_reconhecimento` int unsigned DEFAULT NULL,
  `encerrado_em` datetime(3) DEFAULT NULL,
  `id_usuario_encerramento` int unsigned DEFAULT NULL,
  `motivo_encerramento` varchar(500) DEFAULT NULL,
  `id_ocorrencia` bigint unsigned DEFAULT NULL,
  PRIMARY KEY (`id_alerta`),
  KEY `ix_alerta_id_versao_abertura` (`id_versao_abertura`),
  KEY `ix_alerta_id_usuario_abertura` (`id_usuario_abertura`),
  KEY `ix_alerta_id_usuario_reconhecimento` (`id_usuario_reconhecimento`),
  KEY `ix_alerta_id_usuario_encerramento` (`id_usuario_encerramento`),
  KEY `ix_alerta_id_ocorrencia` (`id_ocorrencia`),
  CONSTRAINT `fk_alerta_id_ocorrencia` FOREIGN KEY (`id_ocorrencia`) REFERENCES `ocorrencia` (`id_ocorrencia`),
  CONSTRAINT `fk_alerta_id_usuario_abertura` FOREIGN KEY (`id_usuario_abertura`) REFERENCES `usuario` (`id_usuario`),
  CONSTRAINT `fk_alerta_id_usuario_encerramento` FOREIGN KEY (`id_usuario_encerramento`) REFERENCES `usuario` (`id_usuario`),
  CONSTRAINT `fk_alerta_id_usuario_reconhecimento` FOREIGN KEY (`id_usuario_reconhecimento`) REFERENCES `usuario` (`id_usuario`),
  CONSTRAINT `fk_alerta_id_versao_abertura` FOREIGN KEY (`id_versao_abertura`) REFERENCES `versao_regra_monitoramento` (`id_versao`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bacia_hidrografica`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bacia_hidrografica` (
  `id_bacia` int unsigned NOT NULL AUTO_INCREMENT,
  `codigo` varchar(20) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `nome` varchar(120) NOT NULL,
  `descricao` varchar(500) DEFAULT NULL,
  `ativo` tinyint unsigned NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_bacia`),
  UNIQUE KEY `uq_bacia_hidrografica_1` (`codigo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `calibracao_parametro`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `calibracao_parametro` (
  `id_manutencao` bigint unsigned NOT NULL,
  `id_parametro` int unsigned NOT NULL,
  `valor_referencia` decimal(14,6) NOT NULL,
  `valor_observado` decimal(14,6) NOT NULL,
  `conclusao` varchar(500) NOT NULL,
  `ajuste_realizado` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`id_manutencao`,`id_parametro`),
  KEY `ix_calibracao_parametro_id_parametro` (`id_parametro`),
  CONSTRAINT `fk_calibracao_parametro_id_manutencao` FOREIGN KEY (`id_manutencao`) REFERENCES `manutencao` (`id_manutencao`),
  CONSTRAINT `fk_calibracao_parametro_id_parametro` FOREIGN KEY (`id_parametro`) REFERENCES `parametro_monitoramento` (`id_parametro`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `corpo_hidrico`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `corpo_hidrico` (
  `id_corpo_hidrico` int unsigned NOT NULL AUTO_INCREMENT,
  `codigo` varchar(20) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `nome` varchar(120) NOT NULL,
  `id_bacia` int unsigned NOT NULL,
  `codigo_tipo_corpo` varchar(12) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `descricao` varchar(500) DEFAULT NULL,
  `ativo` tinyint unsigned NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_corpo_hidrico`),
  UNIQUE KEY `uq_corpo_hidrico_1` (`codigo`),
  KEY `ix_corpo_hidrico_id_bacia` (`id_bacia`),
  KEY `ix_corpo_hidrico_codigo_tipo_corpo` (`codigo_tipo_corpo`),
  CONSTRAINT `fk_corpo_hidrico_codigo_tipo_corpo` FOREIGN KEY (`codigo_tipo_corpo`) REFERENCES `tipo_corpo_hidrico` (`codigo_tipo_corpo`),
  CONSTRAINT `fk_corpo_hidrico_id_bacia` FOREIGN KEY (`id_bacia`) REFERENCES `bacia_hidrografica` (`id_bacia`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `detalhe_auditoria`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `detalhe_auditoria` (
  `id_evento` bigint unsigned NOT NULL,
  `nome_atributo` varchar(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `anterior_presente` tinyint unsigned NOT NULL,
  `posterior_presente` tinyint unsigned NOT NULL,
  `valor_anterior` text,
  `valor_posterior` text,
  PRIMARY KEY (`id_evento`,`nome_atributo`),
  CONSTRAINT `fk_detalhe_auditoria_id_evento` FOREIGN KEY (`id_evento`) REFERENCES `evento_auditoria` (`id_evento`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `estacao_monitoramento`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `estacao_monitoramento` (
  `id_estacao` int unsigned NOT NULL AUTO_INCREMENT,
  `codigo` varchar(20) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `nome` varchar(120) NOT NULL,
  `id_corpo_hidrico` int unsigned NOT NULL,
  `id_orgao` int unsigned NOT NULL,
  `latitude` decimal(8,6) NOT NULL,
  `longitude` decimal(9,6) NOT NULL,
  `descricao_localizacao` varchar(255) DEFAULT NULL,
  `ativo` tinyint unsigned NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_estacao`),
  UNIQUE KEY `uq_estacao_monitoramento_1` (`codigo`),
  KEY `ix_estacao_monitoramento_id_corpo_hidrico` (`id_corpo_hidrico`),
  KEY `ix_estacao_monitoramento_id_orgao` (`id_orgao`),
  CONSTRAINT `fk_estacao_monitoramento_id_corpo_hidrico` FOREIGN KEY (`id_corpo_hidrico`) REFERENCES `corpo_hidrico` (`id_corpo_hidrico`),
  CONSTRAINT `fk_estacao_monitoramento_id_orgao` FOREIGN KEY (`id_orgao`) REFERENCES `orgao_responsavel` (`id_orgao`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `evento_auditoria`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `evento_auditoria` (
  `id_evento` bigint unsigned NOT NULL AUTO_INCREMENT,
  `id_usuario` int unsigned NOT NULL,
  `ocorrido_em` datetime(3) NOT NULL,
  `operacao` varchar(20) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `alvo_relacao` varchar(40) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `chave_alvo_1` varchar(128) NOT NULL,
  `chave_alvo_2` varchar(128) DEFAULT NULL,
  `chave_alvo_3` varchar(128) DEFAULT NULL,
  `descricao` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`id_evento`),
  KEY `ix_evento_auditoria_id_usuario` (`id_usuario`),
  CONSTRAINT `fk_evento_auditoria_id_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `evidencia_alerta`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `evidencia_alerta` (
  `id_documento_mongo` char(24) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `id_leitura` varchar(40) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `id_alerta` bigint unsigned NOT NULL,
  `id_versao_avaliacao` int unsigned NOT NULL,
  `origem` tinyint unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id_documento_mongo`,`id_leitura`),
  KEY `ix_evidencia_alerta_id_alerta` (`id_alerta`),
  KEY `ix_evidencia_alerta_id_versao_avaliacao` (`id_versao_avaliacao`),
  CONSTRAINT `fk_evidencia_alerta_id_alerta` FOREIGN KEY (`id_alerta`) REFERENCES `alerta` (`id_alerta`),
  CONSTRAINT `fk_evidencia_alerta_id_versao_avaliacao` FOREIGN KEY (`id_versao_avaliacao`) REFERENCES `versao_regra_monitoramento` (`id_versao`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `instalacao_sensor`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `instalacao_sensor` (
  `id_instalacao` int unsigned NOT NULL AUTO_INCREMENT,
  `id_sensor` int unsigned NOT NULL,
  `id_estacao` int unsigned NOT NULL,
  `inicio_em` datetime(3) NOT NULL,
  `fim_em` datetime(3) DEFAULT NULL,
  `id_usuario_instalacao` int unsigned NOT NULL,
  `id_usuario_retirada` int unsigned DEFAULT NULL,
  `observacao` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`id_instalacao`),
  UNIQUE KEY `uq_instalacao_sensor_1` (`id_sensor`,`inicio_em`),
  KEY `ix_instalacao_sensor_id_estacao` (`id_estacao`),
  KEY `ix_instalacao_sensor_id_usuario_instalacao` (`id_usuario_instalacao`),
  KEY `ix_instalacao_sensor_id_usuario_retirada` (`id_usuario_retirada`),
  CONSTRAINT `fk_instalacao_sensor_id_estacao` FOREIGN KEY (`id_estacao`) REFERENCES `estacao_monitoramento` (`id_estacao`),
  CONSTRAINT `fk_instalacao_sensor_id_sensor` FOREIGN KEY (`id_sensor`) REFERENCES `sensor` (`id_sensor`),
  CONSTRAINT `fk_instalacao_sensor_id_usuario_instalacao` FOREIGN KEY (`id_usuario_instalacao`) REFERENCES `usuario` (`id_usuario`),
  CONSTRAINT `fk_instalacao_sensor_id_usuario_retirada` FOREIGN KEY (`id_usuario_retirada`) REFERENCES `usuario` (`id_usuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `manutencao`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `manutencao` (
  `id_manutencao` bigint unsigned NOT NULL AUTO_INCREMENT,
  `id_estacao` int unsigned DEFAULT NULL,
  `id_sensor` int unsigned DEFAULT NULL,
  `id_ocorrencia` bigint unsigned DEFAULT NULL,
  `tipo_intervencao` varchar(12) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `inicio_em` datetime(3) NOT NULL,
  `fim_em` datetime(3) NOT NULL,
  `descricao` text NOT NULL,
  `resultado` text NOT NULL,
  `id_usuario_responsavel` int unsigned NOT NULL,
  PRIMARY KEY (`id_manutencao`),
  KEY `ix_manutencao_id_estacao` (`id_estacao`),
  KEY `ix_manutencao_id_sensor` (`id_sensor`),
  KEY `ix_manutencao_id_ocorrencia` (`id_ocorrencia`),
  KEY `ix_manutencao_id_usuario_responsavel` (`id_usuario_responsavel`),
  CONSTRAINT `fk_manutencao_id_estacao` FOREIGN KEY (`id_estacao`) REFERENCES `estacao_monitoramento` (`id_estacao`),
  CONSTRAINT `fk_manutencao_id_ocorrencia` FOREIGN KEY (`id_ocorrencia`) REFERENCES `ocorrencia` (`id_ocorrencia`),
  CONSTRAINT `fk_manutencao_id_sensor` FOREIGN KEY (`id_sensor`) REFERENCES `sensor` (`id_sensor`),
  CONSTRAINT `fk_manutencao_id_usuario_responsavel` FOREIGN KEY (`id_usuario_responsavel`) REFERENCES `usuario` (`id_usuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ocorrencia`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ocorrencia` (
  `id_ocorrencia` bigint unsigned NOT NULL AUTO_INCREMENT,
  `titulo` varchar(160) NOT NULL,
  `descricao` text NOT NULL,
  `aberta_em` datetime(3) NOT NULL,
  `id_usuario_abertura` int unsigned NOT NULL,
  `tratamento_iniciado_em` datetime(3) DEFAULT NULL,
  `id_usuario_tratamento` int unsigned DEFAULT NULL,
  `concluida_em` datetime(3) DEFAULT NULL,
  `id_usuario_conclusao` int unsigned DEFAULT NULL,
  `justificativa_conclusao` text,
  PRIMARY KEY (`id_ocorrencia`),
  KEY `ix_ocorrencia_id_usuario_abertura` (`id_usuario_abertura`),
  KEY `ix_ocorrencia_id_usuario_tratamento` (`id_usuario_tratamento`),
  KEY `ix_ocorrencia_id_usuario_conclusao` (`id_usuario_conclusao`),
  CONSTRAINT `fk_ocorrencia_id_usuario_abertura` FOREIGN KEY (`id_usuario_abertura`) REFERENCES `usuario` (`id_usuario`),
  CONSTRAINT `fk_ocorrencia_id_usuario_conclusao` FOREIGN KEY (`id_usuario_conclusao`) REFERENCES `usuario` (`id_usuario`),
  CONSTRAINT `fk_ocorrencia_id_usuario_tratamento` FOREIGN KEY (`id_usuario_tratamento`) REFERENCES `usuario` (`id_usuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ocorrencia_corpo_hidrico`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ocorrencia_corpo_hidrico` (
  `id_ocorrencia` bigint unsigned NOT NULL,
  `id_corpo_hidrico` int unsigned NOT NULL,
  PRIMARY KEY (`id_ocorrencia`,`id_corpo_hidrico`),
  KEY `ix_ocorrencia_corpo_hidrico_id_corpo_hidrico` (`id_corpo_hidrico`),
  CONSTRAINT `fk_ocorrencia_corpo_hidrico_id_corpo_hidrico` FOREIGN KEY (`id_corpo_hidrico`) REFERENCES `corpo_hidrico` (`id_corpo_hidrico`),
  CONSTRAINT `fk_ocorrencia_corpo_hidrico_id_ocorrencia` FOREIGN KEY (`id_ocorrencia`) REFERENCES `ocorrencia` (`id_ocorrencia`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ocorrencia_estacao`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ocorrencia_estacao` (
  `id_ocorrencia` bigint unsigned NOT NULL,
  `id_estacao` int unsigned NOT NULL,
  PRIMARY KEY (`id_ocorrencia`,`id_estacao`),
  KEY `ix_ocorrencia_estacao_id_estacao` (`id_estacao`),
  CONSTRAINT `fk_ocorrencia_estacao_id_estacao` FOREIGN KEY (`id_estacao`) REFERENCES `estacao_monitoramento` (`id_estacao`),
  CONSTRAINT `fk_ocorrencia_estacao_id_ocorrencia` FOREIGN KEY (`id_ocorrencia`) REFERENCES `ocorrencia` (`id_ocorrencia`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ocorrencia_sensor`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ocorrencia_sensor` (
  `id_ocorrencia` bigint unsigned NOT NULL,
  `id_sensor` int unsigned NOT NULL,
  PRIMARY KEY (`id_ocorrencia`,`id_sensor`),
  KEY `ix_ocorrencia_sensor_id_sensor` (`id_sensor`),
  CONSTRAINT `fk_ocorrencia_sensor_id_ocorrencia` FOREIGN KEY (`id_ocorrencia`) REFERENCES `ocorrencia` (`id_ocorrencia`),
  CONSTRAINT `fk_ocorrencia_sensor_id_sensor` FOREIGN KEY (`id_sensor`) REFERENCES `sensor` (`id_sensor`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `orgao_responsavel`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orgao_responsavel` (
  `id_orgao` int unsigned NOT NULL AUTO_INCREMENT,
  `codigo` varchar(20) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `nome` varchar(120) NOT NULL,
  `descricao` varchar(500) DEFAULT NULL,
  `ativo` tinyint unsigned NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_orgao`),
  UNIQUE KEY `uq_orgao_responsavel_1` (`codigo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `parametro_monitoramento`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `parametro_monitoramento` (
  `id_parametro` int unsigned NOT NULL AUTO_INCREMENT,
  `codigo` varchar(20) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `nome` varchar(120) NOT NULL,
  `id_unidade` int unsigned NOT NULL,
  `descricao` varchar(500) DEFAULT NULL,
  `ativo` tinyint unsigned NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_parametro`),
  UNIQUE KEY `uq_parametro_monitoramento_1` (`codigo`),
  KEY `ix_parametro_monitoramento_id_unidade` (`id_unidade`),
  CONSTRAINT `fk_parametro_monitoramento_id_unidade` FOREIGN KEY (`id_unidade`) REFERENCES `unidade_medida` (`id_unidade`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `perfil`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `perfil` (
  `id_perfil` int unsigned NOT NULL AUTO_INCREMENT,
  `codigo` varchar(20) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `nome` varchar(120) NOT NULL,
  `descricao` varchar(500) DEFAULT NULL,
  `ativo` tinyint unsigned NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_perfil`),
  UNIQUE KEY `uq_perfil_1` (`codigo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `perfil_permissao`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `perfil_permissao` (
  `id_perfil` int unsigned NOT NULL,
  `id_permissao` int unsigned NOT NULL,
  PRIMARY KEY (`id_perfil`,`id_permissao`),
  KEY `ix_perfil_permissao_id_permissao` (`id_permissao`),
  CONSTRAINT `fk_perfil_permissao_id_perfil` FOREIGN KEY (`id_perfil`) REFERENCES `perfil` (`id_perfil`),
  CONSTRAINT `fk_perfil_permissao_id_permissao` FOREIGN KEY (`id_permissao`) REFERENCES `permissao` (`id_permissao`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `permissao`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `permissao` (
  `id_permissao` int unsigned NOT NULL AUTO_INCREMENT,
  `codigo` varchar(40) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `nome` varchar(120) NOT NULL,
  `descricao` varchar(500) DEFAULT NULL,
  `ativo` tinyint unsigned NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_permissao`),
  UNIQUE KEY `uq_permissao_1` (`codigo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `regra_monitoramento`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `regra_monitoramento` (
  `id_regra` int unsigned NOT NULL AUTO_INCREMENT,
  `id_estacao` int unsigned NOT NULL,
  `id_parametro` int unsigned NOT NULL,
  `ativo` tinyint unsigned NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_regra`),
  UNIQUE KEY `uq_regra_monitoramento_1` (`id_estacao`,`id_parametro`),
  KEY `ix_regra_monitoramento_id_parametro` (`id_parametro`),
  CONSTRAINT `fk_regra_monitoramento_id_estacao` FOREIGN KEY (`id_estacao`) REFERENCES `estacao_monitoramento` (`id_estacao`),
  CONSTRAINT `fk_regra_monitoramento_id_parametro` FOREIGN KEY (`id_parametro`) REFERENCES `parametro_monitoramento` (`id_parametro`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `resumo_diario_monitoramento`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `resumo_diario_monitoramento` (
  `id_estacao` int unsigned NOT NULL,
  `id_parametro` int unsigned NOT NULL,
  `dia_utc` date NOT NULL,
  `quantidade_validas` int unsigned NOT NULL,
  `soma` decimal(26,6) DEFAULT NULL,
  `minimo` decimal(14,6) DEFAULT NULL,
  `maximo` decimal(14,6) DEFAULT NULL,
  `consolidado_em` datetime(3) NOT NULL,
  PRIMARY KEY (`id_estacao`,`id_parametro`,`dia_utc`),
  KEY `ix_resumo_diario_monitoramento_id_parametro` (`id_parametro`),
  CONSTRAINT `fk_resumo_diario_monitoramento_id_estacao` FOREIGN KEY (`id_estacao`) REFERENCES `estacao_monitoramento` (`id_estacao`),
  CONSTRAINT `fk_resumo_diario_monitoramento_id_parametro` FOREIGN KEY (`id_parametro`) REFERENCES `parametro_monitoramento` (`id_parametro`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sensor`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sensor` (
  `id_sensor` int unsigned NOT NULL AUTO_INCREMENT,
  `codigo_patrimonial` varchar(20) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `id_tipo_sensor` int unsigned NOT NULL,
  `numero_serie` varchar(80) DEFAULT NULL,
  `descricao` varchar(500) DEFAULT NULL,
  `ativo` tinyint unsigned NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_sensor`),
  UNIQUE KEY `uq_sensor_1` (`codigo_patrimonial`),
  KEY `ix_sensor_id_tipo_sensor` (`id_tipo_sensor`),
  CONSTRAINT `fk_sensor_id_tipo_sensor` FOREIGN KEY (`id_tipo_sensor`) REFERENCES `tipo_sensor` (`id_tipo_sensor`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tipo_corpo_hidrico`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tipo_corpo_hidrico` (
  `codigo_tipo_corpo` varchar(12) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `nome` varchar(40) NOT NULL,
  PRIMARY KEY (`codigo_tipo_corpo`),
  UNIQUE KEY `uq_tipo_corpo_hidrico_1` (`nome`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tipo_sensor`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tipo_sensor` (
  `id_tipo_sensor` int unsigned NOT NULL AUTO_INCREMENT,
  `codigo` varchar(20) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `nome` varchar(120) NOT NULL,
  `descricao` varchar(500) DEFAULT NULL,
  `ativo` tinyint unsigned NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_tipo_sensor`),
  UNIQUE KEY `uq_tipo_sensor_1` (`codigo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tipo_sensor_parametro`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tipo_sensor_parametro` (
  `id_tipo_sensor` int unsigned NOT NULL,
  `id_parametro` int unsigned NOT NULL,
  PRIMARY KEY (`id_tipo_sensor`,`id_parametro`),
  KEY `ix_tipo_sensor_parametro_id_parametro` (`id_parametro`),
  CONSTRAINT `fk_tipo_sensor_parametro_id_parametro` FOREIGN KEY (`id_parametro`) REFERENCES `parametro_monitoramento` (`id_parametro`),
  CONSTRAINT `fk_tipo_sensor_parametro_id_tipo_sensor` FOREIGN KEY (`id_tipo_sensor`) REFERENCES `tipo_sensor` (`id_tipo_sensor`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `unidade_medida`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `unidade_medida` (
  `id_unidade` int unsigned NOT NULL AUTO_INCREMENT,
  `codigo` varchar(20) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `nome` varchar(80) NOT NULL,
  `simbolo` varchar(16) NOT NULL,
  `descricao` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id_unidade`),
  UNIQUE KEY `uq_unidade_medida_1` (`codigo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `usuario`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuario` (
  `id_usuario` int unsigned NOT NULL AUTO_INCREMENT,
  `email` varchar(254) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `nome` varchar(120) NOT NULL,
  `tipo_identidade` varchar(8) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `senha_hash` varchar(255) DEFAULT NULL,
  `ativo` tinyint unsigned NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_usuario`),
  UNIQUE KEY `uq_usuario_1` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `usuario_perfil`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuario_perfil` (
  `id_usuario` int unsigned NOT NULL,
  `id_perfil` int unsigned NOT NULL,
  PRIMARY KEY (`id_usuario`,`id_perfil`),
  KEY `ix_usuario_perfil_id_perfil` (`id_perfil`),
  CONSTRAINT `fk_usuario_perfil_id_perfil` FOREIGN KEY (`id_perfil`) REFERENCES `perfil` (`id_perfil`),
  CONSTRAINT `fk_usuario_perfil_id_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `versao_regra_monitoramento`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `versao_regra_monitoramento` (
  `id_versao` int unsigned NOT NULL AUTO_INCREMENT,
  `id_regra` int unsigned NOT NULL,
  `numero_versao` int unsigned NOT NULL,
  `limite_inferior` decimal(14,6) DEFAULT NULL,
  `limite_superior` decimal(14,6) DEFAULT NULL,
  `prioridade` varchar(7) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `inicio_em` datetime(3) NOT NULL,
  `fim_em` datetime(3) DEFAULT NULL,
  `id_usuario_configuracao` int unsigned NOT NULL,
  PRIMARY KEY (`id_versao`),
  UNIQUE KEY `uq_versao_regra_monitoramento_1` (`id_regra`,`numero_versao`),
  KEY `ix_versao_regra_monitoramento_id_usuario_configuracao` (`id_usuario_configuracao`),
  CONSTRAINT `fk_versao_regra_monitoramento_id_regra` FOREIGN KEY (`id_regra`) REFERENCES `regra_monitoramento` (`id_regra`),
  CONSTRAINT `fk_versao_regra_monitoramento_id_usuario_configuracao` FOREIGN KEY (`id_usuario_configuracao`) REFERENCES `usuario` (`id_usuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-19 20:50:41
