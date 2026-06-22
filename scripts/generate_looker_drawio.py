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
        "id": "looker_studio_architecture",
        "name": "Arquitetura Looker Studio"
    })
    
    graph_model = ET.SubElement(diagram, "mxGraphModel", {
        "dx": "1800",
        "dy": "1200",
        "grid": "1",
        "gridSize": "10",
        "guides": "1",
        "tooltips": "1",
        "connect": "1",
        "arrows": "1",
        "fold": "1",
        "page": "1",
        "pageScale": "1",
        "pageWidth": "1700",
        "pageHeight": "1100",
        "math": "0",
        "shadow": "0"
    })
    
    root = ET.SubElement(graph_model, "root")
    
    # Base cells
    ET.SubElement(root, "mxCell", {"id": "0"})
    ET.SubElement(root, "mxCell", {"id": "1", "parent": "0"})
    
    # Common styles
    group_style = "rounded=1;whiteSpace=wrap;html=1;dashed=1;dashPattern=8 8;fillColor=none;strokeColor=#475569;strokeWidth=2;align=center;verticalAlign=top;fontStyle=1;fontSize=14;fontColor=#1E293B;fontFamily=Helvetica;spacingTop=10;"
    
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
        "<b><font style='font-size: 22px' color='#0F172A'>DIAGRAMA DE ARQUITETURA DE CONSUMO - LOOKER STUDIO & BIGQUERY</font></b><br/>"
        "<font style='font-size: 13px' color='#64748B'>Mapeamento relacional entre as páginas dos relatórios do Looker Studio (Menus), Camadas de Combinação (Blends) e Tabelas/Views físicas do BigQuery.</font>"
    )
    add_node("title_box", title_html, "text;html=1;align=left;verticalAlign=middle;resizable=0;points=[];autosize=0;strokeColor=none;fillColor=none;", 40, 20, 1100, 50)

    # 1. Main Grouping Containers (Columns)
    add_node("grp_looker_pages", "MÓDULOS & PÁGINAS DO LOOKER STUDIO", group_style, 40, 100, 240, 780)
    add_node("grp_blends", "CONECTORES & CAMADA SEMÂNTICA (BIGQUERY VIEWS / BLENDS)", group_style, 320, 100, 420, 780)
    add_node("grp_intelligence", "BQ: customer_intelligence", group_style, 780, 100, 420, 780)
    add_node("grp_database_raw", "BQ: database_aroom_health (RAW)", group_style, 1240, 100, 420, 780)

    # 2. Looker Pages Nodes (Column 1 - Left)
    page_style = "rounded=1;whiteSpace=wrap;html=1;fillColor=#FAF5FF;strokeColor=#C084FC;strokeWidth=2;fontColor=#581C87;fontSize=11;fontFamily=Helvetica;align=left;spacingLeft=10;"
    
    add_node("p_vendas_details", "📊 <b>Vendas: YoY, MoM & Detalhado</b><br/>Páginas 1 a 4 do Menu Vendas", page_style, 60, 140, 200, 60)
    add_node("p_vendas_site", "📊 <b>Vendas: Painel Site Aroom</b><br/>Página 6 (ROAS Google / Meta)", page_style, 60, 225, 200, 60)
    add_node("p_produtos", "📦 <b>Módulo: Produtos</b><br/>Afinidades de compra & Giro", page_style, 60, 310, 200, 60)
    add_node("p_estoque", "🗃️ <b>Módulo: Estoque</b><br/>Inventário físico & saldos", page_style, 60, 395, 200, 60)
    add_node("p_expedicao", "🚚 <b>Módulo: Expedição</b><br/>Fretes & Prazos logísticos", page_style, 60, 480, 200, 60)
    add_node("p_clientes", "👥 <b>Módulo: Clientes (CRM)</b><br/>RFM, Churn e Perfil 360", page_style, 60, 565, 200, 60)
    add_node("p_nps", "💬 <b>Módulo: NPS & Atendimento</b><br/>Chatbot e WhatsApp metrics", page_style, 60, 650, 200, 60)
    add_node("p_financeiro", "💳 <b>Módulo: Financeiro</b><br/>DRE, Fluxo Caixa, Contas P/R", page_style, 60, 735, 200, 60)

    # 3. Blends & Views Nodes (Column 2 - Middle-Left)
    blend_style = "rounded=1;whiteSpace=wrap;html=1;fillColor=#EFF6FF;strokeColor=#3B82F6;strokeWidth=2;fontColor=#1D4ED8;fontSize=11;fontFamily=Helvetica;align=left;spacingLeft=10;"
    blend_orange = "rounded=1;whiteSpace=wrap;html=1;fillColor=#FFFBEB;strokeColor=#D97706;strokeWidth=2;fontColor=#B45309;fontSize=11;fontFamily=Helvetica;align=left;spacingLeft=10;"
    
    add_node("b_vendas_detalhado", "💎 <b>View: growth_engine_vendas_detalhado</b><br/>Grão: Item de Pedido. Bate R$ 9.54M", blend_style, 340, 140, 380, 50)
    add_node("b_roas_blend", "🔗 <b>Combinação (Blend): Site Aroom ROAS</b><br/>Une visao_diaria_de_vendas + custos Ads", blend_orange, 340, 220, 380, 55)
    add_node("b_produtos_giro", "💎 <b>View: growth_engine_produtos_afinidade</b><br/>Afinidades por SKU + Produtos_Giro", blend_style, 340, 305, 380, 55)
    add_node("b_estoque_consolidado", "📄 <b>Tabela: bling_estoque_saldos</b><br/>Estoque real reportado pelo ERP", blend_style, 340, 395, 380, 50)
    add_node("b_expedicao_consolidada", "💎 <b>View: view_tracking_order</b><br/>Faturamento logístico & prazos reais", blend_style, 340, 480, 380, 50)
    add_node("b_crm_rfm", "💎 <b>View: growth_engine_crm_rfm & Geografia</b><br/>Mapeamento RFM + Geografia de clientes", blend_style, 340, 560, 380, 55)
    add_node("b_chatbot_nps", "📄 <b>chatbot_message & WhatsApp metrics</b><br/>Metadados de atendimento e NPS", blend_style, 340, 645, 380, 50)
    add_node("b_financeiro_consolidado", "💎 <b>View: view_financeiro & Contas Pag/Rec</b><br/>Caixa consolidado contábil do ERP", blend_style, 340, 730, 380, 55)

    # 4. customer_intelligence Nodes (Column 3 - Middle-Right)
    ci_style = "rounded=1;whiteSpace=wrap;html=1;fillColor=#F0FDF4;strokeColor=#22C55E;strokeWidth=1.5;fontColor=#16A34A;fontSize=11;fontFamily=Helvetica;"
    
    add_node("ci_cpe", "👤 <b>customer_profile_enriched</b><br/>Distância CD, CEP, Renda Média", ci_style, 800, 140, 380, 45)
    add_node("ci_360", "👤 <b>customer_360</b><br/>LTV Histórico e KPIs do cliente", ci_style, 800, 205, 380, 45)
    add_node("ci_rfm", "🧠 <b>customer_rfm</b><br/>Segmentação RFM Champions/Sleeping", ci_style, 800, 270, 380, 45)
    add_node("ci_pred", "🧠 <b>customer_predictions</b><br/>Predições LTV 12m e Churn 30d", ci_style, 800, 335, 380, 45)
    add_node("ci_affinity", "🧠 <b>product_affinity</b><br/>Combos e cestas de compras", ci_style, 800, 400, 380, 45)
    add_node("ci_geo", "💎 <b>growth_engine_geografia</b><br/>View de inteligência geográfica", ci_style, 800, 465, 380, 45)
    add_node("ci_pro_affinity", "💎 <b>growth_engine_produtos_afinidade</b><br/>View de afinidade de SKUs", ci_style, 800, 530, 380, 45)

    # 5. database_aroom_health Nodes (Column 4 - Right)
    raw_style = "rounded=1;whiteSpace=wrap;html=1;fillColor=#F8FAFC;strokeColor=#94A3B8;strokeWidth=1.5;fontColor=#334155;fontSize=10;fontFamily=Helvetica;"
    raw_warning = "rounded=1;whiteSpace=wrap;html=1;fillColor=#FFFBEB;strokeColor=#D97706;strokeWidth=1.5;fontColor=#B45309;fontSize=10;fontFamily=Helvetica;"
    raw_danger = "rounded=1;whiteSpace=wrap;html=1;fillColor=#FEE2E2;strokeColor=#EF4444;strokeWidth=1.5;fontColor=#991B1B;fontSize=10;fontFamily=Helvetica;"
    
    add_node("raw_pv", "pedidos_vendas (Headers)", raw_style, 1260, 120, 340, 35)
    add_node("raw_pvi", "pedidos_vendas_itens (SKUs - Duplicados)", raw_warning, 1260, 165, 340, 35)
    add_node("raw_pvt", "pedidos_vendas_transporte (Shipping)", raw_style, 1260, 210, 340, 35)
    add_node("raw_prod", "produtos (Costs/Catalog)", raw_style, 1260, 255, 340, 35)
    add_node("raw_bc", "bling_canais_venda (Lookup)", raw_style, 1260, 300, 340, 35)
    add_node("raw_vis_diaria", "visao_diaria_de_vendas (Daily Vendas)", raw_style, 1260, 345, 340, 35)
    add_node("raw_gads", "google_ads_campaign_performance (Frozen)", raw_danger, 1260, 390, 340, 35)
    add_node("raw_fbads", "facebook_ads_insights (Meta Cost)", raw_style, 1260, 435, 340, 35)
    add_node("raw_receber", "contas_receber (Inflow)", raw_style, 1260, 480, 340, 35)
    add_node("raw_pagar", "contas_pagar (Outflow)", raw_style, 1260, 525, 340, 35)
    add_node("raw_chatbot", "chatbot_message (Support logs)", raw_style, 1260, 570, 340, 35)
    add_node("raw_nshop", "nuvemshop_pedidos (Nuvemshop headers)", raw_style, 1260, 615, 340, 35)
    add_node("raw_nshop_prod", "nuvemshop_pedido_produto (Nuvemshop items)", raw_style, 1260, 660, 340, 35)
    add_node("raw_ml", "mercadolivre_pedidos (ML headers)", raw_style, 1260, 705, 340, 35)
    add_node("raw_wt", "whatsapp_template_metrics_daily (WhatsApp)", raw_style, 1260, 750, 340, 35)

    # 6. Legend and info at the bottom (X = 40, Y = 900)
    legend_text = (
        "<b>LEGENDA DE ARQUITETURA DO LOOKER STUDIO</b><br/>"
        "• <font color='#581C87'><b>Roxo (Módulo Looker):</b></font> Representa as seções e páginas visíveis do painel do Looker Studio conforme o menu de navegação do usuário.<br/>"
        "• <font color='#1D4ED8'><b>Azul (BQ View):</b></font> Views do BigQuery que agregam, limpam e modelam os dados antes de entregá-los ao painel.<br/>"
        "• <font color='#B45309'><b>Laranja (Looker Blend):</b></font> Combinações lógicas de dados configuradas diretamente na interface do Looker Studio (ex: Painel Site Aroom blending).<br/>"
        "• <font color='#16A34A'><b>Verde (customer_intelligence):</b></font> Tabelas e views enriquecidas com IA, RFM, Churn e dados socioeconômicos.<br/>"
        "• <font color='#334155'><b>Cinza (Raw/Staging):</b></font> Tabelas transacionais e comportamentais brutas oriundas dos webhooks e APIs.<br/>"
        "<i>Como usar: Arraste e solte o arquivo <b>looker_studio_architecture.drawio</b> no site <b>draw.io</b> para editar e adicionar novas métricas.</i>"
    )
    add_node("legend_box", legend_text, "rounded=1;whiteSpace=wrap;html=1;fillColor=#F8FAFC;strokeColor=#E2E8F0;strokeWidth=2;align=left;spacingLeft=15;fontSize=12;fontColor=#334155;fontFamily=Helvetica;spacingTop=5;", 40, 900, 1620, 150)

    # --- EDGES / CONNECTIONS ---
    edge_page = "edgeStyle=orthogonalEdgeStyle;rounded=1;orthogonalLoop=1;jettySize=auto;html=1;strokeColor=#C084FC;strokeWidth=2;"
    edge_blend = "edgeStyle=orthogonalEdgeStyle;rounded=1;orthogonalLoop=1;jettySize=auto;html=1;strokeColor=#3B82F6;strokeWidth=1.5;"
    edge_ci = "edgeStyle=orthogonalEdgeStyle;rounded=1;orthogonalLoop=1;jettySize=auto;html=1;strokeColor=#22C55E;strokeWidth=1.5;"
    edge_broken = "edgeStyle=orthogonalEdgeStyle;rounded=1;orthogonalLoop=1;jettySize=auto;html=1;strokeColor=#EF4444;strokeWidth=1.5;dashed=1;"

    # Connect Pages to Blends/Views
    add_edge("ep_v_details", "p_vendas_details", "b_vendas_detalhado", edge_page)
    add_edge("ep_v_site", "p_vendas_site", "b_roas_blend", edge_page)
    add_edge("ep_prod", "p_produtos", "b_produtos_giro", edge_page)
    add_edge("ep_est", "p_estoque", "b_estoque_consolidado", edge_page)
    add_edge("ep_exp", "p_expedicao", "b_expedicao_consolidada", edge_page)
    add_edge("ep_cli", "p_clientes", "b_crm_rfm", edge_page)
    add_edge("ep_nps", "p_nps", "b_chatbot_nps", edge_page)
    add_edge("ep_fin", "p_financeiro", "b_financeiro_consolidado", edge_page)

    # Connect Blends/Views to Datasets
    # Vendas Detalhado inputs
    add_edge("eb_vd_pv", "b_vendas_detalhado", "raw_pv", edge_blend)
    add_edge("eb_vd_pvi", "b_vendas_detalhado", "raw_pvi", edge_blend)
    add_edge("eb_vd_pvt", "b_vendas_detalhado", "raw_pvt", edge_blend)
    add_edge("eb_vd_prod", "b_vendas_detalhado", "raw_prod", edge_blend)
    add_edge("eb_vd_bc", "b_vendas_detalhado", "raw_bc", edge_blend)
    add_edge("eb_vd_cpe", "b_vendas_detalhado", "ci_cpe", edge_blend)

    # ROAS Blend inputs
    add_edge("eb_roas_diaria", "b_roas_blend", "raw_vis_diaria", edge_blend)
    add_edge("eb_roas_gads", "b_roas_blend", "raw_gads", edge_broken)
    add_edge("eb_roas_fb", "b_roas_blend", "raw_fbads", edge_blend)

    # Products inputs
    add_edge("eb_prod_aff", "b_produtos_giro", "ci_pro_affinity", edge_blend)
    add_edge("eb_prod_giro", "b_produtos_giro", "raw_prod", edge_blend)
    add_edge("eb_prod_depara", "b_produtos_giro", "ci_affinity", edge_blend)

    # Stock inputs
    add_edge("eb_est_real", "b_estoque_consolidado", "raw_prod", edge_blend)

    # Shipping inputs
    add_edge("eb_exp_pvt", "b_expedicao_consolidada", "raw_pvt", edge_blend)

    # CRM inputs
    add_edge("eb_crm_rfm_t", "b_crm_rfm", "ci_rfm", edge_blend)
    add_edge("eb_crm_360", "b_crm_rfm", "ci_360", edge_blend)
    add_edge("eb_crm_pred", "b_crm_rfm", "ci_pred", edge_blend)
    add_edge("eb_crm_geo", "b_crm_rfm", "ci_geo", edge_blend)

    # Chatbot inputs
    add_edge("eb_nps_chat", "b_chatbot_nps", "raw_chatbot", edge_blend)
    add_edge("eb_nps_wt", "b_chatbot_nps", "raw_wt", edge_blend)

    # Financial inputs
    add_edge("eb_fin_rec", "b_financeiro_consolidado", "raw_receber", edge_blend)
    add_edge("eb_fin_pag", "b_financeiro_consolidado", "raw_pagar", edge_blend)

    # Curated internal lineage connections
    add_edge("eci_cpe_360", "ci_cpe", "ci_360", edge_ci)
    add_edge("eci_360_rfm", "ci_360", "ci_rfm", edge_ci)
    add_edge("eci_rfm_pred", "ci_rfm", "ci_pred", edge_ci)
    add_edge("eci_aff_pro", "ci_affinity", "ci_pro_affinity", edge_ci)

    # Save to file
    tree = ET.ElementTree(mxfile)
    output_path = "/Users/renanstranodeoliveira/Downloads/aroom-health-bi-engine/docs/looker_studio_architecture.drawio"
    ET.indent(tree, space="  ", level=0)
    tree.write(output_path, encoding="utf-8", xml_declaration=True)
    print(f"Diagrama gerado com sucesso em: {output_path}")

if __name__ == "__main__":
    generate_xml()
