module "azure_site_1a" {
  count = var.enable_site["azure_site_1a"] ? 1 : 0
  source                         = "./modules/f5xc/site/azure"
  f5xc_namespace                 = "system"
  f5xc_tenant                    = "playground-wtppvaog"
  f5xc_azure_cred                = "sun-az-creds"
  f5xc_azure_region              = "westus2"
  f5xc_azure_site_name           = "mw-azure-site-1a"
  f5xc_azure_vnet_resource_group = module.azure_resource_group_1.name
  f5xc_azure_vnet_local          = module.azure_vnet_1.name
  custom_tags                     = { "site_mesh_group" = "f5xc-aws-azure-lab" }
  f5xc_azure_ce_gw_type          = "single_nic"
  f5xc_azure_az_nodes            = {
    node0 : { f5xc_azure_az = "1", f5xc_azure_vnet_local_subnet = module.azure_subnet_1a.name }
  }
  f5xc_azure_default_blocked_services = false
  f5xc_azure_default_ce_sw_version    = true
  f5xc_azure_default_ce_os_version    = true
  f5xc_azure_no_worker_nodes          = true
  f5xc_azure_total_worker_nodes       = 0
  public_ssh_key                      = "${file(var.ssh_public_key_file)}"
} 

module "azure_site_1b" {
  count = var.enable_site["azure_site_1b"] ? 1 : 0
  source                         = "./modules/f5xc/site/azure"
  f5xc_namespace                 = "system"
  f5xc_tenant                    = "playground-wtppvaog"
  f5xc_azure_cred                = "sun-az-creds"
  f5xc_azure_region              = "westus2"
  f5xc_azure_site_name           = "mw-azure-site-1b"
  f5xc_azure_vnet_resource_group = module.azure_resource_group_1.name
  f5xc_azure_vnet_local          = module.azure_vnet_1.name
  custom_tags                     = { "site_mesh_group" = "f5xc-aws-azure-lab" }
  f5xc_azure_ce_gw_type          = "single_nic"
  f5xc_azure_az_nodes            = {
    node0 : { f5xc_azure_az = "2", f5xc_azure_vnet_local_subnet = module.azure_subnet_1b.name }
  }
  f5xc_azure_default_blocked_services = false
  f5xc_azure_default_ce_sw_version    = true
  f5xc_azure_default_ce_os_version    = true
  f5xc_azure_no_worker_nodes          = true
  f5xc_azure_total_worker_nodes       = 0
  public_ssh_key                      = "${file(var.ssh_public_key_file)}"
} 

module "site_status_check_1a" {
  count = var.enable_site["azure_site_1a"] ? 1 : 0
  source            = "./modules/f5xc/status/site"
  f5xc_api_url      = "https://playground.staging.volterra.us/api"
  f5xc_api_token    = var.f5xc_api_token
  f5xc_namespace    = "system"
  f5xc_tenant       = "playground-wtppvaog"
  f5xc_site_name    = "mw-azure-site-1a"
  depends_on        = [module.azure_site_1a]
}
module "site_status_check_1b" {
  count = var.enable_site["azure_site_1b"] ? 1 : 0
  source            = "./modules/f5xc/status/site"
  f5xc_api_url      = "https://playground.staging.volterra.us/api"
  f5xc_api_token    = var.f5xc_api_token
  f5xc_namespace    = "system"
  f5xc_tenant       = "playground-wtppvaog"
  f5xc_site_name    = "mw-azure-site-1b"
  depends_on        = [module.azure_site_1b]
}

module "azure_resource_group_1" {
  source              = "./modules/azure/resource_group"
  resource_group_name = "mw-azure-site1"
  azure_region        = "westus2"
}

module "azure_vnet_1" {
  source                  = "./modules/azure/virtual_network"
  azure_vnet_name         = "mw-vnet1"
  azure_vnet_primary_ipv4 = "100.64.16.0/22"
  resource_group_name     = module.azure_resource_group_1.name
  azure_region            = module.azure_resource_group_1.location
}

module "azure_subnet_1a" {
  name                    = "mw-subnet-1a"
  source                  = "./modules/azure/subnet"
  address_prefix          = "100.64.16.0/24"
  azure_vnet_name         = module.azure_vnet_1.name
  resource_group_name     = module.azure_resource_group_1.name
}

module "azure_subnet_1b" {
  name                    = "mw-subnet-1b"
  source                  = "./modules/azure/subnet"
  address_prefix          = "100.64.17.0/24"
  azure_vnet_name         = module.azure_vnet_1.name
  resource_group_name     = module.azure_resource_group_1.name
}

module "azure_workload_1a" {
  source                  = "./modules/azure/virtual_machine"
  name                    = "mw-workload-1a"
  size                    = "Standard_DS1_v2"
  zone                    = 1
  subnet_id               = module.azure_subnet_1a.id
  username                = "azureuser"
  ssh_key                 = "${file(var.ssh_public_key_file)}"
  custom_data             = "${filebase64("./workload_custom_data.sh")}"
  resource_group_name     = module.azure_resource_group_1.name
  azure_region            = module.azure_resource_group_1.location
}

module "azure_workload_1b" {
  source                  = "./modules/azure/virtual_machine"
  name                    = "mw-workload-1b"
  size                    = "Standard_DS1_v2"
  zone                    = 2
  subnet_id               = module.azure_subnet_1b.id
  username                = "azureuser"
  ssh_key                 = "${file(var.ssh_public_key_file)}"
  custom_data             = "${filebase64("./workload_custom_data.sh")}"
  resource_group_name     = module.azure_resource_group_1.name
  azure_region            = module.azure_resource_group_1.location
}

output "azure_resource_group_1_name" {
  value = module.azure_resource_group_1.name
}
output "azure_resource_group_1_location" {
  value = module.azure_resource_group_1.location
}

output "azure_vnet_1" {
  value = module.azure_vnet_1.output
}
output "azure_vnet_subnet_1a" {
  value = module.azure_subnet_1a.output
}
output "azure_vnet_subnet_1b" {
  value = module.azure_subnet_1b.output
}

output "azure_workload_1a" {
  value = module.azure_workload_1a.output
}
output "azure_workload_1b" {
  value = module.azure_workload_1b.output
}
