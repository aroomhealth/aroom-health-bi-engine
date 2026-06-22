-- ==============================================================================
-- VIEW: v_legado_clientes
-- DATASET: legado
-- DESCRICAO: Base unificada de clientes cruzando Bling (contato/contatos_v2)
--            com dados de CPF, gênero, data de nascimento e email.
--            Fonte principal para Customer 360 e segmentação CRM.
-- ==============================================================================

CREATE OR REPLACE VIEW `iron-rex-461220-g4.legado.v_legado_clientes` AS

SELECT
    COALESCE(v2.identificador, c.identificador)         AS cliente_id,
    COALESCE(v2.nome, c.nome)                           AS nome,
    COALESCE(v2.email, c.email)                         AS email,
    COALESCE(v2.numero_documento, c.numero_documento)   AS cpf_cnpj,
    COALESCE(v2.telefone, c.telefone)                   AS telefone,
    COALESCE(v2.celular, c.celular)                     AS celular,
    COALESCE(v2.data_nascimento, c.data_nascimento)     AS data_nascimento,
    COALESCE(v2.genero, c.sexo)                         AS genero,
    COALESCE(v2.situacao, c.situacao)                   AS situacao,
    COALESCE(v2.tipo, c.tipo)                           AS tipo_pessoa,  -- F=Fisica, J=Juridica

    -- Flags de qualidade de dados
    CASE WHEN COALESCE(v2.email, c.email) IS NOT NULL
              AND REGEXP_CONTAINS(COALESCE(v2.email, c.email), r'^[^@]+@[^@]+\.[^@]+$')
         THEN TRUE ELSE FALSE END                        AS email_valido,
    c.email_invalido                                    AS email_marcado_invalido,

    -- Fonte do registro
    CASE
        WHEN v2.id IS NOT NULL AND c.id IS NOT NULL THEN 'ambas'
        WHEN v2.id IS NOT NULL THEN 'contatos_v2'
        ELSE 'contato'
    END                                                 AS fonte_registro,

    COALESCE(v2.codigo, c.codigo)                       AS codigo_cliente,
    c.created_at                                        AS criado_em,
    c.updated_at                                        AS atualizado_em

FROM `iron-rex-461220-g4.database_aroom_health.contato` c
FULL OUTER JOIN `iron-rex-461220-g4.database_aroom_health.contatos_v2` v2
    ON c.identificador = v2.identificador

WHERE COALESCE(v2.situacao, c.situacao) != 'I'  -- exclui inativos
