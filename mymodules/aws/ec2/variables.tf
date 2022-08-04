variable "ssh_public_key" {
  type    = string
}

variable "aws_ec2_instance_name" {
  type = string
}

variable "aws_ec2_instance_type" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "aws_vpc_id" {
  type = string
}

variable "aws_subnet_id" {
  type = string
}

variable "user_data" {
  type = string
}

variable "aws_owner_tag" {
  type = string
}

variable "allow_cidr_blocks" {
  type = list(string)
}

variable "custom_tags" {
  description = "Custom tags to set on resources"
  type        = map(string)
  default     = {}
}
