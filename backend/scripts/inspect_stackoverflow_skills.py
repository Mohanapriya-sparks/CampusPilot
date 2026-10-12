from pathlib import Path
from collections import Counter

import pandas as pd


ROOT = Path(__file__).resolve().parents[1]

DATA_FILE = (
    ROOT
    / "data"
    / "stackoverflow_2024"
    / "survey_results_public.csv"
)


print("=" * 70)
print("STACK OVERFLOW 2024 TECHNOLOGY INSPECTION")
print("=" * 70)


# ------------------------------------------------------------
# LOAD
# ------------------------------------------------------------

df = pd.read_csv(
    DATA_FILE,
    low_memory=False,
)

print(f"\nRows: {len(df):,}")
print(f"Columns: {len(df.columns)}")


# ------------------------------------------------------------
# FIND TECHNOLOGY COLUMNS
# ------------------------------------------------------------

preferred_columns = [
    "LanguageHaveWorkedWith",
    "DatabaseHaveWorkedWith",
    "PlatformHaveWorkedWith",
    "WebframeHaveWorkedWith",
    "EmbeddedHaveWorkedWith",
    "MiscTechHaveWorkedWith",
    "ToolsTechHaveWorkedWith",
    "NEWCollabToolsHaveWorkedWith",
]


available_columns = [
    column
    for column in preferred_columns
    if column in df.columns
]


print()
print("AVAILABLE TECHNOLOGY COLUMNS")
print("-" * 50)

for column in available_columns:
    print(f"✓ {column}")


missing_columns = [
    column
    for column in preferred_columns
    if column not in df.columns
]


if missing_columns:

    print()
    print("NOT FOUND")
    print("-" * 50)

    for column in missing_columns:
        print(f"✗ {column}")


# ------------------------------------------------------------
# EXTRACT TECHNOLOGIES
#
# Stack Overflow normally separates multiple selections using ;
# ------------------------------------------------------------

technology_counter = Counter()

technology_sources = {}


for column in available_columns:

    values = (
        df[column]
        .dropna()
        .astype(str)
    )

    for value in values:

        technologies = value.split(";")

        for technology in technologies:

            technology = (
                technology
                .strip()
                .lower()
            )

            if not technology:
                continue

            technology_counter[
                technology
            ] += 1

            if technology not in technology_sources:
                technology_sources[
                    technology
                ] = set()

            technology_sources[
                technology
            ].add(column)


# ------------------------------------------------------------
# SUMMARY
# ------------------------------------------------------------

print()
print("=" * 70)
print("TECHNOLOGY SUMMARY")
print("=" * 70)

print(
    f"\nUnique technologies found: "
    f"{len(technology_counter):,}"
)


print()
print("TOP 100 TECHNOLOGIES")
print("-" * 70)


for technology, count in (
    technology_counter
    .most_common(100)
):

    sources = ", ".join(
        sorted(
            technology_sources[
                technology
            ]
        )
    )

    print(
        f"{technology:<35} "
        f"{count:>7}   "
        f"{sources}"
    )


# ------------------------------------------------------------
# CAMPUSPILOT GAP CHECK
# ------------------------------------------------------------

campuspilot_missing = [
    "flutter",
    "dart",
    "firebase",
    "git",
    "github",
    "c",
    "graphql",
    "artificial intelligence",
    "ai",
    "pytorch",
    "opencv",
    "cybersecurity",
    "arduino",
    "esp32",
    "iot",
]


available_tech = set(
    technology_counter.keys()
)


print()
print("=" * 70)
print("CAMPUSPILOT MISSING-SKILL CHECK")
print("=" * 70)


found = []
still_missing = []


for skill in campuspilot_missing:

    if skill in available_tech:
        found.append(skill)
    else:
        still_missing.append(skill)


print()
print("FOUND IN STACK OVERFLOW")
print("-" * 40)

for skill in found:
    print(f"✓ {skill}")


print()
print("STILL MISSING")
print("-" * 40)

for skill in still_missing:
    print(f"✗ {skill}")


print()
print(
    f"Recovered: "
    f"{len(found)}/{len(campuspilot_missing)}"
)

print()
print(
    "Stack Overflow inspection completed successfully."
)