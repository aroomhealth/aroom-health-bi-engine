import pandas as pd

file_path = r"C:\Users\arthu\.gemini\antigravity\scratch\aroom_health_analytics\Catalogação - Custo materia prima e insumos Aroom.xlsx"
csv_path = r"c:\Users\arthu\.antigravity-ide\aroom-health-bi-engine\docs\sku_custos_reais.csv"

try:
    # Read the second sheet, header is at index 3 (4th row)
    df = pd.read_excel(file_path, sheet_name=1, header=3)
    
    # Let's print the columns to see what they are
    print("Columns:", df.columns.tolist())
    
    # The first column is usually the SKU, let's rename it to 'sku'
    # And we need to find the column that corresponds to CUSTO. It was Unnamed: 18 in the raw load, which is the 19th column.
    # Let's rename the columns to clean them up. We'll find 'CUSTO'
    
    col_sku = df.columns[0]
    col_custo = [c for c in df.columns if 'CUSTO' in str(c).upper()]
    
    if len(col_custo) > 0:
        target_custo = col_custo[-1] # Usually the last one is the total cost
    else:
        target_custo = df.columns[-1]
        
    print(f"SKU Column: {col_sku}, Custo Column: {target_custo}")
    
    # Extract only the two columns
    df_clean = df[[col_sku, target_custo]].copy()
    df_clean.columns = ['sku', 'custo_total_real']
    
    # Drop rows where sku is NaN
    df_clean = df_clean.dropna(subset=['sku'])
    
    # Ensure sku is string
    df_clean['sku'] = df_clean['sku'].astype(str).str.strip()
    
    # Ensure custo is numeric
    df_clean['custo_total_real'] = pd.to_numeric(df_clean['custo_total_real'], errors='coerce').fillna(0)
    
    # Drop cost <= 0 if any, or keep it. Let's keep it but just valid values.
    
    # Save to CSV
    df_clean.to_csv(csv_path, index=False, encoding='utf-8')
    
    print(f"Successfully saved {len(df_clean)} SKUs to {csv_path}")
    print(df_clean.head())
    
except Exception as e:
    print("Error:", e)
