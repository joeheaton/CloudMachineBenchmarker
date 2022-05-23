# VPC Network
resource "google_compute_network" "net-cmbench" {
  name = "cmbench"
}

# Cloud NAT
resource "google_compute_router" "router" {
  name    = "net-router-cmbench"
  region  = var.gcp_region
  network = google_compute_network.net-cmbench.id
}

resource "google_compute_router_nat" "nat" {
  name                               = "net-nat-cmbench"
  router                             = google_compute_router.router.name
  region                             = var.gcp_region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# Firewall: Allow SSH from IAP
resource "google_compute_firewall" "fw-iap-to-cmbench" {
  name    = "fw-iap-to-cmbench"
  network = google_compute_network.net-cmbench.name
  description = "Allow IAP SSH to Compute"
  
  # SSH
  allow {
    protocol = "tcp"
    ports    = [22]
  }
  
  source_ranges = ["35.235.240.0/20"]
  target_tags = ["cmbench"]
}

# Firewall: SSH, HTTP/S
resource "google_compute_firewall" "fw-cmbench-internal" {
  name    = "fw-cmbench-internal"
  network = google_compute_network.net-cmbench.name

  # ICMP (ping)
  allow {
    protocol = "icmp"
  }

  # SSH, HTTP/S
  allow {
    protocol = "tcp"
    ports    = [22, 80, 443]
  }

  source_ranges = ["10.0.0.0/8"]
  target_tags   = ["cmbench"]
}
