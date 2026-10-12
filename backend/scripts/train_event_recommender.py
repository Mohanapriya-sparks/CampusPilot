from pathlib import Path

import joblib
import pandas as pd

from sklearn.compose import ColumnTransformer
from sklearn.impute import SimpleImputer
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import (
    accuracy_score,
    classification_report,
    confusion_matrix,
    roc_auc_score,
)
from sklearn.model_selection import train_test_split
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import OneHotEncoder, StandardScaler


# ------------------------------------------------------------
# PATHS
# ------------------------------------------------------------

ROOT = Path(__file__).resolve().parents[1]

DATA_DIR = ROOT / "data" / "kaggle_event_recommendation"
MODEL_DIR = ROOT / "models"

MODEL_DIR.mkdir(
    parents=True,
    exist_ok=True,
)

TRAIN_FILE = DATA_DIR / "train.csv"
USERS_FILE = DATA_DIR / "users.csv"
EVENTS_FILE = DATA_DIR / "train_events_subset.csv.gz"

MODEL_FILE = MODEL_DIR / "event_recommender.joblib"


# ------------------------------------------------------------
# LOAD DATA
# ------------------------------------------------------------

print("Loading datasets...")

train = pd.read_csv(TRAIN_FILE)

users = pd.read_csv(
    USERS_FILE,
)

events = pd.read_csv(
    EVENTS_FILE,
    compression="gzip",
)

print(f"Interactions: {len(train):,}")
print(f"Users:        {len(users):,}")
print(f"Events:       {len(events):,}")


# ------------------------------------------------------------
# KEEP EXPLICIT FEEDBACK ONLY
#
# interested = 1       → positive
# not_interested = 1   → negative
#
# Rows containing 0,0 mean the user gave no explicit opinion,
# so they should NOT automatically become negative examples.
# ------------------------------------------------------------

explicit = train[
    (train["interested"] == 1)
    | (train["not_interested"] == 1)
].copy()

explicit["target"] = (
    explicit["interested"] == 1
).astype(int)

print()
print("Explicit feedback:")
print(explicit["target"].value_counts())

print(
    f"\nUsable labelled interactions: "
    f"{len(explicit):,}"
)


# ------------------------------------------------------------
# MERGE USER FEATURES
# ------------------------------------------------------------

data = explicit.merge(
    users,
    left_on="user",
    right_on="user_id",
    how="left",
)


# ------------------------------------------------------------
# MERGE EVENT FEATURES
# ------------------------------------------------------------

data = data.merge(
    events,
    left_on="event",
    right_on="event_id",
    how="left",
    suffixes=("_user", "_event"),
)

print(
    f"Merged training rows: "
    f"{len(data):,}"
)


# ------------------------------------------------------------
# FEATURES
#
# We intentionally DO NOT use raw user_id/event_id because
# CampusPilot must learn patterns rather than memorize IDs.
# ------------------------------------------------------------

event_features = [
    column
    for column in events.columns
    if column.startswith("c_")
]

numeric_features = [
    "invited",
    "timezone",
    *event_features,
]

categorical_features = [
    "locale",
    "gender",
    "country",
]


# ------------------------------------------------------------
# CLEAN MISSING COLUMNS
# ------------------------------------------------------------

numeric_features = [
    column
    for column in numeric_features
    if column in data.columns
]

categorical_features = [
    column
    for column in categorical_features
    if column in data.columns
]


X = data[
    numeric_features
    + categorical_features
]

y = data["target"]


# ------------------------------------------------------------
# PREPROCESSING
# ------------------------------------------------------------

numeric_pipeline = Pipeline(
    steps=[
        (
            "imputer",
            SimpleImputer(
                strategy="median",
            ),
        ),
        (
            "scaler",
            StandardScaler(),
        ),
    ]
)


categorical_pipeline = Pipeline(
    steps=[
        (
            "imputer",
            SimpleImputer(
                strategy="most_frequent",
            ),
        ),
        (
            "onehot",
            OneHotEncoder(
                handle_unknown="ignore",
            ),
        ),
    ]
)


preprocessor = ColumnTransformer(
    transformers=[
        (
            "numeric",
            numeric_pipeline,
            numeric_features,
        ),
        (
            "categorical",
            categorical_pipeline,
            categorical_features,
        ),
    ]
)


# ------------------------------------------------------------
# MODEL
#
# class_weight="balanced" matters because there are many more
# interested examples than explicit not-interested examples.
# ------------------------------------------------------------

model = LogisticRegression(
    max_iter=2000,
    class_weight="balanced",
)


pipeline = Pipeline(
    steps=[
        (
            "preprocessor",
            preprocessor,
        ),
        (
            "model",
            model,
        ),
    ]
)


# ------------------------------------------------------------
# TRAIN / TEST SPLIT
# ------------------------------------------------------------

X_train, X_test, y_train, y_test = (
    train_test_split(
        X,
        y,
        test_size=0.20,
        random_state=42,
        stratify=y,
    )
)

print()
print(
    f"Training rows: "
    f"{len(X_train):,}"
)

print(
    f"Testing rows:  "
    f"{len(X_test):,}"
)


# ------------------------------------------------------------
# TRAIN
# ------------------------------------------------------------

print("\nTraining recommender...")

pipeline.fit(
    X_train,
    y_train,
)

print("Training complete.")


# ------------------------------------------------------------
# EVALUATE
# ------------------------------------------------------------

predictions = pipeline.predict(
    X_test,
)

probabilities = (
    pipeline.predict_proba(
        X_test,
    )[:, 1]
)


accuracy = accuracy_score(
    y_test,
    predictions,
)

roc_auc = roc_auc_score(
    y_test,
    probabilities,
)


print()
print("=" * 60)
print("CAMPUSPILOT RECOMMENDER BASELINE")
print("=" * 60)

print(
    f"\nAccuracy: "
    f"{accuracy:.4f}"
)

print(
    f"ROC-AUC:  "
    f"{roc_auc:.4f}"
)


print(
    "\nClassification Report:"
)

print(
    classification_report(
        y_test,
        predictions,
        digits=4,
    )
)


print(
    "Confusion Matrix:"
)

print(
    confusion_matrix(
        y_test,
        predictions,
    )
)


# ------------------------------------------------------------
# SAVE MODEL
# ------------------------------------------------------------

joblib.dump(
    {
        "pipeline": pipeline,
        "numeric_features":
            numeric_features,
        "categorical_features":
            categorical_features,
    },
    MODEL_FILE,
)


print()
print(
    f"Model saved to:"
)

print(MODEL_FILE)


print(
    "\nBaseline recommendation model "
    "created successfully."
)