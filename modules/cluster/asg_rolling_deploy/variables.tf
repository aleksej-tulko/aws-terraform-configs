variable "cluster_name" {
  description = "The name to use for all the cluster resources"
  type = string
}

variable ami {
  description = "The AMI to run in the cluster"
  default = "ami-06878d265978313ca"
  type = string
}

variable "instance_type" {
  description = "Instance type"
  type = string
  default = "t2.micro"
}

variable "min_size" {
  description = "The minimum number of EC2 Instances in the ASG"
  type        = number
}

variable "max_size" {
  description = "The maximum number of EC2 Instances in the ASG"
  type        = number
}

variable "enable_autoscaling" {
  description = "If set to true, enable autoscaling"
  type = bool
}

variable "custom_tags" {
  description = "Custom tags for spots"
  type = map(string)
  default = {}
}

variable "server_port" {
  description = "HTTP port"
  type = number
  default = 80
}

locals {
  http_port = 80
  any_port = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  all_ips = ["0.0.0.0/0"]
}

variable "target_group_arns" {
  description = "The ARNs of ELB target groups in which to register Instances"
  type        = list(string)
  default     = []
}

variable "health_check_type" {
  description = "The type of health check to perform. Must be one of: EC2, ELB."
  type        = string
  default     = "EC2"
}

variable "user_data" {
  description = "The User Data script to run in each Instance at boot"
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "The subnet IDs to deploy to"
  type        = list(string)
}