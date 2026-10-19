-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
-- -----------------------------------------------------
-- Schema recursos_hidricos
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema recursos_hidricos
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `recursos_hidricos` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci ;
USE `recursos_hidricos` ;

-- -----------------------------------------------------
-- Table `recursos_hidricos`.`usuario`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `recursos_hidricos`.`usuario` (
  `id_usuario` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `email` VARCHAR(254) CHARACTER SET 'ascii' COLLATE 'ascii_bin' NOT NULL,
  `nome` VARCHAR(120) NOT NULL,
  `tipo_identidade` VARCHAR(8) CHARACTER SET 'ascii' COLLATE 'ascii_bin' NOT NULL,
  `senha_hash` VARCHAR(255) NULL DEFAULT NULL,
  `ativo` TINYINT UNSIGNED NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_usuario`),
  UNIQUE INDEX `uq_usuario_1` (`email` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `recursos_hidricos`.`ocorrencia`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `recursos_hidricos`.`ocorrencia` (
  `id_ocorrencia` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `titulo` VARCHAR(160) NOT NULL,
  `descricao` TEXT NOT NULL,
  `aberta_em` DATETIME(3) NOT NULL,
  `id_usuario_abertura` INT UNSIGNED NOT NULL,
  `tratamento_iniciado_em` DATETIME(3) NULL DEFAULT NULL,
  `id_usuario_tratamento` INT UNSIGNED NULL DEFAULT NULL,
  `concluida_em` DATETIME(3) NULL DEFAULT NULL,
  `id_usuario_conclusao` INT UNSIGNED NULL DEFAULT NULL,
  `justificativa_conclusao` TEXT NULL DEFAULT NULL,
  PRIMARY KEY (`id_ocorrencia`),
  INDEX `ix_ocorrencia_id_usuario_abertura` (`id_usuario_abertura` ASC) VISIBLE,
  INDEX `ix_ocorrencia_id_usuario_tratamento` (`id_usuario_tratamento` ASC) VISIBLE,
  INDEX `ix_ocorrencia_id_usuario_conclusao` (`id_usuario_conclusao` ASC) VISIBLE,
  CONSTRAINT `fk_ocorrencia_id_usuario_abertura`
    FOREIGN KEY (`id_usuario_abertura`)
    REFERENCES `recursos_hidricos`.`usuario` (`id_usuario`),
  CONSTRAINT `fk_ocorrencia_id_usuario_conclusao`
    FOREIGN KEY (`id_usuario_conclusao`)
    REFERENCES `recursos_hidricos`.`usuario` (`id_usuario`),
  CONSTRAINT `fk_ocorrencia_id_usuario_tratamento`
    FOREIGN KEY (`id_usuario_tratamento`)
    REFERENCES `recursos_hidricos`.`usuario` (`id_usuario`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `recursos_hidricos`.`acao_ocorrencia`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `recursos_hidricos`.`acao_ocorrencia` (
  `id_acao` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_ocorrencia` BIGINT UNSIGNED NOT NULL,
  `descricao` TEXT NOT NULL,
  `realizada_em` DATETIME(3) NOT NULL,
  `id_usuario_responsavel` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`id_acao`),
  INDEX `ix_acao_ocorrencia_id_ocorrencia` (`id_ocorrencia` ASC) VISIBLE,
  INDEX `ix_acao_ocorrencia_id_usuario_responsavel` (`id_usuario_responsavel` ASC) VISIBLE,
  CONSTRAINT `fk_acao_ocorrencia_id_ocorrencia`
    FOREIGN KEY (`id_ocorrencia`)
    REFERENCES `recursos_hidricos`.`ocorrencia` (`id_ocorrencia`),
  CONSTRAINT `fk_acao_ocorrencia_id_usuario_responsavel`
    FOREIGN KEY (`id_usuario_responsavel`)
    REFERENCES `recursos_hidricos`.`usuario` (`id_usuario`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `recursos_hidricos`.`tipo_corpo_hidrico`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `recursos_hidricos`.`tipo_corpo_hidrico` (
  `codigo_tipo_corpo` VARCHAR(12) CHARACTER SET 'ascii' COLLATE 'ascii_bin' NOT NULL,
  `nome` VARCHAR(40) NOT NULL,
  PRIMARY KEY (`codigo_tipo_corpo`),
  UNIQUE INDEX `uq_tipo_corpo_hidrico_1` (`nome` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `recursos_hidricos`.`bacia_hidrografica`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `recursos_hidricos`.`bacia_hidrografica` (
  `id_bacia` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `codigo` VARCHAR(20) CHARACTER SET 'ascii' COLLATE 'ascii_bin' NOT NULL,
  `nome` VARCHAR(120) NOT NULL,
  `descricao` VARCHAR(500) NULL DEFAULT NULL,
  `ativo` TINYINT UNSIGNED NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_bacia`),
  UNIQUE INDEX `uq_bacia_hidrografica_1` (`codigo` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `recursos_hidricos`.`corpo_hidrico`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `recursos_hidricos`.`corpo_hidrico` (
  `id_corpo_hidrico` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `codigo` VARCHAR(20) CHARACTER SET 'ascii' COLLATE 'ascii_bin' NOT NULL,
  `nome` VARCHAR(120) NOT NULL,
  `id_bacia` INT UNSIGNED NOT NULL,
  `codigo_tipo_corpo` VARCHAR(12) CHARACTER SET 'ascii' COLLATE 'ascii_bin' NOT NULL,
  `descricao` VARCHAR(500) NULL DEFAULT NULL,
  `ativo` TINYINT UNSIGNED NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_corpo_hidrico`),
  UNIQUE INDEX `uq_corpo_hidrico_1` (`codigo` ASC) VISIBLE,
  INDEX `ix_corpo_hidrico_id_bacia` (`id_bacia` ASC) VISIBLE,
  INDEX `ix_corpo_hidrico_codigo_tipo_corpo` (`codigo_tipo_corpo` ASC) VISIBLE,
  CONSTRAINT `fk_corpo_hidrico_codigo_tipo_corpo`
    FOREIGN KEY (`codigo_tipo_corpo`)
    REFERENCES `recursos_hidricos`.`tipo_corpo_hidrico` (`codigo_tipo_corpo`),
  CONSTRAINT `fk_corpo_hidrico_id_bacia`
    FOREIGN KEY (`id_bacia`)
    REFERENCES `recursos_hidricos`.`bacia_hidrografica` (`id_bacia`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `recursos_hidricos`.`orgao_responsavel`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `recursos_hidricos`.`orgao_responsavel` (
  `id_orgao` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `codigo` VARCHAR(20) CHARACTER SET 'ascii' COLLATE 'ascii_bin' NOT NULL,
  `nome` VARCHAR(120) NOT NULL,
  `descricao` VARCHAR(500) NULL DEFAULT NULL,
  `ativo` TINYINT UNSIGNED NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_orgao`),
  UNIQUE INDEX `uq_orgao_responsavel_1` (`codigo` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `recursos_hidricos`.`estacao_monitoramento`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `recursos_hidricos`.`estacao_monitoramento` (
  `id_estacao` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `codigo` VARCHAR(20) CHARACTER SET 'ascii' COLLATE 'ascii_bin' NOT NULL,
  `nome` VARCHAR(120) NOT NULL,
  `id_corpo_hidrico` INT UNSIGNED NOT NULL,
  `id_orgao` INT UNSIGNED NOT NULL,
  `latitude` DECIMAL(8,6) NOT NULL,
  `longitude` DECIMAL(9,6) NOT NULL,
  `descricao_localizacao` VARCHAR(255) NULL DEFAULT NULL,
  `ativo` TINYINT UNSIGNED NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_estacao`),
  UNIQUE INDEX `uq_estacao_monitoramento_1` (`codigo` ASC) VISIBLE,
  INDEX `ix_estacao_monitoramento_id_corpo_hidrico` (`id_corpo_hidrico` ASC) VISIBLE,
  INDEX `ix_estacao_monitoramento_id_orgao` (`id_orgao` ASC) VISIBLE,
  CONSTRAINT `fk_estacao_monitoramento_id_corpo_hidrico`
    FOREIGN KEY (`id_corpo_hidrico`)
    REFERENCES `recursos_hidricos`.`corpo_hidrico` (`id_corpo_hidrico`),
  CONSTRAINT `fk_estacao_monitoramento_id_orgao`
    FOREIGN KEY (`id_orgao`)
    REFERENCES `recursos_hidricos`.`orgao_responsavel` (`id_orgao`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `recursos_hidricos`.`unidade_medida`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `recursos_hidricos`.`unidade_medida` (
  `id_unidade` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `codigo` VARCHAR(20) CHARACTER SET 'ascii' COLLATE 'ascii_bin' NOT NULL,
  `nome` VARCHAR(80) NOT NULL,
  `simbolo` VARCHAR(16) NOT NULL,
  `descricao` VARCHAR(255) NULL DEFAULT NULL,
  PRIMARY KEY (`id_unidade`),
  UNIQUE INDEX `uq_unidade_medida_1` (`codigo` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `recursos_hidricos`.`parametro_monitoramento`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `recursos_hidricos`.`parametro_monitoramento` (
  `id_parametro` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `codigo` VARCHAR(20) CHARACTER SET 'ascii' COLLATE 'ascii_bin' NOT NULL,
  `nome` VARCHAR(120) NOT NULL,
  `id_unidade` INT UNSIGNED NOT NULL,
  `descricao` VARCHAR(500) NULL DEFAULT NULL,
  `ativo` TINYINT UNSIGNED NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_parametro`),
  UNIQUE INDEX `uq_parametro_monitoramento_1` (`codigo` ASC) VISIBLE,
  INDEX `ix_parametro_monitoramento_id_unidade` (`id_unidade` ASC) VISIBLE,
  CONSTRAINT `fk_parametro_monitoramento_id_unidade`
    FOREIGN KEY (`id_unidade`)
    REFERENCES `recursos_hidricos`.`unidade_medida` (`id_unidade`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `recursos_hidricos`.`regra_monitoramento`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `recursos_hidricos`.`regra_monitoramento` (
  `id_regra` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_estacao` INT UNSIGNED NOT NULL,
  `id_parametro` INT UNSIGNED NOT NULL,
  `ativo` TINYINT UNSIGNED NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_regra`),
  UNIQUE INDEX `uq_regra_monitoramento_1` (`id_estacao` ASC, `id_parametro` ASC) VISIBLE,
  INDEX `ix_regra_monitoramento_id_parametro` (`id_parametro` ASC) VISIBLE,
  CONSTRAINT `fk_regra_monitoramento_id_estacao`
    FOREIGN KEY (`id_estacao`)
    REFERENCES `recursos_hidricos`.`estacao_monitoramento` (`id_estacao`),
  CONSTRAINT `fk_regra_monitoramento_id_parametro`
    FOREIGN KEY (`id_parametro`)
    REFERENCES `recursos_hidricos`.`parametro_monitoramento` (`id_parametro`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `recursos_hidricos`.`versao_regra_monitoramento`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `recursos_hidricos`.`versao_regra_monitoramento` (
  `id_versao` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_regra` INT UNSIGNED NOT NULL,
  `numero_versao` INT UNSIGNED NOT NULL,
  `limite_inferior` DECIMAL(14,6) NULL DEFAULT NULL,
  `limite_superior` DECIMAL(14,6) NULL DEFAULT NULL,
  `prioridade` VARCHAR(7) CHARACTER SET 'ascii' COLLATE 'ascii_bin' NOT NULL,
  `inicio_em` DATETIME(3) NOT NULL,
  `fim_em` DATETIME(3) NULL DEFAULT NULL,
  `id_usuario_configuracao` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`id_versao`),
  UNIQUE INDEX `uq_versao_regra_monitoramento_1` (`id_regra` ASC, `numero_versao` ASC) VISIBLE,
  INDEX `ix_versao_regra_monitoramento_id_usuario_configuracao` (`id_usuario_configuracao` ASC) VISIBLE,
  CONSTRAINT `fk_versao_regra_monitoramento_id_regra`
    FOREIGN KEY (`id_regra`)
    REFERENCES `recursos_hidricos`.`regra_monitoramento` (`id_regra`),
  CONSTRAINT `fk_versao_regra_monitoramento_id_usuario_configuracao`
    FOREIGN KEY (`id_usuario_configuracao`)
    REFERENCES `recursos_hidricos`.`usuario` (`id_usuario`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `recursos_hidricos`.`alerta`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `recursos_hidricos`.`alerta` (
  `id_alerta` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_versao_abertura` INT UNSIGNED NOT NULL,
  `aberto_em` DATETIME(3) NOT NULL,
  `id_usuario_abertura` INT UNSIGNED NOT NULL,
  `reconhecido_em` DATETIME(3) NULL DEFAULT NULL,
  `id_usuario_reconhecimento` INT UNSIGNED NULL DEFAULT NULL,
  `encerrado_em` DATETIME(3) NULL DEFAULT NULL,
  `id_usuario_encerramento` INT UNSIGNED NULL DEFAULT NULL,
  `motivo_encerramento` VARCHAR(500) NULL DEFAULT NULL,
  `id_ocorrencia` BIGINT UNSIGNED NULL DEFAULT NULL,
  PRIMARY KEY (`id_alerta`),
  INDEX `ix_alerta_id_versao_abertura` (`id_versao_abertura` ASC) VISIBLE,
  INDEX `ix_alerta_id_usuario_abertura` (`id_usuario_abertura` ASC) VISIBLE,
  INDEX `ix_alerta_id_usuario_reconhecimento` (`id_usuario_reconhecimento` ASC) VISIBLE,
  INDEX `ix_alerta_id_usuario_encerramento` (`id_usuario_encerramento` ASC) VISIBLE,
  INDEX `ix_alerta_id_ocorrencia` (`id_ocorrencia` ASC) VISIBLE,
  CONSTRAINT `fk_alerta_id_ocorrencia`
    FOREIGN KEY (`id_ocorrencia`)
    REFERENCES `recursos_hidricos`.`ocorrencia` (`id_ocorrencia`),
  CONSTRAINT `fk_alerta_id_usuario_abertura`
    FOREIGN KEY (`id_usuario_abertura`)
    REFERENCES `recursos_hidricos`.`usuario` (`id_usuario`),
  CONSTRAINT `fk_alerta_id_usuario_encerramento`
    FOREIGN KEY (`id_usuario_encerramento`)
    REFERENCES `recursos_hidricos`.`usuario` (`id_usuario`),
  CONSTRAINT `fk_alerta_id_usuario_reconhecimento`
    FOREIGN KEY (`id_usuario_reconhecimento`)
    REFERENCES `recursos_hidricos`.`usuario` (`id_usuario`),
  CONSTRAINT `fk_alerta_id_versao_abertura`
    FOREIGN KEY (`id_versao_abertura`)
    REFERENCES `recursos_hidricos`.`versao_regra_monitoramento` (`id_versao`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `recursos_hidricos`.`tipo_sensor`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `recursos_hidricos`.`tipo_sensor` (
  `id_tipo_sensor` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `codigo` VARCHAR(20) CHARACTER SET 'ascii' COLLATE 'ascii_bin' NOT NULL,
  `nome` VARCHAR(120) NOT NULL,
  `descricao` VARCHAR(500) NULL DEFAULT NULL,
  `ativo` TINYINT UNSIGNED NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_tipo_sensor`),
  UNIQUE INDEX `uq_tipo_sensor_1` (`codigo` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `recursos_hidricos`.`sensor`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `recursos_hidricos`.`sensor` (
  `id_sensor` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `codigo_patrimonial` VARCHAR(20) CHARACTER SET 'ascii' COLLATE 'ascii_bin' NOT NULL,
  `id_tipo_sensor` INT UNSIGNED NOT NULL,
  `numero_serie` VARCHAR(80) NULL DEFAULT NULL,
  `descricao` VARCHAR(500) NULL DEFAULT NULL,
  `ativo` TINYINT UNSIGNED NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_sensor`),
  UNIQUE INDEX `uq_sensor_1` (`codigo_patrimonial` ASC) VISIBLE,
  INDEX `ix_sensor_id_tipo_sensor` (`id_tipo_sensor` ASC) VISIBLE,
  CONSTRAINT `fk_sensor_id_tipo_sensor`
    FOREIGN KEY (`id_tipo_sensor`)
    REFERENCES `recursos_hidricos`.`tipo_sensor` (`id_tipo_sensor`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `recursos_hidricos`.`manutencao`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `recursos_hidricos`.`manutencao` (
  `id_manutencao` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_estacao` INT UNSIGNED NULL DEFAULT NULL,
  `id_sensor` INT UNSIGNED NULL DEFAULT NULL,
  `id_ocorrencia` BIGINT UNSIGNED NULL DEFAULT NULL,
  `tipo_intervencao` VARCHAR(12) CHARACTER SET 'ascii' COLLATE 'ascii_bin' NOT NULL,
  `inicio_em` DATETIME(3) NOT NULL,
  `fim_em` DATETIME(3) NOT NULL,
  `descricao` TEXT NOT NULL,
  `resultado` TEXT NOT NULL,
  `id_usuario_responsavel` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`id_manutencao`),
  INDEX `ix_manutencao_id_estacao` (`id_estacao` ASC) VISIBLE,
  INDEX `ix_manutencao_id_sensor` (`id_sensor` ASC) VISIBLE,
  INDEX `ix_manutencao_id_ocorrencia` (`id_ocorrencia` ASC) VISIBLE,
  INDEX `ix_manutencao_id_usuario_responsavel` (`id_usuario_responsavel` ASC) VISIBLE,
  CONSTRAINT `fk_manutencao_id_estacao`
    FOREIGN KEY (`id_estacao`)
    REFERENCES `recursos_hidricos`.`estacao_monitoramento` (`id_estacao`),
  CONSTRAINT `fk_manutencao_id_ocorrencia`
    FOREIGN KEY (`id_ocorrencia`)
    REFERENCES `recursos_hidricos`.`ocorrencia` (`id_ocorrencia`),
  CONSTRAINT `fk_manutencao_id_sensor`
    FOREIGN KEY (`id_sensor`)
    REFERENCES `recursos_hidricos`.`sensor` (`id_sensor`),
  CONSTRAINT `fk_manutencao_id_usuario_responsavel`
    FOREIGN KEY (`id_usuario_responsavel`)
    REFERENCES `recursos_hidricos`.`usuario` (`id_usuario`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `recursos_hidricos`.`calibracao_parametro`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `recursos_hidricos`.`calibracao_parametro` (
  `id_manutencao` BIGINT UNSIGNED NOT NULL,
  `id_parametro` INT UNSIGNED NOT NULL,
  `valor_referencia` DECIMAL(14,6) NOT NULL,
  `valor_observado` DECIMAL(14,6) NOT NULL,
  `conclusao` VARCHAR(500) NOT NULL,
  `ajuste_realizado` VARCHAR(500) NULL DEFAULT NULL,
  PRIMARY KEY (`id_manutencao`, `id_parametro`),
  INDEX `ix_calibracao_parametro_id_parametro` (`id_parametro` ASC) VISIBLE,
  CONSTRAINT `fk_calibracao_parametro_id_manutencao`
    FOREIGN KEY (`id_manutencao`)
    REFERENCES `recursos_hidricos`.`manutencao` (`id_manutencao`),
  CONSTRAINT `fk_calibracao_parametro_id_parametro`
    FOREIGN KEY (`id_parametro`)
    REFERENCES `recursos_hidricos`.`parametro_monitoramento` (`id_parametro`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `recursos_hidricos`.`evento_auditoria`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `recursos_hidricos`.`evento_auditoria` (
  `id_evento` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_usuario` INT UNSIGNED NOT NULL,
  `ocorrido_em` DATETIME(3) NOT NULL,
  `operacao` VARCHAR(20) CHARACTER SET 'ascii' COLLATE 'ascii_bin' NOT NULL,
  `alvo_relacao` VARCHAR(40) CHARACTER SET 'ascii' COLLATE 'ascii_bin' NOT NULL,
  `chave_alvo_1` VARCHAR(128) NOT NULL,
  `chave_alvo_2` VARCHAR(128) NULL DEFAULT NULL,
  `chave_alvo_3` VARCHAR(128) NULL DEFAULT NULL,
  `descricao` VARCHAR(500) NULL DEFAULT NULL,
  PRIMARY KEY (`id_evento`),
  INDEX `ix_evento_auditoria_id_usuario` (`id_usuario` ASC) VISIBLE,
  CONSTRAINT `fk_evento_auditoria_id_usuario`
    FOREIGN KEY (`id_usuario`)
    REFERENCES `recursos_hidricos`.`usuario` (`id_usuario`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `recursos_hidricos`.`detalhe_auditoria`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `recursos_hidricos`.`detalhe_auditoria` (
  `id_evento` BIGINT UNSIGNED NOT NULL,
  `nome_atributo` VARCHAR(64) CHARACTER SET 'ascii' COLLATE 'ascii_bin' NOT NULL,
  `anterior_presente` TINYINT UNSIGNED NOT NULL,
  `posterior_presente` TINYINT UNSIGNED NOT NULL,
  `valor_anterior` TEXT NULL DEFAULT NULL,
  `valor_posterior` TEXT NULL DEFAULT NULL,
  PRIMARY KEY (`id_evento`, `nome_atributo`),
  CONSTRAINT `fk_detalhe_auditoria_id_evento`
    FOREIGN KEY (`id_evento`)
    REFERENCES `recursos_hidricos`.`evento_auditoria` (`id_evento`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `recursos_hidricos`.`evidencia_alerta`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `recursos_hidricos`.`evidencia_alerta` (
  `id_documento_mongo` CHAR(24) CHARACTER SET 'ascii' COLLATE 'ascii_bin' NOT NULL,
  `id_leitura` VARCHAR(40) CHARACTER SET 'ascii' COLLATE 'ascii_bin' NOT NULL,
  `id_alerta` BIGINT UNSIGNED NOT NULL,
  `id_versao_avaliacao` INT UNSIGNED NOT NULL,
  `origem` TINYINT UNSIGNED NOT NULL DEFAULT '0',
  PRIMARY KEY (`id_documento_mongo`, `id_leitura`),
  INDEX `ix_evidencia_alerta_id_alerta` (`id_alerta` ASC) VISIBLE,
  INDEX `ix_evidencia_alerta_id_versao_avaliacao` (`id_versao_avaliacao` ASC) VISIBLE,
  CONSTRAINT `fk_evidencia_alerta_id_alerta`
    FOREIGN KEY (`id_alerta`)
    REFERENCES `recursos_hidricos`.`alerta` (`id_alerta`),
  CONSTRAINT `fk_evidencia_alerta_id_versao_avaliacao`
    FOREIGN KEY (`id_versao_avaliacao`)
    REFERENCES `recursos_hidricos`.`versao_regra_monitoramento` (`id_versao`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `recursos_hidricos`.`instalacao_sensor`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `recursos_hidricos`.`instalacao_sensor` (
  `id_instalacao` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_sensor` INT UNSIGNED NOT NULL,
  `id_estacao` INT UNSIGNED NOT NULL,
  `inicio_em` DATETIME(3) NOT NULL,
  `fim_em` DATETIME(3) NULL DEFAULT NULL,
  `id_usuario_instalacao` INT UNSIGNED NOT NULL,
  `id_usuario_retirada` INT UNSIGNED NULL DEFAULT NULL,
  `observacao` VARCHAR(500) NULL DEFAULT NULL,
  PRIMARY KEY (`id_instalacao`),
  UNIQUE INDEX `uq_instalacao_sensor_1` (`id_sensor` ASC, `inicio_em` ASC) VISIBLE,
  INDEX `ix_instalacao_sensor_id_estacao` (`id_estacao` ASC) VISIBLE,
  INDEX `ix_instalacao_sensor_id_usuario_instalacao` (`id_usuario_instalacao` ASC) VISIBLE,
  INDEX `ix_instalacao_sensor_id_usuario_retirada` (`id_usuario_retirada` ASC) VISIBLE,
  CONSTRAINT `fk_instalacao_sensor_id_estacao`
    FOREIGN KEY (`id_estacao`)
    REFERENCES `recursos_hidricos`.`estacao_monitoramento` (`id_estacao`),
  CONSTRAINT `fk_instalacao_sensor_id_sensor`
    FOREIGN KEY (`id_sensor`)
    REFERENCES `recursos_hidricos`.`sensor` (`id_sensor`),
  CONSTRAINT `fk_instalacao_sensor_id_usuario_instalacao`
    FOREIGN KEY (`id_usuario_instalacao`)
    REFERENCES `recursos_hidricos`.`usuario` (`id_usuario`),
  CONSTRAINT `fk_instalacao_sensor_id_usuario_retirada`
    FOREIGN KEY (`id_usuario_retirada`)
    REFERENCES `recursos_hidricos`.`usuario` (`id_usuario`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `recursos_hidricos`.`ocorrencia_corpo_hidrico`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `recursos_hidricos`.`ocorrencia_corpo_hidrico` (
  `id_ocorrencia` BIGINT UNSIGNED NOT NULL,
  `id_corpo_hidrico` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`id_ocorrencia`, `id_corpo_hidrico`),
  INDEX `ix_ocorrencia_corpo_hidrico_id_corpo_hidrico` (`id_corpo_hidrico` ASC) VISIBLE,
  CONSTRAINT `fk_ocorrencia_corpo_hidrico_id_corpo_hidrico`
    FOREIGN KEY (`id_corpo_hidrico`)
    REFERENCES `recursos_hidricos`.`corpo_hidrico` (`id_corpo_hidrico`),
  CONSTRAINT `fk_ocorrencia_corpo_hidrico_id_ocorrencia`
    FOREIGN KEY (`id_ocorrencia`)
    REFERENCES `recursos_hidricos`.`ocorrencia` (`id_ocorrencia`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `recursos_hidricos`.`ocorrencia_estacao`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `recursos_hidricos`.`ocorrencia_estacao` (
  `id_ocorrencia` BIGINT UNSIGNED NOT NULL,
  `id_estacao` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`id_ocorrencia`, `id_estacao`),
  INDEX `ix_ocorrencia_estacao_id_estacao` (`id_estacao` ASC) VISIBLE,
  CONSTRAINT `fk_ocorrencia_estacao_id_estacao`
    FOREIGN KEY (`id_estacao`)
    REFERENCES `recursos_hidricos`.`estacao_monitoramento` (`id_estacao`),
  CONSTRAINT `fk_ocorrencia_estacao_id_ocorrencia`
    FOREIGN KEY (`id_ocorrencia`)
    REFERENCES `recursos_hidricos`.`ocorrencia` (`id_ocorrencia`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `recursos_hidricos`.`ocorrencia_sensor`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `recursos_hidricos`.`ocorrencia_sensor` (
  `id_ocorrencia` BIGINT UNSIGNED NOT NULL,
  `id_sensor` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`id_ocorrencia`, `id_sensor`),
  INDEX `ix_ocorrencia_sensor_id_sensor` (`id_sensor` ASC) VISIBLE,
  CONSTRAINT `fk_ocorrencia_sensor_id_ocorrencia`
    FOREIGN KEY (`id_ocorrencia`)
    REFERENCES `recursos_hidricos`.`ocorrencia` (`id_ocorrencia`),
  CONSTRAINT `fk_ocorrencia_sensor_id_sensor`
    FOREIGN KEY (`id_sensor`)
    REFERENCES `recursos_hidricos`.`sensor` (`id_sensor`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `recursos_hidricos`.`perfil`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `recursos_hidricos`.`perfil` (
  `id_perfil` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `codigo` VARCHAR(20) CHARACTER SET 'ascii' COLLATE 'ascii_bin' NOT NULL,
  `nome` VARCHAR(120) NOT NULL,
  `descricao` VARCHAR(500) NULL DEFAULT NULL,
  `ativo` TINYINT UNSIGNED NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_perfil`),
  UNIQUE INDEX `uq_perfil_1` (`codigo` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `recursos_hidricos`.`permissao`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `recursos_hidricos`.`permissao` (
  `id_permissao` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `codigo` VARCHAR(40) CHARACTER SET 'ascii' COLLATE 'ascii_bin' NOT NULL,
  `nome` VARCHAR(120) NOT NULL,
  `descricao` VARCHAR(500) NULL DEFAULT NULL,
  `ativo` TINYINT UNSIGNED NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_permissao`),
  UNIQUE INDEX `uq_permissao_1` (`codigo` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `recursos_hidricos`.`perfil_permissao`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `recursos_hidricos`.`perfil_permissao` (
  `id_perfil` INT UNSIGNED NOT NULL,
  `id_permissao` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`id_perfil`, `id_permissao`),
  INDEX `ix_perfil_permissao_id_permissao` (`id_permissao` ASC) VISIBLE,
  CONSTRAINT `fk_perfil_permissao_id_perfil`
    FOREIGN KEY (`id_perfil`)
    REFERENCES `recursos_hidricos`.`perfil` (`id_perfil`),
  CONSTRAINT `fk_perfil_permissao_id_permissao`
    FOREIGN KEY (`id_permissao`)
    REFERENCES `recursos_hidricos`.`permissao` (`id_permissao`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `recursos_hidricos`.`resumo_diario_monitoramento`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `recursos_hidricos`.`resumo_diario_monitoramento` (
  `id_estacao` INT UNSIGNED NOT NULL,
  `id_parametro` INT UNSIGNED NOT NULL,
  `dia_utc` DATE NOT NULL,
  `quantidade_validas` INT UNSIGNED NOT NULL,
  `soma` DECIMAL(26,6) NULL DEFAULT NULL,
  `minimo` DECIMAL(14,6) NULL DEFAULT NULL,
  `maximo` DECIMAL(14,6) NULL DEFAULT NULL,
  `consolidado_em` DATETIME(3) NOT NULL,
  PRIMARY KEY (`id_estacao`, `id_parametro`, `dia_utc`),
  INDEX `ix_resumo_diario_monitoramento_id_parametro` (`id_parametro` ASC) VISIBLE,
  CONSTRAINT `fk_resumo_diario_monitoramento_id_estacao`
    FOREIGN KEY (`id_estacao`)
    REFERENCES `recursos_hidricos`.`estacao_monitoramento` (`id_estacao`),
  CONSTRAINT `fk_resumo_diario_monitoramento_id_parametro`
    FOREIGN KEY (`id_parametro`)
    REFERENCES `recursos_hidricos`.`parametro_monitoramento` (`id_parametro`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `recursos_hidricos`.`tipo_sensor_parametro`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `recursos_hidricos`.`tipo_sensor_parametro` (
  `id_tipo_sensor` INT UNSIGNED NOT NULL,
  `id_parametro` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`id_tipo_sensor`, `id_parametro`),
  INDEX `ix_tipo_sensor_parametro_id_parametro` (`id_parametro` ASC) VISIBLE,
  CONSTRAINT `fk_tipo_sensor_parametro_id_parametro`
    FOREIGN KEY (`id_parametro`)
    REFERENCES `recursos_hidricos`.`parametro_monitoramento` (`id_parametro`),
  CONSTRAINT `fk_tipo_sensor_parametro_id_tipo_sensor`
    FOREIGN KEY (`id_tipo_sensor`)
    REFERENCES `recursos_hidricos`.`tipo_sensor` (`id_tipo_sensor`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `recursos_hidricos`.`usuario_perfil`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `recursos_hidricos`.`usuario_perfil` (
  `id_usuario` INT UNSIGNED NOT NULL,
  `id_perfil` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`id_usuario`, `id_perfil`),
  INDEX `ix_usuario_perfil_id_perfil` (`id_perfil` ASC) VISIBLE,
  CONSTRAINT `fk_usuario_perfil_id_perfil`
    FOREIGN KEY (`id_perfil`)
    REFERENCES `recursos_hidricos`.`perfil` (`id_perfil`),
  CONSTRAINT `fk_usuario_perfil_id_usuario`
    FOREIGN KEY (`id_usuario`)
    REFERENCES `recursos_hidricos`.`usuario` (`id_usuario`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
