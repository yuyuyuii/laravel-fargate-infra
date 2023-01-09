# 以下を使用して、AWSがELBの管理をしているAWSアカウントを参照できる様になる
data "aws_elb_service_account" "current" {}