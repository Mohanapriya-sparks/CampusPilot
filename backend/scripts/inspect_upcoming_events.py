from pathlib import Path
from collections import Counter
import json


ROOT = Path(__file__).resolve().parents[2]

DATA_FILE = (
    ROOT
    / "backend"
    / "data"
    / "derived"
    / "campuspilot_upcoming_events.json"
)


with open(
    DATA_FILE,
    "r",
    encoding="utf-8",
) as file:

    data = json.load(file)


events = data.get(
    "events",
    []
)


# ============================================================
# BASIC SUMMARY
# ============================================================

print("=" * 75)
print("CAMPUSPILOT UPCOMING EVENTS AUDIT")
print("=" * 75)

print(
    f"\nTotal events: "
    f"{len(events)}"
)


verified = [
    event
    for event in events
    if event.get("verified")
]

print(
    f"Verified: "
    f"{len(verified)}"
)

print(
    f"Unverified: "
    f"{len(events) - len(verified)}"
)


# ============================================================
# EVENT TYPES
# ============================================================

event_types = Counter(
    event.get("event_type") or "UNKNOWN"
    for event in events
)

print()
print("EVENT TYPES")
print("-" * 50)

for name, count in event_types.most_common():

    print(
        f"{name:<30} {count}"
    )


# ============================================================
# MISSING FIELDS
# ============================================================

important_fields = [
    "title",
    "event_type",
    "start_date",
    "registration_deadline",
    "location",
    "mode",
    "fee",
    "description",
    "required_skills",
    "official_url",
    "registration_url",
    "image_url",
]


print()
print("MISSING FIELD COUNTS")
print("-" * 50)


for field in important_fields:

    missing = sum(
        1
        for event in events
        if event.get(field) in [
            None,
            "",
            [],
        ]
    )

    print(
        f"{field:<30} {missing}"
    )


# ============================================================
# SKILL QUALITY
# ============================================================

all_skills = Counter()

events_without_skills = []


for event in events:

    skills = event.get(
        "required_skills",
        [],
    )

    if not skills:

        events_without_skills.append(
            event.get(
                "title",
                "UNKNOWN",
            )
        )

    for skill in skills:

        all_skills[
            skill
        ] += 1


print()
print("TOP EXTRACTED SKILLS")
print("-" * 50)


for skill, count in all_skills.most_common(
    30
):

    print(
        f"{skill:<35} {count}"
    )


print()
print("EVENTS WITHOUT SKILLS")
print("-" * 50)


if events_without_skills:

    for title in events_without_skills:

        print(
            f"- {title}"
        )

else:

    print(
        "None"
    )


# ============================================================
# URL AUDIT
# ============================================================

registration_urls = []

bad_official_urls = []

duplicate_urls = []


for event in events:

    title = event.get(
        "title",
        "UNKNOWN",
    )

    registration_url = str(
        event.get(
            "registration_url",
            "",
        )
        or ""
    ).strip()

    official_url = str(
        event.get(
            "official_url",
            "",
        )
        or ""
    ).strip()


    # --------------------------------------------------------
    # REGISTRATION URL
    # --------------------------------------------------------

    if registration_url:

        registration_urls.append(
            (
                title,
                registration_url,
            )
        )


    # --------------------------------------------------------
    # GOOGLE FORM INCORRECTLY STORED AS OFFICIAL URL
    # --------------------------------------------------------

    lower_official = (
        official_url.lower()
    )

    if (
        "docs.google.com/forms"
        in lower_official
        or "forms.gle"
        in lower_official
    ):

        bad_official_urls.append(
            (
                title,
                official_url,
            )
        )


    # --------------------------------------------------------
    # DUPLICATE OFFICIAL + REGISTRATION URL
    # --------------------------------------------------------

    if (
        official_url
        and registration_url
        and official_url.rstrip("/")
        == registration_url.rstrip("/")
    ):

        duplicate_urls.append(
            (
                title,
                official_url,
            )
        )


# ============================================================
# REGISTRATION URL REPORT
# ============================================================

print()
print("REGISTRATION URLS")
print("-" * 75)


if registration_urls:

    for title, url in registration_urls:

        print()
        print(title)
        print(url)

else:

    print(
        "None"
    )


print()
print(
    f"Registration URLs: "
    f"{len(registration_urls)}"
)


# ============================================================
# BAD OFFICIAL URL REPORT
# ============================================================

print()
print(
    "REGISTRATION FORMS STILL IN OFFICIAL_URL"
)
print("-" * 75)


if bad_official_urls:

    for title, url in bad_official_urls:

        print()
        print(title)
        print(url)

else:

    print(
        "None"
    )


print()
print(
    f"Bad official URLs: "
    f"{len(bad_official_urls)}"
)


# ============================================================
# DUPLICATE URL REPORT
# ============================================================

print()
print(
    "DUPLICATE OFFICIAL / REGISTRATION URLS"
)
print("-" * 75)


if duplicate_urls:

    for title, url in duplicate_urls:

        print()
        print(title)
        print(url)

else:

    print(
        "None"
    )


print()
print(
    f"Duplicate URLs: "
    f"{len(duplicate_urls)}"
)


# ============================================================
# FINAL HEALTH SUMMARY
# ============================================================

print()
print("=" * 75)
print("AUDIT SUMMARY")
print("=" * 75)

print(
    f"Events: "
    f"{len(events)}"
)

print(
    f"Verified: "
    f"{len(verified)}"
)

print(
    f"Events without skills: "
    f"{len(events_without_skills)}"
)

print(
    f"Registration URLs: "
    f"{len(registration_urls)}"
)

print(
    f"Bad official URLs: "
    f"{len(bad_official_urls)}"
)

print(
    f"Duplicate URLs: "
    f"{len(duplicate_urls)}"
)