# Catálogos ambientais MySQL

## Escopo

Esta etapa prepara os catálogos mínimos de tipos de corpos hídricos, unidades, parâmetros ambientais, tipos genéricos de sensores e suas capacidades. Não inclui fabricantes, modelos comerciais, sensores físicos, estações, medições, alertas ou limites ambientais.

Os códigos de negócio são estáveis e escritos em ASCII. Nomes e descrições são apresentados em português brasileiro e armazenados com `utf8mb4`.

## Parâmetros e unidades canônicas

| Código | Parâmetro | Unidade | Símbolo | Observação técnica |
|---|---|---|---|---|
| `TEMP_AGUA` | Temperatura da água | Grau Celsius | `°C` | Temperatura da massa de água no ponto de monitoramento. |
| `PH` | pH | Adimensional | `1` | O pH é tratado como grandeza adimensional. A unidade explícita é necessária porque `id_unidade` é obrigatório no modelo. |
| `TURBIDEZ` | Turbidez | Unidade nefelométrica de turbidez | `NTU` | Representa a resposta nefelométrica associada a partículas suspensas. |
| `OXIGENIO_DISSOLVIDO` | Oxigênio dissolvido | Miligrama por litro | `mg/L` | Concentração de oxigênio dissolvido na água. |
| `CONDUTIVIDADE` | Condutividade elétrica | Microsiemens por centímetro | `µS/cm` | Condutividade elétrica da água no ponto de monitoramento. |
| `NIVEL_AGUA` | Nível da água | Metro | `m` | Altura relativa à referência definida para cada estação. |
| `VAZAO` | Vazão | Metro cúbico por segundo | `m³/s` | Volume de água por unidade de tempo. É distinta de velocidade. |
| `PRECIPITACAO` | Precipitação acumulada | Milímetro | `mm` | Toda medição futura deverá registrar ou permitir determinar o intervalo temporal de acumulação. |
| `VELOCIDADE_AGUA` | Velocidade da água | Metro por segundo | `m/s` | Deslocamento da água por unidade de tempo. Não é presumido como saída do medidor de vazão. |

Nenhum limite ou valor de referência regulatório é definido nesta etapa.

## Tipos de sensores e capacidades

Os tipos são genéricos e tecnicamente descritivos. Eles não representam fabricante, modelo, precisão, faixa de operação ou tecnologia proprietária.

- `TERMOMETRO_AGUA`: temperatura da água.
- `SENSOR_PH`: pH.
- `TURBIDIMETRO`: turbidez.
- `SENSOR_OD`: oxigênio dissolvido.
- `CONDUTIVIMETRO`: condutividade elétrica.
- `SENSOR_NIVEL`: nível da água.
- `MEDIDOR_VAZAO`: somente vazão.
- `VELOCIMETRO_AGUA`: somente velocidade da água.
- `PLUVIOMETRO`: precipitação acumulada.
- `SONDA_MULTIPARAM`: temperatura, pH, turbidez, oxigênio dissolvido e condutividade.

A sonda multiparâmetro representa uma categoria genérica plausível. A capacidade de um sensor físico futuro deverá ser determinada por seu tipo e não por uma suposição baseada no nome do equipamento.

## Idempotência e tratamento de registros existentes

O script de carga usa códigos de negócio para localizar as FKs e não pressupõe valores de `AUTO_INCREMENT`.

- Tipos de corpos hídricos: registros ausentes são inseridos e somente os códigos `RIO` e `RESERVATORIO` podem ter o nome atualizado. Um nome conflitante ligado a outro código não é alterado e será apontado pela validação.
- Unidades: uma segunda execução pode atualizar `nome`, `simbolo` e `descricao` dos nove códigos aprovados.
- Parâmetros: uma segunda execução pode atualizar `nome`, `id_unidade`, `descricao` e `ativo` dos nove códigos aprovados.
- Tipos de sensores: uma segunda execução pode atualizar `nome`, `descricao` e `ativo` dos dez códigos aprovados.
- Capacidades: o `ON DUPLICATE KEY UPDATE` é deliberadamente uma operação sem efeito, pois reaplica os mesmos dois IDs da chave primária composta.

Registros com outros códigos não são atualizados nem excluídos. O script de validação lista registros adicionais para revisão humana.

## Transação e falhas

Todas as operações usam tabelas InnoDB e são envolvidas por `START TRANSACTION` e `COMMIT`. No MySQL, um erro de uma instrução DML não garante sozinho o `ROLLBACK` automático de todas as instruções anteriores da transação.

Ao executar no MySQL Workbench, a opção **Stop Script Execution on Errors** deve permanecer ativa. Se ocorrer erro, não execute o `COMMIT`; execute `ROLLBACK;`, corrija a causa e reinicie o script completo. O banco principal só deve receber a carga depois da validação em schema isolado e da revisão humana deste catálogo.

## Registro da primeira carga oficial

- Data: 26/10/2026 (`America/Sao_Paulo`).
- Servidor: instância MySQL local, versão 8.0.46.
- Schema: `recursos_hidricos`.
- Script executado: `mysql/seed/001_seed_catalogos_ambientais.sql`.
- Script de validação: `mysql/verification/003_verify_catalogos_ambientais.sql`.
- Resultado: carga confirmada com `COMMIT`, sem erros ou avisos nas instruções do script de carga.

### Quantidades persistidas

| Tabela | Registros |
|---|---:|
| `tipo_corpo_hidrico` | 2 |
| `unidade_medida` | 9 |
| `parametro_monitoramento` | 9 |
| `tipo_sensor` | 10 |
| `tipo_sensor_parametro` | 14 |
| **Total** | **44** |

Antes da carga, as 30 tabelas do schema estavam vazias e `FOREIGN_KEY_CHECKS` estava ativo. Depois do `COMMIT`, uma contagem explícita das 30 tabelas confirmou 44 registros no schema e zero registros nas outras 25 tabelas.

### Validações executadas

O script de validação executou o resumo de quantidades e as consultas de:

- duplicidades de códigos e nomes;
- códigos previstos ausentes;
- códigos adicionais não previstos;
- referências ausentes e itens previstos inativos;
- unidades divergentes;
- capacidades de sensores ausentes;
- capacidades adicionais não previstas;
- tipos de sensores sem parâmetros associados;
- prévia completa dos cinco catálogos.

As oito consultas de anomalias retornaram zero linhas. As prévias retornaram, respectivamente, 2, 9, 9, 10 e 14 linhas. Não foram encontradas referências inválidas, unidades divergentes, duplicidades, capacidades incompatíveis ou registros adicionais.

### Reprodução do procedimento

1. Confirmar a conexão com a instância MySQL local e o schema `recursos_hidricos`.
2. Manter **Stop Script Execution on Errors** ativo no MySQL Workbench.
3. Confirmar que as cinco tabelas de destino estão vazias e que `FOREIGN_KEY_CHECKS = 1`.
4. Executar `mysql/seed/001_seed_catalogos_ambientais.sql` em uma única conexão.
5. Se qualquer instrução falhar, executar `ROLLBACK;` na mesma conexão e não repetir automaticamente a carga.
6. Executar `mysql/verification/003_verify_catalogos_ambientais.sql` e confirmar as contagens e a ausência de anomalias.

Durante esta execução foi tentada uma consulta auxiliar, externa aos dois scripts oficiais, com `@@in_transaction`. A instância respondeu com o erro 1193 porque essa variável não está disponível nessa configuração. A consulta era somente leitura, não alterou dados e não afetou a carga, as contagens, o `COMMIT` ou as validações oficiais.
