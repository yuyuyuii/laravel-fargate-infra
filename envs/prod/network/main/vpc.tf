resource "aws_vpc" "this" {
  # variables.tfで定義した値を定義
  cidr_block = var.vpc_cidr
  # プライベートホストゾーンで名前解決を有効にする場合は、以下の二つをtrueにする
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    "Name" = "${local.name_prefix}-main"
  }
}