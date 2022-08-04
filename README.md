# f5xc-aws-azure-lab


```
$ export TF_VAR_f5xc_api_token=..............
```


```
git submodule update --init --recursive
```

Example output of a deployment with a single azure site

```
$ terraform output

azure-site-1a = {
  "azure_vnet" = {
    "address_space" = "100.64.16.0/22"
    "name" = "mwlab-azure-1a"
  }
  "inside_subnet" = {
    "address_prefix" = "100.64.17.0/24"
    "name" = "mwlab-azure-1a-inside"
  }
  "outside_subnet" = {
    "address_prefix" = "100.64.16.0/24"
    "name" = "mwlab-azure-1a-outside"
  }
  "resource_group_location" = "westus2"
  "resource_group_name" = "mwlab-azure-1a"
  "site_1a_sli_private_ip" = "100.64.17.5"
  "site_1a_slo_private_ip" = "100.64.16.5"
  "site_1a_slo_public_ip" = "20.83.236.245"
  "workload" = {
    "private_ip" = "100.64.17.4"
    "public_ip" = "20.83.234.89"
  }
}
```

some useful commands:

grep for resource groups

```
az group list --output table | grep mw-
mw-azure-site1    westus2   Succeeded
```

delete resource group

```
az group delete --name mw-azure-site1
```






