from pathlib import Path
from datetime import datetime, timezone
import json
import shutil
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
from backend.app.sources.knowafest_source import (
    KnowAFestSource,
)
from backend.app.sources.official_event_source import (
    OfficialEventSource,
)


OUTPUT_FILE = (
    ROOT
    / "backend"
    / "data"
    / "derived"
    / "campuspilot_upcoming_events.json"
)

BACKUP_FILE = (
    ROOT
    / "backend"
    / "data"
    / "derived"
    / "campuspilot_upcoming_events.backup.json"
)

TEMP_FILE = (
    ROOT
    / "backend"
    / "data"
    / "derived"
    / "campuspilot_upcoming_events.tmp.json"
)


# ============================================================
# DATETIME HELPERS
# ============================================================

def parse_datetime(
    value,
):

    if not value:
        return None

    try:

        return datetime.fromisoformat(
            str(
                value
            ).replace(
                "Z",
                "+00:00",
            )
        )

    except (
        ValueError,
        TypeError,
    ):

        return None


def ensure_timezone(
    value,
):

    if value is None:
        return None

    if value.tzinfo is None:

        return value.replace(
            tzinfo=timezone.utc
        )

    return value


# ============================================================
# UPCOMING CHECK - OPPORTUNITY OBJECT
# ============================================================

def is_active_or_upcoming(
    event,
) -> bool:

    now = datetime.now(
        timezone.utc
    )

    end_date = ensure_timezone(
        parse_datetime(
            event.end_date
        )
    )

    start_date = ensure_timezone(
        parse_datetime(
            event.start_date
        )
    )

    if end_date:

        return (
            end_date >= now
        )

    if start_date:

        return (
            start_date >= now
        )

    # Keep unknown-date events rather than
    # accidentally deleting them.
    return True


# ============================================================
# UPCOMING CHECK - CACHED DICT
# ============================================================

def is_cached_event_active(
    event: dict,
) -> bool:

    now = datetime.now(
        timezone.utc
    )

    end_date = ensure_timezone(
        parse_datetime(
            event.get(
                "end_date"
            )
        )
    )

    start_date = ensure_timezone(
        parse_datetime(
            event.get(
                "start_date"
            )
        )
    )

    if end_date:

        return (
            end_date >= now
        )

    if start_date:

        return (
            start_date >= now
        )

    return True


# ============================================================
# LOAD EXISTING CACHE
# ============================================================

def load_existing_cache():

    if not OUTPUT_FILE.exists():

        return {
            "events": [],
            "failed": [],
        }

    try:

        with open(
            OUTPUT_FILE,
            "r",
            encoding="utf-8",
        ) as file:

            data = json.load(
                file
            )

        if not isinstance(
            data,
            dict,
        ):

            return {
                "events": [],
                "failed": [],
            }

        return data

    except (
        json.JSONDecodeError,
        OSError,
    ) as exc:

        print(
            "WARNING: Existing cache "
            f"could not be read: {exc}"
        )

        return {
            "events": [],
            "failed": [],
        }


# ============================================================
# SAFE SAVE
# ============================================================

def safe_save(
    payload,
):

    OUTPUT_FILE.parent.mkdir(
        parents=True,
        exist_ok=True,
    )

    existing_events = []

    if OUTPUT_FILE.exists():

        try:

            with open(
                OUTPUT_FILE,
                "r",
                encoding="utf-8",
            ) as file:

                existing_data = json.load(
                    file
                )

            existing_events = (
                existing_data.get(
                    "events",
                    [],
                )
            )

        except Exception:

            existing_events = []

    # Only create/replace backup when
    # the current cache actually contains data.
    if (
        OUTPUT_FILE.exists()
        and existing_events
    ):

        shutil.copy2(
            OUTPUT_FILE,
            BACKUP_FILE,
        )

    with open(
        TEMP_FILE,
        "w",
        encoding="utf-8",
    ) as file:

        json.dump(
            payload,
            file,
            indent=2,
            ensure_ascii=False,
        )

    TEMP_FILE.replace(
        OUTPUT_FILE
    )


# ============================================================
# START
# ============================================================

print("=" * 75)
print(
    "CAMPUSPILOT UPCOMING EVENT INGESTION"
)
print("=" * 75)


existing_data = (
    load_existing_cache()
)

cached_events = (
    existing_data.get(
        "events",
        [],
    )
)

cached_active_events = [
    event
    for event in cached_events
    if is_cached_event_active(
        event
    )
]


print(
    f"\nExisting cached events: "
    f"{len(cached_events)}"
)

print(
    f"Still active cached events: "
    f"{len(cached_active_events)}"
)


# ============================================================
# SOURCES
# ============================================================

discovery = (
    KnowAFestDiscovery()
)

knowafest = (
    KnowAFestSource()
)

official = (
    OfficialEventSource()
)


# ============================================================
# DISCOVERY
# ============================================================

try:

    urls = discovery.discover(
        limit=30
    )

except Exception as exc:

    print()
    print(
        "Discovery failed:"
    )

    print(
        exc
    )

    urls = []


print(
    f"\nDiscovered URLs: "
    f"{len(urls)}"
)


# ============================================================
# CRITICAL FAIL-SAFE
# ============================================================

if not urls:

    print()
    print("=" * 75)
    print(
        "DISCOVERY UNAVAILABLE"
    )
    print("=" * 75)

    if cached_events:

        print(
            "Keeping existing cached "
            f"events: {len(cached_events)}"
        )

        print(
            "No data overwritten."
        )

    else:

        print(
            "No valid cached events are "
            "currently available."
        )

        print(
            "Output file will NOT be "
            "overwritten again."
        )

    sys.exit(
        0
    )


# ============================================================
# FETCH EVENTS
# ============================================================

events = []

failed = []

successful_source_urls = set()


for index, url in enumerate(
    urls,
    start=1,
):

    print()

    print(
        f"[{index}/{len(urls)}] "
        f"{url}"
    )

    try:

        event = (
            knowafest.fetch_event(
                url
            )
        )

        print(
            f"  Parsed: "
            f"{event.title}"
        )

        # ----------------------------------------------------
        # FILTER EXPIRED
        # ----------------------------------------------------

        if not is_active_or_upcoming(
            event
        ):

            print(
                "  SKIPPED: expired"
            )

            successful_source_urls.add(
                url
            )

            continue

        # ----------------------------------------------------
        # OFFICIAL VERIFICATION
        # ----------------------------------------------------

        if event.official_url:

            try:

                event = (
                    official.enrich(
                        event
                    )
                )

                print(
                    "  Official verification: "
                    f"{event.verified}"
                )

            except Exception as exc:

                print(
                    "  Official site failed: "
                    f"{exc}"
                )

        else:

            print(
                "  Official URL: "
                "not found"
            )

        events.append(
            event.to_dict()
        )

        successful_source_urls.add(
            url
        )

    except Exception as exc:

        print(
            f"  FAILED: {exc}"
        )

        failed.append(
            {
                "url":
                    url,

                "error":
                    str(exc),
            }
        )


# ============================================================
# SECOND FAIL-SAFE
# ============================================================

if not events:

    print()
    print("=" * 75)
    print(
        "NO EVENTS SUCCESSFULLY INGESTED"
    )
    print("=" * 75)

    if cached_events:

        print(
            "Keeping existing cached "
            f"events: {len(cached_events)}"
        )

        print(
            "No data overwritten."
        )

    else:

        print(
            "No previous valid cache "
            "is available."
        )

        print(
            "No empty dataset will "
            "be written."
        )

    sys.exit(
        0
    )


# ============================================================
# PRESERVE CACHED EVENTS WHOSE FETCH FAILED
# ============================================================

preserved_cached = []


for cached_event in cached_active_events:

    cached_source_url = str(
        cached_event.get(
            "source_url",
            "",
        )
    ).strip()

    if not cached_source_url:
        continue

    # If this URL was successfully processed,
    # prefer the new version.
    if (
        cached_source_url
        in successful_source_urls
    ):
        continue

    preserved_cached.append(
        cached_event
    )


if preserved_cached:

    print()
    print(
        "Preserving cached events "
        "whose refresh failed: "
        f"{len(preserved_cached)}"
    )

    events.extend(
        preserved_cached
    )


# ============================================================
# REMOVE DUPLICATES
# ============================================================

unique_events = {}


for event in events:

    event_id = event.get(
        "id"
    )

    if not event_id:
        continue

    # Later/newer item wins.
    unique_events[
        event_id
    ] = event


events = list(
    unique_events.values()
)


# ============================================================
# FINAL ACTIVE FILTER
# ============================================================

events = [
    event
    for event in events
    if is_cached_event_active(
        event
    )
]


# ============================================================
# SORT
# ============================================================

events.sort(
    key=lambda event:
        event.get(
            "start_date"
        )
        or "9999-12-31"
)


# ============================================================
# FINAL SAFETY CHECK
# ============================================================

if not events:

    print()
    print("=" * 75)
    print(
        "FINAL DATASET EMPTY"
    )
    print("=" * 75)

    print(
        "Existing cache was NOT "
        "overwritten."
    )

    sys.exit(
        0
    )


# ============================================================
# PAYLOAD
# ============================================================

payload = {

    "generated_at":
        datetime.now(
            timezone.utc
        ).isoformat(),

    "event_count":
        len(events),

    "failed_count":
        len(failed),

    "events":
        events,

    "failed":
        failed,
}


# ============================================================
# SAVE
# ============================================================

safe_save(
    payload
)


# ============================================================
# RESULT
# ============================================================

verified_count = sum(
    1
    for event in events
    if event.get(
        "verified"
    )
)


print()
print("=" * 75)
print(
    "INGESTION COMPLETE"
)
print("=" * 75)

print(
    f"Upcoming events: "
    f"{len(events)}"
)

print(
    f"Failed: "
    f"{len(failed)}"
)

print(
    f"Verified: "
    f"{verified_count}"
)

print(
    f"Preserved cached: "
    f"{len(preserved_cached)}"
)

print()

print(
    "Saved:"
)

print(
    OUTPUT_FILE
)

if BACKUP_FILE.exists():

    print()

    print(
        "Backup:"
    )

    print(
        BACKUP_FILE
    )