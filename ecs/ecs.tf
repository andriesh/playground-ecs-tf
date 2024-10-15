resource "aws_security_group" "security_group" {
 name   = "andrei-rusnac-ecs-sg1"
 vpc_id = data.aws_vpc.ecs-vpc.id
 tags = merge(module.common_tags.tags, { Name = "andrei-rusnac-ecs-sg1" })
 ingress {
   from_port   = 80
   to_port     = 80
   protocol    = "tcp"
   self        = "false"
   cidr_blocks = ["0.0.0.0/0"]
   description = "HTTP only"
 }

 egress {
   from_port   = 0
   to_port     = 0
   protocol    = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }
}

resource "aws_ecs_task_definition" "app_task" {
  family                   = "arusnac-randomquotes"
  network_mode              = "awsvpc"
  requires_compatibilities  = ["FARGATE"]
  cpu                       = "512"
  memory                    = "2048"
  execution_role_arn = data.aws_iam_role.ecs_task_execution_role.arn
  tags = merge(module.common_tags.tags, { Name = "andrei-rusnac-ecs-fargate" })

  container_definitions = jsonencode([{
    name      = "randomQuotes"
    image     = data.aws_ecr_image.my_image.image_uri
    cpu       = 512
    memory    = 2048
    essential = true
    portMappings = [{
      containerPort = 80
      hostPort      = 80
      protocol      = "tcp"
    }]
    environment = [
      {
        name  = "AppSettings__AppVersion"
        value = "0.0.1"
      },
      {
        name  = "AppSettings__EnvironmentName"
        value = "DEVELOPMENT"
      }
    ]
  }])
}

# ECS Cluster
resource "aws_ecs_service" "ecs_service" {
  name            = "arusnac-randomquotes-svc1"
  cluster         = aws_ecs_cluster.andrei_rusnac_cluster.id
  task_definition = aws_ecs_task_definition.app_task.arn
  launch_type     = "FARGATE"

  desired_count = 1

  network_configuration {
    subnets         = data.aws_subnets.ecs_subnets.ids
    security_groups = [data.aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  platform_version = "LATEST"

  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200

  deployment_controller {
    type = "ECS"
  }
#   enable_ecs_managed_tags = true
 tags = merge(module.common_tags.tags, { Name = "andrei-rusnac-ecs-fargate" })

force_new_deployment = true
  service_connect_configuration {
    enabled = false
  }

  load_balancer {
    target_group_arn = data.aws_alb_target_group.al_ecs_tg.arn
    container_name   = "randomQuotes"
    container_port   = 80
  }

}


output "ALB_address" {
  value = data.aws_alb.alb_ecs.dns_name
}