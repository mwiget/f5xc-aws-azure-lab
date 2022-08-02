module "apps_1a_to_234" {
  source            = "./modules/f5xc/apps"
  providers         = { volterra = volterra.default }
  namespace         = volterra_namespace.ns.name
  name              = "mw-apps1a-to-234"
  origin_port       = 8080
  origin_servers    = {
    "mw-azure-site-2a": { ip = element(module.azure_workload_2a[*].output.private_ip,0) },
    "mw-azure-site-2b": { ip = element(module.azure_workload_2b[*].output.private_ip,0) },
    "mw-aws-site-3a"  : { ip = element(module.aws_workload_3a[*].private_ip,0) },
    "mw-aws-site-3b"  : { ip = element(module.aws_workload_3b[*].private_ip,0) },
    "mw-aws-site-4a"  : { ip = element(module.aws_workload_4a[*].private_ip,0) },
    "mw-aws-site-4b"  : { ip = element(module.aws_workload_4b[*].private_ip,0) }
  }
  domains           = ["workload.example"]
  advertise_site    = "mw-azure-site-1a"
  advertise_vip     = "100.64.15.254"
  advertise_port    = 80
}

module "apps_1b_to_234" {
  source            = "./modules/f5xc/apps"
  providers         = { volterra = volterra.default }
  namespace         = volterra_namespace.ns.name
  name              = "mw-apps1b-to-234"
  origin_port       = 8080
  origin_servers    = {
    "mw-azure-site-2a": { ip = element(module.azure_workload_2a[*].output.private_ip,0) },
    "mw-azure-site-2b": { ip = element(module.azure_workload_2b[*].output.private_ip,0) },
    "mw-aws-site-3a"  : { ip = element(module.aws_workload_3a[*].private_ip,0) },
    "mw-aws-site-3b"  : { ip = element(module.aws_workload_3b[*].private_ip,0) },
    "mw-aws-site-4a"  : { ip = element(module.aws_workload_4a[*].private_ip,0) },
    "mw-aws-site-4b"  : { ip = element(module.aws_workload_4b[*].private_ip,0) }
  }
  domains           = ["workload.example"]
  advertise_site    = "mw-azure-site-1b"
  advertise_vip     = "100.64.15.254"
  advertise_port    = 80
}
