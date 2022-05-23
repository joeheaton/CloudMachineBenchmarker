# Machine types
locals {
  machines = {
    "e2-standard-4"  = {
        type                = "e2-standard-4"
        cpu_platform        = null
        threads_per_core    = 2
    }
}

# Random string
resource "random_string" "rand-compute" {
  length = 6
  special = false
  upper   = false
  keepers = {
    # New rand-compute on every run
    first = "${timestamp()}"
  } 
}

# Compute instances
resource "google_compute_instance" "compute-cmbench" {
  for_each     = local.machines
  name         = "${var.prefix}-${each.key}-${random_string.rand-compute.result}"
  description  = "Cloud Machine Benchmarker compute"
  tags         = ["cmbench"]
  labels = {
    "cmbench_type" = "compute"
    "cmbench_id"   = random_string.rand-compute.result
  }

  machine_type = each.value.type
  min_cpu_platform = each.value.cpu_platform

  advanced_machine_features {
      threads_per_core = each.value.threads_per_core  # 1 disables SMT
  }

  metadata_startup_script = <<-EOT
set -x

# Store results in 
DATETIME="$(date '+%Y%m%dT%H%M%S%Z')"
RESULTS="/tmp/results/$${DATETIME}/"
mkdir -pv $RESULTS

# Updates
apt-get update
apt-get dist-upgrade -y
apt-get install -y curl

# Google Cloud Ops Agent
curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
bash add-google-cloud-ops-agent-repo.sh --also-install

#
# Edit below
#


#
# Don't edit below
#

# Save results
gsutil -m rsync -r /tmp/results/ gs://${var.objectstore.bucket}/

# Self-destruct instance
export COMPUTE_NAME=$(curl -X GET http://metadata.google.internal/computeMetadata/v1/instance/name -H 'Metadata-Flavor: Google')
export COMPUTE_ZONE=$(curl -X GET http://metadata.google.internal/computeMetadata/v1/instance/zone -H 'Metadata-Flavor: Google')
gcloud --quiet compute instances delete $${COMPUTE_NAME} --zone=$${COMPUTE_ZONE}

  EOT
  #/ End of metadata_startup_script

  metadata = {
    enable-oslogin = "TRUE"
    google-logging-enabled = true
  }

  boot_disk {
    auto_delete = true
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  network_interface {
    network = google_compute_network.net-cmbench.name
  }

  service_account {
    email  = google_service_account.sa-cmbench.email
    scopes = ["cloud-platform"]
  }

  scheduling {
    preemptible       = true
    automatic_restart = false
  }

  lifecycle {
    create_before_destroy = true
  }
}

output "compute-cmbench-id" {
  value = random_string.rand-compute.id
  description = "Instance ID"
}

output "compute-machinetypes" {
  value = local.machines
  description = "Machine types"
}
