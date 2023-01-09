
# 以下の名前でs3のバケットを作成するよ
resource "aws_s3_bucket" "this" {
  bucket = "yuyuyun.net-${local.name_prefix}-alb-log"

# s3の暗号化の設定を行う
# s3が管理するキーによって暗号化が行われる
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name = "yuyuyun.net-${local.name_prefix}-alb-log"
  }

# s3バケット内のbオブジェクトの保持期間を設定
  lifecycle_rule {
    # enabledをtrueにすると設定が有効になる
    enabled = true
    expiration {
      days = "90"
    }
  }
}

# 作ったバケットに対してポリシーを定義していく
resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "AWS" : "arn:aws:iam::${data.aws_elb_service_account.current.id}:root"
          },
          "Action" : "s3:PutObject",
          "Resource" : "arn:aws:s3:::${aws_s3_bucket.this.id}/*"
        },
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "delivery.logs.amazonaws.com"
          },
          "Action" : "s3:PutObject",
          "Resource" : "arn:aws:s3:::${aws_s3_bucket.this.id}/*",
          "Condition" : {
            "StringEquals" : {
              "s3:x-amz-acl" : "bucket-owner-full-control"
            }
          }
        },
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "delivery.logs.amazonaws.com"
          },
          "Action" : "s3:GetBucketAcl",
          "Resource" : "arn:aws:s3:::${aws_s3_bucket.this.id}"
        }
      ]
    }
  )
}