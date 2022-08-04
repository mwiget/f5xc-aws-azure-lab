resource "azurerm_subnet" "sn" {
  name                  = var.name
  virtual_network_name  = var.azure_vnet_name
  address_prefixes      = [ var.address_prefix ]
  resource_group_name   = var.resource_group_name
}
