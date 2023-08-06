module "asg" {
  source = "../../cluster/asg_rolling_deploy"

  cluster_name  = "hello-world-${var.environment}"
  ami           = var.ami
  user_data     = (
    length(data.template_file.user_data[*]) > 0
      ? data.template_file.user_data[0].rendered
      : data.template_file.new-user_data[0].rendered
  )
  instance_type = var.instance_type

  min_size           = var.min_size
  max_size           = var.max_size
  enable_autoscaling = var.enable_autoscaling

  subnet_ids        = data.aws_subnet_ids.default.ids
  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"

  custom_tags = var.custom_tags
}

module "alb" {
  source = "../../networking/alb"

  alb_name   = "hello-world-${var.environment}"
  subnet_ids = data.aws_subnet_ids.default.ids
}

data "terraform_remote_state" "db" {
  backend = "s3"
  config = {
    bucket = var.db_remote_state_bucket
    key = var.db_remote_state_key
    region = "us-east-1"
  }
}

data "template_file" "user_data" {
  count = var.enable_new_user_data ? 0 : 1
  template = file("${path.module}/user-data.sh")

  vars = {
    server_port = var.server_port
    db_address  = data.terraform_remote_state.db.outputs.address
    db_port     = data.terraform_remote_state.db.outputs.port
    server_text = var.server_text
  }
}

data "template_file" "new-user_data" {
  count = var.enable_new_user_data ? 1 : 0
  template = file("${path.module}/new-user-data.sh")

  vars = {
    server_port = var.server_port
  }
}

resource "aws_lb_listener_rule" "asg" {
  tags = {
    Name = "Bebra"
  }
  listener_arn = module.alb.alb_http_listener_arn
  priority = 50
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
  port = local.http_port
  protocol = "HTTP"
  vpc_id = data.aws_vpc.default.id
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

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}