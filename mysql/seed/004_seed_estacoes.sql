-- Water Management - Estacoes de monitoramento
-- Populacao idempotente de 72 estacoes: tres por corpo hidrico ativo.
-- Compatibilidade alvo: MySQL 8.0.46.
--
-- REGIAO FICTICIA DOCUMENTADA
-- As coordenadas representam exclusivamente a regiao sintetica do Vale Sereno.
-- Limites adotados: latitude de -23.850000 a -22.550000 e longitude de
-- -47.400000 a -45.750000. Elas nao identificam instalacoes reais.
--
-- Premissas validadas antes da insercao:
--   * seis bacias ativas;
--   * 24 corpos hidricos ativos, todos em bacias ativas;
--   * somente os tipos RIO e RESERVATORIO;
--   * ao menos um orgao responsavel ativo;
--   * ausencia de conflito nos codigos EST001 a EST072.
--
-- Os codigos sao estaveis enquanto o conjunto aprovado de bacias e corpos
-- mantiver seus codigos de negocio. A ordem e: bacia.codigo, corpo.codigo e
-- posicao. Cada bacia e atribuida deterministicamente a um orgao ativo; assim,
-- todos os corpos da mesma bacia permanecem sob o mesmo orgao responsavel.
--
-- O unico INSERT persistente e atomico e atua somente em estacao_monitoramento.
-- Nenhuma FK e desabilitada e nenhum ID AUTO_INCREMENT e presumido.
-- A transacao permanece aberta ao final para validacao e COMMIT/ROLLBACK manual.

SET NAMES utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE `recursos_hidricos`;

START TRANSACTION;

DROP TEMPORARY TABLE IF EXISTS `_wm_plano_estacoes`;
DROP TEMPORARY TABLE IF EXISTS `_wm_guarda_estacoes`;

CREATE TEMPORARY TABLE `_wm_plano_estacoes` (
    `codigo` VARCHAR(20) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    `nome` VARCHAR(120) NOT NULL,
    `corpo_codigo` VARCHAR(20) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    `orgao_codigo` VARCHAR(20) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    `latitude` DECIMAL(8,6) NOT NULL,
    `longitude` DECIMAL(9,6) NOT NULL,
    `descricao_localizacao` VARCHAR(255) NULL,
    `ativo` TINYINT UNSIGNED NOT NULL,
    PRIMARY KEY (`codigo`)
) ENGINE = InnoDB;

INSERT INTO `_wm_plano_estacoes`
    (`codigo`, `nome`, `corpo_codigo`, `orgao_codigo`, `latitude`, `longitude`,
     `descricao_localizacao`, `ativo`)
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
        ROW_NUMBER() OVER (
            PARTITION BY c.`id_bacia`
            ORDER BY c.`codigo`
        ) AS `ordem_corpo_bacia`,
        COUNT(*) OVER (
            PARTITION BY c.`id_bacia`
        ) AS `total_corpos_bacia`,
        ROW_NUMBER() OVER (
            ORDER BY b.`codigo`, c.`codigo`
        ) AS `ordem_corpo_global`
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
    SELECT 1 AS `posicao`, 'A' AS `sufixo`, 0.012000 AS `delta_lat`, -0.010000 AS `delta_lon`
    UNION ALL
    SELECT 2, 'B', 0.000000, 0.000000
    UNION ALL
    SELECT 3, 'C', -0.012000, 0.010000
),
`plano_base` AS (
    SELECT
        CONCAT(
            'EST',
            LPAD(((c.`ordem_corpo_global` - 1) * 3) + p.`posicao`, 3, '0')
        ) AS `codigo`,
        c.`corpo_codigo`,
        c.`corpo_nome`,
        c.`codigo_tipo_corpo`,
        c.`bacia_codigo`,
        o.`orgao_codigo`,
        p.`posicao`,
        p.`sufixo`,
        CASE
            WHEN c.`codigo_tipo_corpo` = 'RIO' AND p.`posicao` = 1 THEN 'Montante'
            WHEN c.`codigo_tipo_corpo` = 'RIO' AND p.`posicao` = 2 THEN 'Trecho médio'
            WHEN c.`codigo_tipo_corpo` = 'RIO' AND p.`posicao` = 3 THEN 'Jusante'
            WHEN c.`codigo_tipo_corpo` = 'RESERVATORIO' AND p.`posicao` = 1 THEN 'Braço de entrada'
            WHEN c.`codigo_tipo_corpo` = 'RESERVATORIO' AND p.`posicao` = 2 THEN 'Corpo central'
            WHEN c.`codigo_tipo_corpo` = 'RESERVATORIO' AND p.`posicao` = 3 THEN 'Saída do vertedouro'
            ELSE CONCAT('Ponto ', p.`sufixo`)
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
)
SELECT
    pb.`codigo`,
    LEFT(
        CONCAT('Estação ', pb.`codigo`, ' — ', pb.`corpo_nome`, ' — ', pb.`posicao_nome`),
        120
    ) AS `nome`,
    pb.`corpo_codigo`,
    pb.`orgao_codigo`,
    pb.`latitude`,
    pb.`longitude`,
    LEFT(
        CONCAT(
            'Região fictícia do Vale Sereno; ',
            pb.`posicao_nome`, ' de ', pb.`corpo_nome`,
            ', bacia ', pb.`bacia_codigo`,
            '; coordenadas sintéticas.'
        ),
        255
    ) AS `descricao_localizacao`,
    1 AS `ativo`
FROM `plano_base` pb;

-- O MySQL nao permite consultar uma mesma tabela temporaria mais de uma vez na
-- mesma instrucao (erro 1137). Cada verificacao do plano e, portanto, calculada
-- separadamente e armazenada em uma variavel da sessao antes do guardiao.
SET @wm_estacoes_total_plano := (
    SELECT COUNT(*)
    FROM `_wm_plano_estacoes`
);

SET @wm_estacoes_conflitos := (
    SELECT COUNT(*)
    FROM `_wm_plano_estacoes` p
    JOIN `estacao_monitoramento` e ON e.`codigo` = p.`codigo`
    JOIN `corpo_hidrico` c ON c.`id_corpo_hidrico` = e.`id_corpo_hidrico`
    JOIN `orgao_responsavel` o ON o.`id_orgao` = e.`id_orgao`
    WHERE e.`nome` <> p.`nome`
       OR c.`codigo` <> p.`corpo_codigo`
       OR o.`codigo` <> p.`orgao_codigo`
       OR e.`latitude` <> p.`latitude`
       OR e.`longitude` <> p.`longitude`
       OR NOT (e.`descricao_localizacao` <=> p.`descricao_localizacao`)
       OR e.`ativo` <> p.`ativo`
);

-- A restricao CHECK transforma qualquer premissa invalida em erro. O JOIN com
-- a guarda tambem garante zero insercoes caso a ferramenta continue apos o erro.
CREATE TEMPORARY TABLE `_wm_guarda_estacoes` (
    `ok` TINYINT NOT NULL CHECK (`ok` = 1)
) ENGINE = InnoDB;

INSERT INTO `_wm_guarda_estacoes` (`ok`)
SELECT CASE
    WHEN (SELECT COUNT(*) FROM `bacia_hidrografica` WHERE `ativo` = 1) = 6
     AND (SELECT COUNT(*) FROM `corpo_hidrico` WHERE `ativo` = 1) = 24
     AND (SELECT COUNT(*) FROM `orgao_responsavel` WHERE `ativo` = 1) >= 1
     AND NOT EXISTS (
         SELECT 1
         FROM `corpo_hidrico` c
         LEFT JOIN `bacia_hidrografica` b ON b.`id_bacia` = c.`id_bacia`
         WHERE c.`ativo` = 1
           AND (b.`id_bacia` IS NULL OR b.`ativo` <> 1)
     )
     AND NOT EXISTS (
         SELECT 1
         FROM `corpo_hidrico` c
         WHERE c.`ativo` = 1
           AND c.`codigo_tipo_corpo` NOT IN ('RIO', 'RESERVATORIO')
     )
     AND @wm_estacoes_total_plano = 72
     AND @wm_estacoes_conflitos = 0
    THEN 1
    ELSE 0
END;

-- Resolve as duas FKs exclusivamente pelos codigos de negocio materializados
-- no plano. Registros ja existentes e identicos nao sao atualizados.
INSERT INTO `estacao_monitoramento`
    (`codigo`, `nome`, `id_corpo_hidrico`, `id_orgao`, `latitude`, `longitude`,
     `descricao_localizacao`, `ativo`)
SELECT
    p.`codigo`,
    p.`nome`,
    c.`id_corpo_hidrico`,
    o.`id_orgao`,
    p.`latitude`,
    p.`longitude`,
    p.`descricao_localizacao`,
    p.`ativo`
FROM `_wm_plano_estacoes` p
JOIN `_wm_guarda_estacoes` g ON g.`ok` = 1
JOIN `corpo_hidrico` c ON c.`codigo` = p.`corpo_codigo`
JOIN `orgao_responsavel` o ON o.`codigo` = p.`orgao_codigo`
WHERE NOT EXISTS (
    SELECT 1
    FROM `estacao_monitoramento` e
    WHERE e.`codigo` = p.`codigo`
);

DROP TEMPORARY TABLE `_wm_guarda_estacoes`;
DROP TEMPORARY TABLE `_wm_plano_estacoes`;

SET @wm_estacoes_total_plano := NULL;
SET @wm_estacoes_conflitos := NULL;

-- IMPORTANTE: a transacao continua aberta nesta conexao.
-- Execute 006_verify_estacoes.sql na mesma aba/conexao e finalize manualmente:
--   COMMIT;   -- somente se todas as validacoes forem aprovadas
--   ROLLBACK; -- diante de qualquer erro ou anomalia
SELECT
    COUNT(*) AS `estacoes_na_transacao`,
    'TRANSAÇÃO ABERTA — execute 006_verify_estacoes.sql e depois COMMIT ou ROLLBACK manual' AS `proxima_acao`
FROM `estacao_monitoramento`
WHERE `codigo` BETWEEN 'EST001' AND 'EST072';
