from pathlib import Path
from difflib import SequenceMatcher

import pandas as pd

from backend.app.intelligence.skill_normalizer import SkillNormalizer


ROOT = Path(__file__).resolve().parents[2]

SEMANTIC_FILE = (
    ROOT
    / "data"
    / "curated"
    / "campuspilot_semantic_relations.csv"
)


class SemanticMatcher:

    def __init__(self):

        self.semantic_relations = {}

        df = pd.read_csv(
            SEMANTIC_FILE
        )

        for _, row in df.iterrows():

            required = SkillNormalizer.normalize(
                row["required_skill"]
            )

            evidence = SkillNormalizer.normalize(
                row["evidence_skill"]
            )

            key = (
                required,
                evidence,
            )

            self.semantic_relations[key] = {
                "relation_type":
                    str(row["relation_type"]),
                "score":
                    float(row["score"]),
            }


    def lexical_similarity(
        self,
        skill_a: str,
        skill_b: str,
    ) -> float:

        return SequenceMatcher(
            None,
            skill_a,
            skill_b,
        ).ratio()


    def compare(
        self,
        student_skill: str,
        required_skill: str,
    ) -> dict:

        student = SkillNormalizer.normalize(
            student_skill
        )

        required = SkillNormalizer.normalize(
            required_skill
        )


        # ==================================================
        # 1. EXACT / ALIAS MATCH
        # ==================================================

        if student == required:

            return {
                "student_skill": student,
                "required_skill": required,
                "match_type": "exact",
                "relation_type": "exact",
                "score": 1.0,
            }


        # ==================================================
        # 2. VERIFIED SEMANTIC EVIDENCE
        # ==================================================

        relation = self.semantic_relations.get(
            (
                required,
                student,
            )
        )

        if relation:

            return {
                "student_skill": student,
                "required_skill": required,
                "match_type": "semantic",
                "relation_type":
                    relation["relation_type"],
                "score":
                    relation["score"],
            }


        # ==================================================
        # 3. LEXICAL SIMILARITY
        #
        # Only very high similarity is allowed.
        # ==================================================

        similarity = self.lexical_similarity(
            student,
            required,
        )

        if similarity >= 0.90:

            return {
                "student_skill": student,
                "required_skill": required,
                "match_type": "lexical",
                "relation_type":
                    "name_similarity",
                "score": round(
                    similarity,
                    3,
                ),
            }


        # ==================================================
        # NO READINESS EVIDENCE
        # ==================================================

        return {
            "student_skill": student,
            "required_skill": required,
            "match_type": "none",
            "relation_type": None,
            "score": 0.0,
        }


    def best_match(
        self,
        student_skills: list[str],
        required_skill: str,
    ) -> dict:

        best = {
            "student_skill": None,
            "required_skill":
                SkillNormalizer.normalize(
                    required_skill
                ),
            "match_type": "none",
            "relation_type": None,
            "score": 0.0,
        }


        for student_skill in student_skills:

            result = self.compare(
                student_skill,
                required_skill,
            )

            if result["score"] > best["score"]:
                best = result


        return best


    def match_event(
        self,
        student_skills: list[str],
        required_skills: list[str],
    ) -> dict:

        student_skills = (
            SkillNormalizer.normalize_many(
                student_skills
            )
        )

        required_skills = (
            SkillNormalizer.normalize_many(
                required_skills
            )
        )


        matches = []
        total_score = 0.0


        for required_skill in required_skills:

            result = self.best_match(
                student_skills,
                required_skill,
            )

            matches.append(
                result
            )

            total_score += result[
                "score"
            ]


        if required_skills:

            readiness = (
                total_score
                / len(required_skills)
                * 100
            )

        else:
            readiness = 0.0


        strong = [
            item
            for item in matches
            if item["score"] >= 0.90
        ]

        partial = [
            item
            for item in matches
            if 0 < item["score"] < 0.90
        ]

        missing = [
            item
            for item in matches
            if item["score"] == 0
        ]


        return {
            "readiness":
                round(readiness, 1),

            "strong": strong,
            "partial": partial,
            "missing": missing,
            "matches": matches,
        }