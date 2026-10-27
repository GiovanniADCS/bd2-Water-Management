-- Water Management - Verificacao das estacoes de monitoramento
-- Validacao somente leitura da carga preparada em 004_seed_estacoes.sql.
-- Compatibilidade alvo: MySQL 8.0.46.
-- Todas as consultas identificadas como anomalia devem retornar zero linhas.

SET NAMES utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE `recursos_hidricos`;

-- 1. Premissas da carga. Esperado: 6 bacias, 24 corpos, ao menos 1 orgao
-- e somente RIO/RESERVATORIO entre os corpos ativos.
SELECT 'bacias_ativas' AS `verificacao`, COUNT(*) AS `valor`, '6' AS `esperado`
FROM `bacia_hidrografica`
WHERE `ativo` = 1
UNION ALL
SELECT 'corpos_ativos', COUNT(*), '24'
FROM `corpo_hidrico`
WHERE `ativo` = 1
UNION ALL
SELECT 'orgaos_ativos', COUNT(*), '>= 1'
FROM `orgao_responsavel`
WHERE `ativo` = 1
UNION ALL
SELECT 'corpos_ativos_com_tipo_invalido', COUNT(*), '0'
FROM `corpo_hidrico`
WHERE `ativo` = 1
  AND `codigo_tipo_corpo` NOT IN ('RIO', 'RESERVATORIO')
UNION ALL
SELECT 'corpos_ativos_em_bacia_inativa', COUNT(*), '0'
FROM `corpo_hidrico` c
JOIN `bacia_hidrografica` b ON b.`id_bacia` = c.`id_bacia`
WHERE c.`ativo` = 1
  AND b.`ativo` <> 1;

-- 2. Resumo da carga. Esperado: 72 codigos, 72 ativos, 24 corpos cobertos.
WITH RECURSIVE `numeros` (`n`) AS (
    SELECT 1
    UNION ALL
    SELECT `n` + 1 FROM `numeros` WHERE `n` < 72
),
`codigos_previstos` AS (
    SELECT CONCAT('EST', LPAD(`n`, 3, '0')) AS `codigo`
    FROM `numeros`
)
SELECT
    COUNT(e.`id_estacao`) AS `estacoes_previstas_encontradas`,
    COALESCE(SUM(e.`ativo` = 1), 0) AS `estacoes_previstas_ativas`,
    COUNT(DISTINCT e.`id_corpo_hidrico`) AS `corpos_cobertos`,
    COUNT(DISTINCT e.`id_orgao`) AS `orgaos_utilizados`,
    72 AS `total_previsto`
FROM `codigos_previstos` p
LEFT JOIN `estacao_monitoramento` e ON e.`codigo` = p.`codigo`;

-- 3. ANOMALIA: codigos EST001 a EST072 ausentes. Deve retornar zero linhas.
WITH RECURSIVE `numeros` (`n`) AS (
    SELECT 1
    UNION ALL
    SELECT `n` + 1 FROM `numeros` WHERE `n` < 72
)
SELECT CONCAT('EST', LPAD(n.`n`, 3, '0')) AS `codigo_ausente`
FROM `numeros` n
LEFT JOIN `estacao_monitoramento` e
  ON e.`codigo` = CONCAT('EST', LPAD(n.`n`, 3, '0'))
WHERE e.`id_estacao` IS NULL
ORDER BY n.`n`;

-- 4. ANOMALIA: registros adicionais fora do conjunto aprovado.
-- Deve retornar zero linhas quando a tabela contiver exclusivamente esta carga.
WITH RECURSIVE `numeros` (`n`) AS (
    SELECT 1
    UNION ALL
    SELECT `n` + 1 FROM `numeros` WHERE `n` < 72
),
`codigos_previstos` AS (
    SELECT CONCAT('EST', LPAD(`n`, 3, '0')) AS `codigo`
    FROM `numeros`
)
SELECT e.`codigo`, e.`nome`
FROM `estacao_monitoramento` e
LEFT JOIN `codigos_previstos` p ON p.`codigo` = e.`codigo`
WHERE p.`codigo` IS NULL
ORDER BY e.`codigo`;

-- 5. ANOMALIA: cada corpo ativo deve possuir exatamente tres estacoes da carga.
-- Deve retornar zero linhas.
WITH RECURSIVE `numeros` (`n`) AS (
    SELECT 1
    UNION ALL
    SELECT `n` + 1 FROM `numeros` WHERE `n` < 72
),
`codigos_previstos` AS (
    SELECT CONCAT('EST', LPAD(`n`, 3, '0')) AS `codigo`
    FROM `numeros`
)
SELECT
    b.`codigo` AS `bacia_codigo`,
    c.`codigo` AS `corpo_codigo`,
    c.`nome` AS `corpo_nome`,
    COUNT(p.`codigo`) AS `quantidade_estacoes`
FROM `corpo_hidrico` c
JOIN `bacia_hidrografica` b ON b.`id_bacia` = c.`id_bacia`
LEFT JOIN `estacao_monitoramento` e ON e.`id_corpo_hidrico` = c.`id_corpo_hidrico`
LEFT JOIN `codigos_previstos` p ON p.`codigo` = e.`codigo`
WHERE c.`ativo` = 1
GROUP BY b.`codigo`, c.`id_corpo_hidrico`, c.`codigo`, c.`nome`
HAVING COUNT(p.`codigo`) <> 3
ORDER BY b.`codigo`, c.`codigo`;

-- 6. ANOMALIA: duplicidade de nomes ou coordenadas entre os 72 registros.
-- A coluna codigo ja possui restricao UNIQUE na modelagem.
WITH RECURSIVE `numeros` (`n`) AS (
    SELECT 1
    UNION ALL
    SELECT `n` + 1 FROM `numeros` WHERE `n` < 72
),
`codigos_previstos` AS (
    SELECT CONCAT('EST', LPAD(`n`, 3, '0')) AS `codigo`
    FROM `numeros`
),
`duplicidades` AS (
    SELECT 'nome' AS `campo`, e.`nome` AS `valor`, COUNT(*) AS `ocorrencias`
    FROM `estacao_monitoramento` e
    JOIN `codigos_previstos` p ON p.`codigo` = e.`codigo`
    GROUP BY e.`nome`
    HAVING COUNT(*) > 1

    UNION ALL

    SELECT
        'coordenadas',
        CONCAT(CAST(e.`latitude` AS CHAR), ',', CAST(e.`longitude` AS CHAR)),
        COUNT(*)
    FROM `estacao_monitoramento` e
    JOIN `codigos_previstos` p ON p.`codigo` = e.`codigo`
    GROUP BY e.`latitude`, e.`longitude`
    HAVING COUNT(*) > 1
)
SELECT `campo`, `valor`, `ocorrencias`
FROM `duplicidades`
ORDER BY `campo`, `valor`;

-- 7. ANOMALIA: FKs, estado, descricao ou coordenadas invalidas.
-- Deve retornar zero linhas.
WITH RECURSIVE `numeros` (`n`) AS (
    SELECT 1
    UNION ALL
    SELECT `n` + 1 FROM `numeros` WHERE `n` < 72
),
`codigos_previstos` AS (
    SELECT CONCAT('EST', LPAD(`n`, 3, '0')) AS `codigo`
    FROM `numeros`
)
SELECT
    e.`codigo`,
    e.`nome`,
    e.`latitude`,
    e.`longitude`,
    c.`codigo` AS `corpo_codigo`,
    o.`codigo` AS `orgao_codigo`,
    CASE
        WHEN c.`id_corpo_hidrico` IS NULL THEN 'corpo inexistente'
        WHEN o.`id_orgao` IS NULL THEN 'orgao inexistente'
        WHEN c.`ativo` <> 1 THEN 'corpo inativo'
        WHEN o.`ativo` <> 1 THEN 'orgao inativo'
        WHEN e.`ativo` <> 1 THEN 'estacao inativa'
        WHEN e.`latitude` NOT BETWEEN -23.850000 AND -22.550000 THEN 'latitude fora da regiao'
        WHEN e.`longitude` NOT BETWEEN -47.400000 AND -45.750000 THEN 'longitude fora da regiao'
        WHEN e.`descricao_localizacao` IS NULL OR TRIM(e.`descricao_localizacao`) = '' THEN 'descricao ausente'
        ELSE 'inconsistencia nao classificada'
    END AS `anomalia`
FROM `estacao_monitoramento` e
JOIN `codigos_previstos` p ON p.`codigo` = e.`codigo`
LEFT JOIN `corpo_hidrico` c ON c.`id_corpo_hidrico` = e.`id_corpo_hidrico`
LEFT JOIN `orgao_responsavel` o ON o.`id_orgao` = e.`id_orgao`
WHERE c.`id_corpo_hidrico` IS NULL
   OR o.`id_orgao` IS NULL
   OR c.`ativo` <> 1
   OR o.`ativo` <> 1
   OR e.`ativo` <> 1
   OR e.`latitude` NOT BETWEEN -23.850000 AND -22.550000
   OR e.`longitude` NOT BETWEEN -47.400000 AND -45.750000
   OR e.`descricao_localizacao` IS NULL
   OR TRIM(e.`descricao_localizacao`) = ''
ORDER BY e.`codigo`;

-- 8. ANOMALIA: divergencia em relacao ao plano deterministico da carga.
-- Confere corpo, orgao, nome, coordenadas, descricao e estado. Zero linhas.
WITH
`bacias_ordenadas` AS (
    SELECT
        b.`id_bacia`,
        b.`codigo`,
        ROW_NUMBER() OVER (ORDER BY b.`codigo`) AS `ordem_bacia`
    FROM `bacia_hidrografica` b
    WHERE b.`ativo` = 1
),
`corpos_ordenados` AS (
    SELECT
        c.`codigo` AS `corpo_codigo`,
        c.`nome` AS `corpo_nome`,
        c.`codigo_tipo_corpo`,
        b.`codigo` AS `bacia_codigo`,
        b.`ordem_bacia`,
        ROW_NUMBER() OVER (PARTITION BY c.`id_bacia` ORDER BY c.`codigo`) AS `ordem_corpo_bacia`,
        COUNT(*) OVER (PARTITION BY c.`id_bacia`) AS `total_corpos_bacia`,
        ROW_NUMBER() OVER (ORDER BY b.`codigo`, c.`codigo`) AS `ordem_corpo_global`
    FROM `corpo_hidrico` c
    JOIN `bacias_ordenadas` b ON b.`id_bacia` = c.`id_bacia`
    WHERE c.`ativo` = 1
),
`orgaos_ordenados` AS (
    SELECT
        o.`codigo` AS `orgao_codigo`,
        ROW_NUMBER() OVER (ORDER BY o.`codigo`) AS `ordem_orgao`
    FROM `orgao_responsavel` o
    WHERE o.`ativo` = 1
),
`posicoes` AS (
    SELECT 1 AS `posicao`, 0.012000 AS `delta_lat`, -0.010000 AS `delta_lon`
    UNION ALL SELECT 2, 0.000000, 0.000000
    UNION ALL SELECT 3, -0.012000, 0.010000
),
`plano_base` AS (
    SELECT
        CONCAT('EST', LPAD(((c.`ordem_corpo_global` - 1) * 3) + p.`posicao`, 3, '0')) AS `codigo`,
        c.`corpo_codigo`,
        c.`corpo_nome`,
        c.`codigo_tipo_corpo`,
        c.`bacia_codigo`,
        o.`orgao_codigo`,
        p.`posicao`,
        CASE
            WHEN c.`codigo_tipo_corpo` = 'RIO' AND p.`posicao` = 1 THEN 'Montante'
            WHEN c.`codigo_tipo_corpo` = 'RIO' AND p.`posicao` = 2 THEN 'Trecho médio'
            WHEN c.`codigo_tipo_corpo` = 'RIO' AND p.`posicao` = 3 THEN 'Jusante'
            WHEN c.`codigo_tipo_corpo` = 'RESERVATORIO' AND p.`posicao` = 1 THEN 'Braço de entrada'
            WHEN c.`codigo_tipo_corpo` = 'RESERVATORIO' AND p.`posicao` = 2 THEN 'Corpo central'
            WHEN c.`codigo_tipo_corpo` = 'RESERVATORIO' AND p.`posicao` = 3 THEN 'Saída do vertedouro'
            ELSE CONCAT('Ponto ', p.`posicao`)
        END AS `posicao_nome`,
        CAST(
            -22.650000
            - (FLOOR((c.`ordem_bacia` - 1) / 3) * 0.750000)
            - (
                ((c.`ordem_corpo_bacia` - 1) / GREATEST(c.`total_corpos_bacia` - 1, 1))
                * 0.350000
            )
            + p.`delta_lat`
            AS DECIMAL(8,6)
        ) AS `latitude`,
        CAST(
            -47.300000
            + (MOD(c.`ordem_bacia` - 1, 3) * 0.650000)
            + (
                ((c.`ordem_corpo_bacia` - 1) / GREATEST(c.`total_corpos_bacia` - 1, 1))
                * 0.180000
            )
            + p.`delta_lon`
            AS DECIMAL(9,6)
        ) AS `longitude`
    FROM `corpos_ordenados` c
    CROSS JOIN `posicoes` p
    JOIN `orgaos_ordenados` o
      ON o.`ordem_orgao` = MOD(
          c.`ordem_bacia` - 1,
          (SELECT COUNT(*) FROM `orgaos_ordenados`)
      ) + 1
),
`plano` AS (
    SELECT
        pb.`codigo`,
        LEFT(CONCAT('Estação ', pb.`codigo`, ' — ', pb.`corpo_nome`, ' — ', pb.`posicao_nome`), 120) AS `nome`,
        pb.`corpo_codigo`,
        pb.`orgao_codigo`,
        pb.`latitude`,
        pb.`longitude`,
        LEFT(
            CONCAT(
                'Região fictícia do Vale Sereno; ', pb.`posicao_nome`, ' de ',
                pb.`corpo_nome`, ', bacia ', pb.`bacia_codigo`,
                '; coordenadas sintéticas.'
            ),
            255
        ) AS `descricao_localizacao`,
        1 AS `ativo`
    FROM `plano_base` pb
)
SELECT
    p.`codigo`,
    p.`corpo_codigo` AS `corpo_esperado`,
    c.`codigo` AS `corpo_atual`,
    p.`orgao_codigo` AS `orgao_esperado`,
    o.`codigo` AS `orgao_atual`,
    p.`latitude` AS `latitude_esperada`,
    e.`latitude` AS `latitude_atual`,
    p.`longitude` AS `longitude_esperada`,
    e.`longitude` AS `longitude_atual`
FROM `plano` p
LEFT JOIN `estacao_monitoramento` e ON e.`codigo` = p.`codigo`
LEFT JOIN `corpo_hidrico` c ON c.`id_corpo_hidrico` = e.`id_corpo_hidrico`
LEFT JOIN `orgao_responsavel` o ON o.`id_orgao` = e.`id_orgao`
WHERE e.`id_estacao` IS NULL
   OR e.`nome` <> p.`nome`
   OR c.`codigo` <> p.`corpo_codigo`
   OR o.`codigo` <> p.`orgao_codigo`
   OR e.`latitude` <> p.`latitude`
   OR e.`longitude` <> p.`longitude`
   OR NOT (e.`descricao_localizacao` <=> p.`descricao_localizacao`)
   OR e.`ativo` <> p.`ativo`
ORDER BY p.`codigo`;

-- 9. ANOMALIA: pontos do mesmo corpo devem permanecer proximos e sob um
-- unico orgao. Deve retornar zero linhas.
WITH RECURSIVE `numeros` (`n`) AS (
    SELECT 1
    UNION ALL
    SELECT `n` + 1 FROM `numeros` WHERE `n` < 72
),
`codigos_previstos` AS (
    SELECT CONCAT('EST', LPAD(`n`, 3, '0')) AS `codigo`
    FROM `numeros`
)
SELECT
    c.`codigo` AS `corpo_codigo`,
    COUNT(e.`id_estacao`) AS `estacoes`,
    COUNT(DISTINCT e.`id_orgao`) AS `orgaos_distintos`,
    COUNT(DISTINCT CONCAT(e.`latitude`, '/', e.`longitude`)) AS `coordenadas_distintas`,
    MAX(e.`latitude`) - MIN(e.`latitude`) AS `amplitude_latitude`,
    MAX(e.`longitude`) - MIN(e.`longitude`) AS `amplitude_longitude`
FROM `corpo_hidrico` c
JOIN `estacao_monitoramento` e ON e.`id_corpo_hidrico` = c.`id_corpo_hidrico`
JOIN `codigos_previstos` p ON p.`codigo` = e.`codigo`
GROUP BY c.`id_corpo_hidrico`, c.`codigo`
HAVING COUNT(e.`id_estacao`) <> 3
    OR COUNT(DISTINCT e.`id_orgao`) <> 1
    OR COUNT(DISTINCT CONCAT(e.`latitude`, '/', e.`longitude`)) <> 3
    OR MAX(e.`latitude`) - MIN(e.`latitude`) > 0.024000
    OR MAX(e.`longitude`) - MIN(e.`longitude`) > 0.020000
ORDER BY c.`codigo`;

-- 10. Distribuicao por bacia e orgao. Informativo.
WITH RECURSIVE `numeros` (`n`) AS (
    SELECT 1
    UNION ALL
    SELECT `n` + 1 FROM `numeros` WHERE `n` < 72
),
`codigos_previstos` AS (
    SELECT CONCAT('EST', LPAD(`n`, 3, '0')) AS `codigo`
    FROM `numeros`
)
SELECT
    b.`codigo` AS `bacia_codigo`,
    b.`nome` AS `bacia_nome`,
    o.`codigo` AS `orgao_codigo`,
    o.`nome` AS `orgao_nome`,
    COUNT(DISTINCT c.`id_corpo_hidrico`) AS `corpos`,
    COUNT(e.`id_estacao`) AS `estacoes`
FROM `estacao_monitoramento` e
JOIN `codigos_previstos` p ON p.`codigo` = e.`codigo`
JOIN `corpo_hidrico` c ON c.`id_corpo_hidrico` = e.`id_corpo_hidrico`
JOIN `bacia_hidrografica` b ON b.`id_bacia` = c.`id_bacia`
JOIN `orgao_responsavel` o ON o.`id_orgao` = e.`id_orgao`
GROUP BY b.`id_bacia`, b.`codigo`, b.`nome`, o.`id_orgao`, o.`codigo`, o.`nome`
ORDER BY b.`codigo`, o.`codigo`;

-- 11. Previa completa para revisao humana. Esperado: 72 linhas.
WITH RECURSIVE `numeros` (`n`) AS (
    SELECT 1
    UNION ALL
    SELECT `n` + 1 FROM `numeros` WHERE `n` < 72
),
`codigos_previstos` AS (
    SELECT CONCAT('EST', LPAD(`n`, 3, '0')) AS `codigo`
    FROM `numeros`
)
SELECT
    e.`codigo`,
    e.`nome`,
    b.`codigo` AS `bacia_codigo`,
    c.`codigo` AS `corpo_codigo`,
    c.`nome` AS `corpo_nome`,
    o.`codigo` AS `orgao_codigo`,
    e.`latitude`,
    e.`longitude`,
    e.`descricao_localizacao`,
    e.`ativo`
FROM `codigos_previstos` p
JOIN `estacao_monitoramento` e ON e.`codigo` = p.`codigo`
JOIN `corpo_hidrico` c ON c.`id_corpo_hidrico` = e.`id_corpo_hidrico`
JOIN `bacia_hidrografica` b ON b.`id_bacia` = c.`id_bacia`
JOIN `orgao_responsavel` o ON o.`id_orgao` = e.`id_orgao`
ORDER BY e.`codigo`;
