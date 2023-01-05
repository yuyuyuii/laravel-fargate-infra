resource "aws_acm_certificate" "root" {
  # 発行するドメイン名を指定
  domain_name = data.aws_route53_zone.this.name
  # ドメインの所有権の検証を"DNS"か"EMAIL"どちらで検証をするか指定。
  validation_method = "DNS"
  tags = {
    Name = "${local.name_prefix}-yuyuyun-net"
  }

  # デフォはリソースを再作成するときに古いリソースを削除してから、新しいリソースを作成する
  # 以下をtrueにすると新しいリソースを作成してから古いリソースを削除する様になる。trueにしとくのが推奨
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "root" {
  certificate_arn = aws_acm_certificate.root.arn
}