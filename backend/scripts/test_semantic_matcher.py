from pathlib import Path
import sys


ROOT = Path(__file__).resolve().parents[2]

if str(ROOT) not in sys.path:
    sys.path.insert(
        0,
        str(ROOT),
    )


from backend.app.intelligence.semantic_matcher import SemanticMatcher


matcher = SemanticMatcher()


student_skills = [
    "Flutter",
    "Dart",
    "Firebase",
    "GitHub",
    "Figma",
    "PyTorch",
    "ESP32",
]


event_skills = [
    "Flutter",
    "Git",
    "UI/UX",
    "Machine Learning",
    "IoT",
    "Cybersecurity",
]


result = matcher.match_event(
    student_skills,
    event_skills,
)


print("=" * 60)
print("CAMPUSPILOT SEMANTIC MATCH")
print("=" * 60)

print(
    f"\nReadiness: "
    f"{result['readiness']}%"
)


print("\nMATCHES")
print("-" * 60)

for item in result["matches"]:

    print(
        f"{str(item['student_skill']):<20}"
        f" -> "
        f"{item['required_skill']:<25}"
        f" {item['match_type']:<10}"
        f" {item['score']}"
    )


print()
print(
    f"Strong:  "
    f"{len(result['strong'])}"
)

print(
    f"Partial: "
    f"{len(result['partial'])}"
)

print(
    f"Missing: "
    f"{len(result['missing'])}"
)