### Variables
variable "server_port" {
  description = "HTTP port"
  type = number
  default = 80
}

variable "cluster_name" {
  description = "The name to use for all the cluster resources"
  type = string
}

variable "db_remote_state_bucket" {
  description = "The name of s3 bucket for the database remote state"
  type = string
}

variable "db_remote_state_key" {
  description = "The path for the database remote state in s3"
  type = string
}

variable "user_names" {
  description = "Create IAM users with this names"
  type = list(string)
  default = ["neo", "trinity", "morpheus"]
}

variable "custom_tags" {
  description = "Custom tags for spots"
  type = map(string)
  default = {}
}

### Locals
locals {
  http_port = 80
  any_port = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  all_ips = ["0.0.0.0/0"]
}