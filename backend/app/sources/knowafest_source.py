import json
import re
from datetime import datetime, timezone, timedelta
from typing import Optional

import requests
from bs4 import BeautifulSoup

from backend.app.services.opportunity_normalizer import (
    OpportunityNormalizer,
)


class KnowAFestSource:

    BASE_URL = "https://www.knowafest.com"

    def __init__(self):

        self.normalizer = OpportunityNormalizer()

        self.session = requests.Session()

        self.session.headers.update(
            {
                "User-Agent":
                    "CampusPilot/1.0 "
                    "(student opportunity discovery project)"
            }
        )

    # ============================================================
    # REGISTRATION DEADLINE
    # ============================================================

    def extract_registration_deadline(
        self,
        page_text: str,
    ):

        match = re.search(
            r"Registration closes\s+"
            r"(\d{1,2}\s+[A-Za-z]{3}\s+\d{4})"
            r"(?:\s*[·\-]\s*"
            r"(\d{1,2}:\d{2}\s*[AP]M))?",
            page_text,
            re.IGNORECASE,
        )

        if not match:
            return None

        date_part = match.group(1)

        time_part = (
            match.group(2)
            or "11:59 PM"
        )

        try:

            dt = datetime.strptime(
                f"{date_part} {time_part}",
                "%d %b %Y %I:%M %p",
            )

            ist = timezone(
                timedelta(
                    hours=5,
                    minutes=30,
                )
            )

            dt = dt.replace(
                tzinfo=ist
            )

            return dt.isoformat()

        except ValueError:
            return None

    # ============================================================
    # OFFICIAL WEBSITE
    # ============================================================

    def extract_official_url(
        self,
        soup,
    ) -> str:

        for link in soup.find_all(
            "a",
            href=True,
        ):

            text = link.get_text(
                " ",
                strip=True,
            ).lower()

            href = link[
                "href"
            ].strip()

            if (
                "official event website" in text
                and href.startswith("http")
            ):

                lower_href = (
                    href.lower()
                )

                # Google Forms are registration links,
                # not official event websites.
                if (
                    "docs.google.com/forms"
                    in lower_href
                    or "forms.gle"
                    in lower_href
                ):
                    continue

                return href

        return ""

    # ============================================================
    # REGISTRATION URL
    # ============================================================

    def extract_registration_url(
        self,
        soup,
    ) -> str:

        registration_phrases = [
            "register on organizer site",
            "register now",
            "registration link",
            "register here",
            "apply now",
        ]

        for link in soup.find_all(
            "a",
            href=True,
        ):

            text = link.get_text(
                " ",
                strip=True,
            ).lower()

            href = link[
                "href"
            ].strip()

            if not href.startswith(
                "http"
            ):
                continue

            lower_href = (
                href.lower()
            )

            # Direct Google registration form
            if (
                "docs.google.com/forms"
                in lower_href
                or "forms.gle"
                in lower_href
            ):
                return href

            if any(
                phrase in text
                for phrase
                in registration_phrases
            ):
                return href

        return ""

    # ============================================================
    # FETCH PAGE
    # ============================================================

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

    # ============================================================
    # JSON-LD
    # ============================================================

    def find_event_jsonld(
        self,
        soup: BeautifulSoup,
    ) -> Optional[dict]:

        scripts = soup.find_all(
            "script",
            type="application/ld+json",
        )

        for script in scripts:

            raw = script.string

            if not raw:
                continue

            try:

                data = json.loads(
                    raw
                )

            except json.JSONDecodeError:
                continue

            candidates = []

            if isinstance(
                data,
                dict,
            ):

                if "@graph" in data:

                    graph = data.get(
                        "@graph",
                        [],
                    )

                    if isinstance(
                        graph,
                        list,
                    ):

                        candidates.extend(
                            graph
                        )

                candidates.append(
                    data
                )

            elif isinstance(
                data,
                list,
            ):

                candidates.extend(
                    data
                )

            for candidate in candidates:

                if not isinstance(
                    candidate,
                    dict,
                ):
                    continue

                event_type = (
                    candidate.get(
                        "@type"
                    )
                )

                if isinstance(
                    event_type,
                    list,
                ):

                    if "Event" in event_type:
                        return candidate

                elif event_type == "Event":

                    return candidate

        return None

    # ============================================================
    # META
    # ============================================================

    def get_meta(
        self,
        soup,
        *,
        property_name=None,
        name=None,
    ) -> str:

        attrs = {}

        if property_name:

            attrs[
                "property"
            ] = property_name

        if name:

            attrs[
                "name"
            ] = name

        tag = soup.find(
            "meta",
            attrs=attrs,
        )

        if not tag:
            return ""

        return (
            tag.get(
                "content",
                "",
            )
            .strip()
        )

    # ============================================================
    # LOCATION
    # ============================================================

    def extract_location(
        self,
        location,
    ) -> tuple[str, str, str, str]:

        if not location:

            return (
                "",
                "",
                "",
                "India",
            )

        if isinstance(
            location,
            str,
        ):

            return (
                location,
                "",
                "",
                "India",
            )

        address = (
            location.get(
                "address",
                {},
            )
        )

        if isinstance(
            address,
            str,
        ):

            return (
                address,
                "",
                "",
                "India",
            )

        city = str(
            address.get(
                "addressLocality",
                "",
            )
        ).strip()

        state = str(
            address.get(
                "addressRegion",
                "",
            )
        ).strip()

        country = (
            address.get(
                "addressCountry",
                "India",
            )
        )

        if isinstance(
            country,
            dict,
        ):

            country = (
                country.get(
                    "name",
                    "India",
                )
            )

        country = str(
            country
        ).strip()

        parts = [
            part
            for part in [
                city,
                state,
                country,
            ]
            if part
        ]

        return (
            ", ".join(
                parts
            ),
            city,
            state,
            country or "India",
        )

    # ============================================================
    # ORGANIZER
    # ============================================================

    def extract_organizer(
        self,
        organizer,
    ) -> str:

        if isinstance(
            organizer,
            dict,
        ):

            return str(
                organizer.get(
                    "name",
                    "",
                )
            ).strip()

        return str(
            organizer or ""
        ).strip()

    # ============================================================
    # MODE
    # ============================================================

    def extract_mode(
        self,
        event_data,
        page_text,
    ) -> str:

        attendance = str(
            event_data.get(
                "eventAttendanceMode",
                "",
            )
        ).lower()

        if "online" in attendance:
            return "Online"

        if "mixed" in attendance:
            return "Hybrid"

        if "offline" in attendance:
            return "Offline"

        text = (
            page_text.lower()
        )

        if "hybrid" in text:
            return "Hybrid"

        if "online" in text:
            return "Online"

        if (
            "offline" in text
            or "venue" in text
        ):
            return "Offline"

        return ""

    # ============================================================
    # FEE
    # ============================================================

    def extract_fee(
        self,
        event_data,
        page_text,
    ):

        offers = (
            event_data.get(
                "offers"
            )
        )

        if isinstance(
            offers,
            dict,
        ):

            price = offers.get(
                "price"
            )

            if price is not None:
                return price

        free_patterns = [
            "free – no registration fee",
            "free - no registration fee",
            "no registration fee",
        ]

        lower_text = (
            page_text.lower()
        )

        for pattern in free_patterns:

            if pattern in lower_text:
                return 0

        match = re.search(
            r"(?:registration\s+fee\s*:?\s*)?"
            r"(?:₹|rs\.?|inr)\s*"
            r"([0-9][0-9,]*(?:\.[0-9]+)?)",
            page_text,
            re.IGNORECASE,
        )

        if match:

            return (
                match.group(1)
                .replace(
                    ",",
                    "",
                )
            )

        return None

    # ============================================================
    # PARSE EVENT
    # ============================================================

    def fetch_event(
        self,
        url: str,
    ):

        html = self.fetch_html(
            url
        )

        soup = BeautifulSoup(
            html,
            "html.parser",
        )

        page_text = (
            soup.get_text(
                " ",
                strip=True,
            )
        )

        event_data = (
            self.find_event_jsonld(
                soup
            )
            or {}
        )

        # --------------------------------------------------------
        # TITLE
        # --------------------------------------------------------

        title = (
            event_data.get(
                "name",
                "",
            )
        )

        if not title:

            h1 = soup.find(
                "h1"
            )

            if h1:

                title = h1.get_text(
                    " ",
                    strip=True,
                )

        # --------------------------------------------------------
        # DESCRIPTION
        # --------------------------------------------------------

        description = (
            event_data.get(
                "description",
                "",
            )
        )

        if not description:

            description = (
                self.get_meta(
                    soup,
                    name="description",
                )
            )

        # --------------------------------------------------------
        # LOCATION
        # --------------------------------------------------------

        (
            location,
            city,
            state,
            country,
        ) = self.extract_location(
            event_data.get(
                "location"
            )
        )

        # --------------------------------------------------------
        # MODE
        # --------------------------------------------------------

        mode = self.extract_mode(
            event_data,
            page_text,
        )

        # --------------------------------------------------------
        # ORGANIZER
        # --------------------------------------------------------

        organizer = (
            self.extract_organizer(
                event_data.get(
                    "organizer"
                )
            )
        )

        # --------------------------------------------------------
        # DATES
        # --------------------------------------------------------

        start_date = (
            event_data.get(
                "startDate"
            )
        )

        end_date = (
            event_data.get(
                "endDate"
            )
        )

        registration_deadline = (
            self.extract_registration_deadline(
                page_text
            )
        )

        # --------------------------------------------------------
        # IMAGE
        # --------------------------------------------------------

        image = (
            event_data.get(
                "image",
                "",
            )
        )

        if isinstance(
            image,
            list,
        ):

            image = (
                image[0]
                if image
                else ""
            )

        # --------------------------------------------------------
        # FEE
        # --------------------------------------------------------

        fee = self.extract_fee(
            event_data,
            page_text,
        )

        # --------------------------------------------------------
        # EVENT TYPE
        # --------------------------------------------------------

        event_type = ""

        lower_text = (
            f"{title} "
            f"{description} "
            f"{page_text}"
        ).lower()

        type_keywords = [
            (
                "hackathon",
                "Hackathon",
            ),
            (
                "workshop",
                "Workshop",
            ),
            (
                "conference",
                "Conference",
            ),
            (
                "symposium",
                "Symposium",
            ),
            (
                "competition",
                "Competition",
            ),
            (
                "seminar",
                "Seminar",
            ),
            (
                "internship",
                "Internship",
            ),
            (
                "webinar",
                "Webinar",
            ),
        ]

        for (
            keyword,
            label,
        ) in type_keywords:

            if keyword in lower_text:

                event_type = label
                break

        # --------------------------------------------------------
        # URLS
        # --------------------------------------------------------

        official_url = (
            self.extract_official_url(
                soup
            )
        )

        registration_url = (
            self.extract_registration_url(
                soup
            )
        )

        # Avoid storing the same URL twice.
        if (
            registration_url
            and official_url
            and registration_url.rstrip("/")
            == official_url.rstrip("/")
        ):
            registration_url = ""

        # --------------------------------------------------------
        # RAW EVENT
        # --------------------------------------------------------

        raw_event = {

            "title":
                title,

            "event_type":
                event_type,

            "organizer":
                organizer,

            "description":
                description,

            "start_date":
                start_date,

            "end_date":
                end_date,

            "registration_deadline":
                registration_deadline,

            "location":
                location,

            "city":
                city,

            "state":
                state,

            "country":
                country,

            "mode":
                mode,

            "fee":
                fee,

            "source":
                "KnowAFest",

            "source_url":
                url,

            "official_url":
                official_url,

            "registration_url":
                registration_url,

            "image_url":
                image,

            "verified":
                False,
        }

        return self.normalizer.normalize(
            raw_event
        )