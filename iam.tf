# Create service account to run service with no permissions
resource "google_service_account" "sa-cmbench" {
  account_id   = "cmbench"
  display_name = "Cloud Machine Benchmarker"
}

# IAM for Compute self-destruct
resource "google_project_iam_member" "compute_instanceAdmin" {
  project = var.gcp_project
  role    = "roles/compute.instanceAdmin"
  member  = "serviceAccount:cmbench@${var.gcp_project}.iam.gserviceaccount.com"
}

# IAM for Compute self-destruct
resource "google_project_iam_member" "storage" {
  for_each = toset(["roles/storage.objectCreator", "roles/storage.objectViewer"])
  project = var.gcp_project
  role    = each.value
  member  = "serviceAccount:cmbench@${var.gcp_project}.iam.gserviceaccount.com"
}
