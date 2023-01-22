# 自分のAWSアカウントIDが参照できるので、アカウントIDをハードコードで記載しなくて済む
data "aws_caller_identity" "self" {}
data "aws_region" "current" {}

