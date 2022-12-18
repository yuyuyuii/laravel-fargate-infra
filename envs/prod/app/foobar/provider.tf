provider "aws" {
  region = "ap-northeast-1"
}

terraform {
  required_provider {
    aws = {
      source = "hashicorp/aws"
      version = "3.42.0"
    }
  }
}