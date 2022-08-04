variable "name" {
  type = string
}

variable "size" {
  type = string
  default = "Standard_DS1_v2"
}

variable "zone" {
  type = number
  default = 1
}

variable "username" {
  type = string
  default = "azueruser"
}

variable "custom_data" {
  type = string
  default = ""
}

variable "ssh_key" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "azure_region" {
  type = string
}

variable "resource_group_name" {
  type = string
}
