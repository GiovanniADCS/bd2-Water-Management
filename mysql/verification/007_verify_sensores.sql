-- Water Management - Verificacao dos sensores fisicos sinteticos
-- Validacao somente leitura da carga preparada em 005_seed_sensores.sql.
-- Todas as consultas identificadas como ANOMALIA devem retornar zero linhas.

SET NAMES utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE `recursos_hidricos`;

-- 1. Catalogo necessario. Esperado: os dez tipos ativos, tres sensores cada.
SELECT
    t.`codigo` AS `tipo_codigo`,
    t.`nome` AS `tipo_nome`,
    t.`ativo`,
    3 AS `sensores_esperados`
FROM `tipo_sensor` t
WHERE t.`codigo` IN (
    'TERMOMETRO_AGUA', 'SENSOR_PH', 'TURBIDIMETRO', 'SENSOR_OD',
    'CONDUTIVIMETRO', 'SENSOR_NIVEL', 'MEDIDOR_VAZAO',
    'VELOCIMETRO_AGUA', 'PLUVIOMETRO', 'SONDA_MULTIPARAM'
)
ORDER BY t.`codigo`;

-- 2. Resumo. Esperado: 30 encontrados, 30 ativos, 10 tipos e 30 series.
WITH RECURSIVE `numeros` (`n`) AS (
    SELECT 1
    UNION ALL
    SELECT `n` + 1 FROM `numeros` WHERE `n` < 30
),
`codigos_previstos` AS (
    SELECT CONCAT('PAT-WM-SEN-', LPAD(`n`, 4, '0')) AS `codigo_patrimonial`
    FROM `numeros`
)
SELECT
    COUNT(s.`id_sensor`) AS `sensores_previstos_encontrados`,
    COALESCE(SUM(s.`ativo` = 1), 0) AS `sensores_previstos_ativos`,
    COUNT(DISTINCT s.`id_tipo_sensor`) AS `tipos_utilizados`,
    COUNT(DISTINCT s.`numero_serie`) AS `series_distintas`,
    30 AS `total_previsto`
FROM `codigos_previstos` p
LEFT JOIN `sensor` s ON s.`codigo_patrimonial` = p.`codigo_patrimonial`;

-- 3. ANOMALIA: codigos PAT-WM-SEN-0001 a PAT-WM-SEN-0030 ausentes.
WITH RECURSIVE `numeros` (`n`) AS (
    SELECT 1
    UNION ALL
    SELECT `n` + 1 FROM `numeros` WHERE `n` < 30
)
SELECT CONCAT('PAT-WM-SEN-', LPAD(n.`n`, 4, '0')) AS `codigo_ausente`
FROM `numeros` n
LEFT JOIN `sensor` s
  ON s.`codigo_patrimonial` = CONCAT('PAT-WM-SEN-', LPAD(n.`n`, 4, '0'))
WHERE s.`id_sensor` IS NULL
ORDER BY n.`n`;

-- 4. ANOMALIA: sensores adicionais fora da amostra aprovada.
WITH RECURSIVE `numeros` (`n`) AS (
    SELECT 1
    UNION ALL
    SELECT `n` + 1 FROM `numeros` WHERE `n` < 30
),
`codigos_previstos` AS (
    SELECT CONCAT('PAT-WM-SEN-', LPAD(`n`, 4, '0')) AS `codigo_patrimonial`
    FROM `numeros`
)
SELECT s.`codigo_patrimonial`, s.`numero_serie`
FROM `sensor` s
LEFT JOIN `codigos_previstos` p ON p.`codigo_patrimonial` = s.`codigo_patrimonial`
WHERE p.`codigo_patrimonial` IS NULL
ORDER BY s.`codigo_patrimonial`;

-- 5. ANOMALIA: quantidade diferente de tres por tipo aprovado.
WITH RECURSIVE `numeros` (`n`) AS (
    SELECT 1
    UNION ALL
    SELECT `n` + 1 FROM `numeros` WHERE `n` < 30
),
`codigos_previstos` AS (
    SELECT CONCAT('PAT-WM-SEN-', LPAD(`n`, 4, '0')) AS `codigo_patrimonial`
    FROM `numeros`
),
`tipos_previstos` AS (
    SELECT 'TERMOMETRO_AGUA' AS `codigo`
    UNION ALL SELECT 'SENSOR_PH'
    UNION ALL SELECT 'TURBIDIMETRO'
    UNION ALL SELECT 'SENSOR_OD'
    UNION ALL SELECT 'CONDUTIVIMETRO'
    UNION ALL SELECT 'SENSOR_NIVEL'
    UNION ALL SELECT 'MEDIDOR_VAZAO'
    UNION ALL SELECT 'VELOCIMETRO_AGUA'
    UNION ALL SELECT 'PLUVIOMETRO'
    UNION ALL SELECT 'SONDA_MULTIPARAM'
)
SELECT tp.`codigo` AS `tipo_codigo`, COUNT(s.`id_sensor`) AS `quantidade`
FROM `tipos_previstos` tp
LEFT JOIN `tipo_sensor` t ON t.`codigo` = tp.`codigo`
LEFT JOIN `sensor` s ON s.`id_tipo_sensor` = t.`id_tipo_sensor`
LEFT JOIN `codigos_previstos` p ON p.`codigo_patrimonial` = s.`codigo_patrimonial`
GROUP BY tp.`codigo`
HAVING COUNT(p.`codigo_patrimonial`) <> 3
ORDER BY tp.`codigo`;

-- 6. ANOMALIA: series, descricoes ou FKs invalidas na amostra.
WITH RECURSIVE `numeros` (`n`) AS (
    SELECT 1
    UNION ALL
    SELECT `n` + 1 FROM `numeros` WHERE `n` < 30
),
`esperado` AS (
    SELECT
        `n`,
        CONCAT('PAT-WM-SEN-', LPAD(`n`, 4, '0')) AS `codigo_patrimonial`,
        CASE
            WHEN `n` BETWEEN 1 AND 3 THEN 'TERMOMETRO_AGUA'
            WHEN `n` BETWEEN 4 AND 6 THEN 'SENSOR_PH'
            WHEN `n` BETWEEN 7 AND 9 THEN 'TURBIDIMETRO'
            WHEN `n` BETWEEN 10 AND 12 THEN 'SENSOR_OD'
            WHEN `n` BETWEEN 13 AND 15 THEN 'CONDUTIVIMETRO'
            WHEN `n` BETWEEN 16 AND 18 THEN 'SENSOR_NIVEL'
            WHEN `n` BETWEEN 19 AND 21 THEN 'MEDIDOR_VAZAO'
            WHEN `n` BETWEEN 22 AND 24 THEN 'VELOCIMETRO_AGUA'
            WHEN `n` BETWEEN 25 AND 27 THEN 'PLUVIOMETRO'
            WHEN `n` BETWEEN 28 AND 30 THEN 'SONDA_MULTIPARAM'
        END AS `tipo_codigo`,
        CONCAT(
            'VS26-',
            CASE
                WHEN `n` BETWEEN 1 AND 3 THEN 'TA'
                WHEN `n` BETWEEN 4 AND 6 THEN 'PH'
                WHEN `n` BETWEEN 7 AND 9 THEN 'TU'
                WHEN `n` BETWEEN 10 AND 12 THEN 'OD'
                WHEN `n` BETWEEN 13 AND 15 THEN 'CE'
                WHEN `n` BETWEEN 16 AND 18 THEN 'NA'
                WHEN `n` BETWEEN 19 AND 21 THEN 'VZ'
                WHEN `n` BETWEEN 22 AND 24 THEN 'VA'
                WHEN `n` BETWEEN 25 AND 27 THEN 'PL'
                WHEN `n` BETWEEN 28 AND 30 THEN 'SM'
            END,
            '-', LPAD(MOD(`n` - 1, 3) + 1, 5, '0')
        ) AS `numero_serie`
    FROM `numeros`
)
SELECT
    e.`codigo_patrimonial`,
    e.`tipo_codigo` AS `tipo_esperado`,
    t.`codigo` AS `tipo_atual`,
    e.`numero_serie` AS `serie_esperada`,
    s.`numero_serie` AS `serie_atual`,
    CASE
        WHEN s.`id_sensor` IS NULL THEN 'sensor ausente'
        WHEN t.`id_tipo_sensor` IS NULL THEN 'tipo inexistente'
        WHEN t.`codigo` <> e.`tipo_codigo` THEN 'tipo divergente'
        WHEN t.`ativo` <> 1 THEN 'tipo inativo'
        WHEN s.`numero_serie` <> e.`numero_serie` THEN 'serie divergente'
        WHEN s.`descricao` IS NULL OR TRIM(s.`descricao`) = '' THEN 'descricao ausente'
        WHEN s.`ativo` <> 1 THEN 'sensor inativo'
        ELSE 'inconsistencia nao classificada'
    END AS `anomalia`
FROM `esperado` e
LEFT JOIN `sensor` s ON s.`codigo_patrimonial` = e.`codigo_patrimonial`
LEFT JOIN `tipo_sensor` t ON t.`id_tipo_sensor` = s.`id_tipo_sensor`
WHERE s.`id_sensor` IS NULL
   OR t.`id_tipo_sensor` IS NULL
   OR t.`codigo` <> e.`tipo_codigo`
   OR t.`ativo` <> 1
   OR s.`numero_serie` <> e.`numero_serie`
   OR s.`numero_serie` IS NULL
   OR s.`descricao` IS NULL
   OR TRIM(s.`descricao`) = ''
   OR s.`ativo` <> 1
ORDER BY e.`n`;

-- 7. ANOMALIA: duplicidade de numero de serie ou descricao repetida na amostra.
WITH RECURSIVE `numeros` (`n`) AS (
    SELECT 1
    UNION ALL
    SELECT `n` + 1 FROM `numeros` WHERE `n` < 30
),
`codigos_previstos` AS (
    SELECT CONCAT('PAT-WM-SEN-', LPAD(`n`, 4, '0')) AS `codigo_patrimonial`
    FROM `numeros`
),
`duplicidades` AS (
    SELECT 'numero_serie' AS `campo`, s.`numero_serie` AS `valor`, COUNT(*) AS `ocorrencias`
    FROM `sensor` s
    JOIN `codigos_previstos` p ON p.`codigo_patrimonial` = s.`codigo_patrimonial`
    GROUP BY s.`numero_serie`
    HAVING s.`numero_serie` IS NULL OR COUNT(*) > 1

    UNION ALL

    SELECT 'descricao', s.`descricao`, COUNT(*)
    FROM `sensor` s
    JOIN `codigos_previstos` p ON p.`codigo_patrimonial` = s.`codigo_patrimonial`
    GROUP BY s.`descricao`
    HAVING COUNT(*) > 1
)
SELECT `campo`, `valor`, `ocorrencias`
FROM `duplicidades`
ORDER BY `campo`, `valor`;

-- 8. ANOMALIA: a amostra ainda nao pode possuir instalacoes.
WITH RECURSIVE `numeros` (`n`) AS (
    SELECT 1
    UNION ALL
    SELECT `n` + 1 FROM `numeros` WHERE `n` < 30
),
`codigos_previstos` AS (
    SELECT CONCAT('PAT-WM-SEN-', LPAD(`n`, 4, '0')) AS `codigo_patrimonial`
    FROM `numeros`
)
SELECT s.`codigo_patrimonial`, i.`id_instalacao`, i.`id_estacao`
FROM `codigos_previstos` p
JOIN `sensor` s ON s.`codigo_patrimonial` = p.`codigo_patrimonial`
JOIN `instalacao_sensor` i ON i.`id_sensor` = s.`id_sensor`
ORDER BY s.`codigo_patrimonial`, i.`inicio_em`;

-- 9. Distribuicao informativa. Esperado: dez linhas com quantidade tres.
WITH RECURSIVE `numeros` (`n`) AS (
    SELECT 1
    UNION ALL
    SELECT `n` + 1 FROM `numeros` WHERE `n` < 30
),
`codigos_previstos` AS (
    SELECT CONCAT('PAT-WM-SEN-', LPAD(`n`, 4, '0')) AS `codigo_patrimonial`
    FROM `numeros`
)
SELECT t.`codigo` AS `tipo_codigo`, t.`nome` AS `tipo_nome`, COUNT(*) AS `sensores`
FROM `codigos_previstos` p
JOIN `sensor` s ON s.`codigo_patrimonial` = p.`codigo_patrimonial`
JOIN `tipo_sensor` t ON t.`id_tipo_sensor` = s.`id_tipo_sensor`
GROUP BY t.`id_tipo_sensor`, t.`codigo`, t.`nome`
ORDER BY t.`codigo`;

-- 10. Previa completa. Esperado: 30 linhas e nenhuma estacao associada.
WITH RECURSIVE `numeros` (`n`) AS (
    SELECT 1
    UNION ALL
    SELECT `n` + 1 FROM `numeros` WHERE `n` < 30
),
`codigos_previstos` AS (
    SELECT CONCAT('PAT-WM-SEN-', LPAD(`n`, 4, '0')) AS `codigo_patrimonial`
    FROM `numeros`
)
SELECT
    s.`codigo_patrimonial`,
    s.`numero_serie`,
    t.`codigo` AS `tipo_codigo`,
    t.`nome` AS `tipo_nome`,
    s.`descricao`,
    s.`ativo`
FROM `codigos_previstos` p
JOIN `sensor` s ON s.`codigo_patrimonial` = p.`codigo_patrimonial`
JOIN `tipo_sensor` t ON t.`id_tipo_sensor` = s.`id_tipo_sensor`
ORDER BY s.`codigo_patrimonial`;
