# f5xc-aws-azure-lab


```
git submodule update --init --recursive
```

Example output of a deployment

```
$ terraform output

azure_resource_group_id = "/subscriptions/e9cbbd48-704d-4dfa-bf62-60edda755a66/resourceGroups/mw-azure-site1"
azure_resource_group_location = "westus2"
azure_resource_group_name = "mw-azure-site1"
azure_vnet_1 = {
  "address_space" = "100.64.16.0/20"
  "name" = "mw-vnet1"
}
azure_vnet_subnet_1a = {
  "address_prefix" = "100.64.16.0/24"
  "name" = "mw-subnet-1a"
}
azure_vnet_subnet_1b = {
  "address_prefix" = "100.64.17.0/24"
  "name" = "mw-subnet-1b"
}
azure_workload_1a = {
  "private_ip" = "100.64.16.4"
  "public_ip" = "52.151.49.221"
}
azure_workload_1b = {
  "private_ip" = "100.64.17.4"
  "public_ip" = "13.66.156.234"
}
```

Getting public and private IP from F5XC Azure Site with

```
$ ./show_azure_site_ip_address.sh 
master_private_ip_address = 100.64.16.6
master_public_ip_address = 20.83.232.216
```
