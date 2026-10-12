from pathlib import Path

import pandas as pd

from backend.app.intelligence.skill_normalizer import (
    SkillNormalizer,
)


ROOT = Path(__file__).resolve().parents[2]

MASTER_FILE = (
    ROOT
    / "data"
    / "derived"
    / "campuspilot_master_skills_final.csv"
)


class EventSkillFilter:

    # ============================================================
    # READINESS SOFT SKILLS
    # ============================================================

    READINESS_SOFT_SKILLS = {
        "problem solving",
        "teamwork",
        "communication",
        "leadership",
        "project management",
    }

    def __init__(self):

        df = pd.read_csv(
            MASTER_FILE
        )

        self.metadata = {}

        for _, row in df.iterrows():

            skill = (
                str(
                    row["skill"]
                )
                .strip()
                .lower()
            )

            if not skill:
                continue

            sources = {
                item.strip().lower()
                for item in str(
                    row.get(
                        "sources",
                        "",
                    )
                ).split("|")
                if item.strip()
                and item.strip().lower()
                != "nan"
            }

            self.metadata[
                skill
            ] = {

                "sources":
                    sources,

                "source_count":
                    self.safe_int(
                        row.get(
                            "source_count",
                            0,
                        )
                    ),

                "technical_frequency":
                    self.safe_float(
                        row.get(
                            "technical_frequency",
                            0,
                        )
                    ),

                "stackoverflow_frequency":
                    self.safe_float(
                        row.get(
                            "stackoverflow_frequency",
                            0,
                        )
                    ),
            }

    # ============================================================
    # SAFE NUMBER HELPERS
    # ============================================================

    def safe_float(
        self,
        value,
    ) -> float:

        if pd.isna(
            value
        ):
            return 0.0

        try:

            return float(
                value
            )

        except (
            TypeError,
            ValueError,
        ):

            return 0.0

    def safe_int(
        self,
        value,
    ) -> int:

        return int(
            self.safe_float(
                value
            )
        )

    # ============================================================
    # HIGH CONFIDENCE CHECK
    # ============================================================

    def is_high_confidence(
        self,
        skill: str,
    ) -> bool:

        skill = (
            SkillNormalizer.normalize(
                skill
            )
        )

        if not skill:
            return False

        skill = (
            skill.strip()
            .lower()
        )

        # --------------------------------------------------------
        # IMPORTANT SOFT SKILLS
        # --------------------------------------------------------

        if (
            skill
            in self.READINESS_SOFT_SKILLS
        ):
            return True

        info = (
            self.metadata.get(
                skill
            )
        )

        if not info:
            return False

        sources = (
            info[
                "sources"
            ]
        )

        # --------------------------------------------------------
        # CAMPUSPILOT CURATED CORE
        # --------------------------------------------------------

        if (
            "campuspilot_core"
            in sources
        ):
            return True

        # --------------------------------------------------------
        # STACK OVERFLOW TECHNOLOGY
        # --------------------------------------------------------

        if (
            info[
                "stackoverflow_frequency"
            ]
            > 0
        ):
            return True

        # --------------------------------------------------------
        # TECHNICAL ROLE EVIDENCE
        #
        # One isolated technical-role mention is too weak.
        # Require at least two occurrences.
        # --------------------------------------------------------

        if (
            info[
                "technical_frequency"
            ]
            >= 2
        ):
            return True

        return False

    # ============================================================
    # FILTER SKILLS
    # ============================================================

    def filter(
        self,
        skills: list[str],
    ) -> list[str]:

        result = []

        seen = set()

        for skill in skills:

            canonical = (
                SkillNormalizer.normalize(
                    skill
                )
            )

            if not canonical:
                continue

            canonical = (
                canonical.strip()
                .lower()
            )

            if not self.is_high_confidence(
                canonical
            ):
                continue

            if canonical in seen:
                continue

            seen.add(
                canonical
            )

            result.append(
                canonical
            )

        return result