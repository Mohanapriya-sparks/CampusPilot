from pathlib import Path
import re

import pandas as pd


ROOT = Path(__file__).resolve().parents[1]

INPUT_FILE = (
    ROOT
    / "data"
    / "derived"
    / "skill_vocabulary.csv"
)

OUTPUT_FILE = (
    ROOT
    / "data"
    / "derived"
    / "skill_vocabulary_clean.csv"
)


# ------------------------------------------------------------
# SMALL NOISE LIST
#
# We are NOT manually hardcoding hundreds of skills.
# This only removes obvious non-skill terms produced by resumes.
# ------------------------------------------------------------

NOISE = {
    "client",
    "clients",
    "office",
    "phone",
    "market",
    "meetings",
    "materials",
    "personnel",
    "director",
    "delivery",
    "progress",
    "filing",
    "retail",
    "budget",
    "budgets",
    "policies",
    "benefits",
}


# ------------------------------------------------------------
# NORMALIZATION
# ------------------------------------------------------------

ALIASES = {
    "ms office": "microsoft office",
    "microsoft word": "word",
    "ms word": "word",
    "microsoft excel": "excel",
    "ms excel": "excel",
    "microsoft powerpoint": "powerpoint",
    "ms powerpoint": "powerpoint",
    "project mgmt": "project management",
    "team work": "teamwork",
    "team-work": "teamwork",
    "problem-solving": "problem solving",
}


def normalize(value: str) -> str:

    value = str(value).lower().strip()

    value = re.sub(
        r"\s+",
        " ",
        value,
    )

    value = value.strip(
        ".,;:/|()-[]{}"
    )

    return ALIASES.get(
        value,
        value,
    )


def valid_skill(skill: str) -> bool:

    if skill in NOISE:
        return False

    if len(skill) < 2:
        return False

    if len(skill) > 55:
        return False

    if len(skill.split()) > 6:
        return False

    if skill.isdigit():
        return False

    return True


# ------------------------------------------------------------
# LOAD
# ------------------------------------------------------------

print("Loading raw vocabulary...")

df = pd.read_csv(INPUT_FILE)

print(
    f"Raw terms: {len(df):,}"
)


# ------------------------------------------------------------
# NORMALIZE
# ------------------------------------------------------------

df["skill"] = (
    df["skill"]
    .astype(str)
    .map(normalize)
)

df = df[
    df["skill"].map(valid_skill)
]


# ------------------------------------------------------------
# MERGE DUPLICATES
# ------------------------------------------------------------

df = (
    df.groupby(
        "skill",
        as_index=False,
    )["frequency"]
    .sum()
)


# ------------------------------------------------------------
# REMOVE VERY RARE TERMS
# ------------------------------------------------------------

df = df[
    df["frequency"] >= 3
]


# ------------------------------------------------------------
# SORT
# ------------------------------------------------------------

df = (
    df.sort_values(
        "frequency",
        ascending=False,
    )
    .reset_index(drop=True)
)


# ------------------------------------------------------------
# SAVE
# ------------------------------------------------------------

df.to_csv(
    OUTPUT_FILE,
    index=False,
)


print()
print("=" * 60)
print("CAMPUSPILOT CLEAN SKILL VOCABULARY")
print("=" * 60)

print(
    f"Clean skills: {len(df):,}"
)

print()
print("TOP 75:")
print()

print(
    df.head(75)
    .to_string(index=False)
)

print()
print("Saved to:")

print(OUTPUT_FILE)