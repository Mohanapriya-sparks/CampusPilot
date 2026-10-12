from pathlib import Path
import pandas as pd


ROOT = Path(__file__).resolve().parents[1]

DATA_DIR = ROOT / "data" / "linkedin_jobs"

JOB_SKILLS_FILE = DATA_DIR / "job_skills.csv"
SKILLS_FILE = DATA_DIR / "skills.csv"


def inspect_file(title, path):
    print()
    print("=" * 70)
    print(title)
    print("=" * 70)

    df = pd.read_csv(path)

    print(f"File: {path.name}")
    print(f"Rows: {len(df):,}")
    print(f"Columns: {len(df.columns)}")

    print("\nCOLUMN NAMES:")
    for column in df.columns:
        print(f" - {column}")

    print("\nFIRST 10 ROWS:")
    print(df.head(10).to_string(index=False))

    print("\nMISSING VALUES:")
    missing = df.isnull().sum()
    missing = missing[missing > 0]

    if missing.empty:
        print("No missing values.")
    else:
        print(missing.to_string())

    print("\nUNIQUE VALUES:")
    for column in df.columns:
        count = df[column].nunique(dropna=True)

        print(
            f"{column}: "
            f"{count:,} unique values"
        )

    return df


job_skills = inspect_file(
    "LINKEDIN JOB SKILLS",
    JOB_SKILLS_FILE,
)

skills = inspect_file(
    "LINKEDIN SKILL MAPPING",
    SKILLS_FILE,
)


print()
print("=" * 70)
print("CAMPUSPILOT CHECK")
print("=" * 70)

print(
    """
These files will help us determine:

1. How LinkedIn connects jobs to skill categories.
2. What skill labels are available.
3. Whether the labels are detailed enough for CampusPilot.
4. How we should later connect job descriptions to skills.

We are NOT training anything yet.
"""
)

print("Inspection completed successfully.")