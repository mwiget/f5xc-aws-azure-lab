module "apps_site1" {
  count                   = 1
  source                  = "./apps"
  namespace               = volterra_namespace.ns.name
  name                    = "mwlabs-site1"
  domains                 = ["workload.site1"]
  advertise_port          = 80
  origin_port             = 8080
  origin_servers          = {
    "mwlab-azure-1a": { ip = one(module.azure-site-1a[*].workload.private_ip) },
    "mwlab-azure-1b": { ip = one(module.azure-site-1b[*].workload.private_ip) }
  }
  advertise_vip           = "10.64.15.254"
  advertise_sites         = [ 
    "mwlab-azure-1a",  "mwlab-azure-1b",
    "mwlab-aws-2a",    "mwlab-aws-2b",
    "mwlab-gcp-3a",    "mwlab-gcp-3b"
  ]
  depends_on = [ module.azure-site-1a, module.azure-site-1b ]
}

module "apps_site2" {
  count                   = 1
  source                  = "./apps"
  namespace               = volterra_namespace.ns.name
  name                    = "mwlabs-site2"
  domains                 = ["workload.site2"]
  advertise_port          = 80
  origin_port             = 8080
  origin_servers          = {
    "mwlab-aws-2a": { ip = one(module.aws-site-2a[*].aws_workload_private_ip) },
    "mwlab-aws-2b": { ip = one(module.aws-site-2b[*].aws_workload_private_ip) }
  }
  advertise_vip           = "10.64.15.254"
  advertise_sites         = [ 
    "mwlab-azure-1a",  "mwlab-azure-1b",
    "mwlab-aws-2a",    "mwlab-aws-2b",
    "mwlab-gcp-3a",    "mwlab-gcp-3b"
  ]
  depends_on = [ module.aws-site-2a, module.aws-site-2b ]
}

module "apps_site3" {
  count                   = 1
  source                  = "./apps"
  namespace               = volterra_namespace.ns.name
  name                    = "mwlabs-site3"
  domains                 = ["workload.site3"]
  advertise_port          = 80
  origin_port             = 8080
  origin_servers          = {
    "mwlab-gcp-3a": { ip = one(module.gcp-site-3a[*].workload.private_ip) },
    "mwlab-gcp-3b": { ip = one(module.gcp-site-3b[*].workload.private_ip) }
  }
  advertise_vip           = "10.64.15.254"
  advertise_sites         = [ 
    "mwlab-azure-1a",  "mwlab-azure-1b",
    "mwlab-aws-2a",    "mwlab-aws-2b",
    "mwlab-gcp-3a",    "mwlab-gcp-3b"
  ]
  depends_on = [ module.gcp-site-3a, module.gcp-site-3b ]
}

