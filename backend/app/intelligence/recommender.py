from backend.app.intelligence.semantic_matcher import (
    SemanticMatcher,
)


class EventRecommender:

    def __init__(self):

        self.matcher = (
            SemanticMatcher()
        )

        self.weights = {
            "skills": 0.40,
            "interests": 0.25,
            "event_type": 0.15,
            "mode": 0.10,
            "location": 0.10,
        }

        # Unknown event metadata should not count
        # as either a perfect match or a mismatch.
        self.neutral_score = 0.50

    # ============================================================
    # TEXT NORMALIZATION
    # ============================================================

    def normalize_text(
        self,
        value,
    ):

        return (
            str(
                value or ""
            )
            .strip()
            .lower()
        )

    # ============================================================
    # LIST MATCH
    # ============================================================

    def list_match_score(
        self,
        student_values,
        event_values,
    ):

        student = {
            self.normalize_text(
                value
            )
            for value in (
                student_values or []
            )
            if value
        }

        event = {
            self.normalize_text(
                value
            )
            for value in (
                event_values or []
            )
            if value
        }

        # Event does not provide this information.
        if not event:
            return None

        if not student:
            return 0.0

        matches = (
            student.intersection(
                event
            )
        )

        return (
            len(matches)
            / len(event)
        )

    # ============================================================
    # SINGLE VALUE MATCH
    # ============================================================

    def single_match_score(
        self,
        preferred,
        actual,
    ):

        preferred = (
            self.normalize_text(
                preferred
            )
        )

        actual = (
            self.normalize_text(
                actual
            )
        )

        # Event metadata unavailable.
        if not actual:
            return None

        if not preferred:
            return 1.0

        if preferred in {
            "any",
            "all",
            "no preference",
        }:
            return 1.0

        if preferred == actual:
            return 1.0

        return 0.0

    # ============================================================
    # LOCATION
    # ============================================================

    def location_score(
        self,
        preferred_location,
        event_location,
        event_mode,
    ):

        mode = (
            self.normalize_text(
                event_mode
            )
        )

        # Location is not applicable to
        # fully online events.
        if mode in {
            "online",
            "virtual",
            "remote",
        }:
            return None

        preferred = (
            self.normalize_text(
                preferred_location
            )
        )

        actual = (
            self.normalize_text(
                event_location
            )
        )

        if not actual:
            return None

        if not preferred:
            return 1.0

        if preferred in actual:
            return 1.0

        return 0.0

    # ============================================================
    # DISPLAY SCORE
    # ============================================================

    def display_score(
        self,
        score,
    ):

        if score is None:
            return None

        return round(
            score * 100,
            1,
        )

    # ============================================================
    # SCORE ONE EVENT
    # ============================================================

    def score_event(
        self,
        profile: dict,
        event: dict,
    ) -> dict:

        # ========================================================
        # SKILL READINESS
        # ========================================================

        required_skills = (
            event.get(
                "required_skills",
                [],
            )
            or []
        )

        if required_skills:

            skill_result = (
                self.matcher.match_event(
                    profile.get(
                        "skills",
                        [],
                    ),
                    required_skills,
                )
            )

            skill_score = (
                skill_result[
                    "readiness"
                ]
                / 100
            )

            readiness = (
                skill_result[
                    "readiness"
                ]
            )

        else:

            # No reliable skill requirements available.
            skill_score = None

            readiness = None

            skill_result = {
                "strong": [],
                "partial": [],
                "missing": [],
            }

        # ========================================================
        # INTEREST MATCH
        # ========================================================

        interest_score = (
            self.list_match_score(
                profile.get(
                    "interests",
                    [],
                ),
                event.get(
                    "interests",
                    [],
                ),
            )
        )

        # ========================================================
        # EVENT TYPE
        # ========================================================

        preferred_types = [
            self.normalize_text(
                value
            )
            for value in profile.get(
                "preferred_event_types",
                [],
            )
            if value
        ]

        event_type = (
            self.normalize_text(
                event.get(
                    "event_type",
                    "",
                )
            )
        )

        if not event_type:

            event_type_score = None

        elif not preferred_types:

            event_type_score = 1.0

        elif (
            event_type
            in preferred_types
        ):

            event_type_score = 1.0

        else:

            event_type_score = 0.0

        # ========================================================
        # MODE
        # ========================================================

        mode_score = (
            self.single_match_score(
                profile.get(
                    "preferred_mode",
                    "",
                ),
                event.get(
                    "mode",
                    "",
                ),
            )
        )

        # ========================================================
        # LOCATION
        # ========================================================

        location_score = (
            self.location_score(
                profile.get(
                    "preferred_location",
                    "",
                ),
                event.get(
                    "location",
                    "",
                ),
                event.get(
                    "mode",
                    "",
                ),
            )
        )

        # ========================================================
        # COMPONENTS
        # ========================================================

        components = {
            "skills":
                skill_score,

            "interests":
                interest_score,

            "event_type":
                event_type_score,

            "mode":
                mode_score,

            "location":
                location_score,
        }

        # ========================================================
        # EVENT FIT
        #
        # Missing metadata gets a neutral 50% contribution.
        # It no longer behaves like a perfect match.
        # ========================================================

        weighted_total = 0.0

        available_weight = 0.0

        for (
            component,
            weight,
        ) in self.weights.items():

            score = components[
                component
            ]

            if score is None:

                weighted_total += (
                    self.neutral_score
                    * weight
                )

            else:

                weighted_total += (
                    score
                    * weight
                )

                available_weight += (
                    weight
                )

        overall_fit = (
            weighted_total
            * 100
        )

        fit_coverage = (
            available_weight
            * 100
        )

        # ========================================================
        # RESULT
        # ========================================================

        return {

            "event_id":
                event.get(
                    "id"
                ),

            "title":
                event.get(
                    "title"
                ),

            "event_fit":
                round(
                    overall_fit,
                    1,
                ),

            "fit_coverage":
                round(
                    fit_coverage,
                    1,
                ),

            "readiness":
                readiness,

            "readiness_available":
                bool(
                    required_skills
                ),

            "components": {

                "skill_fit":
                    self.display_score(
                        skill_score
                    ),

                "interest_fit":
                    self.display_score(
                        interest_score
                    ),

                "event_type_fit":
                    self.display_score(
                        event_type_score
                    ),

                "mode_fit":
                    self.display_score(
                        mode_score
                    ),

                "location_fit":
                    self.display_score(
                        location_score
                    ),
            },

            "strong_skills":
                skill_result[
                    "strong"
                ],

            "partial_skills":
                skill_result[
                    "partial"
                ],

            "missing_skills":
                skill_result[
                    "missing"
                ],
        }

    # ============================================================
    # RANK EVENTS
    # ============================================================

    def rank_events(
        self,
        profile: dict,
        events: list[dict],
    ) -> list[dict]:

        results = [
            self.score_event(
                profile,
                event,
            )
            for event in events
        ]

        return sorted(
            results,
            key=lambda item: (
                item[
                    "event_fit"
                ],
                item[
                    "fit_coverage"
                ],
            ),
            reverse=True,
        )