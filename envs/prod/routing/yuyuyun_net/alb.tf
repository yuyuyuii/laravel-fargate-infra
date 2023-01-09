resource "aws_lb" "this" {
  # 指定した数だけリソースを作成する
  # enable_albがtrueの時のみ作成かつ、1つだけ作成する
  count = var.enable_alb ? 1 : 0

  name = "${local.name_prefix}-yuyuyun-net"
  # trueにすると内部ロードバランサーになる。trueにすると外部向けのロードバランサーになる
  internal = false
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