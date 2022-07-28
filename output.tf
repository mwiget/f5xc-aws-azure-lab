output "azure_resource_group_1_name" {
  value = module.azure_resource_group_1.name
}
output "azure_resource_group_1_location" {
  value = module.azure_resource_group_1.location
}

output "azure_resource_group_2_name" {
  value = module.azure_resource_group_2.name
}
output "azure_resource_group_2_location" {
  value = module.azure_resource_group_2.location
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
