# generate_v2.py — Draw.io diagram com 5 swimlanes e todos os detalhes
import os

_id = 10
def nid():
    global _id
    _id += 1
    return str(_id)

def esc(t):
    return t.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace('"',"&quot;").replace("\n","&#xa;")

def box(cid, val, style, x, y, w, h, parent="1"):
    return f'<mxCell id="{cid}" value="{esc(val)}" style="{style}" parent="{parent}" vertex="1"><mxGeometry x="{x}" y="{y}" width="{w}" height="{h}" as="geometry"/></mxCell>\n'

def arrow(cid, val, style, src, tgt, parent="1"):
    return f'<mxCell id="{cid}" value="{esc(val)}" style="{style}" parent="{parent}" source="{src}" target="{tgt}" edge="1"><mxGeometry relative="1" as="geometry"/></mxCell>\n'

# Styles
SW   = "swimlane;startSize=32;fontStyle=1;fontSize=12;strokeWidth=2;rounded=1;"
TBL  = "rounded=1;whiteSpace=wrap;html=0;align=left;verticalAlign=top;fontSize=10;spacingLeft=6;spacingTop=4;"
EDGE_H = "edgeStyle=orthogonalEdgeStyle;strokeColor=#22c55e;strokeWidth=2;fontColor=#22c55e;fontSize=9;fontStyle=1;endArrow=block;endFill=1;"
EDGE_M = "edgeStyle=orthogonalEdgeStyle;strokeColor=#f59e0b;strokeWidth=2;dashed=1;dashPattern=8 4;fontColor=#f59e0b;fontSize=9;fontStyle=1;endArrow=block;endFill=1;"
EDGE_X = "edgeStyle=orthogonalEdgeStyle;strokeColor=#ef4444;strokeWidth=2;dashed=1;fontColor=#ef4444;fontSize=9;fontStyle=1;endArrow=block;endFill=1;"
EDGE_I = "edgeStyle=orthogonalEdgeStyle;strokeColor=#94a3b8;strokeWidth=1;fontColor=#94a3b8;fontSize=9;"

def sw_style(color, border):
    return f"swimlane;startSize=32;fontStyle=1;fontSize=13;strokeColor={border};fillColor={color};fontColor=#ffffff;strokeWidth=2;rounded=1;"

def tbl_style(fill, border):
    return f"rounded=1;whiteSpace=wrap;html=0;align=left;verticalAlign=top;fontSize=10;spacingLeft=6;spacingTop=4;fillColor={fill};strokeColor={border};fontColor=#ffffff;strokeWidth=1.5;"

cells = []

# ─── SWIMLANE Y positions ───────────────────────────────────────────
Y0, H0 = 20,  180   # Layer 0: Ads
Y1, H1 = 220, 360   # Layer 1: Frontend GA4
Y2, H2 = 600, 320   # Layer 2: Backend
Y3, H3 = 940, 420   # Layer 3: Bling ERP
Y4, H4 = 1380, 300  # Layer 4: Customer Intelligence
SX, SW_W = 20, 1560

# ─── IDs ────────────────────────────────────────────────────────────
s0=nid(); s1=nid(); s2=nid(); s3=nid(); s4=nid()
gads=nid(); meta=nid(); mktplace=nid()
ga4=nid(); funnel=nid(); ga4rec=nid(); utm_daily=nid(); rev_daily=nid()
perfit=nid(); dispatch=nid()
chk=nid(); ns=nid(); nsprod=nid()
pv=nid(); pvi=nid(); prod=nid(); cont=nid(); nf=nid(); canais=nid(); estoque=nid()
c360=nid(); rfm=nid(); views=nid(); ml=nid()

# ─── SWIMLANES ──────────────────────────────────────────────────────
cells.append(box(s0,"🎯  LAYER 0 — AQUISICAO (Paid Media)",sw_style("#78350f","#f59e0b"),SX,Y0,SW_W,H0))
cells.append(box(s1,"🌐  LAYER 1 — FRONTEND (GA4 + Email CRM)",sw_style("#1e3a8a","#3b82f6"),SX,Y1,SW_W,H1))
cells.append(box(s2,"🛒  LAYER 2 — BACKEND / E-COMMERCE (Nuvemshop + Checkout)",sw_style("#134e4a","#14b8a6"),SX,Y2,SW_W,H2))
cells.append(box(s3,"🏦  LAYER 3 — BLING ERP (Fonte de Verdade | R$ 9.538.019)",sw_style("#14532d","#22c55e"),SX,Y3,SW_W,H3))
cells.append(box(s4,"🧠  LAYER 4 — CUSTOMER INTELLIGENCE + CRM",sw_style("#3b0764","#a855f7"),SX,Y4,SW_W,H4))

# ─── LAYER 0: ADS ───────────────────────────────────────────────────
cells.append(box(gads,
  "GOOGLE ADS\n[PK] campaign_id STRING\ncampaign_name STRING\ncost_micros INT64\nimpressions INT64 / clicks INT64\n─────────────────\nOutbound: utm_campaign → GA4\nBadge: pmax_roas_formula-exclusiva",
  tbl_style("#92400e","#f59e0b"),80,50,310,120,parent=s0))

cells.append(box(meta,
  "META / INSTAGRAM ADS\n[PK] campaign_id STRING (numerico)\nspend NUMERIC / impressions INT64\ndate_start DATE\n─────────────────\nOutbound: utm_source=ig → GA4\nCampanha: 120209681087360703",
  tbl_style("#1e3a8a","#3b82f6"),450,50,310,120,parent=s0))

cells.append(box(mktplace,
  "SHOPEE / ML / TIKTOK\ncanal STRING (sem UTM tracking)\nspend por canal\n─────────────────\n⚠️ SEM rastreio GA4\nChega direto no Bling via integracao",
  tbl_style("#374151","#6b7280"),820,50,310,120,parent=s0))

# ─── LAYER 1: FRONTEND ──────────────────────────────────────────────
cells.append(box(ga4,
  "GA4 events_YYYYMMDD\n[PK] user_pseudo_id STRING (cookie)\nevent_name STRING\nevent_date STRING (particao)\ntraffic_source.source STRING 99.7%\ntraffic_source.medium STRING 99.7%\ntraffic_source.name STRING (campaign)\n[FK→Bling] event_params[transaction_id] ⚠️\ndevice.category STRING\ngeo.country / region / city STRING\n─────────────────\n185.602 eventos | 18 dias | Nov/25–Jun/26\n266 purchase | 17.881 sessions",
  tbl_style("#1e40af","#3b82f6"),80,50,310,250,parent=s1))

cells.append(box(funnel,
  "FUNIL GA4\nsession_start: 17.881\nview_item: 3.673\nadd_to_cart: 3.673\nbegin_checkout: 431\nPURCHASE: 266\n─────────────────\n⚠️ transaction_id NULL em 79.5%",
  tbl_style("#166534","#22c55e"),450,50,230,220,parent=s1))

cells.append(box(ga4rec,
  "ga4_recovery_ecommerce\n[PK] transactionId STRING\nsession_source STRING\nsession_medium STRING\npurchase_revenue NUMERIC\n─────────────────\n4.955 transacoes | R$ 512.023\n[FK→Bling] transactionId=numero",
  tbl_style("#065f46","#10b981"),740,50,240,190,parent=s1))

cells.append(box(utm_daily,
  "ga4_utm_daily\n[PK] metric_date DATE\nsession_campaign_name STRING\nsession_source STRING\nsession_medium STRING\npurchases INT64\npurchase_revenue NUMERIC\n─────────────────\n21.266 linhas | Jan/25–Jun/26",
  tbl_style("#134e4a","#0d9488"),80,270,230,160,parent=s1))

cells.append(box(rev_daily,
  "ga4_revenue_channel_daily\n[PK] metric_date DATE\nchannel_group STRING\npurchase_revenue NUMERIC\nROAS NUMERIC\n─────────────────\nR$ 1.68M | por canal\n8.444 linhas",
  tbl_style("#134e4a","#0d9488"),350,270,230,160,parent=s1))

cells.append(box(perfit,
  "perfit_campaign_actions\n[PK] id INT64\n[FK] campaign_id INT64\naction_type STRING ENUM\n  SENT 56.9% / OPEN 40.7%\n  CLICK 1.9% / BOUNCE 0.1%\n[FK→Bling] contact_email STRING 100%\naction_at DATETIME\n─────────────────\n297.434 eventos | 6.656 emails unicos",
  tbl_style("#4c1d95","#7c3aed"),1000,50,270,220,parent=s1))

cells.append(box(dispatch,
  "dispatch_send_log\n[PK] id INT64\n[FK→Bling] contact_id INT64 100%\nrule_tag STRING ENUM\n  aniversario\n  sinto_sua_falta\n  produto_acabando_cliente\n  sinto_sua_falta_2\nanchor_date DATE | sent_at DATETIME\n─────────────────\n22.376 envios | 15.941 clientes | 4 regras",
  tbl_style("#4c1d95","#7c3aed"),1300,50,240,220,parent=s1))

# ─── LAYER 2: BACKEND ───────────────────────────────────────────────
cells.append(box(chk,
  "checkout\n[PK] token STRING 100% (ID unico carrinho)\ncontact_email STRING 100% ← bridge\ncontact_identification STRING 100% (CPF)\nstore_id INT64 100% = 2537710\nshipping_zipcode STRING 100%\ncreated_at DATETIME\n─────────────────\n2.568 carrinhos | 2.294 emails unicos\n⚠️ 87.5% NAO converte em pedido",
  tbl_style("#0f3b3b","#14b8a6"),80,50,300,220,parent=s2))

cells.append(box(ns,
  "nuvemshop_pedidos\n[PK] token STRING 100% (ID pedido)\ncustomer_id INT64 100% ← ID Nuvemshop\ncontact_email STRING 100% ← bridge\ncontact_identification STRING 100% (CPF)\nstore_id INT64 100% = 2537710 ← bridge\npayment_status STRING paid=93.6%\nfulfillment_status STRING ⚠️ 0% VAZIO\nshipping_address RECORD\n─────────────────\n19.915 pedidos | 16.882 clientes | Jan/25–Jun/26",
  tbl_style("#0f3b3b","#14b8a6"),450,50,320,250,parent=s2))

cells.append(box(nsprod,
  "nuvemshop_pedido_produto\n[PK] id INT64\n[FK] pedido_id INT64 → nuvemshop_pedidos\nsku STRING ← bridge catalogo\nname STRING\nquantity INT64\nprice NUMERIC\n─────────────────\n48.690 itens",
  tbl_style("#0f3b3b","#14b8a6"),850,50,260,190,parent=s2))

# ─── LAYER 3: BLING ─────────────────────────────────────────────────
cells.append(box(pv,
  "pedidos_vendas  ★ FONTE DE VERDADE\n[PK] identificador INT64 100%\n[UK] numero INT64 100% ← transactionId GA4\n[FK] loja_id INT64 100% ← canais_venda\n[FK] contato_id INT64 100% ⚠️ SCHEMA MISMATCH\n[FK] nota_fiscal_id INT64 99.99%\n[FK] vendedor_id INT64 99.99%\ndata DATE | total NUMERIC\nnumero_pedido_compra STRING 0.2%\n─────────────────\n130.135 pedidos | R$ 9.538.019 | 48 lojas\n🔴 contato_id ≠ contato.identificador (0% join)",
  tbl_style("#14532d","#22c55e"),80,50,340,290,parent=s3))

cells.append(box(pvi,
  "pedidos_vendas_itens\n[PK] id INT64\n[FK] pedidos_vendas_identificador INT64\n[FK] codigo STRING ← produtos.codigo\n[FK] produto_id INT64 ← produtos.identificador\ndescricao STRING\nquantidade NUMERIC\nvalor NUMERIC\n─────────────────\n187.875 itens | R$ 9.054.613",
  tbl_style("#14532d","#22c55e"),500,50,290,220,parent=s3))

cells.append(box(prod,
  "produtos\n[PK] identificador INT64\n[UK] codigo STRING ⚠️ 48.3% fill\nnome STRING | preco NUMERIC\nsituacao STRING: A=1.730 / I / E\n─────────────────\n9.751 total | 1.730 ativos\n⚠️ 510 SKUs vendidos sem cadastro\nImpacto: R$ 95.170 sem margem",
  tbl_style("#7c2d12","#f97316"),860,50,270,200,parent=s3))

cells.append(box(cont,
  "contato\n[PK] identificador INT64 ← LONG ID\nnome STRING 100%\nemail STRING ⚠️ 64.7% fill\nnumero_documento STRING 95.0% (CPF) ✓\ntelefone STRING ⚠️ 33.8% fill\nendereco RECORD\n─────────────────\n120.479 clientes\n⚠️ 42.588 sem email (35.3%)\n⚠️ 6.068 sem CPF (5.0%)",
  tbl_style("#14532d","#22c55e"),500,290,290,220,parent=s3))

cells.append(box(nf,
  "notas_fiscais_saida\n[PK] identificador INT64\n[UK] numero STRING 100%\ndata_emissao DATE\nchave_acesso STRING 100% (44 dig)\nloja_id INT64\nsituacao STRING\n─────────────────\n73.286 NFs | 56.3% dos pedidos\n✓ cobertura quase completa",
  tbl_style("#14532d","#22c55e"),860,290,270,200,parent=s3))

cells.append(box(canais,
  "bling_canais_venda\n[PK] id_canal INT64\ncanal_edit STRING (nome do canal)\n─────────────────\n76 canais mapeados\nEx: Site Aroom, Shopee, ML",
  tbl_style("#14532d","#22c55e"),1200,50,220,140,parent=s3))

cells.append(box(estoque,
  "bling_estoque_saldos\n[FK] produto_identificador INT64\nsaldo_fisico NUMERIC\nsaldo_virtual NUMERIC\n─────────────────\n44.117 saldos de estoque",
  tbl_style("#14532d","#22c55e"),1200,230,220,130,parent=s3))

# ─── LAYER 4: CI + CRM ──────────────────────────────────────────────
cells.append(box(c360,
  "customer_360\n[PK] customer_id INT64 ← contato.identificador\nrfm_score STRING\nrfm_segment STRING\nltv_estimated NUMERIC\nchurn_probability FLOAT64\ndays_since_last_purchase INT64\ntotal_orders INT64 | total_revenue NUMERIC",
  tbl_style("#3b0764","#a855f7"),80,50,310,180,parent=s4))

cells.append(box(rfm,
  "customer_rfm / customer_clusters\n[FK] customer_id INT64\nrecency INT64 | frequency INT64\nmonetary NUMERIC\ncluster_label STRING\n─────────────────\nSegmentos: Campeos / Em Risco / Perdidos",
  tbl_style("#3b0764","#a855f7"),460,50,290,180,parent=s4))

cells.append(box(views,
  "growth_engine_views\ngrowth_engine_vendas_detalhado\ngrowth_engine_crm_rfm\ngrowth_engine_churn_risco\ngrowth_engine_aquisicao\ngrowth_engine_marketing_roas\n─────────────────\nLooker Studio ready",
  tbl_style("#3b0764","#a855f7"),820,50,290,180,parent=s4))

cells.append(box(ml,
  "ml.customer_segments\nfeatures.customer_features\nwallet_for_marketing.snapshot\nml.predictions\n─────────────────\nModelos preditivos de churn / LTV\nBase para campanhas de retencao",
  tbl_style("#3b0764","#a855f7"),1180,50,280,180,parent=s4))

# ─── EDGES ──────────────────────────────────────────────────────────
# Ads → GA4
cells.append(arrow(nid(),"utm_campaign → traffic_source.name\nutm_source → traffic_source.source",EDGE_H,gads,ga4))
cells.append(arrow(nid(),"utm_source=ig → traffic_source.source","edgeStyle=orthogonalEdgeStyle;strokeColor=#3b82f6;strokeWidth=2;fontColor=#3b82f6;fontSize=9;fontStyle=1;endArrow=block;endFill=1;",meta,ga4))
cells.append(arrow(nid(),"canal direto (sem UTM)\n⚠️ sem rastreio GA4","edgeStyle=orthogonalEdgeStyle;strokeColor=#6b7280;strokeWidth=1;dashed=1;fontColor=#6b7280;fontSize=9;endArrow=block;endFill=1;",mktplace,pv))

# GA4 → Recovery
cells.append(arrow(nid(),"event_params[transaction_id]\n→ recovery pipeline",EDGE_M,ga4,ga4rec))

# GA4 → Bling (bridge principal)
cells.append(arrow(nid(),"GA4.event_params[transaction_id]\n= pedidos_vendas.numero\n⚠️ MEDIA · 20.5% cobertura",EDGE_M,ga4rec,pv))

# GA4 → UTM aggregated
cells.append(arrow(nid(),"agrega eventos diarios",EDGE_I,ga4,utm_daily))
cells.append(arrow(nid(),"agrega por canal",EDGE_I,ga4,rev_daily))

# checkout → nuvemshop
cells.append(arrow(nid(),"checkout.token\n= nuvemshop_pedidos.token\n⚠️ MEDIA · 12.5% converte",EDGE_M,chk,ns))

# nuvemshop → bling
cells.append(arrow(nid(),"nuvemshop_pedidos.store_id\n= pedidos_vendas.loja_id\n✓ ALTA · R$ 2.85M confirmado",EDGE_H,ns,pv))

# nuvemshop → contato via email/CPF
cells.append(arrow(nid(),"contact_email = contato.email (64.7%)\nCPF = contato.numero_documento (95%)\n✓ ALTA · melhor bridge disponivel",EDGE_H,ns,cont))

# pv → pvi
cells.append(arrow(nid(),"pv.identificador\n= pvi.pedidos_vendas_identificador\n✓ FK nativa 100%",EDGE_H,pv,pvi))

# pvi → prod
cells.append(arrow(nid(),"pvi.codigo\n= produtos.codigo\n⚠️ 510 SKUs faltantes (0.91%)",EDGE_M,pvi,prod))

# pv → cont (broken)
cells.append(arrow(nid(),"pv.contato_id (INT32)\n≠ contato.identificador (INT64)\n🔴 CRITICO · 0% join por ID\nWorkaround: usar email/CPF",EDGE_X,pv,cont))

# pv → nf
cells.append(arrow(nid(),"pv.nota_fiscal_id\n= nf.identificador\n✓ ALTA · 99.99%",EDGE_H,pv,nf))

# pv → canais
cells.append(arrow(nid(),"pv.loja_id\n= canais.id_canal\n✓ 48 canais",EDGE_H,pv,canais))

# prod → estoque
cells.append(arrow(nid(),"produtos.identificador\n= estoque.produto_identificador",EDGE_H,prod,estoque))

# perfit → contato
cells.append(arrow(nid(),"perfit.contact_email\n= contato.email\n✓ ALTA · 75% match · 4.994 clientes","edgeStyle=orthogonalEdgeStyle;strokeColor=#22c55e;strokeWidth=2;fontColor=#22c55e;fontSize=9;fontStyle=1;endArrow=block;endFill=1;",perfit,cont))

# dispatch → contato
cells.append(arrow(nid(),"dispatch.contact_id\n= contato.identificador\n⚠️ MEDIA · schema investigate","edgeStyle=orthogonalEdgeStyle;strokeColor=#f59e0b;strokeWidth=2;dashed=1;fontColor=#f59e0b;fontSize=9;fontStyle=1;endArrow=block;endFill=1;",dispatch,cont))

# bling → CI
cells.append(arrow(nid(),"contato.identificador\n→ ETL pipeline diario\n✓ alimenta Customer 360",EDGE_H,cont,c360))
cells.append(arrow(nid(),"pedidos_vendas → RFM calc",EDGE_H,pv,rfm))
cells.append(arrow(nid(),"customer_360 → views Looker Studio",EDGE_I,c360,views))
cells.append(arrow(nid(),"rfm → modelos ML",EDGE_I,rfm,ml))

# CRM loop back
cells.append(arrow(nid(),"contato → Perfit lista export\nloop CRM retorna p/ BigQuery daily","edgeStyle=orthogonalEdgeStyle;strokeColor=#a855f7;strokeWidth=2;fontColor=#a855f7;fontSize=9;fontStyle=1;endArrow=block;endFill=1;",c360,perfit))

# ─── LEGEND ─────────────────────────────────────────────────────────
leg = nid()
cells.append(box(leg,
  "LEGENDA:  [PK] = Primary Key  |  [FK] = Foreign Key  |  [UK] = Unique Key\n✓ ALTA confianca (match >70% ou FK nativa)  |  ⚠️ MEDIA (cobertura parcial)  |  🔴 CRITICO (quebrado)\nCores de seta: VERDE=alta  AMARELO=media  VERMELHO=critico\n★ = Fonte de verdade financeira  |  ⚠️ Campo com fill rate baixo",
  "text;html=0;strokeColor=none;fillColor=#1e293b;align=left;verticalAlign=middle;fontColor=#94a3b8;fontSize=11;spacingLeft=10;rounded=1;",
  SX, Y4+H4+20, SW_W, 70))

# ─── ASSEMBLE ───────────────────────────────────────────────────────
body = "".join(cells)
xml = "\n".join([
  '<?xml version="1.0" encoding="UTF-8"?>',
  '<mxGraphModel dx="1600" dy="900" grid="1" gridSize="10" guides="1" tooltips="1" connect="1" arrows="1" fold="1" page="0" pageScale="1" pageWidth="2200" pageHeight="1700" math="0" shadow="0" background="#0d1117">',
  '  <root>',
  '    <mxCell id="0"/>',
  '    <mxCell id="1" parent="0"/>',
  body,
  '  </root>',
  '</mxGraphModel>',
])

out = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "docs", "lead_journey_v2.drawio")
with open(out, "w", encoding="utf-8") as f:
    f.write(xml)
print(f"OK: {out} ({os.path.getsize(out):,} bytes)")
