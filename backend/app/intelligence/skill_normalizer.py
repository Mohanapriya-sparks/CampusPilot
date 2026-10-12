class SkillNormalizer:

    ALIASES = {
        "ai": "artificial intelligence",
        "ai/ml": "artificial intelligence",

        "ml": "machine learning",
        "machine-learning": "machine learning",

        "git hub": "github",
        "github.com": "github",

        "graph ql": "graphql",

        "rest apis": "rest api",
        "restful api": "rest api",
        "restful apis": "rest api",

        "ui ux": "ui/ux",
        "ui/ux design": "ui/ux",

        "amazon web services": "aws",
        "amazon web services (aws)": "aws",

        "microsoft azure": "azure",

        "google cloud": "gcp",
        "google cloud platform": "gcp",

        "react.js": "react",
        "reactjs": "react",

        "nodejs": "node.js",
        "node js": "node.js",

        "torch/pytorch": "pytorch",

        "cyber security": "cybersecurity",
        "information security": "cybersecurity",
        "infosec": "cybersecurity",

        "esp-32": "esp32",
        "espressif esp32": "esp32",

        "internet of things": "iot",
        "internet-of-things": "iot",

        "team work": "teamwork",
        "team-work": "teamwork",

        "problem-solving": "problem solving",
        "problem-solving skills": "problem solving",
        "problem solving skills": "problem solving",

        "prototype": "prototyping",
        "prototypes": "prototyping",

        "apis": "api",
        "application programming interface": "api",
        "application programming interfaces": "api",

        "llms": "llm",
        "large language model": "llm",
        "large language models": "llm",
    }

    @classmethod
    def normalize(
        cls,
        skill: str,
    ) -> str:

        if skill is None:
            return ""

        skill = (
            str(skill)
            .strip()
            .lower()
        )

        if not skill:
            return ""

        return cls.ALIASES.get(
            skill,
            skill,
        )

    @classmethod
    def normalize_many(
        cls,
        skills: list[str],
    ) -> list[str]:

        result = []
        seen = set()

        for skill in skills:

            canonical = (
                cls.normalize(
                    skill
                )
            )

            if not canonical:
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