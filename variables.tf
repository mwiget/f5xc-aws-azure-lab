variable "f5xc_api_token" {
  type = string
}

variable "owner_tag" {
  type = string
  default = "owner unknown"
}

variable "ssh_public_key_file" {
  type = string
  default = "~/.ssh/id_rsa.pub"
}
