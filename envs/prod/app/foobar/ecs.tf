resource "aws_ecs_cluster" "this" {
  name = "${local.name_prefix}-${local.service_name}"
  # ECSのタスクを実行するインフラを決める。fargateを使うからfargateにする
  capacity_providers = [ 
    "FARGATE",
    # fargate_spotという仕組みを使って中断する可能性はあるけど、７割引の料金でfargateを使える
    "FARGATE_SPOT"
  ]
  tags ={
    Name = "${local.name_prefix}-${local.service_name}"
  }
}