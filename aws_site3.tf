module "aws_vpc_3" {
  source               = "./modules/aws/vpc"
  aws_vpc_cidr_block   = "100.64.16.0/22"
  aws_vpc_name         = "mw-aws-site-3"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"
  instance_tenancy     = "default"
  aws_region           = "us-west-2"
  custom_tags          = { "owner" = "Marcel Wiget" }
}

module "aws_subnet_3a" {
  source               = "./modules/aws/subnet"
  aws_vpc_id                  = module.aws_vpc_3.aws_vpc_id
  aws_vpc_subnets         = [
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

