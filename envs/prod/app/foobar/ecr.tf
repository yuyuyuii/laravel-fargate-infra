# モジュール呼び出し
module "nginx" {
  source = "../../../../modules/ecr"
  name = "example-prod-foobar-nginx"
}

# PHP用のモジュール作成
module "php" {
  source = "../../../../modules/ecr/"
  name = "example-prod-foobar-php"
}