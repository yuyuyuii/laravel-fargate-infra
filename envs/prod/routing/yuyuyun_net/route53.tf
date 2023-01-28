data "aws_route53_zone" "this" {
  # 自分が取得してるドメイン
  name = "yuyuyun.net"
}

resource "aws_route53_record" "certificate_validation" {
  for_each = {
    for dvo in aws_acm_certificate.root.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }
  name    = each.value.name
  records = [each.value.record]
  ttl     = 60
  type    = each.value.type
  zone_id = data.aws_route53_zone.this.id
}

# terraformで管理してるドメインにアクセスしたときにALBに名前解決をしてくれるようにALIASレコードを作成
resource "aws_route53_record" "root_a" {
  count = var.enable_alb ? 1 : 0
  # 名前解決してほしいドメインを指定
  name = data.aws_route53_zone.this.name
  # レコードの種類を指定。ALIASの場合はAを指定
  type = "A"
  # 名前解決してほしいホストゾーンのIDを指定
  zone_id = data.aws_route53_zone.this.zone_id

  # ALIASレコードの場合、aliasブロックを定義して、ALBやDNS名、ゾーンIDを指定する
  alias {
    evaluate_target_health = true
    name                   = aws_lb.this[0].dns_name
    zone_id                = aws_lb.this[0].zone_id
  }
}