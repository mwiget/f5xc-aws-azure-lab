resource "volterra_namespace" "ns" {
  name = "mwlab-aws-azure"
}

module "smg" {
  source                      = "./mymodules/f5xc/site-mesh"
  f5xc_api_p12_file           = "cert/playground.staging.api-creds.p12"
  f5xc_api_ca_cert            = "cert/public_server_ca.crt"
  f5xc_api_url                = "https://playground.staging.volterra.us/api"
  f5xc_namespace              = "system"
  f5xc_tenant                 = "playground-wtppvaog"
  f5xc_virtual_site_name      = "mwlab-aws-azure"
  f5xc_site_mesh_group_name   = "mwlab-aws-azure"
  virtual_site_selector       = [ "site_mesh_group in (mwlab-aws-azure)" ]
}

module "azure-site-1a" {
  count                       = 1
  source                      = "./azure"
  azure_region                = "westus2"
  azure_az                    = "1"
  name                        = "mwlab-azure-1a"
  vnet_cidr_block             = "10.64.16.0/22"
  outside_subnet_cidr_block   = "10.64.16.0/24"
  inside_subnet_cidr_block    = "10.64.17.0/24"
  allow_cidr_blocks           = [ "10.64.15.0/24" ]
  custom_tags                 = { "site_mesh_group" = "mwlab-aws-azure" }
  workload_user_data          = templatefile(var.workload_user_data_file, { tailscale_key = var.tailscale_key, tailscale_hostname = "mwlab-azure-1a-workload", grafana_agent_stack_id = var.grafana_agent_stack_id, grafana_api_key = var.grafana_api_key, grafana_api_url = var.grafana_api_url })
  f5xc_azure_cred             = var.f5xc_azure_cred
  f5xc_tenant                 = var.f5xc_tenant
  f5xc_api_url                = var.f5xc_api_url
  f5xc_api_token              = var.f5xc_api_token
  owner_tag                   = var.owner_tag
}

module "azure-site-1b" {
  count                       = 1
  source                      = "./azure"
  azure_region                = "westus2"
  azure_az                    = "2"
  name                        = "mwlab-azure-1b"
  vnet_cidr_block             = "10.64.16.0/22"
  outside_subnet_cidr_block   = "10.64.16.0/24"
  inside_subnet_cidr_block    = "10.64.17.0/24"
  allow_cidr_blocks           = [ "10.64.15.0/24" ]
  custom_tags                 = { "site_mesh_group" = "mwlab-aws-azure" }
  workload_user_data          = templatefile(var.workload_user_data_file, { tailscale_key = var.tailscale_key, tailscale_hostname = "mwlab-azure-1b-workload", grafana_agent_stack_id = var.grafana_agent_stack_id, grafana_api_key = var.grafana_api_key, grafana_api_url = var.grafana_api_url })
  f5xc_azure_cred             = var.f5xc_azure_cred
  f5xc_tenant                 = var.f5xc_tenant
  f5xc_api_url                = var.f5xc_api_url
  f5xc_api_token              = var.f5xc_api_token
  owner_tag                   = var.owner_tag
}

module "aws-site-2a" {
  count                       = 1
  source                      = "./aws"
  providers                   = { aws = aws.eu_north_1 }
  aws_region                  = "eu-north-1"
  aws_az_name                 = "eu-north-1a"
  name                        = "mwlab-aws-2a"
  vpc_cidr_block              = "10.64.16.0/22"
  outside_subnet_cidr_block   = "10.64.16.0/24"
  inside_subnet_cidr_block    = "10.64.17.0/24"
  workload_subnet_cidr_block  = "10.64.18.0/24"
  allow_cidr_blocks           = [ "10.64.0.0/16" ]
  custom_tags                 = { "site_mesh_group" = "mwlab-aws-azure" }
  workload_user_data          = templatefile(var.workload_user_data_file, { tailscale_key = var.tailscale_key, tailscale_hostname = "mwlab-aws-2a-workload", grafana_agent_stack_id = var.grafana_agent_stack_id, grafana_api_key = var.grafana_api_key, grafana_api_url = var.grafana_api_url })
  f5xc_tenant                 = var.f5xc_tenant
  f5xc_api_url                = var.f5xc_api_url
  f5xc_api_token              = var.f5xc_api_token
  f5xc_aws_cred               = var.f5xc_aws_cred
  owner_tag                   = var.owner_tag
}

module "aws-site-2b" {
  count                       = 1
  source                      = "./aws"
  providers                   = { aws = aws.eu_north_1 }
  aws_region                  = "eu-north-1"
  aws_az_name                 = "eu-north-1b"
  name                        = "mwlab-aws-2b"
  vpc_cidr_block              = "10.64.16.0/22"
  outside_subnet_cidr_block   = "10.64.16.0/24"
  inside_subnet_cidr_block    = "10.64.17.0/24"
  workload_subnet_cidr_block  = "10.64.18.0/24"
  allow_cidr_blocks           = [ "10.64.0.0/16" ]
  custom_tags                 = { "site_mesh_group" = "mwlab-aws-azure" }
  workload_user_data          = templatefile(var.workload_user_data_file, { tailscale_key = var.tailscale_key, tailscale_hostname = "mwlab-aws-2b-workload", grafana_agent_stack_id = var.grafana_agent_stack_id, grafana_api_key = var.grafana_api_key, grafana_api_url = var.grafana_api_url })
  f5xc_tenant                 = var.f5xc_tenant
  f5xc_api_url                = var.f5xc_api_url
  f5xc_api_token              = var.f5xc_api_token
  f5xc_aws_cred               = var.f5xc_aws_cred
  owner_tag                   = var.owner_tag
}

module "gcp-site-3a" {
  count                       = 1
  source                      = "./gcp"
  providers                   = { google = google.europe_west6 }
  gcp_region                  = "europe-west6"
  gcp_az_name                 = "europe-west6-a"
  name                        = "mwlab-gcp-3a"
  network_cidr_block          = "10.64.16.0/22"
  outside_subnet_cidr_block   = "10.64.16.0/24"
  inside_subnet_cidr_block    = "10.64.17.0/24"
  allow_cidr_blocks           = [ "10.64.15.0/24" ]
  custom_tags                 = { "site_mesh_group" = "mwlab-aws-azure" }
  workload_user_data          = templatefile(var.workload_user_data_file, { tailscale_key = var.tailscale_key, tailscale_hostname = "mwlab-gcp-3a-workload", grafana_agent_stack_id = var.grafana_agent_stack_id, grafana_api_key = var.grafana_api_key, grafana_api_url = var.grafana_api_url })
  f5xc_tenant                 = var.f5xc_tenant
  f5xc_api_url                = var.f5xc_api_url
  f5xc_api_token              = var.f5xc_api_token
  f5xc_gcp_cred               = var.f5xc_gcp_cred
  owner_tag                   = var.owner_tag
}

module "gcp-site-3b" {
  count                       = 1
  source                      = "./gcp"
  providers                   = { google = google.europe_west6 }
  gcp_region                  = "europe-west6"
  gcp_az_name                 = "europe-west6-b"
  name                        = "mwlab-gcp-3b"
  network_cidr_block          = "10.64.16.0/22"
  outside_subnet_cidr_block   = "10.64.16.0/24"
  inside_subnet_cidr_block    = "10.64.17.0/24"
  allow_cidr_blocks           = [ "10.64.15.0/24" ]
  custom_tags                 = { "site_mesh_group" = "mwlab-aws-azure" }
  workload_user_data          = templatefile(var.workload_user_data_file, { tailscale_key = var.tailscale_key, tailscale_hostname = "mwlab-gcp-3b-workload", grafana_agent_stack_id = var.grafana_agent_stack_id, grafana_api_key = var.grafana_api_key, grafana_api_url = var.grafana_api_url })
  f5xc_tenant                 = var.f5xc_tenant
  f5xc_api_url                = var.f5xc_api_url
  f5xc_api_token              = var.f5xc_api_token
  f5xc_gcp_cred               = var.f5xc_gcp_cred
  owner_tag                   = var.owner_tag
}

output "azure-site-1a" {
  value = module.azure-site-1a
}
output "azure-site-1b" {
  value = module.azure-site-1b
}

output "aws-site-2a" {
  value = module.aws-site-2a
}
output "aws-site-2b" {
  value = module.aws-site-2b
}

output "gcp-site-3a" {
  value = module.gcp-site-3a
}
output "gcp-site-3b" {
  value = module.gcp-site-3b
}

