-- Water Management - Verificacao de orgaos e bacias do Vale Sereno
-- Validacao somente leitura da carga 002_seed_orgaos_bacias.sql.
-- Compatibilidade alvo: MySQL 8.0.46.
-- Consultas identificadas como anomalia devem retornar zero linhas.

SET NAMES utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE `recursos_hidricos`;

-- 1. Resumo. Esperado: 3 orgaos e 6 bacias do conjunto aprovado.
SELECT
    'orgao_responsavel' AS `tabela`,
    COUNT(*) AS `total_atual`,
    COALESCE(SUM(`codigo` IN ('ARHVS', 'CENTRO_TECNICO', 'CONSORCIO_VALE')), 0) AS `previstos_encontrados`,
    3 AS `total_previsto`
FROM `orgao_responsavel`
UNION ALL
SELECT
    'bacia_hidrografica',
    COUNT(*),
    COALESCE(SUM(`codigo` IN (
        'BVS_ALTO_CEDRO', 'BVS_BAIXO_VALE', 'BVS_CAMPO_VERDE',
        'BVS_LAGOA_SERENA', 'BVS_PEDRA_CLARA', 'BVS_SERRA_AZUL'
    )), 0),
    6
FROM `bacia_hidrografica`;

-- 2. ANOMALIA: codigos ou nomes duplicados. Deve retornar zero linhas.
SELECT 'orgao_responsavel' AS `tabela`, 'codigo' AS `campo`,
       CONVERT(`codigo` USING utf8mb4) AS `valor`, COUNT(*) AS `ocorrencias`
FROM `orgao_responsavel`
GROUP BY `codigo`
HAVING COUNT(*) > 1
UNION ALL
SELECT 'orgao_responsavel', 'nome', `nome`, COUNT(*)
FROM `orgao_responsavel`
GROUP BY `nome`
HAVING COUNT(*) > 1
UNION ALL
SELECT 'bacia_hidrografica', 'codigo', CONVERT(`codigo` USING utf8mb4), COUNT(*)
FROM `bacia_hidrografica`
GROUP BY `codigo`
HAVING COUNT(*) > 1
UNION ALL
SELECT 'bacia_hidrografica', 'nome', `nome`, COUNT(*)
FROM `bacia_hidrografica`
GROUP BY `nome`
HAVING COUNT(*) > 1;

-- 3. ANOMALIA: registros previstos ausentes. Deve retornar zero linhas.
WITH `previstos` (`tabela`, `codigo`) AS (
    SELECT 'orgao_responsavel', 'ARHVS' UNION ALL
    SELECT 'orgao_responsavel', 'CENTRO_TECNICO' UNION ALL
    SELECT 'orgao_responsavel', 'CONSORCIO_VALE' UNION ALL
    SELECT 'bacia_hidrografica', 'BVS_ALTO_CEDRO' UNION ALL
    SELECT 'bacia_hidrografica', 'BVS_BAIXO_VALE' UNION ALL
    SELECT 'bacia_hidrografica', 'BVS_CAMPO_VERDE' UNION ALL
    SELECT 'bacia_hidrografica', 'BVS_LAGOA_SERENA' UNION ALL
    SELECT 'bacia_hidrografica', 'BVS_PEDRA_CLARA' UNION ALL
    SELECT 'bacia_hidrografica', 'BVS_SERRA_AZUL'
),
`atuais` (`tabela`, `codigo`) AS (
    SELECT 'orgao_responsavel', `codigo` FROM `orgao_responsavel`
    UNION ALL
    SELECT 'bacia_hidrografica', `codigo` FROM `bacia_hidrografica`
)
SELECT p.`tabela`, p.`codigo`
FROM `previstos` p
LEFT JOIN `atuais` a
  ON a.`tabela` = p.`tabela`
 AND a.`codigo` = p.`codigo`
WHERE a.`codigo` IS NULL
ORDER BY p.`tabela`, p.`codigo`;

-- 4. ANOMALIA: registros adicionais fora do conjunto aprovado.
-- Deve retornar zero linhas nesta etapa inicial.
WITH `previstos` (`tabela`, `codigo`) AS (
    SELECT 'orgao_responsavel', 'ARHVS' UNION ALL
    SELECT 'orgao_responsavel', 'CENTRO_TECNICO' UNION ALL
    SELECT 'orgao_responsavel', 'CONSORCIO_VALE' UNION ALL
    SELECT 'bacia_hidrografica', 'BVS_ALTO_CEDRO' UNION ALL
    SELECT 'bacia_hidrografica', 'BVS_BAIXO_VALE' UNION ALL
    SELECT 'bacia_hidrografica', 'BVS_CAMPO_VERDE' UNION ALL
    SELECT 'bacia_hidrografica', 'BVS_LAGOA_SERENA' UNION ALL
    SELECT 'bacia_hidrografica', 'BVS_PEDRA_CLARA' UNION ALL
    SELECT 'bacia_hidrografica', 'BVS_SERRA_AZUL'
),
`atuais` (`tabela`, `codigo`, `nome`) AS (
    SELECT 'orgao_responsavel', `codigo`, `nome` FROM `orgao_responsavel`
    UNION ALL
    SELECT 'bacia_hidrografica', `codigo`, `nome` FROM `bacia_hidrografica`
)
SELECT a.`tabela`, a.`codigo`, a.`nome`
FROM `atuais` a
LEFT JOIN `previstos` p
  ON p.`tabela` = a.`tabela`
 AND p.`codigo` = a.`codigo`
WHERE p.`codigo` IS NULL
ORDER BY a.`tabela`, a.`codigo`;

-- 5. ANOMALIA: conteudo divergente ou registro inativo. Zero linhas.
WITH `orgaos_previstos` (`codigo`, `nome`, `descricao`) AS (
    SELECT 'ARHVS',
           'Agência Regional de Monitoramento Hídrico do Vale Sereno',
           'Órgão fictício de coordenação regional do monitoramento hídrico no Vale Sereno.'
    UNION ALL
    SELECT 'CENTRO_TECNICO',
           'Centro Técnico de Monitoramento do Vale Sereno',
           'Órgão fictício responsável por operação técnica, consistência de dados e apoio às estações.'
    UNION ALL
    SELECT 'CONSORCIO_VALE',
           'Consórcio Interbacias do Vale Sereno',
           'Órgão fictício de cooperação operacional entre as bacias hidrográficas do Vale Sereno.'
),
`bacias_previstas` (`codigo`, `nome`, `descricao`) AS (
    SELECT 'BVS_ALTO_CEDRO', 'Bacia do Alto Cedro',
           'Bacia fictícia de cabeceiras serranas e vales estreitos na porção noroeste do Vale Sereno.'
    UNION ALL
    SELECT 'BVS_BAIXO_VALE', 'Bacia do Baixo Vale',
           'Bacia fictícia de convergência dos cursos d''água na porção sudeste do Vale Sereno.'
    UNION ALL
    SELECT 'BVS_CAMPO_VERDE', 'Bacia do Campo Verde',
           'Bacia fictícia de relevo suave, veredas e áreas de planície na faixa central do Vale Sereno.'
    UNION ALL
    SELECT 'BVS_LAGOA_SERENA', 'Bacia da Lagoa Serena',
           'Bacia fictícia com áreas úmidas, lagoas marginais e cursos de baixa declividade.'
    UNION ALL
    SELECT 'BVS_PEDRA_CLARA', 'Bacia da Pedra Clara',
           'Bacia fictícia de leitos rochosos e águas naturalmente claras na porção nordeste da região.'
    UNION ALL
    SELECT 'BVS_SERRA_AZUL', 'Bacia da Serra Azul',
           'Bacia fictícia de encostas, nascentes frias e trechos de maior declividade.'
),
`divergencias` AS (
    SELECT
        'orgao_responsavel' AS `tabela`,
        p.`codigo`, p.`nome` AS `nome_esperado`, o.`nome` AS `nome_atual`,
        p.`descricao` AS `descricao_esperada`, o.`descricao` AS `descricao_atual`,
        o.`ativo`
    FROM `orgaos_previstos` p
    JOIN `orgao_responsavel` o ON o.`codigo` = p.`codigo`
    WHERE o.`nome` <> p.`nome`
       OR NOT (o.`descricao` <=> p.`descricao`)
       OR o.`ativo` <> 1

    UNION ALL

    SELECT
        'bacia_hidrografica',
        p.`codigo`, p.`nome`, b.`nome`, p.`descricao`, b.`descricao`, b.`ativo`
    FROM `bacias_previstas` p
    JOIN `bacia_hidrografica` b ON b.`codigo` = p.`codigo`
    WHERE b.`nome` <> p.`nome`
       OR NOT (b.`descricao` <=> p.`descricao`)
       OR b.`ativo` <> 1
)
SELECT *
FROM `divergencias`
ORDER BY `tabela`, `codigo`;

-- 6. Previa dos tres orgaos.
SELECT `codigo`, `nome`, `descricao`, `ativo`
FROM `orgao_responsavel`
WHERE `codigo` IN ('ARHVS', 'CENTRO_TECNICO', 'CONSORCIO_VALE')
ORDER BY `codigo`;

-- 7. Previa das seis bacias.
SELECT `codigo`, `nome`, `descricao`, `ativo`
FROM `bacia_hidrografica`
WHERE `codigo` IN (
    'BVS_ALTO_CEDRO', 'BVS_BAIXO_VALE', 'BVS_CAMPO_VERDE',
    'BVS_LAGOA_SERENA', 'BVS_PEDRA_CLARA', 'BVS_SERRA_AZUL'
)
ORDER BY `codigo`;
