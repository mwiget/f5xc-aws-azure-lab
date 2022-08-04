variable "name" {
  type = string
}

variable "azure_vnet_name" {
  type = string
}

variable "address_prefix" {
  type = string
}

variable "resource_group_name" {
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
