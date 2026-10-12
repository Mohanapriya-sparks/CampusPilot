from pathlib import Path
import sys


ROOT = Path(__file__).resolve().parents[2]

if str(ROOT) not in sys.path:
    sys.path.insert(
        0,
        str(ROOT),
    )


from backend.app.services.opportunity_normalizer import OpportunityNormalizer


raw_event = {

    "title":
        "AI and Flutter Innovation Hackathon",

    "event_type":
        "hackathons",

    "organizer":
        "Example Engineering College",

    "description":
        """
        Build an AI-powered mobile application
        using Flutter, Firebase and machine learning.
        Teams should use GitHub for collaboration.
        UI/UX design experience is helpful.
        """,

    "start_date":
        "2026-11-15",

    "registration_deadline":
        "2026-11-05",

    "location":
        "Chennai, Tamil Nadu",

    "city":
        "Chennai",

    "state":
        "Tamil Nadu",

    "mode":
        "in-person",

    "fee":
        "₹200",

    "interests": [
        "AI",
        "Mobile Development",
    ],

    "tags": [
        "Flutter",
        "Firebase",
        "Machine Learning",
    ],

    "source":
        "official",

    "source_url":
        "https://example.com/event",

    "verified":
        True,
}


normalizer = OpportunityNormalizer()

event = normalizer.normalize(
    raw_event
)


print("=" * 70)
print("NORMALIZED CAMPUSPILOT OPPORTUNITY")
print("=" * 70)

for key, value in event.to_dict().items():

    print(
        f"{key:<25}: {value}"
    )