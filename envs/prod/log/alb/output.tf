# ALBを作成する際に、s3バケットのIDが必要なので参照できるように以下を定義
output "s3_bucket_this_id" {
  value = aws_s3_bucket.this.id
}
