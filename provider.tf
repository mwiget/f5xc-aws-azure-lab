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

provider "aws" {
  alias = "eu_north_1"
  region = "eu-north-1"
}

provider "aws" {
  alias = "us_west_2"
  region = "us-west-2"
}

provider "google" {
  alias = "europe_west6"
  region  = "europe-west6"
  project = var.gcp_project_id
  credentials = file("~/.config/gcloud/application_default_credentials.json")
}
