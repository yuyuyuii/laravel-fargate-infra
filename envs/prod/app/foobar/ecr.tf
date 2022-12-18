resource "aws_ecr_repository" "nginx" {
  name = "example-prod-foobar-nginx"
  tags = {
    Name = "example-prod-foobar-nginx"
  }
}

# ecrは最新かそれに近いイメージを使うので、古いイメージは自動削除するようにライフサイクルを定義する 
resource "aws_ecr_lifecycle_policy" "nginx" {
  policy = jsonencode(
    {
      "rules" : [
        {
          "rulePriority": 1,
          "description": "Hold only 10 image, expire all others",
          "selection": {
            "tagStatus": "any",
            "countType": "imageCountMoreThan",
            "countNumber": 10
          },
          "action": {
            "type": "expire"
          }
        }
      ]
    }
  )
  repository = aws_ecr_repository.nginx.name
}