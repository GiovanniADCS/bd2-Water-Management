-- Water Management - Etapa 2B
-- Populacao idempotente dos catalogos ambientais.
-- Compatibilidade alvo: MySQL 8.0.46.
--
-- IMPORTANTE: este script foi preparado para revisao humana.
-- Nao executar antes da aprovacao dos catalogos.
--
-- Escopo exclusivo:
--   tipo_corpo_hidrico
--   unidade_medida
--   parametro_monitoramento
--   tipo_sensor
--   tipo_sensor_parametro
--
-- O script nao exclui registros, nao desabilita FKs, nao altera a estrutura
-- e resolve todas as FKs por codigos de negocio, sem depender de IDs conhecidos.

SET NAMES utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE `recursos_hidricos`;

START TRANSACTION;

-- RF06: o dominio aprovado pelos requisitos possui apenas rios e reservatorios.
-- A insercao evita conflito com um nome preexistente sob outro codigo. A
-- atualizacao seguinte atua exclusivamente nos dois codigos aprovados.
INSERT INTO `tipo_corpo_hidrico` (`codigo_tipo_corpo`, `nome`)
SELECT 'RIO', 'Rio'
WHERE NOT EXISTS (
    SELECT 1 FROM `tipo_corpo_hidrico` WHERE `codigo_tipo_corpo` = 'RIO'
)
AND NOT EXISTS (
    SELECT 1 FROM `tipo_corpo_hidrico` WHERE `nome` = 'Rio'
);

INSERT INTO `tipo_corpo_hidrico` (`codigo_tipo_corpo`, `nome`)
SELECT 'RESERVATORIO', 'Reservatório'
WHERE NOT EXISTS (
    SELECT 1 FROM `tipo_corpo_hidrico` WHERE `codigo_tipo_corpo` = 'RESERVATORIO'
)
AND NOT EXISTS (
    SELECT 1 FROM `tipo_corpo_hidrico` WHERE `nome` = 'Reservatório'
);

UPDATE `tipo_corpo_hidrico`
SET `nome` = CASE `codigo_tipo_corpo`
    WHEN 'RIO' THEN 'Rio'
    WHEN 'RESERVATORIO' THEN 'Reservatório'
END
WHERE `codigo_tipo_corpo` IN ('RIO', 'RESERVATORIO');

-- Unidades canonicas necessarias para os parametros desta primeira carga.
-- O simbolo "1" representa corretamente uma grandeza adimensional.
INSERT INTO `unidade_medida` (`codigo`, `nome`, `simbolo`, `descricao`)
VALUES
    ('ADIMENSIONAL', 'Adimensional', '1', 'Grandeza sem dimensão física.'),
    ('GRAU_CELSIUS', 'Grau Celsius', '°C', 'Unidade canônica para temperatura da água.'),
    ('NTU', 'Unidade nefelométrica de turbidez', 'NTU', 'Unidade utilizada para expressar turbidez por resposta nefelométrica.'),
    ('MG_L', 'Miligrama por litro', 'mg/L', 'Unidade de concentração em massa por volume.'),
    ('US_CM', 'Microsiemens por centímetro', 'µS/cm', 'Unidade de condutividade elétrica.'),
    ('METRO', 'Metro', 'm', 'Unidade de comprimento utilizada para nível da água.'),
    ('METRO_CUBICO_SEG', 'Metro cúbico por segundo', 'm³/s', 'Unidade de vazão volumétrica.'),
    ('MILIMETRO', 'Milímetro', 'mm', 'Unidade de comprimento utilizada para precipitação acumulada.'),
    ('METRO_SEG', 'Metro por segundo', 'm/s', 'Unidade de velocidade da água.')
AS `novo`
ON DUPLICATE KEY UPDATE
    `nome` = `novo`.`nome`,
    `simbolo` = `novo`.`simbolo`,
    `descricao` = `novo`.`descricao`;

-- Parametros ambientais do primeiro catalogo.
INSERT INTO `parametro_monitoramento`
    (`codigo`, `nome`, `id_unidade`, `descricao`, `ativo`)
VALUES
    (
        'TEMP_AGUA',
        'Temperatura da água',
        (SELECT `id_unidade` FROM `unidade_medida` WHERE `codigo` = 'GRAU_CELSIUS'),
        'Temperatura da massa de água no ponto de monitoramento.',
        1
    ),
    (
        'PH',
        'pH',
        (SELECT `id_unidade` FROM `unidade_medida` WHERE `codigo` = 'ADIMENSIONAL'),
        'Grandeza adimensional utilizada para caracterizar a condição ácido-base da água.',
        1
    ),
    (
        'TURBIDEZ',
        'Turbidez',
        (SELECT `id_unidade` FROM `unidade_medida` WHERE `codigo` = 'NTU'),
        'Resposta nefelométrica associada à presença de partículas suspensas na água.',
        1
    ),
    (
        'OXIGENIO_DISSOLVIDO',
        'Oxigênio dissolvido',
        (SELECT `id_unidade` FROM `unidade_medida` WHERE `codigo` = 'MG_L'),
        'Concentração de oxigênio dissolvido na água.',
        1
    ),
    (
        'CONDUTIVIDADE',
        'Condutividade elétrica',
        (SELECT `id_unidade` FROM `unidade_medida` WHERE `codigo` = 'US_CM'),
        'Condutividade elétrica da água no ponto de monitoramento.',
        1
    ),
    (
        'NIVEL_AGUA',
        'Nível da água',
        (SELECT `id_unidade` FROM `unidade_medida` WHERE `codigo` = 'METRO'),
        'Altura da lâmina d''água em relação à referência definida para a estação.',
        1
    ),
    (
        'VAZAO',
        'Vazão',
        (SELECT `id_unidade` FROM `unidade_medida` WHERE `codigo` = 'METRO_CUBICO_SEG'),
        'Volume de água que atravessa a seção de referência por unidade de tempo.',
        1
    ),
    (
        'PRECIPITACAO',
        'Precipitação acumulada',
        (SELECT `id_unidade` FROM `unidade_medida` WHERE `codigo` = 'MILIMETRO'),
        'Precipitação acumulada no intervalo de observação da estação.',
        1
    ),
    (
        'VELOCIDADE_AGUA',
        'Velocidade da água',
        (SELECT `id_unidade` FROM `unidade_medida` WHERE `codigo` = 'METRO_SEG'),
        'Velocidade média da água na seção de monitoramento.',
        1
    )
AS `novo`
ON DUPLICATE KEY UPDATE
    `nome` = `novo`.`nome`,
    `id_unidade` = `novo`.`id_unidade`,
    `descricao` = `novo`.`descricao`,
    `ativo` = `novo`.`ativo`;

-- Tipos genericos, sem fabricante, modelo comercial ou especificacao proprietaria.
INSERT INTO `tipo_sensor` (`codigo`, `nome`, `descricao`, `ativo`)
VALUES
    ('TERMOMETRO_AGUA', 'Termômetro de água', 'Sensor de um parâmetro para temperatura da água.', 1),
    ('SENSOR_PH', 'Sensor de pH', 'Sensor eletroquímico genérico de um parâmetro para pH.', 1),
    ('TURBIDIMETRO', 'Turbidímetro', 'Sensor óptico genérico de um parâmetro para turbidez.', 1),
    ('SENSOR_OD', 'Sensor de oxigênio dissolvido', 'Sensor genérico de um parâmetro para oxigênio dissolvido.', 1),
    ('CONDUTIVIMETRO', 'Condutivímetro', 'Sensor genérico de um parâmetro para condutividade elétrica.', 1),
    ('SENSOR_NIVEL', 'Sensor de nível da água', 'Sensor hidrométrico genérico de um parâmetro para nível da água.', 1),
    ('MEDIDOR_VAZAO', 'Medidor de vazão', 'Instrumento hidrométrico genérico de um parâmetro para vazão.', 1),
    ('VELOCIMETRO_AGUA', 'Velocímetro de água', 'Instrumento hidrométrico genérico de um parâmetro para velocidade da água.', 1),
    ('PLUVIOMETRO', 'Pluviômetro', 'Sensor genérico de um parâmetro para precipitação acumulada.', 1),
    ('SONDA_MULTIPARAM', 'Sonda multiparâmetro de qualidade da água', 'Sonda genérica para temperatura, pH, turbidez, oxigênio dissolvido e condutividade.', 1)
AS `novo`
ON DUPLICATE KEY UPDATE
    `nome` = `novo`.`nome`,
    `descricao` = `novo`.`descricao`,
    `ativo` = `novo`.`ativo`;

-- Matriz de capacidades tecnicas. IDs sao resolvidos pelos codigos estaveis.
INSERT INTO `tipo_sensor_parametro` (`id_tipo_sensor`, `id_parametro`)
VALUES
    (
        (SELECT `id_tipo_sensor` FROM `tipo_sensor` WHERE `codigo` = 'TERMOMETRO_AGUA'),
        (SELECT `id_parametro` FROM `parametro_monitoramento` WHERE `codigo` = 'TEMP_AGUA')
    ),
    (
        (SELECT `id_tipo_sensor` FROM `tipo_sensor` WHERE `codigo` = 'SENSOR_PH'),
        (SELECT `id_parametro` FROM `parametro_monitoramento` WHERE `codigo` = 'PH')
    ),
    (
        (SELECT `id_tipo_sensor` FROM `tipo_sensor` WHERE `codigo` = 'TURBIDIMETRO'),
        (SELECT `id_parametro` FROM `parametro_monitoramento` WHERE `codigo` = 'TURBIDEZ')
    ),
    (
        (SELECT `id_tipo_sensor` FROM `tipo_sensor` WHERE `codigo` = 'SENSOR_OD'),
        (SELECT `id_parametro` FROM `parametro_monitoramento` WHERE `codigo` = 'OXIGENIO_DISSOLVIDO')
    ),
    (
        (SELECT `id_tipo_sensor` FROM `tipo_sensor` WHERE `codigo` = 'CONDUTIVIMETRO'),
        (SELECT `id_parametro` FROM `parametro_monitoramento` WHERE `codigo` = 'CONDUTIVIDADE')
    ),
    (
        (SELECT `id_tipo_sensor` FROM `tipo_sensor` WHERE `codigo` = 'SENSOR_NIVEL'),
        (SELECT `id_parametro` FROM `parametro_monitoramento` WHERE `codigo` = 'NIVEL_AGUA')
    ),
    (
        (SELECT `id_tipo_sensor` FROM `tipo_sensor` WHERE `codigo` = 'MEDIDOR_VAZAO'),
        (SELECT `id_parametro` FROM `parametro_monitoramento` WHERE `codigo` = 'VAZAO')
    ),
    (
        (SELECT `id_tipo_sensor` FROM `tipo_sensor` WHERE `codigo` = 'VELOCIMETRO_AGUA'),
        (SELECT `id_parametro` FROM `parametro_monitoramento` WHERE `codigo` = 'VELOCIDADE_AGUA')
    ),
    (
        (SELECT `id_tipo_sensor` FROM `tipo_sensor` WHERE `codigo` = 'PLUVIOMETRO'),
        (SELECT `id_parametro` FROM `parametro_monitoramento` WHERE `codigo` = 'PRECIPITACAO')
    ),
    (
        (SELECT `id_tipo_sensor` FROM `tipo_sensor` WHERE `codigo` = 'SONDA_MULTIPARAM'),
        (SELECT `id_parametro` FROM `parametro_monitoramento` WHERE `codigo` = 'TEMP_AGUA')
    ),
    (
        (SELECT `id_tipo_sensor` FROM `tipo_sensor` WHERE `codigo` = 'SONDA_MULTIPARAM'),
        (SELECT `id_parametro` FROM `parametro_monitoramento` WHERE `codigo` = 'PH')
    ),
    (
        (SELECT `id_tipo_sensor` FROM `tipo_sensor` WHERE `codigo` = 'SONDA_MULTIPARAM'),
        (SELECT `id_parametro` FROM `parametro_monitoramento` WHERE `codigo` = 'TURBIDEZ')
    ),
    (
        (SELECT `id_tipo_sensor` FROM `tipo_sensor` WHERE `codigo` = 'SONDA_MULTIPARAM'),
        (SELECT `id_parametro` FROM `parametro_monitoramento` WHERE `codigo` = 'OXIGENIO_DISSOLVIDO')
    ),
    (
        (SELECT `id_tipo_sensor` FROM `tipo_sensor` WHERE `codigo` = 'SONDA_MULTIPARAM'),
        (SELECT `id_parametro` FROM `parametro_monitoramento` WHERE `codigo` = 'CONDUTIVIDADE')
    )
AS `novo`
ON DUPLICATE KEY UPDATE
    `id_tipo_sensor` = `novo`.`id_tipo_sensor`,
    `id_parametro` = `novo`.`id_parametro`;

COMMIT;

