module "aws-site-1a" {
  source                      = "./aws"
  aws_region                  = "eu-north-1"
  aws_az_name                 = "eu-north-1a"
  name                        = "mw-site-aws-1a"
  vpc_cidr_block              = "100.64.16.0/22"
  outside_subnet_cidr_block   = "100.64.16.0/24"
  inside_subnet_cidr_block    = "100.64.17.0/24"
  workload_subnet_cidr_block  = "100.64.18.0/24"
  allow_cidr_blocks           = [ "100.64.15.0/24" ]
  site_mesh_group             = "f5xc-aws-azure-lab"
  f5xc_api_p12_file           = var.f5xc_api_p12_file
  f5xc_api_ca_cert            = var.f5xc_api_ca_cert
  f5xc_api_url                = var.f5xc_api_url
  f5xc_api_token              = var.f5xc_api_token
  owner_tag                   = var.owner_tag
}

output "aws-site-1a" {
  value = module.aws-site-1a
}
