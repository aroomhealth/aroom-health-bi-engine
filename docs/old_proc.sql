BEGIN
  MERGE `database_aroom_health.visao_diaria_de_vendas` AS T
  USING (
    WITH
      date_references AS (
        SELECT
          CURRENT_DATE() AS data_atual,
          EXTRACT(YEAR FROM CURRENT_DATE()) AS ano_atual,
          EXTRACT(DAY FROM CURRENT_DATE()) AS dia_atual_mes,
          DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY) AS data_30_dias_atras,
          DATE_TRUNC(CURRENT_DATE(), MONTH) AS inicio_mes_atual,
          DATE_TRUNC(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH), MONTH) AS inicio_mes_anterior,
          LAST_DAY(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH), MONTH) AS fim_mes_anterior
      ),
      /*nuvemshop_daily AS (
        SELECT
          DATE(pv.data) AS dia,
          SUM(pv.total_produtos) AS total_nuvemshop
        FROM
          `database_aroom_health.pedidos_vendas` AS pv
          INNER JOIN `database_aroom_health.pedidos_vendas_situacao` pvs
          ON pvs.id = pv.situacao_id
          INNER JOIN `database_aroom_health.canais_vendas` cv
          ON cv.Id_Canal = pv.loja_id
        WHERE          
          cv.canal_edit like 'Site Aroom'
          AND pvs.identificador <> 12
        GROUP BY
          dia
      ),*/
      /* substituido pela tabela nova */
      nuvemshop_daily AS (
        SELECT
          DATE(np.created_at) AS dia,
          -- Usei 'subtotal' para bater com o antigo 'total_produtos'. 
          -- Se a intenção for pegar o valor final cobrado (com frete/desconto), troque para 'total'
          SUM(np.subtotal) AS total_nuvemshop 
        FROM
          `iron-rex-461220-g4.database_aroom_health.nuvemshop_pedidos` AS np
        WHERE
          -- O antigo pvs.identificador <> 12 significava excluir "Devolvidos/Estornados"
          np.payment_status NOT IN ('refunded', 'voided') 
        GROUP BY
          dia
      ),

      facebook_daily AS (
        SELECT
          DATE(fai.date) AS dia,
          SUM(fai.purchase) AS total_facebook_revenue,
          SUM(fai.spend) AS total_facebook_cost
        FROM
          `database_aroom_health.facebook_ads_insights` AS fai
        GROUP BY
          dia
      ),
      /*google_daily AS (
        SELECT
          DATE(gads.day) AS dia,
          SUM(gads.total_conv_value) AS total_google_revenue,
          SUM(gads.cost_spend) AS total_google_cost
        FROM
          `database_aroom_health.google_ads_campaign_performance` AS gads
        GROUP BY
          dia
      ),*/
      google_daily AS (
        SELECT
          DATE(gads.segments_date) AS dia,
          SUM(gads.metrics_current_model_attributed_conversions_value) AS total_google_revenue,
          SUM(gads.metrics_cost_micros/1000000) AS total_google_cost
        FROM
          `iron-rex-461220-g4.google_ads.ads_CampaignStats_5644422842` AS gads
        GROUP BY
          dia
      ),
      dados_combinados AS (
        SELECT
          COALESCE(n.dia, f.dia, g.dia) AS data,
          IFNULL(n.total_nuvemshop, 0) AS total_nuvemshop,
          IFNULL(g.total_google_revenue, 0) AS total_google_ads,
          IFNULL(f.total_facebook_revenue, 0) AS total_facebook_ads,
          IFNULL(g.total_google_cost, 0) AS custo_google_ads,
          IFNULL(f.total_facebook_cost, 0) AS custo_facebook_ads,
          GREATEST(0, IFNULL(n.total_nuvemshop, 0) - (IFNULL(g.total_google_revenue, 0) + IFNULL(f.total_facebook_revenue, 0))) as total_organico
        FROM
          nuvemshop_daily AS n
          FULL OUTER JOIN facebook_daily AS f ON n.dia = f.dia
          FULL OUTER JOIN google_daily AS g ON COALESCE(n.dia, f.dia) = g.dia
      ),
      calculos_finais AS (
        SELECT
          *,
          (total_google_ads + total_facebook_ads + total_organico) AS soma_prova,
          SAFE_DIVIDE(total_google_ads, (total_google_ads + total_facebook_ads + total_organico)) AS percentual_google,
          SAFE_DIVIDE(total_facebook_ads, (total_google_ads + total_facebook_ads + total_organico)) AS percentual_facebook,
          SAFE_DIVIDE(total_organico, (total_google_ads + total_facebook_ads + total_organico)) AS percentual_organico
        FROM dados_combinados
      )
      SELECT
        c.data,
        c.total_nuvemshop,
        c.total_google_ads,
        c.total_facebook_ads,
        c.total_organico,
        c.percentual_google,
        c.percentual_facebook,
        c.percentual_organico,
        CASE WHEN c.total_nuvemshop < c.soma_prova THEN 'não ok' ELSE 'ok' END AS verificacao_valores,
        CAST(c.soma_prova AS NUMERIC) as soma_prova,
        CAST(c.custo_google_ads AS NUMERIC) as custo_google_ads,
        CAST(c.custo_facebook_ads AS NUMERIC) as custo_facebook_ads,
        CAST(c.percentual_google * c.total_nuvemshop AS NUMERIC) AS total_google_ads_tratado,
        CAST(c.percentual_facebook * c.total_nuvemshop AS NUMERIC) AS total_facebook_ads_tratado,
        CAST(c.percentual_organico * c.total_nuvemshop AS NUMERIC) AS total_organico_tratado,
        CAST(SAFE_DIVIDE((c.percentual_google * c.total_nuvemshop) - c.custo_google_ads, (c.percentual_google * c.total_nuvemshop)) AS NUMERIC) AS roi_google_ads,
        CAST(SAFE_DIVIDE((c.percentual_facebook * c.total_nuvemshop) - c.custo_facebook_ads, (c.percentual_facebook * c.total_nuvemshop)) AS NUMERIC) AS roi_facebook_ads,
        CAST(SAFE_DIVIDE(c.total_google_ads, c.custo_google_ads) AS NUMERIC) AS roas_google_ads,
        CAST(SAFE_DIVIDE(c.total_facebook_ads, c.custo_facebook_ads) AS NUMERIC) AS roas_facebook_ads,
        EXTRACT(YEAR FROM c.data) AS ano,
        EXTRACT(MONTH FROM c.data) AS mes,
        CASE EXTRACT(DAYOFWEEK FROM c.data)
            WHEN 1 THEN 'Domingo'
            WHEN 2 THEN 'Segunda-feira'
            WHEN 3 THEN 'Terça-feira'
            WHEN 4 THEN 'Quarta-feira'
            WHEN 5 THEN 'Quinta-feira'
            WHEN 6 THEN 'Sexta-feira'
            WHEN 7 THEN 'Sábado'
        END AS dia_semana,
        EXTRACT(DAYOFWEEK FROM c.data) AS dia_semana_num,
        EXTRACT(WEEK FROM c.data) - EXTRACT(WEEK FROM DATE_TRUNC(c.data, MONTH)) + 1 AS semana_mes,
        EXTRACT(WEEK FROM c.data) AS semana_ano,
        EXTRACT(DAYOFYEAR FROM c.data) AS dia_ano,
        CONCAT('Semana ', FORMAT_DATE('%W', c.data)) AS semana_ano_string,
        CONCAT(FORMAT_DATE('%d/%m/%Y', DATE_TRUNC(c.data, WEEK)), ' a ', FORMAT_DATE('%d/%m/%Y', DATE_ADD(DATE_TRUNC(c.data, WEEK), INTERVAL 6 DAY))) AS periodo_semana_string,
        (EXTRACT(YEAR FROM c.data) = dr.ano_atual AND c.data <= dr.data_atual) AS flag_ytd,
        (c.data BETWEEN dr.data_30_dias_atras AND dr.data_atual) AS flag_diaano_30,
        ((c.data BETWEEN dr.inicio_mes_anterior AND dr.fim_mes_anterior) OR (c.data BETWEEN dr.inicio_mes_atual AND dr.data_atual)) AS flag_mxm,
        ((c.data BETWEEN dr.inicio_mes_atual AND dr.data_atual) OR (DATE_TRUNC(c.data, MONTH) = dr.inicio_mes_anterior AND EXTRACT(DAY FROM c.data) <= dr.dia_atual_mes)) AS flag_MoM
      FROM calculos_finais AS c
      CROSS JOIN date_references AS dr
  ) AS S
  ON T.data = S.data

  WHEN MATCHED THEN
    UPDATE SET
      total_numveshop = S.total_nuvemshop,
      total_google_ads = S.total_google_ads,
      total_facebook_ads = S.total_facebook_ads,
      total_organico = S.total_organico,
      soma_prova = S.soma_prova,
      verificacao_valores = S.verificacao_valores,
      percentual_google = S.percentual_google,
      percentual_facebook = S.percentual_facebook,
      percentual_organico = S.percentual_organico,
      total_google_ads_tratado = S.total_google_ads_tratado,
      total_facebook_ads_tratado = S.total_facebook_ads_tratado,
      total_organico_tratado = S.total_organico_tratado,
      ano = S.ano,
      mes = S.mes,
      dia_semana = S.dia_semana,
      dia_semana_num = S.dia_semana_num,
      semana_mes = S.semana_mes,
      semana_ano = S.semana_ano,
      dia_ano = S.dia_ano,
      semana_ano_string = S.semana_ano_string,
      periodo_semana_string = S.periodo_semana_string,
      flag_ytd = S.flag_ytd,
      flag_diaano_30 = S.flag_diaano_30,
      flag_mxm = S.flag_mxm,
      flag_MoM = S.flag_MoM,
      custo_google_ads = S.custo_google_ads,
      roi_google_ads = S.roi_google_ads,
      custo_facebook_ads = S.custo_facebook_ads,
      roi_facebook_ads = S.roi_facebook_ads,
      roas_google_ads = S.roas_google_ads,
      roas_facebook_ads = S.roas_facebook_ads

  WHEN NOT MATCHED BY TARGET THEN
    INSERT (
      data, total_numveshop, total_google_ads, total_facebook_ads, total_organico,
      soma_prova, verificacao_valores, percentual_google, percentual_facebook, percentual_organico,
      total_google_ads_tratado, total_facebook_ads_tratado, total_organico_tratado, ano, mes,
      dia_semana, dia_semana_num, semana_mes, semana_ano, dia_ano, semana_ano_string, periodo_semana_string,
      flag_ytd, flag_diaano_30, flag_mxm, flag_MoM, custo_google_ads, roi_google_ads,
      custo_facebook_ads, roi_facebook_ads, roas_google_ads, roas_facebook_ads
    )
    VALUES (
      S.data, S.total_nuvemshop, S.total_google_ads, S.total_facebook_ads, S.total_organico,
      S.soma_prova, S.verificacao_valores, S.percentual_google, S.percentual_facebook, S.percentual_organico,
      S.total_google_ads_tratado, S.total_facebook_ads_tratado, S.total_organico_tratado, S.ano, S.mes,
      S.dia_semana, S.dia_semana_num, S.semana_mes, S.semana_ano, S.dia_ano, S.semana_ano_string, S.periodo_semana_string,
      S.flag_ytd, S.flag_diaano_30, S.flag_mxm, S.flag_MoM, S.custo_google_ads, S.roi_google_ads,
      S.custo_facebook_ads, S.roi_facebook_ads, S.roas_google_ads, S.roas_facebook_ads
    );
END