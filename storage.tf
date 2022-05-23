# Storage bucket
resource "google_storage_bucket" "store-cmbench" {
  name          = var.objectstore.bucket
  location      = var.objectstore.location
  storage_class = var.objectstore.class
  uniform_bucket_level_access = true

  force_destroy = false

  versioning {
    enabled = false 
  }

  logging {
    log_bucket = false
  }
}
