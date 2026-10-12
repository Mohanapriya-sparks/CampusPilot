from pathlib import Path
from collections import Counter
from itertools import combinations
import math
import sys

import pandas as pd


# ============================================================
# PATH SETUP
# ============================================================

ROOT = Path(__file__).resolve().parents[2]

if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))


from backend.app.intelligence.skill_normalizer import SkillNormalizer


BACKEND = ROOT / "backend"

STACKOVERFLOW_FILE = (
    BACKEND
    / "data"
    / "stackoverflow_2024"
    / "survey_results_public.csv"
)

ROLE_MAP_FILE = (
    BACKEND
    / "data"
    / "derived"
    / "campuspilot_role_skill_map.csv"
)

MASTER_FILE = (
    BACKEND
    / "data"
    / "derived"
    / "campuspilot_master_skills_final.csv"
)

OUTPUT_FILE = (
    BACKEND
    / "data"
    / "derived"
    / "campuspilot_skill_relationships.csv"
)


TECH_COLUMNS = [
    "LanguageHaveWorkedWith",
    "DatabaseHaveWorkedWith",
    "PlatformHaveWorkedWith",
    "WebframeHaveWorkedWith",
    "EmbeddedHaveWorkedWith",
    "MiscTechHaveWorkedWith",
    "ToolsTechHaveWorkedWith",
    "NEWCollabToolsHaveWorkedWith",
]


# ============================================================
# LOAD MASTER VOCABULARY
# ============================================================

print("=" * 70)
print("BUILDING CAMPUSPILOT SKILL RELATIONSHIPS")
print("=" * 70)

master = pd.read_csv(MASTER_FILE)

master_skills = set(
    master["skill"]
    .dropna()
    .astype(str)
    .str.strip()
    .str.lower()
)

print(f"\nMaster skills: {len(master_skills):,}")


# ============================================================
# STACK OVERFLOW RELATIONSHIPS
# ============================================================

print("\nProcessing Stack Overflow 2024...")

survey = pd.read_csv(
    STACKOVERFLOW_FILE,
    low_memory=False,
)

available_columns = [
    col
    for col in TECH_COLUMNS
    if col in survey.columns
]

print(
    f"Technology columns: "
    f"{len(available_columns)}"
)


so_skill_frequency = Counter()
so_pair_frequency = Counter()


for row_number, (_, row) in enumerate(
    survey[available_columns].iterrows(),
    start=1,
):

    row_skills = set()

    for column in available_columns:

        value = row[column]

        if pd.isna(value):
            continue

        for raw_skill in str(value).split(";"):

            raw_skill = raw_skill.strip()

            if not raw_skill:
                continue

            skill = SkillNormalizer.normalize(
                raw_skill
            )

            # Special Stack Overflow naming fixes
            aliases = {
                "torch/pytorch": "pytorch",
                "amazon web services (aws)": "aws",
                "microsoft azure": "azure",
                "google cloud": "gcp",
                "html/css": None,
                "visual studio code": "vs code",
                "bash/shell (all shells)": "bash",
                "rasberry pi": "raspberry pi",
            }

            if skill == "html/css":
                row_skills.add("html")
                row_skills.add("css")
                continue

            skill = aliases.get(
                skill,
                skill,
            )

            if not skill:
                continue

            if skill in master_skills:
                row_skills.add(skill)

    for skill in row_skills:
        so_skill_frequency[skill] += 1

    for skill_a, skill_b in combinations(
        sorted(row_skills),
        2,
    ):
        so_pair_frequency[
            (skill_a, skill_b)
        ] += 1

    if row_number % 10000 == 0:
        print(
            f"Processed "
            f"{row_number:,}/"
            f"{len(survey):,} respondents"
        )


print(
    f"Stack Overflow skills observed: "
    f"{len(so_skill_frequency):,}"
)

print(
    f"Stack Overflow skill pairs: "
    f"{len(so_pair_frequency):,}"
)


# ============================================================
# ROLE → SKILL RELATIONSHIPS
# ============================================================

print("\nProcessing role → skill map...")

role_map = pd.read_csv(
    ROLE_MAP_FILE
)

role_skill_frequency = Counter()
role_pair_frequency = Counter()


for role, group in role_map.groupby(
    "job_role"
):

    skills = set()

    for raw_skill in group["skill"]:

        skill = SkillNormalizer.normalize(
            raw_skill
        )

        if skill in master_skills:
            skills.add(skill)

    for skill in skills:
        role_skill_frequency[
            skill
        ] += 1

    for skill_a, skill_b in combinations(
        sorted(skills),
        2,
    ):
        role_pair_frequency[
            (skill_a, skill_b)
        ] += 1


print(
    f"Roles: "
    f"{role_map['job_role'].nunique():,}"
)

print(
    f"Role-based skill pairs: "
    f"{len(role_pair_frequency):,}"
)


# ============================================================
# COMBINE ALL PAIRS
# ============================================================

all_pairs = (
    set(so_pair_frequency.keys())
    |
    set(role_pair_frequency.keys())
)


rows = []


for skill_a, skill_b in all_pairs:

    so_pair = so_pair_frequency.get(
        (skill_a, skill_b),
        0,
    )

    so_a = so_skill_frequency.get(
        skill_a,
        0,
    )

    so_b = so_skill_frequency.get(
        skill_b,
        0,
    )


    # Cosine-style association:
    #
    # pair_count / sqrt(freq_a * freq_b)
    #
    # This prevents extremely popular technologies
    # from automatically dominating relationships.

    if (
        so_pair > 0
        and so_a > 0
        and so_b > 0
    ):

        so_similarity = (
            so_pair
            /
            math.sqrt(
                so_a * so_b
            )
        )

    else:
        so_similarity = 0.0


    role_pair = role_pair_frequency.get(
        (skill_a, skill_b),
        0,
    )

    role_a = role_skill_frequency.get(
        skill_a,
        0,
    )

    role_b = role_skill_frequency.get(
        skill_b,
        0,
    )


    if (
        role_pair > 0
        and role_a > 0
        and role_b > 0
    ):

        role_similarity = (
            role_pair
            /
            math.sqrt(
                role_a * role_b
            )
        )

    else:
        role_similarity = 0.0


    sources = []

    if so_pair > 0:
        sources.append(
            "stackoverflow"
        )

    if role_pair > 0:
        sources.append(
            "role_map"
        )


    rows.append(
        {
            "skill_a": skill_a,
            "skill_b": skill_b,

            "stackoverflow_cooccurrence":
                so_pair,

            "stackoverflow_similarity":
                round(
                    so_similarity,
                    4,
                ),

            "role_cooccurrence":
                role_pair,

            "role_similarity":
                round(
                    role_similarity,
                    4,
                ),

            "source_count":
                len(sources),

            "sources":
                "|".join(sources),
        }
    )


relationships = pd.DataFrame(
    rows
)


# ============================================================
# SORT
# ============================================================

relationships[
    "evidence_score"
] = (
    relationships[
        "stackoverflow_similarity"
    ]
    +
    relationships[
        "role_similarity"
    ]
)


relationships = (
    relationships
    .sort_values(
        [
            "source_count",
            "evidence_score",
            "stackoverflow_cooccurrence",
        ],
        ascending=[
            False,
            False,
            False,
        ],
    )
    .reset_index(drop=True)
)


# ============================================================
# SAVE
# ============================================================

relationships.to_csv(
    OUTPUT_FILE,
    index=False,
)


print()
print("=" * 70)
print("RELATIONSHIP BUILD COMPLETE")
print("=" * 70)

print(
    f"\nTotal relationships: "
    f"{len(relationships):,}"
)

both_sources_count = (
    relationships["source_count"] == 2
).sum()

print(
    f"Relationships supported by BOTH sources: "
    f"{both_sources_count:,}"
)

print()
print("TOP 30 RELATIONSHIPS")
print("-" * 70)

print(
    relationships[
        [
            "skill_a",
            "skill_b",
            "stackoverflow_cooccurrence",
            "stackoverflow_similarity",
            "role_cooccurrence",
            "role_similarity",
            "source_count",
        ]
    ]
    .head(30)
    .to_string(
        index=False
    )
)

print()
print("Saved:")
print(OUTPUT_FILE)