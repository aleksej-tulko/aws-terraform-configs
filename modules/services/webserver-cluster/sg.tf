resource "aws_security_group" "server" { #ASG security group which accepts requests from ALB to 80 port
  ingress {
    from_port = var.server_port
    protocol = "tcp"
    to_port = var.server_port
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "terraform"
  }
}
resource "aws_security_group" "alb" { #ALB security group which forwards requests from balancer 80 port to spots 80 port
  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "terraform"
  }
}