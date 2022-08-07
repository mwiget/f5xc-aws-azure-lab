module "apps_site1" {
  source                  = "./apps"
  providers               = { volterra = volterra.default }
  namespace               = volterra_namespace.ns.name
  name                    = "mwlabs-site1"
  domains                 = ["workload.site1"]
  advertise_port          = 80
  origin_port             = 8080
  origin_servers          = {
    "mwlab-azure-site-1a": { ip = module.azure-site-1a.workload.private_ip },
    "mwlab-azure-site-1b": { ip = module.azure-site-1b.workload.private_ip }
  }
  advertise_vip           = "100.64.15.254"
  advertise_sites         = [ 
    "mwlab-azure-site-1a",  "mwlab-azure-site-1b",
    "mwlab-aws-site-2a",    "mwlab-aws-site-2b",
    "mwlab-gcp-site-3a",    "mwlab-gcp-site-3b"
  ]
}

module "apps_site2" {
  source                  = "./apps"
  providers               = { volterra = volterra.default }
  namespace               = volterra_namespace.ns.name
  name                    = "mwlabs-site2"
  domains                 = ["workload.site2"]
  advertise_port          = 80
  origin_port             = 8080
  origin_servers          = {
    "mwlab-aws-site-2a": { ip = module.aws-site-2a.aws_workload_private_ip },
    "mwlab-aws-site-2b": { ip = module.aws-site-2b.aws_workload_private_ip }
  }
  advertise_vip           = "100.64.15.254"
  advertise_sites         = [ 
    "mwlab-azure-site-1a",  "mwlab-azure-site-1b",
    "mwlab-aws-site-2a",    "mwlab-aws-site-2b",
    "mwlab-gcp-site-3a",    "mwlab-gcp-site-3b"
  ]
}

module "apps_site3" {
  source                  = "./apps"
  providers               = { volterra = volterra.default }
  namespace               = volterra_namespace.ns.name
  name                    = "mwlabs-site3"
  domains                 = ["workload.site3"]
  advertise_port          = 80
  origin_port             = 8080
  origin_servers          = {
    "mwlab-gcp-site-3a": { ip = module.gcp-site-3a.workload.private_ip },
    "mwlab-gcp-site-3b": { ip = module.gcp-site-3b.workload.private_ip }
  }
  advertise_vip           = "100.64.15.254"
  advertise_sites         = [ 
    "mwlab-azure-site-1a",  "mwlab-azure-site-1b",
    "mwlab-aws-site-2a",    "mwlab-aws-site-2b",
    "mwlab-gcp-site-3a",    "mwlab-gcp-site-3b"
  ]
}

