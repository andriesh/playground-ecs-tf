data "aws_vpc" "ecs-vpc" {
  filter {
    name   = "tag:Name"
    values = ["andrei-rusnac-vpc"]
  }
}

data "aws_security_group" "ecs-sg" {
  filter {
    name = "tag:Name"
    values = [ "andrei-rusnac-ecs-sg1" ]
  }
}

data "aws_subnets" "ecs_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.ecs-vpc.id]
  }
}

###
resource "aws_lb" "ecs-alb" {
  name               = "andrei-rusnac-ecs-alb"
  internal           = false
  load_balancer_type = "application"
    security_groups    = [data.aws_security_group.ecs-sg.id]
    subnets            = data.aws_subnets.ecs_subnets.ids

  enable_deletion_protection = false

#   access_logs {
#     bucket  = aws_s3_bucket.lb_logs.id
#     prefix  = "andrei-rusnac-alb"
#     enabled = true
#   }

  tags = merge(module.common_tags.tags, { Name = "andrei-rusnac-ecs-alb" })
}

############## ALB Listener

resource "aws_lb_target_group" "front_end" {
  name     = "andrei-rusnac-alb-tg1"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.ecs-vpc.id
  tags = merge(module.common_tags.tags, { Name = "andrei-rusnac-ecs-alb-tg" })
  target_type = "ip"
  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/"
    unhealthy_threshold = "2"
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.ecs-alb.arn
  port              = "80"
  protocol          = "HTTP"
  tags = merge(module.common_tags.tags, { Name = "andrei-rusnac-ecs-alb" })
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.front_end.arn
  }
}

output "load-balancer" {
  value = aws_lb.ecs-alb.dns_name
}