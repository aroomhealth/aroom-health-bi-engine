import xml.etree.ElementTree as ET
import os

def generate_xml():
    # Create the root structures of draw.io mxfile
    mxfile = ET.Element("mxfile", {
        "host": "app.diagrams.net",
        "modified": "2026-06-17T18:00:00.000Z",
        "agent": "Antigravity AI Assistant",
        "version": "21.0.0",
        "type": "device"
    })
    
    diagram = ET.SubElement(mxfile, "diagram", {
        "id": "aroom_health_architecture",
        "name": "Arquitetura Aroom Health BI"
    })
    
    graph_model = ET.SubElement(diagram, "mxGraphModel", {
        "dx": "1800",
        "dy": "1400",
        "grid": "1",
        "gridSize": "10",
        "guides": "1",
        "tooltips": "1",
        "connect": "1",
        "arrows": "1",
        "fold": "1",
        "page": "1",
        "pageScale": "1",
        "pageWidth": "1800",
        "pageHeight": "1300",
        "math": "0",
        "shadow": "0"
    })
    
    root = ET.SubElement(graph_model, "root")
    
    # Base cells
    ET.SubElement(root, "mxCell", {"id": "0"})
    ET.SubElement(root, "mxCell", {"id": "1", "parent": "0"})
    
    # Common styles
    group_style = "rounded=1;whiteSpace=wrap;html=1;dashed=1;dashPattern=8 8;fillColor=none;strokeColor=#475569;strokeWidth=2;align=center;verticalAlign=top;fontStyle=1;fontSize=14;fontColor=#1E293B;fontFamily=Helvetica;spacingTop=10;"
    sub_group_style = "rounded=1;whiteSpace=wrap;html=1;fillColor=#F8FAFC;strokeColor=#CBD5E1;strokeWidth=1;align=center;verticalAlign=top;fontStyle=1;fontSize=12;fontColor=#475569;spacingTop=5;"
    
    # Helper to add a node
    def add_node(id_val, value, style, x, y, w, h):
        cell = ET.SubElement(root, "mxCell", {
            "id": id_val,
            "value": value,
            "style": style,
            "vertex": "1",
            "parent": "1"
        })
        ET.SubElement(cell, "mxGeometry", {
            "x": str(x),
            "y": str(y),
            "width": str(w),
            "height": str(h),
            "as": "geometry"
        })
        return cell

    # Helper to add an edge
    def add_edge(id_val, source_id, target_id, style, value=""):
        cell = ET.SubElement(root, "mxCell", {
            "id": id_val,
            "value": value,
            "style": style,
            "edge": "1",
            "parent": "1",
            "source": source_id,
            "target": target_id
        })
        ET.SubElement(cell, "mxGeometry", {
            "relative": "1",
            "as": "geometry"
        })
        return cell

    # 0. Title Box
    title_html = (
        "<b><font style='font-size: 22px' color='#0F172A'>DIAGRAMA DE ARQUITETURA DE DADOS COMPLETO - AROOM HEALTH BI</font></b><br/>"
        "<font style='font-size: 13px' color='#64748B'>Mapeamento de ponta a ponta: Origens, Ingestão Raw, Transformação Semântica, Consumo BI/CRM, Infraestrutura (IaC/dbt) e Validação de Dados.</font>"
    )
    add_node("title_box", title_html, "text;html=1;align=left;verticalAlign=middle;resizable=0;points=[];autosize=0;strokeColor=none;fillColor=none;", 40, 20, 1100, 50)

    # 1. Main Grouping Containers (Columns)
    add_node("grp_sources", "FONTES DE ORIGEM (SISTEMAS)", group_style, 40, 100, 220, 780)
    add_node("grp_raw", "BIGQUERY: DATASET RAW (database_aroom_health)", group_style, 300, 100, 340, 780)
    add_node("grp_curated", "BIGQUERY: DATASET CURATED (customer_intelligence)", group_style, 680, 100, 380, 780)
    add_node("grp_others", "BIGQUERY: OUTROS DATASETS (MARKETING / AUDIT)", group_style, 1100, 100, 300, 780)
    add_node("grp_consumers", "CAMADA DE CONSUMO (BI / CRM)", group_style, 1440, 100, 240, 780)

    # 2. Source Nodes
    add_node("src_ibge", "🌍 <b>IBGE & Dados Públicos</b><br/>Arquivos Municipais<br/>(Socioeconômico / UF)", 
             "rounded=1;whiteSpace=wrap;html=1;fillColor=#F1F5F9;strokeColor=#64748B;strokeWidth=1.5;fontColor=#334155;fontSize=11;fontFamily=Helvetica;", 60, 140, 180, 60)

    add_node("src_bling", "📦 <b>Bling ERP</b><br/>Webhooks & API<br/>(Faturamento e Logística)", 
             "rounded=1;whiteSpace=wrap;html=1;fillColor=#E0F2FE;strokeColor=#0284C7;strokeWidth=2;fontColor=#0369A1;fontSize=12;fontFamily=Helvetica;", 60, 250, 180, 75)
             
    add_node("src_ga4", "📈 <b>Google Analytics 4</b><br/>Export Nativo Integrado<br/>(Sessões & Tráfego)", 
             "rounded=1;whiteSpace=wrap;html=1;fillColor=#E0F2FE;strokeColor=#0284C7;strokeWidth=2;fontColor=#0369A1;fontSize=12;fontFamily=Helvetica;", 60, 480, 180, 75)
             
    add_node("src_gads", "📢 <b>Google Ads API</b><br/>Mídia Paga (Campanhas)<br/><font color='#DC2626'><b>INTEGRAÇÃO QUEBRADA</b></font>", 
             "rounded=1;whiteSpace=wrap;html=1;fillColor=#FEE2E2;strokeColor=#EF4444;strokeWidth=2;fontColor=#991B1B;fontSize=12;fontFamily=Helvetica;", 60, 650, 180, 75)
             
    add_node("src_ga4_api", "🐍 <b>GA4 Data API</b><br/>Consultas Python SDK<br/>(Recuperação Histórica)", 
             "rounded=1;whiteSpace=wrap;html=1;fillColor=#F0FDF4;strokeColor=#22C55E;strokeWidth=2;fontColor=#15803D;fontSize=12;fontFamily=Helvetica;", 60, 780, 180, 75)

    # 3. Raw Sub-Containers (Inside database_aroom_health)
    add_node("sub_grp_bling", "<b>TABELAS BRUTAS: BLING ERP</b>", sub_group_style, 315, 140, 310, 315)
    add_node("t_pv", "📄 <b>pedidos_vendas</b> (Headers)",
             "rounded=1;whiteSpace=wrap;html=1;fillColor=#F0FDF4;strokeColor=#22C55E;strokeWidth=1.5;fontColor=#16A34A;fontSize=11;fontFamily=Helvetica;", 330, 175, 280, 40)
    add_node("t_pvi", "⚠️ <b>pedidos_vendas_itens</b> (SKUs)<br/><font color='#D97706'>▲ Duplicados (Impacto R$ 45k)</font>",
             "rounded=1;whiteSpace=wrap;html=1;fillColor=#FFFBEB;strokeColor=#D97706;strokeWidth=1.5;fontColor=#B45309;fontSize=10;fontFamily=Helvetica;", 330, 225, 280, 45)
    add_node("t_pvt", "📄 <b>pedidos_vendas_transporte</b> (Fretes)",
             "rounded=1;whiteSpace=wrap;html=1;fillColor=#F0FDF4;strokeColor=#22C55E;strokeWidth=1.5;fontColor=#16A34A;fontSize=11;fontFamily=Helvetica;", 330, 280, 280, 40)
    add_node("t_prod", "📄 <b>produtos</b> (Cadastro e Custos)",
             "rounded=1;whiteSpace=wrap;html=1;fillColor=#F0FDF4;strokeColor=#22C55E;strokeWidth=1.5;fontColor=#16A34A;fontSize=11;fontFamily=Helvetica;", 330, 330, 280, 40)
    add_node("t_bling_canais", "📄 <b>bling_canais_venda</b> (Lookup de Canais)",
             "rounded=1;whiteSpace=wrap;html=1;fillColor=#F0FDF4;strokeColor=#22C55E;strokeWidth=1.5;fontColor=#16A34A;fontSize=11;fontFamily=Helvetica;", 330, 385, 280, 40)

    add_node("sub_grp_ga4", "<b>TABELAS BRUTAS: GA4</b>", sub_group_style, 315, 470, 310, 120)
    add_node("t_ga_utm", "📄 <b>google_analytics_utm_daily</b> (UTMs Consolidadas)",
             "rounded=1;whiteSpace=wrap;html=1;fillColor=#F0FDF4;strokeColor=#22C55E;strokeWidth=1.5;fontColor=#16A34A;fontSize=11;fontFamily=Helvetica;", 330, 505, 280, 40)
    add_node("t_ga_dummy", "<i>Tráfego consolidado no grão diário</i>",
             "rounded=1;whiteSpace=wrap;html=1;fillColor=#F8FAFC;strokeColor=#CBD5E1;strokeWidth=1;fontColor=#64748B;fontSize=10;fontStyle=2;fontFamily=Helvetica;", 330, 555, 280, 25)

    add_node("sub_grp_gads", "<b>TABELAS BRUTAS: GOOGLE ADS</b>", sub_group_style, 315, 605, 310, 175)
    add_node("t_gads_frozen", "🚨 <b>google_ads_campaign_performance</b><br/><font color='#DC2626'><b>FROZEN - Desde 12/12/2025</b></font>",
             "rounded=1;whiteSpace=wrap;html=1;fillColor=#FEE2E2;strokeColor=#EF4444;strokeWidth=1.5;fontColor='#991B1B';fontSize=10;fontFamily=Helvetica;", 330, 640, 280, 50)
    add_node("t_gads_dts", "✨ <b>google_ads_campaign_performance_v2</b><br/><font color='#2563EB'>★ Proposto (Transferencia DTS e Backfill)</font>",
             "rounded=1;whiteSpace=wrap;html=1;fillColor=#EFF6FF;strokeColor=#3B82F6;strokeWidth=2;dashed=1;fontColor=#1D4ED8;fontSize=10;fontFamily=Helvetica;", 330, 705, 280, 55)

    # 4. Curated Nodes (X = 700)
    add_node("t_cpe", "👤 <b>customer_profile_enriched</b><br/>Perfis de clientes enriquecidos<br/>(UF, CEP, Renda Média Setor, Distância CD)",
             "rounded=1;whiteSpace=wrap;html=1;fillColor=#F0FDF4;strokeColor=#22C55E;strokeWidth=1.5;fontColor=#16A34A;fontSize=11;fontFamily=Helvetica;", 700, 140, 340, 55)
             
    add_node("t_rfm", "🧠 <b>customer_rfm</b><br/>Segmentação RFM de clientes (IA)<br/><font color='#16A34A'>● Ativo (D-1)</font>",
             "rounded=1;whiteSpace=wrap;html=1;fillColor=#F0FDF4;strokeColor=#22C55E;strokeWidth=1.5;fontColor=#16A34A;fontSize=11;fontFamily=Helvetica;", 700, 215, 340, 45)
             
    add_node("t_pred", "🧠 <b>customer_predictions</b><br/>Previsões de LTV e Churn de clientes (IA)<br/><font color='#16A34A'>● Ativo (D-1)</font>",
             "rounded=1;whiteSpace=wrap;html=1;fillColor=#F0FDF4;strokeColor=#22C55E;strokeWidth=1.5;fontColor=#16A34A;fontSize=11;fontFamily=Helvetica;", 700, 275, 340, 45)
             
    add_node("v_gevd", "💎 <b>growth_engine_vendas_detalhado</b><br/><font color='#1D4ED8'><b>VIEW DE NEGÓCIO PRINCIPAL (PROD)</b></font><br/><i>Faturamento Auditado: R$ 9.540.041,07</i><br/>• Rateio proporcional de frete e custos por item<br/>• SmartMetrics Dimensions (Família, Objetivo, Etapa)<br/>• Fallback inteligente via IA para categorias vazias",
             "rounded=1;whiteSpace=wrap;html=1;fillColor=#EFF6FF;strokeColor=#3B82F6;strokeWidth=2.5;fontColor=#1D4ED8;fontSize=11;fontFamily=Helvetica;align=left;spacingLeft=10;", 700, 350, 340, 110)
             
    add_node("v_gemvc", "✨ <b>growth_engine_mkt_vendas_consolidado</b><br/><font color='#D97706'><b>VIEW SEMÂNTICA UNIFICADA (Roadmap)</b></font><br/>• Une Vendas Detalhadas + Origens de Marketing<br/>• Regex de UTMs nas obs. do Bling e GA4 UTMs<br/>• Consolida custos diários de Google Ads DTS<br/>• Calcula Lucro Líquido e ROAS por SKU & Campanha",
             "rounded=1;whiteSpace=wrap;html=1;fillColor=#FFFBEB;strokeColor=#D97706;strokeWidth=2.5;dashed=1;fontColor=#B45309;fontSize=11;fontFamily=Helvetica;align=left;spacingLeft=10;", 700, 560, 340, 115)

    # 5. Other Datasets (X = 1110)
    add_node("grp_gads_internal", "dataset: google_ads (Frozen)", 
             "rounded=1;whiteSpace=wrap;html=1;fillColor=none;strokeColor=#94A3B8;strokeWidth=1;dashed=1;align=center;verticalAlign=top;fontStyle=1;fontSize=12;fontColor=#475569;", 1110, 140, 280, 180)
    add_node("t_ads_internal", "ads_CampaignBasicStats_...<br/>ads_AdStats_...<br/>ads_Budget_...<br/><font color='#DC2626'><b>FROZEN - Desde 12/12/2025</b></font>",
             "rounded=1;whiteSpace=wrap;html=1;fillColor=#FEE2E2;strokeColor=#EF4444;strokeWidth=1;fontColor=#991B1B;fontSize=11;fontFamily=Helvetica;", 1120, 180, 260, 120)

    add_node("grp_ga4_internal", "dataset: analytics_414017556", 
             "rounded=1;whiteSpace=wrap;html=1;fillColor=none;strokeColor=#94A3B8;strokeWidth=1;dashed=1;align=center;verticalAlign=top;fontStyle=1;fontSize=12;fontColor=#475569;", 1110, 340, 280, 180)
    add_node("t_ga4_sharded", "📄 <b>events_YYYYMMDD</b><br/>Tabelas brutas GA4 por dia<br/>(Export Firebase nativo)<br/><font color='#16A34A'>● Ativo (D-1)</font>",
             "rounded=1;whiteSpace=wrap;html=1;fillColor=#F0FDF4;strokeColor=#22C55E;strokeWidth=1;fontColor=#16A34A;fontSize=11;fontFamily=Helvetica;", 1120, 380, 260, 120)

    add_node("grp_recovery_internal", "dataset: analytics_recovery", 
             "rounded=1;whiteSpace=wrap;html=1;fillColor=none;strokeColor=#94A3B8;strokeWidth=1;dashed=1;align=center;verticalAlign=top;fontStyle=1;fontSize=12;fontColor=#475569;", 1110, 540, 280, 200)
    add_node("t_ga4_rec_tables", "📄 <b>ga4_recovery_traffic_sources</b><br/>ga4_recovery_ecommerce<br/>ga4_recovery_pages / geo / devices<br/><i>(Tabelas consolidadas via API)</i><br/><font color='#16A34A'>● Recuperado e Atualizado</font>",
             "rounded=1;whiteSpace=wrap;html=1;fillColor=#F0FDF4;strokeColor=#22C55E;strokeWidth=1;fontColor=#16A34A;fontSize=11;fontFamily=Helvetica;", 1120, 580, 260, 140)

    # 6. Consumer Nodes (X = 1460)
    add_node("vis_looker_faturamento", "📊 <b>Looker Studio Dashboard</b><br/>Faturamento e SmartMetrics<br/><font color='#16A34A'>● <b>CONFIÁVEL</b> bate faturamento</font><br/>Fonte: growth_engine_vendas_detalhado",
             "rounded=1;whiteSpace=wrap;html=1;fillColor=#F0FDF4;strokeColor=#22C55E;strokeWidth=2;fontColor=#16A34A;fontSize=12;fontFamily=Helvetica;", 1460, 150, 200, 85)
             
    add_node("vis_looker_mkt", "📊 <b>Looker Studio Dashboard</b><br/>Mídia e Campanhas (CAC/ROAS)<br/><font color='#DC2626'>▲ <b>DESATUALIZADO (CONGELADO)</b></font><br/>Fonte: google_ads_campaign_performance",
             "rounded=1;whiteSpace=wrap;html=1;fillColor=#FEE2E2;strokeColor=#EF4444;strokeWidth=2;fontColor=#991B1B;fontSize=12;fontFamily=Helvetica;", 1460, 260, 200, 85)

    add_node("vis_looker_mkt_new", "📊 <b>Looker Studio Dashboard</b><br/><b>Novo Dashboard ROAS Real</b><br/><font color='#2563EB'>★ Planejado (DRE/Mkt)</font><br/>Fonte: growth_engine_mkt_vendas_consolidado",
             "rounded=1;whiteSpace=wrap;html=1;fillColor=#EFF6FF;strokeColor=#3B82F6;strokeWidth=2;dashed=1;fontColor=#1D4ED8;fontSize=12;fontFamily=Helvetica;", 1460, 370, 200, 85)
             
    add_node("vis_crm", "✉️ <b>ActiveCampaign / CRM</b><br/>Automação e Réguas de Email<br/>Segmentações LTV & RFM<br/><font color='#16A34A'>● Ativo</font>",
             "rounded=1;whiteSpace=wrap;html=1;fillColor=#F0FDF4;strokeColor=#22C55E;strokeWidth=2;fontColor=#16A34A;fontSize=12;fontFamily=Helvetica;", 1460, 480, 200, 85)

    # NEW: 8. DevOps & Infrastructure Group (X = 40, Y = 900)
    add_node("grp_devops", "🛠️ ORQUESTRAÇÃO & INFRAESTRUTURA (DEVOPS)", group_style, 40, 900, 600, 160)
    add_node("inf_tf", "⚙️ <b>Terraform IaC</b><br/>Provisionamento de Datasets BigQuery<br/>e controle de acessos (IAM GCP)",
             "rounded=1;whiteSpace=wrap;html=1;fillColor=#FAF5FF;strokeColor=#A855F7;strokeWidth=1.5;fontColor=#6B21A8;fontSize=11;fontFamily=Helvetica;", 60, 940, 260, 80)
    add_node("inf_dbt", "⚙️ <b>dbt / Dataform</b><br/>Orquestração de views e tabelas<br/>(Semântica, staging e marts analíticos)",
             "rounded=1;whiteSpace=wrap;html=1;fillColor=#FAF5FF;strokeColor=#A855F7;strokeWidth=1.5;fontColor=#6B21A8;fontSize=11;fontFamily=Helvetica;", 340, 940, 260, 80)

    # NEW: 9. Data Quality & Monitoring Group (X = 680, Y = 900)
    add_node("grp_quality", "🛡️ MONITORAMENTO, QUALIDADE & AUDITORIA DE DADOS", group_style, 680, 900, 1000, 160)
    add_node("mon_fresh", "🛡️ <b>Freshness Validation Checks</b><br/>Scripts de monitoramento de atrasos<br/>(Bling D-1 / Google Ads alerts)",
             "rounded=1;whiteSpace=wrap;html=1;fillColor=#ECFDF5;strokeColor=#10B981;strokeWidth=1.5;fontColor=#065F46;fontSize=11;fontFamily=Helvetica;", 700, 940, 300, 80)
    add_node("mon_rev", "🛡️ <b>Revenue Integrity Auditor</b><br/>Validações de faturamento diário (R$ 9.54M)<br/>e alertas de duplicidades e nulos",
             "rounded=1;whiteSpace=wrap;html=1;fillColor=#ECFDF5;strokeColor=#10B981;strokeWidth=1.5;fontColor=#065F46;fontSize=11;fontFamily=Helvetica;", 1020, 940, 300, 80)
    add_node("mon_alerts", "📣 <b>Quality Alerts (PubSub/Slack)</b><br/>Notificações automáticas de falhas de<br/>pipeline ou dados corrompidos",
             "rounded=1;whiteSpace=wrap;html=1;fillColor=#ECFDF5;strokeColor=#10B981;strokeWidth=1.5;fontColor=#065F46;fontSize=11;fontFamily=Helvetica;", 1340, 940, 320, 80)

    # 7. Legend and Info box (shifted down to Y = 1090)
    legend_text = (
        "<b>LEGENDA & STATUS DO ECOSSISTEMA</b><br/>"
        "• <font color='#16A34A'><b>Verde (Saudável / Ativo):</b></font> Ingestões diárias funcionando perfeitamente sem problemas de integridade detectados.<br/>"
        "• <font color='#D97706'><b>Amarelo (Atenção / Duplicidade):</b></font> Tabela/View funcionando, porém com riscos conhecidos de fan-out ou duplicações físicas a serem saneadas.<br/>"
        "• <font color='#DC2626'><b>Vermelho (Quebrado / Congelado):</b></font> Pipeline inativo desde 12/12/2025. Dados estáticos e dashboards de marketing corrompidos.<br/>"
        "• <font color='#2563EB'><b>Azul Pontilhado (Planejado / Roadmap):</b></font> Camadas de dados, ferramentas (DTS) e views propostas no plano de recuperação e atribuição de ROAS.<br/>"
        "• <font color='#6B21A8'><b>Roxo (Orquestração / IaC):</b></font> Camada de governança e controle de recursos (Terraform / dbt).<br/>"
        "<i>Instruções de Edição: Para alterar este diagrama, abra-o no site <b>draw.io</b> (File &gt; Open From &gt; Device...) ou arraste e solte o arquivo <b>aroom_health_architecture.drawio</b> na tela do draw.io.</i>"
    )
    add_node("legend_box", legend_text, "rounded=1;whiteSpace=wrap;html=1;fillColor=#F8FAFC;strokeColor=#E2E8F0;strokeWidth=2;align=left;spacingLeft=15;fontSize=12;fontColor=#334155;fontFamily=Helvetica;spacingTop=5;", 40, 1090, 1640, 160)

    # --- EDGES / CONNECTIONS (Highly Organized Routing) ---
    edge_healthy = "edgeStyle=orthogonalEdgeStyle;rounded=1;orthogonalLoop=1;jettySize=auto;html=1;strokeColor=#22C55E;strokeWidth=1.5;"
    edge_warning = "edgeStyle=orthogonalEdgeStyle;rounded=1;orthogonalLoop=1;jettySize=auto;html=1;strokeColor=#D97706;strokeWidth=1.5;"
    edge_broken = "edgeStyle=orthogonalEdgeStyle;rounded=1;orthogonalLoop=1;jettySize=auto;html=1;strokeColor=#EF4444;strokeWidth=2;dashed=1;"
    edge_proposed = "edgeStyle=orthogonalEdgeStyle;rounded=1;orthogonalLoop=1;jettySize=auto;html=1;strokeColor=#3B82F6;strokeWidth=2;dashed=1;"
    edge_devops = "edgeStyle=orthogonalEdgeStyle;rounded=1;orthogonalLoop=1;jettySize=auto;html=1;strokeColor=#A855F7;strokeWidth=1.5;dashed=1;"
    edge_quality = "edgeStyle=orthogonalEdgeStyle;rounded=1;orthogonalLoop=1;jettySize=auto;html=1;strokeColor=#10B981;strokeWidth=1.5;dashed=1;"

    # Connect Sources to Groups / Tables
    add_edge("e_src_bling_grp", "src_bling", "sub_grp_bling", edge_healthy)
    add_edge("e_src_ga4_grp", "src_ga4", "sub_grp_ga4", edge_healthy)
    
    add_edge("e_src_gads_frozen", "src_gads", "t_gads_frozen", edge_broken)
    add_edge("e_src_gads_new", "src_gads", "t_gads_dts", edge_proposed)
    
    add_edge("e_src_ibge_cpe", "src_ibge", "t_cpe", edge_healthy)
    add_edge("e_src_ga4api_rec", "src_ga4_api", "grp_recovery_internal", edge_healthy)

    # Connect Raw groups & tables to View/Curated
    add_edge("e_raw_bling_gevd", "sub_grp_bling", "v_gevd", edge_healthy)
    add_edge("e_cpe_gevd", "t_cpe", "v_gevd", edge_healthy)

    # Internal Curated flow
    add_edge("e_cpe_rfm", "t_cpe", "t_rfm", edge_healthy)
    add_edge("e_rfm_pred", "t_rfm", "t_pred", edge_healthy)

    # Connect Google Ads frozen data to Google Ads dataset
    add_edge("e_gads_old_stats", "t_gads_frozen", "t_ads_internal", edge_broken)
    
    # Connect GA4 raw events to internal GA4 dataset
    add_edge("e_ga4_raw_sharded", "src_ga4", "t_ga4_sharded", edge_healthy)

    # Connect components to the proposed view (consolidated view)
    add_edge("e_gevd_gemvc", "v_gevd", "v_gemvc", edge_proposed)
    add_edge("e_ga_utm_gemvc", "t_ga_utm", "v_gemvc", edge_proposed)
    add_edge("e_gads_new_gemvc", "t_gads_dts", "v_gemvc", edge_proposed)
    add_edge("e_ga4_rec_gemvc", "t_ga4_rec_tables", "v_gemvc", edge_proposed)

    # Connect to Consumption (BI / CRM)
    add_edge("e_gevd_looker", "v_gevd", "vis_looker_faturamento", edge_healthy)
    add_edge("e_ads_old_looker", "t_ads_internal", "vis_looker_mkt", edge_broken)
    
    add_edge("e_gemvc_looker_new", "v_gemvc", "vis_looker_mkt_new", edge_proposed)
    
    add_edge("e_rfm_crm", "t_rfm", "vis_crm", edge_healthy)
    add_edge("e_pred_crm", "t_pred", "vis_crm", edge_healthy)

    # Connect DevOps & Quality
    add_edge("e_inf_tf_raw", "inf_tf", "grp_raw", edge_devops)
    add_edge("e_inf_dbt_cur", "inf_dbt", "grp_curated", edge_devops)
    
    add_edge("e_mon_fresh_pv", "mon_fresh", "t_pv", edge_quality)
    add_edge("e_mon_rev_gevd", "mon_rev", "v_gevd", edge_quality)

    # Save to file
    tree = ET.ElementTree(mxfile)
    output_path = "/Users/renanstranodeoliveira/Downloads/aroom-health-bi-engine/docs/aroom_health_architecture.drawio"
    ET.indent(tree, space="  ", level=0)
    tree.write(output_path, encoding="utf-8", xml_declaration=True)
    print(f"Diagrama gerado com sucesso em: {output_path}")

if __name__ == "__main__":
    generate_xml()
