# Plano de população futura — 50.000 registros MySQL

## Escopo

Este é apenas um plano. Nenhum dado foi inserido e nenhum gerador de massa foi implementado nesta etapa.

A meta é produzir exatamente **50.000 linhas relacionais** no MySQL, respeitando dependências, chaves, períodos e regras de negócio. Medições brutas, telemetria, logs e mensagens continuam no escopo futuro do MongoDB e não entram nesta contagem.

## Distribuição proposta

| Ordem | Tabela | Quantidade | Finalidade e justificativa | Dependências principais |
|---:|---|---:|---|---|
| 1 | `perfil` | 8 | Perfis administrativos e operacionais estáveis. | — |
| 2 | `permissao` | 30 | Catálogo de operações autorizáveis. | — |
| 3 | `usuario` | 150 | Equipe, operadores, gestores e contas de integração. | — |
| 4 | `perfil_permissao` | 100 | Cobertura variada de permissões por perfil. | `perfil`, `permissao` |
| 5 | `usuario_perfil` | 180 | Usuários com um ou mais perfis. | `usuario`, `perfil` |
| 6 | `orgao_responsavel` | 20 | Órgãos/entidades gestoras. | — |
| 7 | `bacia_hidrografica` | 60 | Recorte geográfico suficiente para consultas. | — |
| 8 | `tipo_corpo_hidrico` | 5 | Rio, reservatório e extensões aprovadas do catálogo. | — |
| 9 | `corpo_hidrico` | 240 | Quatro corpos por bacia, em média. | `bacia_hidrografica`, `tipo_corpo_hidrico` |
| 10 | `estacao_monitoramento` | 600 | Distribuição de estações por corpos e órgãos. | `corpo_hidrico`, `orgao_responsavel` |
| 11 | `unidade_medida` | 20 | Unidades canônicas, incluindo unidade adimensional. | — |
| 12 | `parametro_monitoramento` | 45 | Parâmetros ambientais e operacionais. | `unidade_medida` |
| 13 | `tipo_sensor` | 40 | Famílias de sensores mono e multiparâmetro. | — |
| 14 | `tipo_sensor_parametro` | 120 | Matriz de capacidades com média de três parâmetros por tipo. | `tipo_sensor`, `parametro_monitoramento` |
| 15 | `sensor` | 1.800 | Três equipamentos por estação, em média. | `tipo_sensor` |
| 16 | `instalacao_sensor` | 3.200 | Histórico de instalação, retirada e realocação. | `sensor`, `estacao_monitoramento`, `usuario` |
| 17 | `regra_monitoramento` | 1.200 | Regras em subconjunto representativo de estação/parâmetro. | `estacao_monitoramento`, `parametro_monitoramento` |
| 18 | `versao_regra_monitoramento` | 3.000 | Histórico com cerca de 2,5 versões por regra. | `regra_monitoramento`, `usuario` |
| 19 | `ocorrencia` | 2.500 | Casos operacionais independentes ou associados a alertas. | `usuario` |
| 20 | `ocorrencia_corpo_hidrico` | 2.200 | Associação de ocorrências ao contexto hídrico. | `ocorrencia`, `corpo_hidrico` |
| 21 | `ocorrencia_estacao` | 2.490 | Associação de ocorrências a estações. | `ocorrencia`, `estacao_monitoramento` |
| 22 | `ocorrencia_sensor` | 2.992 | Associação de ocorrências a equipamentos. | `ocorrencia`, `sensor` |
| 23 | `acao_ocorrencia` | 3.500 | Ações de tratamento e trilha operacional. | `ocorrencia`, `usuario` |
| 24 | `manutencao` | 3.500 | Inspeções, manutenções e calibrações. | `estacao_monitoramento`, `sensor`, `ocorrencia`, `usuario` |
| 25 | `calibracao_parametro` | 3.000 | Resultados por parâmetro para intervenções de calibração. | `manutencao`, `parametro_monitoramento` |
| 26 | `alerta` | 6.000 | Episódios com estados e tempos variados. | `versao_regra_monitoramento`, `usuario`, `ocorrencia` |
| 27 | `evidencia_alerta` | 8.000 | Uma ou mais leituras/evidências por alerta. | `alerta`, `versao_regra_monitoramento`, documentos MongoDB reais |
| 28 | `resumo_diario_monitoramento` | 2.500 | Amostra de consolidações por estação/parâmetro/dia. | `estacao_monitoramento`, `parametro_monitoramento`, medições MongoDB válidas |
| 29 | `evento_auditoria` | 1.500 | Operações críticas rastreáveis. | `usuario` |
| 30 | `detalhe_auditoria` | 1.000 | Atributos alterados em parte dos eventos. | `evento_auditoria` |
|  | **Total** | **50.000** |  |  |

## Fases de execução

### Fase A — catálogos e identidade

Carregar perfis, permissões, usuários, associações, órgãos, bacias, tipos, unidades e parâmetros. Usar códigos determinísticos e estáveis; senhas de contas locais devem receber hash apropriado, nunca texto simples.

### Fase B — topologia de monitoramento

Carregar corpos hídricos, estações, tipos/capacidades de sensores, sensores e instalações. Antes de inserir cada instalação, validar que o intervalo não sobrepõe outro período do mesmo sensor.

### Fase C — regras e operação

Carregar regras e versões sem vigências conflitantes; depois ocorrências, vínculos, ações e intervenções. Resultados de calibração só podem usar parâmetros suportados pelo tipo do sensor atendido.

### Fase D — integração com medições

Somente após existirem documentos MongoDB reais, criar alertas, evidências e resumos. Não gerar `id_documento_mongo` nem `id_leitura` fictícios. Cada referência deve ser reconciliada com uma leitura existente, sua instalação no instante da coleta e a versão de regra vigente.

### Fase E — auditoria e homologação

Registrar eventos/detalhes correspondentes às operações críticas simuladas, recalcular contagens e executar todas as verificações de integridade e desempenho.

## Estratégia de geração

- Fixar uma semente aleatória e versioná-la na configuração do gerador para tornar a carga reproduzível.
- Separar dados canônicos pequenos de dados sintéticos volumosos.
- Gerar chaves naturais únicas antes das chaves estrangeiras; não depender de ordem incidental de `AUTO_INCREMENT` entre ambientes.
- Manter um mapa de IDs por código de negócio durante a carga.
- Executar lotes idempotentes, com chave de execução e possibilidade de retomada.
- Usar transações por lote, registrando falhas sem continuar silenciosamente.
- Distribuir tempos em UTC e incluir casos de borda: períodos abertos, encerrados, realocações, leituras atrasadas e valores exatamente nos limites.
- Criar dados nulos apenas quando a ausência for legítima.
- Não desabilitar FKs ou validações para “fazer a carga passar”.

## Validações de aceite

1. A soma exata das 30 tabelas deve ser 50.000.
2. Nenhuma PK, FK ou chave única deve ser violada.
3. Não deve haver instalação ou vigência de regra sobreposta.
4. Não deve haver mais de um alerta ativo para o mesmo episódio definido.
5. Encerramentos de alerta devem conter instante, responsável e justificativa.
6. Manutenções devem ter alvo e intervalo válidos; calibrações devem respeitar capacidades do sensor.
7. Todos os instantes técnicos devem representar UTC.
8. Evidências e resumos devem ser reconciliáveis com documentos MongoDB reais e válidos.
9. Resumos devem usar apenas leituras válidas e ser recalculáveis sem duplicação.
10. A auditoria deve identificar usuário, instante, operação, alvo e mudanças críticas.
11. Consultas representativas devem ter seus planos e tempos registrados no ambiente de homologação.
12. O script `mysql/verification/002_verify_schema.sql` deve continuar sem divergências estruturais.

## Observação sobre volume

Esta distribuição exercita todas as tabelas relacionais, mas não representa a escala de produção das séries temporais. A avaliação volumétrica principal de medições, telemetria e logs deve ser feita no MongoDB com hipóteses explícitas de frequência por sensor, retenção e crescimento.
