# Water Management — Banco de Dados II

Modelo e documentação de um sistema de monitoramento e gestão de recursos hídricos com MySQL para dados relacionais e MongoDB para dados de séries temporais e estrutura variável.

## Banco de Dados MySQL

O MySQL mantém a parte relacional do sistema de monitoramento e gestão de recursos hídricos. A arquitetura prevê que dados de séries temporais e de estrutura variável sejam tratados futuramente no MongoDB, sem misturá-los à estrutura relacional desta etapa.

O schema `recursos_hidricos` possui 30 tabelas InnoDB. Os artefatos disponíveis são:

- Modelo físico: `docs/modelagem/modelagem.mwb`
- DDL de reconstrução: `mysql/ddl/001_create_schema.sql`
- Export SQL portátil: `mysql/exports/recursos_hidricos_schema.sql`
- Verificação estrutural: `mysql/verification/002_verify_schema.sql`
- Tutorial de instalação e importação: `mysql/docs/COMO_IMPORTAR_MYSQL.md`
- Relatório de reconstrução: `mysql/docs/RECONSTRUCAO_MYSQL.md`
- Plano futuro de 50.000 registros: `mysql/docs/PLANO_POPULACAO_50000.md`

O DDL e o export criam somente a estrutura do schema, sem registros e sem operações de exclusão. O banco está inicialmente vazio; a população planejada de 50.000 registros será realizada em etapas posteriores.
