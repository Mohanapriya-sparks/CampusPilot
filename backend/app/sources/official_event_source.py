import re
from datetime import datetime, timezone

import requests
from bs4 import BeautifulSoup


class OfficialEventSource:

    def __init__(self):

        self.session = requests.Session()

        self.session.headers.update(
            {
                "User-Agent":
                    "CampusPilot/1.0 "
                    "(student opportunity discovery project)"
            }
        )

    def fetch_html(
        self,
        url: str,
    ) -> str:

        response = self.session.get(
            url,
            timeout=20,
        )

        response.raise_for_status()

        return response.text

    def clean(
        self,
        value,
    ) -> str:

        return re.sub(
            r"\s+",
            " ",
            str(value or ""),
        ).strip()

    def get_meta(
        self,
        soup,
        *,
        name=None,
        property_name=None,
    ) -> str:

        attrs = {}

        if name:
            attrs["name"] = name

        if property_name:
            attrs["property"] = property_name

        tag = soup.find(
            "meta",
            attrs=attrs,
        )

        if not tag:
            return ""

        return self.clean(
            tag.get(
                "content",
                ""
            )
        )

    def title_matches(
        self,
        event_title: str,
        page_title: str,
    ) -> bool:

        def compact(value):

            return re.sub(
                r"[^a-z0-9]",
                "",
                str(value).lower(),
            )

        event_compact = compact(
            event_title
        )

        page_compact = compact(
            page_title
        )

        if not event_compact:
            return False

        if (
            event_compact in page_compact
            or page_compact in event_compact
        ):
            return True

        def words(value):

            return {
                word
                for word in re.findall(
                    r"[a-z0-9]+",
                    str(value).lower(),
                )
                if len(word) > 1
            }

        event_words = words(
            event_title
        )

        page_words = words(
            page_title
        )

        if not event_words:
            return False

        overlap = (
            event_words
            .intersection(
                page_words
            )
        )

        score = (
            len(overlap)
            / len(event_words)
        )

        return score >= 0.50

    def extract_prize(
        self,
        page_text: str,
    ) -> str:

        text = page_text.lower()

        if (
            "tba prize pool" in text
            or "prize pool tba" in text
        ):
            return "TBA"

        patterns = [
            r"prize\s+pool\s*(?:of\s*)?₹\s*([\d,]+)",
            r"₹\s*([\d,]+)\s*(?:prize\s+pool|in\s+prizes)",
            r"total\s+prize\s+pool\s*₹\s*([\d,]+)",
        ]

        for pattern in patterns:

            match = re.search(
                pattern,
                page_text,
                re.IGNORECASE,
            )

            if match:

                amount = match.group(1)

                return (
                    f"₹{amount} prize pool"
                )

        return ""

    def extract_eligibility(
        self,
        page_text: str,
    ) -> str:

        text = page_text.lower()

        if "open to all students" in text:

            return "Open to all students"

        if (
            "college or engineering student"
            in text
        ):

            return (
                "Open to college and "
                "engineering students"
            )

        if "all college students" in text:

            return "Open to all college students"

        return ""

    def enrich(
        self,
        event,
    ):

        if not event.official_url:
            return event

        html = self.fetch_html(
            event.official_url
        )

        soup = BeautifulSoup(
            html,
            "html.parser",
        )

        page_text = soup.get_text(
            " ",
            strip=True,
        )

        meta_description = (
            self.get_meta(
                soup,
                name="description",
            )
        )

        og_title = (
            self.get_meta(
                soup,
                property_name="og:title",
            )
        )

        og_description = (
            self.get_meta(
                soup,
                property_name="og:description",
            )
        )

        official_text = " ".join(
            [
                page_text,
                meta_description,
                og_title,
                og_description,
            ]
        )

        page_title = ""

        if soup.title:

            page_title = (
                soup.title.get_text(
                    " ",
                    strip=True,
                )
            )

        verification_title = (
            page_title
            or og_title
        )

        if self.title_matches(
            event.title,
            verification_title,
        ):

            event.verified = True

        prize = self.extract_prize(
            official_text
        )

        if prize:
            event.prize = prize

        eligibility = (
            self.extract_eligibility(
                official_text
            )
        )

        if eligibility:
            event.eligibility = (
                eligibility
            )

        event.last_checked = (
            datetime.now(
                timezone.utc
            ).isoformat()
        )

        return event