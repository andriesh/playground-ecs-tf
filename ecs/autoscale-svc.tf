resource "aws_appautoscaling_target" "target" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.andrei_rusnac_cluster.name}/${aws_ecs_service.ecs_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  role_arn           = data.aws_iam_role.ecs_autoscale_role.arn
  min_capacity       = 1
  max_capacity       = 2
  tags = merge(module.common_tags.tags, { Name = "andrei-rusnac-ecs-fargate" })
}

# Automatically scale capacity up by one
resource "aws_appautoscaling_policy" "up" {
  name               = "cb_scale_up"
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.andrei_rusnac_cluster.name}/${aws_ecs_service.ecs_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 10
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }

  depends_on = [aws_appautoscaling_target.target]
}

# Automatically scale capacity down by one
resource "aws_appautoscaling_policy" "down" {
  name               = "cb_scale_down"
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.andrei_rusnac_cluster.name}/${aws_ecs_service.ecs_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 10
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = -1
    }
  }
  
  depends_on = [aws_appautoscaling_target.target]
}

# CloudWatch alarm that triggers the autoscaling up policy
resource "aws_cloudwatch_metric_alarm" "service_cpu_high" {
  alarm_name          = "cb_cpu_utilization_high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "70"

  dimensions = {
    ClusterName = aws_ecs_cluster.andrei_rusnac_cluster.name
    ServiceName = aws_ecs_service.ecs_service.name
  }
  tags = merge(module.common_tags.tags, { Name = "andrei-rusnac-ecs-fargate" })
  alarm_actions = [aws_appautoscaling_policy.up.arn]
}

# CloudWatch alarm that triggers the autoscaling down policy
resource "aws_cloudwatch_metric_alarm" "service_cpu_low" {
  alarm_name          = "cb_cpu_utilization_low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "70"

  dimensions = {
    ClusterName = aws_ecs_cluster.andrei_rusnac_cluster.name
    ServiceName = aws_ecs_service.ecs_service.name
  }
  tags = merge(module.common_tags.tags, { Name = "andrei-rusnac-ecs-fargate" })
  alarm_actions = [aws_appautoscaling_policy.down.arn]
}
