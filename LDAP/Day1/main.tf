provider "google" {
  project = "vvv-test-100001"
  region  = "us-central1"
}

#################################################################
# Terraform backend GCS

data "terraform_remote_state" "my_gcs_backend" {
  backend = "gcs"
  config = {
    bucket = "terraform-gvi"
    prefix = "tfstate"
  }
}


#################################################################
#  Creating VPC network


resource "google_compute_network" "vpc_network" {
  name                    = "ldap-vpc"
  description             = "ldap-vpc-network"
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
    ports    = ["22", "80", "443"]
  }
  allow {
    protocol = "icmp"
  }

  #source_tags = ["jump"]
  target_tags = ["ldap"]

}


##################################################################
# LDAP-server

resource "google_compute_instance" "ldap" {
  name                      = "ldap"
  machine_type              = "custom-1-4608"
  zone                      = "us-central1-c"
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-7"
      size  = "35"
      type  = "pd-ssd"
    }
  }

  network_interface {
    network    = "ldap-vpc"
    subnetwork = google_compute_subnetwork.public.id
    access_config {
      // Ephemeral IP
    }
  }

  tags = ["ldap"]
  metadata = {
    ssh-keys = "supreme888:${file("id_rsa.pub")}"
  }
  metadata_startup_script = templatefile("script.sh", {
    name    = "vvv"
    surname = "vvv"
  })

}
