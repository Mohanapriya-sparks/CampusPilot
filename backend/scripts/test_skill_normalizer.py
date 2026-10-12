from pathlib import Path
import sys


# Add CampusPilot project root to Python path
ROOT = Path(__file__).resolve().parents[2]

if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))


from backend.app.intelligence.skill_normalizer import SkillNormalizer


skills = [
    "AI",
    "AI/ML",
    "Git Hub",
    "ESP-32",
    "Internet of Things",
    "Torch/PyTorch",
    "React.js",
    "Google Cloud Platform",
]


result = SkillNormalizer.normalize_many(
    skills
)


print("NORMALIZED SKILLS")
print("-" * 40)

for skill in result:
    print(skill)