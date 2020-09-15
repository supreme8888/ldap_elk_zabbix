output "External_ip_elk_server" {
  value = google_compute_instance.zabbix.network_interface.0.access_config.0.nat_ip
}

output "Internal_ip_elk" {
  value = google_compute_instance.zabbix.network_interface.0.network_ip
}

output "External_ip_client" {
  value = google_compute_instance.zagent.network_interface.0.access_config.0.nat_ip
}

output "Internal_ip_client" {
  value = google_compute_instance.zagent.network_interface.0.network_ip
}

output "External_ip_nginx" {
  value = google_compute_instance.ldap.network_interface.0.access_config.0.nat_ip
}
