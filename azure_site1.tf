module "azure_site_1a" {
  count = var.enable_site["azure_site_1a"] ? 1 : 0
  source                         = "./modules/f5xc/site/azure"
  f5xc_namespace                 = "system"
  f5xc_tenant                    = "playground-wtppvaog"
  f5xc_azure_cred                = "sun-az-creds"
  f5xc_azure_region              = "westus2"
  f5xc_azure_site_name           = "mw-azure-site-1a"
  f5xc_azure_vnet_resource_group = module.azure_resource_group_1.name
  f5xc_azure_vnet                 = module.azure_vnet_1a.name
  custom_tags                     = { "site_mesh_group" = "f5xc-aws-azure-lab" }
  f5xc_azure_ce_gw_type          = "multi_nic"
  f5xc_azure_az_nodes            = {
    node0 : { f5xc_azure_az = "1", f5xc_azure_vnet_outside_subnet = module.azure_outside_subnet_1a.name, f5xc_azure_vnet_inside_subnet = module.azure_inside_subnet_1a.name }
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
  f5xc_azure_vnet                = module.azure_vnet_1b.name
  custom_tags                     = { "site_mesh_group" = "f5xc-aws-azure-lab" }
  f5xc_azure_ce_gw_type          = "multi_nic"
  f5xc_azure_az_nodes            = {
    node0 : { f5xc_azure_az = "2", f5xc_azure_vnet_outside_subnet = module.azure_outside_subnet_1b.name, f5xc_azure_vnet_inside_subnet = module.azure_inside_subnet_1b.name }
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

module "azure_vnet_1a" {
  source                  = "./modules/azure/virtual_network"
  azure_vnet_name         = "mw-vnet1a"
  azure_vnet_primary_ipv4 = "100.64.16.0/22"
  resource_group_name     = module.azure_resource_group_1.name
  azure_region            = module.azure_resource_group_1.location
}

module "azure_vnet_1b" {
  source                  = "./modules/azure/virtual_network"
  azure_vnet_name         = "mw-vnet1b"
  azure_vnet_primary_ipv4 = "100.64.16.0/22"
  resource_group_name     = module.azure_resource_group_1.name
  azure_region            = module.azure_resource_group_1.location
}

module "azure_outside_subnet_1a" {
  name                    = "mw-outside-subnet-1a"
  source                  = "./modules/azure/subnet"
  address_prefix          = "100.64.16.0/24"
  azure_vnet_name         = module.azure_vnet_1a.name
  resource_group_name     = module.azure_resource_group_1.name
}

module "azure_inside_subnet_1a" {
  name                    = "mw-inside-subnet-1a"
  source                  = "./modules/azure/subnet"
  address_prefix          = "100.64.17.0/24"
  azure_vnet_name         = module.azure_vnet_1a.name
  resource_group_name     = module.azure_resource_group_1.name
}

module "azure_outside_subnet_1b" {
  name                    = "mw-outside-subnet-1b"
  source                  = "./modules/azure/subnet"
  address_prefix          = "100.64.16.0/24"
  azure_vnet_name         = module.azure_vnet_1b.name
  resource_group_name     = module.azure_resource_group_1.name
}

module "azure_inside_subnet_1b" {
  name                    = "mw-inside-subnet-1b"
  source                  = "./modules/azure/subnet"
  address_prefix          = "100.64.17.0/24"
  azure_vnet_name         = module.azure_vnet_1b.name
  resource_group_name     = module.azure_resource_group_1.name
}

module "azure_workload_1a" {
  count = var.enable_site["azure_site_1a"] ? 1 : 0
  source                  = "./modules/azure/virtual_machine"
  name                    = "mw-workload-1a"
  size                    = "Standard_DS1_v2"
  zone                    = 1
  subnet_id               = module.azure_inside_subnet_1a.id
  username                = "azureuser"
  ssh_key                 = "${file(var.ssh_public_key_file)}"
  custom_data             = "${filebase64("./workload_custom_data.sh")}"
  resource_group_name     = module.azure_resource_group_1.name
  azure_region            = module.azure_resource_group_1.location
}

module "azure_workload_1b" {
  count = var.enable_site["azure_site_1b"] ? 1 : 0
  source                  = "./modules/azure/virtual_machine"
  name                    = "mw-workload-1b"
  size                    = "Standard_DS1_v2"
  zone                    = 2
  subnet_id               = module.azure_inside_subnet_1b.id
  username                = "azureuser"
  ssh_key                 = "${file(var.ssh_public_key_file)}"
  custom_data             = "${filebase64("./workload_custom_data.sh")}"
  resource_group_name     = module.azure_resource_group_1.name
  azure_region            = module.azure_resource_group_1.location
}

resource "azurerm_route_table" "vip1a" {
  name                = "workload_rt1a"
  location            = "westus2"
  resource_group_name = module.azure_resource_group_1.name
}

resource "azurerm_route_table" "vip1b" {
  name                = "workload_rt1b"
  location            = "westus2"
  resource_group_name = module.azure_resource_group_1.name
}

resource "azurerm_subnet_route_table_association" "vip1a" {
  subnet_id      = module.azure_inside_subnet_1a.id
  route_table_id = azurerm_route_table.vip1a.id
}

resource "azurerm_subnet_route_table_association" "vip1b" {
  subnet_id      = module.azure_inside_subnet_1b.id
  route_table_id = azurerm_route_table.vip1b.id
}

resource "azurerm_route" "vip1a" {
  name                    = "acceptVIP"
  resource_group_name     = module.azure_resource_group_1.name
  route_table_name        = azurerm_route_table.vip1a.name
  address_prefix          = "100.64.15.0/24"
  next_hop_type           = "VirtualAppliance"
  next_hop_in_ip_address  = data.azurerm_network_interface.sli-1a.private_ip_address
}

resource "azurerm_route" "vip1b" {
  name                    = "acceptVIP"
  resource_group_name     = module.azure_resource_group_1.name
  route_table_name        = azurerm_route_table.vip1b.name
  address_prefix          = "100.64.15.0/24"
  next_hop_type           = "VirtualAppliance"
  next_hop_in_ip_address  = data.azurerm_network_interface.sli-1b.private_ip_address
}

data "azurerm_network_interface" "sli-1a" {
  name                = "master-0-sli"
  resource_group_name = "mw-azure-site-1a-rg"
}
data "azurerm_network_interface" "sli-1b" {
  name                = "master-0-sli"
  resource_group_name = "mw-azure-site-1b-rg"
}

output "azure_resource_group_1_name" {
  value = module.azure_resource_group_1.name
}
output "azure_resource_group_1_location" {
  value = module.azure_resource_group_1.location
}

output "azure_vnet_1a" {
  value = module.azure_vnet_1a.output
}
output "azure_vnet_1b" {
  value = module.azure_vnet_1b.output
}
output "azure_vnet_outside_subnet_1a" {
  value = module.azure_outside_subnet_1a.output
}
output "azure_vnet_inside_subnet_1a" {
  value = module.azure_inside_subnet_1a.output
}
output "azure_vnet_outside_subnet_1b" {
  value = module.azure_outside_subnet_1b.output
}
output "azure_vnet_inside_subnet_1b" {
  value = module.azure_inside_subnet_1b.output
}

output "azure_workload_1a" {
  value = toset(module.azure_workload_1a[*].output)
}
output "azure_workload_1b" {
  value = toset(module.azure_workload_1b[*].output)
}

output "site_1a_sli_ip" {
  value = data.azurerm_network_interface.sli-1a.private_ip_address
}
output "site_1b_sli_ip" {
  value = data.azurerm_network_interface.sli-1b.private_ip_address
}
