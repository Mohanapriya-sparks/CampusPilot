from pathlib import Path
import pandas as pd


ROOT = Path(__file__).resolve().parents[1]

DATA_FILE = (
    ROOT
    / "data"
    / "technical_skills"
    / "candidate_job_role_dataset.csv"
)


print("=" * 70)
print("CANDIDATE JOB ROLE DATASET INSPECTION")
print("=" * 70)

df = pd.read_csv(DATA_FILE)

print(f"\nRows: {len(df):,}")
print(f"Columns: {len(df.columns)}")


print("\nCOLUMN NAMES:")

for column in df.columns:
    print(f" - {column}")


print("\nFIRST 10 ROWS:")

print(
    df.head(10).to_string(index=False)
)


print("\nMISSING VALUES:")

missing = df.isnull().sum()
missing = missing[missing > 0]

if missing.empty:
    print("No missing values.")
else:
    print(missing.to_string())


print("\nUNIQUE VALUE COUNTS:")

for column in df.columns:
    print(
        f"{column}: "
        f"{df[column].nunique(dropna=True):,}"
    )


print()
print("=" * 70)
print("POSSIBLE SKILL COLUMNS")
print("=" * 70)

skill_keywords = [
    "skill",
    "technology",
    "tech",
    "tool",
    "language",
    "framework",
    "role",
]

possible_columns = []

for column in df.columns:
    name = column.lower()

    if any(
        keyword in name
        for keyword in skill_keywords
    ):
        possible_columns.append(column)


if possible_columns:
    for column in possible_columns:
        print(f"\n--- {column} ---")

        print(
            df[column]
            .dropna()
            .astype(str)
            .head(20)
            .to_string(index=False)
        )
else:
    print(
        "No obvious skill-related columns found."
    )


print()
print("=" * 70)
print("INSPECTION COMPLETE")
print("=" * 70)