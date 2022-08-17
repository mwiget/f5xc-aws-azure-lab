resource "volterra_healthcheck" "hc" {
  name      = var.name
  namespace = var.namespace

  http_health_check {
    use_origin_server_name = true
    path                   = "/"
  }
  healthy_threshold   = 1
  interval            = 15
  timeout             = 1
  unhealthy_threshold = 2
}

resource "volterra_origin_pool" "op" {
  name                   = var.name
  namespace              = var.namespace
  endpoint_selection     = "DISTRIBUTED"
  loadbalancer_algorithm = "LB_OVERRIDE"
  port                   = var.origin_port
  no_tls                 = true

  dynamic "origin_servers" {
    for_each = var.origin_servers
    content {
      private_ip {
        ip = var.origin_servers[origin_servers.key].ip
        inside_network = true
        site_locator {
          site {
            namespace = "system"
            name      = origin_servers.key
          }
        }
      }
    }
  }

  advanced_options {
    disable_outlier_detection = false
    outlier_detection {
      base_ejection_time = 10000
      consecutive_5xx = 2
      consecutive_gateway_failure = 2
      interval = 5000
      max_ejection_percent = 100
    }
  }

  healthcheck {
    name = volterra_healthcheck.hc.name
  }
}

resource "volterra_http_loadbalancer" "lb" {
  name                            = var.name
  namespace                       = var.namespace
  no_challenge                    = true
  domains                         = var.domains

  disable_rate_limit              = true
  service_policies_from_namespace = true
  disable_waf                     = true

  advertise_custom {
    dynamic "advertise_where" {
      for_each = var.advertise_sites
      content {
        port = var.advertise_port
        site {
          ip = var.advertise_vip
          network = "SITE_NETWORK_INSIDE"
          site {
            name      = advertise_where.value
            namespace = "system"
          }
        }
      }
    }
  }

  default_route_pools {
    pool {
      name = volterra_origin_pool.op.name
    }
    weight = 1
    priority = 1
  }

  http {
    dns_volterra_managed = false
  }

  depends_on = [ volterra_origin_pool.op ]
}
