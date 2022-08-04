# f5xc-aws-azure-lab


```
$ export TF_VAR_f5xc_api_token=..............
```


```
git submodule update --init --recursive
```

Example output of a deployment with 2 Azure and 2 AWS sites:

```
$ terraform output

aws-site-2a = {
  "aws_subnet_id" = {
    "0" = "subnet-0fa3d4d2f131f215d"
    "1" = "subnet-0c88595b9d9aba23c"
    "2" = "subnet-0b02ca0f75936bf47"
  }
  "aws_vpc_id" = "vpc-067640949d05c8130"
  "aws_workload_private_ip" = "100.64.18.170"
  "aws_workload_public_ip" = "13.48.106.238"
  "sli_private_ip" = "100.64.17.113"
  "slo_private_ip" = "100.64.16.160"
  "slo_public_ip" = "13.50.66.74"
}
aws-site-2b = {
  "aws_subnet_id" = {
    "0" = "subnet-0738071ee219fe60b"
    "1" = "subnet-017f96433a8ff56c1"
    "2" = "subnet-0751d4202149afeeb"
  }
  "aws_vpc_id" = "vpc-087915aa6db9e474c"
  "aws_workload_private_ip" = "100.64.18.122"
  "aws_workload_public_ip" = "16.171.29.215"
  "sli_private_ip" = "100.64.17.40"
  "slo_private_ip" = "100.64.16.9"
  "slo_public_ip" = "13.50.47.198"
}
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
  "sli_private_ip" = "100.64.17.6"
  "slo_private_ip" = "100.64.16.5"
  "slo_public_ip" = "20.98.114.23"
  "workload" = {
    "private_ip" = "100.64.17.4"
    "public_ip" = "20.98.113.246"
  }
}
azure-site-1b = {
  "azure_vnet" = {
    "address_space" = "100.64.16.0/22"
    "name" = "mwlab-azure-1b"
  }
  "inside_subnet" = {
    "address_prefix" = "100.64.17.0/24"
    "name" = "mwlab-azure-1b-inside"
  }
  "outside_subnet" = {
    "address_prefix" = "100.64.16.0/24"
    "name" = "mwlab-azure-1b-outside"
  }
  "resource_group_location" = "westus2"
  "resource_group_name" = "mwlab-azure-1b"
  "sli_private_ip" = "100.64.17.6"
  "slo_private_ip" = "100.64.16.5"
  "slo_public_ip" = "20.51.104.173"
  "workload" = {
    "private_ip" = "100.64.17.4"
    "public_ip" = "20.9.136.172"
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






