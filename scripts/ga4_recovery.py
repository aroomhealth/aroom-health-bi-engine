import os
import sys
import argparse
from datetime import datetime, timedelta
import pandas as pd
from google.cloud import bigquery
from google.analytics.data_v1beta import BetaAnalyticsDataClient
from google.analytics.data_v1beta.types import (
    RunReportRequest,
    DateRange,
    Dimension,
    Metric,
)

# GA4 Property Configuration
DEFAULT_PROPERTY_ID = "414017556"
DATASET_ID = "analytics_recovery"

def get_credentials(credentials_path=None):
    import google.auth
    scopes = [
        "https://www.googleapis.com/auth/analytics.readonly",
        "https://www.googleapis.com/auth/cloud-platform"
    ]
    if credentials_path:
        try:
            return google.auth.load_credentials_from_file(credentials_path, scopes=scopes)
        except Exception as e:
            print(f"Aviso: Falha ao carregar credenciais de {credentials_path}: {e}")
            print("Tentando carregar credenciais padrão (ADC)...")
    return google.auth.default(scopes=scopes)

def get_bq_client(credentials, project_id):
    return bigquery.Client(credentials=credentials, project=project_id)

def get_ga4_client(credentials):
    return BetaAnalyticsDataClient(credentials=credentials)


def run_ga4_report(client, property_id, start_date_str, end_date_str, dimensions_list, metrics_list):
    """
    Executa um relatório na API de dados do GA4 para um intervalo de datas.
    """
    request = RunReportRequest(
        property=f"properties/{property_id}",
        dimensions=[Dimension(name=name) for name in dimensions_list],
        metrics=[Metric(name=name) for name in metrics_list],
        date_ranges=[DateRange(start_date=start_date_str, end_date=end_date_str)],
        limit=250000
    )
    
    response = client.run_report(request)
    
    # Parse results
    headers = [dim.name for dim in response.dimension_headers] + [metric.name for metric in response.metric_headers]
    rows_data = []
    
    for row in response.rows:
        row_values = [val.value for val in row.dimension_values] + [val.value for val in row.metric_values]
        rows_data.append(row_values)
        
    df = pd.DataFrame(rows_data, columns=headers)
    return df

def upload_to_bigquery(bq_client, df, table_id, project_id):
    """
    Realiza o upload dos dados em lote para o BigQuery.
    """
    if df.empty:
        print(f"Sem dados para inserir em {table_id}.")
        return
        
    full_table_id = f"{project_id}.{DATASET_ID}.{table_id}"
    
    job_config = bigquery.LoadJobConfig(
        write_disposition=bigquery.WriteDisposition.WRITE_APPEND,
        autodetect=True,
    )
    
    print(f"Enviando {len(df)} linhas para {full_table_id}...")
    job = bq_client.load_table_from_dataframe(df, full_table_id, job_config=job_config)
    job.result()  # Aguarda a conclusão
    print(f"Tabela {table_id} atualizada com sucesso.")

def main():
    parser = argparse.ArgumentParser(description="Recuperador de Histórico do GA4 para o BigQuery")
    parser.add_argument("--credentials", help="Caminho para a chave JSON da conta de serviço")
    parser.add_argument("--property", default=DEFAULT_PROPERTY_ID, help="ID da Propriedade do GA4")
    parser.add_argument("--start-date", default="2025-12-11", help="Data de início (YYYY-MM-DD)")
    parser.add_argument("--end-date", default="2026-06-10", help="Data de término (YYYY-MM-DD)")
    
    args = parser.parse_args()
    
    # Inicialização de clientes
    try:
        credentials, project_id = get_credentials(args.credentials)
        bq_client = get_bq_client(credentials, project_id)
        ga4_client = get_ga4_client(credentials)
        project_id = bq_client.project
        print(f"Autenticação estabelecida no projeto GCP: {project_id}")
    except Exception as e:
        print(f"Erro de autenticação: {e}")
        print("Certifique-se de que a variável GOOGLE_APPLICATION_CREDENTIALS está definida ou passe --credentials.")
        sys.exit(1)
        
    # Certificar a existência do dataset analytics_recovery
    dataset_ref = bigquery.DatasetReference(project_id, DATASET_ID)
    try:
        bq_client.get_dataset(dataset_ref)
        print(f"Dataset {DATASET_ID} já existe.")
    except Exception:
        # Se não existe, cria na mesma região da produção
        dataset = bigquery.Dataset(dataset_ref)
        dataset.location = "us-central1"
        bq_client.create_dataset(dataset)
        print(f"Dataset {DATASET_ID} criado com sucesso na região us-central1.")

    # Definição dos relatórios a serem extraídos
    reports_config = {
        "ga4_recovery_traffic_sources": {
            "dimensions": ["date", "sessionSource", "sessionMedium", "sessionCampaignName"],
            "metrics": ["activeUsers", "sessions", "conversions", "eventCount", "purchaseRevenue"]
        },
        "ga4_recovery_pages": {
            "dimensions": ["date", "landingPage"],
            "metrics": ["activeUsers", "sessions", "screenPageViews"]
        },
        "ga4_recovery_geo": {
            "dimensions": ["date", "country", "region", "city"],
            "metrics": ["activeUsers", "sessions"]
        },
        "ga4_recovery_devices": {
            "dimensions": ["date", "deviceCategory", "operatingSystem"],
            "metrics": ["activeUsers", "sessions"]
        },
        "ga4_recovery_events": {
            "dimensions": ["date", "eventName"],
            "metrics": ["eventCount"]
        },
        "ga4_recovery_ecommerce": {
            "dimensions": ["date", "sessionSource", "sessionMedium", "transactionId"],
            "metrics": ["purchaseRevenue"]
        }
    }

    # Range de datas divididos em chunks de no máximo 30 dias
    start = datetime.strptime(args.start_date, "%Y-%m-%d")
    end = datetime.strptime(args.end_date, "%Y-%m-%d")
    
    chunks = []
    current_date = start
    chunk_size_days = 30
    
    while current_date <= end:
        next_date = min(current_date + timedelta(days=chunk_size_days - 1), end)
        chunks.append((current_date.strftime("%Y-%m-%d"), next_date.strftime("%Y-%m-%d")))
        current_date = next_date + timedelta(days=1)
        
    print(f"Dividido o período em {len(chunks)} blocos de processamento.")
    
    for chunk_start, chunk_end in chunks:
        print(f"\n--- Processando período: {chunk_start} até {chunk_end} ---")
        
        # Executa e carrega cada relatório para o período corrente
        for table_id, config in reports_config.items():
            try:
                print(f"Executando relatório {table_id}...")
                df = run_ga4_report(
                    ga4_client, 
                    args.property, 
                    chunk_start,
                    chunk_end,
                    config["dimensions"], 
                    config["metrics"]
                )
                
                # Converter tipos de métricas para numéricos no DF antes do upload
                for metric in config["metrics"]:
                    if metric in df.columns:
                        df[metric] = pd.to_numeric(df[metric], errors="coerce").fillna(0)
                        
                # Adicionar coluna de carimbo de data formatada como data
                if "date" in df.columns:
                    df["date"] = pd.to_datetime(df["date"], format="%Y%m%d").dt.date
                
                upload_to_bigquery(bq_client, df, table_id, project_id)
            except Exception as e:
                print(f"Erro ao recuperar relatório {table_id} para {chunk_start} a {chunk_end}: {e}")

    print("\nProcesso de recuperação de dados históricos GA4 concluído.")

if __name__ == "__main__":
    main()
