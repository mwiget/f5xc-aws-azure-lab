module "aws_site_3a" {
  source                          = "./modules/f5xc/site/aws/vpc"
  f5xc_api_p12_file              = "cert/playground.staging.api-creds.p12"
  f5xc_api_ca_cert               = "cert/public_server_ca.crt"
  f5xc_api_url                   = "https://playground.staging.volterra.us/api"
  f5xc_namespace                 = "system"
  f5xc_tenant                    = "playground-wtppvaog"
  f5xc_aws_region                 = "us-west-2"
  f5xc_aws_cred                   = "mw-aws-f5"
  f5xc_aws_vpc_site_name          = "mw-aws-site-3a"
  f5xc_aws_vpc_name_tag           = ""
  f5xc_aws_vpc_id                 = module.aws_vpc_3.aws_vpc_id
  f5xc_aws_vpc_total_worker_nodes = 0
  f5xc_aws_ce_gw_type             = "single_nic"
  aws_owner_tag                   = var.owner_tag
  custom_tags                     = { "site_mesh_group" = "f5xc-aws-azure-lab" }
  f5xc_aws_vpc_az_nodes           = {
    node0 : { 
      f5xc_aws_vpc_id           = module.aws_vpc_3.aws_vpc_id,
      f5xc_aws_vpc_local_subnet = module.aws_subnet_3.aws_subnet_id[0], 
      f5xc_aws_vpc_az_name      = "us-west-2a" }
  }
  f5xc_aws_default_ce_os_version       = true
  f5xc_aws_default_ce_sw_version       = true
  f5xc_aws_vpc_no_worker_nodes         = false
  f5xc_aws_vpc_use_http_https_port     = true
  f5xc_aws_vpc_use_http_https_port_sli = true
  public_ssh_key                       = "${file(var.ssh_public_key_file)}"
}

module "aws_site_3b" {
  source                          = "./modules/f5xc/site/aws/vpc"
  f5xc_api_p12_file              = "cert/playground.staging.api-creds.p12"
  f5xc_api_ca_cert               = "cert/public_server_ca.crt"
  f5xc_api_url                   = "https://playground.staging.volterra.us/api"
  f5xc_namespace                 = "system"
  f5xc_tenant                    = "playground-wtppvaog"
  f5xc_aws_region                 = "us-west-2"
  f5xc_aws_cred                   = "mw-aws-f5"
  f5xc_aws_vpc_site_name          = "mw-aws-site-3b"
  f5xc_aws_vpc_name_tag           = ""
  f5xc_aws_vpc_id                 = module.aws_vpc_3.aws_vpc_id
  f5xc_aws_vpc_total_worker_nodes = 0
  f5xc_aws_ce_gw_type             = "single_nic"
  aws_owner_tag                   = var.owner_tag
  custom_tags                     = { "site_mesh_group" = "f5xc-aws-azure-lab" }
  f5xc_aws_vpc_az_nodes           = {
    node0 : { 
      f5xc_aws_vpc_id           = module.aws_vpc_3.aws_vpc_id,
      f5xc_aws_vpc_local_subnet = module.aws_subnet_3.aws_subnet_id[1], 
      f5xc_aws_vpc_az_name      = "us-west-2b" }
  }
  f5xc_aws_default_ce_os_version       = true
  f5xc_aws_default_ce_sw_version       = true
  f5xc_aws_vpc_no_worker_nodes         = false
  f5xc_aws_vpc_use_http_https_port     = true
  f5xc_aws_vpc_use_http_https_port_sli = true
  public_ssh_key                       = "${file(var.ssh_public_key_file)}"
}

module "site_status_check_3a" {
  source            = "./modules/f5xc/status/site"
  f5xc_api_url      = "https://playground.staging.volterra.us/api"
  f5xc_api_token    = var.f5xc_api_token
  f5xc_namespace    = "system"
  f5xc_tenant       = "playground-wtppvaog"
  f5xc_site_name    = "mw-aws-site-3a"
  depends_on        = [module.aws_site_3a]
}

module "site_status_check_3b" {
  source            = "./modules/f5xc/status/site"
  f5xc_api_url      = "https://playground.staging.volterra.us/api"
  f5xc_api_token    = var.f5xc_api_token
  f5xc_namespace    = "system"
  f5xc_tenant       = "playground-wtppvaog"
  f5xc_site_name    = "mw-aws-site-3b"
  depends_on        = [module.aws_site_3b]
}

module "aws_workload_3a" {
  source                = "./modules/aws/ec2ubuntu"
  aws_ec2_instance_name = "mw-aws-site-3a"
  aws_ec2_instance_type = "t3.micro"
  aws_region            = "us-west-2"
  aws_vpc_id            = module.aws_vpc_3.aws_vpc_id
  aws_subnet_id         = module.aws_subnet_3.aws_subnet_id[0]
  aws_owner_tag         = var.owner_tag
  ssh_public_key        = file(var.ssh_public_key_file)
  user_data             = file("./workload_custom_data.sh")
  allow_cidr_blocks     = [ "100.0.0.0/8" ]
}

module "aws_workload_3b" {
  source                = "./modules/aws/ec2ubuntu"
  aws_ec2_instance_type = "t3.micro"
  aws_ec2_instance_name = "mw-aws-site-3b"
  aws_region            = "us-west-2"
  aws_owner_tag         = var.owner_tag
  aws_vpc_id            = module.aws_vpc_3.aws_vpc_id
  aws_subnet_id         = module.aws_subnet_3.aws_subnet_id[1]
  ssh_public_key        = file(var.ssh_public_key_file)
  user_data             = file("./workload_custom_data.sh")
  allow_cidr_blocks     = [ "100.0.0.0/8" ]
}

module "aws_vpc_3" {
  source               = "./modules/aws/vpc"
  aws_vpc_cidr_block   = "100.64.16.0/22"
  aws_vpc_name         = "mw-aws-site-3"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"
  instance_tenancy     = "default"
  aws_region           = "us-west-2"
  aws_owner_tag        = var.owner_tag
}

module "aws_subnet_3" {
  source               = "./modules/aws/subnet"
  aws_region           = "us-west-2"
  aws_vpc_id           = module.aws_vpc_3.aws_vpc_id
  aws_vpc_subnets      = [
    { 
      cidr_block = "100.64.16.0/24", availability_zone = "us-west-2a",
      map_public_ip_on_launch = "true", custom_tags = { "Name" = "mw-aws-site-3" }
    },
    { 
      cidr_block = "100.64.17.0/24", availability_zone = "us-west-2b",
      map_public_ip_on_launch = "true", custom_tags = { "Name" = "mw-aws-site-3" }
    }
  ]
}

output "aws_vpc_3_id" {
  value = module.aws_vpc_3.aws_vpc_id
}
output "aws_subnet_3" {
  value = module.aws_subnet_3.aws_subnet_id
}

output aws_workload_3a_private_ip {
    value = module.aws_workload_3a.private_ip
}
output aws_workload_3a_public_ip {
    value = module.aws_workload_3a.public_ip
}
output aws_workload_3b_private_ip {
    value = module.aws_workload_3b.private_ip
}
output aws_workload_3b_public_ip {
    value = module.aws_workload_3b.public_ip
}

