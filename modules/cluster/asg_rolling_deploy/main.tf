resource "aws_launch_configuration" "user-data" {
  image_id = var.ami
  instance_type = var.instance_type
  security_groups = [aws_security_group.spots.id]
  user_data = var.user_data

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  count = var.enable_autoscaling ? 1 : 0
  autoscaling_group_name = aws_autoscaling_group.server.name
  scheduled_action_name  = "${var.cluster_name}-scale-out-during-business-hours"
  max_size = 1
  min_size = 1
  desired_capacity = 1
  recurrence = "0 9 * * *"
}

resource "aws_autoscaling_schedule" "scale_out_during_night_hours" {
  count = var.enable_autoscaling ? 1 : 0
  autoscaling_group_name = aws_autoscaling_group.server.name
  scheduled_action_name  = "${var.cluster_name}-scale-out-during-night-hours"
  max_size = 0
  min_size = 0
  desired_capacity = 0
  recurrence = "0 17 * * *"
}

resource "aws_autoscaling_group" "server" {
  name = "${var.cluster_name}-${aws_launch_configuration.user-data.name}"
  launch_configuration = aws_launch_configuration.user-data.id
  vpc_zone_identifier = data.aws_subnets.server_net.ids
  target_group_arns = var.target_group_arns
  min_elb_capacity = 1
  max_size = var.max_size
  min_size = var.min_size
  desired_capacity = 2
  lifecycle {
    create_before_destroy = true
  }
  tag {
    key = "Name"
    propagate_at_launch = true
    value = "terraform_server"
  }
  dynamic "tag" {
    for_each = var.custom_tags
    content {
      key = tag.key
      value = tag.value
      propagate_at_launch = true
    }
  }
}

### VPC and subnets
data "aws_vpc" "server_net" {
  default = true
}

data "aws_subnets" "server_net" {
}

resource "aws_security_group" "spots" { #ASG security group which accepts requests from ALB to 80 port
  name = "${var.cluster_name}-instance"
  ingress {
    from_port = local.http_port
    protocol = local.tcp_protocol
    to_port = local.http_port
    cidr_blocks = local.all_ips
  }
  tags = {
    Name = "terraform"
  }
}

# Cloudwatch metrics
resource "aws_cloudwatch_metric_alarm" "high_cpu_utilization" {
  alarm_name = "${var.cluster_name}-high-cpu-utilization"
  namespace = "AWS/EC2"
  metric_name = "CPUUtilization"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.server.name
  }
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  period = 300
  statistic = "Average"
  threshold = 90
  unit = "Percent"
}

resource "aws_cloudwatch_metric_alarm" "low_cpu_credit_balance" {
  count = format("%.2s", var.instance_type) == "t2" ? 1 : 0
  alarm_name = "${var.cluster_name}-low-cpu-credit-balance"
  namespace = "AWS/EC2"
  metric_name = "CPUCreditBalance"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.server.name
  }
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  period = 300
  statistic = "Minimum"
  threshold = 10
  unit = "Count"
}