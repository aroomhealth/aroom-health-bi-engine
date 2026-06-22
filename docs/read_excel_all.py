import pandas as pd

file_path = r"C:\Users\arthu\.gemini\antigravity\scratch\aroom_health_analytics\Catalogação - Custo materia prima e insumos Aroom.xlsx"

try:
    xl = pd.ExcelFile(file_path)
    print("Sheet names:", xl.sheet_names)

    for sheet in xl.sheet_names:
        df = pd.read_excel(file_path, sheet_name=sheet)
        print(f"\n--- SHEET: {sheet} ---")
        print("Columns:", df.columns.tolist()[:10]) # print first 10 columns
        print("Total Rows:", len(df))
        if len(df) > 0:
            # Drop empty columns for printing clarity
            row = df.head(2).dropna(axis=1, how='all').to_dict('records')
            print("First rows:", row)
except Exception as e:
    print("Error:", e)
