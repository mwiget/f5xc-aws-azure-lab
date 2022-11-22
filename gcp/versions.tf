terraform {
  required_version = ">= 1.2.3"

  required_providers {
    volterra = {
      source  = "volterraedge/volterra"
      version = "0.11.14"
    }

    google = {
      source  = "hashicorp/google"
      version = ">= 4.31.0"
    }

    local = ">= 2.2.3"
    null  = ">= 3.1.1"
  }
}
