variable "workload_user_data" {
  type = string
}

variable "f5xc_aws_cred" {
  type = string
}

variable "f5xc_api_url" {
  type = string
}

variable "f5xc_api_token" {
  type = string
}

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

variable "custom_tags" {
  type = map(string)
  default = {}
}

variable "f5xc_tenant" {
  type = string
}

