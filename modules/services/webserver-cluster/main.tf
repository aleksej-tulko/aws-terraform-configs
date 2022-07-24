#Save state in S3 bucket
terraform {
  backend "s3" {
    bucket = "aleksej-terraform-state"
    key = "stage/services/webserver-cluster/terraform.tfstate"
    region = "us-east-2"
    dynamodb_table = "aleksej-terraform-state"
    encrypt = true
  }
}

### IAM users
resource "aws_iam_user" "test" {
  name = each.value
  for_each = toset(var.user_names)
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
resource "aws_launch_configuration" "server" {
  image_id = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.spots.id]

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
    region = "us-east-2"
  }
}
# Get user data
data "template_file" "user-data" {
  template = file("${path.module}/user-data.sh")
  vars = {
    db_address = data.terraform_remote_state.db.outputs.address
    db_port= data.terraform_remote_state.db.outputs.port
    server_port = var.server_port
  }
}