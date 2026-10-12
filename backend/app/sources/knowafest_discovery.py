import json
import time
import xml.etree.ElementTree as ET
from datetime import datetime, timezone
from pathlib import Path

import requests


BACKEND_ROOT = (
    Path(__file__)
    .resolve()
    .parents[2]
)

CACHE_FILE = (
    BACKEND_ROOT
    / "data"
    / "cache"
    / "knowafest_discovered_urls.json"
)


class KnowAFestDiscovery:

    FEED_URL = (
        "https://www.knowafest.com/feed.xml"
    )

    SITEMAP_INDEX_URL = (
        "https://www.knowafest.com/"
        "sitemap-events.xml"
    )

    GENERAL_SITEMAP_URL = (
        "https://www.knowafest.com/"
        "sitemap.xml"
    )

    CONNECT_TIMEOUT = 10

    READ_TIMEOUT = 45

    MAX_RETRIES = 3

    BACKOFF_SECONDS = [
        2,
        5,
        10,
    ]

    def __init__(self):

        self.session = requests.Session()

        self.session.headers.update(
            {
                "User-Agent":
                    "Mozilla/5.0 "
                    "(Windows NT 10.0; Win64; x64) "
                    "AppleWebKit/537.36 "
                    "(KHTML, like Gecko) "
                    "Chrome/154.0.0.0 "
                    "Safari/537.36",

                "Accept":
                    "application/xml,"
                    "text/xml,"
                    "application/rss+xml,"
                    "text/html,"
                    "*/*",

                "Accept-Language":
                    "en-US,en;q=0.9",

                "Cache-Control":
                    "no-cache",
            }
        )

    # ============================================================
    # URL HELPERS
    # ============================================================

    def clean_event_url(
        self,
        url: str,
    ) -> str:

        if not url:
            return ""

        url = str(
            url
        ).strip()

        url = url.split(
            "#"
        )[0]

        url = url.split(
            "?"
        )[0]

        return url.rstrip(
            "/"
        )

    def is_event_url(
        self,
        url: str,
    ) -> bool:

        if not url:
            return False

        clean_url = (
            self.clean_event_url(
                url
            )
            .lower()
        )

        return (
            clean_url.startswith(
                "https://www.knowafest.com/event/"
            )
            or clean_url.startswith(
                "http://www.knowafest.com/event/"
            )
        )

    # ============================================================
    # CACHE
    # ============================================================

    def load_cached_urls(
        self,
    ) -> list[str]:

        if not CACHE_FILE.exists():
            return []

        try:

            with open(
                CACHE_FILE,
                "r",
                encoding="utf-8",
            ) as file:

                data = json.load(
                    file
                )

            urls = data.get(
                "urls",
                [],
            )

            if not isinstance(
                urls,
                list,
            ):
                return []

            result = []

            seen = set()

            for url in urls:

                if not self.is_event_url(
                    url
                ):
                    continue

                clean_url = (
                    self.clean_event_url(
                        url
                    )
                )

                if clean_url in seen:
                    continue

                seen.add(
                    clean_url
                )

                result.append(
                    clean_url
                )

            return result

        except (
            OSError,
            json.JSONDecodeError,
        ) as exc:

            print(
                "URL cache could not be read: "
                f"{exc}"
            )

            return []

    def save_cached_urls(
        self,
        new_urls: list[str],
    ):

        if not new_urls:
            return

        existing_urls = (
            self.load_cached_urls()
        )

        combined = []

        seen = set()

        # New URLs first.
        for url in (
            new_urls
            +
            existing_urls
        ):

            if not self.is_event_url(
                url
            ):
                continue

            clean_url = (
                self.clean_event_url(
                    url
                )
            )

            if clean_url in seen:
                continue

            seen.add(
                clean_url
            )

            combined.append(
                clean_url
            )

        CACHE_FILE.parent.mkdir(
            parents=True,
            exist_ok=True,
        )

        payload = {
            "updated_at":
                datetime.now(
                    timezone.utc
                ).isoformat(),

            "url_count":
                len(combined),

            "urls":
                combined,
        }

        with open(
            CACHE_FILE,
            "w",
            encoding="utf-8",
        ) as file:

            json.dump(
                payload,
                file,
                indent=2,
                ensure_ascii=False,
            )

        print(
            "KnowAFest URL cache updated: "
            f"{len(combined)} URLs"
        )

    # ============================================================
    # REQUEST WITH RETRIES
    # ============================================================

    def fetch(
        self,
        url: str,
    ) -> str:

        for attempt in range(
            1,
            self.MAX_RETRIES + 1,
        ):

            try:

                response = (
                    self.session.get(
                        url,
                        timeout=(
                            self.CONNECT_TIMEOUT,
                            self.READ_TIMEOUT,
                        ),
                    )
                )

                if response.status_code == 200:

                    text = (
                        response.text
                        or ""
                    )

                    if text.strip():
                        return text

                    print(
                        "KnowAFest returned "
                        f"empty content for {url}"
                    )

                elif (
                    response.status_code
                    in {
                        429,
                        500,
                        502,
                        503,
                        504,
                    }
                ):

                    print(
                        "KnowAFest returned "
                        f"{response.status_code} "
                        f"for {url} "
                        f"(attempt "
                        f"{attempt}/"
                        f"{self.MAX_RETRIES})"
                    )

                else:

                    print(
                        "KnowAFest returned "
                        f"{response.status_code} "
                        f"for {url}"
                    )

                    return ""

            except requests.RequestException as exc:

                print(
                    "Request failed "
                    f"(attempt "
                    f"{attempt}/"
                    f"{self.MAX_RETRIES}): "
                    f"{exc}"
                )

            if (
                attempt
                < self.MAX_RETRIES
            ):

                wait_seconds = (
                    self.BACKOFF_SECONDS[
                        min(
                            attempt - 1,
                            len(
                                self.BACKOFF_SECONDS
                            ) - 1,
                        )
                    ]
                )

                print(
                    f"Retrying in "
                    f"{wait_seconds}s..."
                )

                time.sleep(
                    wait_seconds
                )

        return ""

    # ============================================================
    # XML HELPERS
    # ============================================================

    def parse_xml(
        self,
        xml_text: str,
    ):

        if not xml_text:
            return None

        try:

            return ET.fromstring(
                xml_text
            )

        except ET.ParseError as exc:

            print(
                "XML parse failed: "
                f"{exc}"
            )

            return None

    def extract_loc_values(
        self,
        root,
    ) -> list[str]:

        if root is None:
            return []

        results = []

        for element in root.iter():

            tag = (
                element.tag
                .split("}")[-1]
                .lower()
            )

            if (
                tag == "loc"
                and element.text
            ):

                value = (
                    element.text
                    .strip()
                )

                if value:

                    results.append(
                        value
                    )

        return results

    # ============================================================
    # RSS DISCOVERY
    # ============================================================

    def discover_from_rss(
        self,
    ) -> list[str]:

        print(
            "Trying KnowAFest RSS feed..."
        )

        xml_text = self.fetch(
            self.FEED_URL
        )

        if not xml_text:
            return []

        root = self.parse_xml(
            xml_text
        )

        if root is None:
            return []

        urls = []

        seen = set()

        for item in root.iter():

            tag = (
                item.tag
                .split("}")[-1]
                .lower()
            )

            if tag != "item":
                continue

            event_url = ""

            for child in item:

                child_tag = (
                    child.tag
                    .split("}")[-1]
                    .lower()
                )

                if (
                    child_tag == "link"
                    and child.text
                ):

                    event_url = (
                        child.text
                        .strip()
                    )

                    break

            if not self.is_event_url(
                event_url
            ):
                continue

            event_url = (
                self.clean_event_url(
                    event_url
                )
            )

            if event_url in seen:
                continue

            seen.add(
                event_url
            )

            urls.append(
                event_url
            )

        print(
            "RSS event URLs found: "
            f"{len(urls)}"
        )

        return urls

    # ============================================================
    # SINGLE SITEMAP
    # ============================================================

    def discover_from_single_sitemap(
        self,
        sitemap_url: str,
    ) -> list[str]:

        xml_text = self.fetch(
            sitemap_url
        )

        if not xml_text:
            return []

        root = self.parse_xml(
            xml_text
        )

        if root is None:
            return []

        urls = []

        seen = set()

        for url in self.extract_loc_values(
            root
        ):

            if not self.is_event_url(
                url
            ):
                continue

            clean_url = (
                self.clean_event_url(
                    url
                )
            )

            if clean_url in seen:
                continue

            seen.add(
                clean_url
            )

            urls.append(
                clean_url
            )

        return urls

    # ============================================================
    # EVENT SITEMAP
    # ============================================================

    def discover_from_sitemap(
        self,
        limit: int = 30,
    ) -> list[str]:

        print(
            "Trying KnowAFest event sitemap..."
        )

        xml_text = self.fetch(
            self.SITEMAP_INDEX_URL
        )

        if not xml_text:
            return []

        root = self.parse_xml(
            xml_text
        )

        if root is None:
            return []

        locations = (
            self.extract_loc_values(
                root
            )
        )

        results = []

        seen = set()

        # Direct event URLs
        for location in locations:

            if self.is_event_url(
                location
            ):

                event_url = (
                    self.clean_event_url(
                        location
                    )
                )

                if event_url not in seen:

                    seen.add(
                        event_url
                    )

                    results.append(
                        event_url
                    )

                    if (
                        len(results)
                        >= limit
                    ):

                        return results

        # Sitemap index children
        child_sitemaps = [
            location
            for location in locations
            if (
                location.endswith(
                    ".xml"
                )
                and not self.is_event_url(
                    location
                )
            )
        ]

        for sitemap_url in child_sitemaps:

            child_events = (
                self.discover_from_single_sitemap(
                    sitemap_url
                )
            )

            for event_url in child_events:

                if event_url in seen:
                    continue

                seen.add(
                    event_url
                )

                results.append(
                    event_url
                )

                if (
                    len(results)
                    >= limit
                ):

                    return results

        print(
            "Sitemap event URLs found: "
            f"{len(results)}"
        )

        return results

    # ============================================================
    # GENERAL SITEMAP
    # ============================================================

    def discover_from_general_sitemap(
        self,
        limit: int = 30,
    ) -> list[str]:

        print(
            "Trying KnowAFest general sitemap..."
        )

        xml_text = self.fetch(
            self.GENERAL_SITEMAP_URL
        )

        if not xml_text:
            return []

        root = self.parse_xml(
            xml_text
        )

        if root is None:
            return []

        locations = (
            self.extract_loc_values(
                root
            )
        )

        results = []

        seen = set()

        # Direct event URLs
        for location in locations:

            if not self.is_event_url(
                location
            ):
                continue

            clean_url = (
                self.clean_event_url(
                    location
                )
            )

            if clean_url in seen:
                continue

            seen.add(
                clean_url
            )

            results.append(
                clean_url
            )

            if (
                len(results)
                >= limit
            ):

                return results

        # Child sitemap URLs
        if len(results) < limit:

            child_sitemaps = [
                location
                for location in locations
                if location.endswith(
                    ".xml"
                )
            ]

            for sitemap_url in child_sitemaps:

                child_events = (
                    self.discover_from_single_sitemap(
                        sitemap_url
                    )
                )

                for event_url in child_events:

                    if event_url in seen:
                        continue

                    seen.add(
                        event_url
                    )

                    results.append(
                        event_url
                    )

                    if (
                        len(results)
                        >= limit
                    ):

                        return results

        print(
            "General sitemap event URLs found: "
            f"{len(results)}"
        )

        return results

    # ============================================================
    # MAIN DISCOVERY
    # ============================================================

    def discover(
        self,
        limit: int = 30,
    ) -> list[str]:

        collected = []

        seen = set()

        live_urls = []

        # --------------------------------------------------------
        # 1. RSS
        # --------------------------------------------------------

        rss_urls = (
            self.discover_from_rss()
        )

        for url in rss_urls:

            if url in seen:
                continue

            seen.add(
                url
            )

            collected.append(
                url
            )

            live_urls.append(
                url
            )

            if (
                len(collected)
                >= limit
            ):

                self.save_cached_urls(
                    live_urls
                )

                return collected[
                    :limit
                ]

        # --------------------------------------------------------
        # 2. EVENT SITEMAP
        # --------------------------------------------------------

        if len(collected) < limit:

            print(
                "RSS unavailable, empty, "
                "or insufficient. "
                "Trying sitemap fallback..."
            )

            sitemap_urls = (
                self.discover_from_sitemap(
                    limit=limit
                )
            )

            for url in sitemap_urls:

                if url in seen:
                    continue

                seen.add(
                    url
                )

                collected.append(
                    url
                )

                live_urls.append(
                    url
                )

                if (
                    len(collected)
                    >= limit
                ):

                    self.save_cached_urls(
                        live_urls
                    )

                    return collected[
                        :limit
                    ]

        # --------------------------------------------------------
        # 3. GENERAL SITEMAP
        # --------------------------------------------------------

        if len(collected) < limit:

            general_urls = (
                self.discover_from_general_sitemap(
                    limit=limit
                )
            )

            for url in general_urls:

                if url in seen:
                    continue

                seen.add(
                    url
                )

                collected.append(
                    url
                )

                live_urls.append(
                    url
                )

                if (
                    len(collected)
                    >= limit
                ):

                    self.save_cached_urls(
                        live_urls
                    )

                    return collected[
                        :limit
                    ]

        # --------------------------------------------------------
        # SAVE ANY LIVE URLs WE FOUND
        # --------------------------------------------------------

        if live_urls:

            self.save_cached_urls(
                live_urls
            )

        # --------------------------------------------------------
        # 4. CACHE FALLBACK
        # --------------------------------------------------------

        if len(collected) < limit:

            cached_urls = (
                self.load_cached_urls()
            )

            if cached_urls:

                print(
                    "Using cached KnowAFest "
                    f"URLs: {len(cached_urls)}"
                )

                for url in cached_urls:

                    if url in seen:
                        continue

                    seen.add(
                        url
                    )

                    collected.append(
                        url
                    )

                    if (
                        len(collected)
                        >= limit
                    ):

                        break

        # --------------------------------------------------------
        # RESULT
        # --------------------------------------------------------

        if not collected:

            print(
                "No KnowAFest events "
                "could be discovered."
            )

            print(
                "KnowAFest URL cache "
                "is also empty."
            )

        else:

            print(
                "Total available "
                "KnowAFest event URLs: "
                f"{len(collected)}"
            )

        return collected[
            :limit
        ]