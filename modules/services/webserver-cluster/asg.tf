# Get user data
data "template_file" "user-data" {
  template = file("${path.module}/user-data/user-data.sh")
  vars = {
    db_address = data.terraform_remote_state.db.outputs.address
    db_port= data.terraform_remote_state.db.outputs.port
    server_port = var.server_port
    server_text = var.server_text
  }
}

resource "aws_launch_configuration" "user-data" {
  image_id = var.ami
  instance_type = var.instance_type
  security_groups = [aws_security_group.spots.id]
  user_data = data.template_file.user-data.rendered

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
  depends_on = [aws_lb.server_alb]
  launch_configuration = aws_launch_configuration.user-data.id
  vpc_zone_identifier = data.aws_subnets.server_net.ids
  target_group_arns = [aws_lb_target_group.asg.arn] #integration beteween ASG and ALB. A set of aws_alb_target_group ARNs, for use with Application or Network Load Balancing.
  health_check_type = "ELB"
  min_elb_capacity = 1
  max_size = 2
  min_size = 0
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