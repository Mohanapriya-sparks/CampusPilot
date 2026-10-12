import requests
import xml.etree.ElementTree as ET


URLS = [
    "https://www.knowafest.com/feed.xml",
    "https://www.knowafest.com/sitemap-events.xml",
]


HEADERS = {
    "User-Agent":
        "Mozilla/5.0 "
        "(Windows NT 10.0; Win64; x64) "
        "AppleWebKit/537.36 "
        "(KHTML, like Gecko) "
        "Chrome/154.0.0.0 Safari/537.36"
}


for url in URLS:

    print()
    print("=" * 80)
    print(url)
    print("=" * 80)

    try:

        response = requests.get(
            url,
            timeout=20,
            headers=HEADERS,
        )

        print(
            "Status:",
            response.status_code,
        )

        print(
            "Length:",
            len(response.text),
        )

        if response.status_code != 200:
            continue


        root = ET.fromstring(
            response.content
        )

        print(
            "Root tag:",
            root.tag,
        )


        # ====================================================
        # RSS
        # ====================================================

        items = root.findall(
            ".//item"
        )

        if items:

            print(
                "RSS items:",
                len(items),
            )

            print()
            print("FIRST 10 RSS ITEMS")
            print("-" * 80)

            for item in items[:10]:

                title = item.findtext(
                    "title",
                    default="",
                )

                link = item.findtext(
                    "link",
                    default="",
                )

                pub_date = item.findtext(
                    "pubDate",
                    default="",
                )

                print()
                print(
                    "Title:",
                    title,
                )

                print(
                    "Link :",
                    link,
                )

                print(
                    "Date :",
                    pub_date,
                )

            continue


        # ====================================================
        # XML SITEMAP
        # ====================================================

        namespace = {
            "sm":
                "http://www.sitemaps.org/"
                "schemas/sitemap/0.9"
        }

        urls = root.findall(
            ".//sm:url",
            namespace,
        )

        print(
            "Sitemap URLs:",
            len(urls),
        )

        print()
        print("FIRST 10 SITEMAP URLS")
        print("-" * 80)

        for item in urls[:10]:

            loc = item.findtext(
                "sm:loc",
                default="",
                namespaces=namespace,
            )

            lastmod = item.findtext(
                "sm:lastmod",
                default="",
                namespaces=namespace,
            )

            print()
            print(
                "URL    :",
                loc,
            )

            print(
                "Lastmod:",
                lastmod,
            )


    except Exception as exc:

        print(
            "ERROR:",
            exc,
        )