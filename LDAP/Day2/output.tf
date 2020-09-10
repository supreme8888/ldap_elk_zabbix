output "External_ip_ldap_server" {
  value = google_compute_instance.ldap.network_interface.0.access_config.0.nat_ip
}

output "Internal_ip_server" {
  value = google_compute_instance.ldap.network_interface.0.network_ip
}

output "External_ip_client" {
  value = google_compute_instance.client.network_interface.0.access_config.0.nat_ip
}

output "Internal_ip_client" {
  value = google_compute_instance.client.network_interface.0.network_ip
}
