module "azure_site_2a" {
  count = var.enable_site["azure_site_2a"] ? 1 : 0
  source                         = "./modules/f5xc/site/azure"
  f5xc_namespace                 = "system"
  f5xc_tenant                    = "playground-wtppvaog"
  f5xc_azure_cred                = "sun-az-creds"
  f5xc_azure_region              = "eastus"
  f5xc_azure_site_name           = "mw-azure-site-2a"
  f5xc_azure_vnet_resource_group = module.azure_resource_group_2.name
  f5xc_azure_vnet_local          = module.azure_vnet_2.name
  custom_tags                    = { "site_mesh_group" = "f5xc-aws-azure-lab" }
  f5xc_azure_ce_gw_type          = "single_nic"
  f5xc_azure_az_nodes            = {
    node0 : { f5xc_azure_az = "1", f5xc_azure_vnet_local_subnet = module.azure_subnet_2a.name }
  }
  f5xc_azure_default_blocked_services = false
  f5xc_azure_default_ce_sw_version    = true
  f5xc_azure_default_ce_os_version    = true
  f5xc_azure_no_worker_nodes          = true
  f5xc_azure_total_worker_nodes       = 0
  public_ssh_key                      = "${file(var.ssh_public_key_file)}"
} 

module "azure_site_2b" {
  count = var.enable_site["azure_site_2b"] ? 1 : 0
  source                         = "./modules/f5xc/site/azure"
  f5xc_namespace                 = "system"
  f5xc_tenant                    = "playground-wtppvaog"
  f5xc_azure_cred                = "sun-az-creds"
  f5xc_azure_region              = "eastus"
  f5xc_azure_site_name           = "mw-azure-site-2b"
  f5xc_azure_vnet_resource_group = module.azure_resource_group_2.name
  f5xc_azure_vnet_local          = module.azure_vnet_2.name
  custom_tags                    = { "site_mesh_group" = "f5xc-aws-azure-lab" }
  f5xc_azure_ce_gw_type          = "single_nic"
  f5xc_azure_az_nodes            = {
    node0 : { f5xc_azure_az = "1", f5xc_azure_vnet_local_subnet = module.azure_subnet_2b.name }
  }
  f5xc_azure_default_blocked_services = false
  f5xc_azure_default_ce_sw_version    = true
  f5xc_azure_default_ce_os_version    = true
  f5xc_azure_no_worker_nodes          = true
  f5xc_azure_total_worker_nodes       = 0
  public_ssh_key                      = "${file(var.ssh_public_key_file)}"
} 

module "site_status_check_2a" {
  count = var.enable_site["azure_site_2a"] ? 1 : 0
  source            = "./modules/f5xc/status/site"
  f5xc_api_url      = "https://playground.staging.volterra.us/api"
  f5xc_api_token    = var.f5xc_api_token
  f5xc_namespace    = "system"
  f5xc_tenant       = "playground-wtppvaog"
  f5xc_site_name    = "mw-azure-site-2a"
  depends_on        = [module.azure_site_2a]
}

module "site_status_check_2b" {
  count = var.enable_site["azure_site_2b"] ? 1 : 0
  source            = "./modules/f5xc/status/site"
  f5xc_api_url      = "https://playground.staging.volterra.us/api"
  f5xc_api_token    = var.f5xc_api_token
  f5xc_namespace    = "system"
  f5xc_tenant       = "playground-wtppvaog"
  f5xc_site_name    = "mw-azure-site-2b"
  depends_on        = [module.azure_site_2b]
}

module "azure_resource_group_2" {
  source              = "./modules/azure/resource_group"
  resource_group_name = "mw-azure-site2"
  azure_region        = "eastus"
}

module "azure_vnet_2" {
  source                  = "./modules/azure/virtual_network"
  azure_vnet_name         = "mw-vnet2"
  azure_vnet_primary_ipv4 = "100.64.16.0/22"
  resource_group_name     = module.azure_resource_group_2.name
  azure_region            = module.azure_resource_group_2.location
}

module "azure_subnet_2a" {
  name                    = "mw-subnet-2a"
  source                  = "./modules/azure/subnet"
  address_prefix          = "100.64.16.0/24"
  azure_vnet_name         = module.azure_vnet_2.name
  resource_group_name     = module.azure_resource_group_2.name
}

module "azure_subnet_2b" {
  name                    = "mw-subnet-2b"
  source                  = "./modules/azure/subnet"
  address_prefix          = "100.64.17.0/24"
  azure_vnet_name         = module.azure_vnet_2.name
  resource_group_name     = module.azure_resource_group_2.name
}

module "azure_workload_2a" {
  source                  = "./modules/azure/virtual_machine"
  name                    = "mw-workload-2a"
  size                    = "Standard_DS1_v2"
  zone                    = 1
  subnet_id               = module.azure_subnet_2a.id
  username                = "azureuser"
  ssh_key                 = "${file(var.ssh_public_key_file)}"
  custom_data             = "${filebase64("./workload_custom_data.sh")}"
  resource_group_name     = module.azure_resource_group_2.name
  azure_region            = module.azure_resource_group_2.location
}

module "azure_workload_2b" {
  source                  = "./modules/azure/virtual_machine"
  name                    = "mw-workload-2b"
  size                    = "Standard_DS1_v2"
  zone                    = 2
  subnet_id               = module.azure_subnet_2b.id
  username                = "azureuser"
  ssh_key                 = "${file(var.ssh_public_key_file)}"
  custom_data             = "${filebase64("./workload_custom_data.sh")}"
  resource_group_name     = module.azure_resource_group_2.name
  azure_region            = module.azure_resource_group_2.location
}

output "azure_resource_group_2_name" {
  value = module.azure_resource_group_2.name
}
output "azure_resource_group_2_location" {
  value = module.azure_resource_group_2.location
}

output "azure_vnet_2" {
  value = module.azure_vnet_2.output
}
output "azure_vnet_subnet_2a" {
  value = module.azure_subnet_2a.output
}
output "azure_vnet_subnet_2b" {
  value = module.azure_subnet_2b.output
}

output "azure_workload_2a" {
  value = module.azure_workload_2a.output
}
output "azure_workload_2b" {
  value = module.azure_workload_2b.output
}
