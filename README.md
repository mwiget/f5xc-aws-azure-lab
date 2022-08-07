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
    "0" = "subnet-03842c97783c95587"
    "1" = "subnet-0c16e8fcc7f939e69"
    "2" = "subnet-0729c64b5e913693c"
  }
  "aws_vpc_id" = "vpc-06bdd68a987e3ff8e"
  "aws_workload_private_ip" = "10.64.18.128"
  "aws_workload_public_ip" = "13.49.245.152"
  "sli_private_ip" = "10.64.17.196"
  "slo_private_ip" = "10.64.16.45"
  "slo_public_ip" = "13.50.54.218"
}
aws-site-2b = {
  "aws_subnet_id" = {
    "0" = "subnet-0598ad6bc5a237b98"
    "1" = "subnet-03c3d31fc0f3e122b"
    "2" = "subnet-002de36c46fb9b461"
  }
  "aws_vpc_id" = "vpc-0e3fddb15cc323b47"
  "aws_workload_private_ip" = "10.64.18.217"
  "aws_workload_public_ip" = "18.236.155.238"
  "sli_private_ip" = "10.64.17.26"
  "slo_private_ip" = "10.64.16.229"
  "slo_public_ip" = "44.225.20.121"
}
azure-site-1a = {
  "azure_vnet" = {
    "address_space" = "10.64.16.0/22"
    "name" = "mwlab-azure-1a"
  }
  "inside_subnet" = {
    "address_prefix" = "10.64.17.0/24"
    "name" = "mwlab-azure-1a-inside"
  }
  "outside_subnet" = {
    "address_prefix" = "10.64.16.0/24"
    "name" = "mwlab-azure-1a-outside"
  }
  "resource_group_location" = "westus2"
  "resource_group_name" = "mwlab-azure-1a"
  "sli_private_ip" = "10.64.17.6"
  "slo_private_ip" = "10.64.16.5"
  "slo_public_ip" = "20.98.105.131"
  "workload" = {
    "private_ip" = "10.64.17.4"
    "public_ip" = "20.115.217.202"
  }
}
azure-site-1b = {
  "azure_vnet" = {
    "address_space" = "10.64.16.0/22"
    "name" = "mwlab-azure-1b"
  }
  "inside_subnet" = {
    "address_prefix" = "10.64.17.0/24"
    "name" = "mwlab-azure-1b-inside"
  }
  "outside_subnet" = {
    "address_prefix" = "10.64.16.0/24"
    "name" = "mwlab-azure-1b-outside"
  }
  "resource_group_location" = "westus2"
  "resource_group_name" = "mwlab-azure-1b"
  "sli_private_ip" = "10.64.17.6"
  "slo_private_ip" = "10.64.16.5"
  "slo_public_ip" = "20.51.121.61"
  "workload" = {
    "private_ip" = "10.64.17.4"
    "public_ip" = "52.247.227.60"
  }
}
gcp-site-3a = {
  "site" = <<-EOT
  gcp_object_name = v4geegl1zr
  instance_names = [
    "mwlab-gcp-3a-grf5",
  ]
  master_private_ip_address = {
    "mwlab-gcp-3a-grf5" = "10.64.16.2"
  }
  master_public_ip_address = {
    "mwlab-gcp-3a-grf5" = "34.65.157.172"
  }
  
  EOT
  "workload" = {
    "private_ip" = "10.64.17.2"
    "public_ip" = "34.65.108.180"
  }
}
gcp-site-3b = {
  "site" = <<-EOT
  gcp_object_name = 
  instance_names = [
    "mwlab-gcp-3b-b4t0",
  ]
  master_private_ip_address = {
    "mwlab-gcp-3b-b4t0" = "10.64.16.2"
  }
  master_public_ip_address = {
    "mwlab-gcp-3b-b4t0" = "34.65.232.12"
  }
  
  EOT
  "workload" = {
    "private_ip" = "10.64.17.2"
    "public_ip" = "34.65.188.215"
  }
}
```

access to workload instances via tailscale:

```
$ tailscale status|grep mwlab
100.66.170.187  mwlab-aws-2a-workload mwiget@      linux   -
100.119.43.182  mwlab-aws-2b-workload mwiget@      linux   -
100.80.104.134  mwlab-azure-1a-workload mwiget@    linux   -
100.94.28.162   mwlab-azure-1b-workload mwiget@    linux   -
100.125.121.151 mwlab-gcp-3a-workload mwiget@      linux   -
100.78.134.207  mwlab-gcp-3b-workload mwiget@      linux   -
```

```
$ ssh ubuntu@mwlab-azure-1a-workload 
The authenticity of host 'mwlab-azure-1a-workload (100.80.104.134)' can't be established.
ED25519 key fingerprint is SHA256:jVhO0fqGt+m7s2GS5JPyFM94j7Cn/Gk4EQUTk64Op3g.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added 'mwlab-azure-1a-workload' (ED25519) to the list of known hosts.
Welcome to Ubuntu 18.04.6 LTS (GNU/Linux 5.4.0-1086-azure x86_64)
ubuntu@mwlab-azure-1a:~$ 
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

