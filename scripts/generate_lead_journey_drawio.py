"""
generate_lead_journey_drawio.py
================================
Gera o arquivo draw.io (XML) da jornada do lead:
  Frontend (GA4 + Email CRM) → Backend (Nuvemshop/Checkout) → Bling ERP

Uso:
    python scripts/generate_lead_journey_drawio.py

Saída:
    docs/lead_journey_data_model.drawio

Abrir no draw.io:
    1. Acesse app.diagrams.net (ou draw.io desktop)
    2. File → Open → selecione o arquivo .drawio
    OU
    3. Arraste o arquivo para a janela do draw.io
"""

import textwrap

# ─────────────────────────────────────────────────────────────────────────────
# HELPERS
# ─────────────────────────────────────────────────────────────────────────────

def esc(text: str) -> str:
    """Escapa caracteres especiais para XML."""
    return (text
            .replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace('"', "&quot;"))


_id_counter = 1

def new_id() -> str:
    global _id_counter
    _id_counter += 1
    return str(_id_counter)


def cell(cid, value, style, x, y, w, h, parent="1", vertex="1", edge="0",
         source="", target="", extra_attrs=""):
    src = f'source="{source}" ' if source else ""
    tgt = f'target="{target}" ' if target else ""
    vtx = f'vertex="{vertex}" ' if vertex else ""
    edg = f'edge="{edge}" ' if edge else ""
    return (
        f'    <mxCell id="{cid}" value="{esc(value)}" style="{style}" '
        f'parent="{parent}" {vtx}{edg}{src}{tgt}{extra_attrs}>\n'
        f'      <mxGeometry x="{x}" y="{y}" width="{w}" height="{h}" as="geometry"/>\n'
        f'    </mxCell>\n'
    )


def edge_cell(cid, value, style, source, target, parent="1",
              ex_x=None, ex_y=None):
    pts = ""
    if ex_x is not None:
        pts = f'\n      <Array as="points"><mxPoint x="{ex_x}" y="{ex_y}"/></Array>'
    return (
        f'    <mxCell id="{cid}" value="{esc(value)}" style="{style}" '
        f'parent="{parent}" source="{source}" target="{target}" edge="1">\n'
        f'      <mxGeometry relative="1" as="geometry"/>{pts}\n'
        f'    </mxCell>\n'
    )


# ─────────────────────────────────────────────────────────────────────────────
# STYLES
# ─────────────────────────────────────────────────────────────────────────────

STYLE_SWIMLANE_FRONT = (
    "swimlane;startSize=30;fillColor=#1a2744;strokeColor=#3b82f6;"
    "fontColor=#ffffff;fontSize=13;fontStyle=1;swimlaneLine=1;"
    "strokeWidth=2;rounded=1;"
)
STYLE_SWIMLANE_BACK = (
    "swimlane;startSize=30;fillColor=#0f2b2b;strokeColor=#14b8a6;"
    "fontColor=#ffffff;fontSize=13;fontStyle=1;swimlaneLine=1;"
    "strokeWidth=2;rounded=1;"
)
STYLE_SWIMLANE_BLING = (
    "swimlane;startSize=30;fillColor=#0f2b1a;strokeColor=#22c55e;"
    "fontColor=#ffffff;fontSize=13;fontStyle=1;swimlaneLine=1;"
    "strokeWidth=2;rounded=1;"
)

STYLE_BOX_ADS = (
    "rounded=1;whiteSpace=wrap;html=1;fillColor=#f59e0b;strokeColor=#d97706;"
    "fontColor=#000000;fontSize=11;fontStyle=1;align=center;"
)
STYLE_BOX_GA4 = (
    "rounded=1;whiteSpace=wrap;html=1;fillColor=#1d4ed8;strokeColor=#3b82f6;"
    "fontColor=#ffffff;fontSize=10;align=left;verticalAlign=top;"
)
STYLE_BOX_FUNNEL = (
    "rounded=1;whiteSpace=wrap;html=1;fillColor=#166534;strokeColor=#22c55e;"
    "fontColor=#ffffff;fontSize=10;align=center;fontStyle=1;"
)
STYLE_BOX_EMAIL = (
    "rounded=1;whiteSpace=wrap;html=1;fillColor=#5b21b6;strokeColor=#8b5cf6;"
    "fontColor=#ffffff;fontSize=10;align=left;verticalAlign=top;"
)
STYLE_BOX_TEAL = (
    "rounded=1;whiteSpace=wrap;html=1;fillColor=#0d4b4b;strokeColor=#14b8a6;"
    "fontColor=#ffffff;fontSize=10;align=left;verticalAlign=top;"
)
STYLE_BOX_GREEN = (
    "rounded=1;whiteSpace=wrap;html=1;fillColor=#14532d;strokeColor=#22c55e;"
    "fontColor=#ffffff;fontSize=10;align=left;verticalAlign=top;"
)
STYLE_BOX_GREEN_MAIN = (
    "rounded=1;whiteSpace=wrap;html=1;fillColor=#14532d;strokeColor=#22c55e;"
    "fontColor=#ffffff;fontSize=11;align=left;verticalAlign=top;fontStyle=1;"
    "strokeWidth=2;"
)
STYLE_BOX_WARN = (
    "rounded=1;whiteSpace=wrap;html=1;fillColor=#7c2d12;strokeColor=#f97316;"
    "fontColor=#ffffff;fontSize=10;align=left;verticalAlign=top;"
)

EDGE_INTERNAL = (
    "edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;"
    "strokeColor=#22c55e;strokeWidth=2;exitX=1;exitY=0.5;entryX=0;entryY=0.5;"
    "fontColor=#ffffff;fontSize=9;"
)
EDGE_BRIDGE_HIGH = (
    "edgeStyle=orthogonalEdgeStyle;rounded=1;orthogonalLoop=1;"
    "strokeColor=#22c55e;strokeWidth=2;dashed=0;"
    "fontColor=#22c55e;fontSize=9;fontStyle=1;endArrow=block;endFill=1;"
)
EDGE_BRIDGE_MED = (
    "edgeStyle=orthogonalEdgeStyle;rounded=1;orthogonalLoop=1;"
    "strokeColor=#f59e0b;strokeWidth=2;dashed=1;dashPattern=8 4;"
    "fontColor=#f59e0b;fontSize=9;fontStyle=1;endArrow=block;endFill=1;"
)
EDGE_ARROW_PLAIN = (
    "edgeStyle=orthogonalEdgeStyle;rounded=0;strokeColor=#94a3b8;"
    "strokeWidth=1;fontColor=#ffffff;fontSize=9;"
)
EDGE_UTM = (
    "edgeStyle=orthogonalEdgeStyle;rounded=1;strokeColor=#f59e0b;"
    "strokeWidth=2;fontColor=#f59e0b;fontSize=9;fontStyle=1;"
)


# ─────────────────────────────────────────────────────────────────────────────
# BUILD DIAGRAM
# ─────────────────────────────────────────────────────────────────────────────

def build_diagram() -> str:
    cells = []

    # ── Swimlane coords ──────────────────────────────────────────────────────
    SW_X, SW_W = 30, 1300
    FRONT_Y,  FRONT_H  = 40,  320
    BACK_Y,   BACK_H   = 400, 220
    BLING_Y,  BLING_H  = 660, 300

    # ── IDs ──────────────────────────────────────────────────────────────────
    id_sw_front  = new_id()
    id_sw_back   = new_id()
    id_sw_bling  = new_id()

    id_ads       = new_id()
    id_ga4       = new_id()
    id_funnel    = new_id()
    id_perfit    = new_id()
    id_dispatch  = new_id()

    id_checkout  = new_id()
    id_ns_ped    = new_id()
    id_ns_prod   = new_id()

    id_pv        = new_id()   # pedidos_vendas
    id_pvi       = new_id()   # pedidos_vendas_itens
    id_prod      = new_id()   # produtos
    id_contato   = new_id()   # contato
    id_nf        = new_id()   # notas_fiscais_saida

    # ─── SWIMLANES ────────────────────────────────────────────────────────────
    cells.append(cell(id_sw_front, "LAYER 1 — FRONTEND (Comportamento Digital)",
                      STYLE_SWIMLANE_FRONT, SW_X, FRONT_Y, SW_W, FRONT_H))
    cells.append(cell(id_sw_back,  "LAYER 2 — BACKEND / E-COMMERCE (Nuvemshop + Checkout)",
                      STYLE_SWIMLANE_BACK,  SW_X, BACK_Y,  SW_W, BACK_H))
    cells.append(cell(id_sw_bling, "LAYER 3 — BLING ERP (Fonte de Verdade | R$ 9.538.019)",
                      STYLE_SWIMLANE_BLING, SW_X, BLING_Y, SW_W, BLING_H))

    # ─── FRONTEND boxes (relative to swimlane parent) ────────────────────────
    ga4_fields = (
        "GA4 events_YYYYMMDD\n"
        "─────────────────────\n"
        "event_name\n"
        "user_pseudo_id\n"
        "traffic_source.source\n"
        "traffic_source.medium\n"
        "event_params[transaction_id]\n"
        "─────────────────────\n"
        "185.602 eventos | 18 dias\n"
        "266 purchase | 17.881 sessions"
    )
    perfit_fields = (
        "perfit_campaign_actions\n"
        "─────────────────────\n"
        "campaign_id\n"
        "action_type (SENT/OPEN/CLICK)\n"
        "contact_email  ← bridge\n"
        "action_at\n"
        "─────────────────────\n"
        "297.434 eventos | 6.656 emails"
    )
    dispatch_fields = (
        "dispatch_send_log\n"
        "─────────────────────\n"
        "contact_id  ← FK direta\n"
        "rule_tag (aniversario, etc)\n"
        "anchor_date | sent_at\n"
        "─────────────────────\n"
        "22.376 envios | 4 automações"
    )

    cells.append(cell(id_ads, "Google / Meta Ads\nUTM params →",
                      STYLE_BOX_ADS, 60, 50, 160, 60, parent=id_sw_front))
    cells.append(cell(id_ga4, ga4_fields,
                      STYLE_BOX_GA4, 250, 40, 260, 200, parent=id_sw_front))
    cells.append(cell(id_funnel,
                      "page_view  →  view_item  →  add_to_cart  →  begin_checkout  →  PURCHASE ✓",
                      STYLE_BOX_FUNNEL, 250, 255, 540, 40, parent=id_sw_front))
    cells.append(cell(id_perfit, perfit_fields,
                      STYLE_BOX_EMAIL, 850, 40, 210, 160, parent=id_sw_front))
    cells.append(cell(id_dispatch, dispatch_fields,
                      STYLE_BOX_EMAIL, 1075, 40, 200, 160, parent=id_sw_front))

    # ─── BACKEND boxes ───────────────────────────────────────────────────────
    checkout_fields = (
        "checkout\n"
        "─────────────────────\n"
        "token  ← bridge\n"
        "contact_email  ← bridge\n"
        "store_id\n"
        "contact_identification\n"
        "─────────────────────\n"
        "2.568 carrinhos | 2.294 emails"
    )
    ns_ped_fields = (
        "nuvemshop_pedidos\n"
        "─────────────────────\n"
        "token  ← bridge\n"
        "store_id  ← bridge Bling\n"
        "customer_id\n"
        "contact_email\n"
        "payment_status\n"
        "fulfillment_status\n"
        "─────────────────────\n"
        "19.915 pedidos | 16.882 clientes"
    )
    ns_prod_fields = (
        "nuvemshop_pedido_produto\n"
        "─────────────────────\n"
        "pedido_id  FK\n"
        "sku | name\n"
        "quantity | price\n"
        "─────────────────────\n"
        "48.690 itens"
    )

    cells.append(cell(id_checkout, checkout_fields,
                      STYLE_BOX_TEAL, 60, 50, 230, 160, parent=id_sw_back))
    cells.append(cell(id_ns_ped, ns_ped_fields,
                      STYLE_BOX_TEAL, 340, 50, 240, 160, parent=id_sw_back))
    cells.append(cell(id_ns_prod, ns_prod_fields,
                      STYLE_BOX_TEAL, 640, 50, 210, 130, parent=id_sw_back))

    # ─── BLING boxes ─────────────────────────────────────────────────────────
    pv_fields = (
        "pedidos_vendas\n"
        "─────────────────────\n"
        "identificador  PK\n"
        "numero  ← transactionId\n"
        "loja_id  FK → canais_venda\n"
        "contato_id  FK → contato\n"
        "nota_fiscal_id  FK\n"
        "data | total\n"
        "─────────────────────\n"
        "130.135 pedidos\n"
        "R$ 9.538.019 (fonte de verdade)"
    )
    pvi_fields = (
        "pedidos_vendas_itens\n"
        "─────────────────────\n"
        "pedidos_vendas_identificador  FK\n"
        "codigo  FK → produtos\n"
        "descricao | quantidade\n"
        "valor\n"
        "─────────────────────\n"
        "187.875 itens\n"
        "R$ 9.054.613"
    )
    prod_fields = (
        "produtos\n"
        "─────────────────────\n"
        "identificador  PK\n"
        "codigo  PK\n"
        "nome | situacao\n"
        "preco\n"
        "─────────────────────\n"
        "9.751 total | 1.730 ativos\n"
        "⚠️ 510 SKUs faltantes\n"
        "(R$ 95.170 sem cadastro)"
    )
    contato_fields = (
        "contato\n"
        "─────────────────────\n"
        "identificador  PK\n"
        "email  ← bridge email\n"
        "nome\n"
        "numero_documento\n"
        "─────────────────────\n"
        "120.479 clientes"
    )
    nf_fields = (
        "notas_fiscais_saida\n"
        "─────────────────────\n"
        "identificador  PK\n"
        "numero NF\n"
        "data_emissao\n"
        "loja_id\n"
        "─────────────────────\n"
        "73.286 notas fiscais"
    )

    cells.append(cell(id_pv, pv_fields,
                      STYLE_BOX_GREEN_MAIN, 60, 50, 240, 230, parent=id_sw_bling))
    cells.append(cell(id_pvi, pvi_fields,
                      STYLE_BOX_GREEN, 360, 50, 230, 180, parent=id_sw_bling))
    cells.append(cell(id_prod, prod_fields,
                      STYLE_BOX_WARN, 650, 50, 220, 180, parent=id_sw_bling))
    cells.append(cell(id_contato, contato_fields,
                      STYLE_BOX_GREEN, 360, 250, 200, 150, parent=id_sw_bling))
    cells.append(cell(id_nf, nf_fields,
                      STYLE_BOX_GREEN, 650, 250, 200, 150, parent=id_sw_bling))

    # ─── INTERNAL EDGES ──────────────────────────────────────────────────────
    # Ads → GA4
    cells.append(edge_cell(new_id(), "UTM params", EDGE_UTM,
                            id_ads, id_ga4, parent=id_sw_front))
    # GA4 → funnel
    cells.append(edge_cell(new_id(), "", EDGE_ARROW_PLAIN,
                            id_ga4, id_funnel, parent=id_sw_front))
    # perfit → dispatch (visual grouping)
    cells.append(edge_cell(new_id(), "", EDGE_ARROW_PLAIN,
                            id_perfit, id_dispatch, parent=id_sw_front))

    # checkout → nuvemshop_pedidos
    cells.append(edge_cell(new_id(), "token", EDGE_BRIDGE_MED,
                            id_checkout, id_ns_ped, parent=id_sw_back))
    # nuvemshop_pedidos → nuvemshop_pedido_produto
    cells.append(edge_cell(new_id(), "id → pedido_id", EDGE_INTERNAL,
                            id_ns_ped, id_ns_prod, parent=id_sw_back))

    # pedidos_vendas → pedidos_vendas_itens
    cells.append(edge_cell(new_id(), "identificador →", EDGE_INTERNAL,
                            id_pv, id_pvi, parent=id_sw_bling))
    # pedidos_vendas_itens → produtos
    cells.append(edge_cell(new_id(), "codigo → codigo", EDGE_INTERNAL,
                            id_pvi, id_prod, parent=id_sw_bling))
    # pedidos_vendas → contato
    cells.append(edge_cell(new_id(), "contato_id →", EDGE_INTERNAL,
                            id_pv, id_contato, parent=id_sw_bling))
    # pedidos_vendas → notas_fiscais
    cells.append(edge_cell(new_id(), "nota_fiscal_id →", EDGE_INTERNAL,
                            id_pv, id_nf, parent=id_sw_bling))

    # ─── BRIDGE EDGES (entre swimlanes — usam parent="1") ────────────────────
    # GA4 purchase → pedidos_vendas  [MÉDIA 20.5%]
    cells.append(edge_cell(new_id(),
                            "transactionId = numero\n[MÉDIA · 20.5% cobertura]",
                            EDGE_BRIDGE_MED, id_ga4, id_pv))

    # nuvemshop_pedidos → pedidos_vendas  [ALTA]
    cells.append(edge_cell(new_id(),
                            "store_id = loja_id\n[ALTA ✓ · R$ 2.85M confirmado]",
                            EDGE_BRIDGE_HIGH, id_ns_ped, id_pv))

    # perfit_actions → contato  [ALTA 75%]
    cells.append(edge_cell(new_id(),
                            "contact_email = email\n[ALTA · 75% · 4.994 clientes]",
                            EDGE_BRIDGE_HIGH, id_perfit, id_contato))

    # dispatch_send_log → contato  [ALTA 100% FK]
    cells.append(edge_cell(new_id(),
                            "contact_id = identificador\n[ALTA · 100% · FK direta]",
                            EDGE_BRIDGE_HIGH, id_dispatch, id_contato))

    # checkout.contact_email → contato  [MÉDIA]
    cells.append(edge_cell(new_id(),
                            "contact_email = email\n[MÉDIA · bridge potencial]",
                            EDGE_BRIDGE_MED, id_checkout, id_contato))

    # ─── LEGEND ──────────────────────────────────────────────────────────────
    legend_style = (
        "text;html=1;strokeColor=none;fillColor=none;"
        "align=left;verticalAlign=middle;whiteSpace=wrap;"
        "fontColor=#ffffff;fontSize=11;"
    )
    legend_text = (
        "<b>Legenda de Confiança das Pontes:</b><br/>"
        "── Verde sólida → ALTA confiança (FK nativa ou match >70%)<br/>"
        "── Amarela tracejada → MÉDIA confiança (cobertura parcial ou não validado)<br/>"
        "⚠️ Laranja → SKU faltante (510 SKUs / R$ 95.170 sem cadastro no produtos)"
    )
    cells.append(cell(new_id(), legend_text, legend_style,
                      SW_X, BLING_Y + BLING_H + 20, SW_W, 60))

    return cells


# ─────────────────────────────────────────────────────────────────────────────
# ASSEMBLE XML
# ─────────────────────────────────────────────────────────────────────────────

def generate_xml(cells: list) -> str:
    body = "".join(cells)
    return textwrap.dedent(f"""\
        <?xml version="1.0" encoding="UTF-8"?>
        <mxGraphModel dx="1422" dy="762" grid="1" gridSize="10" guides="1"
          tooltips="1" connect="1" arrows="1" fold="1" page="0"
          pageScale="1" pageWidth="1654" pageHeight="1169"
          math="0" shadow="0" background="#0f1117">
          <root>
            <mxCell id="0"/>
            <mxCell id="1" parent="0"/>
        {body}
          </root>
        </mxGraphModel>
    """)


# ─────────────────────────────────────────────────────────────────────────────
# MAIN
# ─────────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    import os
    import sys

    output_path = os.path.join(
        os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
        "docs", "lead_journey_data_model.drawio"
    )

    cells = build_diagram()
    xml = generate_xml(cells)

    with open(output_path, "w", encoding="utf-8") as f:
        f.write(xml)

    print(f"✅ Diagrama gerado: {output_path}")
    print(f"   Tamanho: {os.path.getsize(output_path):,} bytes")
    print()
    print("Como abrir:")
    print("  1. Acesse https://app.diagrams.net")
    print("  2. File → Open → selecione lead_journey_data_model.drawio")
    print("  OU")
    print("  3. Arraste o arquivo para a janela do draw.io")
