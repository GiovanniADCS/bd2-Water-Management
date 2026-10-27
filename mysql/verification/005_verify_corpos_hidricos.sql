-- Water Management - Verificacao dos corpos hidricos do Vale Sereno
-- Validacao somente leitura da carga 003_seed_corpos_hidricos.sql.
-- Compatibilidade alvo: MySQL 8.0.46.
-- Consultas identificadas como anomalia devem retornar zero linhas.

SET NAMES utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE `recursos_hidricos`;

-- Relacao de negocio aprovada: codigo, nome, bacia e tipo.
-- Esta CTE e repetida nas consultas para manter o script somente leitura.

-- 1. Resumo. Esperado: 24 corpos previstos e ativos.
WITH `previstos` (`codigo`, `nome`, `bacia_codigo`, `tipo_codigo`) AS (
    SELECT 'AC_RES_MIRANTE', 'Reservatório do Mirante', 'BVS_ALTO_CEDRO', 'RESERVATORIO' UNION ALL
    SELECT 'AC_RIO_BRUMA', 'Rio da Bruma', 'BVS_ALTO_CEDRO', 'RIO' UNION ALL
    SELECT 'AC_RIO_CEDRO', 'Rio Cedro', 'BVS_ALTO_CEDRO', 'RIO' UNION ALL
    SELECT 'AC_RIO_FIGUEIRA', 'Rio Figueira', 'BVS_ALTO_CEDRO', 'RIO' UNION ALL
    SELECT 'BV_RES_FOZ_SERENA', 'Reservatório Foz Serena', 'BVS_BAIXO_VALE', 'RESERVATORIO' UNION ALL
    SELECT 'BV_RIO_ESTRELA', 'Rio Estrela', 'BVS_BAIXO_VALE', 'RIO' UNION ALL
    SELECT 'BV_RIO_VALE', 'Rio do Vale', 'BVS_BAIXO_VALE', 'RIO' UNION ALL
    SELECT 'BV_RIO_VENTANIA', 'Rio Ventania', 'BVS_BAIXO_VALE', 'RIO' UNION ALL
    SELECT 'CV_RES_PLANICIE', 'Reservatório da Planície', 'BVS_CAMPO_VERDE', 'RESERVATORIO' UNION ALL
    SELECT 'CV_RIO_CAMPO', 'Rio do Campo', 'BVS_CAMPO_VERDE', 'RIO' UNION ALL
    SELECT 'CV_RIO_CAPIM', 'Rio Capim-Dourado', 'BVS_CAMPO_VERDE', 'RIO' UNION ALL
    SELECT 'CV_RIO_VEREDA', 'Rio da Vereda', 'BVS_CAMPO_VERDE', 'RIO' UNION ALL
    SELECT 'LS_RES_AGUAS_CALMAS', 'Reservatório Águas Calmas', 'BVS_LAGOA_SERENA', 'RESERVATORIO' UNION ALL
    SELECT 'LS_RIO_JUNCO', 'Rio do Junco', 'BVS_LAGOA_SERENA', 'RIO' UNION ALL
    SELECT 'LS_RIO_LIRIO', 'Rio dos Lírios', 'BVS_LAGOA_SERENA', 'RIO' UNION ALL
    SELECT 'LS_RIO_SALGUEIRO', 'Rio Salgueiro', 'BVS_LAGOA_SERENA', 'RIO' UNION ALL
    SELECT 'PC_RES_HORIZONTE', 'Reservatório Horizonte', 'BVS_PEDRA_CLARA', 'RESERVATORIO' UNION ALL
    SELECT 'PC_RIO_AROEIRA', 'Rio Aroeira', 'BVS_PEDRA_CLARA', 'RIO' UNION ALL
    SELECT 'PC_RIO_CRISTAL', 'Rio Cristal', 'BVS_PEDRA_CLARA', 'RIO' UNION ALL
    SELECT 'PC_RIO_PEDRA', 'Rio Pedra Clara', 'BVS_PEDRA_CLARA', 'RIO' UNION ALL
    SELECT 'SA_RES_PEDRA_ALTA', 'Reservatório Pedra Alta', 'BVS_SERRA_AZUL', 'RESERVATORIO' UNION ALL
    SELECT 'SA_RIO_NEVOA', 'Rio da Névoa', 'BVS_SERRA_AZUL', 'RIO' UNION ALL
    SELECT 'SA_RIO_PINHEIRO', 'Rio dos Pinheiros', 'BVS_SERRA_AZUL', 'RIO' UNION ALL
    SELECT 'SA_RIO_SERRA', 'Rio Serra Azul', 'BVS_SERRA_AZUL', 'RIO'
)
SELECT
    COUNT(c.`id_corpo_hidrico`) AS `previstos_encontrados`,
    COALESCE(SUM(c.`ativo` = 1), 0) AS `previstos_ativos`,
    COUNT(DISTINCT c.`id_bacia`) AS `bacias_cobertas`,
    24 AS `total_previsto`,
    (SELECT COUNT(*) FROM `corpo_hidrico`) AS `total_atual`
FROM `previstos` p
LEFT JOIN `corpo_hidrico` c ON c.`codigo` = p.`codigo`;

-- 2. Distribuicao informativa. Esperado por bacia: 4 corpos, 3 RIO e
-- 1 RESERVATORIO.
SELECT
    b.`codigo` AS `bacia_codigo`,
    b.`nome` AS `bacia_nome`,
    COUNT(c.`id_corpo_hidrico`) AS `total_corpos`,
    COALESCE(SUM(c.`codigo_tipo_corpo` = 'RIO'), 0) AS `rios`,
    COALESCE(SUM(c.`codigo_tipo_corpo` = 'RESERVATORIO'), 0) AS `reservatorios`
FROM `bacia_hidrografica` b
LEFT JOIN `corpo_hidrico` c ON c.`id_bacia` = b.`id_bacia`
WHERE b.`codigo` IN (
    'BVS_ALTO_CEDRO', 'BVS_BAIXO_VALE', 'BVS_CAMPO_VERDE',
    'BVS_LAGOA_SERENA', 'BVS_PEDRA_CLARA', 'BVS_SERRA_AZUL'
)
GROUP BY b.`id_bacia`, b.`codigo`, b.`nome`
ORDER BY b.`codigo`;

-- 3. ANOMALIA: codigos ou nomes duplicados. Deve retornar zero linhas.
SELECT 'codigo' AS `campo`, CONVERT(`codigo` USING utf8mb4) AS `valor`, COUNT(*) AS `ocorrencias`
FROM `corpo_hidrico`
GROUP BY `codigo`
HAVING COUNT(*) > 1
UNION ALL
SELECT 'nome', `nome`, COUNT(*)
FROM `corpo_hidrico`
GROUP BY `nome`
HAVING COUNT(*) > 1;

-- 4. ANOMALIA: corpos previstos ausentes. Deve retornar zero linhas.
WITH `previstos` (`codigo`) AS (
    SELECT 'AC_RES_MIRANTE' UNION ALL SELECT 'AC_RIO_BRUMA' UNION ALL
    SELECT 'AC_RIO_CEDRO' UNION ALL SELECT 'AC_RIO_FIGUEIRA' UNION ALL
    SELECT 'BV_RES_FOZ_SERENA' UNION ALL SELECT 'BV_RIO_ESTRELA' UNION ALL
    SELECT 'BV_RIO_VALE' UNION ALL SELECT 'BV_RIO_VENTANIA' UNION ALL
    SELECT 'CV_RES_PLANICIE' UNION ALL SELECT 'CV_RIO_CAMPO' UNION ALL
    SELECT 'CV_RIO_CAPIM' UNION ALL SELECT 'CV_RIO_VEREDA' UNION ALL
    SELECT 'LS_RES_AGUAS_CALMAS' UNION ALL SELECT 'LS_RIO_JUNCO' UNION ALL
    SELECT 'LS_RIO_LIRIO' UNION ALL SELECT 'LS_RIO_SALGUEIRO' UNION ALL
    SELECT 'PC_RES_HORIZONTE' UNION ALL SELECT 'PC_RIO_AROEIRA' UNION ALL
    SELECT 'PC_RIO_CRISTAL' UNION ALL SELECT 'PC_RIO_PEDRA' UNION ALL
    SELECT 'SA_RES_PEDRA_ALTA' UNION ALL SELECT 'SA_RIO_NEVOA' UNION ALL
    SELECT 'SA_RIO_PINHEIRO' UNION ALL SELECT 'SA_RIO_SERRA'
)
SELECT p.`codigo`
FROM `previstos` p
LEFT JOIN `corpo_hidrico` c ON c.`codigo` = p.`codigo`
WHERE c.`id_corpo_hidrico` IS NULL
ORDER BY p.`codigo`;

-- 5. ANOMALIA: registros adicionais fora do conjunto aprovado.
-- Deve retornar zero linhas nesta etapa inicial.
WITH `previstos` (`codigo`) AS (
    SELECT 'AC_RES_MIRANTE' UNION ALL SELECT 'AC_RIO_BRUMA' UNION ALL
    SELECT 'AC_RIO_CEDRO' UNION ALL SELECT 'AC_RIO_FIGUEIRA' UNION ALL
    SELECT 'BV_RES_FOZ_SERENA' UNION ALL SELECT 'BV_RIO_ESTRELA' UNION ALL
    SELECT 'BV_RIO_VALE' UNION ALL SELECT 'BV_RIO_VENTANIA' UNION ALL
    SELECT 'CV_RES_PLANICIE' UNION ALL SELECT 'CV_RIO_CAMPO' UNION ALL
    SELECT 'CV_RIO_CAPIM' UNION ALL SELECT 'CV_RIO_VEREDA' UNION ALL
    SELECT 'LS_RES_AGUAS_CALMAS' UNION ALL SELECT 'LS_RIO_JUNCO' UNION ALL
    SELECT 'LS_RIO_LIRIO' UNION ALL SELECT 'LS_RIO_SALGUEIRO' UNION ALL
    SELECT 'PC_RES_HORIZONTE' UNION ALL SELECT 'PC_RIO_AROEIRA' UNION ALL
    SELECT 'PC_RIO_CRISTAL' UNION ALL SELECT 'PC_RIO_PEDRA' UNION ALL
    SELECT 'SA_RES_PEDRA_ALTA' UNION ALL SELECT 'SA_RIO_NEVOA' UNION ALL
    SELECT 'SA_RIO_PINHEIRO' UNION ALL SELECT 'SA_RIO_SERRA'
)
SELECT c.`codigo`, c.`nome`
FROM `corpo_hidrico` c
LEFT JOIN `previstos` p ON p.`codigo` = c.`codigo`
WHERE p.`codigo` IS NULL
ORDER BY c.`codigo`;

-- 6. ANOMALIA: nome, bacia, tipo ou estado divergente. Zero linhas.
WITH `previstos` (`codigo`, `nome`, `bacia_codigo`, `tipo_codigo`) AS (
    SELECT 'AC_RES_MIRANTE', 'Reservatório do Mirante', 'BVS_ALTO_CEDRO', 'RESERVATORIO' UNION ALL
    SELECT 'AC_RIO_BRUMA', 'Rio da Bruma', 'BVS_ALTO_CEDRO', 'RIO' UNION ALL
    SELECT 'AC_RIO_CEDRO', 'Rio Cedro', 'BVS_ALTO_CEDRO', 'RIO' UNION ALL
    SELECT 'AC_RIO_FIGUEIRA', 'Rio Figueira', 'BVS_ALTO_CEDRO', 'RIO' UNION ALL
    SELECT 'BV_RES_FOZ_SERENA', 'Reservatório Foz Serena', 'BVS_BAIXO_VALE', 'RESERVATORIO' UNION ALL
    SELECT 'BV_RIO_ESTRELA', 'Rio Estrela', 'BVS_BAIXO_VALE', 'RIO' UNION ALL
    SELECT 'BV_RIO_VALE', 'Rio do Vale', 'BVS_BAIXO_VALE', 'RIO' UNION ALL
    SELECT 'BV_RIO_VENTANIA', 'Rio Ventania', 'BVS_BAIXO_VALE', 'RIO' UNION ALL
    SELECT 'CV_RES_PLANICIE', 'Reservatório da Planície', 'BVS_CAMPO_VERDE', 'RESERVATORIO' UNION ALL
    SELECT 'CV_RIO_CAMPO', 'Rio do Campo', 'BVS_CAMPO_VERDE', 'RIO' UNION ALL
    SELECT 'CV_RIO_CAPIM', 'Rio Capim-Dourado', 'BVS_CAMPO_VERDE', 'RIO' UNION ALL
    SELECT 'CV_RIO_VEREDA', 'Rio da Vereda', 'BVS_CAMPO_VERDE', 'RIO' UNION ALL
    SELECT 'LS_RES_AGUAS_CALMAS', 'Reservatório Águas Calmas', 'BVS_LAGOA_SERENA', 'RESERVATORIO' UNION ALL
    SELECT 'LS_RIO_JUNCO', 'Rio do Junco', 'BVS_LAGOA_SERENA', 'RIO' UNION ALL
    SELECT 'LS_RIO_LIRIO', 'Rio dos Lírios', 'BVS_LAGOA_SERENA', 'RIO' UNION ALL
    SELECT 'LS_RIO_SALGUEIRO', 'Rio Salgueiro', 'BVS_LAGOA_SERENA', 'RIO' UNION ALL
    SELECT 'PC_RES_HORIZONTE', 'Reservatório Horizonte', 'BVS_PEDRA_CLARA', 'RESERVATORIO' UNION ALL
    SELECT 'PC_RIO_AROEIRA', 'Rio Aroeira', 'BVS_PEDRA_CLARA', 'RIO' UNION ALL
    SELECT 'PC_RIO_CRISTAL', 'Rio Cristal', 'BVS_PEDRA_CLARA', 'RIO' UNION ALL
    SELECT 'PC_RIO_PEDRA', 'Rio Pedra Clara', 'BVS_PEDRA_CLARA', 'RIO' UNION ALL
    SELECT 'SA_RES_PEDRA_ALTA', 'Reservatório Pedra Alta', 'BVS_SERRA_AZUL', 'RESERVATORIO' UNION ALL
    SELECT 'SA_RIO_NEVOA', 'Rio da Névoa', 'BVS_SERRA_AZUL', 'RIO' UNION ALL
    SELECT 'SA_RIO_PINHEIRO', 'Rio dos Pinheiros', 'BVS_SERRA_AZUL', 'RIO' UNION ALL
    SELECT 'SA_RIO_SERRA', 'Rio Serra Azul', 'BVS_SERRA_AZUL', 'RIO'
)
SELECT
    p.`codigo`,
    p.`nome` AS `nome_esperado`, c.`nome` AS `nome_atual`,
    p.`bacia_codigo` AS `bacia_esperada`, b.`codigo` AS `bacia_atual`,
    p.`tipo_codigo` AS `tipo_esperado`, c.`codigo_tipo_corpo` AS `tipo_atual`,
    c.`ativo`
FROM `previstos` p
JOIN `corpo_hidrico` c ON c.`codigo` = p.`codigo`
LEFT JOIN `bacia_hidrografica` b ON b.`id_bacia` = c.`id_bacia`
WHERE c.`nome` <> p.`nome`
   OR b.`codigo` <> p.`bacia_codigo`
   OR c.`codigo_tipo_corpo` <> p.`tipo_codigo`
   OR c.`ativo` <> 1
ORDER BY p.`codigo`;

-- 7. ANOMALIA: referencia, descricao ou distribuicao invalida. Zero linhas.
SELECT
    c.`codigo`, c.`nome`, b.`codigo` AS `bacia_codigo`,
    c.`codigo_tipo_corpo`, c.`ativo`,
    CASE
        WHEN b.`id_bacia` IS NULL THEN 'bacia inexistente'
        WHEN b.`ativo` <> 1 THEN 'bacia inativa'
        WHEN t.`codigo_tipo_corpo` IS NULL THEN 'tipo inexistente'
        WHEN c.`codigo_tipo_corpo` NOT IN ('RIO', 'RESERVATORIO') THEN 'tipo nao aprovado'
        WHEN c.`descricao` IS NULL OR TRIM(c.`descricao`) = '' THEN 'descricao ausente'
        WHEN c.`ativo` <> 1 THEN 'corpo inativo'
        ELSE 'inconsistencia nao classificada'
    END AS `anomalia`
FROM `corpo_hidrico` c
LEFT JOIN `bacia_hidrografica` b ON b.`id_bacia` = c.`id_bacia`
LEFT JOIN `tipo_corpo_hidrico` t ON t.`codigo_tipo_corpo` = c.`codigo_tipo_corpo`
WHERE c.`codigo` IN (
    'AC_RES_MIRANTE', 'AC_RIO_BRUMA', 'AC_RIO_CEDRO', 'AC_RIO_FIGUEIRA',
    'BV_RES_FOZ_SERENA', 'BV_RIO_ESTRELA', 'BV_RIO_VALE', 'BV_RIO_VENTANIA',
    'CV_RES_PLANICIE', 'CV_RIO_CAMPO', 'CV_RIO_CAPIM', 'CV_RIO_VEREDA',
    'LS_RES_AGUAS_CALMAS', 'LS_RIO_JUNCO', 'LS_RIO_LIRIO', 'LS_RIO_SALGUEIRO',
    'PC_RES_HORIZONTE', 'PC_RIO_AROEIRA', 'PC_RIO_CRISTAL', 'PC_RIO_PEDRA',
    'SA_RES_PEDRA_ALTA', 'SA_RIO_NEVOA', 'SA_RIO_PINHEIRO', 'SA_RIO_SERRA'
)
AND (
       b.`id_bacia` IS NULL
    OR b.`ativo` <> 1
    OR t.`codigo_tipo_corpo` IS NULL
    OR c.`codigo_tipo_corpo` NOT IN ('RIO', 'RESERVATORIO')
    OR c.`descricao` IS NULL
    OR TRIM(c.`descricao`) = ''
    OR c.`ativo` <> 1
)
ORDER BY c.`codigo`;

-- 8. ANOMALIA: cada bacia deve ter exatamente 4 corpos, 3 rios e
-- 1 reservatorio. Deve retornar zero linhas.
SELECT
    b.`codigo` AS `bacia_codigo`,
    COUNT(c.`id_corpo_hidrico`) AS `total_corpos`,
    COALESCE(SUM(c.`codigo_tipo_corpo` = 'RIO'), 0) AS `rios`,
    COALESCE(SUM(c.`codigo_tipo_corpo` = 'RESERVATORIO'), 0) AS `reservatorios`
FROM `bacia_hidrografica` b
LEFT JOIN `corpo_hidrico` c ON c.`id_bacia` = b.`id_bacia`
WHERE b.`codigo` IN (
    'BVS_ALTO_CEDRO', 'BVS_BAIXO_VALE', 'BVS_CAMPO_VERDE',
    'BVS_LAGOA_SERENA', 'BVS_PEDRA_CLARA', 'BVS_SERRA_AZUL'
)
GROUP BY b.`id_bacia`, b.`codigo`
HAVING COUNT(c.`id_corpo_hidrico`) <> 4
    OR COALESCE(SUM(c.`codigo_tipo_corpo` = 'RIO'), 0) <> 3
    OR COALESCE(SUM(c.`codigo_tipo_corpo` = 'RESERVATORIO'), 0) <> 1
ORDER BY b.`codigo`;

-- 9. Previa completa dos 24 corpos hidricos.
SELECT
    c.`codigo`, c.`nome`, b.`codigo` AS `bacia_codigo`, b.`nome` AS `bacia_nome`,
    c.`codigo_tipo_corpo`, c.`descricao`, c.`ativo`
FROM `corpo_hidrico` c
JOIN `bacia_hidrografica` b ON b.`id_bacia` = c.`id_bacia`
WHERE c.`codigo` IN (
    'AC_RES_MIRANTE', 'AC_RIO_BRUMA', 'AC_RIO_CEDRO', 'AC_RIO_FIGUEIRA',
    'BV_RES_FOZ_SERENA', 'BV_RIO_ESTRELA', 'BV_RIO_VALE', 'BV_RIO_VENTANIA',
    'CV_RES_PLANICIE', 'CV_RIO_CAMPO', 'CV_RIO_CAPIM', 'CV_RIO_VEREDA',
    'LS_RES_AGUAS_CALMAS', 'LS_RIO_JUNCO', 'LS_RIO_LIRIO', 'LS_RIO_SALGUEIRO',
    'PC_RES_HORIZONTE', 'PC_RIO_AROEIRA', 'PC_RIO_CRISTAL', 'PC_RIO_PEDRA',
    'SA_RES_PEDRA_ALTA', 'SA_RIO_NEVOA', 'SA_RIO_PINHEIRO', 'SA_RIO_SERRA'
)
ORDER BY b.`codigo`, c.`codigo`;
