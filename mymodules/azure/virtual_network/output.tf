output "name" {
    value = azurerm_virtual_network.vnet.name
}

output "output" {
  value = {
    "name"            = azurerm_virtual_network.vnet.name
    "address_space"   = azurerm_virtual_network.vnet.address_space[0]
  }
}
