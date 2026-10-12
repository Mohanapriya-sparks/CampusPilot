import sys
from pathlib import Path


ROOT = (
    Path(__file__)
    .resolve()
    .parents[1]
)

sys.path.insert(
    0,
    str(ROOT.parent),
)


from backend.app.intelligence.skill_extractor import (
    SkillExtractor,
)


extractor = SkillExtractor()


samples = [

    """
    Looking for students with experience in
    project management, leadership,
    Microsoft Excel and problem solving.
    """,

    """
    Participants should demonstrate
    teamwork, research, presentation
    skills and database knowledge.
    """,

    """
    Build an innovative solution involving
    marketing, customer service and
    financial analysis.
    """,
]


for index, text in enumerate(
    samples,
    start=1,
):

    print()
    print("=" * 60)

    print(
        f"TEST {index}"
    )

    print(
        "=" * 60
    )

    print(
        extractor.extract(text)
    )

    """
    Build an AI-powered IoT system using ESP32,
    Firebase and Flutter. Use GitHub for version control,
    GraphQL APIs, PyTorch and OpenCV.
    The team should also understand cyber security.
    """