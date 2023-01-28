resource "aws_ecs_cluster" "this" {
  name = "${local.name_prefix}-${local.service_name}"
  # ECSのタスクを実行するインフラを決める。fargateを使うからfargateにする
  capacity_providers = [
    "FARGATE",
    # fargate_spotという仕組みを使って中断する可能性はあるけど、７割引の料金でfargateを使える
    "FARGATE_SPOT"
  ]
  tags = {
    Name = "${local.name_prefix}-${local.service_name}"
  }
}

resource "aws_ecs_task_definition" "this" {
  # タスク定義の名前を指定
  family = "${local.name_prefix}-${local.service_name}"
  # タスクロールのARNを指定。使わない場合は省略できる
  task_role_arn = aws_iam_role.ecs_task.arn
  # コンテナで使用するDockerネットワーキングモードを指定する。Fargateはaws_vpcを指定
  network_mode = "awsvpc"
  # ECSの起動タイプを指定。FargateはFARGATEを指定
  requires_compatibilities = [
    "FARGATE"
  ]
  # タスク実行ロールのARN
  execution_role_arn = aws_iam_role.ecs_task_execution.arn
  # メモリとCPUを指定
  memory = "512"
  cpu    = "256"
  # タスクで動かす各コンテナの設定(nginx, phpの設定を記述)
  container_definitions = jsonencode(
    [
      {
        # コンテナ名
        name = "nginx"
        # コンテナで使用するイメージとURL, タグを指定。各ECRの最新を使用する
        image = "${module.nginx.ecr_repository_this_repository_url}:latest"
        # どのポート, プロトコルを使用するか
        portMappings = [
          {
            containerPort = 80
            protocol      = "tcp"
          }
        ]
        # コンテナに渡す環境変数
        enviroment = []
        # パラメータストア又は、Secret Managetを指定するとその値がコンテナに環境変数として渡される
        secret = []
        # phpのコンテナが起動したら、nginxのコンテナも起動
        depends_on = [
          {
            containerName = "php"
            condition     = "START"
          }
        ]
        # ボリュームのマウントポイントを指定
        mountPoints = [
          {
            containerPath = "/var/run/php-fpm"
            sourceVolume  = "php-fpm-socket"
          }
        ]
        # コンテナのログ設定。logDriverに"awslogs"を指定するとCloudWatch logにコンテナのログが出力される
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = "/ecs/${local.name_prefix}-${(local.service_name)}/nginx"
            awslogs-region        = data.aws_region.current.id
            awslogs-stream-prefix = "ecs"
          }
        }
      },
      {
        name         = "php"
        image        = "${module.php.ecr_repository_this_repository_url}:latest"
        portMappings = []
        enviroment   = []
        secrets = [
          {
            name      = "APP_KEY"
            valueFrom = "/${local.system_name}/${local.env_name}/${local.service_name}/APP_KEY"
          }
        ]
        mountPoints = [
          {
            containerPath = "/var/run/php-fpm"
            sourceVolume  = "php-fpm-socket"
          }
        ]
        logConfigration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = "/ecs/${local.name_prefix}-${local.service_name}/php"
            awslogs-region        = data.aws_region.current.id
            awslogs-stream-prefix = "ecs"
          }
        }
      }
    ]
  )
  volume {
    name = "php-fpm-socket"
  }
  tags = {
    name = "${local.name_prefix}-${local.service_name}"
  }
}

resource "aws_ecs_service" "this" {
  # ECSサービス名
  name = "${local.name_prefix}-${local.service_name}"
  # 属するECSクラスターのARNを指定
  cluster = aws_ecs_cluster.this.arn

  capacity_provider_strategy {
    # キャパシティプロバイダーを指定
    capacity_provider = "FARGATE_SPOT"
    # 実行する最小限のタスク数を指定
    base = 0
    # 比率を指定できるが、キャパシティプロバイダーをSPOTのみとしているので、1としているが特に意味ない。
    weight = 1
  }
  # Fargateのバージョン
  platform_version = "1.4.0"
  # タスク定義のARNを指定
  task_definition = aws_ecs_task_definition.this.arn
  # 起動させておくタスク数
  desired_count = var.desired_count
  # 最低いくつタスクを起動させておくかをパーセントで指定する。今回は(desire_count分)1個起動させておくので,100%だと最低1個は起動した状態になる
  deployment_minimum_healthy_percent = 100
  # 上記の逆。最大幾つ起動させとくか
  deployment_maximum_percent = 200

  # 使用するロードバランサーの設定
  load_balancer {
    # ロードバランサーがトラフィックがフォワードするコンテナ、ポートを指定
    container_name = "nginx"
    container_port = 80
    # タスクを登録するターゲットグループのARNを指定
    target_group_arn = data.terraform_remote_state.routing_appfoobar_link.outputs.lb_target_group_foobar_arn
  }
  # ヘルスチェックで異常が出た時、以上の状態を無視しておく秒数を指定
  health_check_grace_period_seconds = 60

  # タスクのネットワーク設定
  network_configuration {
    # 今回はプライベートサブネットで起動させるので、パブリックIPは割り当てない
    assign_public_ip = false
    security_groups = [
      data.terraform_remote_state.network_main.outputs.security_group_vpc_id
    ]
    subnets = [
      for s in data.terraform_remote_state.network_main.outputs.subnet_private : s.id
    ]
  }

  enable_execute_command = true

  tags = {
    Name = "${local.name_prefix}-${local.service_name}"
  }
}