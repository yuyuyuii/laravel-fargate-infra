# モジュール呼び出し
module "nginx" {
  source = "../../../../modules/ecr"
  name   = "${local.name_prefix}-${local.service_name}-nginx"
}

# PHP用のモジュール作成
module "php" {
  source = "../../../../modules/ecr/"
  name   = "${local.name_prefix}-${local.service_name}-php"
}