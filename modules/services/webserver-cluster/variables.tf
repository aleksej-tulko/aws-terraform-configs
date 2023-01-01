### Variables
variable "instance_type" {
  description = "Instance type"
  type = string
  default = "t2.micro"
}

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

variable "give_neo_full_cloudwatch_acccess" {
  description = "If true, Neo will get full access to Cloudwatch"
  type = bool
  default = true
}

variable "enable_new_user_data" {
  description = "If true, use the new script"
  type = bool
}

variable "custom_tags" {
  description = "Custom tags for spots"
  type = map(string)
  default = {}
}

variable "enable_autoscaling" {
  description = "If set to true, enable autoscaling"
  type = bool
}

### Locals
locals {
  http_port = 80
  any_port = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  all_ips = ["0.0.0.0/0"]
}

#page 177
variable "hero_thousand_faces" {
  description = "map"
  type = map(string)
  default = {
    neo = "hero"
    trinity = "love interest"
    morpheus = "mentor"
  }
}