from pathlib import Path
from collections import Counter
import re

import pandas as pd
from bs4 import BeautifulSoup


ROOT = Path(__file__).resolve().parents[1]

RESUME_FILE = (
    ROOT
    / "data"
    / "resume_dataset"
    / "Resume.csv"
)

OUTPUT_DIR = ROOT / "data" / "derived"

OUTPUT_DIR.mkdir(
    parents=True,
    exist_ok=True,
)

OUTPUT_FILE = (
    OUTPUT_DIR
    / "skill_vocabulary.csv"
)


# ---------------------------------------------------------
# LOAD DATA
# ---------------------------------------------------------

print("Loading Resume.csv...")

df = pd.read_csv(RESUME_FILE)

print(f"Resumes: {len(df):,}")


# ---------------------------------------------------------
# CLEANING
# ---------------------------------------------------------

def normalize_skill(value: str) -> str:
    value = value.strip()

    value = re.sub(
        r"\s+",
        " ",
        value,
    )

    value = value.strip(
        " .,:;|-•*"
    )

    return value


def valid_skill(value: str) -> bool:
    if not value:
        return False

    if len(value) < 2:
        return False

    if len(value) > 70:
        return False

    words = value.split()

    if len(words) > 8:
        return False

    # Remove entries containing mostly numbers.
    letters = sum(
        char.isalpha()
        for char in value
    )

    if letters < 2:
        return False

    return True


# ---------------------------------------------------------
# EXTRACT SKILLS FROM HTML
# ---------------------------------------------------------

skill_counter = Counter()

resumes_with_skill_section = 0


for html in df["Resume_html"].astype(str):

    soup = BeautifulSoup(
        html,
        "html.parser",
    )

    skill_sections = []

    # Dataset commonly identifies the skill section
    # using SECTION_SKLL...
    for section in soup.find_all(
        id=re.compile(
            r"SECTION_SKLL",
            re.IGNORECASE,
        )
    ):
        skill_sections.append(
            section.get_text(
                " ",
                strip=True,
            )
        )

    if not skill_sections:
        continue

    resumes_with_skill_section += 1

    for section_text in skill_sections:

        # Remove the heading itself.
        section_text = re.sub(
            r"^\s*skills?\s*",
            "",
            section_text,
            flags=re.IGNORECASE,
        )

        # Skills in this dataset are commonly comma,
        # bullet, semicolon or pipe separated.
        parts = re.split(
            r"[,;•|\n]+",
            section_text,
        )

        for part in parts:

            skill = normalize_skill(
                part
            )

            if valid_skill(skill):

                key = skill.lower()

                skill_counter[key] += 1


# ---------------------------------------------------------
# BUILD OUTPUT
# ---------------------------------------------------------

rows = []

for skill, frequency in skill_counter.items():

    rows.append(
        {
            "skill": skill,
            "frequency": frequency,
        }
    )


skills_df = pd.DataFrame(rows)

if skills_df.empty:
    raise RuntimeError(
        "No skills were extracted."
    )


skills_df = (
    skills_df
    .sort_values(
        by=[
            "frequency",
            "skill",
        ],
        ascending=[
            False,
            True,
        ],
    )
    .reset_index(drop=True)
)


# Keep skills seen at least twice.
skills_df = skills_df[
    skills_df["frequency"] >= 2
].copy()


skills_df.to_csv(
    OUTPUT_FILE,
    index=False,
)


# ---------------------------------------------------------
# SUMMARY
# ---------------------------------------------------------

print()
print("=" * 65)
print("CAMPUSPILOT SKILL VOCABULARY")
print("=" * 65)

print(
    f"Resumes containing Skills section: "
    f"{resumes_with_skill_section:,}"
)

print(
    f"Unique retained skills: "
    f"{len(skills_df):,}"
)

print()
print("TOP 50 SKILLS:")
print()

print(
    skills_df
    .head(50)
    .to_string(
        index=False
    )
)

print()
print("Saved to:")

print(
    OUTPUT_FILE
)

print()
print(
    "Skill vocabulary generation completed."
)