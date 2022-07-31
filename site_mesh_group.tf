module "smg" {
  source                          = "./modules/f5xc/site-mesh"
  f5xc_api_p12_file              = "cert/playground.staging.api-creds.p12"
  f5xc_api_ca_cert               = "cert/public_server_ca.crt"
  f5xc_api_url                   = "https://playground.staging.volterra.us/api"
  f5xc_namespace                 = "system"
  f5xc_tenant                    = "playground-wtppvaog"
  f5xc_virtual_site_name        = "mw-aws-azure-lab"
  f5xc_site_mesh_group_name     = "mw-aws-azure-lab"
  virtual_site_selector         = [ "site_mesh_group in (f5xc-aws-azure-lab)" ]
}

