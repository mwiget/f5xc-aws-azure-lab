module "azure_site_2a" {
  source                         = "./modules/f5xc/site/azure"
  f5xc_api_p12_file              = "cert/playground.staging.api-creds.p12"
  f5xc_api_ca_cert               = "cert/public_server_ca.crt"
  f5xc_api_url                   = "https://playground.staging.volterra.us/api"
  f5xc_namespace                 = "system"
  f5xc_tenant                    = "playground-wtppvaog"
  f5xc_azure_cred                = "sun-az-creds"
  f5xc_azure_region              = "westus2"
  f5xc_azure_site_name           = "mw-azure-site-2a"
  f5xc_azure_vnet_resource_group = module.azure_resource_group_2.name
  f5xc_azure_vnet_local          = module.azure_vnet_1.name
  #f5xc_azure_vnet_primary_ipv4 = "100.64.16.0/20"
  #f5xc_azure_ce_gw_type        = "multi_nic"
  f5xc_azure_ce_gw_type          = "single_nic"
  f5xc_azure_az_nodes            = {
    node0 : { f5xc_azure_az = "1", f5xc_azure_vnet_local_subnet = module.azure_subnet_2a.name }
    # node0 : { f5xc_azure_az = "1", f5xc_azure_vnet_local_subnet = "100.64.16.0/24" }
    # node0 : { f5xc_azure_az = "1", f5xc_azure_vnet_inside_subnet = "100.64.16.0/24", f5xc_azure_vnet_outside_subnet = "100.64.17.0/24" }
  }
  f5xc_azure_default_blocked_services = false
  f5xc_azure_default_ce_sw_version    = true
  f5xc_azure_default_ce_os_version    = true
  f5xc_azure_no_worker_nodes          = true
  f5xc_azure_total_worker_nodes       = 0
  public_ssh_key                      = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDr1zH+NmWzf/+qtCTqC/+QAHoWIoq3k3YjH/IsjYdHXZ0mQonsMlrL+owArvLtvi3gXxqPGlO/aWt53v8KAY+RV7IOSbqfFY56k0GTmvPJisSsBkAedruu05hqlFMS/2mkNFL/BsWNzL617LtuFQpN6ud57QSrQruQQtIKTuWUe+XjqkSNiAkvD4zc4tip9ovULhC9QY/IVmhguVDJ0FuQWCDd4l7IM+KjlTXGplN5Y9bIVuU+nnSHnUEkRFxuGX1pvOHB1L31INlD9CVJHDA6bBJyIQgv0WcqoA2/3/8eRqN/pXOe+clglJGRT6bb/+5Sfy6JZoA0OlsyW66VfGR3 mwiget@xeon"
} 

module "site_status_check_2" {
  source            = "./modules/f5xc/status/site"
  f5xc_api_url      = "https://playground.staging.volterra.us/api"
  f5xc_api_token    = var.f5xc_api_token
  f5xc_namespace    = "system"
  f5xc_tenant       = "playground-wtppvaog"
  f5xc_site_name    = "mw-azure-site-2a"
  depends_on        = [module.azure_site_2a]
}

module "azure_resource_group_2" {
  source              = "./modules/azure/resource_group"
  resource_group_name = "mw-azure-site2"
  azure_region        = "westus2"
}

module "azure_vnet_2" {
  source                  = "./modules/azure/virtual_network"
  azure_vnet_name         = "mw-vnet2"
  azure_vnet_primary_ipv4 = "100.64.16.0/20"
  resource_group_name     = module.azure_resource_group_2.name
  azure_region            = module.azure_resource_group_2.location
}

module "azure_subnet_2a" {
  name                    = "mw-subnet-2a"
  source                  = "./modules/azure/subnet"
  address_prefix          = "100.64.16.0/24"
  azure_vnet_name         = module.azure_vnet_1.name
  resource_group_name     = module.azure_resource_group_2.name
}

module "azure_subnet_2b" {
  name                    = "mw-subnet-2b"
  source                  = "./modules/azure/subnet"
  address_prefix          = "100.64.17.0/24"
  azure_vnet_name         = module.azure_vnet_1.name
  resource_group_name     = module.azure_resource_group_2.name
}

module "azure_workload_2a" {
  source                  = "./modules/azure/virtual_machine"
  name                    = "mw-workload-2a"
  size                    = "Standard_DS1_v2"
  zone                    = 1
  subnet_id               = module.azure_subnet_2a.id
  username                = "azureuser"
  ssh_key                 = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDr1zH+NmWzf/+qtCTqC/+QAHoWIoq3k3YjH/IsjYdHXZ0mQonsMlrL+owArvLtvi3gXxqPGlO/aWt53v8KAY+RV7IOSbqfFY56k0GTmvPJisSsBkAedruu05hqlFMS/2mkNFL/BsWNzL617LtuFQpN6ud57QSrQruQQtIKTuWUe+XjqkSNiAkvD4zc4tip9ovULhC9QY/IVmhguVDJ0FuQWCDd4l7IM+KjlTXGplN5Y9bIVuU+nnSHnUEkRFxuGX1pvOHB1L31INlD9CVJHDA6bBJyIQgv0WcqoA2/3/8eRqN/pXOe+clglJGRT6bb/+5Sfy6JZoA0OlsyW66VfGR3 mwiget@xeon"
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
  ssh_key                 = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDr1zH+NmWzf/+qtCTqC/+QAHoWIoq3k3YjH/IsjYdHXZ0mQonsMlrL+owArvLtvi3gXxqPGlO/aWt53v8KAY+RV7IOSbqfFY56k0GTmvPJisSsBkAedruu05hqlFMS/2mkNFL/BsWNzL617LtuFQpN6ud57QSrQruQQtIKTuWUe+XjqkSNiAkvD4zc4tip9ovULhC9QY/IVmhguVDJ0FuQWCDd4l7IM+KjlTXGplN5Y9bIVuU+nnSHnUEkRFxuGX1pvOHB1L31INlD9CVJHDA6bBJyIQgv0WcqoA2/3/8eRqN/pXOe+clglJGRT6bb/+5Sfy6JZoA0OlsyW66VfGR3 mwiget@xeon"
  custom_data             = "${filebase64("./workload_custom_data.sh")}"
  resource_group_name     = module.azure_resource_group_2.name
  azure_region            = module.azure_resource_group_2.location
}
