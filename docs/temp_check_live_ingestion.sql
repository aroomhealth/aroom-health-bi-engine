SELECT 'Google Ads' as fonte, CAST(MAX(day) AS STRING) as ultima_data, COUNT(*) as total_registros 
FROM `iron-rex-461220-g4.database_aroom_health.google_ads_campaign_performance`
UNION ALL
SELECT 'GA4 UTMs', CAST(MAX(metric_date) AS STRING), COUNT(*) 
FROM `iron-rex-461220-g4.database_aroom_health.google_analytics_utm_daily`
UNION ALL
SELECT 'GA4 Events', CAST(MAX(metric_date) AS STRING), COUNT(*) 
FROM `iron-rex-461220-g4.database_aroom_health.google_analytics_event_daily`
