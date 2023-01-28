resource "aws_lb" "this" {
  # 指定した数だけリソースを作成する
  # enable_albがtrueの時のみ作成かつ、1つだけ作成する
  count = var.enable_alb ? 1 : 0

  name = "${local.name_prefix}-yuyuyun-net"
  # trueにすると内部ロードバランサーになる。trueにすると外部向けのロードバランサーになる
  internal           = false
  load_balancer_type = "application"

  # アクセスログをs3に保存する場合は、以下の様に定義する。bucketは事前に作成したものを指定する
  access_logs {
    # S3のバケットIDを指定
    # terraform_remote_stateにつけたlog_alb.log/albのoutputs.tfのバケット名
    bucket = data.terraform_remote_state.log_alb.outputs.s3_bucket_this_id
    # trueにするとアクセスロゴを保存する
    enabled = true
    # 保存するログ名に以下のprefixをつける
    prefix = "yuyuyun-net"
  }

  # ALBにつけるセキュリティグループをlist形式で指定
  # http, httpsの通信の許可とvpc内部の通信を許可。fargateにもvpcをつけてALBとfargateが通信できるようにする
  security_groups = [
    data.terraform_remote_state.network_main.outputs.security_group_web_id,
    data.terraform_remote_state.network_main.outputs.security_group_vpc_id
  ]

  # ALBが属するsubnetをlist形式で指定
  subnets = [
    for s in data.terraform_remote_state.network_main.outputs.subnet_public : s.id
  ]

  tags = {
    Name = "${local.name_prefix}-yuyuyun-net"
  }
}

resource "aws_lb_listener" "https" {
  count = var.enable_alb ? 1 : 0
  # protocolをhttpsを指定した場合はcertificate_arnが必要
  certificate_arn = aws_acm_certificate.root.arn
  # このリスナーに紐づくロードバランサーのarnを指定 
  load_balancer_arn = aws_lb.this[0].arn 
  port              = "443"
  protocol          = "HTTPS"
  # protocolにhttpsを指定したらssl_policyを指定うる必要あり。以下のやつはデフォルトで設定されるやつ
  ssl_policy = "ELBSecurityPolicy-2016-08"
  # ALBがリクエストを受け付けた時のデフォルトのアクションを指定
  default_action {
    # 固定のレスポンスを返すように指定
    # type = "fixed-response"
    # 動的になる様に修正
    type = "forward"
    # fixed_response{
    #   content_type = "text/plain"
    #   message_body = "Fixed response content"
    #   status_code = "200"
    # }
    target_group_arn = aws_lb_target_group.foobar.arn
  }
}

resource "aws_lb_listener" "redirect_http_to_https" {
  count             = var.enable_alb ? 1 : 0
  load_balancer_arn = aws_lb.this[0].arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_target_group" "foobar" {
  name                 = "${local.name_prefix}-foobar"
  deregistration_delay = 60
  port                 = 80
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = data.terraform_remote_state.network_main.outputs.vpc_this_id

  health_check {
    # ヘルスチェック連続成功回数
    healthy_threshold = 2
    # ヘルスチェックの間隔(秒)
    interval = 30
    # どんなステータスコードが帰ってきたら正常とみなすか
    matcher = 200
    # ヘルスチェックで使用するパス
    path = "/"

    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }
  tags = {
    Name = "${local.name_prefix}-foobar"
  }
}