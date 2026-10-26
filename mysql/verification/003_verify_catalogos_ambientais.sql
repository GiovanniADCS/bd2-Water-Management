-- Water Management - Etapa 2B
-- Validacao somente leitura dos catalogos ambientais.
-- Compatibilidade alvo: MySQL 8.0.46.
-- Nao cria, altera, exclui ou popula registros.

SET NAMES utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE `recursos_hidricos`;

-- 1. Resumo. Esperado para a primeira carga: 2, 9, 9, 10 e 14.
WITH `capacidades_previstas` (`tipo_codigo`, `parametro_codigo`) AS (
    SELECT 'TERMOMETRO_AGUA', 'TEMP_AGUA' UNION ALL
    SELECT 'SENSOR_PH', 'PH' UNION ALL
    SELECT 'TURBIDIMETRO', 'TURBIDEZ' UNION ALL
    SELECT 'SENSOR_OD', 'OXIGENIO_DISSOLVIDO' UNION ALL
    SELECT 'CONDUTIVIMETRO', 'CONDUTIVIDADE' UNION ALL
    SELECT 'SENSOR_NIVEL', 'NIVEL_AGUA' UNION ALL
    SELECT 'MEDIDOR_VAZAO', 'VAZAO' UNION ALL
    SELECT 'VELOCIMETRO_AGUA', 'VELOCIDADE_AGUA' UNION ALL
    SELECT 'PLUVIOMETRO', 'PRECIPITACAO' UNION ALL
    SELECT 'SONDA_MULTIPARAM', 'TEMP_AGUA' UNION ALL
    SELECT 'SONDA_MULTIPARAM', 'PH' UNION ALL
    SELECT 'SONDA_MULTIPARAM', 'TURBIDEZ' UNION ALL
    SELECT 'SONDA_MULTIPARAM', 'OXIGENIO_DISSOLVIDO' UNION ALL
    SELECT 'SONDA_MULTIPARAM', 'CONDUTIVIDADE'
)
SELECT
    'tipo_corpo_hidrico' AS `catalogo`,
    COUNT(*) AS `total_atual`,
    COALESCE(SUM(`codigo_tipo_corpo` IN ('RIO', 'RESERVATORIO')), 0) AS `previstos_encontrados`,
    2 AS `total_previsto`
FROM `tipo_corpo_hidrico`
UNION ALL
SELECT
    'unidade_medida',
    COUNT(*),
    COALESCE(SUM(`codigo` IN ('ADIMENSIONAL', 'GRAU_CELSIUS', 'NTU', 'MG_L', 'US_CM', 'METRO', 'METRO_CUBICO_SEG', 'MILIMETRO', 'METRO_SEG')), 0),
    9
FROM `unidade_medida`
UNION ALL
SELECT
    'parametro_monitoramento',
    COUNT(*),
    COALESCE(SUM(`codigo` IN ('TEMP_AGUA', 'PH', 'TURBIDEZ', 'OXIGENIO_DISSOLVIDO', 'CONDUTIVIDADE', 'NIVEL_AGUA', 'VAZAO', 'PRECIPITACAO', 'VELOCIDADE_AGUA')), 0),
    9
FROM `parametro_monitoramento`
UNION ALL
SELECT
    'tipo_sensor',
    COUNT(*),
    COALESCE(SUM(`codigo` IN ('TERMOMETRO_AGUA', 'SENSOR_PH', 'TURBIDIMETRO', 'SENSOR_OD', 'CONDUTIVIMETRO', 'SENSOR_NIVEL', 'MEDIDOR_VAZAO', 'VELOCIMETRO_AGUA', 'PLUVIOMETRO', 'SONDA_MULTIPARAM')), 0),
    10
FROM `tipo_sensor`
UNION ALL
SELECT
    'tipo_sensor_parametro',
    COUNT(*),
    COUNT(e.`tipo_codigo`),
    14
FROM `tipo_sensor_parametro` tsp
JOIN `tipo_sensor` ts ON ts.`id_tipo_sensor` = tsp.`id_tipo_sensor`
JOIN `parametro_monitoramento` p ON p.`id_parametro` = tsp.`id_parametro`
LEFT JOIN `capacidades_previstas` e
  ON e.`tipo_codigo` = ts.`codigo`
 AND e.`parametro_codigo` = p.`codigo`;

-- 2. Nao deve retornar linhas: codigos ou nomes duplicados.
SELECT 'tipo_corpo_hidrico' AS `tabela`, 'codigo' AS `campo`,
       CONVERT(`codigo_tipo_corpo` USING utf8mb4) AS `valor`, COUNT(*) AS `ocorrencias`
FROM `tipo_corpo_hidrico`
GROUP BY `codigo_tipo_corpo`
HAVING COUNT(*) > 1
UNION ALL
SELECT 'tipo_corpo_hidrico', 'nome', CONVERT(`nome` USING utf8mb4), COUNT(*)
FROM `tipo_corpo_hidrico`
GROUP BY `nome`
HAVING COUNT(*) > 1
UNION ALL
SELECT 'unidade_medida', 'codigo', CONVERT(`codigo` USING utf8mb4), COUNT(*)
FROM `unidade_medida`
GROUP BY `codigo`
HAVING COUNT(*) > 1
UNION ALL
SELECT 'unidade_medida', 'nome', CONVERT(`nome` USING utf8mb4), COUNT(*)
FROM `unidade_medida`
GROUP BY `nome`
HAVING COUNT(*) > 1
UNION ALL
SELECT 'parametro_monitoramento', 'codigo', CONVERT(`codigo` USING utf8mb4), COUNT(*)
FROM `parametro_monitoramento`
GROUP BY `codigo`
HAVING COUNT(*) > 1
UNION ALL
SELECT 'parametro_monitoramento', 'nome', CONVERT(`nome` USING utf8mb4), COUNT(*)
FROM `parametro_monitoramento`
GROUP BY `nome`
HAVING COUNT(*) > 1
UNION ALL
SELECT 'tipo_sensor', 'codigo', CONVERT(`codigo` USING utf8mb4), COUNT(*)
FROM `tipo_sensor`
GROUP BY `codigo`
HAVING COUNT(*) > 1
UNION ALL
SELECT 'tipo_sensor', 'nome', CONVERT(`nome` USING utf8mb4), COUNT(*)
FROM `tipo_sensor`
GROUP BY `nome`
HAVING COUNT(*) > 1;

-- 3. Nao deve retornar linhas: registros previstos ausentes.
WITH `previstos` (`catalogo`, `codigo`) AS (
    SELECT 'tipo_corpo_hidrico', 'RIO' UNION ALL
    SELECT 'tipo_corpo_hidrico', 'RESERVATORIO' UNION ALL
    SELECT 'unidade_medida', 'ADIMENSIONAL' UNION ALL
    SELECT 'unidade_medida', 'GRAU_CELSIUS' UNION ALL
    SELECT 'unidade_medida', 'NTU' UNION ALL
    SELECT 'unidade_medida', 'MG_L' UNION ALL
    SELECT 'unidade_medida', 'US_CM' UNION ALL
    SELECT 'unidade_medida', 'METRO' UNION ALL
    SELECT 'unidade_medida', 'METRO_CUBICO_SEG' UNION ALL
    SELECT 'unidade_medida', 'MILIMETRO' UNION ALL
    SELECT 'unidade_medida', 'METRO_SEG' UNION ALL
    SELECT 'parametro_monitoramento', 'TEMP_AGUA' UNION ALL
    SELECT 'parametro_monitoramento', 'PH' UNION ALL
    SELECT 'parametro_monitoramento', 'TURBIDEZ' UNION ALL
    SELECT 'parametro_monitoramento', 'OXIGENIO_DISSOLVIDO' UNION ALL
    SELECT 'parametro_monitoramento', 'CONDUTIVIDADE' UNION ALL
    SELECT 'parametro_monitoramento', 'NIVEL_AGUA' UNION ALL
    SELECT 'parametro_monitoramento', 'VAZAO' UNION ALL
    SELECT 'parametro_monitoramento', 'PRECIPITACAO' UNION ALL
    SELECT 'parametro_monitoramento', 'VELOCIDADE_AGUA' UNION ALL
    SELECT 'tipo_sensor', 'TERMOMETRO_AGUA' UNION ALL
    SELECT 'tipo_sensor', 'SENSOR_PH' UNION ALL
    SELECT 'tipo_sensor', 'TURBIDIMETRO' UNION ALL
    SELECT 'tipo_sensor', 'SENSOR_OD' UNION ALL
    SELECT 'tipo_sensor', 'CONDUTIVIMETRO' UNION ALL
    SELECT 'tipo_sensor', 'SENSOR_NIVEL' UNION ALL
    SELECT 'tipo_sensor', 'MEDIDOR_VAZAO' UNION ALL
    SELECT 'tipo_sensor', 'VELOCIMETRO_AGUA' UNION ALL
    SELECT 'tipo_sensor', 'PLUVIOMETRO' UNION ALL
    SELECT 'tipo_sensor', 'SONDA_MULTIPARAM'
),
`atuais` (`catalogo`, `codigo`) AS (
    SELECT 'tipo_corpo_hidrico', `codigo_tipo_corpo` FROM `tipo_corpo_hidrico` UNION ALL
    SELECT 'unidade_medida', `codigo` FROM `unidade_medida` UNION ALL
    SELECT 'parametro_monitoramento', `codigo` FROM `parametro_monitoramento` UNION ALL
    SELECT 'tipo_sensor', `codigo` FROM `tipo_sensor`
)
SELECT p.`catalogo`, p.`codigo`
FROM `previstos` p
LEFT JOIN `atuais` a
  ON a.`catalogo` = p.`catalogo`
 AND a.`codigo` = p.`codigo`
WHERE a.`codigo` IS NULL
ORDER BY p.`catalogo`, p.`codigo`;

-- 4. Informativa: registros fora desta primeira proposta exigem revisao humana.
WITH `previstos` (`catalogo`, `codigo`) AS (
    SELECT 'tipo_corpo_hidrico', 'RIO' UNION ALL
    SELECT 'tipo_corpo_hidrico', 'RESERVATORIO' UNION ALL
    SELECT 'unidade_medida', 'ADIMENSIONAL' UNION ALL
    SELECT 'unidade_medida', 'GRAU_CELSIUS' UNION ALL
    SELECT 'unidade_medida', 'NTU' UNION ALL
    SELECT 'unidade_medida', 'MG_L' UNION ALL
    SELECT 'unidade_medida', 'US_CM' UNION ALL
    SELECT 'unidade_medida', 'METRO' UNION ALL
    SELECT 'unidade_medida', 'METRO_CUBICO_SEG' UNION ALL
    SELECT 'unidade_medida', 'MILIMETRO' UNION ALL
    SELECT 'unidade_medida', 'METRO_SEG' UNION ALL
    SELECT 'parametro_monitoramento', 'TEMP_AGUA' UNION ALL
    SELECT 'parametro_monitoramento', 'PH' UNION ALL
    SELECT 'parametro_monitoramento', 'TURBIDEZ' UNION ALL
    SELECT 'parametro_monitoramento', 'OXIGENIO_DISSOLVIDO' UNION ALL
    SELECT 'parametro_monitoramento', 'CONDUTIVIDADE' UNION ALL
    SELECT 'parametro_monitoramento', 'NIVEL_AGUA' UNION ALL
    SELECT 'parametro_monitoramento', 'VAZAO' UNION ALL
    SELECT 'parametro_monitoramento', 'PRECIPITACAO' UNION ALL
    SELECT 'parametro_monitoramento', 'VELOCIDADE_AGUA' UNION ALL
    SELECT 'tipo_sensor', 'TERMOMETRO_AGUA' UNION ALL
    SELECT 'tipo_sensor', 'SENSOR_PH' UNION ALL
    SELECT 'tipo_sensor', 'TURBIDIMETRO' UNION ALL
    SELECT 'tipo_sensor', 'SENSOR_OD' UNION ALL
    SELECT 'tipo_sensor', 'CONDUTIVIMETRO' UNION ALL
    SELECT 'tipo_sensor', 'SENSOR_NIVEL' UNION ALL
    SELECT 'tipo_sensor', 'MEDIDOR_VAZAO' UNION ALL
    SELECT 'tipo_sensor', 'VELOCIMETRO_AGUA' UNION ALL
    SELECT 'tipo_sensor', 'PLUVIOMETRO' UNION ALL
    SELECT 'tipo_sensor', 'SONDA_MULTIPARAM'
),
`atuais` (`catalogo`, `codigo`) AS (
    SELECT 'tipo_corpo_hidrico', `codigo_tipo_corpo` FROM `tipo_corpo_hidrico` UNION ALL
    SELECT 'unidade_medida', `codigo` FROM `unidade_medida` UNION ALL
    SELECT 'parametro_monitoramento', `codigo` FROM `parametro_monitoramento` UNION ALL
    SELECT 'tipo_sensor', `codigo` FROM `tipo_sensor`
)
SELECT a.`catalogo`, a.`codigo`
FROM `atuais` a
LEFT JOIN `previstos` p
  ON p.`catalogo` = a.`catalogo`
 AND p.`codigo` = a.`codigo`
WHERE p.`codigo` IS NULL
ORDER BY a.`catalogo`, a.`codigo`;

-- 5. Nao deve retornar linhas: referencias quebradas ou catalogos inativos.
SELECT 'parametro_sem_unidade' AS `problema`, p.`codigo` AS `registro`
FROM `parametro_monitoramento` p
LEFT JOIN `unidade_medida` u ON u.`id_unidade` = p.`id_unidade`
WHERE u.`id_unidade` IS NULL
UNION ALL
SELECT 'tipo_sensor_parametro_sem_tipo', CAST(tsp.`id_tipo_sensor` AS CHAR)
FROM `tipo_sensor_parametro` tsp
LEFT JOIN `tipo_sensor` ts ON ts.`id_tipo_sensor` = tsp.`id_tipo_sensor`
WHERE ts.`id_tipo_sensor` IS NULL
UNION ALL
SELECT 'tipo_sensor_parametro_sem_parametro', CAST(tsp.`id_parametro` AS CHAR)
FROM `tipo_sensor_parametro` tsp
LEFT JOIN `parametro_monitoramento` p ON p.`id_parametro` = tsp.`id_parametro`
WHERE p.`id_parametro` IS NULL
UNION ALL
SELECT 'parametro_previsto_inativo', p.`codigo`
FROM `parametro_monitoramento` p
WHERE p.`codigo` IN ('TEMP_AGUA', 'PH', 'TURBIDEZ', 'OXIGENIO_DISSOLVIDO', 'CONDUTIVIDADE', 'NIVEL_AGUA', 'VAZAO', 'PRECIPITACAO', 'VELOCIDADE_AGUA')
  AND p.`ativo` <> 1
UNION ALL
SELECT 'tipo_sensor_previsto_inativo', ts.`codigo`
FROM `tipo_sensor` ts
WHERE ts.`codigo` IN ('TERMOMETRO_AGUA', 'SENSOR_PH', 'TURBIDIMETRO', 'SENSOR_OD', 'CONDUTIVIMETRO', 'SENSOR_NIVEL', 'MEDIDOR_VAZAO', 'VELOCIMETRO_AGUA', 'PLUVIOMETRO', 'SONDA_MULTIPARAM')
  AND ts.`ativo` <> 1;

-- 6. Nao deve retornar linhas: unidade ausente ou diferente da proposta.
WITH `unidades_previstas` (`parametro_codigo`, `unidade_codigo`) AS (
    SELECT 'TEMP_AGUA', 'GRAU_CELSIUS' UNION ALL
    SELECT 'PH', 'ADIMENSIONAL' UNION ALL
    SELECT 'TURBIDEZ', 'NTU' UNION ALL
    SELECT 'OXIGENIO_DISSOLVIDO', 'MG_L' UNION ALL
    SELECT 'CONDUTIVIDADE', 'US_CM' UNION ALL
    SELECT 'NIVEL_AGUA', 'METRO' UNION ALL
    SELECT 'VAZAO', 'METRO_CUBICO_SEG' UNION ALL
    SELECT 'PRECIPITACAO', 'MILIMETRO' UNION ALL
    SELECT 'VELOCIDADE_AGUA', 'METRO_SEG'
)
SELECT
    e.`parametro_codigo`,
    e.`unidade_codigo` AS `unidade_esperada`,
    COALESCE(u.`codigo`, '<ausente>') AS `unidade_atual`
FROM `unidades_previstas` e
LEFT JOIN `parametro_monitoramento` p ON p.`codigo` = e.`parametro_codigo`
LEFT JOIN `unidade_medida` u ON u.`id_unidade` = p.`id_unidade`
WHERE p.`id_parametro` IS NULL
   OR u.`codigo` <> e.`unidade_codigo`
ORDER BY e.`parametro_codigo`;

-- 7. Nao deve retornar linhas: capacidades previstas ausentes.
WITH `capacidades_previstas` (`tipo_codigo`, `parametro_codigo`) AS (
    SELECT 'TERMOMETRO_AGUA', 'TEMP_AGUA' UNION ALL
    SELECT 'SENSOR_PH', 'PH' UNION ALL
    SELECT 'TURBIDIMETRO', 'TURBIDEZ' UNION ALL
    SELECT 'SENSOR_OD', 'OXIGENIO_DISSOLVIDO' UNION ALL
    SELECT 'CONDUTIVIMETRO', 'CONDUTIVIDADE' UNION ALL
    SELECT 'SENSOR_NIVEL', 'NIVEL_AGUA' UNION ALL
    SELECT 'MEDIDOR_VAZAO', 'VAZAO' UNION ALL
    SELECT 'VELOCIMETRO_AGUA', 'VELOCIDADE_AGUA' UNION ALL
    SELECT 'PLUVIOMETRO', 'PRECIPITACAO' UNION ALL
    SELECT 'SONDA_MULTIPARAM', 'TEMP_AGUA' UNION ALL
    SELECT 'SONDA_MULTIPARAM', 'PH' UNION ALL
    SELECT 'SONDA_MULTIPARAM', 'TURBIDEZ' UNION ALL
    SELECT 'SONDA_MULTIPARAM', 'OXIGENIO_DISSOLVIDO' UNION ALL
    SELECT 'SONDA_MULTIPARAM', 'CONDUTIVIDADE'
),
`capacidades_atuais` (`tipo_codigo`, `parametro_codigo`) AS (
    SELECT ts.`codigo`, p.`codigo`
    FROM `tipo_sensor_parametro` tsp
    JOIN `tipo_sensor` ts ON ts.`id_tipo_sensor` = tsp.`id_tipo_sensor`
    JOIN `parametro_monitoramento` p ON p.`id_parametro` = tsp.`id_parametro`
)
SELECT e.`tipo_codigo`, e.`parametro_codigo`
FROM `capacidades_previstas` e
LEFT JOIN `capacidades_atuais` a
  ON a.`tipo_codigo` = e.`tipo_codigo`
 AND a.`parametro_codigo` = e.`parametro_codigo`
WHERE a.`tipo_codigo` IS NULL
ORDER BY e.`tipo_codigo`, e.`parametro_codigo`;

-- 8. Nao deve retornar linhas: capacidades adicionais nao aprovadas para os tipos propostos.
WITH `capacidades_previstas` (`tipo_codigo`, `parametro_codigo`) AS (
    SELECT 'TERMOMETRO_AGUA', 'TEMP_AGUA' UNION ALL
    SELECT 'SENSOR_PH', 'PH' UNION ALL
    SELECT 'TURBIDIMETRO', 'TURBIDEZ' UNION ALL
    SELECT 'SENSOR_OD', 'OXIGENIO_DISSOLVIDO' UNION ALL
    SELECT 'CONDUTIVIMETRO', 'CONDUTIVIDADE' UNION ALL
    SELECT 'SENSOR_NIVEL', 'NIVEL_AGUA' UNION ALL
    SELECT 'MEDIDOR_VAZAO', 'VAZAO' UNION ALL
    SELECT 'VELOCIMETRO_AGUA', 'VELOCIDADE_AGUA' UNION ALL
    SELECT 'PLUVIOMETRO', 'PRECIPITACAO' UNION ALL
    SELECT 'SONDA_MULTIPARAM', 'TEMP_AGUA' UNION ALL
    SELECT 'SONDA_MULTIPARAM', 'PH' UNION ALL
    SELECT 'SONDA_MULTIPARAM', 'TURBIDEZ' UNION ALL
    SELECT 'SONDA_MULTIPARAM', 'OXIGENIO_DISSOLVIDO' UNION ALL
    SELECT 'SONDA_MULTIPARAM', 'CONDUTIVIDADE'
)
SELECT ts.`codigo` AS `tipo_codigo`, p.`codigo` AS `parametro_codigo`
FROM `tipo_sensor_parametro` tsp
JOIN `tipo_sensor` ts ON ts.`id_tipo_sensor` = tsp.`id_tipo_sensor`
JOIN `parametro_monitoramento` p ON p.`id_parametro` = tsp.`id_parametro`
LEFT JOIN `capacidades_previstas` e
  ON e.`tipo_codigo` = ts.`codigo`
 AND e.`parametro_codigo` = p.`codigo`
WHERE ts.`codigo` IN ('TERMOMETRO_AGUA', 'SENSOR_PH', 'TURBIDIMETRO', 'SENSOR_OD', 'CONDUTIVIMETRO', 'SENSOR_NIVEL', 'MEDIDOR_VAZAO', 'VELOCIMETRO_AGUA', 'PLUVIOMETRO', 'SONDA_MULTIPARAM')
  AND e.`tipo_codigo` IS NULL
ORDER BY ts.`codigo`, p.`codigo`;

-- 9. Nao deve retornar linhas: tipo proposto sem qualquer parametro associado.
SELECT ts.`codigo`, ts.`nome`
FROM `tipo_sensor` ts
LEFT JOIN `tipo_sensor_parametro` tsp ON tsp.`id_tipo_sensor` = ts.`id_tipo_sensor`
WHERE ts.`codigo` IN ('TERMOMETRO_AGUA', 'SENSOR_PH', 'TURBIDIMETRO', 'SENSOR_OD', 'CONDUTIVIMETRO', 'SENSOR_NIVEL', 'MEDIDOR_VAZAO', 'VELOCIMETRO_AGUA', 'PLUVIOMETRO', 'SONDA_MULTIPARAM')
GROUP BY ts.`id_tipo_sensor`, ts.`codigo`, ts.`nome`
HAVING COUNT(tsp.`id_parametro`) = 0
ORDER BY ts.`codigo`;

-- 10. Previa legivel dos catalogos carregados.
SELECT `codigo_tipo_corpo`, `nome`
FROM `tipo_corpo_hidrico`
ORDER BY `codigo_tipo_corpo`;

SELECT `codigo`, `nome`, `simbolo`, `descricao`
FROM `unidade_medida`
ORDER BY `codigo`;

SELECT p.`codigo`, p.`nome`, u.`codigo` AS `unidade_codigo`, u.`simbolo`, p.`descricao`, p.`ativo`
FROM `parametro_monitoramento` p
JOIN `unidade_medida` u ON u.`id_unidade` = p.`id_unidade`
ORDER BY p.`codigo`;

SELECT ts.`codigo`, ts.`nome`, ts.`descricao`, ts.`ativo`
FROM `tipo_sensor` ts
ORDER BY ts.`codigo`;

SELECT ts.`codigo` AS `tipo_sensor_codigo`, p.`codigo` AS `parametro_codigo`
FROM `tipo_sensor_parametro` tsp
JOIN `tipo_sensor` ts ON ts.`id_tipo_sensor` = tsp.`id_tipo_sensor`
JOIN `parametro_monitoramento` p ON p.`id_parametro` = tsp.`id_parametro`
ORDER BY ts.`codigo`, p.`codigo`;
