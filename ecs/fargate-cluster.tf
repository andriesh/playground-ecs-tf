# Create the ECS Fargate Cluster with Container Insights enabled
resource "aws_ecs_cluster" "andrei_rusnac_cluster" {
  name = "andrei-rusnac-fargate-cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  tags = merge(module.common_tags.tags, { Name = "andrei-rusnac-fargate" })
}

resource "aws_service_discovery_private_dns_namespace" "ecs_namespace" {
  name        = "andrei-rusnac-ecs-ns"
  vpc        = data.aws_vpc.ecs-vpc.id
  description = "Private DNS namespace for ECS Fargate services."
}

