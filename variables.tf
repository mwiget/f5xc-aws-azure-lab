variable "f5xc_api_url" {
  type = string
}

variable "f5xc_api_cert" {
  default = ""
}

variable "f5xc_tenant" {
  type = string
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

variable "f5xc_azure_creds" {
  type = string
}

variable "f5xc_aws_cred" {
  type = string
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

