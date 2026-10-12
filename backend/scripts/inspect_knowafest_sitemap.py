import requests
from bs4 import BeautifulSoup
from urllib.parse import urljoin


URL = "https://www.knowafest.com/sitemap"


response = requests.get(
    URL,
    timeout=20,
    headers={
        "User-Agent":
            "Mozilla/5.0 "
            "(Windows NT 10.0; Win64; x64) "
            "AppleWebKit/537.36 "
            "(KHTML, like Gecko) "
            "Chrome/154.0.0.0 Safari/537.36"
    },
)


print("=" * 70)
print("KNOWAFEST SITEMAP INSPECTION")
print("=" * 70)

print(
    "Status:",
    response.status_code,
)

print(
    "HTML length:",
    len(response.text),
)


if response.status_code != 200:

    print(
        "\nSitemap is not accessible "
        "from Python right now."
    )

    raise SystemExit()


soup = BeautifulSoup(
    response.text,
    "html.parser",
)


print()
print("POSSIBLE RSS / XML LINKS")
print("-" * 70)


found = []


for link in soup.find_all(
    "a",
    href=True,
):

    href = link[
        "href"
    ].strip()

    text = link.get_text(
        " ",
        strip=True,
    )

    combined = (
        f"{text} {href}"
        .lower()
    )


    if (
        "rss" in combined
        or "xml" in combined
        or "feed" in combined
        or "sitemap" in combined
    ):

        full_url = urljoin(
            URL,
            href,
        )

        if full_url not in found:

            found.append(
                full_url
            )

            print(
                f"{text:<30} "
                f"{full_url}"
            )


print()
print(
    f"Found: {len(found)}"
)