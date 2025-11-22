import csv
import json
import urllib.request
import configparser

title_includes = ["IT ", "SOFT", "DEVELOP", "OP APPL", "COMPUTER"]
title_excludes = ["TRANSIT"]
import_columns = [
    "agency",
    "business_title",
    "civil_service_title",
    "salary_range_to",
    "job_category",
    "posting_date",
    "post_until",
    "number_of_positions",
]


def get_json_data(url):
    req = urllib.request.Request(url)
    with urllib.request.urlopen(req) as response:
        data = json.loads(response.read().decode("utf-8"))
    return data


def get_nyc_city_jobs():
    jobs_data = get_json_data("https://data.cityofnewyork.us/resource/kpav-sd4t.json")
    cs_titles_data = get_json_data(
        "https://data.cityofnewyork.us/resource/nzjr-3966.json"
    )
    cs_titles = []
    for title in set([c["descr"] for c in cs_titles_data]):
        for include in title_includes:
            if include in title and all(
                exclude not in title for exclude in title_excludes
            ):
                cs_titles.append(title)

    it_jobs = [
        j
        for j in jobs_data
        if j["civil_service_title"] in cs_titles and j["posting_type"] == "External"
    ]
    it_jobs.sort(key=lambda x: float(x["salary_range_to"]), reverse=True)

    cs_title_rows = ""
    for title in cs_titles:
        cs_title_rows += f"""
        <tr>
          <td>{title}</td>
        </tr>
        """

    it_job_rows = ""
    for job in it_jobs[0:10]:
        it_job_rows += "<tr>"
        for column in import_columns:
            it_job_rows += f"<td>{job.get(column, None)}</td>"
        it_job_rows += "</tr>"

    import_columns_headers = ""
    for column in import_columns:
        import_columns_headers += f"<th>{column}</th>"

    html_body = f"""
    <html>
    <body>
      <h2>NYC Tech Jobs Update</h2>
      <p>Here are the latest IT job listings:</p>
      <table border="1" cellpadding="6" cellspacing="0">
        <tr style="background-color: #f2f2f2;">
          {import_columns_headers}
        </tr>
        {it_job_rows}
      </table>
      <p>Here are the Civil Service titles used to filter the jobs:</p>
      <table border="1" cellpadding="6" cellspacing="0">
        <tr style="background-color: #f2f2f2;">
          {cs_title_rows}
        </tr>
      </table>
      <br/>
    </body>
    </html>
    """

    return html_body


if __name__ == "__main__":
    print(get_nyc_city_jobs())
