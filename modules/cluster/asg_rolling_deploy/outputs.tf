output "asg_name" {
  value = aws_autoscaling_group.server.name
  description = "The name of the Autoscaling Group"
}

output "instance_security_group_id" {
  value = aws_autoscaling_group.server.id
  description = "The ID of the Autoscaling Group"
}