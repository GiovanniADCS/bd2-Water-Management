-- Water Management - Sensores fisicos sinteticos
-- Amostra controlada de 30 equipamentos: tres por tipo de sensor aprovado.
-- Compatibilidade alvo: MySQL 8.0.46.
--
-- Escopo exclusivo: tabela sensor. Nenhuma estacao ou instalacao e atribuida.
-- As FKs sao resolvidas pelo codigo de negocio de tipo_sensor.
-- A transacao permanece aberta para validacao e COMMIT/ROLLBACK manual.

SET NAMES utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE `recursos_hidricos`;

START TRANSACTION;

DROP TEMPORARY TABLE IF EXISTS `_wm_plano_sensores`;
DROP TEMPORARY TABLE IF EXISTS `_wm_guarda_sensores`;

CREATE TEMPORARY TABLE `_wm_plano_sensores` (
    `codigo_patrimonial` VARCHAR(20) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    `tipo_codigo` VARCHAR(20) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    `numero_serie` VARCHAR(80) NOT NULL,
    `descricao` VARCHAR(500) NOT NULL,
    `ativo` TINYINT UNSIGNED NOT NULL,
    PRIMARY KEY (`codigo_patrimonial`),
    UNIQUE KEY `uq_wm_plano_sensores_serie` (`numero_serie`)
) ENGINE = InnoDB;

INSERT INTO `_wm_plano_sensores`
    (`codigo_patrimonial`, `tipo_codigo`, `numero_serie`, `descricao`, `ativo`)
VALUES
    ('PAT-WM-SEN-0001', 'TERMOMETRO_AGUA', 'VS26-TA-00001',
     'Elemento submersível para acompanhamento contínuo da temperatura na coluna d''água.', 1),
    ('PAT-WM-SEN-0002', 'TERMOMETRO_AGUA', 'VS26-TA-00002',
     'Unidade portátil destinada a campanhas de perfil térmico em diferentes profundidades.', 1),
    ('PAT-WM-SEN-0003', 'TERMOMETRO_AGUA', 'VS26-TA-00003',
     'Conjunto encapsulado para registro térmico em ponto fixo de monitoramento.', 1),

    ('PAT-WM-SEN-0004', 'SENSOR_PH', 'VS26-PH-00001',
     'Eletrodo combinado para verificação periódica da condição ácido-base da água.', 1),
    ('PAT-WM-SEN-0005', 'SENSOR_PH', 'VS26-PH-00002',
     'Conjunto de imersão contínua com referência interna para acompanhamento de pH.', 1),
    ('PAT-WM-SEN-0006', 'SENSOR_PH', 'VS26-PH-00003',
     'Sensor portátil com proteção mecânica para levantamentos de pH em campo.', 1),

    ('PAT-WM-SEN-0007', 'TURBIDIMETRO', 'VS26-TU-00001',
     'Módulo nefelométrico de imersão para observação contínua de turbidez.', 1),
    ('PAT-WM-SEN-0008', 'TURBIDIMETRO', 'VS26-TU-00002',
     'Unidade óptica portátil para campanhas de turbidez em pontos de acesso controlado.', 1),
    ('PAT-WM-SEN-0009', 'TURBIDIMETRO', 'VS26-TU-00003',
     'Conjunto óptico protegido contra incidência externa para operação em ponto fixo.', 1),

    ('PAT-WM-SEN-0010', 'SENSOR_OD', 'VS26-OD-00001',
     'Sensor de imersão para acompanhamento contínuo da concentração de oxigênio dissolvido.', 1),
    ('PAT-WM-SEN-0011', 'SENSOR_OD', 'VS26-OD-00002',
     'Unidade portátil com elemento sensível protegido para campanhas de oxigênio dissolvido.', 1),
    ('PAT-WM-SEN-0012', 'SENSOR_OD', 'VS26-OD-00003',
     'Conjunto de leitura de oxigênio dissolvido preparado para operação submersa prolongada.', 1),

    ('PAT-WM-SEN-0013', 'CONDUTIVIMETRO', 'VS26-CE-00001',
     'Célula de condutividade para acompanhamento contínuo da resposta elétrica da água.', 1),
    ('PAT-WM-SEN-0014', 'CONDUTIVIMETRO', 'VS26-CE-00002',
     'Unidade portátil para levantamentos comparativos de condutividade em campo.', 1),
    ('PAT-WM-SEN-0015', 'CONDUTIVIMETRO', 'VS26-CE-00003',
     'Conjunto de imersão com proteção contra resíduos para leitura de condutividade.', 1),

    ('PAT-WM-SEN-0016', 'SENSOR_NIVEL', 'VS26-NA-00001',
     'Sensor hidrométrico submersível para acompanhamento da altura da lâmina d''água.', 1),
    ('PAT-WM-SEN-0017', 'SENSOR_NIVEL', 'VS26-NA-00002',
     'Unidade de nível sem contato destinada a seções com referência vertical definida.', 1),
    ('PAT-WM-SEN-0018', 'SENSOR_NIVEL', 'VS26-NA-00003',
     'Conjunto de nível para poço tranquilizador com referência local de medição.', 1),

    ('PAT-WM-SEN-0019', 'MEDIDOR_VAZAO', 'VS26-VZ-00001',
     'Medidor de vazão para seção hidráulica previamente caracterizada, sem saída de velocidade.', 1),
    ('PAT-WM-SEN-0020', 'MEDIDOR_VAZAO', 'VS26-VZ-00002',
     'Conjunto de medição volumétrica destinado ao acompanhamento de vazão em canal definido.', 1),
    ('PAT-WM-SEN-0021', 'MEDIDOR_VAZAO', 'VS26-VZ-00003',
     'Unidade integradora para obtenção direta de vazão em estrutura hidráulica controlada.', 1),

    ('PAT-WM-SEN-0022', 'VELOCIMETRO_AGUA', 'VS26-VA-00001',
     'Velocímetro acústico para observação da velocidade da água em seção monitorada.', 1),
    ('PAT-WM-SEN-0023', 'VELOCIMETRO_AGUA', 'VS26-VA-00002',
     'Unidade eletromagnética portátil para campanhas de velocidade em cursos d''água.', 1),
    ('PAT-WM-SEN-0024', 'VELOCIMETRO_AGUA', 'VS26-VA-00003',
     'Conjunto submersível para acompanhamento direcional da velocidade da água.', 1),

    ('PAT-WM-SEN-0025', 'PLUVIOMETRO', 'VS26-PL-00001',
     'Pluviômetro de báscula para totalização de precipitação em intervalos definidos.', 1),
    ('PAT-WM-SEN-0026', 'PLUVIOMETRO', 'VS26-PL-00002',
     'Coletor pluviométrico automático com proteção contra entrada de detritos.', 1),
    ('PAT-WM-SEN-0027', 'PLUVIOMETRO', 'VS26-PL-00003',
     'Unidade de precipitação acumulada preparada para exposição ambiental contínua.', 1),

    ('PAT-WM-SEN-0028', 'SONDA_MULTIPARAM', 'VS26-SM-00001',
     'Sonda integrada para temperatura, pH, turbidez, oxigênio dissolvido e condutividade.', 1),
    ('PAT-WM-SEN-0029', 'SONDA_MULTIPARAM', 'VS26-SM-00002',
     'Conjunto multiparâmetro submersível para campanhas de qualidade da água.', 1),
    ('PAT-WM-SEN-0030', 'SONDA_MULTIPARAM', 'VS26-SM-00003',
     'Sonda multiparâmetro preparada para permanência em ponto fixo com proteção dos elementos sensíveis.', 1);

-- Cada consulta referencia a tabela temporaria apenas uma vez, evitando o erro
-- 1137 (Can't reopen table) observado em guardioes anteriores.
SET @wm_sensores_total_plano := (
    SELECT COUNT(*) FROM `_wm_plano_sensores`
);

SET @wm_sensores_tipos_plano := (
    SELECT COUNT(DISTINCT `tipo_codigo`) FROM `_wm_plano_sensores`
);

SET @wm_sensores_tipos_ausentes := (
    SELECT COUNT(DISTINCT p.`tipo_codigo`)
    FROM `_wm_plano_sensores` p
    LEFT JOIN `tipo_sensor` t ON t.`codigo` = p.`tipo_codigo` AND t.`ativo` = 1
    WHERE t.`id_tipo_sensor` IS NULL
);

SET @wm_sensores_conflitos_codigo := (
    SELECT COUNT(*)
    FROM `_wm_plano_sensores` p
    JOIN `sensor` s ON s.`codigo_patrimonial` = p.`codigo_patrimonial`
    JOIN `tipo_sensor` t ON t.`id_tipo_sensor` = s.`id_tipo_sensor`
    WHERE t.`codigo` <> p.`tipo_codigo`
       OR NOT (s.`numero_serie` <=> p.`numero_serie`)
       OR NOT (s.`descricao` <=> p.`descricao`)
       OR s.`ativo` <> p.`ativo`
);

SET @wm_sensores_conflitos_serie := (
    SELECT COUNT(*)
    FROM `_wm_plano_sensores` p
    JOIN `sensor` s ON s.`numero_serie` = p.`numero_serie`
    WHERE s.`codigo_patrimonial` <> p.`codigo_patrimonial`
);

CREATE TEMPORARY TABLE `_wm_guarda_sensores` (
    `ok` TINYINT NOT NULL CHECK (`ok` = 1)
) ENGINE = InnoDB;

INSERT INTO `_wm_guarda_sensores` (`ok`)
SELECT CASE
    WHEN @wm_sensores_total_plano = 30
     AND @wm_sensores_tipos_plano = 10
     AND @wm_sensores_tipos_ausentes = 0
     AND @wm_sensores_conflitos_codigo = 0
     AND @wm_sensores_conflitos_serie = 0
    THEN 1
    ELSE 0
END;

INSERT INTO `sensor`
    (`codigo_patrimonial`, `id_tipo_sensor`, `numero_serie`, `descricao`, `ativo`)
SELECT
    p.`codigo_patrimonial`,
    t.`id_tipo_sensor`,
    p.`numero_serie`,
    p.`descricao`,
    p.`ativo`
FROM `_wm_plano_sensores` p
JOIN `_wm_guarda_sensores` g ON g.`ok` = 1
JOIN `tipo_sensor` t ON t.`codigo` = p.`tipo_codigo` AND t.`ativo` = 1
WHERE NOT EXISTS (
    SELECT 1
    FROM `sensor` s
    WHERE s.`codigo_patrimonial` = p.`codigo_patrimonial`
);

DROP TEMPORARY TABLE `_wm_guarda_sensores`;
DROP TEMPORARY TABLE `_wm_plano_sensores`;

SET @wm_sensores_total_plano := NULL;
SET @wm_sensores_tipos_plano := NULL;
SET @wm_sensores_tipos_ausentes := NULL;
SET @wm_sensores_conflitos_codigo := NULL;
SET @wm_sensores_conflitos_serie := NULL;

-- IMPORTANTE: a transacao continua aberta nesta conexao.
-- Execute 007_verify_sensores.sql e finalize manualmente com COMMIT ou ROLLBACK.
SELECT
    COUNT(*) AS `sensores_na_transacao`,
    'TRANSAÇÃO ABERTA - valide e execute COMMIT ou ROLLBACK manual' AS `proxima_acao`
FROM `sensor`
WHERE `codigo_patrimonial` BETWEEN 'PAT-WM-SEN-0001' AND 'PAT-WM-SEN-0030';
