resource "aws_cloudwatch_log_group" "ecs_logs" {
  name = "${var.project_name}-ecs_logs"
  retention_in_days = var.retention_in_days
}