from datetime import datetime, timezone
from hashlib import sha1
import re

from backend.app.models.opportunity import Opportunity
from backend.app.intelligence.skill_extractor import SkillExtractor
from backend.app.intelligence.skill_normalizer import SkillNormalizer
from backend.app.intelligence.event_skill_filter import EventSkillFilter


class OpportunityNormalizer:

    EVENT_SKILL_NOISE = {
        "innovation",
        "mobile",
        "application",
        "applications",
        "technology",
        "technologies",
        "experience",
        "team",
        "teams",
        "collaboration",
        "business systems",
        "engineering",
        "organized",
        "solutions",
        "computer",
        "creative",
        "features",
        "science",
        "reporting",
        "win",
        "marks",
        "build",
        "code",
        "participant",
        "participants",
        "make",
        "training",
    }

    def __init__(self):

        self.skill_extractor = (
            SkillExtractor()
        )

        self.event_skill_filter = (
            EventSkillFilter()
        )

    # ============================================================
    # BASIC CLEANING
    # ============================================================

    def clean(
        self,
        value,
    ) -> str:

        if value is None:
            return ""

        return re.sub(
            r"\s+",
            " ",
            str(value),
        ).strip()

    # ============================================================
    # LIST CONVERSION
    # ============================================================

    def to_list(
        self,
        value,
    ) -> list[str]:

        if value is None:
            return []

        if isinstance(
            value,
            list,
        ):

            values = value

        else:

            values = re.split(
                r"[;,|]",
                str(value),
            )

        result = []

        for item in values:

            item = self.clean(
                item
            )

            if item:

                result.append(
                    item
                )

        return result

    # ============================================================
    # MODE
    # ============================================================

    def normalize_mode(
        self,
        value,
    ) -> str:

        value = (
            self.clean(
                value
            )
            .lower()
        )

        if value in {
            "online",
            "virtual",
            "remote",
        }:
            return "Online"

        if value in {
            "hybrid",
            "online + offline",
            "offline + online",
        }:
            return "Hybrid"

        if value in {
            "offline",
            "in-person",
            "in person",
            "onsite",
            "on-site",
        }:
            return "Offline"

        return (
            self.clean(
                value
            )
            .title()
        )

    # ============================================================
    # EVENT TYPE
    # ============================================================

    def normalize_event_type(
        self,
        value,
    ) -> str:

        value = (
            self.clean(
                value
            )
            .lower()
        )

        aliases = {
            "hackathons":
                "Hackathon",

            "hackathon":
                "Hackathon",

            "workshops":
                "Workshop",

            "workshop":
                "Workshop",

            "conference":
                "Conference",

            "conferences":
                "Conference",

            "competition":
                "Competition",

            "contest":
                "Competition",

            "webinar":
                "Webinar",

            "meetup":
                "Meetup",

            "internship":
                "Internship",

            "seminar":
                "Seminar",

            "symposium":
                "Symposium",
        }

        return aliases.get(
            value,
            self.clean(
                value
            ).title(),
        )

    # ============================================================
    # FEE
    # ============================================================

    def parse_fee(
        self,
        value,
    ):

        if value is None:
            return None

        text = (
            self.clean(
                value
            )
            .lower()
        )

        if text in {
            "",
            "none",
            "n/a",
            "not specified",
        }:
            return None

        if text in {
            "free",
            "no fee",
            "0",
        }:
            return 0.0

        cleaned = re.sub(
            r"[^\d.]",
            "",
            text,
        )

        if not cleaned:
            return None

        try:

            return float(
                cleaned
            )

        except ValueError:

            return None

    # ============================================================
    # ID GENERATION
    # ============================================================

    def generate_id(
        self,
        title,
        start_date,
        source_url,
    ) -> str:

        raw = (
            f"{title}|"
            f"{start_date}|"
            f"{source_url}"
        )

        digest = sha1(
            raw.encode(
                "utf-8"
            )
        ).hexdigest()[:12]

        return (
            f"event_{digest}"
        )

    # ============================================================
    # NORMALIZE EVENT
    # ============================================================

    def normalize(
        self,
        raw: dict,
    ) -> Opportunity:

        # --------------------------------------------------------
        # TEXT FIELDS
        # --------------------------------------------------------

        title = self.clean(
            raw.get(
                "title"
            )
        )

        description = self.clean(
            raw.get(
                "description"
            )
        )

        eligibility = self.clean(
            raw.get(
                "eligibility"
            )
        )

        tags = self.to_list(
            raw.get(
                "tags"
            )
        )

        provided_skills = self.to_list(
            raw.get(
                "required_skills"
            )
        )

        # --------------------------------------------------------
        # SKILL EXTRACTION
        # --------------------------------------------------------

        skill_text = " ".join(
            [
                title,
                description,
                eligibility,
                " ".join(
                    tags
                ),
                " ".join(
                    provided_skills
                ),
            ]
        )

        # URLs can contain technology-looking words
        # such as vercel.app, github.com, etc.
        # They should not become event requirements.
        skill_text = re.sub(
            r"https?://\S+|www\.\S+",
            " ",
            skill_text,
        )

        skill_text = re.sub(
            r"\s+",
            " ",
            skill_text,
        ).strip()

        extracted_skills = (
            self.skill_extractor.extract(
                skill_text
            )
        )

        # --------------------------------------------------------
        # PROVIDED SKILLS
        #
        # Explicit skills supplied by a source are trusted more
        # than automatically extracted words.
        # --------------------------------------------------------

        provided_skills = (
            SkillNormalizer.normalize_many(
                provided_skills
            )
        )

        # --------------------------------------------------------
        # EXTRACTED SKILLS
        #
        # Extracted candidates must pass the technical/readiness
        # evidence filter before affecting event readiness.
        # --------------------------------------------------------

        extracted_skills = (
            SkillNormalizer.normalize_many(
                extracted_skills
            )
        )

        extracted_skills = (
            self.event_skill_filter.filter(
                extracted_skills
            )
        )

        # --------------------------------------------------------
        # COMBINE SKILLS
        # --------------------------------------------------------

        combined_skills = (
            provided_skills
            +
            extracted_skills
        )

        required_skills = (
            SkillNormalizer.normalize_many(
                combined_skills
            )
        )

        # --------------------------------------------------------
        # FINAL NOISE SAFETY FILTER
        # --------------------------------------------------------

        required_skills = [
            skill
            for skill in required_skills
            if skill not in self.EVENT_SKILL_NOISE
        ]

        # --------------------------------------------------------
        # BASIC FIELDS
        # --------------------------------------------------------

        source_url = self.clean(
            raw.get(
                "source_url"
            )
        )

        start_date = raw.get(
            "start_date"
        )

        event_id = self.clean(
            raw.get(
                "id"
            )
        )

        if not event_id:

            event_id = (
                self.generate_id(
                    title,
                    start_date,
                    source_url,
                )
            )

        # --------------------------------------------------------
        # BUILD OPPORTUNITY
        # --------------------------------------------------------

        return Opportunity(

            id=event_id,

            title=title,

            event_type=(
                self.normalize_event_type(
                    raw.get(
                        "event_type"
                    )
                )
            ),

            organizer=self.clean(
                raw.get(
                    "organizer"
                )
            ),

            description=description,

            start_date=start_date,

            end_date=raw.get(
                "end_date"
            ),

            registration_deadline=raw.get(
                "registration_deadline"
            ),

            location=self.clean(
                raw.get(
                    "location"
                )
            ),

            city=self.clean(
                raw.get(
                    "city"
                )
            ),

            state=self.clean(
                raw.get(
                    "state"
                )
            ),

            country=(
                self.clean(
                    raw.get(
                        "country"
                    )
                )
                or "India"
            ),

            mode=self.normalize_mode(
                raw.get(
                    "mode"
                )
            ),

            fee=self.parse_fee(
                raw.get(
                    "fee"
                )
            ),

            prize=self.clean(
                raw.get(
                    "prize"
                )
            ),

            eligibility=eligibility,

            interests=self.to_list(
                raw.get(
                    "interests"
                )
            ),

            required_skills=(
                required_skills
            ),

            tags=tags,

            source=self.clean(
                raw.get(
                    "source"
                )
            ),

            source_url=source_url,

            official_url=self.clean(
                raw.get(
                    "official_url"
                )
            ),

            registration_url=self.clean(
                raw.get(
                    "registration_url"
                )
            ),

            image_url=self.clean(
                raw.get(
                    "image_url"
                )
            ),

            verified=bool(
                raw.get(
                    "verified",
                    False,
                )
            ),

            last_checked=(
                raw.get(
                    "last_checked"
                )
                or datetime.now(
                    timezone.utc
                ).isoformat()
            ),
        )