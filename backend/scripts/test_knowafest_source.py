from pathlib import Path
import sys


ROOT = Path(__file__).resolve().parents[2]

if str(ROOT) not in sys.path:
    sys.path.insert(
        0,
        str(ROOT),
    )


from backend.app.sources.knowafest_source import KnowAFestSource


URL = (
    "https://www.knowafest.com/event/"
    "sakthi-hack-fest-26"
)

source = KnowAFestSource()

event = source.fetch_event(
    URL
)


print("=" * 70)
print("REAL KNOWAFEST EVENT")
print("=" * 70)

for key, value in event.to_dict().items():

    print(
        f"{key:<25}: {value}"
    )