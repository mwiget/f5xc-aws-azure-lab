output "output" {
  value = {
    "public_ip"   = google_compute_instance.compute.attributes.network_interfaces[0].access_config[0].nat_ip
    #    "private_ip"  = google_compute_instance.compute.private_ip_address
  }
}
