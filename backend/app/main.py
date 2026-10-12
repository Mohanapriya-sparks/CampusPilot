from pathlib import Path
import json

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field

from backend.app.intelligence.recommender import (
    EventRecommender,
)


# ============================================================
# PATHS
# ============================================================

ROOT = Path(__file__).resolve().parents[2]

EVENTS_FILE = (
    ROOT
    / "backend"
    / "data"
    / "derived"
    / "campuspilot_upcoming_events.json"
)


# ============================================================
# FASTAPI APP
# ============================================================

app = FastAPI(
    title="CampusPilot API",
    description=(
        "Opportunity discovery, readiness, "
        "and recommendation API for CampusPilot."
    ),
    version="1.0.0",
)


# ============================================================
# CORS
# ============================================================

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ============================================================
# RECOMMENDER
# ============================================================

recommender = EventRecommender()


# ============================================================
# REQUEST MODEL
# ============================================================

class RecommendationRequest(BaseModel):

    skills: list[str] = Field(
        default_factory=list
    )

    interests: list[str] = Field(
        default_factory=list
    )

    preferred_event_types: list[str] = Field(
        default_factory=list
    )

    preferred_mode: str = ""

    preferred_location: str = ""

    limit: int = Field(
        default=10,
        ge=1,
        le=100,
    )


# ============================================================
# DATA LOADER
# ============================================================

def load_opportunities() -> list[dict]:

    if not EVENTS_FILE.exists():

        raise HTTPException(
            status_code=503,
            detail=(
                "Opportunity dataset "
                "is not available."
            ),
        )

    try:

        with open(
            EVENTS_FILE,
            "r",
            encoding="utf-8",
        ) as file:

            data = json.load(file)

    except json.JSONDecodeError:

        raise HTTPException(
            status_code=500,
            detail=(
                "Opportunity dataset "
                "contains invalid JSON."
            ),
        )

    except OSError as exc:

        raise HTTPException(
            status_code=500,
            detail=(
                "Could not read opportunity data: "
                f"{exc}"
            ),
        )

    events = data.get(
        "events",
        [],
    )

    if not isinstance(
        events,
        list,
    ):

        raise HTTPException(
            status_code=500,
            detail=(
                "Opportunity dataset "
                "has an invalid structure."
            ),
        )

    return events


# ============================================================
# ROOT
# ============================================================

@app.get("/")
def root():

    return {
        "service": "CampusPilot API",
        "status": "running",
        "version": "1.0.0",
    }


# ============================================================
# HEALTH
# ============================================================

@app.get("/api/health")
def health():

    events = load_opportunities()

    verified_count = sum(
        1
        for event in events
        if event.get("verified")
    )

    return {
        "status": "ok",
        "opportunities": len(events),
        "verified": verified_count,
    }


# ============================================================
# ALL OPPORTUNITIES
# ============================================================

@app.get("/api/opportunities")
def get_opportunities():

    events = load_opportunities()

    return {
        "count": len(events),
        "opportunities": events,
    }


# ============================================================
# ONE OPPORTUNITY
# ============================================================

@app.get(
    "/api/opportunities/{opportunity_id}"
)
def get_opportunity(
    opportunity_id: str,
):

    events = load_opportunities()

    for event in events:

        if (
            event.get("id")
            == opportunity_id
        ):

            return event

    raise HTTPException(
        status_code=404,
        detail="Opportunity not found.",
    )


# ============================================================
# RECOMMENDATIONS
# ============================================================

@app.post("/api/recommendations")
def get_recommendations(
    request: RecommendationRequest,
):

    events = load_opportunities()

    # --------------------------------------------------------
    # BUILD PROFILE
    # --------------------------------------------------------

    profile = {
        "skills":
            request.skills,

        "interests":
            request.interests,

        "preferred_event_types":
            request.preferred_event_types,

        "preferred_mode":
            request.preferred_mode,

        "preferred_location":
            request.preferred_location,
    }

    # --------------------------------------------------------
    # SCORE + RANK
    # --------------------------------------------------------

    ranked = recommender.rank_events(
        profile,
        events,
    )

    # --------------------------------------------------------
    # EVENT LOOKUP
    # --------------------------------------------------------

    event_lookup = {
        event.get("id"): event
        for event in events
        if event.get("id")
    }

    recommendations = []

    # --------------------------------------------------------
    # MERGE EVENT DATA + INTELLIGENCE
    # --------------------------------------------------------

    for score in ranked:

        event_id = score.get(
            "event_id"
        )

        event = event_lookup.get(
            event_id
        )

        if not event:
            continue

        result = dict(event)

        result.update(
            {
                "event_fit":
                    score.get(
                        "event_fit",
                        0,
                    ),

                "fit_coverage":
                    score.get(
                        "fit_coverage",
                        0,
                    ),

                "readiness":
                    score.get(
                        "readiness"
                    ),

                "readiness_available":
                    score.get(
                        "readiness_available",
                        False,
                    ),

                "fit_components":
                    score.get(
                        "components",
                        {},
                    ),

                "strong_skills":
                    score.get(
                        "strong_skills",
                        [],
                    ),

                "partial_skills":
                    score.get(
                        "partial_skills",
                        [],
                    ),

                "missing_skills":
                    score.get(
                        "missing_skills",
                        [],
                    ),
            }
        )

        recommendations.append(
            result
        )

    recommendations = (
        recommendations[
            :request.limit
        ]
    )

    return {
        "profile":
            profile,

        "total_opportunities":
            len(events),

        "count":
            len(recommendations),

        "recommendations":
            recommendations,
    }