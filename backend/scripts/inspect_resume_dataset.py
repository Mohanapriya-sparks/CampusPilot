from pathlib import Path
import pandas as pd


ROOT = Path(__file__).resolve().parents[1]

DATA_DIR = ROOT / "data" / "resume_dataset"

RESUME_FILE = DATA_DIR / "Resume.csv"


print("=" * 70)
print("RESUME DATASET INSPECTION")
print("=" * 70)

df = pd.read_csv(RESUME_FILE)

print(f"\nFile: {RESUME_FILE.name}")
print(f"Rows: {len(df):,}")
print(f"Columns: {len(df.columns)}")


print("\nCOLUMN NAMES:")

for column in df.columns:
    print(f" - {column}")


print("\nFIRST 5 ROWS:")

print(
    df.head(5).to_string()
)


print("\nMISSING VALUES:")

missing = df.isnull().sum()
missing = missing[missing > 0]

if missing.empty:
    print("No missing values.")
else:
    print(
        missing.to_string()
    )


print("\nUNIQUE VALUES:")

for column in df.columns:
    print(
        f"{column}: "
        f"{df[column].nunique(dropna=True):,}"
    )


# ---------------------------------------------------------
# CATEGORY CHECK
# ---------------------------------------------------------

if "Category" in df.columns:

    print()
    print("=" * 70)
    print("RESUME CATEGORIES")
    print("=" * 70)

    category_counts = (
        df["Category"]
        .value_counts()
    )

    print(
        category_counts.to_string()
    )


# ---------------------------------------------------------
# TEXT SAMPLE
# ---------------------------------------------------------

possible_text_columns = [
    "Resume_str",
    "Resume",
    "resume_text",
    "text",
]


text_column = None

for column in possible_text_columns:
    if column in df.columns:
        text_column = column
        break


if text_column:

    print()
    print("=" * 70)
    print("SAMPLE RESUME TEXT")
    print("=" * 70)

    sample = (
        df[text_column]
        .dropna()
        .astype(str)
        .iloc[0]
    )

    print(
        sample[:2500]
    )

else:

    print(
        "\nNo recognised resume text "
        "column was automatically found."
    )


print()
print("=" * 70)
print("CAMPUSPILOT CHECK")
print("=" * 70)

print(
    """
We are checking whether this dataset contains:

1. Raw resume text
2. Resume categories
3. Enough text to extract detailed skills
4. Suitable data for StudentProfile skill extraction

Next:
Resume text
    ↓
Skill extraction
    ↓
Normalized skills
    ↓
CampusPilot StudentProfile
"""
)

print(
    "\nResume dataset inspection completed successfully."
)