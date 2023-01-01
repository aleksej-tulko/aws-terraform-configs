provider "aws" {
  region = "us-east-1"
}
#Save state in S3 bucket
terraform {
  backend "s3" {
    bucket = "aws-block-terraform-state"
    key = "stage/services/webserver-cluster/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "aws-playground-terraform-state"
    encrypt = true
  }
}

### IAM users
resource "aws_iam_user" "test" {
  name = each.value
  for_each = toset(var.user_names)
}

resource "aws_iam_policy" "cloudwatch_read_only" {
  name = "cloudwatch_read_only"
  policy = data.aws_iam_policy_document.cloudwatch_read_only.json
}

resource "aws_iam_policy" "cloudwatch_full_access" {
  name = "cloudwatch_full_access"
  policy = data.aws_iam_policy_document.cloudwatch_full_access.json
}

data "aws_iam_policy_document" "cloudwatch_read_only" {
  statement {
    effect = "Allow"
    actions = [
    "cloudwatch:Describe",
    "cloudwatch:Get*",
    "cloudwatch:List*"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "cloudwatch_full_access" {
  statement {
    effect = "Allow"
    actions = [
      "cloudwatch:*"
    ]
    resources = ["*"]
  }
}

### VPC and subnets
data "aws_vpc" "server_net" {
  default = true
}
data "aws_subnet_ids" "server_net" {
  vpc_id = data.aws_vpc.server_net.id
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
resource "aws_security_group" "alb" {
  name = "${var.cluster_name}-alb"
  tags = {
    Name = "terraform"
  }
}
resource "aws_security_group_rule" "allow-http-inbound" {
  #ALB security group which forwards requests from balancer 80 port to spots 80 port
  type = "ingress"
  security_group_id = aws_security_group.alb.id
  from_port = local.http_port
  protocol = local.tcp_protocol
  to_port = local.http_port
  cidr_blocks = local.all_ips
}
resource "aws_security_group_rule" "allow-http-outbound" {
  type = "egress"
  security_group_id = aws_security_group.alb.id
  from_port = local.any_port
  protocol = local.any_protocol
  to_port = local.any_port
  cidr_blocks = local.all_ips
}
### ALB
resource "aws_lb" "server_alb" {
  name = "server-load-balancer"
  load_balancer_type = "application"
  subnets = data.aws_subnet_ids.server_net.ids
  security_groups = [aws_security_group.alb.id]
}
resource "aws_lb_listener" "http" {
  port = var.server_port
  load_balancer_arn = aws_lb.server_alb.arn #(Required, Forces New Resource) ARN of the load balancer.
  default_action { #(Required) Configuration block for default actions. By default return2 404
    type = "fixed-response" #(Required) Type of routing action. Valid values are forward, redirect, fixed-response, authenticate-cognito and authenticate-oidc
    fixed_response {
      content_type = "text/plain"
      message_body = "404: bebra"
      status_code = "404"
    }
  }
}
resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority = 100
  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
  condition {
    path_pattern {
      values = ["*"]
    }
  }
}
resource "aws_lb_target_group" "asg" {
  name = "terraform"
  port = var.server_port
  protocol = "HTTP"
  vpc_id = data.aws_vpc.server_net.id
  health_check {
    path  = "/"
    protocol = "HTTP"
    matcher = "200"
    interval = 15
    timeout = 3
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}

### ASG
#resource "aws_launch_configuration" "server" {
#  image_id = "ami-0574da719dca65348"
#  instance_type = "t2.micro"
#  security_groups = [aws_security_group.spots.id]
#
#  user_data = data.template_file.user-data.rendered
#  lifecycle {
#    create_before_destroy = true
#  }
#}
resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  count = var.enable_autoscaling ? 1 : 0
  autoscaling_group_name = aws_autoscaling_group.server.name
  scheduled_action_name  = "${var.cluster_name}-scale-out-during-business-hours"
  max_size = 1
  min_size = 0
  desired_capacity = 1
  recurrence = "0 9 * * *"
}
resource "aws_autoscaling_group" "server" {
  depends_on = [aws_lb.server_alb]
  launch_configuration = aws_launch_configuration.user-data.id
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
  dynamic "tag" {
    for_each = var.custom_tags
    content {
      key = tag.key
      value = tag.value
      propagate_at_launch = true
    }
  }
}
# Read DB
data "terraform_remote_state" "db" {
  backend = "s3"
  config = {
    bucket = var.db_remote_state_bucket
    key = var.db_remote_state_key
    region = "us-east-1"
  }
}
# Get user data
data "template_file" "user-data" {
  count = var.enable_new_user_data ? 0 : 1
  template = file("${path.module}/user-data.sh")
  vars = {
    db_address = data.terraform_remote_state.db.outputs.address
    db_port= data.terraform_remote_state.db.outputs.port
    server_port = var.server_port
  }
}

data "template_file" "user-data-new" {
  count = var.enable_new_user_data ? 1 : 0
  template = file("${path.module}/user-data-new.sh")
  vars = {
    server_port = var.server_port
  }
}

resource "aws_launch_configuration" "user-data" {
  image_id = "ami-0574da719dca65348"
  instance_type = var.instance_type
  security_groups = [aws_security_group.spots.id]

  user_data = (
    length(data.template_file.user-data[*]) > 0
      ? data.template_file.user-data[0].rendered
      : data.template_file.user-data-new[0].rendered
    )

  lifecycle {
    create_before_destroy = true
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