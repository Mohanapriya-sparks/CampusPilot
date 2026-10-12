from pathlib import Path
import pandas as pd


ROOT = Path(__file__).resolve().parents[1]

RELATIONSHIP_FILE = (
    ROOT
    / "data"
    / "derived"
    / "campuspilot_skill_relationships.csv"
)


TARGET_SKILLS = [
    "flutter",
    "dart",
    "firebase",
    "git",
    "github",

    "python",
    "javascript",
    "react",
    "node.js",

    "machine learning",
    "artificial intelligence",
    "pytorch",
    "tensorflow",

    "figma",
    "ui/ux",

    "iot",
    "esp32",
    "arduino",

    "cybersecurity",
    "network security",

    "docker",
    "kubernetes",
    "aws",

    "blockchain",
    "ethereum",
    "solidity",
]


df = pd.read_csv(
    RELATIONSHIP_FILE
)


def relationships_for(skill):

    left = df[
        df["skill_a"] == skill
    ].copy()

    if not left.empty:
        left["related_skill"] = (
            left["skill_b"]
        )


    right = df[
        df["skill_b"] == skill
    ].copy()

    if not right.empty:
        right["related_skill"] = (
            right["skill_a"]
        )


    combined = pd.concat(
        [
            left,
            right,
        ],
        ignore_index=True,
    )


    if combined.empty:
        return combined


    combined[
        "combined_score"
    ] = (
        combined[
            "stackoverflow_similarity"
        ]
        +
        combined[
            "role_similarity"
        ]
    )


    return (
        combined
        .sort_values(
            [
                "source_count",
                "combined_score",
                "stackoverflow_cooccurrence",
            ],
            ascending=[
                False,
                False,
                False,
            ],
        )
        .head(10)
    )


print("=" * 80)
print("CAMPUSPILOT RELATIONSHIP INSPECTION")
print("=" * 80)


for skill in TARGET_SKILLS:

    print()
    print("=" * 80)
    print(skill.upper())
    print("=" * 80)

    result = relationships_for(
        skill
    )

    if result.empty:
        print("No relationships found.")
        continue


    for _, row in result.iterrows():

        print(
            f"{row['related_skill']:<28}"
            f" SO={row['stackoverflow_similarity']:<7.4f}"
            f" Role={row['role_similarity']:<7.4f}"
            f" Sources={int(row['source_count'])}"
            f" Co={int(row['stackoverflow_cooccurrence'])}"
        )