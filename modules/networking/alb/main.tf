### ALB
resource "aws_lb" "server_alb" {
  name = var.alb_name
  load_balancer_type = "application"
  subnets = var.subnet_ids
  security_groups = [aws_security_group.alb.id]
}

resource "aws_lb_listener" "http" {
  port = local.http_port
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

resource "aws_security_group" "alb" {
  name = var.alb_name
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