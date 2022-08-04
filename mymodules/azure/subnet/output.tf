output "id" {
    value = azurerm_subnet.sn.id
}
output "name" {
    value = azurerm_subnet.sn.name
}

output "output" {
  value = {
    "name"            = azurerm_subnet.sn.name
    "address_prefix"  = azurerm_subnet.sn.address_prefixes[0]
  }
}
