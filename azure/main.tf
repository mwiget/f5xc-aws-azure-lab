module "resource_group" {
  source              = "../mymodules/azure/resource_group"
  resource_group_name = var.name
  azure_region        = var.azure_region
}

module "site" {
  source                          = "../mymodules/f5xc/site/azure"
  f5xc_namespace                  = "system"
  f5xc_azure_site_name            = var.name
  f5xc_azure_region               = var.azure_region
  f5xc_azure_vnet_resource_group  = module.resource_group.name
  custom_tags                     = { "site_mesh_group" = var.site_mesh_group }
  f5xc_azure_ce_gw_type           = "multi_nic"
  f5xc_azure_vnet_name            = module.vnet.name
  f5xc_azure_az_nodes             = {
    node0 : { f5xc_azure_az = var.azure_az, f5xc_azure_vnet_outside_subnet = module.outside_subnet.name, f5xc_azure_vnet_inside_subnet = module.inside_subnet.name }
  }
  f5xc_azure_default_blocked_services = false
  f5xc_azure_default_ce_sw_version    = true
  f5xc_azure_default_ce_os_version    = true
  f5xc_azure_no_worker_nodes          = true
  f5xc_azure_total_worker_nodes       = 0
  public_ssh_key                      = "${file(var.ssh_public_key_file)}"
  f5xc_azure_cred                     = var.f5xc_azure_creds
  f5xc_api_url                        = var.f5xc_api_url
  f5xc_api_p12_file                   = var.f5xc_api_p12_file
  f5xc_tenant                         = var.f5xc_tenant
  depends_on                          = [module.outside_subnet, module.inside_subnet]
} 

module "site_status_check" {
  source            = "../modules/f5xc/status/site"
  f5xc_namespace    = "system"
  f5xc_site_name    = var.name
  f5xc_api_url      = var.f5xc_api_url
  f5xc_api_token    = var.f5xc_api_token
  f5xc_tenant       = var.f5xc_tenant
  depends_on        = [module.site]
}

module "vnet" {
  source                  = "../mymodules/azure/virtual_network"
  azure_vnet_name         = var.name
  azure_vnet_primary_ipv4 = "100.64.16.0/22"
  resource_group_name     = module.resource_group.name
  azure_region            = module.resource_group.location
}

module "outside_subnet" {
  name                    = "${var.name}-outside"
  source                  = "../mymodules/azure/subnet"
  address_prefix          = var.outside_subnet_cidr_block
  azure_vnet_name         = module.vnet.name
  resource_group_name     = module.resource_group.name
}

module "inside_subnet" {
  name                    = "${var.name}-inside"
  source                  = "../mymodules/azure/subnet"
  address_prefix          = var.inside_subnet_cidr_block
  azure_vnet_name         = module.vnet.name
  resource_group_name     = module.resource_group.name
}

resource "azurerm_route_table" "vip" {
  name                = "${var.name}-vip"
  location            = var.azure_region
  resource_group_name = module.resource_group.name
}

resource "azurerm_subnet_route_table_association" "vip" {
  subnet_id      = module.inside_subnet.id
  route_table_id = azurerm_route_table.vip.id
}

resource "azurerm_route" "vip" {
  name                    = "acceptVIP"
  resource_group_name     = module.resource_group.name
  route_table_name        = azurerm_route_table.vip.name
  address_prefix          = var.allow_cidr_blocks[0]
  next_hop_type           = "VirtualAppliance"
  next_hop_in_ip_address  = data.azurerm_network_interface.sli.private_ip_address
  depends_on              = [module.site_status_check]
}

module "workload" {
  source                  = "../mymodules/azure/virtual_machine"
  name                    = var.name
  zone                    = var.azure_az
  size                    = "Standard_DS1_v2"
  username                = "ubuntu"
  ssh_key                 = file(var.ssh_public_key_file)
  custom_data             = filebase64("${path.module}/workload_custom_data.sh")
  subnet_id               = module.inside_subnet.id
  resource_group_name     = module.resource_group.name
  azure_region            = module.resource_group.location
}

data "azurerm_network_interface" "sli" {
  name                = "master-0-sli"
  resource_group_name = "${var.name}-rg"
  depends_on        = [module.site_status_check]
}

data "azurerm_network_interface" "slo" {
  name                = "master-0-slo"
  resource_group_name = "${var.name}-rg"
  depends_on        = [module.site_status_check]
}

data "azurerm_public_ip" "pib" {
  name                = "master-0-public-ip"
  resource_group_name = "${var.name}-rg"
  depends_on        = [module.site_status_check]
}

output "resource_group_name" {
  value = module.resource_group.name
}
output "resource_group_location" {
  value = module.resource_group.location
}

output "azure_vnet" {
  value = module.vnet.output
}
output "outside_subnet" {
  value = module.outside_subnet.output
}
output "inside_subnet" {
  value = module.inside_subnet.output
}

output "workload" {
  value = module.workload.output
}

output "site_1a_sli_private_ip" {
  value = data.azurerm_network_interface.sli.private_ip_address
  depends_on        = [module.site_status_check]
}

output "site_1a_slo_private_ip" {
  value = data.azurerm_network_interface.slo.private_ip_address
  depends_on        = [module.site_status_check]
}

output "site_1a_slo_public_ip" {
  value = data.azurerm_public_ip.pib.ip_address
  depends_on        = [module.site_status_check]
}
