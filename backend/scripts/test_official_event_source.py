from pathlib import Path
import sys


ROOT = Path(__file__).resolve().parents[2]

if str(ROOT) not in sys.path:
    sys.path.insert(
        0,
        str(ROOT),
    )


from backend.app.sources.knowafest_source import KnowAFestSource
from backend.app.sources.official_event_source import OfficialEventSource


KNOWAFEST_URL = (
    "https://www.knowafest.com/event/"
    "sakthi-hack-fest-26"
)

knowafest = KnowAFestSource()

official = OfficialEventSource()


event = knowafest.fetch_event(
    KNOWAFEST_URL
)


print("=" * 70)
print("BEFORE OFFICIAL VERIFICATION")
print("=" * 70)

print(
    "verified   :",
    event.verified,
)

print(
    "prize      :",
    event.prize,
)

print(
    "eligibility:",
    event.eligibility,
)

print(
    "official   :",
    event.official_url,
)


event = official.enrich(
    event
)


print()
print("=" * 70)
print("AFTER OFFICIAL VERIFICATION")
print("=" * 70)

print(
    "verified   :",
    event.verified,
)

print(
    "prize      :",
    event.prize,
)

print(
    "eligibility:",
    event.eligibility,
)

print(
    "last checked:",
    event.last_checked,
)