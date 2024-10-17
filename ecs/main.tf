# Declare universal project tags
module "common_tags" {
    source = "../modules/tags"
}

data "aws_vpc" "ecs-vpc" {
  filter {
    name   = "tag:Name"
    values = ["andrei-rusnac-vpc"]
  }
}

data "aws_ecr_repository" "ecr_repo" {
  name = "andrei-rusnac-ecr"
}

data "aws_ecr_image" "my_image" {
  repository_name = data.aws_ecr_repository.ecr_repo.name
  # image_tag      = "latest"
  most_recent     = true
}

data "aws_iam_role" "ecs_task_execution_role" {
    name = "ecsTaskExecutionRole" 
}
data "aws_iam_role" "ecs_task_role" {
    name = "ecsTaskExecution" 
}
data "aws_iam_role" "ecs_service_role" {
  name = "ecsServiceRole"
}

data "aws_security_group" "ecs_sg" {
  filter {
    name   = "tag:Name"
    values = ["andrei-rusnac-ecs-sg1"]
  }
  vpc_id = data.aws_vpc.ecs-vpc.id
}

data "aws_subnets" "ecs_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.ecs-vpc.id]
  }
}

data "aws_alb" "alb_ecs" {
    name = "andrei-rusnac-ecs-alb"
}

data "aws_alb_target_group" "al_ecs_tg" {
  name = "andrei-rusnac-alb-tg1"
}

data "aws_iam_role" "ecs_autoscale_role" {
  name = "ecsAutoscaleRole"
}



resource "aws_cloudwatch_log_group" "log_group" {
  name              = var.log_group_name
  retention_in_days = var.retention_days
}

resource "aws_cloudwatch_log_stream" "log_stream" {
  name           = "ecs"
  log_group_name = aws_cloudwatch_log_group.log_group.name
}

output "log_group_arn" {
  value = aws_cloudwatch_log_group.log_group.arn
}