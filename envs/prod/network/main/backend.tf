terraform {
  backend "s3" {
    bucket = "00-laravel-fargate-app-tfstate"
    key = "example/prod/network/main_v1.0.0.tfstate"
    region = "ap-northeast-1"
  }
}