from pathlib import Path
import pandas as pd


ROOT = Path(__file__).resolve().parents[1]

DATA_DIR = ROOT / "data" / "kaggle_event_recommendation"

TRAIN_FILE = DATA_DIR / "train.csv"
EVENTS_FILE = DATA_DIR / "events.csv.gz"

OUTPUT_FILE = DATA_DIR / "train_events_subset.csv.gz"


print("Loading train.csv...")

train = pd.read_csv(TRAIN_FILE)

target_event_ids = set(
    train["event"].astype("int64").unique()
)

print(
    f"Unique events required: "
    f"{len(target_event_ids):,}"
)

print("\nScanning events.csv.gz...")

matched_chunks = []

processed = 0

for chunk in pd.read_csv(
    EVENTS_FILE,
    compression="gzip",
    chunksize=50_000,
):
    processed += len(chunk)

    matches = chunk[
        chunk["event_id"].isin(
            target_event_ids
        )
    ]

    if not matches.empty:
        matched_chunks.append(matches)

    print(
        f"Processed: {processed:,} | "
        f"Matched so far: "
        f"{sum(len(x) for x in matched_chunks):,}",
        end="\r",
    )


print("\n")

if not matched_chunks:
    raise RuntimeError(
        "No matching events were found."
    )

events_subset = pd.concat(
    matched_chunks,
    ignore_index=True,
)

events_subset = (
    events_subset
    .drop_duplicates(
        subset=["event_id"]
    )
    .reset_index(drop=True)
)


print(
    f"Final matched events: "
    f"{len(events_subset):,}"
)


missing_ids = (
    target_event_ids
    - set(events_subset["event_id"])
)

print(
    f"Training event IDs missing "
    f"from events.csv.gz: "
    f"{len(missing_ids):,}"
)


events_subset.to_csv(
    OUTPUT_FILE,
    index=False,
    compression="gzip",
)


print(
    "\nSaved:"
)

print(OUTPUT_FILE)

print(
    "\nTraining subset created successfully."
)