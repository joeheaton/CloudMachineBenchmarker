# Enable APIs: Service Networking
resource "google_project_service" "project" {
  for_each = toset(var.api_enable)
  project = var.gcp_project
  service = each.value

  disable_dependent_services = false
  disable_on_destroy = false
}
