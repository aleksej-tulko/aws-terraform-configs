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
}