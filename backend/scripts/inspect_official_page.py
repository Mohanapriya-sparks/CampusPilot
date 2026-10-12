import requests
from bs4 import BeautifulSoup


URL = "https://sakthihackfest-26.vercel.app/"


response = requests.get(
    URL,
    timeout=20,
    headers={
        "User-Agent":
            "CampusPilot/1.0 "
            "(student opportunity discovery project)"
    },
)


print("=" * 70)
print("OFFICIAL PAGE DIAGNOSTIC")
print("=" * 70)

print(
    "Status:",
    response.status_code,
)

print(
    "HTML length:",
    len(response.text),
)


soup = BeautifulSoup(
    response.text,
    "html.parser",
)


print()
print("PAGE TITLE")
print("-" * 70)

if soup.title:
    print(
        soup.title.get_text(
            " ",
            strip=True,
        )
    )
else:
    print("NO TITLE")


print()
print("META TAGS")
print("-" * 70)

for name in [
    "description",
    "og:title",
    "og:description",
]:

    if name.startswith("og:"):

        tag = soup.find(
            "meta",
            attrs={
                "property": name
            },
        )

    else:

        tag = soup.find(
            "meta",
            attrs={
                "name": name
            },
        )

    if tag:

        print(
            name,
            ":",
            tag.get(
                "content",
                "",
            ),
        )


page_text = soup.get_text(
    " ",
    strip=True,
)


print()
print(
    "Visible text length:",
    len(page_text),
)


print()
print("FIRST 1500 CHARACTERS")
print("-" * 70)

print(
    page_text[:1500]
)


print()
print("KEYWORD CHECK")
print("-" * 70)

for keyword in [
    "25,000",
    "25000",
    "prize",
    "students",
    "college",
    "hack",
]:

    print(
        f"{keyword:<15}:",
        keyword.lower()
        in page_text.lower(),
    )