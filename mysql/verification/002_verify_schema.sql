-- Verificacao estrutural do schema recursos_hidricos.
-- Compatibilidade validada: MySQL 8.0.46.
-- Este script e somente leitura: nao cria, altera, exclui nem popula objetos.

SET @schema_alvo := 'recursos_hidricos';

-- 1. Resumo do ambiente e do catalogo.
SELECT
    VERSION() AS mysql_version,
    @@session.time_zone AS session_time_zone,
    s.default_character_set_name AS schema_charset,
    s.default_collation_name AS schema_collation,
    (SELECT COUNT(*)
       FROM information_schema.tables t
      WHERE t.table_schema = @schema_alvo
        AND t.table_type = 'BASE TABLE') AS tabelas,
    (SELECT COUNT(*)
       FROM information_schema.table_constraints tc
      WHERE tc.constraint_schema = @schema_alvo
        AND tc.constraint_type = 'PRIMARY KEY') AS chaves_primarias,
    (SELECT COUNT(*)
       FROM information_schema.referential_constraints rc
      WHERE rc.constraint_schema = @schema_alvo) AS chaves_estrangeiras,
    (SELECT COUNT(*)
       FROM information_schema.table_constraints tc
      WHERE tc.constraint_schema = @schema_alvo
        AND tc.constraint_type = 'UNIQUE') AS restricoes_unicas,
    (SELECT COUNT(*)
       FROM information_schema.table_constraints tc
      WHERE tc.constraint_schema = @schema_alvo
        AND tc.constraint_type = 'CHECK') AS restricoes_check,
    (SELECT COUNT(*)
       FROM information_schema.views v
      WHERE v.table_schema = @schema_alvo) AS views,
    (SELECT COUNT(*)
       FROM information_schema.triggers tr
      WHERE tr.trigger_schema = @schema_alvo) AS triggers,
    (SELECT COUNT(*)
       FROM information_schema.routines r
      WHERE r.routine_schema = @schema_alvo) AS rotinas
FROM information_schema.schemata s
WHERE s.schema_name = @schema_alvo;

-- Resultado esperado: exatamente 30 tabelas e nenhuma divergencia de nome.
WITH expected (table_name) AS (
    SELECT 'acao_ocorrencia' UNION ALL
    SELECT 'alerta' UNION ALL
    SELECT 'bacia_hidrografica' UNION ALL
    SELECT 'calibracao_parametro' UNION ALL
    SELECT 'corpo_hidrico' UNION ALL
    SELECT 'detalhe_auditoria' UNION ALL
    SELECT 'estacao_monitoramento' UNION ALL
    SELECT 'evento_auditoria' UNION ALL
    SELECT 'evidencia_alerta' UNION ALL
    SELECT 'instalacao_sensor' UNION ALL
    SELECT 'manutencao' UNION ALL
    SELECT 'ocorrencia' UNION ALL
    SELECT 'ocorrencia_corpo_hidrico' UNION ALL
    SELECT 'ocorrencia_estacao' UNION ALL
    SELECT 'ocorrencia_sensor' UNION ALL
    SELECT 'orgao_responsavel' UNION ALL
    SELECT 'parametro_monitoramento' UNION ALL
    SELECT 'perfil' UNION ALL
    SELECT 'perfil_permissao' UNION ALL
    SELECT 'permissao' UNION ALL
    SELECT 'regra_monitoramento' UNION ALL
    SELECT 'resumo_diario_monitoramento' UNION ALL
    SELECT 'sensor' UNION ALL
    SELECT 'tipo_corpo_hidrico' UNION ALL
    SELECT 'tipo_sensor' UNION ALL
    SELECT 'tipo_sensor_parametro' UNION ALL
    SELECT 'unidade_medida' UNION ALL
    SELECT 'usuario' UNION ALL
    SELECT 'usuario_perfil' UNION ALL
    SELECT 'versao_regra_monitoramento'
), actual AS (
    SELECT t.table_name
      FROM information_schema.tables t
     WHERE t.table_schema = @schema_alvo
       AND t.table_type = 'BASE TABLE'
)
SELECT 'AUSENTE' AS divergencia, e.table_name
  FROM expected e
  LEFT JOIN actual a ON a.table_name = e.table_name
 WHERE a.table_name IS NULL
UNION ALL
SELECT 'NAO_PREVISTA' AS divergencia, a.table_name
  FROM actual a
  LEFT JOIN expected e ON e.table_name = a.table_name
 WHERE e.table_name IS NULL
ORDER BY divergencia, table_name;

-- 2. Tabelas, engines, collations e estimativa de linhas.
SELECT
    t.table_name,
    t.engine,
    t.table_collation,
    t.table_rows AS linhas_estimadas
FROM information_schema.tables t
WHERE t.table_schema = @schema_alvo
  AND t.table_type = 'BASE TABLE'
ORDER BY t.table_name;

-- Nao deve retornar linhas: todas as tabelas devem ser InnoDB/utf8mb4_0900_ai_ci.
SELECT
    t.table_name,
    t.engine,
    t.table_collation
FROM information_schema.tables t
WHERE t.table_schema = @schema_alvo
  AND t.table_type = 'BASE TABLE'
  AND (t.engine <> 'InnoDB' OR t.table_collation <> 'utf8mb4_0900_ai_ci')
ORDER BY t.table_name;

-- 3. Colunas e nulabilidade (dicionario executavel do catalogo).
SELECT
    c.table_name,
    c.ordinal_position,
    c.column_name,
    c.column_type,
    c.is_nullable,
    c.column_default,
    c.extra,
    c.character_set_name,
    c.collation_name
FROM information_schema.columns c
WHERE c.table_schema = @schema_alvo
ORDER BY c.table_name, c.ordinal_position;

-- 4. Chaves primarias, unicas e estrangeiras.
SELECT
    tc.table_name,
    tc.constraint_name,
    tc.constraint_type,
    GROUP_CONCAT(kcu.column_name ORDER BY kcu.ordinal_position SEPARATOR ', ') AS colunas
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
  ON kcu.constraint_schema = tc.constraint_schema
 AND kcu.table_name = tc.table_name
 AND kcu.constraint_name = tc.constraint_name
WHERE tc.constraint_schema = @schema_alvo
GROUP BY tc.table_name, tc.constraint_name, tc.constraint_type
ORDER BY tc.table_name, tc.constraint_type, tc.constraint_name;

SELECT
    kcu.table_name,
    kcu.constraint_name,
    GROUP_CONCAT(kcu.column_name ORDER BY kcu.ordinal_position SEPARATOR ', ') AS colunas_fk,
    kcu.referenced_table_name,
    GROUP_CONCAT(kcu.referenced_column_name ORDER BY kcu.ordinal_position SEPARATOR ', ') AS colunas_referenciadas,
    rc.update_rule,
    rc.delete_rule
FROM information_schema.key_column_usage kcu
JOIN information_schema.referential_constraints rc
  ON rc.constraint_schema = kcu.constraint_schema
 AND rc.constraint_name = kcu.constraint_name
WHERE kcu.constraint_schema = @schema_alvo
  AND kcu.referenced_table_name IS NOT NULL
GROUP BY
    kcu.table_name,
    kcu.constraint_name,
    kcu.referenced_table_name,
    rc.update_rule,
    rc.delete_rule
ORDER BY kcu.table_name, kcu.constraint_name;

-- Nao deve retornar linhas: todas as 30 tabelas devem possuir chave primaria.
SELECT t.table_name
FROM information_schema.tables t
LEFT JOIN information_schema.table_constraints tc
  ON tc.constraint_schema = t.table_schema
 AND tc.table_name = t.table_name
 AND tc.constraint_type = 'PRIMARY KEY'
WHERE t.table_schema = @schema_alvo
  AND t.table_type = 'BASE TABLE'
  AND tc.constraint_name IS NULL
ORDER BY t.table_name;

-- 5. Indices, inclusive os indices de apoio das FKs.
SELECT
    s.table_name,
    s.index_name,
    CASE s.non_unique WHEN 0 THEN 'UNIQUE' ELSE 'NON_UNIQUE' END AS tipo,
    GROUP_CONCAT(s.column_name ORDER BY s.seq_in_index SEPARATOR ', ') AS colunas
FROM information_schema.statistics s
WHERE s.table_schema = @schema_alvo
GROUP BY s.table_name, s.index_name, s.non_unique
ORDER BY s.table_name, s.index_name;

-- 6. Contagem exata: apos a reconstrucao inicial, todas devem retornar zero.
SELECT 'acao_ocorrencia' AS tabela, COUNT(*) AS linhas FROM recursos_hidricos.acao_ocorrencia UNION ALL
SELECT 'alerta', COUNT(*) FROM recursos_hidricos.alerta UNION ALL
SELECT 'bacia_hidrografica', COUNT(*) FROM recursos_hidricos.bacia_hidrografica UNION ALL
SELECT 'calibracao_parametro', COUNT(*) FROM recursos_hidricos.calibracao_parametro UNION ALL
SELECT 'corpo_hidrico', COUNT(*) FROM recursos_hidricos.corpo_hidrico UNION ALL
SELECT 'detalhe_auditoria', COUNT(*) FROM recursos_hidricos.detalhe_auditoria UNION ALL
SELECT 'estacao_monitoramento', COUNT(*) FROM recursos_hidricos.estacao_monitoramento UNION ALL
SELECT 'evento_auditoria', COUNT(*) FROM recursos_hidricos.evento_auditoria UNION ALL
SELECT 'evidencia_alerta', COUNT(*) FROM recursos_hidricos.evidencia_alerta UNION ALL
SELECT 'instalacao_sensor', COUNT(*) FROM recursos_hidricos.instalacao_sensor UNION ALL
SELECT 'manutencao', COUNT(*) FROM recursos_hidricos.manutencao UNION ALL
SELECT 'ocorrencia', COUNT(*) FROM recursos_hidricos.ocorrencia UNION ALL
SELECT 'ocorrencia_corpo_hidrico', COUNT(*) FROM recursos_hidricos.ocorrencia_corpo_hidrico UNION ALL
SELECT 'ocorrencia_estacao', COUNT(*) FROM recursos_hidricos.ocorrencia_estacao UNION ALL
SELECT 'ocorrencia_sensor', COUNT(*) FROM recursos_hidricos.ocorrencia_sensor UNION ALL
SELECT 'orgao_responsavel', COUNT(*) FROM recursos_hidricos.orgao_responsavel UNION ALL
SELECT 'parametro_monitoramento', COUNT(*) FROM recursos_hidricos.parametro_monitoramento UNION ALL
SELECT 'perfil', COUNT(*) FROM recursos_hidricos.perfil UNION ALL
SELECT 'perfil_permissao', COUNT(*) FROM recursos_hidricos.perfil_permissao UNION ALL
SELECT 'permissao', COUNT(*) FROM recursos_hidricos.permissao UNION ALL
SELECT 'regra_monitoramento', COUNT(*) FROM recursos_hidricos.regra_monitoramento UNION ALL
SELECT 'resumo_diario_monitoramento', COUNT(*) FROM recursos_hidricos.resumo_diario_monitoramento UNION ALL
SELECT 'sensor', COUNT(*) FROM recursos_hidricos.sensor UNION ALL
SELECT 'tipo_corpo_hidrico', COUNT(*) FROM recursos_hidricos.tipo_corpo_hidrico UNION ALL
SELECT 'tipo_sensor', COUNT(*) FROM recursos_hidricos.tipo_sensor UNION ALL
SELECT 'tipo_sensor_parametro', COUNT(*) FROM recursos_hidricos.tipo_sensor_parametro UNION ALL
SELECT 'unidade_medida', COUNT(*) FROM recursos_hidricos.unidade_medida UNION ALL
SELECT 'usuario', COUNT(*) FROM recursos_hidricos.usuario UNION ALL
SELECT 'usuario_perfil', COUNT(*) FROM recursos_hidricos.usuario_perfil UNION ALL
SELECT 'versao_regra_monitoramento', COUNT(*) FROM recursos_hidricos.versao_regra_monitoramento
ORDER BY tabela;
