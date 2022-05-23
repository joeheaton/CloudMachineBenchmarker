terraform {
  backend "gcs" {
    prefix = "cloud-machine-benchmarker/state"
    bucket = SET_YOUR_BUCKET
  }
}
