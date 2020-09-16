provider "google" {
  project = "vvv-test-100001"
  region  = "us-central1"
}

### Variables for hyding security keys
variable "api" {}
variable "app" {}

#################################################################
# Terraform backend GCS

data "terraform_remote_state" "my_gcs_backend" {
  backend = "gcs"
  config = {
    bucket = "terraform-gvi"
    prefix = "tfstate"
  }
}

resource "google_compute_address" "int_datadog_ip" {
  name         = "internal-datadog-ip"
  subnetwork   = google_compute_subnetwork.public.id
  address_type = "INTERNAL"
}


#################################################################
#  Creating VPC network


resource "google_compute_network" "vpc_network" {
  name                    = "datadog-vpc"
  description             = "datadog-vpc-network"
  auto_create_subnetworks = false
}


#################################################################
# Creating subnetworks

resource "google_compute_subnetwork" "public" {
  name          = "public-subnetwork"
  ip_cidr_range = "10.12.1.0/24"
  network       = google_compute_network.vpc_network.id
  description   = "vgulinkiy-public subnetwork"
  region        = "us-central1"
}

#################################################################
#  Creating firewalls rules

resource "google_compute_firewall" "external_access_jump" {
  name    = "vgulinskiy-ext-firewall-jump"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "icmp"
  }

  #source_tags = ["jump"]
  target_tags = ["datadog"]

}


##################################################################
# datadog-agent1

resource "google_compute_instance" "datadog1" {
  name                      = "datadog1"
  machine_type              = "custom-1-4608"
  zone                      = "us-central1-c"
  allow_stopping_for_update = true
  #int_ip                    = "int_zabbix_ip"

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-7"
      size  = "30"
      type  = "pd-ssd"
    }
  }

  network_interface {
    network    = "datadog-vpc"
    subnetwork = google_compute_subnetwork.public.id
    network_ip = google_compute_address.int_datadog_ip.address
    access_config {
      // Ephemeral IP
    }
  }

  tags = ["datadog"]
  metadata = {
    ssh-keys = "supreme888:${file("id_rsa.pub")}"
  }
  metadata_startup_script = templatefile("script.sh", {
    key1 = var.api

  })
}


# Configure the Datadog provider
provider "datadog" {
  api_key = var.api
  app_key = var.app
}

# Create a new dashboard
resource "datadog_timeboard" "cpu_usage_tf" {
  title       = "CPU Usage TF"
  description = "created using the Datadog provider in Terraform"
  read_only   = true

  graph {
    title = "CPU Usage TF"
    viz   = "timeseries"

    request {
      q    = "avg:system.cpu.user{*}"
      type = "lines"
    }
  }
}

### Monitor one metric
resource "datadog_monitor" "high_cpu_usage" {
  name               = "High CPU Usage TF"
  type               = "metric alert"
  message            = <<EOT
High CPU Usage
EOT
  escalation_message = ""

  query               = "max(last_5m):avg:system.cpu.user{*} > 85"
  notify_no_data      = false
  renotify_interval   = 0
  notify_audit        = false
  timeout_h           = 0
  include_tags        = true
  require_full_window = false
  new_host_delay      = 300

  thresholds = {
    ok                = 50
    warning           = 75
    warning_recovery  = 60
    critical          = 85
    critical_recovery = 80
  }

}

### Monitor httpd log
resource "datadog_monitor" "log_monitor" {
  name    = "log_monitor_tf"
  type    = "log alert"
  message = "@vvvsupremacy@gmail.com"


  query = "logs(\"Content*\").index(\"*\").rollup(\"count\").last(\"5m\") < 1"
}

### Monitor if tomcat is available
resource "datadog_monitor" "tomcat_monitor" {
  name    = "tomcat_monitor_tf"
  type    = "metric alert"
  message = "@vvvsupremacy@gmail.com"


  query = "avg(last_5m):avg:network.http.cant_connect{*} > 3"
}
