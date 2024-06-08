import json
import os
import re

import requests
from bs4 import BeautifulSoup


class ListingInfoGetter:
    def __init__(self, ref: str):
        # url_base = "https://www.wg-gesucht.de"
        url_base = "https://www.wg-gesucht.de/wg-zimmer-in-Berlin.8.0.1.0.html?csrf_token=c9280a89ddcd56ac55c721ab68f7c5fd64996ca7&offer_filter=1&city_id=8&sort_column=0&sort_order=0&noDeact=1&categories%5B%5D=0&rent_types%5B%5D=2&rent_types%5B%5D=1&rent_types%5B%5D=2%2C1&sMin=14&ot%5B%5D=126&ot%5B%5D=132&ot%5B%5D=85079&ot%5B%5D=151&ot%5B%5D=163&ot%5B%5D=85086&ot%5B%5D=165&wgSea=2&wgMnF=2&wgArt%5B%5D=6&wgArt%5B%5D=12&wgArt%5B%5D=11&wgArt%5B%5D=19&wgArt%5B%5D=22&wgSmo=2&exc=2&img_only=1"
        # url = url_base + ref
        self.r = requests.get(url_base).text

    def get_listing_text(self):
        soup = BeautifulSoup(self.r, "lxml")
        ad_description = soup.find("div", {"id": "ad_description_text"}).find_all(
            ["p", "h3"]
        )
        text = []
        for chunk in ad_description:
            text.extend([chunk.getText().strip(), "\n\n"])
        text = "".join(text)
        return text

    @staticmethod
    def save_listing_text(file_name: str, text: str):
        if not os.path.exists(file_name):
            data = {"texts": [text]}
            with open(file_name, "w") as f:
                json.dump(data, f)

        with open(file_name, "r+") as f:
            data = json.load(f)
            data["texts"].append(text)
            f.seek(0)
            json.dump(data, f)

    def get_rental_length_months(self):
        soup = BeautifulSoup(self.r, "lxml")
        ps = soup.find_all("p", {"style": "line-height: 2em;"})
        dates = []
        for i, p in enumerate(ps):
            text = p.getText().strip()
            if "frei ab:" in text:
                text = text.replace("  ", "")
                dates = [elem for elem in re.split(" |\n", text) if "." in elem]
        if dates:
            return self._get_rental_length_months("-".join(dates))
        else:
            raise ValueError("Could not get rental dates!")

    @staticmethod
    def _get_rental_length_months(date_range_str: str) -> int:
        dates = date_range_str.split("-")
        if len(dates) != 2:
            # means listing is 'unbefristet'
            return -1
        start, end = date_range_str.split("-")
        start, end = start.strip(), end.strip()

        # year, month, day
        start_day, start_month, start_year = start.split(".")
        end_day, end_month, end_year = end.split(".")

        # get time difference in months
        date_diff = (int(end_year) - int(start_year)) * 12 + (
            int(end_month) - int(start_month)
        )
        return date_diff


if __name__ == "__main__":
    getter = ListingInfoGetter("wg-zimmer-in-Berlin.8.0.1.0.html?csrf_token=c9280a89ddcd56ac55c721ab68f7c5fd64996ca7&offer_filter=1&city_id=8&sort_column=0&sort_order=0&noDeact=1&categories%5B%5D=0&rent_types%5B%5D=2&rent_types%5B%5D=1&rent_types%5B%5D=2%2C1&sMin=14&ot%5B%5D=126&ot%5B%5D=132&ot%5B%5D=85079&ot%5B%5D=151&ot%5B%5D=163&ot%5B%5D=85086&ot%5B%5D=165&wgSea=2&wgMnF=2&wgArt%5B%5D=6&wgArt%5B%5D=12&wgArt%5B%5D=11&wgArt%5B%5D=19&wgArt%5B%5D=22&wgSmo=2&exc=2&img_only=1")
    # print(getter.get_listing_text())
    print(getter.get_rental_length_months())
