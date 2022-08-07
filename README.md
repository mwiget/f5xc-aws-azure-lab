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
    "0" = "subnet-02752256b560b7ccc"
    "1" = "subnet-05df8c86bb2ee8a18"
    "2" = "subnet-0b2ef20c38be8cb51"
  }
  "aws_vpc_id" = "vpc-0d0a87823a07ba3ed"
  "aws_workload_private_ip" = "100.64.18.118"
  "aws_workload_public_ip" = "13.48.67.186"
  "sli_private_ip" = "100.64.17.108"
  "slo_private_ip" = "100.64.16.114"
  "slo_public_ip" = "13.50.49.17"
}
aws-site-2b = {
  "aws_subnet_id" = {
    "0" = "subnet-08bab1071e26c4c42"
    "1" = "subnet-0d9d22875d83842bc"
    "2" = "subnet-08afc5e029941bdbc"
  }
  "aws_vpc_id" = "vpc-0e8405ed1332bfc96"
  "aws_workload_private_ip" = "100.64.18.31"
  "aws_workload_public_ip" = "54.201.251.173"
  "sli_private_ip" = "100.64.17.49"
  "slo_private_ip" = "100.64.16.46"
  "slo_public_ip" = "44.225.123.145"
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
  "sli_private_ip" = "100.64.17.5"
  "slo_private_ip" = "100.64.16.5"
  "slo_public_ip" = "20.98.113.143"
  "workload" = {
    "private_ip" = "100.64.17.4"
    "public_ip" = "20.98.110.178"
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
  "sli_private_ip" = "100.64.17.5"
  "slo_private_ip" = "100.64.16.5"
  "slo_public_ip" = "20.9.136.62"
  "workload" = {
    "private_ip" = "100.64.17.4"
    "public_ip" = "52.247.230.230"
  }
}
gcp-site-3a = {
  "site" = <<-EOT
  gcp_object_name = v08jnor-q8
  instance_names = [
    "mwlab-gcp-3a-nvsq",
  ]
  master_private_ip_address = {
    "mwlab-gcp-3a-nvsq" = "100.64.16.2"
  }
  master_public_ip_address = {
    "mwlab-gcp-3a-nvsq" = "34.65.232.12"
  }
  
  EOT
  "workload" = {
    "private_ip" = "100.64.17.2"
    "public_ip" = "34.65.157.172"
  }
}
gcp-site-3b = {
  "site" = <<-EOT
  gcp_object_name = v8x0kpde6e
  instance_names = [
    "mwlab-gcp-3b-w060",
  ]
  master_private_ip_address = {
    "mwlab-gcp-3b-w060" = "100.64.16.2"
  }
  master_public_ip_address = {
    "mwlab-gcp-3b-w060" = "34.65.108.180"
  }
  
  EOT
  "workload" = {
    "private_ip" = "100.64.17.2"
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

