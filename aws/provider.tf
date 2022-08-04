provider "aws" {
  region = var.aws_region
}

provider "volterra" {
  alias        = "default"
  api_p12_file = var.f5xc_api_p12_file
  api_cert     = var.f5xc_api_p12_file != "" ? "" : var.f5xc_api_cert
  api_key      = var.f5xc_api_p12_file != "" ? "" : var.f5xc_api_key
  api_ca_cert  = var.f5xc_api_ca_cert
  url          = var.f5xc_api_url
}

provider "azurerm" {                                                                              
  subscription_id = var.azure_subscription_id != "" ? "" : var.azure_subscription_id
  client_id       = var.azure_client_id != "" ? "" : var.azure_client_id 
  client_secret   = var.azure_client_secret != "" ? "" : var.azure_client_secret
  tenant_id       = var.azure_tenant_id != "" ? "" : var.azure_tenant_id
  features {}
}
