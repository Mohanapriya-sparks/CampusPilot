from pathlib import Path
import sys


ROOT = Path(__file__).resolve().parents[2]

if str(ROOT) not in sys.path:
    sys.path.insert(
        0,
        str(ROOT),
    )


from backend.app.sources.knowafest_discovery import (
    KnowAFestDiscovery,
)


discovery = KnowAFestDiscovery()


urls = discovery.discover(
    limit=15
)


print("=" * 70)
print("KNOWAFEST EVENT DISCOVERY")
print("=" * 70)

print(
    f"\nEvents discovered: "
    f"{len(urls)}"
)

print()


for index, url in enumerate(
    urls,
    start=1,
):

    print(
        f"{index:>2}. {url}"
    )