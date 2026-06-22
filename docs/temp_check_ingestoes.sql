SELECT 
  table_id as Tabela, 
  DATETIME(TIMESTAMP_MILLIS(last_modified_time), 'America/Sao_Paulo') as Ultima_Atualizacao,
  row_count as Linhas
FROM `iron-rex-461220-g4.database_aroom_health.__TABLES__`
WHERE table_id IN (
  'pedidos_vendas', 'google_analytics_utm_daily', 'google_ads_campaign_performance',
  'meta_ads', 'tiktok_ads_insights', 'mercadolivre_pedidos', 'produtos', 'nuvemshop_pedidos', 'meta_ads_actions', 'bling_canais_venda', 'pedidos_vendas_itens'
)
ORDER BY last_modified_time DESC;
