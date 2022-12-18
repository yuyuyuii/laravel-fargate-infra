terraform {
  backend "s3" {
    bucket = "01-laravel-fargate-app-tfstate"        # S3に作成したバケット名を記載
    key    = "example/prod/app/foobar_1.0.0.tfstate" # 例としてexampleをシステム名/prod/app/foobar_terraformのバージョン.tfstate
    region = "ap-northeast-1"                        # 東京リージョンを指定
  }
}