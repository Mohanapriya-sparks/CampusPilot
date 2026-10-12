from pathlib import Path
import sys


ROOT = Path(__file__).resolve().parents[2]

if str(ROOT) not in sys.path:
    sys.path.insert(
        0,
        str(ROOT),
    )


from backend.app.intelligence.recommender import EventRecommender


profile = {

    "skills": [
        "Flutter",
        "Dart",
        "Firebase",
        "GitHub",
        "Figma",
        "PyTorch",
        "ESP32",
    ],

    "interests": [
        "AI",
        "Mobile Development",
        "Hackathons",
        "IoT",
    ],

    "preferred_event_types": [
        "Hackathon",
        "Workshop",
    ],

    "preferred_mode":
        "Offline",

    "preferred_location":
        "Chennai",
}


events = [

    {
        "id": "event_001",

        "title":
            "AI + Mobile Hackathon",

        "event_type":
            "Hackathon",

        "mode":
            "Offline",

        "location":
            "Chennai",

        "interests": [
            "AI",
            "Mobile Development",
        ],

        "required_skills": [
            "Flutter",
            "Git",
            "Machine Learning",
            "UI/UX",
        ],
    },

    {
        "id": "event_002",

        "title":
            "Cybersecurity Challenge",

        "event_type":
            "Hackathon",

        "mode":
            "Online",

        "location":
            "Bengaluru",

        "interests": [
            "Cybersecurity",
        ],

        "required_skills": [
            "Cybersecurity",
            "Network Security",
            "Linux",
        ],
    },

    {
        "id": "event_003",

        "title":
            "IoT Innovation Workshop",

        "event_type":
            "Workshop",

        "mode":
            "Offline",

        "location":
            "Chennai",

        "interests": [
            "IoT",
        ],

        "required_skills": [
            "IoT",
            "Arduino",
        ],
    },
]


recommender = EventRecommender()


results = recommender.rank_events(
    profile,
    events,
)


print("=" * 70)
print("CAMPUSPILOT EVENT RECOMMENDATIONS")
print("=" * 70)


for index, result in enumerate(
    results,
    start=1,
):

    print()
    print(
        f"{index}. "
        f"{result['title']}"
    )

    print(
        f"   Event Fit: "
        f"{result['event_fit']}%"
    )

    print(
        f"   Readiness: "
        f"{result['readiness']}%"
    )

    print(
        f"   Missing skills: "
        f"{len(result['missing_skills'])}"
    )

    print(
        f"   Components: "
        f"{result['components']}"
    )