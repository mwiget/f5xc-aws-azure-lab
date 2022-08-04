module "vpc" {
  source                = "../mymodules/aws/vpc"
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
  source                = "../mymodules/aws/subnet"
  aws_vpc_id           = module.vpc.aws_vpc_id
  aws_vpc_subnets      = [
    { 
      cidr_block = var.outside_subnet_cidr_block, availability_zone = var.aws_az_name,
      map_public_ip_on_launch = "true", custom_tags = { "Name" = "${var.name}-outside" }
    },
    { 
      cidr_block = var.inside_subnet_cidr_block, availability_zone = var.aws_az_name,
      map_public_ip_on_launch = "false", custom_tags = { "Name" = "${var.name}-inside" }
    },
    { 
      cidr_block = var.workload_subnet_cidr_block, availability_zone = var.aws_az_name,
      map_public_ip_on_launch = "true", custom_tags = { "Name" = "${var.name}-workload" }
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
  source                          = "../mymodules/f5xc/site/aws/vpc"
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
      f5xc_aws_vpc_id               = module.vpc.aws_vpc_id,
      f5xc_aws_vpc_outside_subnet   = module.subnet.aws_subnet_id[0], 
      f5xc_aws_vpc_inside_subnet    = module.subnet.aws_subnet_id[1], 
      f5xc_aws_vpc_workload_subnet  = module.subnet.aws_subnet_id[2], 
      f5xc_aws_vpc_az_name        = var.aws_az_name
    }
  }
  f5xc_aws_default_ce_os_version       = true
  f5xc_aws_default_ce_sw_version       = true
  f5xc_aws_vpc_no_worker_nodes         = true
  f5xc_aws_vpc_use_http_https_port     = true
  f5xc_aws_vpc_use_http_https_port_sli = true
  public_ssh_key                       = "${file(var.ssh_public_key_file)}"
  depends_on                           = [module.subnet]
}

module "site_status_check" {
  source            = "../modules/f5xc/status/site"
  f5xc_namespace    = "system"
  f5xc_site_name    = var.name
  f5xc_api_url      = var.f5xc_api_url
  f5xc_api_token    = var.f5xc_api_token
  f5xc_tenant       = var.f5xc_tenant
  depends_on        = [module.site]
}

data "aws_network_interface" "slo" {
  filter { 
    name    = "tag:ves-io-site-name"
    values  = [ var.name ]
  }
  filter { 
    name    = "tag:ves.io/interface-type"
    values  = [ "site-local-outside" ]
  }
  depends_on        = [module.site_status_check]
}

data "aws_network_interface" "sli" {
  filter { 
    name    = "tag:ves-io-site-name"
    values  = [ var.name ]
  }
  filter { 
    name    = "tag:ves.io/interface-type"
    values  = [ "site-local-inside" ]
  }
  depends_on        = [module.site_status_check]
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

output "sli_private_ip" {
  value = data.aws_network_interface.sli.private_ip
  depends_on = [module.site_status_check]
}
output "slo_private_ip" {
  value = data.aws_network_interface.slo.private_ip
  depends_on = [module.site_status_check]
}
output "slo_public_ip" {
  value = data.aws_network_interface.slo.association[0]["public_ip"]
  depends_on = [module.site_status_check]
}

#output "test" {
#  value = module.subnet.aws_subnet_id[0]
#}
