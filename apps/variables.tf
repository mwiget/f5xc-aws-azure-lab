variable "namespace" {}
variable "name" {}

variable "origin_port" {
  type = number
  default = 8080
}

variable "advertise_port" {
  type = number
  default = 80
}

variable "advertise_vip" {
  type = string
}

variable "advertise_sites" {
  type = list(string)
}

variable "origin_servers" {
  type = map(map(string))
}

variable "domains" {
  type = list(string)
}
