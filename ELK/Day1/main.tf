provider "google" {
  project = "vvv-test-100001"
  region  = "us-central1"
}

#variable "ldap_ip" {
#}

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
  name                    = "elk-vpc"
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
  target_tags = ["elk"]

}


##################################################################
# LDAP-server

resource "google_compute_instance" "elk" {
  name                      = "elk"
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
    network    = "elk-vpc"
    subnetwork = google_compute_subnetwork.public.id
    access_config {
      // Ephemeral IP
    }
  }

  tags = ["elk"]
  metadata = {
    ssh-keys = "supreme888:${file("id_rsa.pub")}"
  }
  metadata_startup_script = templatefile("script.sh", {
    name    = "vvv"
    surname = "vvv"
  })
}


##################################################################
# LDAP-client

resource "google_compute_instance" "elk_client" {
  name                      = "client"
  machine_type              = "custom-1-4608"
  zone                      = "us-central1-c"
  allow_stopping_for_update = true
  #ldap_ip                   = var.Internal_ip_server

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-7"
      size  = "50"
      type  = "pd-ssd"
    }
  }

  network_interface {
    network    = "elk-vpc"
    subnetwork = google_compute_subnetwork.public.id
    access_config {
      // Ephemeral IP
    }
  }

  tags = ["elk"]
  metadata = {
    ssh-keys = "supreme888:${file("id_rsa.pub")}"
  }
  #metadata_startup_script = templatefile("script1.sh", {
  #  ldap_ip = google_compute_instance.ldap.network_interface.0.network_ip
  #  surname = "vvv"
  #})

}
