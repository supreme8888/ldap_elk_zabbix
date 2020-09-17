output "External_ip_datadog_agent" {
  value = google_compute_instance.prometheus.network_interface.0.access_config.0.nat_ip
}

output "Internal_ip_datadog" {
  value = google_compute_instance.prometheus.network_interface.0.network_ip
}
