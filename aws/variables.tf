variable "aws_region" {
  type = string
}

variable "aws_az_name" {
  type = string
}

variable "name" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "outside_subnet_cidr_block" {
  type = string
}

variable "inside_subnet_cidr_block" {
  type = string
}

variable "workload_subnet_cidr_block" {
  type = string
}

variable "owner_tag" {
  type = string
}

variable "ssh_public_key_file" {
  type = string
  default = "~/.ssh/id_rsa.pub"
}

variable "allow_cidr_blocks" {
  type = list(string)
}

variable "site_mesh_group" {
  type = string
  default = ""
}

#####

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

