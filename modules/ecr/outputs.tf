output "ecr_repository_this_repository_url" {
  value = aws_ecr_repository.this.repository_url
}

output "lb_taget_group_foobar_arn" {
  value = aws_lb_target_group.foobar.arn
}