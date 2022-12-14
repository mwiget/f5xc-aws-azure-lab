terraform {
  required_version = ">= 1.2.3"

  required_providers {
    volterra = {
      source  = "volterraedge/volterra"
      version = "0.11.14"
    }

    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.20.1"
    }

    local = ">= 2.2.3"
    null  = ">= 3.1.1"
  }
}
