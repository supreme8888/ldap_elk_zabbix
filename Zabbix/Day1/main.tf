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

resource "google_compute_address" "int_zabbix_ip" {
  name         = "internal-zabbix-ip"
  subnetwork   = google_compute_subnetwork.public.id
  address_type = "INTERNAL"
}

resource "google_compute_address" "int_zagent_ip" {
  name         = "internal-zagent-ip"
  subnetwork   = google_compute_subnetwork.public.id
  address_type = "INTERNAL"
}

#################################################################
#  Creating VPC network


resource "google_compute_network" "vpc_network" {
  name                    = "zabbix-vpc"
  description             = "zabbix-vpc-network"
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
  target_tags = ["zabbix"]

}


##################################################################
# zabbix-server

resource "google_compute_instance" "zabbix" {
  name                      = "zabbix"
  machine_type              = "custom-2-9216"
  zone                      = "us-central1-c"
  allow_stopping_for_update = true
  #int_ip                    = "int_zabbix_ip"

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-7"
      size  = "35"
      type  = "pd-ssd"
    }
  }

  network_interface {
    network    = "zabbix-vpc"
    subnetwork = google_compute_subnetwork.public.id
    network_ip = google_compute_address.int_zabbix_ip.address
    access_config {
      // Ephemeral IP
    }
  }

  tags = ["zabbix"]
  metadata = {
    ssh-keys = "supreme888:${file("id_rsa.pub")}"
  }
  metadata_startup_script = templatefile("script.sh", {
    zabbix_ip = google_compute_address.int_zabbix_ip.address
    surname   = "vvv"
  })
}


##################################################################
# zabbix-agent

resource "google_compute_instance" "zagent" {
  name                      = "zagent"
  machine_type              = "custom-1-4608"
  zone                      = "us-central1-c"
  allow_stopping_for_update = true
  #ldap_ip                   = var.Internal_ip_server

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-7"
      size  = "20"
      type  = "pd-ssd"
    }
  }

  network_interface {
    network    = "zabbix-vpc"
    subnetwork = google_compute_subnetwork.public.id
    network_ip = google_compute_address.int_zagent_ip.address

    access_config {
      // Ephemeral IP
    }
  }

  tags = ["zabbix"]
  metadata = {
    ssh-keys = "supreme888:${file("id_rsa.pub")}"
  }
  metadata_startup_script = templatefile("script1.sh", {
    zabbix_ip = google_compute_address.int_zagent_ip.address
    #zabbix_ip = google_compute_instance.zabbix.network_interface.0.network_ip
  })

}
