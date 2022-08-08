resource "volterra_virtual_site" "vs" {
  name      = var.f5xc_virtual_site_name
  namespace = "shared"

  site_selector {
    expressions = var.virtual_site_selector
  }

  site_type = "CUSTOMER_EDGE"
}

resource "volterra_site_mesh_group" "sg" {
  name        = var.f5xc_site_mesh_group_name
  namespace   = var.f5xc_namespace
  tunnel_type = "SITE_TO_SITE_TUNNEL_IPSEC"
  type        = "SITE_MESH_GROUP_TYPE_FULL_MESH"
  virtual_site {
    name = volterra_virtual_site.vs.name
    namespace = "shared"
  }
}

