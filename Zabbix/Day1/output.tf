output "External_ip_zabbix_server" {
  value = google_compute_instance.zabbix.network_interface.0.access_config.0.nat_ip
}

output "Internal_ip_zabbix_server" {
  value = google_compute_instance.zabbix.network_interface.0.network_ip
}

output "External_ip_zagent" {
  value = google_compute_instance.zagent.network_interface.0.access_config.0.nat_ip
}

output "Internal_ip_zagent" {
  value = google_compute_instance.zagent.network_interface.0.network_ip
}
