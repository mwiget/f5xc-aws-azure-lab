resource "google_compute_network" "vpc" {
  name                    =  var.name
  auto_create_subnetworks = "false"
  routing_mode            = "REGIONAL"
}

resource "google_compute_firewall" "allow-internal" {
  name    = "${var.name}-fw-allow-internal"
  network = google_compute_network.vpc.name
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  source_ranges = [
    var.inside_subnet_cidr_block,
    var.outside_subnet_cidr_block
  ]
}
resource "google_compute_firewall" "allow-http" {
  name    = "${var.name}-fw-allow-http"
  network = google_compute_network.vpc.name
  allow {
    protocol = "tcp"
    ports    = ["80","8080"]
  }
  source_ranges = var.allow_cidr_blocks
  target_tags = ["http"] 
}

resource "google_compute_route" "vip" {
  name        = "network-route"
  dest_range  = var.allow_cidr_blocks[0]
  network     = google_compute_network.vpc.name
  next_hop_instance = regex("mwlab-gcp-\\w+-\\w+",module.site.output.tf_output)
  next_hop_instance_zone = var.gcp_az_name
  priority    = 100
  depends_on        = [module.site]
}

resource "google_compute_firewall" "allow-ssh" {
  name    = "${var.name}-fw-allow-bastion"
  network = google_compute_network.vpc.name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = [ "0.0.0.0/0" ]
  target_tags = ["ssh"]
}

resource "google_compute_subnetwork" "outside_subnet" {
  name          =  "${var.name}-outside"
  ip_cidr_range = var.outside_subnet_cidr_block
  network       = google_compute_network.vpc.self_link
  region        = var.gcp_region
}

resource "google_compute_subnetwork" "inside_subnet" {
  name          =  "${var.name}-inside"
  ip_cidr_range = var.inside_subnet_cidr_block
  network       = google_compute_network.vpc.self_link
  region        = var.gcp_region
}

resource "google_compute_instance" "workload" {
  name = var.name
  machine_type  = "n1-standard-1"
  zone          = var.gcp_az_name
  tags          = ["ssh","http"]
  boot_disk {
    initialize_params {
      image     =  "ubuntu-os-cloud/ubuntu-1804-lts"
    }
  }
  labels = {
    webserver =  "true"     
  }
  metadata =  {
    startup-script = var.workload_user_data
    ssh-keys = "ubuntu:${file(var.ssh_public_key_file)}"
  }
  network_interface {
    subnetwork = google_compute_subnetwork.inside_subnet.name
    access_config {
      // Ephemeral IP
    }
  }
}

module "site" {
  source                            = "../mymodules/f5xc/site/gcp"
  f5xc_namespace                    = "system"
  f5xc_gcp_site_name                = var.name
  f5xc_gcp_ce_gw_type               = "multi_nic"
  f5xc_gcp_default_ce_sw_version    = true
  custom_tags                       = var.custom_tags
  f5xc_gcp_inside_network_name      = google_compute_network.vpc.name
  f5xc_gcp_inside_subnet_name       = google_compute_subnetwork.inside_subnet.name
  f5xc_gcp_outside_primary_ipv4     = var.outside_subnet_cidr_block
  f5xc_gcp_node_number              = 1
  f5xc_gcp_default_blocked_services = true
  f5xc_gcp_default_ce_os_version    = true
  f5xc_gcp_region                   = var.gcp_region
  f5xc_gcp_zone_names               = [var.gcp_az_name]
  f5xc_tenant                       = var.f5xc_tenant
  f5xc_gcp_cred                     = var.f5xc_gcp_cred
  public_ssh_key                    = file(var.ssh_public_key_file)
}

module "site_status_check" {
  source            = "../mymodules/f5xc/status/site"
  f5xc_namespace    = "system"
  f5xc_site_name    = var.name
  f5xc_tenant       = var.f5xc_tenant
  f5xc_api_url      = var.f5xc_api_url
  f5xc_api_token    = var.f5xc_api_token
  depends_on        = [module.site]
}

output "site" {
  value = module.site.output.tf_output
}

output "workload" {
  value = {
    "public_ip" = resource.google_compute_instance.workload.network_interface[0].access_config[0].nat_ip 
    "private_ip" = resource.google_compute_instance.workload.network_interface[0].network_ip
  }
}
