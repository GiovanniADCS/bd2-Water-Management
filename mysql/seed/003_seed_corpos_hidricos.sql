-- Water Management - Corpos hidricos do Vale Sereno
-- Carga idempotente de 24 corpos hidricos ficticios.
-- Compatibilidade alvo: MySQL 8.0.46.
--
-- Distribuicao aprovada:
--   6 bacias x (3 rios + 1 reservatorio) = 24 corpos hidricos.
--
-- O script resolve id_bacia por bacia_hidrografica.codigo e utiliza os codigos
-- de negocio RIO e RESERVATORIO. Nenhum ID AUTO_INCREMENT e presumido.

SET NAMES utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE `recursos_hidricos`;

START TRANSACTION;

INSERT INTO `corpo_hidrico`
    (`codigo`, `nome`, `id_bacia`, `codigo_tipo_corpo`, `descricao`, `ativo`)
VALUES
    -- Bacia do Alto Cedro
    (
        'AC_RES_MIRANTE', 'Reservatório do Mirante',
        (SELECT `id_bacia` FROM `bacia_hidrografica` WHERE `codigo` = 'BVS_ALTO_CEDRO'),
        'RESERVATORIO',
        'Reservatório fictício de regularização hídrica nas cabeceiras da Bacia do Alto Cedro.', 1
    ),
    (
        'AC_RIO_BRUMA', 'Rio da Bruma',
        (SELECT `id_bacia` FROM `bacia_hidrografica` WHERE `codigo` = 'BVS_ALTO_CEDRO'),
        'RIO',
        'Curso d''água fictício de cabeceira com trechos sombreados e pequena planície aluvial.', 1
    ),
    (
        'AC_RIO_CEDRO', 'Rio Cedro',
        (SELECT `id_bacia` FROM `bacia_hidrografica` WHERE `codigo` = 'BVS_ALTO_CEDRO'),
        'RIO',
        'Curso principal fictício da Bacia do Alto Cedro, com direção predominante para sudeste.', 1
    ),
    (
        'AC_RIO_FIGUEIRA', 'Rio Figueira',
        (SELECT `id_bacia` FROM `bacia_hidrografica` WHERE `codigo` = 'BVS_ALTO_CEDRO'),
        'RIO',
        'Afluente fictício do Rio Cedro, de leito estreito e margens vegetadas.', 1
    ),

    -- Bacia do Baixo Vale
    (
        'BV_RES_FOZ_SERENA', 'Reservatório Foz Serena',
        (SELECT `id_bacia` FROM `bacia_hidrografica` WHERE `codigo` = 'BVS_BAIXO_VALE'),
        'RESERVATORIO',
        'Reservatório fictício próximo à convergência dos cursos do Baixo Vale.', 1
    ),
    (
        'BV_RIO_ESTRELA', 'Rio Estrela',
        (SELECT `id_bacia` FROM `bacia_hidrografica` WHERE `codigo` = 'BVS_BAIXO_VALE'),
        'RIO',
        'Curso d''água fictício de planície que recebe afluentes da porção leste da bacia.', 1
    ),
    (
        'BV_RIO_VALE', 'Rio do Vale',
        (SELECT `id_bacia` FROM `bacia_hidrografica` WHERE `codigo` = 'BVS_BAIXO_VALE'),
        'RIO',
        'Curso principal fictício do Baixo Vale, com canal amplo e baixa declividade.', 1
    ),
    (
        'BV_RIO_VENTANIA', 'Rio Ventania',
        (SELECT `id_bacia` FROM `bacia_hidrografica` WHERE `codigo` = 'BVS_BAIXO_VALE'),
        'RIO',
        'Afluente fictício proveniente de colinas abertas na margem sul da bacia.', 1
    ),

    -- Bacia do Campo Verde
    (
        'CV_RES_PLANICIE', 'Reservatório da Planície',
        (SELECT `id_bacia` FROM `bacia_hidrografica` WHERE `codigo` = 'BVS_CAMPO_VERDE'),
        'RESERVATORIO',
        'Reservatório fictício raso, inserido na planície central da Bacia do Campo Verde.', 1
    ),
    (
        'CV_RIO_CAMPO', 'Rio do Campo',
        (SELECT `id_bacia` FROM `bacia_hidrografica` WHERE `codigo` = 'BVS_CAMPO_VERDE'),
        'RIO',
        'Curso principal fictício que atravessa a faixa central de relevo suave da bacia.', 1
    ),
    (
        'CV_RIO_CAPIM', 'Rio Capim-Dourado',
        (SELECT `id_bacia` FROM `bacia_hidrografica` WHERE `codigo` = 'BVS_CAMPO_VERDE'),
        'RIO',
        'Afluente fictício associado a campos úmidos sazonais e vegetação rasteira.', 1
    ),
    (
        'CV_RIO_VEREDA', 'Rio da Vereda',
        (SELECT `id_bacia` FROM `bacia_hidrografica` WHERE `codigo` = 'BVS_CAMPO_VERDE'),
        'RIO',
        'Curso d''água fictício de baixa velocidade que percorre áreas de vereda.', 1
    ),

    -- Bacia da Lagoa Serena
    (
        'LS_RES_AGUAS_CALMAS', 'Reservatório Águas Calmas',
        (SELECT `id_bacia` FROM `bacia_hidrografica` WHERE `codigo` = 'BVS_LAGOA_SERENA'),
        'RESERVATORIO',
        'Reservatório fictício conectado a áreas úmidas e lagoas marginais da bacia.', 1
    ),
    (
        'LS_RIO_JUNCO', 'Rio do Junco',
        (SELECT `id_bacia` FROM `bacia_hidrografica` WHERE `codigo` = 'BVS_LAGOA_SERENA'),
        'RIO',
        'Curso d''água fictício de baixa declividade com margens ocupadas por juncais.', 1
    ),
    (
        'LS_RIO_LIRIO', 'Rio dos Lírios',
        (SELECT `id_bacia` FROM `bacia_hidrografica` WHERE `codigo` = 'BVS_LAGOA_SERENA'),
        'RIO',
        'Afluente fictício associado a lagoas sazonais e vegetação aquática.', 1
    ),
    (
        'LS_RIO_SALGUEIRO', 'Rio Salgueiro',
        (SELECT `id_bacia` FROM `bacia_hidrografica` WHERE `codigo` = 'BVS_LAGOA_SERENA'),
        'RIO',
        'Curso principal fictício da Bacia da Lagoa Serena, com fluxo lento e margens baixas.', 1
    ),

    -- Bacia da Pedra Clara
    (
        'PC_RES_HORIZONTE', 'Reservatório Horizonte',
        (SELECT `id_bacia` FROM `bacia_hidrografica` WHERE `codigo` = 'BVS_PEDRA_CLARA'),
        'RESERVATORIO',
        'Reservatório fictício encaixado entre formações rochosas da Bacia da Pedra Clara.', 1
    ),
    (
        'PC_RIO_AROEIRA', 'Rio Aroeira',
        (SELECT `id_bacia` FROM `bacia_hidrografica` WHERE `codigo` = 'BVS_PEDRA_CLARA'),
        'RIO',
        'Afluente fictício de leito pedregoso e vegetação ripária descontínua.', 1
    ),
    (
        'PC_RIO_CRISTAL', 'Rio Cristal',
        (SELECT `id_bacia` FROM `bacia_hidrografica` WHERE `codigo` = 'BVS_PEDRA_CLARA'),
        'RIO',
        'Curso d''água fictício de águas naturalmente claras e substrato rochoso.', 1
    ),
    (
        'PC_RIO_PEDRA', 'Rio Pedra Clara',
        (SELECT `id_bacia` FROM `bacia_hidrografica` WHERE `codigo` = 'BVS_PEDRA_CLARA'),
        'RIO',
        'Curso principal fictício da Bacia da Pedra Clara, com corredeiras e poços naturais.', 1
    ),

    -- Bacia da Serra Azul
    (
        'SA_RES_PEDRA_ALTA', 'Reservatório Pedra Alta',
        (SELECT `id_bacia` FROM `bacia_hidrografica` WHERE `codigo` = 'BVS_SERRA_AZUL'),
        'RESERVATORIO',
        'Reservatório fictício de montanha localizado em vale encaixado da Serra Azul.', 1
    ),
    (
        'SA_RIO_NEVOA', 'Rio da Névoa',
        (SELECT `id_bacia` FROM `bacia_hidrografica` WHERE `codigo` = 'BVS_SERRA_AZUL'),
        'RIO',
        'Curso d''água fictício de nascente fria em área serrana sujeita a neblina.', 1
    ),
    (
        'SA_RIO_PINHEIRO', 'Rio dos Pinheiros',
        (SELECT `id_bacia` FROM `bacia_hidrografica` WHERE `codigo` = 'BVS_SERRA_AZUL'),
        'RIO',
        'Afluente fictício de encosta, com canal estreito e elevada declividade.', 1
    ),
    (
        'SA_RIO_SERRA', 'Rio Serra Azul',
        (SELECT `id_bacia` FROM `bacia_hidrografica` WHERE `codigo` = 'BVS_SERRA_AZUL'),
        'RIO',
        'Curso principal fictício da Bacia da Serra Azul, alimentado por nascentes de altitude.', 1
    )
AS `novo`
ON DUPLICATE KEY UPDATE
    `nome` = `novo`.`nome`,
    `id_bacia` = `novo`.`id_bacia`,
    `codigo_tipo_corpo` = `novo`.`codigo_tipo_corpo`,
    `descricao` = `novo`.`descricao`,
    `ativo` = `novo`.`ativo`;

COMMIT;
