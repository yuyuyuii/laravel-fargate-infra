resource "aws_cloudwatch_log_group" "nginx" {
  name = "/ecs/${local.name_prefix}-${local.service_name}/nginx"
  # ログの保存期間
  retention_in_days = 90
}

resource "aws_cloudwatch_log_group" "php" {
  name = "/ecs/${local.name_prefix}-${local.service_name}/php"
  # ログの保存期間
  retention_in_days = 90
}