from dataclasses import dataclass, field
from typing import Optional


@dataclass
class Opportunity:

    id: str
    title: str
    event_type: str

    organizer: str = ""
    description: str = ""

    start_date: Optional[str] = None
    end_date: Optional[str] = None
    registration_deadline: Optional[str] = None

    location: str = ""
    city: str = ""
    state: str = ""
    country: str = "India"

    mode: str = ""

    fee: Optional[float] = None

    prize: str = ""
    eligibility: str = ""

    interests: list[str] = field(
        default_factory=list
    )

    required_skills: list[str] = field(
        default_factory=list
    )

    tags: list[str] = field(
        default_factory=list
    )

    source: str = ""

    source_url: str = ""

    official_url: str = ""

    registration_url: str = ""

    image_url: str = ""

    verified: bool = False

    last_checked: Optional[str] = None

    def to_dict(self):

        return {
            "id": self.id,
            "title": self.title,
            "event_type": self.event_type,

            "organizer": self.organizer,
            "description": self.description,

            "start_date": self.start_date,
            "end_date": self.end_date,

            "registration_deadline":
                self.registration_deadline,

            "location": self.location,
            "city": self.city,
            "state": self.state,
            "country": self.country,

            "mode": self.mode,

            "fee": self.fee,

            "prize": self.prize,
            "eligibility": self.eligibility,

            "interests": self.interests,

            "required_skills":
                self.required_skills,

            "tags": self.tags,

            "source": self.source,

            "source_url":
                self.source_url,

            "official_url":
                self.official_url,

            "registration_url":
                self.registration_url,

            "image_url":
                self.image_url,

            "verified":
                self.verified,

            "last_checked":
                self.last_checked,
        }