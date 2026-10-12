from pathlib import Path
from collections import Counter
import re

import pandas as pd


ROOT = Path(__file__).resolve().parents[1]

DERIVED_DIR = ROOT / "data" / "derived"

RESUME_SKILLS_FILE = (
    DERIVED_DIR
    / "skill_vocabulary_clean.csv"
)

TECHNICAL_SKILLS_FILE = (
    ROOT
    / "data"
    / "technical_skills"
    / "candidate_job_role_dataset.csv"
)

LINKEDIN_SKILLS_FILE = (
    ROOT
    / "data"
    / "linkedin_jobs"
    / "skills.csv"
)

OUTPUT_FILE = (
    DERIVED_DIR
    / "campuspilot_master_skills.csv"
)

ROLE_MAP_FILE = (
    DERIVED_DIR
    / "campuspilot_role_skill_map.csv"
)


# ============================================================
# NORMALIZATION
# ============================================================

ALIASES = {
    "rest apis": "rest api",
    "restful api": "rest api",
    "restful apis": "rest api",

    "machine-learning": "machine learning",
    "ml": "machine learning",

    "artificial intelligence": "ai",
    "ai/ml": "ai",

    "ui/ux design": "ui/ux",
    "ui ux": "ui/ux",

    "user interface design": "ui/ux",
    "user experience design": "ui/ux",

    "amazon web services": "aws",

    "google cloud platform": "gcp",

    "microsoft azure": "azure",

    "continuous integration": "ci/cd",
    "continuous delivery": "ci/cd",

    "springboot": "spring boot",

    "nodejs": "node.js",
    "node js": "node.js",

    "javascript": "javascript",
    "java script": "javascript",

    "typescript": "typescript",

    "reactjs": "react",
    "react.js": "react",

    "vuejs": "vue.js",

    "mongodb": "mongodb",

    "postgres": "postgresql",

    "git hub": "github",

    "problem-solving": "problem solving",

    "team work": "teamwork",
    "team-work": "teamwork",

    "communication skills": "communication",

    "project mgmt": "project management",

    "data visualisation": "data visualization",
}


def normalize_skill(value: str) -> str:

    value = str(value).strip().lower()

    value = re.sub(
        r"\s+",
        " ",
        value,
    )

    value = value.strip(
        " ,.;:|"
    )

    return ALIASES.get(
        value,
        value,
    )


def valid_skill(skill: str) -> bool:

    if not skill:
        return False

    if len(skill) < 2:
        return False

    if len(skill) > 70:
        return False

    if len(skill.split()) > 8:
        return False

    return True


# ============================================================
# STORAGE
# ============================================================

resume_frequency = Counter()

technical_frequency = Counter()

linkedin_frequency = Counter()

skill_sources = {}

role_skill_rows = []


def add_source(
    skill: str,
    source: str,
):

    if skill not in skill_sources:
        skill_sources[skill] = set()

    skill_sources[skill].add(
        source
    )


# ============================================================
# 1. RESUME VOCABULARY
# ============================================================

print(
    "Loading Resume skill vocabulary..."
)

resume_df = pd.read_csv(
    RESUME_SKILLS_FILE
)


for _, row in resume_df.iterrows():

    skill = normalize_skill(
        row["skill"]
    )

    if not valid_skill(skill):
        continue

    frequency = int(
        row.get(
            "frequency",
            1,
        )
    )

    resume_frequency[skill] += (
        frequency
    )

    add_source(
        skill,
        "resume",
    )


print(
    f"Resume skills loaded: "
    f"{len(resume_frequency):,}"
)


# ============================================================
# 2. TECHNICAL CANDIDATE DATASET
# ============================================================

print(
    "Loading technical role skills..."
)

technical_df = pd.read_csv(
    TECHNICAL_SKILLS_FILE
)


for _, row in technical_df.iterrows():

    role = str(
        row["job_role"]
    ).strip()

    skills_text = str(
        row["skills"]
    )

    pieces = re.split(
        r"[,;|]+",
        skills_text,
    )

    for raw_skill in pieces:

        skill = normalize_skill(
            raw_skill
        )

        if not valid_skill(skill):
            continue

        technical_frequency[
            skill
        ] += 1

        add_source(
            skill,
            "technical_roles",
        )

        role_skill_rows.append(
            {
                "job_role": role,
                "skill": skill,
            }
        )


print(
    f"Technical skills loaded: "
    f"{len(technical_frequency):,}"
)


# ============================================================
# 3. LINKEDIN BROAD SKILL CATEGORIES
# ============================================================

print(
    "Loading LinkedIn skill categories..."
)

linkedin_df = pd.read_csv(
    LINKEDIN_SKILLS_FILE
)


for _, row in linkedin_df.iterrows():

    skill = normalize_skill(
        row["skill_name"]
    )

    if not valid_skill(skill):
        continue

    linkedin_frequency[
        skill
    ] += 1

    add_source(
        skill,
        "linkedin",
    )


print(
    f"LinkedIn categories loaded: "
    f"{len(linkedin_frequency):,}"
)


# ============================================================
# BUILD MASTER VOCABULARY
# ============================================================

all_skills = sorted(
    set(resume_frequency)
    | set(technical_frequency)
    | set(linkedin_frequency)
)


rows = []


for skill in all_skills:

    resume_count = (
        resume_frequency.get(
            skill,
            0,
        )
    )

    technical_count = (
        technical_frequency.get(
            skill,
            0,
        )
    )

    linkedin_count = (
        linkedin_frequency.get(
            skill,
            0,
        )
    )

    sources = sorted(
        skill_sources.get(
            skill,
            set(),
        )
    )

    rows.append(
        {
            "skill": skill,

            "resume_frequency":
                resume_count,

            "technical_frequency":
                technical_count,

            "linkedin_frequency":
                linkedin_count,

            "source_count":
                len(sources),

            "sources":
                "|".join(sources),
        }
    )


master_df = pd.DataFrame(
    rows
)


# ============================================================
# PRIORITY SCORE
#
# Technical skills receive extra weight because CampusPilot
# focuses on student opportunities / hackathons.
# ============================================================

master_df["priority_score"] = (
    master_df["resume_frequency"]
    +
    (
        master_df[
            "technical_frequency"
        ]
        * 5
    )
    +
    (
        master_df[
            "linkedin_frequency"
        ]
        * 2
    )
)


master_df = (
    master_df
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


DERIVED_DIR.mkdir(
    parents=True,
    exist_ok=True,
)


master_df.to_csv(
    OUTPUT_FILE,
    index=False,
)


# ============================================================
# ROLE → SKILL MAP
# ============================================================

role_df = pd.DataFrame(
    role_skill_rows
)

role_df = (
    role_df
    .drop_duplicates()
    .sort_values(
        [
            "job_role",
            "skill",
        ]
    )
)

role_df.to_csv(
    ROLE_MAP_FILE,
    index=False,
)


# ============================================================
# RESULTS
# ============================================================

print()
print("=" * 70)
print(
    "CAMPUSPILOT MASTER SKILL VOCABULARY"
)
print("=" * 70)

print(
    f"Total master skills: "
    f"{len(master_df):,}"
)

print()
print(
    "Skills appearing in multiple sources:"
)

multi_source = master_df[
    master_df[
        "source_count"
    ] >= 2
]

print(
    f"{len(multi_source):,}"
)

print()
print("TOP 100 SKILLS:")
print()

print(
    master_df[
        [
            "skill",
            "resume_frequency",
            "technical_frequency",
            "source_count",
            "priority_score",
        ]
    ]
    .head(100)
    .to_string(
        index=False
    )
)


print()
print(
    "Master vocabulary saved:"
)

print(
    OUTPUT_FILE
)


print()
print(
    "Role → skill map saved:"
)

print(
    ROLE_MAP_FILE
)