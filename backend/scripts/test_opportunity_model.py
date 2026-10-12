from pathlib import Path
import sys


ROOT = Path(__file__).resolve().parents[2]

if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))


from backend.app.models.opportunity import Opportunity


event = Opportunity(
    id="test_001",

    title="AI Innovation Hackathon",

    event_type="Hackathon",

    organizer="Example University",

    start_date="2026-11-10",

    registration_deadline="2026-11-01",

    location="Chennai, Tamil Nadu",

    city="Chennai",

    state="Tamil Nadu",

    mode="Offline",

    interests=[
        "AI",
        "Mobile Development",
    ],

    required_skills=[
        "Python",
        "Machine Learning",
        "Git",
    ],

    source="official",

    source_url="https://example.com",

    verified=True,
)


print("=" * 60)
print("CAMPUSPILOT OPPORTUNITY MODEL")
print("=" * 60)

for key, value in event.to_dict().items():
    print(
        f"{key:<25}: {value}"
    )