import pandas as pd
import json

file_path = r"C:\Users\arthu\.gemini\antigravity\scratch\aroom_health_analytics\Catalogação - Custo materia prima e insumos Aroom.xlsx"

try:
    # Read the Excel file
    df = pd.read_excel(file_path, sheet_name=0)
    
    # Print the columns
    print("COLUMNS:")
    print(df.columns.tolist())
    
    # Print the first 5 rows as dict
    print("\nFIRST 5 ROWS:")
    print(df.head(5).to_dict('records'))
    
    print("\nTOTAL ROWS:", len(df))
except Exception as e:
    print("Error:", e)
