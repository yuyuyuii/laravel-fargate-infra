terraform {
  backend "s3" {
    bucket = "tfstate用のS3バケット名"
    key = "example/prod/cicd/app_foobar_v1.0.0.tfstate"
    region = "ap-northeast-1"
  }
}