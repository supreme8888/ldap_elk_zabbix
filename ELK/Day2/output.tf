output "External_ip_elk_server" {
  value = google_compute_instance.elk.network_interface.0.access_config.0.nat_ip
}

output "Internal_ip_elk" {
  value = google_compute_instance.elk.network_interface.0.network_ip
}

output "External_ip_client" {
  value = google_compute_instance.elk_client.network_interface.0.access_config.0.nat_ip
}

output "Internal_ip_client" {
  value = google_compute_instance.elk_client.network_interface.0.network_ip
}
