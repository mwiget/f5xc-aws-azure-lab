module "vpc" {
  source                = "../modules/aws/vpc"
  aws_vpc_cidr_block    = var.vpc_cidr_block
  aws_vpc_name          = var.name
  enable_dns_support    = "true"
  enable_dns_hostnames  = "true"
  enable_classiclink    = "false"
  instance_tenancy      = "default"
  aws_region            = var.aws_region
  aws_az_name           = var.aws_az_name
}

module "subnet" {
  source                = "../modules/aws/subnet"
  aws_vpc_id           = module.vpc.aws_vpc_id
  aws_vpc_subnets      = [
    { 
      cidr_block = var.outside_subnet_cidr_block, availability_zone = var.aws_az_name,
      map_public_ip_on_launch = "true", custom_tags = { "Name" = var.name }
    },
    { 
      cidr_block = var.inside_subnet_cidr_block, availability_zone = var.aws_az_name,
      map_public_ip_on_launch = "true", custom_tags = { "Name" = var.name }
    },
    { 
      cidr_block = var.workload_subnet_cidr_block, availability_zone = var.aws_az_name,
      map_public_ip_on_launch = "true", custom_tags = { "Name" = var.name }
    }
  ]
}

module "workload" {
  source                = "../mymodules/aws/ec2"
  aws_ec2_instance_name = var.name
  aws_ec2_instance_type = "t3.micro"
  aws_region            = var.aws_region
  aws_vpc_id            = module.vpc.aws_vpc_id
  aws_subnet_id         = module.subnet.aws_subnet_id[2]
  aws_owner_tag         = var.owner_tag
  ssh_public_key        = file(var.ssh_public_key_file)
  user_data             = file("${path.module}/workload_custom_data.sh")
  allow_cidr_blocks     = [ "100.0.0.0/8" ]
}

module "site" {
  source                          = "../modules/f5xc/site/aws/vpc"
  f5xc_namespace                  = "system"
  f5xc_tenant                     = var.f5xc_tenant
  f5xc_aws_region                 = var.aws_region
  f5xc_aws_cred                   = var.f5xc_aws_cred
  f5xc_aws_vpc_site_name          = var.name
  f5xc_aws_vpc_name_tag           = ""
  f5xc_aws_vpc_id                 = module.vpc.aws_vpc_id
  f5xc_aws_vpc_total_worker_nodes = 0
  f5xc_aws_ce_gw_type             = "multi_nic"
  aws_owner_tag                   = var.owner_tag
  custom_tags                     = { "site_mesh_group" = var.site_mesh_group }
  f5xc_aws_vpc_az_nodes           = {
    node0 : { 
      f5xc_aws_vpc_id           = module.aws_vpc_3a.aws_vpc_id,
      f5xc_aws_vpc_local_subnet = module.aws_subnet_3a.aws_subnet_id[0], 
      f5xc_aws_vpc_az_name      = "us-west-2a" }
  }
  f5xc_aws_default_ce_os_version       = true
  f5xc_aws_default_ce_sw_version       = true
# F5-XC-MODULES

This repository consists of Terraform template modules to bring up various F5XC components.

## Table of Contents

- [F5-XC-MODULES](#f5-xc-modules)
  * [Table of Contents](#table-of-contents)
- [Usage](#usage)
- [Modules](#modules)
  * [F5XC Modules](#f5xc-modules)
    + [Namespace](#namespace)
    + [Virtual Kubernetes](#virtual-kubernetes)
    + [Site Mesh Group](#site-mesh-group)
    + [Fleet](#fleet)
    + [BGP](#bgp)
    + [Interface](#interface)
    + [NFV](#nfv)
    + [CE](#ce)
    + [IPSec tunnel](#ipsec-tunnel)
    + [Virtual Network](#virtual-network)
    + [Site](#site)
      - [AWS VCP](#aws-vcp)
      - [AWS TGW](#aws-tgw)
      - [GCP VPC](#gcp-vpc)
      - [Azure VNET](#azure-vnet)
      - [Update](#update)
    + [Site Status Check](#site-status-check)
  * [AWS Modules](#aws-modules)
    + [EC2](#ec2)
    + [VPC](#vpc)
    + [EKS](#eks)
  * [GCP Modules](#gcp-modules)
    + [Compute](#compute)
  * [Azure Modules](#azure-modules)
    + [Linux Virtual Machine](#linux-virtual-machine)

# Usage

- The Terraform templates in this repository ment to be used as modules in any root Terraform template environment
- Create a new Terraform project e.g. __f5xc-mcn__
- Clone this repo with: `git clone https://github.com/cklewar/f5-xc-modules` into the new created project folder

Folder structure example:

```bash
.
├── cert
└── modules
└── main.tf
```

Terraform usage example:

```hcl
module "my_test_modul" {
  source = "./modules/f5xc/<module_name>"
  <Module Paramet
A> = <Module Paramet A Value>
<Module Paramet B> = <Module Paramet B Value>
<Module Paramet C> = <Module Paramet C Value>
...
}
```

# Modules

Module repository folder structure like below:

## F5XC Modules

### Namespace

__Module Usage Example__

```hcl
variable "project_prefix" {
  type        = string
  description = "prefix string put in front of string"
}

variable "project_suffix" {
  type        = string
  description = "prefix string put at the end of string"
}

variable "f5xc_api_p12_file" {
  type = string
}

variable "f5xc_api_url" {
  type = string
}

variable "f5xc_namespace_name" {
  type = string
}

module "namespace" {
  source              = "../modules/namespace"
  f5xc_namespace_name = format("%s-ns-%s", var.project_prefix, var.project_suffix)
  f5xc_namespace      = var.f5xc_namespace
  f5xc_api_url        = var.f5xc_api_url
  f5xc_api_p12_file   = var.f5xc_api_p12_file
}
```

### Virtual Kubernetes

__Module Usage Example__

```hcl
variable "project_prefix" {
  type        = string
  description = "prefix string put in front of string"
}

variable "project_suffix" {
  type        = string
  description = "prefix string put at the end of string"
}

variable "f5xc_api_p12_file" {
  type = string
}

variable "f5xc_api_url" {
  type = string
}

variable "f5xc_tenant" {
  type = string
}

variable "f5xc_namespace" {
  type = string
}

module "vk8s" {
  source                              = "../modules/vk8s"
  f5xc_f5xc_site_mesh_group_name_name = format("%s-vk8s-%s", var.project_prefix, var.project_suffix)
  f5xc_virtual_site_refs              = ["vSiteA"]
  kubectl_secret_registry_type        = "docker-registry"
  kubectl_secret_registry_server      = "docker.io"
  kubectl_secret_name                 = "regcred"
  kubectl_secret_registry_username    = "admin"
  kubectl_secret_registry_password    = "password"
  kubectl_secret_registry_email       = "admin@example.net"
  f5xc_namespace                      = var.f5xc_namespace
  f5xc_tenant                         = var.f5xc_tenant
  f5xc_api_url                        = var.f5xc_api_url
  f5xc_api_p12_file                   = var.f5xc_api_p12_file
}
```

### Site Mesh Group

__Module Usage Example__

```hcl
variable "project_prefix" {
  type        = string
  description = "prefix string put in front of string"
}

variable "project_suffix" {
  type        = string
  description = "prefix string put at the end of string"
}

variable "f5xc_api_p12_file" {
  type = string
}

variable "f5xc_api_url" {
  type = string
}

variable "f5xc_tenant" {
  type = string
}

variable "f5xc_namespace" {
  type = string
}

variable "f5xc_site_mesh_group_name" {
  type = string
}

module "site_mesh_group" {
  source                    = "../modules/site-mesh-group"
  f5xc_site_mesh_group_name = format("%s-smg-%s", var.project_prefix, var.project_suffix)
  f5xc_namespace            = var.f5xc_namespace
  f5xc_tenant               = var.f5xc_tenant
  f5xc_api_url              = var.f5xc_api_url
  f5xc_api_p12_file         = var.f5xc_api_p12_file
}
```

### Fleet

__Module Usage Example__

```hcl
variable "project_prefix" {
  type        = string
  description = "prefix string put in front of string"
}

variable "project_suffix" {
  type        = string
  description = "prefix string put at the end of string"
}

variable "f5xc_api_p12_file" {
  type = string
}

variable "f5xc_api_url" {
  type = string
}

variable "f5xc_tenant" {
  type = string
}

variable "f5xc_namespace" {
  type = string
}

variable "f5xc_fleet_label" {
  type = string
}

locals {
  tunnel_interface_name  = format("%s-tunnel-interface-%s", var.project_prefix, var.project_suffix)
  tunnel_virtual_network = format("%s-vn-%s", var.project_prefix, var.project_suffix)
}

module "fleet" {
  source                       = "../modules/fleet"
  f5xc_fleet_name              = format("%s-fleet-%s", var.project_prefix, var.project_suffix)
  f5xc_fleet_label             = var.fleet_label
  f5xc_outside_virtual_network = [local.tunnel_virtual_network]
  f5xc_inside_virtual_network  = var.inside_virtual_network
  f5xc_networks_interface_list = [local.tunnel_interface_name]
  f5xc_namespace               = var.f5xc_namespace
  f5xc_tenant                  = var.f5xc_tenant
  f5xc_api_url                 = var.f5xc_api_url
  f5xc_api_p12_file            = var.f5xc_api_p12_file
}
```

__Input Vars Example__

```json
{
  "project_prefix": "aws",
  "project_suffix": "01",
  "f5xc_tenant": "xyz-ydghbxyc",
  "f5xc_namespace": "system",
  "f5xc_api_p12_file": "xyz.console.ves.volterra.io.api-creds.p12",
  "f5xc_api_url": "https://xyz.console.ves.volterra.io/api",
  "f5xc_fleet_label": "fleet-123-abc"
}
```

### BGP

__Module Usage Example__

```hcl
variable "project_prefix" {
  type        = string
  description = "prefix string put in front of string"
}

variable "project_suffix" {
  type        = string
  description = "prefix string put at the end of string"
}

variable "f5xc_api_p12_file" {
  type = string
}

variable "f5xc_api_url" {
  type = string
}

variable "f5xc_tenant" {
  type = string
}

variable "f5xc_namespace" {
  type = string
}

variable "f5xc_bgp_local_asn" {
  type = number
}

variable "f5xc_bgp_peer_asn" {
  type = number
}

variable "f5xc_bgp_peer_address" {
  type = string
}

variable "f5xc_bgp_description" {
  type = string
}

locals {
  deployment = format("%s-%s", var.project_prefix, var.project_suffix)
}

module "bgp" {
  source                = "../modules/bgp"
  f5xc_namespace        = var.f5xc_namespace
  f5xc_tenant           = var.f5xc_tenant
  f5xc_api_url          = var.f5xc_api_url
  f5xc_api_p12_file     = var.f5xc_api_p12_file
  f5xc_bgp_asn          = var.f5xc_bgp_local_asn
  f5xc_bgp_description  = var.f5xc_bgp_description
  f5xc_bgp_name         = format("%s-bgp-%s", var.project_prefix, var.project_suffix)
  f5xc_bgp_peer_asn     = var.f5xc_bgp_peer_asn
  f5xc_bgp_peer_name    = format("%s-peer-%s", var.project_prefix, var.project_suffix)
  f5xc_bgp_peer_address = var.f5xc_bgp_peer_address
  f5xc_site_name        = local.deployment
}
```

__Input Vars Example__

````json
{
  "project_prefix": "aws",
  "project_suffix": "01",
  "f5xc_tenant": "xyz-ydghbxyc",
  "f5xc_namespace": "system",
  "f5xc_api_p12_file": "xyz.console.ves.volterra.io.api-creds.p12",
  "f5xc_api_url": "https://xyz.console.ves.volterra.io/api",
  "f5xc_bgp_local_asn": 65200,
  "f5xc_bgp_peer_asn": 65000,
  "f5xc_bgp_peer_address": "169.254.186.2",
  "f5xc_bgp_description": "Neighbor Xyz"
}
````

### Interface

__Module Usage Example: IPSec tunnel interface in F5XC AWS site__

```hcl
variable "project_prefix" {
  type        = string
  description = "prefix string put in front of string"
}

variable "project_suffix" {
  type        = string
  description = "prefix string put at the end of string"
}

variable "f5xc_api_p12_file" {
  type = string
}

variable "f5xc_api_url" {
  type = string
}

variable "f5xc_tenant" {
  type = string
}

variable "f5xc_namespace" {
  type = string
}

locals {
  f5xc_tunnel_interface_name = format("%s-tunnel-interface-%s", var.project_prefix, var.project_suffix)
  f5xc_tunnel_name           = format("%s-tunnel-%s", var.project_prefix, var.project_suffix)
}

module "interface" {
  source                   = "../modules/interface"
  f5xc_tenant              = var.f5xc_tenant
  f5xc_namespace           = var.f5xc_namespace
  f5xc_api_p12_file        = var.f5xc_api_p12_file
  f5xc_api_token           = var.f5xc_api_token
  f5xc_api_url             = var.f5xc_api_url
  f5xc_interface_name      = local.tunnel_interface_name
  f5xc_interface_type      = var.f5xc_interface_type
  f5xc_interface_static_ip = var.f5xc_tunnel_interface_static_ip
  f5xc_node_name           = "ip-192-168-45-1"
  f5xc_tunnel_name         = local.f5xc_tunnel_name
}
```

__Input Vars Example: IPSec tunnel interface in F5XC AWS site__

```json
{
  "project_prefix": "aws",
  "project_suffix": "01",
  "f5xc_tenant": "xyz-ydghbxyc",
  "f5xc_namespace": "system",
  "f5xc_api_p12_file": "xyz.console.ves.volterra.io.api-creds.p12",
  "f5xc_api_url": "https://xyz.console.ves.volterra.io/api",
  "f5xc_interface_type": "tunnel_interface",
  "f5xc_tunnel_interface_static_ip": "192.168.1.1"
}
```

__Module Usage Example: IPSec tunnel interface in F5XC GCP site__

````hcl
variable "project_prefix" {
  type        = string
  description = "prefix string put in front of string"
}

variable "project_suffix" {
  type        = string
  description = "prefix string put at the end of string"
}

variable "f5xc_api_p12_file" {
  type = string
}

variable "f5xc_api_url" {
  type = string
}

variable "f5xc_tenant" {
  type = string
}

variable "f5xc_namespace" {
  type = string
}

locals {
  deployment            = format("%s-%s", var.project_prefix, var.project_suffix)
  tunnel_name           = format("%s-tunnel-%s", var.project_prefix, var.project_suffix)
  tunnel_interface_name = format("%s-tunnel-interface-%s", var.project_prefix, var.project_suffix)
}

module "interface" {
  source                   = "../modules/interface"
  f5xc_tenant              = var.f5xc_tenant
  f5xc_namespace           = var.f5xc_namespace
  f5xc_api_p12_file        = var.f5xc_api_p12_file
  f5xc_api_token           = var.f5xc_api_token
  f5xc_api_url             = var.f5xc_api_url
  f5xc_interface_name      = local.tunnel_interface_name
  f5xc_interface_type      = "tunnel_interface"
  f5xc_interface_static_ip = var.f5xc_tunnel_interface_static_ip
  f5xc_node_name           = local.deployment
  f5xc_tunnel_name         = local.tunnel_name
}
````

__Input Vars Example: IPSec tunnel interface in F5XC GCP site__

```json
{
  "project_prefix": "gcp",
  "project_suffix": "01",
  "f5xc_tenant": "xyz-ydghbxyc",
  "f5xc_namespace": "system",
  "f5xc_api_p12_file": "xyz.console.ves.volterra.io.api-creds.p12",
  "f5xc_api_url": "https://xyz.console.ves.volterra.io/api",
  "f5xc_interface_type": "tunnel_interface",
  "f5xc_tunnel_interface_static_ip": "192.168.1.1"
}
```

### NFV

__Module Usage Example__

This module needs a F5XC AWS TGW site to be deployed first since it depends on F5XC TGW input data.

````hcl
module "nfv" {
  source                    = "../modules/nfv"
  dependency                = module.tgw.this
  f5xc_project_prefix       = var.project_prefix
  f5xc_project_suffix       = var.project_suffix
  f5xc_tenant               = var.data[terraform.workspace].tenant
  f5xc_namespace            = var.namespace
  aws_region                = var.aws_region
  f5xc_api_p12_file         = var.data[terraform.workspace].api_p12_file
  f5xc_api_ca_cert          = var.f5xc_api_ca_cert
  f5xc_api_token            = var.data[terraform.workspace].api_token
  f5xc_api_cert             = var.f5xc_api_cert
  f5xc_api_key              = var.f5xc_api_key
  f5xc_api_url              = var.data[terraform.workspace].api_url
  aws_az_name               = var.aws_az_name
  tgw_name                  = format("%s-%s-%s", var.project_prefix, var.tgw_name, var.project_suffix)
  f5xc_nfv_name             = format("%s-%s-%s", var.project_prefix, var.f5xc_nfv_name, var.project_suffix)
  f5xc_nfv_node_name        = format("%s-%s-%s", var.project_prefix, var.f5xc_nfv_node_name, var.project_suffix)
  f5xc_nfv_admin_username   = var.f5xc_nfv_admin_username
  f5xc_nfv_admin_password   = base64encode(var.f5xc_nfv_admin_password)
  f5xc_nfv_domain_suffix    = var.data[terraform.workspace].nfv_domain_suffix
  f5xc_nfv_description      = var.f5xc_nfv_description
  f5xc_nfv_payload_file     = var.f5xc_nfv_payload_file
  f5xc_nfv_payload_template = var.f5xc_nfv_payload_template
  f5xc_nfv_svc_create_uri   = var.f5xc_nfv_svc_create_uri
  f5xc_nfv_svc_delete_uri   = var.f5xc_nfv_svc_delete_uri
  f5xc_nfv_svc_get_uri      = var.f5xc_nfv_svc_get_uri
  aws_owner_tag             = var.data[terraform.workspace].owner_tag
  public_ssh_key            = var.public_ssh_key
}
````

### CE

### IPSec tunnel

__Module Usage Example__

````hcl
variable "project_prefix" {
  type        = string
  description = "prefix string put in front of string"
}

variable "project_suffix" {
  type        = string
  description = "prefix string put at the end of string"
}

variable "f5xc_api_p12_file" {
  type = string
}

variable "f5xc_api_url" {
  type = string
}

variable "f5xc_tenant" {
  type = string
}

variable "f5xc_namespace" {
  type = string
}

module "tunnel" {
  source                 = "../modules/tunnel"
  f5xc_tenant            = var.f5xc_tenant
  f5xc_namespace         = var.f5xc_namespace
  f5xc_api_p12_file      = var.f5xc_api_p12_file
  f5xc_api_token         = var.f5xc_api_token
  f5xc_api_url           = var.f5xc_api_url
  f5xc_tunnel_name       = local.tunnel_name
  f5xc_remote_ip_address = var.f5xc_tunnel_remote_ip_address
  f5xc_clear_secret      = var.f5xc_tunnel_clear_secret
}
````

### Virtual Network

__Module Usage Example: Tunnel Interface Virtual Network__

````hcl
variable "project_prefix" {
  type        = string
  description = "prefix string put in front of string"
}

variable "project_suffix" {
  type        = string
  description = "prefix string put at the end of string"
}

variable "f5xc_api_p12_file" {
  type = string
}

variable "f5xc_api_url" {
  type = string
}

variable "f5xc_tenant" {
  type = string
}

variable "f5xc_namespace" {
  type = string
}

module "tunnel_virtual_network" {
  source                            = "../modules/virtual-network"
  f5xc_name                         = local.tunnel_virtual_network
  f5xc_namespace                    = var.f5xc_namespace
  f5xc_site_local_network           = true
  f5xc_tenant                       = var.f5xc_tenant
  f5xc_ip_prefixes                  = var.f5xc_tunnel_virtual_network_ip_prefixes
  f5xc_ip_prefix_next_hop_interface = local.tunnel_interface_name
}
````

__Module Usage Example: Global Virtual Network__

```hcl
variable "project_prefix" {
  type        = string
  description = "prefix string put in front of string"
}

variable "project_suffix" {
  type        = string
  description = "prefix string put at the end of string"
}

variable "f5xc_api_p12_file" {
  type = string
}

variable "f5xc_api_url" {
  type = string
}

variable "f5xc_tenant" {
  type = string
}

variable "f5xc_namespace" {
  type = string
}

locals {
  global_vn_name = format("my-global-vn-%s", var.project_suffix)
}

module "global_virtual_network" {
  source              = "../modules/virtual-network"
  f5xc_name           = local.global_vn_name
  f5xc_tenant         = var.f5xc_tenant
  f5xc_namespace      = var.f5xc_namespace
  f5xc_global_network = true
}
```

### Site

#### AWS VCP

__Module Usage Example__

```hcl
module "aws_vpc_multi_node" {
  source                          = "./modules/f5xc/site/aws/vpc"
  f5xc_api_p12_file               = "cert/api-creds.p12"
  f5xc_api_url                    = "https://playground.staging.volterra.us/api"
  f5xc_namespace                  = "system"
  f5xc_tenant                     = "playground-wtppvaog"
  f5xc_aws_region                 = "us-east-2"
  f5xc_aws_cred                   = "ck-aws-01"
  f5xc_aws_vpc_site_name          = "ck-aws-vpc-multi-node-03"
  f5xc_aws_vpc_name_tag           = ""
  f5xc_aws_vpc_az_name            = "us-east-2a"
  f5xc_aws_vpc_primary_ipv4       = "192.168.168.0/21"
  f5xc_aws_vpc_total_worker_nodes = 2
  f5xc_aws_ce_gw_type             = "single_nic"
  f5xc_aws_vpc_az_nodes           = {
    node0 = { f5xc_aws_vpc_local_subnet = "192.168.168.0/26" },
    node1 = { f5xc_aws_vpc_local_subnet = "192.168.169.0/26" },
    node2 = { f5xc_aws_vpc_local_subnet = "192.168.170.0/26" }
  }
  f5xc_aws_default_ce_os_version       = true
  f5xc_aws_default_ce_sw_version       = true
  f5xc_aws_vpc_no_worker_nodes         = false
  f5xc_aws_vpc_use_http_https_port     = true
  f5xc_aws_vpc_use_http_https_port_sli = true
  public_ssh_key                       = "ssh-rsa xyz"
}
```

#### AWS TGW

__Module Usage Example__

````hcl
module "aws_tgw_multi_node" {
  source                          = "./modules/f5xc/site/aws/tgw"
  f5xc_api_p12_file               = "cert/api-creds.p12"
  f5xc_api_url                    = "https://playground.staging.volterra.us/api"
  f5xc_namespace                  = "system"
  f5xc_tenant                     = "playground"
  f5xc_aws_region                 = "us-east-2"
  f5xc_aws_cred                   = "aws-01"
  f5xc_aws_default_ce_sw_version  = true
  f5xc_aws_default_os_version     = true
  f5xc_aws_tgw_az_name            = "us-east-2a"
  f5xc_aws_tgw_name               = "aws-tgw-multi-node-01"
  f5xc_aws_tgw_no_worker_nodes    = false
  f5xc_aws_tgw_total_worker_nodes = 2
  f5xc_aws_tgw_primary_ipv4       = "192.168.168.0/21"
  f5xc_aws_tgw_az_nodes           = {
    node0 : {
      f5xc_aws_tgw_workload_subnet = "192.168.168.0/26", f5xc_aws_tgw_inside_subnet = "192.168.168.64/26",
      f5xc_aws_tgw_outside_subnet  = "192.168.168.128/26"
    },
    node1 : {
      f5xc_aws_tgw_workload_subnet = "192.168.169.0/26", f5xc_aws_tgw_inside_subnet = "192.168.169.64/26",
      f5xc_aws_tgw_outside_subnet  = "192.168.169.128/26"
    },
    node2 : {
      f5xc_aws_tgw_workload_subnet = "192.168.170.0/26", f5xc_aws_tgw_inside_subnet = "192.168.170.64/26",
      f5xc_aws_tgw_outside_subnet  = "192.168.170.128/26"
    }
  }
  f5xc_aws_tgw_vpc_attach_label_deploy = ""
  aws_owner_tag                        = "c.klewar@f5.com"
  public_ssh_key                       = "ssh-rsa xyz"
}
````

#### GCP VPC

__Module Usage Example__

````hcl
module "gcp_multi_node" {
  source                            = "./modules/f5xc/site/gcp"
  f5xc_api_p12_file                 = "/cert/api-creds.p12"
  f5xc_api_url                      = "https://playground.staging.volterra.us/api"
  f5xc_namespace                    = "system"
  f5xc_tenant                       = "playground"
  f5xc_gcp_cred                     = "gcp-01"
  f5xc_gcp_ce_gw_type               = "single_nic"
  f5xc_gcp_default_ce_sw_version    = true
  f5xc_gcp_default_os_version       = true
  f5xc_gcp_inside_primary_ipv4      = "192.168.169.0/24"
  f5xc_gcp_outside_primary_ipv4     = "192.168.168.0/24"
  f5xc_gcp_node_number              = 3
  f5xc_gcp_project_id               = "gcp_project_id"
  f5xc_gcp_region                   = "us-east1"
  f5xc_gcp_site_name                = "gcp-multi-node-01"
  f5xc_gcp_zone_names               = ["us-east1-b"]
  f5xc_gcp_default_blocked_services = true
  public_ssh_key                    = "ssh-rsa xyz"
}
````

#### Azure VNET

__Module Usage Example Single_NIC / New VNET__

```hcl
module "azure_multi_node" {
  source                       = "./modules/f5xc/site/azure"
  f5xc_api_p12_file            = "/api-creds.p12"
  f5xc_api_url                 = "https://playground.staging.volterra.us/api"
  f5xc_namespace               = "system"
  f5xc_tenant                  = "playground"
  f5xc_azure_az                = 1
  f5xc_azure_cred              = "az-creds"
  f5xc_azure_region            = "useast"
  f5xc_azure_site_name         = "azure-multi-node-01"
  f5xc_azure_vnet_primary_ipv4 = "192.168.168.0/21"
  f5xc_azure_ce_gw_type        = "single_nic"
  f5xc_azure_az_nodes          = {
    node0 : { f5xc_azure_vnet_local_subnet = "192.168.168.0/24" },
    node1 : { f5xc_azure_vnet_local_subnet = "192.168.170.0/24" },
    node2 : { f5xc_azure_vnet_local_subnet = "192.168.172.0/24" }
  }
  f5xc_azure_default_blocked_services = false
  f5xc_azure_default_ce_sw_version    = true
  f5xc_azure_default_os_version       = true
  f5xc_azure_no_worker_nodes          = false
  f5xc_azure_total_worker_nodes       = 2
  public_ssh_key                      = "ssh-rsa xyz"
}
```

__Module Usage Example Single_NIC / existing VNET__

```hcl
module "azure_multi_node" {
  source                       = "./modules/f5xc/site/azure"
  f5xc_api_p12_file            = "/api-creds.p12"
  f5xc_api_url                 = "https://playground.staging.volterra.us/api"
  f5xc_namespace               = "system"
  f5xc_tenant                  = "playground"
  f5xc_azure_az                = 1
  f5xc_azure_cred              = "az-creds"
  f5xc_azure_region            = "useast"
  f5xc_azure_site_name         = "azure-multi-node-01"
  f5xc_azure_vnet_primary_ipv4 = "192.168.168.0/21"
  f5xc_azure_ce_gw_type        = "single_nic"
  f5xc_azure_az_nodes          = {
    node0 : { f5xc_azure_local_subnet_name = "node0_subnetA" },
    node1 : { f5xc_azure_local_subnet_name = "node1_subnetB" },
    node2 : { f5xc_azure_local_subnet_name = "node2_subnetC" }
  }
  f5xc_azure_vnet_resource_group      = "vnet_resource_group_A"
  f5xc_azure_default_blocked_services = false
  f5xc_azure_default_ce_sw_version    = true
  f5xc_azure_default_os_version       = true
  f5xc_azure_no_worker_nodes          = true
  f5xc_azure_total_worker_nodes       = 0
  public_ssh_key                      = "ssh-rsa xyz"
}
```

__Module Usage Example Multi_NIC / new VNET__

```hcl
module "azure_multi_node" {
  source                       = "./modules/f5xc/site/azure"
  f5xc_api_p12_file            = "./playground.staging.api-creds.p12"
  f5xc_api_url                 = "https://playground.staging.volterra.us/api"
  f5xc_namespace               = "system"
  f5xc_tenant                  = "playground"
  f5xc_azure_cred              = "az-creds"
  f5xc_azure_region            = "useast"
  f5xc_azure_site_name         = "azure-multi-node-01"
  f5xc_azure_vnet_primary_ipv4 = "100.64.16.0/20"
  f5xc_azure_ce_gw_type        = "multi_nic"
  f5xc_azure_az_nodes          = {
    node0 : {
      f5xc_azure_az                  = "1", f5xc_azure_vnet_inside_subnet = "100.64.16.0/24",
      f5xc_azure_vnet_outside_subnet = "100.64.17.0/24"
    }
  }
  f5xc_azure_default_blocked_services = false
  f5xc_azure_default_ce_sw_version    = true
  f5xc_azure_default_ce_os_version    = true
  f5xc_azure_no_worker_nodes          = true
  f5xc_azure_total_worker_nodes       = 0
  public_ssh_key                      = "ssh-rsa xyz"
}
```

__Module Usage Example Multi_NIC / existing VNET__

```hcl
module "azure_multi_node" {
  source                       = "./modules/f5xc/site/azure"
  f5xc_api_p12_file            = "./playground.staging.api-creds.p12"
  f5xc_api_url                 = "https://playground.staging.volterra.us/api"
  f5xc_namespace               = "system"
  f5xc_tenant                  = "playground"
  f5xc_azure_cred              = "az-creds"
  f5xc_azure_region            = "useast"
  f5xc_azure_site_name         = "azure-multi-node-01"
  f5xc_azure_vnet_primary_ipv4 = "100.64.16.0/20"
  f5xc_azure_ce_gw_type        = "multi_nic"
  f5xc_azure_az_nodes          = {
    node0 : {
      f5xc_azure_az                  = "1", f5xc_azure_vnet_inside_subnet_name = "node_0_inside_subnet",
      f5xc_azure_vnet_outside_subnet_name = "node_0_outside_subnet"
    },
    node1 : {
      f5xc_azure_az                  = "1", f5xc_azure_vnet_inside_subnet_name = "node_1_inside_subnet",
      f5xc_azure_vnet_outside_subnet_name = "node_1_outside_subnet"
    },
    node2 : {
      f5xc_azure_az                  = "1", f5xc_azure_vnet_inside_subnet_name = "node_2_inside_subnet",
      f5xc_azure_vnet_outside_subnet_name = "node_2_outside_subnet"
    }
  }
  f5xc_azure_vnet_resource_group      = "vnet_resource_group_A"
  f5xc_azure_default_blocked_services = false
  f5xc_azure_default_ce_sw_version    = true
  f5xc_azure_default_ce_os_version    = true
  f5xc_azure_no_worker_nodes          = true
  f5xc_azure_total_worker_nodes       = 2
  public_ssh_key                      = "ssh-rsa xyz"
}
```

#### Update

__Module Usage Example__

```hcl
variable "project_prefix" {
  type        = string
  description = "prefix string put in front of string"
}

variable "project_suffix" {
  type        = string
  description = "prefix string put at the end of string"
}

variable "f5xc_api_p12_file" {
  type = string
}

variable "f5xc_api_url" {
  type = string
}

variable "f5xc_tenant" {
  type = string
}

variable "f5xc_namespace" {
  type = string
}

locals {
  deployment     = format("%s-%s", var.project_prefix, var.project_suffix)
  cluster_labels = var.fleet_label != "" ? { "ves.io/fleet" = var.fleet_label } : {}
  global_vn_name = format("my-global-vn-%s", var.project_suffix)
}

module "site_update" {
  source                      = "../modules/site/update"
  f5xc_tenant                 = var.f5xc_tenant
  f5xc_namespace              = var.f5xc_namespace
  f5xc_api_p12_file           = var.f5xc_api_p12_file
  f5xc_api_token              = var.f5xc_api_token
  f5xc_api_url                = var.f5xc_api_url
  f5xc_global_virtual_network = local.global_vn_name
  f5xc_site_name              = local.deployment
  f5xc_cluster_labels         = local.cluster_labels
}
```

### Site Status Check

__Module Usage Example__

````hcl
variable "f5xc_api_url" {
  type = string
}

variable "f5xc_api_token" {
  type = string
}

variable "f5xc_tenant" {
  type = string
}

variable "f5xc_namespace" {
  type = string
}

variable "f5xc_site_name" {
  type = string
}

module "site_status_check" {
  source         = "../modules/status/site"
  f5xc_api_url   = var.f5xc_api_url
  f5xc_api_token = var.f5xc_api_token
  f5xc_namespace = var.f5xc_namespace
  f5xc_site_name = var.f5xc_site_name
  f5xc_tenant    = var.f5xc_tenant
}
````

## AWS Modules

### EC2

__Module Usage Example__

```hcl
module "ec2" {
  source                        = "./modules/aws/ec2"
  aws_ec2_instance_name         = "ck-ec2-instance-01"
  aws_ec2_instance_type         = "t2.small"
  aws_subnet_cidr               = "172.16.192.0/21"
  aws_ec2_public_interface_ips  = ["172.16.192.10"]
  aws_ec2_private_interface_ips = ["172.16.193.10"]
  aws_ec2_instance_data_key     = "ec2-instance-01"
  aws_ec2_instance_data         = {
    inline = [
      format("chmod +x /tmp/%s", var.aws_ec2_instance_script_file_name),
      format("sudo /tmp/%s", var.aws_ec2_instance_script_file_name)
    ]
    userdata = {
      GITEA_VERSION  = var.gitea_version
      GITEA_PASSWORD = var.gitea_password
    }
  }
  aws_ec2_instance_script_template = format("%s.tftpl", var.aws_ec2_instance_script_template_file_name)
  aws_ec2_instance_script_file     = format("%s.sh", var.aws_ec2_instance_script_file_name)
  aws_subnet_private_id            = element([for s in module.aws_subnets.aws_subnet_id : s], 1)
  aws_subnet_public_id             = element([for s in module.aws_subnets.aws_subnet_id : s], 0)
  aws_az_name                      = var.aws_az
  aws_region                       = var.aws_region
  ssh_private_key_file             = abspath("keys/key")
  ssh_public_key_file              = abspath("keys/key.pub")
  aws_vpc_id                       = module.aws_vpc.aws_vpc_id
  aws_ec2_instance_userdata_dirs   = [
    {
      name        = "instance_script"
      source      = abspath(format("../modules/ec2/_out/%s", format("%s.sh", var.aws_ec2_instance_script_file_name)))
      destination = format("/tmp/%s", format("%s.sh", var.aws_ec2_instance_script_file_name))
    },
    {
      name        = "additional_custom_data"
      source      = abspath(format("../modules/ec2/userdata/%s", var.aws_ec2_instance_script_file_name))
      destination = "/tmp/userdata"
    }
  ]
  custom_tags = {
    Name    = "ec2-instance-01"
    Version = "1"
    Owner   = "c.klewar@f5.com"
  }
}
```

### VPC

### EKS

## GCP Modules

### Compute

## Azure Modules

### Linux Virtual Machine

__Module Usage Example__

```hcl
  source = "../modules/azure/virtual_machine"
```
  f5xc_aws_vpc_no_worker_nodes         = true
  f5xc_aws_vpc_use_http_https_port     = true
  f5xc_aws_vpc_use_http_https_port_sli = true
  public_ssh_key                       = "${file(var.ssh_public_key_file)}"
}

output "aws_vpc_id" {
  value = module.vpc.aws_vpc_id
}

output "aws_subnet_id" {
  value = module.subnet.aws_subnet_id
}

output aws_workload_private_ip {
  value = module.workload.private_ip
}
output aws_workload_public_ip {
  value = module.workload.public_ip
}