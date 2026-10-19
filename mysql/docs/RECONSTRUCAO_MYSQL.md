# Reconstrução e validação do MySQL

## Resultado

O schema `recursos_hidricos` foi reconstruído localmente a partir do modelo `docs/modelagem/modelagem.mwb`, sem alterar o arquivo `.mwb`. Antes da execução, o schema não existia no servidor local. A engenharia direta foi executada no MySQL Workbench sem opções de exclusão e terminou com sucesso.

Validação realizada em 19/10/2026:

| Item | Resultado |
|---|---:|
| MySQL Server | 8.0.46 |
| MySQL Workbench | 8.0.47 |
| Tabelas base | 30 |
| Tabelas com chave primária | 30 |
| Chaves estrangeiras | 48 |
| Restrições únicas, além das PKs | 15 |
| Restrições `CHECK` | 0 |
| Tabelas fora de InnoDB | 0 |
| Views | 0 |
| Triggers | 0 |
| Linhas após a reconstrução | 0 |
| Charset/collation | `utf8mb4` / `utf8mb4_0900_ai_ci` |
| Fuso da sessão validada | `SYSTEM` — não garante UTC |

O DDL salvo contém 30 comandos `CREATE TABLE`, nenhum `DROP` e nenhum `INSERT`. Portanto, a reconstrução criou somente a estrutura solicitada e manteve todas as tabelas vazias.

## Fontes de verdade usadas

- Modelo físico: `docs/modelagem/modelagem.mwb`.
- Requisitos: `docs/requisitos/Levantamento de requisitos - Grupo 4.pdf`.
- DDL reproduzível: `mysql/ddl/001_create_schema.sql`.
- Verificação somente leitura: `mysql/verification/002_verify_schema.sql`.

O modelo contém dois schemas: `mydb`, vazio, e `recursos_hidricos`, com os 30 objetos de negócio. Somente `recursos_hidricos` foi materializado pelo DDL.

## Tabelas reconstruídas

| Domínio | Tabelas |
|---|---|
| Acesso | `usuario`, `perfil`, `permissao`, `usuario_perfil`, `perfil_permissao` |
| Recursos hídricos | `orgao_responsavel`, `bacia_hidrografica`, `tipo_corpo_hidrico`, `corpo_hidrico`, `estacao_monitoramento` |
| Sensores e parâmetros | `unidade_medida`, `parametro_monitoramento`, `tipo_sensor`, `tipo_sensor_parametro`, `sensor`, `instalacao_sensor` |
| Regras e alertas | `regra_monitoramento`, `versao_regra_monitoramento`, `alerta`, `evidencia_alerta` |
| Ocorrências | `ocorrencia`, `ocorrencia_corpo_hidrico`, `ocorrencia_estacao`, `ocorrencia_sensor`, `acao_ocorrencia` |
| Intervenções | `manutencao`, `calibracao_parametro` |
| Derivados e auditoria | `resumo_diario_monitoramento`, `evento_auditoria`, `detalhe_auditoria` |

## Como reconstruir

### Pelo MySQL Workbench

1. Conecte-se a um servidor MySQL 8.0 com uma conta autorizada a criar schemas e tabelas.
2. Abra `mysql/ddl/001_create_schema.sql`.
3. Revise o servidor de destino e execute o script inteiro.
4. Abra `mysql/verification/002_verify_schema.sql` e execute-o.
5. Confirme 30 tabelas, 30 PKs, 48 FKs, 15 restrições únicas e nenhuma divergência de nomes.

### Pela linha de comando

```powershell
mysql --host localhost --port 3306 --user SEU_USUARIO --password --execute="SOURCE mysql/ddl/001_create_schema.sql"
mysql --host localhost --port 3306 --user SEU_USUARIO --password --execute="SOURCE mysql/verification/002_verify_schema.sql"
```

Não coloque senhas nos scripts, no repositório ou no histórico do shell. Em automação, prefira um cofre de segredos ou um login configurado fora do repositório.

O DDL usa `CREATE ... IF NOT EXISTS`. Isso o torna seguro para uma primeira reconstrução, mas não é um mecanismo de migração: ele não altera tabelas existentes que tenham uma definição antiga. Para evoluções, devem ser criadas migrações versionadas e testadas.

## Cobertura dos requisitos

A estrutura cobre os principais grupos relacionais: usuários/perfis/permissões; órgãos, bacias, corpos hídricos e estações; tipos, sensores, parâmetros e histórico de instalação; regras versionadas; alertas e evidências; ocorrências e ações; manutenção/calibração; resumo diário; e auditoria.

As medições brutas, séries temporais, telemetria, logs e mensagens de equipamentos permanecem fora do MySQL, conforme o escopo previsto para MongoDB. A tabela `evidencia_alerta` contém apenas as referências de integração (`id_documento_mongo` e `id_leitura`); nenhum identificador fictício foi criado.

## Divergências e controles ainda necessários

As observações abaixo comparam o modelo físico com os requisitos. Elas foram documentadas, não corrigidas automaticamente, para preservar o `.mwb` como fonte de verdade.

| Prioridade | Lacuna estrutural | Impacto / requisito relacionado | Tratamento recomendado |
|---|---|---|---|
| Alta | `instalacao_sensor` só impede a repetição de `(id_sensor, inicio_em)`; períodos diferentes ainda podem se sobrepor. | RF10 e RNF22. | Validar em transação com bloqueio por sensor ou criar trigger/procedimento aprovado; testar concorrência. |
| Alta | `versao_regra_monitoramento` não impede vigências sobrepostas para a mesma regra. | RF21 e RNF22. | Validar intervalos em transação/trigger e indexar a busca por regra e vigência. |
| Alta | Não há garantia de apenas um alerta aberto por regra/contexto. | RF23 e RNF22. | Definir a chave do episódio ativo e aplicar controle transacional/idempotente; considerar coluna gerada e índice único quando a regra estiver fechada. |
| Alta | Não existem `CHECK`s para consistência temporal, limites, estados ou alvos. | RNF14 e RNF19. | Acrescentar em migração: `fim_em >= inicio_em`, limite inferior/superior coerentes, flags 0/1, latitude/longitude válidas e domínios enumerados. |
| Alta | `alerta.motivo_encerramento` é opcional e não há validação condicional entre instante, usuário e motivo de encerramento; o mesmo vale para reconhecimento. | RF24. | Criar validações condicionais no banco e na aplicação. |
| Alta | `manutencao` permite estação e sensor ambos nulos ou ambos preenchidos; também não garante `fim_em >= inicio_em`. | RF28 e RNF14. | Definir se o alvo é exatamente um ou pelo menos um e aplicar `CHECK`; validar o período. |
| Alta | A compatibilidade do parâmetro calibrado com o tipo do sensor não é garantida por FK. | RF29. | Validar pelo caminho manutenção → sensor → tipo → `tipo_sensor_parametro`, com regra transacional. |
| Média | A situação operacional de estação/sensor está reduzida à flag `ativo`; não há histórico de estados ou de mudança de localização/vínculo. | RF08, RF09 e RNF16. | Definir catálogo de estados e, se necessário, tabelas de vigência/histórico. |
| Média | Datas técnicas usam `DATETIME(3)`, que não carrega fuso. Só `dia_utc` explicita UTC no nome; a sessão validada retornou `SYSTEM`. | RNF13. | Fixar conexões e jobs em UTC (`SET time_zone = '+00:00'`), validar a sessão e documentar conversões na borda. |
| Média | Tabelas de auditoria existem, mas não há trigger/rotina que garanta sua gravação. | RF03, RNF08. | Definir quais operações serão auditadas pela aplicação ou por triggers e criar testes de completude. |
| Média | O resumo diário não guarda referência direta às medições MongoDB usadas no cálculo. | RF35 e RNF23. | Manter metadados de versão/lote de consolidação e trilha de reconciliação no desenho de integração. |
| Média | `senha_hash` é anulável e não há regra condicional ligada a `tipo_identidade`. | RNF06 e RNF19. | Documentar identidades locais/federadas e exigir hash para a modalidade local. |
| Baixa | `numero_serie` não é único; somente `codigo_patrimonial` é chave de negócio única do sensor. | RNF18. | Confirmar se número de série é chave global, por fabricante/modelo ou apenas informativo. |

Outros pontos a confirmar na próxima revisão do modelo:

- parâmetros adimensionais exigem uma unidade canônica explícita, pois `id_unidade` é obrigatório;
- exclusões históricas ficam protegidas pelas FKs com comportamento restritivo padrão, mas a política de desativação deve ser formalizada por entidade;
- os domínios de `prioridade`, `tipo_intervencao`, `origem`, `operacao` e `tipo_identidade` ainda dependem de convenções externas;
- índices adicionais só devem ser definidos após medir os padrões reais de consulta e carga.

## Validação futura após carga

Depois da população planejada, repita o script de verificação e acrescente testes de dados para:

- ausência de instalações e vigências sobrepostas;
- coerência dos ciclos de alerta, ocorrência e manutenção;
- compatibilidade sensor/parâmetro;
- datas em UTC e intervalos válidos;
- referências MongoDB existentes, sem IDs fabricados;
- cardinalidades e distribuição dos dados;
- planos de execução das consultas críticas.
