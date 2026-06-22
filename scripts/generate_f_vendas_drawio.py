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
        "id": "f_vendas_governance_process",
        "name": "Processo f_vendas (growth_engine_vendas_detalhado)"
    })
    
    graph_model = ET.SubElement(diagram, "mxGraphModel", {
        "dx": "1600",
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
        "pageWidth": "1400",
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
        "<b><font style='font-size: 20px' color='#0F172A'>RELAÇÃO ENTRE VIEW LÓGICA E TABELA FÍSICA (f_vendas / Fato)</font></b><br/>"
        "<font style='font-size: 13px' color='#64748B'>Como a view lógica <b>growth_engine_vendas_detalhado</b> se materializa na tabela fato física <b>f_vendas</b> para otimizar custos e performance no Looker.</font>"
    )
    add_node("title_box", title_html, "text;html=1;align=left;verticalAlign=middle;resizable=0;points=[];autosize=0;strokeColor=none;fillColor=none;", 40, 20, 1100, 50)

    # 1. Main Grouping Containers (Columns)
    add_node("grp_raw", "DADOS DE ORIGEM BRUTOS (Bling ERP / 2026)", group_style, 40, 100, 280, 780)
    add_node("grp_view", "REGRAS DE TRANSFORMAÇÃO (VIEW LÓGICA vs TABELA FISICA)", group_style, 360, 100, 680, 780)
    add_node("grp_looker", "CAMADA DE CONSUMO (LOOKER STUDIO)", group_style, 1080, 100, 280, 780)

    # 2. Raw Nodes (Column 1 - Left)
    raw_style = "rounded=1;whiteSpace=wrap;html=1;fillColor=#FAF5FF;strokeColor=#C084FC;strokeWidth=1.5;fontColor=#581C87;fontSize=11;fontFamily=Helvetica;align=left;spacingLeft=10;"
    raw_warning = "rounded=1;whiteSpace=wrap;html=1;fillColor=#FFFBEB;strokeColor=#D97706;strokeWidth=1.5;fontColor=#B45309;fontSize=11;fontFamily=Helvetica;align=left;spacingLeft=10;"
    raw_danger = "rounded=1;whiteSpace=wrap;html=1;fillColor=#FEE2E2;strokeColor=#EF4444;strokeWidth=1.5;fontColor=#991B1B;fontSize=11;fontFamily=Helvetica;align=left;spacingLeft=10;"
    
    add_node("r_pv", "📄 <b>pedidos_vendas (Bling)</b><br/>• Apenas vendas de 2026<br/>• Status cancelados misturados", raw_warning, 50, 140, 260, 60)
    add_node("r_pvi", "⚠️ <b>pedidos_vendas_itens (Bling)</b><br/>• <b>895 duplicatas físicas</b><br/>• SKUs faturados em 2026", raw_danger, 50, 230, 260, 65)
    add_node("r_pvt", "📄 <b>pedidos_vendas_transporte</b><br/>• Fretes cobrados em 2026<br/>• Risco de fan-out no join", raw_warning, 50, 325, 260, 60)
    add_node("r_prod", "📄 <b>produtos (Catálogo)</b><br/>• Apenas ativos (situacao = 'A')<br/>• 91.1% dos custos unitários zerados", raw_warning, 50, 415, 260, 60)
    add_node("r_bc", "📄 <b>bling_canais_venda</b><br/>• Canais de vendas do Bling", raw_style, 50, 505, 260, 50)
    add_node("r_cpe", "👤 <b>customer_profile_enriched</b><br/>• Distância CD, CEP, Renda", raw_style, 50, 585, 260, 55)

    # 3. View Processing Nodes (Column 2 - Middle)
    proc_style = "rounded=1;whiteSpace=wrap;html=1;fillColor=#EFF6FF;strokeColor=#3B82F6;strokeWidth=2;fontColor=#1D4ED8;fontSize=11;fontFamily=Helvetica;align=left;spacingLeft=10;"
    table_style = "rounded=1;whiteSpace=wrap;html=1;fillColor=#ECFDF5;strokeColor=#10B981;strokeWidth=2.5;fontColor=#065F46;fontSize=12;fontFamily=Helvetica;align=left;spacingLeft=15;"
    
    add_node("v_logic", "💎 <b>VIEW LÓGICA: growth_engine_vendas_detalhado</b><br/><br/>"
                        "• Contém toda a lógica e regras SQL de negócio:<br/>"
                        "  1. Filtra cancelados e ano 2026.<br/>"
                        "  2. Deduplica itens via ROW_NUMBER().<br/>"
                        "  3. Rateia frete proporcionalmente por item.<br/>"
                        "  4. Categoriza por regex de IA produtos nulos.<br/>"
                        "  5. Associa custos (COGS) de SKUs ativos ('A').<br/>"
                        "  6. Enriquece com as 6 dimensões SmartMetrics.", proc_style, 380, 140, 640, 160)
                        
    add_node("t_f_vendas", "🗄️ <b>TABELA FÍSICA FATO: f_vendas (Marts)</b><br/><br/>"
                           "• <b>Tabela Materializada Persistida diariamente (D-1)</b> via dbt/scheduled queries.<br/>"
                           "• Armazena os dados finais já processados e consolidados no grão de item.<br/>"
                           "• <b>Benefício:</b> Alta performance de carregamento e custo zero de execução de joins complexos no Looker Studio.", table_style, 380, 420, 640, 130)

    # 4. Looker Studio Node (Column 3 - Right)
    looker_style = "rounded=1;whiteSpace=wrap;html=1;fillColor=#E8F5E9;strokeColor=#2E7D32;strokeWidth=2.5;fontColor=#1B5E20;fontSize=11;fontFamily=Helvetica;align=left;spacingLeft=15;"
    
    looker_html = (
        "📊 <b>Looker Studio: Dashboard</b><br/><br/>"
        "• Conectado a: <b>f_vendas</b> (Tabela)<br/>"
        "• <b>Carregamento instantâneo</b> de gráficos<br/>"
        "• Apenas produtos ativos e ano 2026<br/>"
        "• Sem re-execução de joins ou regex<br/>"
        "• Faturamento Auditado: R$ 9.54M"
    )
    add_node("l_sales", looker_html, looker_style, 1100, 385, 240, 200)

    # 5. Legend and Info box (X = 40, Y = 900)
    legend_text = (
        "<b>RELAÇÃO ENTRE CAMADA LÓGICA E FÍSICA DA FATO DE VENDAS</b><br/>"
        "• <font color='#1D4ED8'><b>Azul (View Lógica / Transformação):</b></font> Onde reside o código SQL complexo. Não deve ser lido diretamente pelo Looker Studio para evitar lentidão e custos.<br/>"
        "• <font color='#065F46'><b>Verde Escuro (Tabela Física / Persistência):</b></font> A fato materializada (Mart) que armazena os dados limpos fisicamente. Otimiza o desempenho do painel.<br/>"
        "• <font color='#1B5E20'><b>Verde Claro (Looker Studio / Consumo):</b></font> Camada de visualização apontando para a fato persistida f_vendas."
    )
    add_node("legend_box", legend_text, "rounded=1;whiteSpace=wrap;html=1;fillColor=#F8FAFC;strokeColor=#E2E8F0;strokeWidth=2;align=left;spacingLeft=15;fontSize=12;fontColor=#334155;fontFamily=Helvetica;spacingTop=5;", 40, 900, 1320, 150)

    # --- EDGES / CONNECTIONS ---
    edge_raw_proc = "edgeStyle=orthogonalEdgeStyle;rounded=1;orthogonalLoop=1;jettySize=auto;html=1;strokeColor=#C084FC;strokeWidth=1.5;dashed=1;"
    edge_flow = "edgeStyle=orthogonalEdgeStyle;rounded=1;orthogonalLoop=1;jettySize=auto;html=1;strokeColor=#3B82F6;strokeWidth=2;"
    edge_materialize = "edgeStyle=orthogonalEdgeStyle;rounded=1;orthogonalLoop=1;jettySize=auto;html=1;strokeColor=#10B981;strokeWidth=2.5;labelBackgroundColor=none;fontColor=#047857;"
    edge_looker = "edgeStyle=orthogonalEdgeStyle;rounded=1;orthogonalLoop=1;jettySize=auto;html=1;strokeColor=#2E7D32;strokeWidth=2.5;"

    # Connect Raw inputs to the View
    add_edge("er_pv", "r_pv", "v_logic", edge_raw_proc)
    add_edge("er_pvi", "r_pvi", "v_logic", edge_raw_proc)
    add_edge("er_pvt", "r_pvt", "v_logic", edge_raw_proc)
    add_edge("er_prod", "r_prod", "v_logic", edge_raw_proc)
    add_edge("er_bc", "r_bc", "v_logic", edge_raw_proc)
    add_edge("er_cpe", "r_cpe", "v_logic", edge_raw_proc)

    # Materialization Connection (View logic to physical table)
    add_edge("e_materialize", "v_logic", "t_f_vendas", edge_materialize, "Materialização diária (dbt run)")

    # Connect physical table to Looker
    add_edge("el_looker", "t_f_vendas", "l_sales", edge_looker)

    # Save to file
    tree = ET.ElementTree(mxfile)
    output_path = "/Users/renanstranodeoliveira/Downloads/aroom-health-bi-engine/docs/looker_studio_f_vendas_architecture.drawio"
    ET.indent(tree, space="  ", level=0)
    tree.write(output_path, encoding="utf-8", xml_declaration=True)
    print(f"Diagrama gerado com sucesso em: {output_path}")

if __name__ == "__main__":
    generate_xml()
