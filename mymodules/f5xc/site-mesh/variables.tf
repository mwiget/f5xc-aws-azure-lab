variable "f5xc_api_url" {
  type = string
}

variable "f5xc_api_cert" {
  default = ""
}

variable "f5xc_api_key" {
  default = ""
}

variable "f5xc_api_ca_cert" {
  default = ""
}

variable "f5xc_api_p12_file" {
  type = string
}

variable "f5xc_tenant" {
  type = string
}

variable "f5xc_namespace" {
  type = string
}

variable "f5xc_virtual_site_name" {
  type = string
}

variable "f5xc_site_mesh_group_name" {
  type = string
}

variable "virtual_site_selector" {
  type = list(string)
}

