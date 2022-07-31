module "aws_site_4a" {
  source                          = "./modules/f5xc/site/aws/vpc"
  f5xc_api_p12_file              = "cert/playground.staging.api-creds.p12"
  f5xc_api_ca_cert               = "cert/public_server_ca.crt"
  f5xc_api_url                   = "https://playground.staging.volterra.us/api"
  f5xc_namespace                 = "system"
  f5xc_tenant                    = "playground-wtppvaog"
  f5xc_aws_region                 = "eu-north-1"
  f5xc_aws_cred                   = "mw-aws-f5"
  f5xc_aws_vpc_site_name          = "mw-aws-site-4a"
  f5xc_aws_vpc_name_tag           = ""
  f5xc_aws_vpc_id                 = module.aws_vpc_4.aws_vpc_id
  f5xc_aws_vpc_total_worker_nodes = 0
  f5xc_aws_ce_gw_type             = "single_nic"
  aws_owner_tag                   = var.owner_tag
  f5xc_aws_vpc_az_nodes           = {
    node0 : { 
      f5xc_aws_vpc_id           = module.aws_vpc_4.aws_vpc_id,
      f5xc_aws_vpc_local_subnet = module.aws_subnet_4.aws_subnet_id[0], 
      f5xc_aws_vpc_az_name      = "eu-north-1a" }
  }
  f5xc_aws_default_ce_os_version       = true
  f5xc_aws_default_ce_sw_version       = true
  f5xc_aws_vpc_no_worker_nodes         = false
  f5xc_aws_vpc_use_http_https_port     = true
  f5xc_aws_vpc_use_http_https_port_sli = true
  public_ssh_key                       = "${file(var.ssh_public_key_file)}"
}

module "aws_site_4b" {
  source                          = "./modules/f5xc/site/aws/vpc"
  f5xc_api_p12_file              = "cert/playground.staging.api-creds.p12"
  f5xc_api_ca_cert               = "cert/public_server_ca.crt"
  f5xc_api_url                   = "https://playground.staging.volterra.us/api"
  f5xc_namespace                 = "system"
  f5xc_tenant                    = "playground-wtppvaog"
  f5xc_aws_region                 = "eu-north-1"
  f5xc_aws_cred                   = "mw-aws-f5"
  f5xc_aws_vpc_site_name          = "mw-aws-site-4b"
  f5xc_aws_vpc_name_tag           = ""
  f5xc_aws_vpc_id                 = module.aws_vpc_4.aws_vpc_id
  f5xc_aws_vpc_total_worker_nodes = 0
  f5xc_aws_ce_gw_type             = "single_nic"
  aws_owner_tag                   = var.owner_tag
  f5xc_aws_vpc_az_nodes           = {
    node0 : { 
      f5xc_aws_vpc_id           = module.aws_vpc_4.aws_vpc_id,
      f5xc_aws_vpc_local_subnet = module.aws_subnet_4.aws_subnet_id[1], 
      f5xc_aws_vpc_az_name      = "eu-north-1b" }
  }
  f5xc_aws_default_ce_os_version       = true
  f5xc_aws_default_ce_sw_version       = true
  f5xc_aws_vpc_no_worker_nodes         = false
  f5xc_aws_vpc_use_http_https_port     = true
  f5xc_aws_vpc_use_http_https_port_sli = true
  public_ssh_key                       = "${file(var.ssh_public_key_file)}"
}

module "site_status_check_4a" {
  source            = "./modules/f5xc/status/site"
  f5xc_api_url      = "https://playground.staging.volterra.us/api"
  f5xc_api_token    = var.f5xc_api_token
  f5xc_namespace    = "system"
  f5xc_tenant       = "playground-wtppvaog"
  f5xc_site_name    = "mw-aws-site-4a"
  depends_on        = [module.aws_site_4a]
}

module "site_status_check_4b" {
  source            = "./modules/f5xc/status/site"
  f5xc_api_url      = "https://playground.staging.volterra.us/api"
  f5xc_api_token    = var.f5xc_api_token
  f5xc_namespace    = "system"
  f5xc_tenant       = "playground-wtppvaog"
  f5xc_site_name    = "mw-aws-site-4b"
  depends_on        = [module.aws_site_4b]
}

module "aws_workload_4a" {
  source                = "./modules/aws/ec2ubuntu"
  aws_ec2_instance_name = "mw-aws-site-4a"
  aws_ec2_instance_type = "t3.micro"
  aws_region            = "eu-north-1"
  aws_vpc_id            = module.aws_vpc_4.aws_vpc_id
  aws_subnet_id         = module.aws_subnet_4.aws_subnet_id[0]
  aws_owner_tag         = var.owner_tag
  ssh_public_key        = file(var.ssh_public_key_file)
  user_data             = file("./workload_custom_data.sh")
  allow_cidr_blocks     = [ "100.0.0.0/8" ]
}

module "aws_workload_4b" {
  source                = "./modules/aws/ec2ubuntu"
  aws_ec2_instance_type = "t3.micro"
  aws_ec2_instance_name = "mw-aws-site-4b"
  aws_region            = "eu-north-1"
  aws_owner_tag         = var.owner_tag
  aws_vpc_id            = module.aws_vpc_4.aws_vpc_id
  aws_subnet_id         = module.aws_subnet_4.aws_subnet_id[1]
  ssh_public_key        = file(var.ssh_public_key_file)
  user_data             = file("./workload_custom_data.sh")
  allow_cidr_blocks     = [ "100.0.0.0/8" ]
}

module "aws_vpc_4" {
  source               = "./modules/aws/vpc"
  aws_vpc_cidr_block   = "100.64.16.0/22"
  aws_vpc_name         = "mw-aws-site-4"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"
  instance_tenancy     = "default"
  aws_region           = "eu-north-1"
  aws_owner_tag        = var.owner_tag
}

module "aws_subnet_4" {
  source               = "./modules/aws/subnet"
  aws_region           = "eu-north-1"
  aws_vpc_id                  = module.aws_vpc_4.aws_vpc_id
  aws_vpc_subnets      = [
    { 
      cidr_block = "100.64.16.0/24", availability_zone = "eu-north-1a",
      map_public_ip_on_launch = "true", custom_tags = { "Name" = "mw-aws-site-4" }
    },
    { 
      cidr_block = "100.64.17.0/24", availability_zone = "eu-north-1b",
      map_public_ip_on_launch = "true", custom_tags = { "Name" = "mw-aws-site-4" }
    }
  ]
}

output "aws_vpc_4_id" {
  value = module.aws_vpc_4.aws_vpc_id
}
output "aws_subnet_4" {
  value = module.aws_subnet_4.aws_subnet_id
}

output aws_workload_4a_private_ip {
    value = module.aws_workload_4a.private_ip
}
output aws_workload_4a_public_ip {
    value = module.aws_workload_4a.public_ip
}
output aws_workload_4b_private_ip {
    value = module.aws_workload_4b.private_ip
}
output aws_workload_4b_public_ip {
    value = module.aws_workload_4b.public_ip
}

