from pathlib import Path
import pandas as pd


ROOT = Path(__file__).resolve().parents[1]

VOCAB_FILE = (
    ROOT
    / "data"
    / "derived"
    / "campuspilot_master_skills_final.csv"
)


IMPORTANT_SKILLS = [
    "flutter",
    "dart",
    "firebase",
    "git",
    "github",

    "python",
    "java",
    "c",
    "c++",
    "c#",

    "javascript",
    "typescript",

    "react",
    "angular",
    "vue.js",
    "node.js",

    "html",
    "css",

    "sql",
    "mysql",
    "postgresql",
    "mongodb",

    "rest api",
    "graphql",

    "machine learning",
    "deep learning",
    "artificial intelligence",
    "ai",

    "tensorflow",
    "pytorch",
    "opencv",
    "nlp",

    "data science",
    "data analysis",
    "data visualization",

    "figma",
    "ui/ux",

    "docker",
    "kubernetes",

    "aws",
    "azure",
    "gcp",

    "jenkins",
    "terraform",
    "ci/cd",

    "linux",

    "cybersecurity",
    "network security",
    "penetration testing",

    "blockchain",
    "ethereum",
    "solidity",
    "web3",

    "arduino",
    "esp32",
    "iot",

    "problem solving",
    "teamwork",
    "communication",
    "leadership",
    "project management",
]


df = pd.read_csv(VOCAB_FILE)

available = set(
    df["skill"]
    .dropna()
    .astype(str)
    .str.lower()
)

ALIASES = {
    "ai": "artificial intelligence",
}


found = []
missing = []

for skill in IMPORTANT_SKILLS:

    canonical = ALIASES.get(
        skill,
        skill,
    )

    if canonical in available:
        found.append(skill)
    else:
        missing.append(skill)
print("=" * 70)
print("CAMPUSPILOT SKILL COVERAGE")
print("=" * 70)

print(
    f"\nImportant skills tested: "
    f"{len(IMPORTANT_SKILLS)}"
)

print(
    f"Found: {len(found)}"
)

print(
    f"Missing: {len(missing)}"
)


print()
print("FOUND")
print("-" * 40)

for skill in found:
    print(f"✓ {skill}")


print()
print("MISSING")
print("-" * 40)

for skill in missing:
    print(f"✗ {skill}")


coverage = (
    len(found)
    / len(IMPORTANT_SKILLS)
    * 100
)

print()
print(
    f"Coverage: {coverage:.1f}%"
)