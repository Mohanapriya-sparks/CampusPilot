from pathlib import Path

import pandas as pd


ROOT = Path(__file__).resolve().parents[2]

MASTER_FILE = (
    ROOT
    / "backend"
    / "data"
    / "derived"
    / "campuspilot_master_skills_final.csv"
)

CORE_FILE = (
    ROOT
    / "backend"
    / "data"
    / "curated"
    / "campuspilot_core_skills.csv"
)


print(
    "Loading CampusPilot master vocabulary..."
)


master = pd.read_csv(
    MASTER_FILE
)

core = pd.read_csv(
    CORE_FILE
)


# ============================================================
# NORMALIZE CORE SKILLS
# ============================================================

core["skill"] = (
    core["skill"]
    .astype(str)
    .str.strip()
    .str.lower()
)

master["skill"] = (
    master["skill"]
    .astype(str)
    .str.strip()
    .str.lower()
)


# ============================================================
# ADD CAMPUSPILOT CORE SOURCE
# ============================================================

processed = []


for _, core_row in core.iterrows():

    skill = str(
        core_row["skill"]
    ).strip().lower()

    if not skill:
        continue

    matching_rows = (
        master["skill"]
        == skill
    )

    # --------------------------------------------------------
    # SKILL ALREADY EXISTS
    # --------------------------------------------------------

    if matching_rows.any():

        index = master[
            matching_rows
        ].index[0]

        current_sources = str(
            master.at[
                index,
                "sources",
            ]
            or ""
        )

        if (
            current_sources.lower()
            == "nan"
        ):
            current_sources = ""

        sources = [
            source.strip()
            for source
            in current_sources.split("|")
            if source.strip()
        ]

        if (
            "campuspilot_core"
            not in sources
        ):
            sources.append(
                "campuspilot_core"
            )

        master.at[
            index,
            "sources",
        ] = "|".join(
            sources
        )

        master.at[
            index,
            "source_count",
        ] = len(
            set(
                sources
            )
        )

    # --------------------------------------------------------
    # COMPLETELY NEW CORE SKILL
    # --------------------------------------------------------

    else:

        new_row = {}

        for column in master.columns:

            if column == "skill":

                new_row[column] = (
                    skill
                )

            elif column == "sources":

                new_row[column] = (
                    "campuspilot_core"
                )

            elif column == "source_count":

                new_row[column] = 1

            elif column in {
                "resume_frequency",
                "technical_frequency",
                "linkedin_frequency",
                "priority_score",
                "stackoverflow_frequency",
                "stackoverflow_score",
            }:

                new_row[column] = 0

            else:

                new_row[column] = ""

        master = pd.concat(
            [
                master,
                pd.DataFrame(
                    [
                        new_row
                    ]
                ),
            ],
            ignore_index=True,
        )

    processed.append(
        skill
    )


# ============================================================
# REMOVE DUPLICATES
# ============================================================

master = (
    master
    .drop_duplicates(
        subset=[
            "skill"
        ],
        keep="first",
    )
    .reset_index(
        drop=True
    )
)


# ============================================================
# SAVE
# ============================================================

master.to_csv(
    MASTER_FILE,
    index=False,
)


print()
print("=" * 65)
print(
    "CAMPUSPILOT FINAL VOCABULARY"
)
print("=" * 65)

print(
    f"Final skills: "
    f"{len(master):,}"
)

print(
    f"Curated core skills processed: "
    f"{len(processed)}"
)

print()
print("Core skills:")

for skill in processed:

    print(
        f"✓ {skill}"
    )

print()
print("Saved:")
print(
    MASTER_FILE
)