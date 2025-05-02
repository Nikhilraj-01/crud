output "log_group_name" {
  value = aws_cloudwatch_log_group.ecs_logs.name
}

output "log_group_arn" {
  value = aws_cloudwatch_log_group.ecs_logs.arn
}