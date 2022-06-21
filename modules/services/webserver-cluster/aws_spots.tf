### ASG
resource "aws_launch_configuration" "server" {
  image_id = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.server.id]

  user_data = data.template_file.user-data.rendered
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_autoscaling_group" "server" {
  launch_configuration = aws_launch_configuration.server.name
  vpc_zone_identifier = data.aws_subnet_ids.server_net.ids
  target_group_arns = [aws_lb_target_group.asg.arn] #integration beteween ASG and ALB. A set of aws_alb_target_group ARNs, for use with Application or Network Load Balancing.
  health_check_type = "ELB"
  max_size = 2
  min_size = 0
  desired_capacity = 2
  tag {
    key = "Name"
    propagate_at_launch = true
    value = "terraform_server"
  }
}