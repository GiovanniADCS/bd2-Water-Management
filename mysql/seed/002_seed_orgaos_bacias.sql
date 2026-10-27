-- Water Management - Orgaos responsaveis e bacias hidrograficas
-- Carga idempotente do cenario ficticio do Vale Sereno.
-- Compatibilidade alvo: MySQL 8.0.46.
--
-- Escopo exclusivo:
--   orgao_responsavel: 3 registros
--   bacia_hidrografica: 6 registros
--
-- Os nomes representam entidades inteiramente ficticias. O script nao exclui
-- registros, nao desabilita FKs e nao depende de IDs AUTO_INCREMENT.

SET NAMES utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE `recursos_hidricos`;

START TRANSACTION;

INSERT INTO `orgao_responsavel`
    (`codigo`, `nome`, `descricao`, `ativo`)
VALUES
    (
        'ARHVS',
        'Agência Regional de Monitoramento Hídrico do Vale Sereno',
        'Órgão fictício de coordenação regional do monitoramento hídrico no Vale Sereno.',
        1
    ),
    (
        'CENTRO_TECNICO',
        'Centro Técnico de Monitoramento do Vale Sereno',
        'Órgão fictício responsável por operação técnica, consistência de dados e apoio às estações.',
        1
    ),
    (
        'CONSORCIO_VALE',
        'Consórcio Interbacias do Vale Sereno',
        'Órgão fictício de cooperação operacional entre as bacias hidrográficas do Vale Sereno.',
        1
    )
AS `novo`
ON DUPLICATE KEY UPDATE
    `nome` = `novo`.`nome`,
    `descricao` = `novo`.`descricao`,
    `ativo` = `novo`.`ativo`;

INSERT INTO `bacia_hidrografica`
    (`codigo`, `nome`, `descricao`, `ativo`)
VALUES
    (
        'BVS_ALTO_CEDRO',
        'Bacia do Alto Cedro',
        'Bacia fictícia de cabeceiras serranas e vales estreitos na porção noroeste do Vale Sereno.',
        1
    ),
    (
        'BVS_BAIXO_VALE',
        'Bacia do Baixo Vale',
        'Bacia fictícia de convergência dos cursos d''água na porção sudeste do Vale Sereno.',
        1
    ),
    (
        'BVS_CAMPO_VERDE',
        'Bacia do Campo Verde',
        'Bacia fictícia de relevo suave, veredas e áreas de planície na faixa central do Vale Sereno.',
        1
    ),
    (
        'BVS_LAGOA_SERENA',
        'Bacia da Lagoa Serena',
        'Bacia fictícia com áreas úmidas, lagoas marginais e cursos de baixa declividade.',
        1
    ),
    (
        'BVS_PEDRA_CLARA',
        'Bacia da Pedra Clara',
        'Bacia fictícia de leitos rochosos e águas naturalmente claras na porção nordeste da região.',
        1
    ),
    (
        'BVS_SERRA_AZUL',
        'Bacia da Serra Azul',
        'Bacia fictícia de encostas, nascentes frias e trechos de maior declividade.',
        1
    )
AS `novo`
ON DUPLICATE KEY UPDATE
    `nome` = `novo`.`nome`,
    `descricao` = `novo`.`descricao`,
    `ativo` = `novo`.`ativo`;

COMMIT;
