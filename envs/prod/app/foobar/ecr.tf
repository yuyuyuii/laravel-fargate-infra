# モジュール呼び出し
module "nginx" {
  source = "../../../../modules/ecr"
  name = "example-prod-foobar-nginx"
}