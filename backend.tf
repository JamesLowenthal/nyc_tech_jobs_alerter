terraform {
  backend "remote" {
    organization = "NYCJobsDataAlerter"
    workspaces {
      name = "nyc_tech_jobs_alerter"
    }
  }
}
