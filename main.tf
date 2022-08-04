module "azure-site-1a" {
  source                      = "./azure"
  azure_region                = "westus2"
  azure_az                    = "1"
  name                        = "mwlab-azure-1a"
  vnet_cidr_block             = "100.64.16.0/22"
  outside_subnet_cidr_block   = "100.64.16.0/24"
  inside_subnet_cidr_block    = "100.64.17.0/24"
  workload_subnet_cidr_block  = "100.64.18.0/24"
  allow_cidr_blocks           = [ "100.64.15.0/24" ]
  site_mesh_group             = "mwlab-aws-azure-lab"
  f5xc_azure_creds            = var.f5xc_azure_creds
  f5xc_api_p12_file           = var.f5xc_api_p12_file
  f5xc_api_ca_cert            = var.f5xc_api_ca_cert
  f5xc_api_url                = var.f5xc_api_url
  f5xc_tenant                 = var.f5xc_tenant
  f5xc_api_token              = var.f5xc_api_token
  owner_tag                   = var.owner_tag
}

module "azure-site-1b" {
  source                      = "./azure"
  azure_region                = "westus2"
  azure_az                    = "2"
  name                        = "mwlab-azure-1b"
  vnet_cidr_block             = "100.64.16.0/22"
  outside_subnet_cidr_block   = "100.64.16.0/24"
  inside_subnet_cidr_block    = "100.64.17.0/24"
  workload_subnet_cidr_block  = "100.64.18.0/24"
  allow_cidr_blocks           = [ "100.64.15.0/24" ]
  site_mesh_group             = "mwlab-aws-azure-lab"
  f5xc_azure_creds            = var.f5xc_azure_creds
  f5xc_api_p12_file           = var.f5xc_api_p12_file
  f5xc_api_ca_cert            = var.f5xc_api_ca_cert
  f5xc_api_url                = var.f5xc_api_url
  f5xc_tenant                 = var.f5xc_tenant
  f5xc_api_token              = var.f5xc_api_token
  owner_tag                   = var.owner_tag
}

module "aws-site-2a" {
  source                      = "./aws"
  aws_region                  = "eu-north-1"
  aws_az_name                 = "eu-north-1a"
  name                        = "mwlab-aws-2a"
  vpc_cidr_block              = "100.64.16.0/22"
  outside_subnet_cidr_block   = "100.64.16.0/24"
  inside_subnet_cidr_block    = "100.64.17.0/24"
  workload_subnet_cidr_block  = "100.64.18.0/24"
  allow_cidr_blocks           = [ "100.64.15.0/24" ]
  site_mesh_group             = "mwlab-aws-azure-lab"
  f5xc_aws_cred               = var.f5xc_aws_cred
  f5xc_api_p12_file           = var.f5xc_api_p12_file
  f5xc_api_ca_cert            = var.f5xc_api_ca_cert
  f5xc_api_url                = var.f5xc_api_url
  f5xc_tenant                 = var.f5xc_tenant
  f5xc_api_token              = var.f5xc_api_token
  owner_tag                   = var.owner_tag
}

output "azure-site-1a" {
  value = module.azure-site-1a
}

#output "aws-site-4a" {
#  value = module.aws-site-4a
#}


