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