from pathlib import Path
import pandas as pd


# ------------------------------------------------------------
# PATHS
# ------------------------------------------------------------

ROOT = Path(__file__).resolve().parents[1]

DATA_DIR = ROOT / "data" / "kaggle_event_recommendation"

TRAIN_FILE = DATA_DIR / "train.csv"
USERS_FILE = DATA_DIR / "users.csv"
EVENTS_FILE = DATA_DIR / "events.csv.gz"


# ------------------------------------------------------------
# HELPERS
# ------------------------------------------------------------

def heading(title: str):
    print()
    print("=" * 70)
    print(title)
    print("=" * 70)


def inspect_small_csv(name: str, path: Path):
    heading(name)

    df = pd.read_csv(path)

    print(f"File: {path.name}")
    print(f"Rows: {len(df):,}")
    print(f"Columns: {len(df.columns)}")

    print("\nCOLUMN NAMES:")
    for column in df.columns:
        print(f" - {column}")

    print("\nFIRST 5 ROWS:")
    print(df.head().to_string())

    print("\nMISSING VALUES:")
    missing = df.isnull().sum()
    missing = missing[missing > 0]

    if missing.empty:
        print("No missing values.")
    else:
        print(missing.to_string())

    return df


# ------------------------------------------------------------
# TRAIN DATA
# ------------------------------------------------------------

train = inspect_small_csv(
    "TRAIN.CSV — USER ↔ EVENT INTERACTIONS",
    TRAIN_FILE,
)

heading("TRAIN INTERACTION SUMMARY")

if "interested" in train.columns:
    print(
        f"Interested = 1: "
        f"{int(train['interested'].sum()):,}"
    )

if "not_interested" in train.columns:
    print(
        f"Not Interested = 1: "
        f"{int(train['not_interested'].sum()):,}"
    )

if "user" in train.columns:
    print(
        f"Unique users: "
        f"{train['user'].nunique():,}"
    )

if "event" in train.columns:
    print(
        f"Unique events: "
        f"{train['event'].nunique():,}"
    )


# ------------------------------------------------------------
# USER DATA
# ------------------------------------------------------------

users = inspect_small_csv(
    "USERS.CSV — USER FEATURES",
    USERS_FILE,
)

heading("USER SUMMARY")

if "user_id" in users.columns:
    print(
        f"Unique users: "
        f"{users['user_id'].nunique():,}"
    )

if "locale" in users.columns:
    print("\nTop locales:")
    print(
        users["locale"]
        .value_counts()
        .head(10)
        .to_string()
    )

if "location" in users.columns:
    print("\nTop known locations:")
    print(
        users["location"]
        .dropna()
        .value_counts()
        .head(10)
        .to_string()
    )


# ------------------------------------------------------------
# EVENTS DATA
#
# Read it in chunks so the 169 MB gzip file is NOT loaded
# completely into RAM.
# ------------------------------------------------------------

heading("EVENTS.CSV.GZ — EVENT FEATURES")

chunk_size = 50_000

total_rows = 0
event_columns = None
first_event_rows = None

city_counts = {}
country_counts = {}

for index, chunk in enumerate(
    pd.read_csv(
        EVENTS_FILE,
        compression="gzip",
        chunksize=chunk_size,
    )
):
    if event_columns is None:
        event_columns = list(chunk.columns)
        first_event_rows = chunk.head(5).copy()

    total_rows += len(chunk)

    if "city" in chunk.columns:
        values = (
            chunk["city"]
            .dropna()
            .astype(str)
            .value_counts()
        )

        for key, value in values.items():
            city_counts[key] = (
                city_counts.get(key, 0)
                + int(value)
            )

    if "country" in chunk.columns:
        values = (
            chunk["country"]
            .dropna()
            .astype(str)
            .value_counts()
        )

        for key, value in values.items():
            country_counts[key] = (
                country_counts.get(key, 0)
                + int(value)
            )

    print(
        f"Processed event rows: "
        f"{total_rows:,}",
        end="\r",
    )


print()

print(f"\nTotal event rows: {total_rows:,}")
print(
    f"Total event columns: "
    f"{len(event_columns or [])}"
)

print("\nEVENT COLUMN NAMES:")

for column in event_columns or []:
    print(f" - {column}")


if first_event_rows is not None:
    print("\nFIRST 5 EVENT ROWS:")
    print(
        first_event_rows.to_string()
    )


if country_counts:
    heading("TOP EVENT COUNTRIES")

    top_countries = sorted(
        country_counts.items(),
        key=lambda item: item[1],
        reverse=True,
    )[:15]

    for country, count in top_countries:
        print(
            f"{country}: {count:,}"
        )


if city_counts:
    heading("TOP EVENT CITIES")

    top_cities = sorted(
        city_counts.items(),
        key=lambda item: item[1],
        reverse=True,
    )[:15]

    for city, count in top_cities:
        print(
            f"{city}: {count:,}"
        )


# ------------------------------------------------------------
# CAMPUSPILOT RELEVANCE
# ------------------------------------------------------------

heading("CAMPUSPILOT DATASET CHECK")

print(
    """
train.csv
---------
Useful for:
✓ learning user-event recommendation behaviour
✓ interested vs not-interested labels
✓ collaborative recommendation experiments

users.csv
---------
Useful for:
✓ learning how user-side features are represented
✓ location / locale based recommendation ideas

events.csv.gz
-------------
Useful for:
✓ learning event-side feature representation
✓ content-based recommendation experiments
✓ combining user and event features

Important:
This Kaggle dataset will NOT be used as CampusPilot's
live event database.

CampusPilot live events will later come from:
- KnowAFest
- official event websites
- other verified event sources

The Kaggle data is for recommendation research/training.
"""
)

print("Dataset inspection completed successfully.")