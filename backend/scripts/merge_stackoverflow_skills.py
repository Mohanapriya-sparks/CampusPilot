from pathlib import Path
from collections import Counter
import re

import pandas as pd


ROOT = Path(__file__).resolve().parents[1]

STACKOVERFLOW_FILE = (
    ROOT
    / "data"
    / "stackoverflow_2024"
    / "survey_results_public.csv"
)

MASTER_FILE = (
    ROOT
    / "data"
    / "derived"
    / "campuspilot_master_skills.csv"
)

OUTPUT_FILE = (
    ROOT
    / "data"
    / "derived"
    / "campuspilot_master_skills_v2.csv"
)


# ============================================================
# TECHNOLOGY COLUMNS
# ============================================================

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
# NORMALIZATION
# ============================================================

ALIASES = {
    "torch/pytorch": "pytorch",

    "amazon web services (aws)": "aws",
    "microsoft azure": "azure",
    "google cloud": "gcp",

    "react.js": "react",
    "vuejs": "vue.js",

    "nodejs": "node.js",

    "postgres": "postgresql",

    "springboot": "spring boot",

    "rasberry pi": "raspberry pi",

    "bash/shell (all shells)": "bash",

    ".net (5+)": ".net",
    ".net framework (1.0 - 4.8)": ".net framework",

    "visual studio code": "vs code",

    "maven (build tool)": "maven",
}


EXPANSIONS = {
    "html/css": [
        "html",
        "css",
    ],
}


def normalize(value: str) -> str:
    value = str(value).strip().lower()

    value = re.sub(
        r"\s+",
        " ",
        value,
    )

    return ALIASES.get(
        value,
        value,
    )


# ============================================================
# LOAD CURRENT MASTER
# ============================================================

print("Loading current CampusPilot vocabulary...")

master = pd.read_csv(
    MASTER_FILE
)

print(
    f"Current skills: {len(master):,}"
)


# Add Stack Overflow columns if they don't exist yet.

if "stackoverflow_frequency" not in master.columns:
    master["stackoverflow_frequency"] = 0


# ============================================================
# LOAD STACK OVERFLOW
# ============================================================

print(
    "Loading Stack Overflow 2024..."
)

survey = pd.read_csv(
    STACKOVERFLOW_FILE,
    low_memory=False,
)

available_columns = [
    column
    for column in TECH_COLUMNS
    if column in survey.columns
]


print(
    f"Technology columns found: "
    f"{len(available_columns)}"
)


# ============================================================
# EXTRACT TECHNOLOGIES
# ============================================================

stackoverflow_frequency = Counter()


for column in available_columns:

    values = (
        survey[column]
        .dropna()
        .astype(str)
    )

    for value in values:

        raw_items = value.split(";")

        for raw in raw_items:

            raw = raw.strip().lower()

            if not raw:
                continue

            # Special expansion:
            # html/css becomes html + css

            if raw in EXPANSIONS:

                for item in EXPANSIONS[raw]:

                    stackoverflow_frequency[
                        item
                    ] += 1

                continue

            skill = normalize(raw)

            if skill:
                stackoverflow_frequency[
                    skill
                ] += 1


print(
    f"Unique Stack Overflow technologies: "
    f"{len(stackoverflow_frequency):,}"
)


# ============================================================
# MERGE
# ============================================================

existing_index = {
    str(row["skill"]).lower():
        index
    for index, row
    in master.iterrows()
}


new_rows = []


for skill, frequency in (
    stackoverflow_frequency.items()
):

    skill = normalize(skill)

    if skill in existing_index:

        index = existing_index[
            skill
        ]

        master.at[
            index,
            "stackoverflow_frequency"
        ] = frequency

        current_sources = str(
            master.at[
                index,
                "sources"
            ]
        )

        source_set = {
            item
            for item in current_sources.split("|")
            if item
            and item != "nan"
        }

        source_set.add(
            "stackoverflow"
        )

        master.at[
            index,
            "sources"
        ] = "|".join(
            sorted(source_set)
        )

        master.at[
            index,
            "source_count"
        ] = len(source_set)

    else:

        new_rows.append(
            {
                "skill": skill,
                "resume_frequency": 0,
                "technical_frequency": 0,
                "linkedin_frequency": 0,
                "stackoverflow_frequency":
                    frequency,
                "source_count": 1,
                "sources": "stackoverflow",
                "priority_score": 0,
            }
        )


if new_rows:

    master = pd.concat(
        [
            master,
            pd.DataFrame(new_rows),
        ],
        ignore_index=True,
    )


# ============================================================
# RECOMPUTE SCORE
#
# We don't let Stack Overflow frequency dominate because
# tens of thousands of developers selected popular tools.
# ============================================================

master[
    "stackoverflow_score"
] = (
    master[
        "stackoverflow_frequency"
    ]
    .fillna(0)
    .clip(
        upper=10000,
    )
    / 100
)


master[
    "priority_score"
] = (
    master[
        "resume_frequency"
    ].fillna(0)

    +

    master[
        "technical_frequency"
    ].fillna(0) * 5

    +

    master[
        "linkedin_frequency"
    ].fillna(0) * 2

    +

    master[
        "stackoverflow_score"
    ]
)


master = (
    master
    .drop_duplicates(
        subset=["skill"]
    )
    .sort_values(
        [
            "priority_score",
            "source_count",
            "skill",
        ],
        ascending=[
            False,
            False,
            True,
        ],
    )
    .reset_index(
        drop=True
    )
)


# ============================================================
# SAVE
# ============================================================

master.to_csv(
    OUTPUT_FILE,
    index=False,
)


print()
print("=" * 70)
print("STACK OVERFLOW MERGE COMPLETE")
print("=" * 70)

print(
    f"Final master skills: "
    f"{len(master):,}"
)

print(
    f"New Stack Overflow-only skills: "
    f"{len(new_rows):,}"
)


important = [
    "flutter",
    "dart",
    "firebase",
    "c",
    "pytorch",
    "opencv",
    "arduino",
    "raspberry pi",
]


print()
print("IMPORTANT TECHNOLOGIES")
print("-" * 50)


available = set(
    master["skill"]
    .astype(str)
    .str.lower()
)


for skill in important:

    if skill in available:
        print(f"✓ {skill}")
    else:
        print(f"✗ {skill}")


print()
print("Saved to:")
print(OUTPUT_FILE)