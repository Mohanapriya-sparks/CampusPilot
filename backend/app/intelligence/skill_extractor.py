from pathlib import Path
import re

import pandas as pd


ROOT = Path(__file__).resolve().parents[2]

VOCABULARY_FILE = (
    ROOT
    / "data"
    / "derived"
    / "campuspilot_master_skills_final.csv"
)


# Alias → canonical skill
ALIASES = {
    "ai": "artificial intelligence",
    "ai/ml": "artificial intelligence",
    "artificial intelligence": "artificial intelligence",

    "git hub": "github",
    "github.com": "github",

    "graph ql": "graphql",

    "cyber security": "cybersecurity",
    "information security": "cybersecurity",
    "infosec": "cybersecurity",

    "esp-32": "esp32",
    "espressif esp32": "esp32",

    "internet of things": "iot",
    "internet-of-things": "iot",

    "torch/pytorch": "pytorch",

    "rest apis": "rest api",
    "restful api": "rest api",
    "restful apis": "rest api",

    "ui ux": "ui/ux",
    "ui/ux design": "ui/ux",

    "amazon web services": "aws",
    "microsoft azure": "azure",
    "google cloud": "gcp",

    "react.js": "react",
    "reactjs": "react",

    "nodejs": "node.js",
    "node js": "node.js",

    "team work": "teamwork",
    "team-work": "teamwork",

    "problem-solving": "problem solving",
"apis": "api",
"application programming interface": "api",
"application programming interfaces": "api",

"llms": "llm",
"large language model": "llm",
"large language models": "llm",

}


class SkillExtractor:

    def __init__(self):

        df = pd.read_csv(
            VOCABULARY_FILE
        )

        skills = (
            df["skill"]
            .dropna()
            .astype(str)
            .str.lower()
            .unique()
            .tolist()
        )

        # Search phrase → canonical skill
        self.search_terms = {}

        for skill in skills:
            self.search_terms[skill] = skill

        for alias, canonical in ALIASES.items():
            self.search_terms[alias] = canonical

        # Search longest terms first.
        self.search_terms = dict(
            sorted(
                self.search_terms.items(),
                key=lambda item: len(item[0]),
                reverse=True,
            )
        )

        self.single_word_noise = {
            "skill",
            "skills",
            "project",
            "customer",
            "service",
            "analysis",
            "microsoft",
            "basic",
            "forms",
            "written",
            "functional",
            "managing",
            "supervisor",
        }


    def clean_text(
        self,
        text: str,
    ) -> str:

        text = text.lower()

        text = re.sub(
            r"[^a-z0-9+#./ -]",
            " ",
            text,
        )

        text = re.sub(
            r"\s+",
            " ",
            text,
        )

        return text.strip()


    def extract(
        self,
        text: str,
    ) -> list[str]:

        cleaned = self.clean_text(
            text
        )

        matches = []


        # --------------------------------------------------
        # FIND MATCHES
        # --------------------------------------------------

        for phrase, canonical in (
            self.search_terms.items()
        ):

            if (
                " " not in phrase
                and phrase
                in self.single_word_noise
            ):
                continue

            pattern = (
                r"(?<![a-z0-9])"
                + re.escape(phrase)
                + r"(?![a-z0-9])"
            )

            for match in re.finditer(
                pattern,
                cleaned,
            ):

                matches.append(
                    {
                        "phrase": phrase,
                        "skill": canonical,
                        "start": match.start(),
                        "end": match.end(),
                        "length": len(phrase),
                    }
                )


        # --------------------------------------------------
        # LONGEST MATCH WINS
        # --------------------------------------------------

        matches.sort(
            key=lambda item: (
                -item["length"],
                item["start"],
            )
        )

        selected = []

        occupied = []


        for item in matches:

            start = item["start"]
            end = item["end"]

            overlap = any(
                start < existing_end
                and end > existing_start
                for existing_start,
                existing_end
                in occupied
            )

            if overlap:
                continue

            selected.append(
                item["skill"]
            )

            occupied.append(
                (
                    start,
                    end,
                )
            )


        # --------------------------------------------------
        # REMOVE DUPLICATES
        # --------------------------------------------------

        result = []

        seen = set()

        for skill in selected:

            if skill not in seen:

                seen.add(skill)
                result.append(skill)


        return result