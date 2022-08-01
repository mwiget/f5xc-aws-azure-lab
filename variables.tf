variable "f5xc_api_url" {
  type = string
}

variable "f5xc_api_cert" {
  default = ""
}

variable "f5xc_api_token" {
  type = string
}

variable "f5xc_api_ca_cert" {
  default = ""
}

variable "f5xc_api_p12_file" {
  type = string
}

variable "f5xc_api_key" {
  type = string
  default = ""
}

variable "azure_subscription_id" {
  type = string
  default = ""
}

variable "azure_client_id" {
  type = string
  default = ""
}

variable "azure_client_secret" {
  type = string
  default = ""
}

variable "azure_tenant_id" {
  type = string
  default = ""
}

variable "owner_tag" {
  type = string
  default = "owner unknown"
}

variable "ssh_public_key_file" {
  type = string
  default = "~/.ssh/id_rsa.pub"
}

variable "enable_site" {
  type = map
  default = {
    "azure_site_1a" = true
    "azure_site_1b" = true
    "azure_site_2a" = true
    "azure_site_2b" = true
    "aws_site_3a" = true
    "aws_site_3b" = true
    "aws_site_4a" = true
    "aws_site_4b" = true
  }
}
