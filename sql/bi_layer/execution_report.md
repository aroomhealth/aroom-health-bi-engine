# Phase 2 — Execution Report
**Data:** 2026-06-22 | **Status:** ✅ 6/6 views criadas

## Resultados por View

### P-01 v_pedido_contato_bridge
| Bridge | Pedidos | Receita | Cobertura |
|:---|:---:|:---:|:---:|
| CPF | 45.522 | R$ 3.931.084 | 35.0% |
| EMAIL | 25 | R$ 1.895 | 0.0% |
| **Total** | **45.547** | **R$ 3.932.980** | **35.0%** |

> ⚠️ Cobertura menor que esperado (35% vs 85% esperado). Causa: apenas 19.915 pedidos do Nuvemshop para fazer o join CPF. Os 130.135 pedidos do Bling incluem canais sem correspondência no Nuvemshop.

### P-02 v_pedido_atribuicao
| Método | Pedidos | Receita | % Receita |
|:---|:---:|:---:|:---:|
| GA4_RECOVERY | 2.539 | R$ 295.488 | 3.1% |
| SEM_ATRIBUICAO | 127.813 | R$ 9.266.516 | 96.9% |

> ⚠️ Atribuição menor que esperado (3.1% vs 20.5%). O transactionId da recovery bate apenas via join direto — muitos pedidos têm numero diferente do transactionId.

### P-03 v_checkout_pedido_bridge
| Status | Carrinhos | % |
|:---|:---:|:---:|
| EMAIL_MATCH | 1.674 | 47.3% |
| ABANDONO | 1.469 | 41.5% |
| TOKEN_MATCH | 320 | 9.0% |
| CPF_MATCH | 79 | 2.2% |

> ✅ Insight crítico: taxa de conversão REAL via email = 58.5% (não 12.5%). A taxa de 12.5% era apenas token-to-token. Com email bridge, cobertura salta para 58.5%.

### P-04 v_sku_orphans
| Prioridade | SKUs | Receita |
|:---|:---:|:---:|
| P1_ALTO | 19 | R$ 37.926 |
| P2_MEDIO | 164 | R$ 40.880 |
| P3_BAIXO | 327 | R$ 16.363 |
| **Total** | **510** | **R$ 95.170** |

> ✅ 510 SKUs catalogados. Top 19 SKUs (P1_ALTO) representam R$ 37.926 — prioridade de saneamento.

### P-05 v_pedido_status_entrega
| Status | Pedidos | % |
|:---|:---:|:---:|
| NF_AUTORIZADA | 68.053 | 52.3% |
| NF_VINCULADA | 62.071 | 47.7% |
| STATUS_DESCONHECIDO | 11 | 0.0% |

> ✅ 100% dos pedidos cobertos pela proxy via NF. 52.3% têm NF autorizada (entrega confirmável), 47.7% têm NF vinculada (em processo).

### P-06 v_contato_email_quality
| Status | Clientes | % |
|:---|:---:|:---:|
| EMAIL_VALIDO | 75.939 | 62.9% |
| SEM_EMAIL (sem fonte) | 42.507 | 35.2% |
| EMAIL_MASCARADO | 2.207 | 1.8% |
| RECUPERÁVEL via NS | 82 | 0.1% |
| EMAIL_INVÁLIDO | 12 | 0.0% |

> ✅ 82 clientes sem email no Bling MAS com email no Nuvemshop — recuperáveis imediatamente.

## ZERO impacto em produção
Todos os objetos criados em `iron-rex-461220-g4.bi_layer` — nenhuma tabela ou view de produção modificada.
