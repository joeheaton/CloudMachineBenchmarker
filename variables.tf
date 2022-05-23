provider "google" {
  project   = var.gcp_project
  region    = var.gcp_region
  zone      = var.gcp_zone
}

variable "gcp_project" {
  type = string
  description = "Google Cloud project"
}

variable "gcp_region" {
  type = string
  description = "Google Cloud region"
  default = "europe-west1"
}

variable "gcp_zone" {
  type = string
  description = "Google Cloud zone"
  default = "europe-west1-b"
}

variable "prefix" {
  type = string
  default = "cmbench"
}

variable "api_enable" {
  type = list(string)
  default = [
    #"osconfig.googleapis.com",  # OpsAgent Module
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "storage.googleapis.com",
    "storage-component.googleapis.com",
    "bigquery.googleapis.com",
    "bigqueryconnection.googleapis.com"
  ]
}

variable "objectstore" {
  type = object({
    bucket        = string
    class         = string
    location      = string
  })
  default = {
    bucket        = "SET_YOUR_BUCKET"
    class         = "REGIONAL"
    location      = "europe-west4"
  }
}
