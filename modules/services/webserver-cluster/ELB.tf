### ALB
resource "aws_lb" "server_alb" {
  name = "server-load-balancer"
  load_balancer_type = "application"
  subnets = data.aws_subnet_ids.server_net.ids
  security_groups = [aws_security_group.alb.id]
}
resource "aws_lb_listener" "http" {
  port = var.server_port
  load_balancer_arn = aws_lb.server_alb.arn
  default_action {
    type = "fixed-response"
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