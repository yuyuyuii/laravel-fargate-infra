# main.tfは各種リソース情報を定義していく
# output.出力を定義
# variables.tfは変数を定義

# resource内に記載してるvarはvariables.tf内の変数を参照してる
# 文字列内で変数を使用する場合は${}を使って変数展開する

resource "aws_ecr_repository" "this" {
  name = var.name
  tags = {
    "Name" = "var.name"
  }
}

resource "aws_ecr_lifecycle_policy" "this" {
  policy = jsonencode(
    {
      "rules": [
        {
          "rulePriority": 1,
          "description": "Hold only ${var.holding_count} images, expire all others",
          "selection": {
            "tagStatus": "any", 
            "countType": "imageCountMoreThan", 
            "countNumber": var.holding_count
          },
          "action": {
            "type": "expire"
          }
        }
      ]
    }
  )
  repository = aws_ecr_repository.this.name
}

