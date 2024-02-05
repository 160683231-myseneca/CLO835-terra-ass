terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.27"
    }
  }

  required_version = ">=0.14"
}

provider "aws" {
  region = "us-east-1"
}

data "terraform_remote_state" "rm_nw_state" {
  backend = "s3"
  config = {
    bucket = "bucket-sanah"
    key    = "network/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "rm_web_state" {
  backend = "s3"
  config = {
    bucket = "bucket-sanah"
    key    = "webserver/terraform.tfstate"
    region = "us-east-1"
  }
}

resource "aws_lb" "app_lb" {
  name               = "${var.prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = data.terraform_remote_state.rm_nw_state.outputs.public_subnet_ids

  enable_deletion_protection = false

  tags = merge(
    var.default_tags, {
      Name = "${var.prefix}-App_Load_Balancer"
    }
  )
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: Not Found"
      status_code  = "404"
    }
  }

  tags = merge(
    var.default_tags, {
      Name = "${var.prefix}-lb-front_end"
    }
  )
}

resource "aws_security_group" "alb_sg" {
  name        = "${var.prefix}-alb-sg"
  description = "Security group for ALB"
  vpc_id      = data.terraform_remote_state.rm_nw_state.outputs.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.default_tags, {
      Name = "${var.prefix}-ALB_security_group"
    }
  )
}

resource "aws_lb_target_group" "blue" {
  name     = "blue"
  port     = 8081
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.rm_nw_state.outputs.vpc_id
}

resource "aws_lb_target_group" "pink" {
  name     = "pink"
  port     = 8082
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.rm_nw_state.outputs.vpc_id
}

resource "aws_lb_target_group" "lime" {
  name     = "lime"
  port     = 8083
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.rm_nw_state.outputs.vpc_id
}

resource "aws_lb_listener_rule" "blue" {
  listener_arn = aws_lb_listener.front_end.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue.arn
  }

  condition {
    path_pattern {
      values = ["/blue*"]
    }
  }
}

resource "aws_lb_listener_rule" "pink" {
  listener_arn = aws_lb_listener.front_end.arn
  priority     = 101

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.pink.arn
  }

  condition {
    path_pattern {
      values = ["/pink*"]
    }
  }
}

resource "aws_lb_listener_rule" "lime" {
  listener_arn = aws_lb_listener.front_end.arn
  priority     = 102

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lime.arn
  }

  condition {
    path_pattern {
      values = ["/lime*"]
    }
  }
}

resource "aws_lb_target_group_attachment" "blue_attachment" {
  for_each         = toset(data.terraform_remote_state.rm_web_state.outputs.ec2_ids)
  target_group_arn = aws_lb_target_group.blue.arn
  target_id        = each.value
  port             = 8081
}

resource "aws_lb_target_group_attachment" "pink_attachment" {
  for_each         = toset(data.terraform_remote_state.rm_web_state.outputs.ec2_ids)
  target_group_arn = aws_lb_target_group.pink.arn
  target_id        = each.value
  port             = 8082
}

resource "aws_lb_target_group_attachment" "lime_attachment" {
  for_each         = toset(data.terraform_remote_state.rm_web_state.outputs.ec2_ids)
  target_group_arn = aws_lb_target_group.lime.arn
  target_id        = each.value
  port             = 8083
}